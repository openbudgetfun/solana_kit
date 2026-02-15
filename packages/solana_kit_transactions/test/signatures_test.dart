import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_keys/solana_kit_keys.dart';
import 'package:solana_kit_transactions/solana_kit_transactions.dart';
import 'package:test/test.dart';

void main() {
  group('getSignatureFromTransaction', () {
    test("returns the signature associated with a transaction's fee payer", () {
      final sigBytes = SignatureBytes(
        Uint8List.fromList(List<int>.filled(64, 9)),
      );
      final transaction = TransactionWithLifetime(
        lifetimeConstraint: TransactionBlockhashLifetime(
          blockhash: '11111111111111111111111111111111',
          lastValidBlockHeight: BigInt.zero,
        ),
        messageBytes: Uint8List(0),
        signatures: {
          const Address('12345678901234567890123456789012'): sigBytes,
        },
      );
      final sig = getSignatureFromTransaction(transaction);
      expect(sig.value, isA<String>());
      expect(sig.value.isNotEmpty, isTrue);
    });

    test('throws when supplied a transaction that has not been signed by the '
        'fee payer', () {
      final transaction = TransactionWithLifetime(
        lifetimeConstraint: TransactionBlockhashLifetime(
          blockhash: '11111111111111111111111111111111',
          lastValidBlockHeight: BigInt.zero,
        ),
        messageBytes: Uint8List(0),
        signatures: const {},
      );
      expect(
        () => getSignatureFromTransaction(transaction),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.transactionFeePayerSignatureMissing,
          ),
        ),
      );
    });

    test('throws when the fee payer signature is null', () {
      final transaction = TransactionWithLifetime(
        lifetimeConstraint: TransactionBlockhashLifetime(
          blockhash: '11111111111111111111111111111111',
          lastValidBlockHeight: BigInt.zero,
        ),
        messageBytes: Uint8List(0),
        signatures: const {Address('12345678901234567890123456789012'): null},
      );
      expect(
        () => getSignatureFromTransaction(transaction),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.transactionFeePayerSignatureMissing,
          ),
        ),
      );
    });
  });

  group('partiallySignTransaction', () {
    late KeyPair keyPairA;
    late KeyPair keyPairB;
    late KeyPair keyPairC;
    late Address addressA;
    late Address addressB;
    late Address addressC;

    setUp(() {
      keyPairA = generateKeyPair();
      keyPairB = generateKeyPair();
      keyPairC = generateKeyPair();
      addressA = getAddressFromPublicKey(keyPairA.publicKey);
      addressB = getAddressFromPublicKey(keyPairB.publicKey);
      addressC = getAddressFromPublicKey(keyPairC.publicKey);
    });

    test(
      "returns a signed transaction having the first signer's signature",
      () async {
        final transaction = TransactionWithLifetime(
          lifetimeConstraint: TransactionBlockhashLifetime(
            blockhash: '11111111111111111111111111111111',
            lastValidBlockHeight: BigInt.zero,
          ),
          messageBytes: Uint8List.fromList([1, 2, 3]),
          signatures: {addressA: null},
        );

        final signed = await partiallySignTransaction([keyPairA], transaction);
        expect(signed.signatures[addressA], isNotNull);
        expect(signed.signatures[addressA]!.value.length, 64);
      },
    );

    test('returns unchanged compiled message bytes', () async {
      final messageBytes = Uint8List.fromList([1, 2, 3]);
      final transaction = TransactionWithLifetime(
        lifetimeConstraint: TransactionBlockhashLifetime(
          blockhash: '11111111111111111111111111111111',
          lastValidBlockHeight: BigInt.zero,
        ),
        messageBytes: messageBytes,
        signatures: {addressA: null},
      );
      final signed = await partiallySignTransaction([keyPairA], transaction);
      expect(signed.messageBytes, messageBytes);
    });

    test(
      'returns a signed transaction with null for missing signers',
      () async {
        final transaction = TransactionWithLifetime(
          lifetimeConstraint: TransactionBlockhashLifetime(
            blockhash: '11111111111111111111111111111111',
            lastValidBlockHeight: BigInt.zero,
          ),
          messageBytes: Uint8List.fromList([1, 2, 3]),
          signatures: {addressA: null, addressB: null, addressC: null},
        );
        final signed = await partiallySignTransaction([keyPairA], transaction);
        expect(signed.signatures[addressA], isNotNull);
        expect(signed.signatures[addressB], isNull);
        expect(signed.signatures[addressC], isNull);
      },
    );

    test(
      "returns a transaction having the second signer's signature",
      () async {
        final transaction = TransactionWithLifetime(
          lifetimeConstraint: TransactionBlockhashLifetime(
            blockhash: '11111111111111111111111111111111',
            lastValidBlockHeight: BigInt.zero,
          ),
          messageBytes: Uint8List.fromList([1, 2, 3]),
          signatures: {addressA: null, addressB: null},
        );
        final signed = await partiallySignTransaction([keyPairB], transaction);
        expect(signed.signatures[addressB], isNotNull);
      },
    );

    test('returns a transaction with multiple signatures', () async {
      final transaction = TransactionWithLifetime(
        lifetimeConstraint: TransactionBlockhashLifetime(
          blockhash: '11111111111111111111111111111111',
          lastValidBlockHeight: BigInt.zero,
        ),
        messageBytes: Uint8List.fromList([1, 2, 3]),
        signatures: {addressA: null, addressB: null, addressC: null},
      );
      final signed = await partiallySignTransaction([
        keyPairA,
        keyPairB,
        keyPairC,
      ], transaction);
      expect(signed.signatures[addressA], isNotNull);
      expect(signed.signatures[addressB], isNotNull);
      expect(signed.signatures[addressC], isNotNull);
    });

    test('returns the same transaction if no signatures changed', () async {
      final existingSig = signBytes(
        keyPairA.privateKey,
        Uint8List.fromList([1, 2, 3]),
      );
      final transaction = TransactionWithLifetime(
        lifetimeConstraint: TransactionBlockhashLifetime(
          blockhash: '11111111111111111111111111111111',
          lastValidBlockHeight: BigInt.zero,
        ),
        messageBytes: Uint8List.fromList([1, 2, 3]),
        signatures: {addressA: existingSig},
      );
      final signed = await partiallySignTransaction([keyPairA], transaction);
      expect(identical(signed, transaction), isTrue);
    });

    test('replaces an existing different signature', () async {
      final differentSig = SignatureBytes(
        Uint8List.fromList(List<int>.filled(64, 0xff)),
      );
      final transaction = TransactionWithLifetime(
        lifetimeConstraint: TransactionBlockhashLifetime(
          blockhash: '11111111111111111111111111111111',
          lastValidBlockHeight: BigInt.zero,
        ),
        messageBytes: Uint8List.fromList([1, 2, 3]),
        signatures: {addressA: differentSig},
      );
      final signed = await partiallySignTransaction([keyPairA], transaction);
      expect(signed.signatures[addressA], isNotNull);
      // The signature should be different from the original different one.
      expect(
        signed.signatures[addressA]!.value,
        isNot(equals(differentSig.value)),
      );
    });

    test(
      'throws if a keypair is for an address not in the signatures',
      () async {
        final transaction = TransactionWithLifetime(
          lifetimeConstraint: TransactionBlockhashLifetime(
            blockhash: '11111111111111111111111111111111',
            lastValidBlockHeight: BigInt.zero,
          ),
          messageBytes: Uint8List.fromList([1, 2, 3]),
          signatures: {addressA: null},
        );
        expect(
          () => partiallySignTransaction([keyPairB], transaction),
          throwsA(
            isA<SolanaError>().having(
              (e) => e.code,
              'code',
              SolanaErrorCode.transactionAddressesCannotSignTransaction,
            ),
          ),
        );
      },
    );

    test(
      'throws with multiple addresses if multiple keypairs are unexpected',
      () async {
        final transaction = TransactionWithLifetime(
          lifetimeConstraint: TransactionBlockhashLifetime(
            blockhash: '11111111111111111111111111111111',
            lastValidBlockHeight: BigInt.zero,
          ),
          messageBytes: Uint8List.fromList([1, 2, 3]),
          signatures: {addressA: null},
        );
        expect(
          () => partiallySignTransaction([keyPairB, keyPairC], transaction),
          throwsA(
            isA<SolanaError>().having(
              (e) => e.code,
              'code',
              SolanaErrorCode.transactionAddressesCannotSignTransaction,
            ),
          ),
        );
      },
    );
  });

  group('signTransaction', () {
    late KeyPair keyPairA;
    late KeyPair keyPairB;
    late Address addressA;
    late Address addressB;

    setUp(() {
      keyPairA = generateKeyPair();
      keyPairB = generateKeyPair();
      addressA = getAddressFromPublicKey(keyPairA.publicKey);
      addressB = getAddressFromPublicKey(keyPairB.publicKey);
    });

    test('fatals when missing a signer', () async {
      final transaction = TransactionWithLifetime(
        lifetimeConstraint: TransactionBlockhashLifetime(
          blockhash: '11111111111111111111111111111111',
          lastValidBlockHeight: BigInt.zero,
        ),
        messageBytes: Uint8List.fromList([1, 2, 3]),
        signatures: {addressA: null, addressB: null},
      );
      expect(
        () => signTransaction([keyPairA], transaction),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.transactionSignaturesMissing,
          ),
        ),
      );
    });

    test('returns a signed transaction with multiple signatures', () async {
      final transaction = TransactionWithLifetime(
        lifetimeConstraint: TransactionBlockhashLifetime(
          blockhash: '11111111111111111111111111111111',
          lastValidBlockHeight: BigInt.zero,
        ),
        messageBytes: Uint8List.fromList([1, 2, 3]),
        signatures: {addressA: null, addressB: null},
      );
      final signed = await signTransaction([keyPairA, keyPairB], transaction);
      expect(signed.signatures[addressA], isNotNull);
      expect(signed.signatures[addressB], isNotNull);
    });

    test(
      'returns a signed transaction with the compiled message bytes',
      () async {
        final messageBytes = Uint8List.fromList([1, 2, 3]);
        final transaction = TransactionWithLifetime(
          lifetimeConstraint: TransactionBlockhashLifetime(
            blockhash: '11111111111111111111111111111111',
            lastValidBlockHeight: BigInt.zero,
          ),
          messageBytes: messageBytes,
          signatures: {addressA: null, addressB: null},
        );
        final signed = await signTransaction([keyPairA, keyPairB], transaction);
        expect(signed.messageBytes, messageBytes);
      },
    );
  });

  group('isFullySignedTransaction', () {
    test('returns false if the transaction has missing signatures', () {
      final transaction = TransactionWithLifetime(
        lifetimeConstraint: TransactionBlockhashLifetime(
          blockhash: '11111111111111111111111111111111',
          lastValidBlockHeight: BigInt.zero,
        ),
        messageBytes: Uint8List(0),
        signatures: const {Address('AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'): null},
      );
      expect(isFullySignedTransaction(transaction), isFalse);
    });

    test('returns true if the transaction is signed by all its signers', () {
      final sigA = SignatureBytes(Uint8List(64));
      final sigB = SignatureBytes(Uint8List.fromList(List<int>.filled(64, 1)));
      final transaction = TransactionWithLifetime(
        lifetimeConstraint: TransactionBlockhashLifetime(
          blockhash: '11111111111111111111111111111111',
          lastValidBlockHeight: BigInt.zero,
        ),
        messageBytes: Uint8List(0),
        signatures: {
          const Address('AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'): sigA,
          const Address('BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB'): sigB,
        },
      );
      expect(isFullySignedTransaction(transaction), isTrue);
    });

    test('returns true if the transaction has no signatures', () {
      final transaction = TransactionWithLifetime(
        lifetimeConstraint: TransactionBlockhashLifetime(
          blockhash: '11111111111111111111111111111111',
          lastValidBlockHeight: BigInt.zero,
        ),
        messageBytes: Uint8List(0),
        signatures: const {},
      );
      expect(isFullySignedTransaction(transaction), isTrue);
    });
  });

  group('assertIsFullySignedTransaction', () {
    test('throws if the transaction has no signature for the fee payer', () {
      final transaction = TransactionWithLifetime(
        lifetimeConstraint: TransactionBlockhashLifetime(
          blockhash: '11111111111111111111111111111111',
          lastValidBlockHeight: BigInt.zero,
        ),
        messageBytes: Uint8List(0),
        signatures: const {Address('AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'): null},
      );
      expect(
        () => assertIsFullySignedTransaction(transaction),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.transactionSignaturesMissing,
          ),
        ),
      );
    });

    test('throws all missing signers if the transaction has no signature for '
        'multiple signers', () {
      final transaction = TransactionWithLifetime(
        lifetimeConstraint: TransactionBlockhashLifetime(
          blockhash: '11111111111111111111111111111111',
          lastValidBlockHeight: BigInt.zero,
        ),
        messageBytes: Uint8List(0),
        signatures: const {
          Address('AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'): null,
          Address('BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB'): null,
        },
      );
      expect(
        () => assertIsFullySignedTransaction(transaction),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.transactionSignaturesMissing,
          ),
        ),
      );
    });

    test('does not throw if the transaction is signed by its only signer', () {
      final sigA = SignatureBytes(Uint8List(64));
      final transaction = TransactionWithLifetime(
        lifetimeConstraint: TransactionBlockhashLifetime(
          blockhash: '11111111111111111111111111111111',
          lastValidBlockHeight: BigInt.zero,
        ),
        messageBytes: Uint8List(0),
        signatures: {const Address('AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'): sigA},
      );
      expect(
        () => assertIsFullySignedTransaction(transaction),
        returnsNormally,
      );
    });

    test('does not throw if the transaction has no signatures', () {
      final transaction = TransactionWithLifetime(
        lifetimeConstraint: TransactionBlockhashLifetime(
          blockhash: '11111111111111111111111111111111',
          lastValidBlockHeight: BigInt.zero,
        ),
        messageBytes: Uint8List(0),
        signatures: const {},
      );
      expect(
        () => assertIsFullySignedTransaction(transaction),
        returnsNormally,
      );
    });
  });
}
