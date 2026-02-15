import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_keys/solana_kit_keys.dart';
import 'package:solana_kit_signers/solana_kit_signers.dart';
import 'package:solana_kit_transactions/solana_kit_transactions.dart';
import 'package:test/test.dart';

import 'test_helpers.dart';

// Valid base58 addresses that encode to exactly 32 bytes.
const _addressA = Address('22222222222222222222222222222222222222222222');
const _addressB = Address('33333333333333333333333333333333333333333333');

void main() {
  group('partiallySignTransactionMessageWithSigners', () {
    test('signs the transaction with its extracted signers', () async {
      // Given a transaction with a modifying signer A and a partial signer B.
      final signerA = MockTransactionModifyingSigner(_addressA);
      final signerB = MockTransactionPartialSigner(_addressB);
      final transactionMessage = createMockTransactionMessageWithSigners([
        signerA,
        signerB,
      ]);

      // Mock the modifying signer to return a modified transaction.
      signerA.modifyAndSignTransactionsMock = (transactions, config) async {
        return transactions.map((tx) {
          return Transaction(
            messageBytes: tx.messageBytes,
            signatures: <Address, SignatureBytes?>{
              _addressA: SignatureBytes(Uint8List.fromList(List.filled(64, 1))),
              _addressB: null,
            },
          );
        }).toList();
      };

      // Mock the partial signer to return signatures.
      signerB.signTransactionsMock = (transactions, config) async {
        return transactions.map((_) {
          return <Address, SignatureBytes>{
            _addressB: SignatureBytes(Uint8List.fromList(List.filled(64, 2))),
          };
        }).toList();
      };

      // When we partially sign this transaction.
      final signedTransaction =
          await partiallySignTransactionMessageWithSigners(transactionMessage);

      // Then it contains signatures from both signers.
      expect(signedTransaction.signatures[_addressA], isNotNull);
      expect(signedTransaction.signatures[_addressB], isNotNull);
    });

    test('ignores sending signers', () async {
      // Given a transaction with a sending signer A and a partial+sending
      // composite signer B.
      final signerA = MockTransactionSendingSigner(_addressA);

      // Create a composite signer that is both sending and partial.
      final signerB = MockTransactionSendingPartialSigner(_addressB)
        ..signTransactionsMock = (transactions, config) async {
          return transactions.map((_) {
            return <Address, SignatureBytes>{
              _addressB: SignatureBytes(Uint8List.fromList(List.filled(64, 2))),
            };
          }).toList();
        };

      final transactionMessage = createMockTransactionMessageWithSigners([
        signerA,
        signerB,
      ]);

      // When we partially sign this transaction.
      final signedTransaction =
          await partiallySignTransactionMessageWithSigners(transactionMessage);

      // Then only the partial signer's signature is present.
      expect(signedTransaction.signatures[_addressB], isNotNull);
    });
  });

  group('signTransactionMessageWithSigners', () {
    test('asserts the transaction is fully signed', () async {
      // Given a transaction with a partial signer A and a sending signer B.
      final signerA = MockTransactionPartialSigner(_addressA);
      final signerB = MockTransactionSendingSigner(_addressB);
      final transactionMessage = createMockTransactionMessageWithSigners([
        signerA,
        signerB,
      ]);

      signerA.signTransactionsMock = (transactions, config) async {
        return transactions.map((_) {
          return <Address, SignatureBytes>{
            _addressA: SignatureBytes(Uint8List.fromList(List.filled(64, 1))),
          };
        }).toList();
      };

      // When we try to fully sign this transaction, it should fail because
      // the sending signer doesn't provide a signature.
      expect(
        () => signTransactionMessageWithSigners(transactionMessage),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.transactionSignaturesMissing,
          ),
        ),
      );
    });
  });

  group('signAndSendTransactionMessageWithSigners', () {
    test('signs and sends the transaction', () async {
      // Given a transaction with a partial signer A and a sending signer B.
      final signerA = MockTransactionPartialSigner(_addressA);
      final signerB = MockTransactionSendingSigner(_addressB);
      final transactionMessage = createMockTransactionMessageWithSigners([
        signerA,
        signerB,
      ]);

      signerA.signTransactionsMock = (transactions, config) async {
        return transactions.map((_) {
          return <Address, SignatureBytes>{
            _addressA: SignatureBytes(Uint8List.fromList(List.filled(64, 1))),
          };
        }).toList();
      };

      final expectedSignature = SignatureBytes(
        Uint8List.fromList([1, 2, 3, ...List.filled(61, 0)]),
      );
      signerB.signAndSendTransactionsMock = (transactions, config) async {
        return [expectedSignature];
      };

      // When we sign and send this transaction.
      final transactionSignature =
          await signAndSendTransactionMessageWithSigners(transactionMessage);

      // Then the returned signature matches.
      expect(transactionSignature.value, equals(expectedSignature.value));
    });

    test('fails if no sending signer exists on the transaction', () async {
      // Given a transaction with only a partial signer.
      final signer = MockTransactionPartialSigner(_addressA);
      final transactionMessage = createMockTransactionMessageWithSigners([
        signer,
      ]);

      signer.signTransactionsMock = (transactions, config) async {
        return transactions.map((_) {
          return <Address, SignatureBytes>{
            _addressA: SignatureBytes(Uint8List.fromList(List.filled(64, 1))),
          };
        }).toList();
      };

      // When we try to sign and send, it should fail.
      expect(
        () => signAndSendTransactionMessageWithSigners(transactionMessage),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.signerTransactionSendingSignerMissing,
          ),
        ),
      );
    });
  });
}
