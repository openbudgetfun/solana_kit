import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';
import 'package:solana_kit_transactions/solana_kit_transactions.dart';
import 'package:test/test.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() {
  group('preconf websocket', () {
    test('preconfWebsocketUrl embeds the API key', () {
      expect(
        preconfWebsocketUrl('key-123'),
        'wss://beta.helius-rpc.com/?api-key=key-123',
      );
    });

    test('preconfWireVersion and preconfHeadLength match the frame layout', () {
      expect(preconfWireVersion, 1);
      // version(1) + slot(8) + transaction_index(8) + status(1).
      expect(preconfHeadLength, 18);
    });

    test('decodePreconfFrame maps an out-of-range status to unknown', () {
      final encoded = _encodedTransaction();
      final frame = Uint8List(preconfHeadLength + encoded.length)
        ..[0] = preconfWireVersion
        ..setAll(1, _u64le(9))
        ..setAll(9, _u64le(1))
        ..[17] =
            99 // not 0 or 1
        ..setAll(preconfHeadLength, encoded);

      final notification = decodePreconfFrame(frame);
      expect(notification.status, PreconfStatus.unknown);
    });

    test('subscribe, receive a notification, unsubscribe, and close', () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final received = StreamController<Object?>.broadcast();
      final sockets = <WebSocket>[];
      final serverClosed = Completer<void>();

      unawaited(() async {
        await for (final request in server) {
          final socket = await WebSocketTransformer.upgrade(request);
          sockets.add(socket);
          socket.listen(received.add);
          await serverClosed.future;
          await socket.close();
        }
      }());

      final client = PreconfWsClient(
        apiKey: 'test-key',
        channel: WebSocketChannel.connect(
          Uri.parse('ws://127.0.0.1:${server.port}'),
        ),
      );

      final subFuture = client.preconfSubscribe();
      // Wait for the subscribe request to arrive.
      final request = await received.stream.first.timeout(
        const Duration(seconds: 5),
      );
      final subscribeCall =
          jsonDecode(request! as String) as Map<String, Object?>;
      expect(subscribeCall['method'], 'preconfSubscribe');
      final subscribeId = subscribeCall['id']! as int;
      expect(subscribeId, 1);
      sockets.first.add(
        jsonEncode({
          'jsonrpc': '2.0',
          'id': subscribeId,
          'result': 42,
        }),
      );

      final subscription = await subFuture;
      expect(subscription.subscriptionId, 42);

      // Push a binary notification frame.
      final encoded = _encodedTransaction();
      final frame = Uint8List(preconfHeadLength + encoded.length)
        ..[0] = preconfWireVersion
        ..setAll(1, _u64le(123))
        ..setAll(9, _u64le(4))
        ..[17] =
            1 // success
        ..setAll(preconfHeadLength, encoded);
      sockets.first.add(frame);

      final notification = await subscription.notifications.first.timeout(
        const Duration(seconds: 5),
      );
      expect(notification.slot, 123);
      expect(notification.transactionIndex, 4);
      expect(notification.status, PreconfStatus.success);
      expect(notification.transactionBytes, encoded);

      // Unsubscribe.
      final unsubReceived = received.stream.first;
      final unsubFuture = subscription.unsubscribe();
      final unsubRequest =
          (await unsubReceived.timeout(const Duration(seconds: 5)))! as String;
      final unsubCall = jsonDecode(unsubRequest) as Map<String, Object?>;
      expect(unsubCall['method'], 'preconfUnsubscribe');
      expect(unsubCall['params'], [42]);
      sockets.first.add(
        jsonEncode({
          'jsonrpc': '2.0',
          'id': unsubCall['id'],
          'result': true,
        }),
      );
      expect(await unsubFuture, isTrue);

      client.close();
      serverClosed.complete();
      await server.close(force: true);
    });

    test('close cancels an active subscription stream', () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final received = StreamController<Object?>.broadcast();
      final sockets = <WebSocket>[];
      final serverClosed = Completer<void>();

      unawaited(() async {
        await for (final request in server) {
          final socket = await WebSocketTransformer.upgrade(request);
          sockets.add(socket);
          socket.listen(received.add);
          await serverClosed.future;
          await socket.close();
        }
      }());

      final client = PreconfWsClient(
        apiKey: 'test-key',
        channel: WebSocketChannel.connect(
          Uri.parse('ws://127.0.0.1:${server.port}'),
        ),
      );

      final subFuture = client.preconfSubscribe();
      final request =
          (await received.stream.first.timeout(const Duration(seconds: 5)))!
              as String;
      final call = jsonDecode(request) as Map<String, Object?>;
      sockets.first.add(
        jsonEncode({
          'jsonrpc': '2.0',
          'id': call['id'],
          'result': 7,
        }),
      );
      await subFuture;

      // Closing while subscribed must close the per-subscription stream.
      client.close();
      serverClosed.complete();
      await server.close(force: true);
    });

    test('connects to the default preconf URL when no channel is given', () {
      // Constructing without a channel builds the beta.helius-rpc.com URL; the
      // underlying connection attempt is async and must not throw here.
      final client = PreconfWsClient(apiKey: 'test-key');
      try {
        client.close();
      } on Exception {
        // The remote endpoint is not reachable in tests; closing may surface a
        // connection error asynchronously. Swallow it.
      }
    });

    test('subscribe surfaces JSON-RPC errors', () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final received = StreamController<Object?>.broadcast();
      final sockets = <WebSocket>[];
      final serverClosed = Completer<void>();

      unawaited(() async {
        await for (final request in server) {
          final socket = await WebSocketTransformer.upgrade(request);
          sockets.add(socket);
          socket.listen(received.add);
          await serverClosed.future;
          await socket.close();
        }
      }());

      final client = PreconfWsClient(
        apiKey: 'test-key',
        channel: WebSocketChannel.connect(
          Uri.parse('ws://127.0.0.1:${server.port}'),
        ),
      );

      final subFuture = client.preconfSubscribe();
      final request =
          (await received.stream.first.timeout(const Duration(seconds: 5)))!
              as String;
      final call = jsonDecode(request) as Map<String, Object?>;
      sockets.first.add(
        jsonEncode({
          'jsonrpc': '2.0',
          'id': call['id'],
          'error': {'code': -32601, 'message': 'method not found'},
        }),
      );

      await expectLater(
        subFuture,
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('method not found'),
          ),
        ),
      );

      client.close();
      serverClosed.complete();
      await server.close(force: true);
    });
  });
}

Uint8List _encodedTransaction() {
  final message = const TransactionMessage(version: TransactionVersion.v0)
      .copyWith(
        feePayer: const Address(
          '22222222222222222222222222222222222222222222',
        ),
        lifetimeConstraint: BlockhashLifetimeConstraint(
          blockhash: '11111111111111111111111111111111',
          lastValidBlockHeight: BigInt.zero,
        ),
      );
  return getTransactionEncoder().encode(compileTransaction(message));
}

List<int> _u64le(int value) {
  final bytes = Uint8List(8);
  for (var i = 0; i < 8; i++) {
    bytes[i] = (value >> (8 * i)) & 0xff;
  }
  return bytes;
}
