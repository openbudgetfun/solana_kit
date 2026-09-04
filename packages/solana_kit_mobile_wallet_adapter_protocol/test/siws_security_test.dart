import 'package:solana_kit_mobile_wallet_adapter_protocol/solana_kit_mobile_wallet_adapter_protocol.dart';
import 'package:test/test.dart';

void main() {
  group('SIWS line injection', () {
    final scalarPayloads = <String, SignInPayload Function(String)>{
      'domain': (value) => SignInPayload(domain: value),
      'address': (value) => SignInPayload(address: value),
      'statement': (value) => SignInPayload(statement: value),
      'uri': (value) => SignInPayload(uri: value),
      'version': (value) => SignInPayload(version: value),
      'chainId': (value) => SignInPayload(chainId: value),
      'nonce': (value) => SignInPayload(nonce: value),
      'issuedAt': (value) => SignInPayload(issuedAt: value),
      'expirationTime': (value) => SignInPayload(expirationTime: value),
      'notBefore': (value) => SignInPayload(notBefore: value),
      'requestId': (value) => SignInPayload(requestId: value),
    };

    for (final entry in scalarPayloads.entries) {
      for (final (name, newline) in [
        ('LF', '\n'),
        ('CR', '\r'),
        ('CRLF', '\r\n'),
      ]) {
        test('rejects $name in ${entry.key}', () {
          final payload = entry.value('value${newline}Nonce: injected');

          expect(() => createSiwsMessage(payload), throwsFormatException);
        });
      }
    }

    for (final (name, newline) in [
      ('LF', '\n'),
      ('CR', '\r'),
      ('CRLF', '\r\n'),
    ]) {
      for (final index in [0, 1]) {
        test('rejects $name in resource $index', () {
          final resources = ['https://example.com/read', 'https://example.com'];
          resources[index] =
              'https://example.com/read$newline- https://example.com/admin';

          expect(
            () => createSiwsMessage(SignInPayload(resources: resources)),
            throwsFormatException,
          );
        });
      }
    }

    test('one resource cannot serialize as two authorized resources', () {
      const injected = SignInPayload(
        domain: 'example.com',
        address: '11111111111111111111111111111111',
        resources: [
          'https://example.com/read\n- https://example.com/admin',
        ],
      );
      const expanded = SignInPayload(
        domain: 'example.com',
        address: '11111111111111111111111111111111',
        resources: [
          'https://example.com/read',
          'https://example.com/admin',
        ],
      );
      final expandedMessage = createSiwsMessage(expanded);
      String injectedMessage;

      try {
        injectedMessage = createSiwsMessage(injected);
      } on FormatException {
        // Rejecting the injected payload prevents an ambiguous signature.
        return;
      }

      expect(
        injectedMessage,
        isNot(expandedMessage),
        reason:
            'Different resource scopes must not produce identical bytes '
            'for the wallet to sign.',
      );
    });

    test('preserves valid fields and resource delimiters', () {
      const payload = SignInPayload(
        domain: 'example.com',
        address: '11111111111111111111111111111111',
        statement: 'Sign in to view your account.',
        uri: 'https://example.com/login',
        version: '1',
        chainId: 'solana:mainnet',
        nonce: 'abcdefgh',
        issuedAt: '2026-09-04T12:00:00Z',
        expirationTime: '2026-09-04T13:00:00Z',
        notBefore: '2026-09-04T12:00:00Z',
        requestId: 'request-1',
        resources: [
          'https://example.com/read',
          'https://example.com/data?line=%0A',
        ],
      );

      expect(
        createSiwsMessage(payload),
        'example.com wants you to sign in with your Solana account:\n'
        '11111111111111111111111111111111\n\n'
        'Sign in to view your account.\n\n'
        'URI: https://example.com/login\n'
        'Version: 1\n'
        'Chain ID: solana:mainnet\n'
        'Nonce: abcdefgh\n'
        'Issued At: 2026-09-04T12:00:00Z\n'
        'Expiration Time: 2026-09-04T13:00:00Z\n'
        'Not Before: 2026-09-04T12:00:00Z\n'
        'Request ID: request-1\n'
        'Resources:\n'
        '- https://example.com/read\n'
        '- https://example.com/data?line=%0A',
      );
    });

    test('preserves omitted fields and empty resources', () {
      expect(
        createSiwsMessage(const SignInPayload()),
        ' wants you to sign in with your Solana account:',
      );
      expect(
        createSiwsMessage(const SignInPayload(resources: [])),
        createSiwsMessage(const SignInPayload()),
      );
    });
  });
}
