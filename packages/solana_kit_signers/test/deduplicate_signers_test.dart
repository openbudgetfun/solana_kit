import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_signers/solana_kit_signers.dart';
import 'package:test/test.dart';

import 'test_helpers.dart';

void main() {
  group('deduplicateSigners', () {
    test('removes duplicated signers by address', () {
      final signerA = MockTransactionPartialSigner(
        const Address('11111111111111111111111111111111'),
      );
      final signerB = MockMessagePartialSigner(
        const Address('22222222222222222222222222222222'),
      );

      final signers = <Object>[
        signerA,
        signerB,
        signerA,
        signerA,
        signerB,
        signerB,
      ];

      final deduplicatedSigners = deduplicateSigners(signers);

      expect(deduplicatedSigners, hasLength(2));
      final addresses = deduplicatedSigners.map(getSignerAddress).toList()
        ..sort((a, b) => a.value.compareTo(b.value));
      expect(addresses.map((a) => a.value).toList(), [
        '11111111111111111111111111111111',
        '22222222222222222222222222222222',
      ]);
    });

    test('fails to deduplicate distinct signers for the same address', () {
      const addressA = Address('11111111111111111111111111111111');
      const addressB = Address('22222222222222222222222222222222');
      final signers = <Object>[
        MockTransactionPartialSigner(addressA),
        MockMessagePartialSigner(addressB),
        MockTransactionModifyingSigner(addressA),
        MockTransactionSendingSigner(addressA),
      ];

      expect(
        () => deduplicateSigners(signers),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.signerAddressCannotHaveMultipleSigners,
          ),
        ),
      );
    });

    test('deduplicates equivalent noop signers with the same address', () {
      const address = Address('11111111111111111111111111111111');
      final noopSignerA = createNoopSigner(address);
      final noopSignerB = createNoopSigner(address);

      final deduplicatedSigners = deduplicateSigners([
        noopSignerA,
        noopSignerB,
      ]);

      expect(deduplicatedSigners, hasLength(1));
      expect(identical(deduplicatedSigners.single, noopSignerA), isTrue);
    });

    test(
      'fails when a noop signer and a real signer share the same address',
      () {
        const address = Address('11111111111111111111111111111111');
        final signers = <Object>[
          createNoopSigner(address),
          MockTransactionPartialSigner(address),
        ];

        expect(
          () => deduplicateSigners(signers),
          throwsA(
            isA<SolanaError>().having(
              (e) => e.code,
              'code',
              SolanaErrorCode.signerAddressCannotHaveMultipleSigners,
            ),
          ),
        );
      },
    );

    test('filters signers without cloning them', () {
      final signerA = MockTransactionPartialSigner(
        const Address('11111111111111111111111111111111'),
      );
      final signerB = MockMessagePartialSigner(
        const Address('22222222222222222222222222222222'),
      );
      final signers = <Object>[signerA, signerB];

      final deduplicatedSigners = deduplicateSigners(signers);

      expect(deduplicatedSigners, hasLength(2));
      expect(identical(deduplicatedSigners[0], signerA), isTrue);
      expect(identical(deduplicatedSigners[1], signerB), isTrue);
    });
  });
}
