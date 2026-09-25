import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_rpc_spec/solana_kit_rpc_spec.dart';
import 'package:solana_kit_rpc_transport_http/solana_kit_rpc_transport_http.dart';
import 'package:test/test.dart';

void main() {
  group('HTTP endpoint credentials in failures', () {
    const endpoint =
        'https://username:password@rpc.example.com/private-token?api-key=test-secret';
    for (final aborted in [false, true]) {
      test(
        'redacts failed requests while preserving abort type: $aborted',
        () async {
          final transport = createHttpTransport(
            const HttpTransportConfig(url: endpoint),
            client: MockClient((request) async {
              if (aborted) throw http.RequestAbortedException(request.url);
              throw http.ClientException(
                'Failed to connect to ${request.url}',
                request.url,
              );
            }),
          );
          final outcome = await transport(
            const RpcTransportConfig(payload: null),
          ).then<Object?>((value) => value, onError: (Object error) => error);

          expect(
            outcome,
            aborted
                ? isA<http.RequestAbortedException>()
                : isA<http.ClientException>(),
          );
          for (final secret in [
            'username',
            'password',
            'private-token',
            'test-secret',
          ]) {
            expect(outcome.toString(), isNot(contains(secret)));
          }
        },
      );
    }

    test('redacts errors from a response body stream', () async {
      final client = MockClient.streaming((request, body) async {
        await body.drain<void>();
        return http.StreamedResponse(
          Stream<List<int>>.error(
            http.ClientException(
              'Body failed for $endpoint',
              Uri.parse(endpoint),
            ),
          ),
          200,
        );
      });
      final transport = createHttpTransport(
        const HttpTransportConfig(url: endpoint),
        client: client,
      );
      final outcome = await transport(
        const RpcTransportConfig(payload: null),
      ).then<Object?>((value) => value, onError: (Object error) => error);

      expect(outcome, isA<http.ClientException>());
      expect(outcome.toString(), isNot(contains('test-secret')));
    });
  });
}
