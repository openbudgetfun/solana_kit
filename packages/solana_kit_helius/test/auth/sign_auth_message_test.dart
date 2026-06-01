import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

void main() {
  group('AuthClient.signAuthMessage', () {
    test(
      'throws instead of returning a forgeable placeholder signature',
      () async {
        final helius = createHelius(HeliusConfig(apiKey: 'test'));

        await expectLater(
          helius.auth.signAuthMessage(
            const SignAuthMessageRequest(
              message: 'hello',
              secretKey: 'secret-key-base64',
            ),
          ),
          throwsA(isA<UnsupportedError>()),
        );
      },
    );
  });
}
