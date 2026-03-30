import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_rpc_subscriptions/solana_kit_rpc_subscriptions.dart';
import 'package:solana_kit_rpc_subscriptions_channel_websocket/solana_kit_rpc_subscriptions_channel_websocket.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:test/test.dart';

Future<(HttpServer, StreamController<String>, List<Object?>)>
_startServer() async {
  final requests = <Object?>[];
  final commands = StreamController<String>();
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);

  unawaited(() async {
    await for (final request in server) {
      final socket = await WebSocketTransformer.upgrade(request);
      commands.stream.listen(socket.add);
      socket.listen(requests.add);
    }
  }());

  return (server, commands, requests);
}

void main() {
  group('DefaultRpcSubscriptionsConfig', () {
    test('exposes confirmed as the default commitment', () {
      expect(
        DefaultRpcSubscriptionsConfig.defaultCommitment,
        Commitment.confirmed,
      );
    });

    test(
      'default integer overflow handler throws the standard SolanaError',
      () {
        expect(
          () => DefaultRpcSubscriptionsConfig.onIntegerOverflow(
            'slotNotifications',
            ['params', 'result'],
            BigInt.from(1) << 65,
          ),
          throwsA(
            isA<SolanaError>().having(
              (error) => error.code,
              'code',
              SolanaErrorCode.rpcIntegerOverflow,
            ),
          ),
        );
      },
    );
  });

  group('DefaultRpcSubscriptionsChannelConfig', () {
    test('uses documented default values', () {
      const config = DefaultRpcSubscriptionsChannelConfig(
        url: 'ws://localhost:8900',
      );

      expect(config.url, 'ws://localhost:8900');
      expect(config.allowInsecureWs, isFalse);
      expect(config.intervalMs, 5000);
      expect(config.maxSubscriptionsPerChannel, 100);
      expect(config.minChannels, 1);
      expect(config.sendBufferHighWatermark, 131072);
    });

    test('stores insecure override flag', () {
      const config = DefaultRpcSubscriptionsChannelConfig(
        url: 'ws://localhost:8900',
        allowInsecureWs: true,
      );
      expect(config.allowInsecureWs, isTrue);
    });
  });

  group('channel creator factories', () {
    test('accept ws/wss URLs (case-insensitive) and return creators', () {
      final wsCreator = createDefaultRpcSubscriptionsChannelCreator(
        const DefaultRpcSubscriptionsChannelConfig(url: 'ws://localhost:8900'),
      );
      final wssCreator = createDefaultSolanaRpcSubscriptionsChannelCreator(
        const DefaultRpcSubscriptionsChannelConfig(
          url: 'WSS://api.mainnet-beta.solana.com',
        ),
      );

      expect(wsCreator, isA<Function>());
      expect(wssCreator, isA<Function>());
    });

    test('rejects unsupported URL schemes', () {
      expect(
        () => createDefaultRpcSubscriptionsChannelCreator(
          const DefaultRpcSubscriptionsChannelConfig(
            url: 'https://api.mainnet-beta.solana.com',
          ),
        ),
        throwsA(
          isA<ArgumentError>().having(
            (error) => error.message.toString(),
            'message',
            allOf(contains("'ws'"), contains("'wss'"), contains('https')),
          ),
        ),
      );
    });

    test('rejects malformed URLs with no protocol match', () {
      expect(
        () => createDefaultSolanaRpcSubscriptionsChannelCreator(
          const DefaultRpcSubscriptionsChannelConfig(
            url: 'not-a-websocket-url',
          ),
        ),
        throwsA(
          isA<ArgumentError>().having(
            (error) => error.message.toString(),
            'message',
            contains('invalid'),
          ),
        ),
      );
    });

    test('creates channels that JSON-serialize outbound messages', () async {
      final (server, commands, requests) = await _startServer();
      addTearDown(() async {
        await commands.close();
        await server.close(force: true);
      });

      final creator = createDefaultRpcSubscriptionsChannelCreator(
        DefaultRpcSubscriptionsChannelConfig(
          url: 'ws://${server.address.address}:${server.port}',
          allowInsecureWs: true,
          intervalMs: 60000,
        ),
      );
      final abortController = AbortController();
      final channel = await creator(abortSignal: abortController.signal);
      addTearDown(abortController.abort);

      final nextMessage = Completer<Object?>();
      final unsubscribe = channel.on('message', nextMessage.complete);
      addTearDown(unsubscribe);

      await channel.send({'ping': 'pong'});
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(jsonDecode(requests.single! as String), {'ping': 'pong'});

      commands.add(jsonEncode({'hello': 'world'}));
      expect(await nextMessage.future, {'hello': 'world'});
    });
  });
}
