import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_rpc_spec/solana_kit_rpc_spec.dart';
import 'package:solana_kit_rpc_transport_http/solana_kit_rpc_transport_http.dart';
import 'package:test/test.dart';

void main() {
  group('createHttpTransport', () {
    group('when the endpoint returns a well-formed JSON response', () {
      late http.Request capturedRequest;
      late RpcTransport transport;

      setUp(() {
        final mockClient = MockClient((request) async {
          capturedRequest = request;
          return http.Response(
            jsonEncode({'ok': true}),
            200,
            headers: {'content-type': 'application/json'},
          );
        });

        transport = createHttpTransport(
          const HttpTransportConfig(url: 'http://localhost'),
          client: mockClient,
        );
      });

      test('calls the specified URL', () async {
        await transport(const RpcTransportConfig(payload: 123));
        expect(capturedRequest.url.toString(), 'http://localhost');
      });

      test(
        'sets the body to a JSON-stringified version of the payload',
        () async {
          await transport(const RpcTransportConfig(payload: {'ok': true}));
          expect(capturedRequest.body, jsonEncode({'ok': true}));
        },
      );

      test('sets the accept header to application/json', () async {
        await transport(const RpcTransportConfig(payload: 123));
        expect(capturedRequest.headers['accept'], 'application/json');
      });

      test('sets the content type header to '
          'application/json; charset=utf-8', () async {
        await transport(const RpcTransportConfig(payload: 123));
        expect(
          capturedRequest.headers['content-type'],
          'application/json; charset=utf-8',
        );
      });

      test('sets the content length header to the byte length '
          'of the JSON-stringified payload', () async {
        await transport(const RpcTransportConfig(payload: 123));
        // '123' is 3 bytes in UTF-8
        expect(capturedRequest.headers['content-length'], '3');
      });

      test('sets the method to POST', () async {
        await transport(const RpcTransportConfig(payload: 123));
        expect(capturedRequest.method, 'POST');
      });

      test('returns the parsed JSON response', () async {
        final result = await transport(const RpcTransportConfig(payload: 123));
        expect(result, {'ok': true});
      });
    });

    group('with custom headers', () {
      test('includes custom headers in the request', () async {
        late http.Request capturedRequest;
        final mockClient = MockClient((request) async {
          capturedRequest = request;
          return http.Response(
            jsonEncode({'ok': true}),
            200,
            headers: {'content-type': 'application/json'},
          );
        });

        final transport = createHttpTransport(
          const HttpTransportConfig(
            url: 'http://localhost',
            headers: {'Authorization': 'Bearer token123'},
          ),
          client: mockClient,
        );

        await transport(const RpcTransportConfig(payload: 123));

        expect(capturedRequest.headers['authorization'], 'Bearer token123');
      });

      test('disallowed headers in custom headers throw a SolanaError '
          'in debug mode', () {
        final mockClient = MockClient(
          (request) async => http.Response(
            jsonEncode({'ok': true}),
            200,
            headers: {'content-type': 'application/json'},
          ),
        );

        expect(
          () => createHttpTransport(
            const HttpTransportConfig(
              url: 'http://localhost',
              headers: {'aCcEpT': 'text/html'},
            ),
            client: mockClient,
          ),
          throwsA(
            isA<SolanaError>().having(
              (e) => e.code,
              'code',
              SolanaErrorCode.rpcTransportHttpHeaderForbidden,
            ),
          ),
        );
      });

      test(
        'custom headers are normalized (lowercased) in the request',
        () async {
          late http.Request capturedRequest;
          final mockClient = MockClient((request) async {
            capturedRequest = request;
            return http.Response(
              jsonEncode({'ok': true}),
              200,
              headers: {'content-type': 'application/json'},
            );
          });

          final transport = createHttpTransport(
            const HttpTransportConfig(
              url: 'http://localhost',
              headers: {'X-Custom-Header': 'custom-value'},
            ),
            client: mockClient,
          );

          await transport(const RpcTransportConfig(payload: 123));

          expect(capturedRequest.headers['x-custom-header'], 'custom-value');
          // Protocol headers should still be present and correct
          expect(capturedRequest.headers['accept'], 'application/json');
          expect(
            capturedRequest.headers['content-type'],
            'application/json; charset=utf-8',
          );
          expect(capturedRequest.headers['content-length'], '3');
        },
      );
    });

    group('when the endpoint returns a non-200 status code', () {
      test('throws a SolanaError with the HTTP error code', () async {
        final mockClient = MockClient(
          (request) async => http.Response('Not Found', 404),
        );

        final transport = createHttpTransport(
          const HttpTransportConfig(url: 'http://localhost'),
          client: mockClient,
        );

        expect(
          () => transport(const RpcTransportConfig(payload: 123)),
          throwsA(
            isA<SolanaError>()
                .having(
                  (e) => e.code,
                  'code',
                  SolanaErrorCode.rpcTransportHttpError,
                )
                .having((e) => e.context['statusCode'], 'statusCode', 404),
          ),
        );
      });

      test('includes the status message in the error context', () async {
        final mockClient = MockClient(
          (request) async => http.Response(
            'We looked everywhere',
            404,
            reasonPhrase: 'Not Found',
          ),
        );

        final transport = createHttpTransport(
          const HttpTransportConfig(url: 'http://localhost'),
          client: mockClient,
        );

        try {
          await transport(const RpcTransportConfig(payload: 123));
          fail('Expected SolanaError to be thrown');
        } on SolanaError catch (e) {
          expect(e.code, SolanaErrorCode.rpcTransportHttpError);
          expect(e.context['statusCode'], 404);
          expect(e.context['message'], isNotNull);
        }
      });
    });

    group('with custom toJson function', () {
      test('uses the toJson function to serialize the payload', () async {
        late http.Request capturedRequest;
        final mockClient = MockClient((request) async {
          capturedRequest = request;
          return http.Response(
            jsonEncode({'ok': true}),
            200,
            headers: {'content-type': 'application/json'},
          );
        });

        final transport = createHttpTransport(
          HttpTransportConfig(
            url: 'http://localhost',
            toJson: (payload) => '{"someAugmented":"jsonString"}',
          ),
          client: mockClient,
        );

        await transport(const RpcTransportConfig(payload: {'foo': 123}));

        expect(capturedRequest.body, '{"someAugmented":"jsonString"}');
      });

      test('passes the payload to the toJson function', () async {
        Object? receivedPayload;
        final mockClient = MockClient(
          (request) async => http.Response(
            jsonEncode({'ok': true}),
            200,
            headers: {'content-type': 'application/json'},
          ),
        );

        final transport = createHttpTransport(
          HttpTransportConfig(
            url: 'http://localhost',
            toJson: (payload) {
              receivedPayload = payload;
              return jsonEncode(payload);
            },
          ),
          client: mockClient,
        );

        await transport(const RpcTransportConfig(payload: {'foo': 123}));

        expect(receivedPayload, {'foo': 123});
      });
    });

    group('with custom fromJson function', () {
      test('uses the fromJson function to parse the response '
          'from a JSON string', () async {
        String? receivedRawResponse;
        Object? receivedPayload;
        final mockClient = MockClient(
          (request) async => http.Response(
            '{"ok":true}',
            200,
            headers: {'content-type': 'application/json'},
          ),
        );

        final transport = createHttpTransport(
          HttpTransportConfig(
            url: 'http://localhost',
            fromJson: (rawResponse, payload) {
              receivedRawResponse = rawResponse;
              receivedPayload = payload;
              return {'result': 456};
            },
          ),
          client: mockClient,
        );

        await transport(const RpcTransportConfig(payload: {'foo': 123}));

        expect(receivedRawResponse, '{"ok":true}');
        expect(receivedPayload, {'foo': 123});
      });

      test('returns the value parsed by fromJson', () async {
        final mockClient = MockClient(
          (request) async => http.Response(
            '{"ok":true}',
            200,
            headers: {'content-type': 'application/json'},
          ),
        );

        final transport = createHttpTransport(
          HttpTransportConfig(
            url: 'http://localhost',
            fromJson: (rawResponse, payload) => {'result': 456},
          ),
          client: mockClient,
        );

        final result = await transport(
          const RpcTransportConfig(payload: {'foo': 123}),
        );

        expect(result, {'result': 456});
      });
    });

    group('content-length header for multi-byte characters', () {
      test('calculates content-length based on UTF-8 byte length', () async {
        late http.Request capturedRequest;
        final mockClient = MockClient((request) async {
          capturedRequest = request;
          return http.Response(
            jsonEncode({'ok': true}),
            200,
            headers: {'content-type': 'application/json'},
          );
        });

        final transport = createHttpTransport(
          const HttpTransportConfig(url: 'http://localhost'),
          client: mockClient,
        );

        // A string with multi-byte UTF-8 characters
        await transport(const RpcTransportConfig(payload: '\u00e9'));

        // '\u00e9' encoded as JSON is '"\u00e9"' which is 4 bytes in the JSON
        // string (the quotes + the UTF-8 encoded character)
        final expectedBytes = utf8.encode(jsonEncode('\u00e9'));
        expect(
          capturedRequest.headers['content-length'],
          expectedBytes.length.toString(),
        );
      });
    });
  });
}
