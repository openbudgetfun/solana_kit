import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

void main() {
  group('createTxMessage', () {
    test('builds a message with address fee payer and lifetime', () {
      final ix1 = Object();
      final ix2 = Object();
      const lifetime = TxMessageLifetime(
        blockhash: '5nP4a8kpkJwY5j7cQeWWoJc3qQ9mMxjX8v3d5fWg2JkN',
        lastValidBlockHeight: 123,
      );

      final message = createTxMessage(
        CreateTxMessageInput(
          version: 0,
          feePayer: '11111111111111111111111111111111',
          lifetime: lifetime,
          instructions: [ix1, ix2],
        ),
      );

      expect(message.instructions, hasLength(2));
      expect(message.instructions[0], same(ix1));
      expect(message.instructions[1], same(ix2));
      expect(message.feePayer, '11111111111111111111111111111111');
      expect(message.lifetime, same(lifetime));
    });

    test('builds a message with signer fee payer address', () {
      final ix = Object();
      const signer = TxMessageSigner(
        address: '9z8b2Uun1rJtQwVhLQxC9rjNV8o6D5pL4tFz3s7Yk1Qh',
      );

      final message = createTxMessage(
        CreateTxMessageInput(version: 0, feePayer: signer, instructions: [ix]),
      );

      expect(message.instructions, hasLength(1));
      expect(message.instructions.single, same(ix));
      expect(message.feePayer, signer.address);
    });

    test('rejects unsupported fee payer values', () {
      expect(
        () => createTxMessage(
          const CreateTxMessageInput(
            version: 0,
            feePayer: 123,
            instructions: [],
          ),
        ),
        throwsArgumentError,
      );
    });

    test('works without lifetime', () {
      final message = createTxMessage(
        const CreateTxMessageInput(
          version: 0,
          feePayer: '11111111111111111111111111111111',
          instructions: [],
        ),
      );

      expect(message.lifetime, isNull);
      expect(message.instructions, isEmpty);
    });
  });
}
