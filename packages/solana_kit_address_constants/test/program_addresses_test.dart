// ignore_for_file: public_member_api_docs

import 'package:solana_kit_address/solana_kit_address.dart';
import 'package:solana_kit_address_constants/solana_kit_address_constants.dart';
import 'package:test/test.dart';

void main() {
  group('program_addresses.dart', () {
    test('systemProgramAddress has the correct value', () {
      expect(systemProgramAddress.value, '11111111111111111111111111111111');
    });

    test('addressLookupTableProgramAddress has the correct value', () {
      expect(
        addressLookupTableProgramAddress.value,
        'AddressLookupTab1e1111111111111111111111111',
      );
    });

    test('computeBudgetProgramAddress has the correct value', () {
      expect(
        computeBudgetProgramAddress.value,
        'ComputeBudget111111111111111111111111111111',
      );
    });

    test('configProgramAddress has the correct value', () {
      expect(
        configProgramAddress.value,
        'Config1111111111111111111111111111111111111',
      );
    });

    test('stakeProgramAddress has the correct value', () {
      expect(
        stakeProgramAddress.value,
        'Stake11111111111111111111111111111111111111',
      );
    });

    test('stakeConfigAddress has the correct value', () {
      expect(
        stakeConfigAddress.value,
        'StakeConfig1111111111111111111111111111',
      );
    });

    test('voteProgramAddress has the correct value', () {
      expect(
        voteProgramAddress.value,
        'Vote111111111111111111111111111111111111111',
      );
    });

    test('bpfLoaderUpgradeableProgramAddress has the correct value', () {
      expect(
        bpfLoaderUpgradeableProgramAddress.value,
        'BPFLoaderUpgradeab1e11111111111111111111111',
      );
    });

    test('loaderV4ProgramAddress has the correct value', () {
      expect(
        loaderV4ProgramAddress.value,
        'LoaderV411111111111111111111111111111111111',
      );
    });

    test('incineratorAddress has the correct value', () {
      expect(
        incineratorAddress.value,
        '1nc1nerator11111111111111111111111111111111',
      );
    });

    test('featureProgramAddress has the correct value', () {
      expect(
        featureProgramAddress.value,
        'Feature111111111111111111111111111111111111',
      );
    });

    test('ed25519ProgramAddress has the correct value', () {
      expect(
        ed25519ProgramAddress.value,
        'Ed25519SigVerify111111111111111111111111111',
      );
    });

    test('secp256k1ProgramAddress has the correct value', () {
      expect(
        secp256k1ProgramAddress.value,
        'KeccakSecp256k11111111111111111111111111111',
      );
    });

    test('secp256r1ProgramAddress has the correct value', () {
      expect(
        secp256r1ProgramAddress.value,
        'Secp256r1SigVerify1111111111111111111111111',
      );
    });

    test('native program addresses are all valid Address instances', () {
      // Spot-check that all native program addresses are constructable and
      // produce 32-byte base58 values.
      final addresses = <Address>[
        systemProgramAddress,
        addressLookupTableProgramAddress,
        bpfLoaderProgramAddress,
        bpfLoaderDeprecatedProgramAddress,
        bpfLoaderUpgradeableProgramAddress,
        computeBudgetProgramAddress,
        configProgramAddress,
        ed25519ProgramAddress,
        featureProgramAddress,
        incineratorAddress,
        loaderV4ProgramAddress,
        nativeLoaderProgramAddress,
        secp256k1ProgramAddress,
        secp256r1ProgramAddress,
        stakeProgramAddress,
        stakeConfigAddress,
        voteProgramAddress,
        zkTokenProofProgramAddress,
        zkElgamalProofProgramAddress,
      ];

      for (final address in addresses) {
        expect(
          address.value.length,
          greaterThanOrEqualTo(32),
          reason: '${address.value} should be a valid base58 address',
        );
      }
    });
  });

  group('sysvar_addresses.dart', () {
    test('sysvarClockAddress has the correct value', () {
      expect(
        sysvarClockAddress.value,
        'SysvarC1ock11111111111111111111111111111111',
      );
    });

    test('sysvarRentAddress has the correct value', () {
      expect(
        sysvarRentAddress.value,
        'SysvarRent111111111111111111111111111111111',
      );
    });

    test('sysvarRecentBlockhashesAddress has the correct value', () {
      expect(
        sysvarRecentBlockhashesAddress.value,
        'SysvarRecentB1ockHashes11111111111111111111',
      );
    });

    test('sysvarFeesAddress has the correct value', () {
      expect(
        sysvarFeesAddress.value,
        'SysvarFees111111111111111111111111111111111',
      );
    });

    test('sysvarRewardsAddress has the correct value', () {
      expect(
        sysvarRewardsAddress.value,
        'SysvarRewards111111111111111111111111111111',
      );
    });

    test('sysvarOwnerAddress has the correct value', () {
      expect(
        sysvarOwnerAddress.value,
        'Sysvar1111111111111111111111111111111111111',
      );
    });

    test('all sysvar addresses are valid 32-byte Address instances', () {
      final addresses = <Address>[
        sysvarOwnerAddress,
        sysvarClockAddress,
        sysvarEpochRewardsAddress,
        sysvarEpochScheduleAddress,
        sysvarFeesAddress,
        sysvarInstructionsAddress,
        sysvarLastRestartSlotAddress,
        sysvarRecentBlockhashesAddress,
        sysvarRentAddress,
        sysvarRewardsAddress,
        sysvarSlotHashesAddress,
        sysvarSlotHistoryAddress,
        sysvarStakeHistoryAddress,
      ];

      for (final address in addresses) {
        expect(
          address.value.length,
          greaterThanOrEqualTo(32),
          reason: '${address.value} should be a valid base58 address',
        );
      }
    });
  });

  group('spl_addresses.dart', () {
    test('tokenProgramAddress has the correct value', () {
      expect(
        tokenProgramAddress.value,
        'TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA',
      );
    });

    test('token2022ProgramAddress has the correct value', () {
      expect(
        token2022ProgramAddress.value,
        'TokenzQdBNbLqP5VEhdkAS6EPFLC1PHnBqCXEpPxuEb',
      );
    });

    test('associatedTokenProgramAddress has the correct value', () {
      expect(
        associatedTokenProgramAddress.value,
        'ATokenGPvbdGVxr1b2hvZbsiqW5xWH25ef7s3c8BnQKu',
      );
    });

    test('memoProgramAddress has the correct value', () {
      expect(
        memoProgramAddress.value,
        'Memo1UhkJ4AsZNBm8hWoQeYfRDfaK9K7a8Kj9vOUdhM7Q',
      );
    });

    test('memoLegacyProgramAddress has the correct value', () {
      expect(
        memoLegacyProgramAddress.value,
        'MemoSq4gqABb5KBAsS3tQ9UJMKg7hXe3LF7tu4RssKE3',
      );
    });

    test('all SPL addresses are valid 32-byte Address instances', () {
      final addresses = <Address>[
        tokenProgramAddress,
        token2022ProgramAddress,
        associatedTokenProgramAddress,
        memoProgramAddress,
        memoLegacyProgramAddress,
      ];

      for (final address in addresses) {
        expect(
          address.value.length,
          greaterThanOrEqualTo(32),
          reason: '${address.value} should be a valid base58 address',
        );
      }
    });
  });

  group('metaplex_addresses.dart', () {
    test('tokenMetadataProgramAddress has the correct value', () {
      expect(
        tokenMetadataProgramAddress.value,
        'metaqbxxUerdq28cj1RbAWkYQm3ybzjb6a8bt518x1s',
      );
    });

    test('noopProgramAddress has the correct value', () {
      expect(
        noopProgramAddress.value,
        'noopb9bkMVz3tFhZ5L7bJGby9DreGG5J2P4V4Wxe8tK',
      );
    });

    test('all Metaplex addresses are valid 32-byte Address instances', () {
      final addresses = <Address>[
        tokenMetadataProgramAddress,
        mplBubblegumProgramAddress,
        mplTokenAuthRulesProgramAddress,
        mplCoreProgramAddress,
        splAccountCompressionProgramAddress,
        noopProgramAddress,
      ];

      for (final address in addresses) {
        expect(
          address.value.length,
          greaterThanOrEqualTo(32),
          reason: '${address.value} should be a valid base58 address',
        );
      }
    });
  });

  group('well_known_addresses.dart', () {
    test('wrappedSolMintAddress has the correct value', () {
      expect(
        wrappedSolMintAddress.value,
        'So11111111111111111111111111111111111111112',
      );
    });

    test('usdcMintAddress has the correct value', () {
      expect(
        usdcMintAddress.value,
        'EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v',
      );
    });

    test('usdtMintAddress has the correct value', () {
      expect(
        usdtMintAddress.value,
        'Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB',
      );
    });

    test(
      'all well-known mint addresses are valid 32-byte Address instances',
      () {
        final addresses = <Address>[
          wrappedSolMintAddress,
          usdcMintAddress,
          usdtMintAddress,
        ];

        for (final address in addresses) {
          expect(
            address.value.length,
            greaterThanOrEqualTo(32),
            reason: '${address.value} should be a valid base58 address',
          );
        }
      },
    );
  });
}
