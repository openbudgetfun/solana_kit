import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'package:solana_kit_dapp_publisher_cli/src/errors.dart';
import 'package:solana_kit_dapp_publisher_cli/src/portal_client.dart';
import 'package:solana_kit_dapp_publisher_cli/src/portal_types.dart';
import 'package:test/test.dart';

class _RecordingHttpClient extends http.BaseClient {
  _RecordingHttpClient(this.handler);

  http.Response Function(http.BaseRequest request) handler;
  final sentRequests = <http.BaseRequest>[];

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    sentRequests.add(request);
    final response = handler(request);
    return http.StreamedResponse(
      Stream.value(response.bodyBytes),
      response.statusCode,
      contentLength: response.bodyBytes.length,
      reasonPhrase: response.reasonPhrase,
      headers: response.headers,
    );
  }
}

const _apiKey = 'test-api-key';

PortalClientConfig _configWith(_RecordingHttpClient client) =>
    PortalClientConfig(
      apiBaseUrl: 'https://portal.example.com/api',
      apiKey: const SensitiveString(_apiKey),
      client: client,
    );

void main() {
  group('callPortalProcedure', () {
    test('performs mutations with the API key header', () async {
      final client = _RecordingHttpClient(
        (request) => http.Response(
          jsonEncode({
            'result': {
              'data': {
                'uploadUrl': 'https://upload',
                'publicUrl': 'https://public',
              },
            },
          }),
          200,
        ),
      );
      final result = await callPortalProcedure<Map<String, Object?>>(
        _configWith(client),
        'publication.createUploadTarget',
        {'fileHash': 'abc'},
        'mutation',
      );
      expect(result['uploadUrl'], 'https://upload');
      expect(client.sentRequests, hasLength(1));
      final request = client.sentRequests.single;
      expect(
        request.url.path,
        contains('/api/trpc/publication.createUploadTarget'),
      );
      expect(request.headers['x-api-key'], _apiKey);
      expect(request.headers['content-type'], 'application/json');
    });

    test('performs queries with a JSON encoded input parameter', () async {
      final client = _RecordingHttpClient(
        (request) => http.Response(
          jsonEncode({
            'result': {
              'data': {'slot': 5, 'blockhash': 'Bh'},
            },
          }),
          200,
        ),
      );
      final result = await callPortalProcedure<Map<String, Object?>>(
        _configWith(client),
        'attestation.getBlockData',
        const <String, Object?>{},
        'query',
      );
      expect(result['slot'], 5);
      final request = client.sentRequests.single;
      expect(request.method, 'GET');
      expect(request.url.queryParameters['input'], '{}');
    });

    test('unwraps the result.data envelope', () async {
      final client = _RecordingHttpClient(
        (request) => http.Response(
          jsonEncode({
            'result': {
              'data': {'ok': true},
            },
          }),
          200,
        ),
      );
      final result = await callPortalProcedure<Map<String, Object?>>(
        _configWith(client),
        'publication.getPublicationBundle',
        {'releaseId': 'r'},
        'query',
      );
      expect(result['ok'], isTrue);
    });

    test('unwraps Right/Left tagged results', () async {
      final client = _RecordingHttpClient(
        (request) => http.Response(
          jsonEncode({
            'result': {
              'data': {
                '_tag': 'Right',
                'right': {'v': 1},
              },
            },
          }),
          200,
        ),
      );
      final result = await callPortalProcedure<Map<String, Object?>>(
        _configWith(client),
        'publication.getPublicationSession',
        {},
        'query',
      );
      expect(result['v'], 1);
    });

    test('throws the Left message', () async {
      final client = _RecordingHttpClient(
        (request) => http.Response(
          jsonEncode({
            'result': {
              'data': {
                '_tag': 'Left',
                'left': {'message': 'not authorized'},
              },
            },
          }),
          200,
        ),
      );
      await expectLater(
        callPortalProcedure<Map<String, Object?>>(
          _configWith(client),
          'publication.getPublicationSession',
          {},
          'query',
        ),
        throwsA(
          isA<PublisherCliException>().having(
            (error) => error.message,
            'message',
            contains('not authorized'),
          ),
        ),
      );
    });

    test('extracts error.message on HTTP failures', () async {
      final client = _RecordingHttpClient(
        (request) => http.Response(
          jsonEncode({
            'error': {'message': 'Invalid API key'},
          }),
          401,
        ),
      );
      await expectLater(
        callPortalProcedure<Map<String, Object?>>(
          _configWith(client),
          'publication.createIngestionSession',
          {},
          'mutation',
        ),
        throwsA(
          isA<PublisherCliException>().having(
            (error) => error.message,
            'message',
            contains('Invalid API key'),
          ),
        ),
      );
    });

    test('extracts nested Left messages on HTTP failures', () async {
      final client = _RecordingHttpClient(
        (request) => http.Response(
          jsonEncode({
            'result': {
              'data': {
                '_tag': 'Left',
                'left': {'message': 'Portal exploded'},
              },
            },
          }),
          500,
        ),
      );
      await expectLater(
        callPortalProcedure<Map<String, Object?>>(
          _configWith(client),
          'publication.createIngestionSession',
          {},
          'mutation',
        ),
        throwsA(
          isA<PublisherCliException>().having(
            (error) => error.message,
            'message',
            contains('Portal exploded'),
          ),
        ),
      );
    });

    test('falls back to the status message', () async {
      final client = _RecordingHttpClient(
        (request) => http.Response('{}', 503),
      );
      await expectLater(
        callPortalProcedure<Map<String, Object?>>(
          _configWith(client),
          'publication.createIngestionSession',
          {},
          'mutation',
        ),
        throwsA(
          isA<PublisherCliException>().having(
            (error) => error.message,
            'message',
            contains('status 503'),
          ),
        ),
      );
    });

    test('reports unparseable responses', () async {
      final client = _RecordingHttpClient(
        (request) => http.Response('<html>oops</html>', 200),
      );
      await expectLater(
        callPortalProcedure<Map<String, Object?>>(
          _configWith(client),
          'publication.createIngestionSession',
          {},
          'mutation',
        ),
        throwsA(
          isA<PublisherCliException>().having(
            (error) => error.message,
            'message',
            contains('Failed to parse portal response'),
          ),
        ),
      );
    });

    test('unwraps batched array responses', () async {
      final client = _RecordingHttpClient(
        (request) => http.Response(
          jsonEncode({
            '0': {
              'result': {
                'data': {'v': 1},
              },
            },
          }),
          200,
        ),
      );
      final result = await callPortalProcedure<Map<String, Object?>>(
        _configWith(client),
        'publication.createUploadTarget',
        {},
        'mutation',
      );
      expect(result['v'], 1);
    });

    test('falls back to an empty record for non-record payloads', () async {
      final client = _RecordingHttpClient(
        (request) => http.Response('[1, 2]', 200),
      );
      final result = await callPortalProcedure<Map<String, Object?>>(
        _configWith(client),
        'publication.createUploadTarget',
        {},
        'mutation',
      );
      expect(result, isEmpty);
    });

    test('throws when the result is not a record', () async {
      final client = _RecordingHttpClient(
        (request) => http.Response(
          jsonEncode({
            'result': {'data': 'plain'},
          }),
          200,
        ),
      );
      await expectLater(
        callPortalProcedure<Map<String, Object?>>(
          _configWith(client),
          'publication.createUploadTarget',
          {},
          'mutation',
        ),
        throwsA(isA<PublisherCliException>()),
      );
    });

    test('closes owned clients', () async {
      const config = PortalClientConfig(
        apiBaseUrl: 'https://portal.example.com/api',
        apiKey: SensitiveString(_apiKey),
      );
      await expectLater(
        callPortalProcedure<Map<String, Object?>>(
          config,
          'publication.createUploadTarget',
          {},
          'mutation',
        ),
        throwsA(anything),
      );
    });

    test('falls back when the result is not a record', () async {
      final client = _RecordingHttpClient(
        (request) => http.Response(
          jsonEncode({
            'result': {'data': 'plain'},
          }),
          200,
        ),
      );
      await expectLater(
        callPortalProcedure<Map<String, Object?>>(
          _configWith(client),
          'publication.createUploadTarget',
          {},
          'mutation',
        ),
        throwsA(isA<PublisherCliException>()),
      );
    });
  });

  group('uploadBytes', () {
    test('PUTs the payload to the upload URL', () async {
      final client = _RecordingHttpClient(
        (request) => http.Response('', 200),
      );
      await uploadBytes(
        'https://portal.example.com/upload',
        Uint8List.fromList([1, 2, 3]),
        'application/json',
        client: client,
      );
      final request = client.sentRequests.single as http.Request;
      expect(request.method, 'PUT');
      expect(request.bodyBytes, [1, 2, 3]);
      expect(request.headers['content-type'], 'application/json');
    });

    test('throws on failure with the response preview', () async {
      final client = _RecordingHttpClient(
        (request) => http.Response('forbidden', 403),
      );
      await expectLater(
        uploadBytes(
          'https://x',
          Uint8List(2),
          'application/json',
          client: client,
        ),
        throwsA(
          isA<PublisherCliException>().having(
            (error) => error.message,
            'message',
            contains('Failed to upload file to the portal: forbidden'),
          ),
        ),
      );
    });
  });

  group('callCreateIngestionSessionWithRetry', () {
    test('retries transient failures and succeeds', () async {
      var attempts = 0;
      final delays = <Duration>[];
      final client = _RecordingHttpClient((request) {
        attempts++;
        if (attempts < 3) {
          return http.Response('<html>Bad Gateway</html>', 502);
        }
        return http.Response(
          jsonEncode({
            'result': {
              'data': {'id': 'ing-1'},
            },
          }),
          200,
        );
      });
      final config = PortalClientConfig(
        apiBaseUrl: 'https://portal.example.com/api',
        apiKey: const SensitiveString(_apiKey),
        client: client,
      );
      final result = await callCreateIngestionSessionWithRetry(
        config,
        {},
        client: client,
        sleep: (duration) async {
          delays.add(duration);
        },
      );
      expect(result['id'], 'ing-1');
      expect(attempts, 3);
      expect(delays, [
        const Duration(milliseconds: 1500),
        const Duration(milliseconds: 3000),
      ]);
    });

    test('rethrows non-retryable errors immediately', () async {
      final client = _RecordingHttpClient(
        (request) => http.Response(
          jsonEncode({
            'error': {'message': 'nope'},
          }),
          400,
        ),
      );
      final config = PortalClientConfig(
        apiBaseUrl: 'https://portal.example.com/api',
        apiKey: const SensitiveString(_apiKey),
        client: client,
      );
      await expectLater(
        callCreateIngestionSessionWithRetry(config, {}, client: client),
        throwsA(
          isA<PublisherCliException>().having(
            (error) => error.message,
            'message',
            contains('nope'),
          ),
        ),
      );
    });

    test('gives up after three attempts', () async {
      var attempts = 0;
      final client = _RecordingHttpClient((request) {
        attempts++;
        return http.Response('<html>gateway timeout</html>', 504);
      });
      final config = PortalClientConfig(
        apiBaseUrl: 'https://portal.example.com/api',
        apiKey: const SensitiveString(_apiKey),
        client: client,
      );
      await expectLater(
        callCreateIngestionSessionWithRetry(
          config,
          {},
          client: client,
          sleep: (_) async {},
        ),
        throwsA(isA<PublisherCliException>()),
      );
      expect(attempts, 3);
    });
  });

  group('PortalAttestationClient', () {
    test('fetches block data', () async {
      final client = _RecordingHttpClient(
        (request) => http.Response(
          jsonEncode({
            'result': {
              'data': {'slot': 99, 'blockhash': 'Bh'},
            },
          }),
          200,
        ),
      );
      final blockData = await PortalAttestationClient(
        _configWith(client),
      ).getBlockData();
      expect(blockData.slot, 99);
      expect(blockData.blockhash, 'Bh');
    });
  });

  group('SensitiveString', () {
    test('redacts its value in toString', () {
      const secret = SensitiveString('super-secret');
      expect(secret.toString(), 'SensitiveString(****)');
    });

    test('compares in constant time', () {
      expect(const SensitiveString('abc'), const SensitiveString('abc'));
      expect(
        const SensitiveString('abc'),
        isNot(const SensitiveString('abd')),
      );
      expect(
        const SensitiveString('abcd'),
        isNot(const SensitiveString('abc')),
      );
      expect(const SensitiveString('a').hashCode, 1);
    });
  });

  group('retry classification', () {
    test('identifies retryable errors', () {
      expect(
        isRetryableCreateIngestionSessionError(
          const PublisherCliException(
            'Failed to parse portal response from '
            'publication.createIngestionSession: [empty]',
          ),
        ),
        isTrue,
      );
      expect(
        isRetryableCreateIngestionSessionError(
          const PublisherCliException('Gateway Timeout from upstream'),
        ),
        isTrue,
      );
      expect(
        isRetryableCreateIngestionSessionError(
          const PublisherCliException('Bad Gateway'),
        ),
        isTrue,
      );
      expect(
        isRetryableCreateIngestionSessionError(
          const PublisherCliException('Service Unavailable'),
        ),
        isTrue,
      );
      expect(
        isRetryableCreateIngestionSessionError(
          const PublisherCliException('Unexpected token < in JSON'),
        ),
        isTrue,
      );
      expect(
        isRetryableCreateIngestionSessionError(
          const PublisherCliException('Invalid API key'),
        ),
        isFalse,
      );
    });
  });

  group('constants', () {
    test('exposes the default endpoints', () {
      expect(
        defaultProductionPortalUrl,
        'https://publish.solanamobile.com',
      );
      expect(defaultLocalPortalUrl, 'http://localhost:3333');
      expect(defaultApiKeyEnv, 'DAPP_STORE_API_KEY');
    });
  });

  group('PortalUploadTarget', () {
    test('parses from a portal response', () {
      final target = PortalUploadTarget.fromMap({
        'uploadUrl': 'https://upload',
        'publicUrl': 'https://public',
      });
      expect(target.uploadUrl, 'https://upload');
      expect(target.publicUrl, 'https://public');
    });
  });

  group('CreateUploadTargetInput', () {
    test('serializes to a map', () {
      const input = CreateUploadTargetInput(
        fileHash: 'h',
        fileExtension: 'apk',
        contentType: 'application/vnd.android.package-archive',
      );
      expect(input.toMap(), {
        'fileHash': 'h',
        'fileExtension': 'apk',
        'contentType': 'application/vnd.android.package-archive',
      });
    });
  });

  group('result models', () {
    test('parses prepared transactions', () {
      final release = PreparedReleaseTransaction.fromMap({
        'transaction': 'dHg=',
        'mintAddress': 'm',
        'blockhash': 'b',
      });
      expect(release.transaction, 'dHg=');
      expect(release.mintAddress, 'm');
      expect(release.blockhash, 'b');

      final verify = PreparedVerifyCollectionTransaction.fromMap({
        'transaction': 'dHg=',
        'blockhash': 'b',
      });
      expect(verify.transaction, 'dHg=');
      expect(verify.blockhash, 'b');

      final submit = SubmitSignedTransactionResult.fromMap({
        'transactionSignature': 's',
      });
      expect(submit.transactionSignature, 's');

      final save = SaveReleaseNftDataResult.fromMap({'success': true});
      expect(save.success, isTrue);

      final verified = MarkReleaseCollectionAsVerifiedResult.fromMap({
        'success': false,
        'releaseId': 'r',
      });
      expect(verified.success, isFalse);
      expect(verified.releaseId, 'r');

      final cleanup = CleanupReleaseResult.fromMap({
        'action': 'deleted',
      });
      expect(cleanup.action, 'deleted');

      final store = SubmitToStoreResult.fromMap({
        'hubspotTicketId': 'HS',
      });
      expect(store.hubspotTicketId, 'HS');
    });
  });
}
