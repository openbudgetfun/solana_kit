import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:test/test.dart';

void main() {
  group('getProgramDerivedAddress()', () {
    test('fatals when supplied more than 16 seeds', () async {
      await expectLater(
        getProgramDerivedAddress(
          programAddress: const Address(
            'FN2R9R724eb4WaxeDmDYrUtmJgoSzkBiQMEHELV3ocyg',
          ),
          seeds: List<String>.filled(17, ''),
        ),
        throwsA(
          isA<SolanaError>()
              .having(
                (e) => e.code,
                'code',
                SolanaErrorCode.addressesMaxNumberOfPdaSeedsExceeded,
              )
              .having(
                (e) => e.context['actual'],
                'actual',
                18, // 17 seeds + 1 bump
              ),
        ),
      );
    });

    test(
      'fatals when supplied a Uint8List seed that is 33 bytes long',
      () async {
        await expectLater(
          getProgramDerivedAddress(
            programAddress: const Address(
              '5eUi55m4FVaDqKubGH9r6ca1TxjmimmXEU9v1WUZJ47Z',
            ),
            seeds: [Uint8List(33)],
          ),
          throwsA(
            isA<SolanaError>()
                .having(
                  (e) => e.code,
                  'code',
                  SolanaErrorCode.addressesMaxPdaSeedLengthExceeded,
                )
                .having((e) => e.context['actual'], 'actual', 33),
          ),
        );
      },
    );

    test('fatals when supplied a String seed that is 33 bytes long', () async {
      await expectLater(
        getProgramDerivedAddress(
          programAddress: const Address(
            '5eUi55m4FVaDqKubGH9r6ca1TxjmimmXEU9v1WUZJ47Z',
          ),
          seeds: ['a' * 33],
        ),
        throwsA(
          isA<SolanaError>()
              .having(
                (e) => e.code,
                'code',
                SolanaErrorCode.addressesMaxPdaSeedLengthExceeded,
              )
              .having((e) => e.context['actual'], 'actual', 33),
        ),
      );
    });

    test('returns a PDA given a program address and no seeds', () async {
      final result = await getProgramDerivedAddress(
        programAddress: const Address(
          'CZ3TbkgUYpDAJVEWpujQhDSgzNTeqbokrJmYa1j4HAZc',
        ),
        seeds: [],
      );
      expect(result.$1.value, '9tVtkyCGAHSDDBPwz7895aC3p2gJRjpu2v26o35FTUco');
      expect(result.$2, 255);
    });

    test(
      'returns a PDA after trying multiple bump seeds with no seeds',
      () async {
        final result = await getProgramDerivedAddress(
          programAddress: const Address(
            'EfTbwNBrSqSuCNBhWUHsBoBdSMWgRU1S47daqRNgW7aK',
          ),
          seeds: [],
        );
        expect(result.$1.value, 'CKWT8KZ5GMzKpVRiAULWKPg1LiHt9U3NdAtbuTErHCTq');
        expect(result.$2, 251);
      },
    );

    test(
      'returns a PDA given a program address and a byte-array seed',
      () async {
        final result = await getProgramDerivedAddress(
          programAddress: const Address(
            'FD3PDEvpQ9JXq8tv7FpJPyZrCjWkCnAaTju16gFPdpqP',
          ),
          seeds: [
            Uint8List.fromList([1, 2, 3]),
          ],
        );
        expect(result.$1.value, '9Tj3hpMWacDiZoBe94sjwJQ72zsUVvEQYsrqyy2CfHky');
        expect(result.$2, 255);
      },
    );

    test(
      'returns a PDA after trying multiple bumps with a byte-array seed',
      () async {
        final result = await getProgramDerivedAddress(
          programAddress: const Address(
            '9HT3iB4oX1aZPH5V8eNUGByKuwhfcKjBQ3x9rfEAuNeF',
          ),
          seeds: [
            Uint8List.fromList([1, 2, 3]),
          ],
        );
        expect(result.$1.value, 'EeTcRajHcPh74C5D4GqZePac1wYB7Dj9ChTaNHaTH77V');
        expect(result.$2, 251);
      },
    );

    test('returns a PDA given a program address and a string seed', () async {
      final result = await getProgramDerivedAddress(
        programAddress: const Address(
          'EKaNRGA37uiGRyRPMap5EZg9cmbT5mt7KWrGwKwAQ3rK',
        ),
        seeds: ['hello'],
      );
      expect(result.$1.value, '6V76gtKMCmVVjrx4sxR9uB868HtZbL3piKEmadC7rSgf');
      expect(result.$2, 255);
    });

    test(
      'returns a PDA after trying multiple bumps with a string seed',
      () async {
        final result = await getProgramDerivedAddress(
          programAddress: const Address(
            '9PyoV2rqNtoboSvg2JD7GWhM5RQvHGwgdDvK7MCfpgX1',
          ),
          seeds: ['hello'],
        );
        expect(result.$1.value, 'E6npEurFu1UEbQFh1DsqBvny17XxUK2QPMgxD3Edn3aG');
        expect(result.$2, 251);
      },
    );

    test(
      'returns a PDA given a program address and a UTF-8 string seed',
      () async {
        final result = await getProgramDerivedAddress(
          programAddress: const Address(
            'A5dcVPLJsE2vbf7hkqqyYkYDK9UjUfNxuwGtWF2m2vEz',
          ),
          seeds: ['\u{1F680}'], // Rocket emoji
        );
        expect(result.$1.value, 'GYpAzW57Ex4Sw3rp4pq95QrjvtsDyqZsMhSZwqz3NMsE');
        expect(result.$2, 255);
      },
    );

    test(
      'returns a PDA after trying multiple bumps with a UTF-8 string seed',
      () async {
        final result = await getProgramDerivedAddress(
          programAddress: const Address(
            'H8gBP21L5ietkHgXcGbgQBCVVEdPUQyuP9Q5MPRLLSJu',
          ),
          seeds: ['\u{1F680}'], // Rocket emoji
        );
        expect(result.$1.value, '46v3JvPtEPeQmH3euXydEbxYD6yfxeZjWSzkkYvvM5Pp');
        expect(result.$2, 251);
      },
    );

    test(
      'returns the same result for different seed inputs that concatenate to '
      'the same bytes',
      () async {
        final results = await Future.wait([
          getProgramDerivedAddress(
            programAddress: const Address(
              '9PyoV2rqNtoboSvg2JD7GWhM5RQvHGwgdDvK7MCfpgX1',
            ),
            seeds: ['butterfly'],
          ),
          getProgramDerivedAddress(
            programAddress: const Address(
              '9PyoV2rqNtoboSvg2JD7GWhM5RQvHGwgdDvK7MCfpgX1',
            ),
            seeds: ['butter', 'fly'],
          ),
        ]);

        expect(results[0].$1.value, equals(results[1].$1.value));
        expect(results[0].$2, equals(results[1].$2));
      },
    );
  });

  group('createAddressWithSeed()', () {
    test('returns the SHA-256 hash of the concatenated inputs', () async {
      const baseAddress = Address(
        'Bh1uUDP3ApWLeccVNHwyQKpnfGQbuE2UECbGA6M4jiZJ',
      );
      const programAddress = Address(
        'FGrddpvjBUAG6VdV4fR8Q2hEZTHS6w4SEveVBgfwbfdm',
      );
      const expectedAddress = 'HUKxCeXY6gZohFJFARbLE6L6C9wDEHz1SfK8ENM7QY7z';

      final result1 = await createAddressWithSeed(
        baseAddress: baseAddress,
        programAddress: programAddress,
        seed: 'seed',
      );
      expect(result1.value, equals(expectedAddress));

      // Same result with Uint8List seed
      final result2 = await createAddressWithSeed(
        baseAddress: baseAddress,
        programAddress: programAddress,
        seed: Uint8List.fromList([0x73, 0x65, 0x65, 0x64]),
      );
      expect(result2.value, equals(expectedAddress));
    });

    test('fails when the seed is longer than 32 bytes', () async {
      await expectLater(
        createAddressWithSeed(
          baseAddress: const Address(
            'Bh1uUDP3ApWLeccVNHwyQKpnfGQbuE2UECbGA6M4jiZJ',
          ),
          programAddress: const Address(
            'FGrddpvjBUAG6VdV4fR8Q2hEZTHS6w4SEveVBgfwbfdm',
          ),
          seed: 'a' * 33,
        ),
        throwsA(
          isA<SolanaError>()
              .having(
                (e) => e.code,
                'code',
                SolanaErrorCode.addressesMaxPdaSeedLengthExceeded,
              )
              .having((e) => e.context['actual'], 'actual', 33),
        ),
      );
    });

    test(
      'fails with a malicious programAddress that ends with PDA marker',
      () async {
        // The ending bytes of this address decode to the ASCII string
        // 'ProgramDerivedAddress'
        await expectLater(
          createAddressWithSeed(
            baseAddress: const Address(
              'Bh1uUDP3ApWLeccVNHwyQKpnfGQbuE2UECbGA6M4jiZJ',
            ),
            programAddress: const Address(
              '4vJ9JU1bJJE96FbKdjWme2JfVK1knU936FHTDZV7AC2',
            ),
            seed: 'seed',
          ),
          throwsA(
            isA<SolanaError>().having(
              (e) => e.code,
              'code',
              SolanaErrorCode.addressesPdaEndsWithPdaMarker,
            ),
          ),
        );
      },
    );
  });
}
