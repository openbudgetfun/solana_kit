import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_rpc_transport_http/solana_kit_rpc_transport_http.dart';
import 'package:test/test.dart';

void main() {
  group('assertIsAllowedHttpRequestHeaders', () {
    for (final forbiddenHeader in [
      'Accept-Charset',
      'Accept-charset',
      'accept-charset',
      'ACCEPT-CHARSET',
      'Accept-Encoding',
      'Access-Control-Request-Headers',
      'Access-Control-Request-Method',
      'Connection',
      'Content-Length',
      'Cookie',
      'Date',
      'DNT',
      'Expect',
      'Host',
      'Keep-Alive',
      'Origin',
      'Permissions-Policy',
      'Proxy-Anything',
      'Proxy-Authenticate',
      'Proxy-Authorization',
      'Sec-Fetch-Dest',
      'Sec-Fetch-Mode',
      'Sec-Fetch-Site',
      'Sec-Fetch-User',
      'Referer',
      'TE',
      'Trailer',
      'Transfer-Encoding',
      'Upgrade',
      'Via',
    ]) {
      test(
        'throws when called with the forbidden header `$forbiddenHeader`',
        () {
          expect(
            () => assertIsAllowedHttpRequestHeaders({forbiddenHeader: 'value'}),
            throwsA(
              isA<SolanaError>().having(
                (e) => e.code,
                'code',
                SolanaErrorCode.rpcTransportHttpHeaderForbidden,
              ),
            ),
          );
        },
      );
    }

    for (final disallowedHeader in [
      'Accept',
      'accept',
      'ACCEPT',
      'Content-Length',
      'content-length',
      'Content-Type',
      'content-type',
    ]) {
      test(
        'throws when called with the disallowed header `$disallowedHeader`',
        () {
          expect(
            () =>
                assertIsAllowedHttpRequestHeaders({disallowedHeader: 'value'}),
            throwsA(
              isA<SolanaError>().having(
                (e) => e.code,
                'code',
                SolanaErrorCode.rpcTransportHttpHeaderForbidden,
              ),
            ),
          );
        },
      );
    }

    test('throws with the correct headers list in the error context', () {
      try {
        assertIsAllowedHttpRequestHeaders({
          'Accept': 'text/html',
          'Sec-Fetch-Mode': 'no-cors',
        });
        fail('Expected SolanaError to be thrown');
      } on SolanaError catch (e) {
        expect(e.code, SolanaErrorCode.rpcTransportHttpHeaderForbidden);
        final headers = e.context['headers']! as List<String>;
        expect(headers, containsAll(['Accept', 'Sec-Fetch-Mode']));
      }
    });

    test('throws for proxy-* prefix headers', () {
      expect(
        () =>
            assertIsAllowedHttpRequestHeaders({'Proxy-Custom-Header': 'value'}),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.rpcTransportHttpHeaderForbidden,
          ),
        ),
      );
    });

    test('throws for sec-* prefix headers', () {
      expect(
        () => assertIsAllowedHttpRequestHeaders({'Sec-Custom-Header': 'value'}),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.rpcTransportHttpHeaderForbidden,
          ),
        ),
      );
    });

    for (final allowedHeader in [
      'Authorization',
      'Content-Language',
      'X-Custom-Header',
    ]) {
      test('does not throw when called with the header `$allowedHeader`', () {
        expect(
          () => assertIsAllowedHttpRequestHeaders({allowedHeader: 'value'}),
          returnsNormally,
        );
      });
    }
  });

  group('normalizeHeaders', () {
    test('lowercases all header names', () {
      final result = normalizeHeaders({
        'Content-Type': 'text/html',
        'X-CUSTOM-HEADER': 'custom-value',
        'Authorization': 'Bearer token',
      });

      expect(result, {
        'content-type': 'text/html',
        'x-custom-header': 'custom-value',
        'authorization': 'Bearer token',
      });
    });

    test('preserves header values unchanged', () {
      final result = normalizeHeaders({
        'Authorization': 'Bearer MySecretToken',
      });

      expect(result['authorization'], 'Bearer MySecretToken');
    });

    test('returns an empty map for empty input', () {
      final result = normalizeHeaders({});
      expect(result, isEmpty);
    });
  });
}
