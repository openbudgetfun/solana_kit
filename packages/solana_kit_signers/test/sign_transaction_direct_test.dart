import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_keys/solana_kit_keys.dart';
import 'package:solana_kit_signers/solana_kit_signers.dart';
import 'package:solana_kit_transactions/solana_kit_transactions.dart';
import 'package:test/test.dart';

import 'test_helpers.dart';

const _addressA = Address('22222222222222222222222222222222222222222222');
const _addressB = Address('33333333333333333333333333333333333333333333');

void main() {
  group('partiallySignTransactionWithSigners', () {
    test('signs a compiled transaction directly', () async {
      final signer = MockTransactionPartialSigner(_addressA)
        ..signTransactionsMock = (transactions, config) async =>
            transactions
                .map(
                  (_) => <Address, SignatureBytes>{
                    _addressA: SignatureBytes(Uint8List.fromList(List<int>.filled(64, 1))),
                  },
                )
                .toList();

      final transaction = compileTransaction(
        createMockTransactionMessageWithSigners([signer]),
      );

      final result = await partiallySignTransactionWithSigners(
        [signer],
        transaction,
      );

      expect(result.signatures[_addressA], isNotNull);
    });

    test('applies modifying signers before partial signers', () async {
      final order = <String>[];
      final modifying = MockTransactionModifyingSigner(_addressA)
        ..modifyAndSignTransactionsMock = (transactions, config) async {
          order.add('modify');
          return transactions;
        };
      final partial = MockTransactionPartialSigner(_addressB)
        ..signTransactionsMock = (transactions, config) async {
          order.add('partial');
          return transactions
              .map(
                (_) => <Address, SignatureBytes>{
                  _addressB: SignatureBytes(Uint8List.fromList(List<int>.filled(64, 2))),
                },
              )
              .toList();
        };

      final transaction = compileTransaction(
        createMockTransactionMessageWithSigners([modifying, partial]),
      );

      await partiallySignTransactionWithSigners(
        [modifying, partial],
        transaction,
      );

      expect(order, ['modify', 'partial']);
    });

    test('throws when config is already aborted', () async {
      final signer = MockTransactionPartialSigner(_addressA);
      final transaction = compileTransaction(
        createMockTransactionMessageWithSigners([signer]),
      );

      expect(
        () => partiallySignTransactionWithSigners(
          [signer],
          transaction,
          const TransactionSignerConfig(aborted: true),
        ),
        throwsStateError,
      );
    });
  });

  group('signTransactionWithSigners', () {
    test('returns fully signed transaction for compiled transaction', () async {
      final signer = MockTransactionPartialSigner(_addressA)
        ..signTransactionsMock = (transactions, config) async =>
            transactions
                .map(
                  (_) => <Address, SignatureBytes>{
                    _addressA: SignatureBytes(Uint8List.fromList(List<int>.filled(64, 1))),
                  },
                )
                .toList();
      final transaction = compileTransaction(
        createMockTransactionMessageWithSigners([signer]),
      );

      final result = await signTransactionWithSigners([signer], transaction);

      expect(result.signatures[_addressA], isNotNull);
    });
  });

  group('signAndSendTransactionWithSigners', () {
    test('sends a compiled transaction directly', () async {
      final partial = MockTransactionPartialSigner(_addressA)
        ..signTransactionsMock = (transactions, config) async =>
            transactions
                .map(
                  (_) => <Address, SignatureBytes>{
                    _addressA: SignatureBytes(Uint8List.fromList(List<int>.filled(64, 1))),
                  },
                )
                .toList();
      final sending = MockTransactionSendingSigner(_addressB)
        ..signAndSendTransactionsMock = (transactions, config) async => [
              SignatureBytes(Uint8List.fromList([9, ...List<int>.filled(63, 0)])),
            ];
      final transaction = compileTransaction(
        createMockTransactionMessageWithSigners([partial, sending]),
      );

      final signature = await signAndSendTransactionWithSigners(
        [partial, sending],
        transaction,
      );

      expect(signature.value.first, 9);
    });

    test('throws when no resolvable sending signer exists', () async {
      final partial = MockTransactionPartialSigner(_addressA);
      final transaction = compileTransaction(
        createMockTransactionMessageWithSigners([partial]),
      );

      expect(
        () => signAndSendTransactionWithSigners([partial], transaction),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.signerTransactionSendingSignerMissing,
          ),
        ),
      );
    });

    test('throws when config is aborted before send', () async {
      final sending = MockTransactionSendingSigner(_addressA);
      final transaction = compileTransaction(
        createMockTransactionMessageWithSigners([sending]),
      );

      expect(
        () => signAndSendTransactionWithSigners(
          [sending],
          transaction,
          const TransactionSignerConfig(aborted: true),
        ),
        throwsStateError,
      );
    });
  });

  group('assertContainsResolvableTransactionSendingSigner', () {
    test('allows composite sending signers without sending-only signers', () {
      final signerA = MockTransactionCompositeSigner(_addressA);
      final signerB = MockTransactionCompositeSigner(_addressB);

      expect(
        () => assertContainsResolvableTransactionSendingSigner([signerA, signerB]),
        returnsNormally,
      );
    });

    test('throws when multiple sending-only signers exist', () {
      final signerA = MockTransactionSendingSigner(_addressA);
      final signerB = MockTransactionSendingSigner(_addressB);

      expect(
        () => assertContainsResolvableTransactionSendingSigner([signerA, signerB]),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.signerTransactionCannotHaveMultipleSendingSigners,
          ),
        ),
      );
    });
  });
}
