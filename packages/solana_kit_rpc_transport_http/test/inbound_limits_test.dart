import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_rpc_spec/solana_kit_rpc_spec.dart';
import 'package:solana_kit_rpc_transport_http/solana_kit_rpc_transport_http.dart';
import 'package:test/test.dart';

void main() {
  test(
    'stops an oversized chunked response before buffering all of it',
    () async {
      var chunksRead = 0;
      var cancelled = false;
      var decoded = false;
      final chunk = List<int>.filled(1024, 32);
      Stream<List<int>> response() async* {
        try {
          for (var i = 0; i < 20000; i++) {
            chunksRead++;
            yield chunk;
          }
        } finally {
          cancelled = true;
        }
      }

      final transport = createHttpTransport(
        HttpTransportConfig(
          url: 'https://example.com',
          fromJson: (_, _) {
            decoded = true;
            return null;
          },
        ),
        client: MockClient.streaming(
          (_, _) async => http.StreamedResponse(response(), 200),
        ),
      );

      await expectLater(
        transport(const RpcTransportConfig(payload: null)),
        throwsA(isA<InboundPayloadLimitException>()),
      );
      expect(chunksRead, lessThan(20000));
      expect(cancelled, isTrue);
      expect(decoded, isFalse);
    },
  );

  test('rejects deeply nested JSON before invoking a custom decoder', () async {
    var decoded = false;
    final body = '${'[' * 65}0${']' * 65}';
    final transport = createHttpTransport(
      HttpTransportConfig(
        url: 'https://example.com',
        fromJson: (_, _) {
          decoded = true;
          return null;
        },
      ),
      client: MockClient((_) async => http.Response(body, 200)),
    );

    await expectLater(
      transport(const RpcTransportConfig(payload: null)),
      throwsA(isA<InboundPayloadLimitException>()),
    );
    expect(decoded, isFalse);
  });

  test(
    'cancels an oversized Content-Length without waiting for body data',
    () async {
      var cancelled = false;
      final body = StreamController<List<int>>(
        onCancel: () => cancelled = true,
      );
      final transport = createHttpTransport(
        const HttpTransportConfig(
          url: 'https://example.com',
          inboundLimits: InboundPayloadLimits(maxBytes: 8),
        ),
        client: MockClient.streaming(
          (_, _) async =>
              http.StreamedResponse(body.stream, 200, contentLength: 9),
        ),
      );

      await expectLater(
        transport(const RpcTransportConfig(payload: null)),
        throwsA(isA<InboundPayloadLimitException>()),
      );
      expect(cancelled, isTrue);
      await body.close();
    },
  );

  test('does not trust an understated Content-Length', () async {
    var decoded = false;
    final transport = createHttpTransport(
      HttpTransportConfig(
        url: 'https://example.com',
        inboundLimits: const InboundPayloadLimits(maxBytes: 8),
        fromJson: (_, _) => decoded = true,
      ),
      client: MockClient.streaming(
        (_, _) async => http.StreamedResponse(
          Stream.value(List.filled(9, 32)),
          200,
          contentLength: 1,
        ),
      ),
    );

    await expectLater(
      transport(const RpcTransportConfig(payload: null)),
      throwsA(isA<InboundPayloadLimitException>()),
    );
    expect(decoded, isFalse);
  });

  test(
    'accepts a UTF-8 response exactly at its configured byte limit',
    () async {
      final bytes = utf8.encode('{"value":"é😀"}');
      final transport = createHttpTransport(
        HttpTransportConfig(
          url: 'https://example.com',
          inboundLimits: InboundPayloadLimits(maxBytes: bytes.length),
        ),
        client: MockClient.streaming(
          (_, _) async => http.StreamedResponse(
            Stream.fromIterable(bytes.map((byte) => [byte])),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          ),
        ),
      );

      expect(await transport(const RpcTransportConfig(payload: null)), {
        'value': 'é😀',
      });
    },
  );

  test(
    'Solana transport forwards JSON token limits before BigInt parsing',
    () async {
      final transport = createHttpTransportForSolanaRpc(
        url: 'https://example.com',
        inboundLimits: const InboundPayloadLimits(maxJsonTokens: 3),
        client: MockClient((_) async => http.Response('{"result":[1,2]}', 200)),
      );

      await expectLater(
        transport(
          const RpcTransportConfig(
            payload: {'jsonrpc': '2.0', 'id': 1, 'method': 'getSlot'},
          ),
        ),
        throwsA(isA<InboundPayloadLimitException>()),
      );
    },
  );

  test('rejects invalid limits when creating the transport', () {
    expect(
      () => createHttpTransport(
        const HttpTransportConfig(
          url: 'https://example.com',
          inboundLimits: InboundPayloadLimits(maxBytes: 0),
        ),
      ),
      throwsArgumentError,
    );
  });
}
