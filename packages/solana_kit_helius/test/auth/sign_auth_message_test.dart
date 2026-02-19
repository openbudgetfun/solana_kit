import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

void main() {
  group('AuthClient.signAuthMessage', () {
    test('returns a non-empty signature', () async {
      final helius = createHelius(const HeliusConfig(apiKey: 'test'));
      final result = await helius.auth.signAuthMessage(
        const SignAuthMessageRequest(
          message: 'hello',
          secretKey: 'secret-key-base64',
        ),
      );
      expect(result.signature, isNotEmpty);
    });

    test('signature is a base64-encoded string', () async {
      final helius = createHelius(const HeliusConfig(apiKey: 'test'));
      final result = await helius.auth.signAuthMessage(
        const SignAuthMessageRequest(
          message: 'test-message',
          secretKey: 'secret-key',
        ),
      );
      // Base64 strings contain only valid base64 characters.
      expect(result.signature, matches(RegExp(r'^[A-Za-z0-9+/]+=*$')));
    });

    test('different messages produce different signatures', () async {
      final helius = createHelius(const HeliusConfig(apiKey: 'test'));
      final result1 = await helius.auth.signAuthMessage(
        const SignAuthMessageRequest(message: 'message-a', secretKey: 'key'),
      );
      final result2 = await helius.auth.signAuthMessage(
        const SignAuthMessageRequest(message: 'message-b', secretKey: 'key'),
      );
      expect(result1.signature, isNot(result2.signature));
    });
  });
}
