import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

void main() {
  group('AuthClient.generateKeypair', () {
    test('returns a keypair with non-empty keys', () {
      final helius = createHelius(HeliusConfig(apiKey: 'test'));
      final keypair = helius.auth.generateKeypair();
      expect(keypair.publicKey, isNotEmpty);
      expect(keypair.secretKey, isNotEmpty);
    });

    test('returns different keypairs on each call', () {
      final helius = createHelius(HeliusConfig(apiKey: 'test'));
      final keypair1 = helius.auth.generateKeypair();
      final keypair2 = helius.auth.generateKeypair();
      // Overwhelmingly likely to differ with secure random.
      expect(keypair1.publicKey != keypair2.publicKey, isTrue);
      expect(keypair1.secretKey != keypair2.secretKey, isTrue);
    });

    test('publicKey and secretKey are base64-encoded strings', () {
      final helius = createHelius(HeliusConfig(apiKey: 'test'));
      final keypair = helius.auth.generateKeypair();
      // Base64 strings contain only valid base64 characters.
      expect(keypair.publicKey, matches(RegExp(r'^[A-Za-z0-9+/]+=*$')));
      expect(keypair.secretKey, matches(RegExp(r'^[A-Za-z0-9+/]+=*$')));
    });
  });
}
