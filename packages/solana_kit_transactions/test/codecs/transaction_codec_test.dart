import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_keys/solana_kit_keys.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';
import 'package:solana_kit_transactions/solana_kit_transactions.dart';
import 'package:test/test.dart';

void main() {
  group('getTransactionEncoder', () {
    test('encodes a transaction with null signatures to bytes', () {
      final transaction = Transaction(
        messageBytes: Uint8List.fromList([1, 2, 3]),
        signatures: const {Address('11111111111111111111111111111111'): null},
      );
      final encoder = getTransactionEncoder();
      final encoded = encoder.encode(transaction);
      expect(encoded, isA<Uint8List>());
      // 1 (shortU16 count) + 64 (signature) + 3 (message) = 68.
      expect(encoded.length, 68);
    });

    test('encodes a transaction with a real signature', () {
      final sigBytes = SignatureBytes(
        Uint8List.fromList(List<int>.filled(64, 0xab)),
      );
      final transaction = Transaction(
        messageBytes: Uint8List.fromList([1, 2, 3]),
        signatures: {
          const Address('11111111111111111111111111111111'): sigBytes,
        },
      );
      final encoder = getTransactionEncoder();
      final encoded = encoder.encode(transaction);
      expect(encoded.length, 68);
      // Verify signature bytes are in the encoded output.
      for (var i = 1; i < 65; i++) {
        expect(encoded[i], 0xab);
      }
    });

    test('getSizeFromValue returns correct size', () {
      final transaction = Transaction(
        messageBytes: Uint8List.fromList([1, 2, 3, 4, 5]),
        signatures: const {Address('11111111111111111111111111111111'): null},
      );
      final encoder = getTransactionEncoder();
      final size = encoder.getSizeFromValue(transaction);
      // 1 (shortU16 count) + 64 (signature) + 5 (message) = 70.
      expect(size, 70);
    });
  });

  group('getTransactionDecoder', () {
    test('decodes a round-tripped transaction', () {
      // Create and compile a transaction message.
      final message = const TransactionMessage(version: TransactionVersion.v0)
          .copyWith(
            feePayer: const Address(
              '22222222222222222222222222222222222222222222',
            ),
            lifetimeConstraint: BlockhashLifetimeConstraint(
              blockhash: '11111111111111111111111111111111',
              lastValidBlockHeight: BigInt.zero,
            ),
          );

      final compiled = compileTransaction(message);
      final encoder = getTransactionEncoder();
      final encoded = encoder.encode(compiled);

      final decoder = getTransactionDecoder();
      final decoded = decoder.decode(encoded);

      expect(decoded.messageBytes, compiled.messageBytes);
      expect(decoded.signatures.length, compiled.signatures.length);
      // All signatures should be null since the original was unsigned.
      for (final sig in decoded.signatures.values) {
        expect(sig, isNull);
      }
    });

    test('decodes a transaction with a real signature', () {
      final sigBytes = SignatureBytes(
        Uint8List.fromList(List<int>.filled(64, 0xab)),
      );

      final message = const TransactionMessage(version: TransactionVersion.v0)
          .copyWith(
            feePayer: const Address(
              '22222222222222222222222222222222222222222222',
            ),
            lifetimeConstraint: BlockhashLifetimeConstraint(
              blockhash: '11111111111111111111111111111111',
              lastValidBlockHeight: BigInt.zero,
            ),
          );

      final compiled = compileTransaction(message);

      // Replace the null signature with a real one.
      final feePayer = compiled.signatures.keys.first;
      final transaction = Transaction(
        messageBytes: compiled.messageBytes,
        signatures: {feePayer: sigBytes},
      );

      final encoder = getTransactionEncoder();
      final encoded = encoder.encode(transaction);

      final decoder = getTransactionDecoder();
      final decoded = decoder.decode(encoded);

      expect(decoded.signatures[feePayer], isNotNull);
      expect(decoded.signatures[feePayer]!.value, sigBytes.value);
    });
  });

  group('getTransactionCodec', () {
    test('round-trips a compiled transaction', () {
      final message = const TransactionMessage(version: TransactionVersion.v0)
          .copyWith(
            feePayer: const Address(
              '22222222222222222222222222222222222222222222',
            ),
            lifetimeConstraint: BlockhashLifetimeConstraint(
              blockhash: '11111111111111111111111111111111',
              lastValidBlockHeight: BigInt.zero,
            ),
            instructions: [
              const Instruction(
                programAddress: Address(
                  '33333333333333333333333333333333333333333333',
                ),
              ),
            ],
          );

      final compiled = compileTransaction(message);
      final codec = getTransactionCodec();
      final encoded = codec.encode(compiled);
      final decoded = codec.decode(encoded);

      expect(decoded.messageBytes, compiled.messageBytes);
      expect(decoded.signatures.length, compiled.signatures.length);
      expect(
        decoded.signatures.keys.toList(),
        compiled.signatures.keys.toList(),
      );
    });
  });
}
