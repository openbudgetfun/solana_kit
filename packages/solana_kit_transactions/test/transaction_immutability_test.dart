import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_keys/solana_kit_keys.dart';
import 'package:solana_kit_transactions/solana_kit_transactions.dart';
import 'package:test/test.dart';

void main() {
  group('transaction signing integrity', () {
    test(
      'retained message buffers cannot change the approved payload',
      () async {
        final keyPair = generateKeyPair();
        addTearDown(keyPair.dispose);
        final signer = getAddressFromPublicKey(keyPair.publicKey);
        final approvedMessage = Uint8List.fromList([1, 2, 3]);
        final suppliedBuffer = Uint8List.fromList(approvedMessage);
        final transaction = Transaction(
          messageBytes: suppliedBuffer,
          signatures: {signer: null},
        );

        // A proposer retains its buffer after approval, then changes the payload
        // before an asynchronous wallet operation signs the transaction.
        suppliedBuffer[2] = 99;
        final signed = await signTransaction([keyPair], transaction);

        expect(
          verifySignature(
            keyPair.publicKey,
            signed.signatures[signer]!,
            approvedMessage,
          ),
          isTrue,
        );
      },
    );

    test('message bytes and buffer views are read-only', () {
      final transaction = Transaction(
        messageBytes: Uint8List.fromList([1, 2, 3]),
        signatures: const {},
      );

      expect(() => transaction.messageBytes[0] = 9, throwsUnsupportedError);
      expect(
        () => transaction.messageBytes.buffer.asUint8List()[0] = 9,
        throwsUnsupportedError,
      );
      expect(transaction.messageBytes, [1, 2, 3]);
    });

    test('retained signature buffers cannot corrupt a signed transaction', () {
      const signer = Address('11111111111111111111111111111111');
      final signatureBuffer = Uint8List(64)..[0] = 1;
      final transaction = Transaction(
        messageBytes: Uint8List.fromList([1, 2, 3]),
        signatures: {signer: SignatureBytes(signatureBuffer)},
      );

      signatureBuffer[0] = 99;

      expect(transaction.signatures[signer]!.value.first, 1);
      expect(
        () => transaction.signatures[signer]!.value[0] = 9,
        throwsUnsupportedError,
      );
      expect(
        () => transaction.signatures[signer]!.value.buffer.asUint8List()[0] = 9,
        throwsUnsupportedError,
      );
    });
  });
}
