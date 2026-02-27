// ignore_for_file: type=lint

/// Tests for generated staking code.
///
/// These tests exercise the generated Dart code for the staking IDL:
/// - Struct construction with const constructors
/// - Enum values and variant iteration
/// - Encoder/decoder round-trip for struct types and enums
/// - Error code values and message lookup
/// - Program address constant
library;

import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

// Import generated code
import 'package:test_generated/src/staking/types/pool_status.dart';
import 'package:test_generated/src/staking/types/stake_info.dart';
import 'package:test_generated/src/staking/errors/staking.dart';
import 'package:test_generated/src/staking/programs/staking.dart';

void main() {
  group('PoolStatus enum', () {
    test('should have 4 variants', () {
      expect(PoolStatus.values.length, equals(4));
    });

    test('should have correct variant names and indices', () {
      expect(PoolStatus.uninitialized.index, equals(0));
      expect(PoolStatus.active.index, equals(1));
      expect(PoolStatus.paused.index, equals(2));
      expect(PoolStatus.deprecated.index, equals(3));
    });

    test('should iterate all variants', () {
      final names = PoolStatus.values.map((v) => v.name).toList();
      expect(
        names,
        equals(['uninitialized', 'active', 'paused', 'deprecated']),
      );
    });

    test('should encode and decode PoolStatus', () {
      final encoder = getPoolStatusEncoder();
      final decoder = getPoolStatusDecoder();

      for (final status in PoolStatus.values) {
        final bytes = encoder.encode(status);
        final decoded = decoder.decode(bytes);
        expect(decoded, equals(status));
      }
    });

    test('should round-trip through codec', () {
      final codec = getPoolStatusCodec();

      for (final status in PoolStatus.values) {
        final bytes = codec.encode(status);
        final decoded = codec.decode(bytes);
        expect(decoded, equals(status));
      }
    });

    test('should encode to single byte (U8)', () {
      final encoder = getPoolStatusEncoder();

      final uninitBytes = encoder.encode(PoolStatus.uninitialized);
      expect(uninitBytes.length, equals(1));
      expect(uninitBytes[0], equals(0));

      final deprecatedBytes = encoder.encode(PoolStatus.deprecated);
      expect(deprecatedBytes.length, equals(1));
      expect(deprecatedBytes[0], equals(3));
    });
  });

  group('StakeInfo struct', () {
    test('should construct with required fields', () {
      final info = StakeInfo(
        amount: BigInt.from(1000),
        startTime: BigInt.from(1700000000),
        endTime: null,
        isLocked: true,
      );
      expect(info.amount, equals(BigInt.from(1000)));
      expect(info.startTime, equals(BigInt.from(1700000000)));
      expect(info.endTime, isNull);
      expect(info.isLocked, isTrue);
    });

    test('should construct with optional endTime', () {
      final info = StakeInfo(
        amount: BigInt.from(500),
        startTime: BigInt.from(1700000000),
        endTime: BigInt.from(1700100000),
        isLocked: false,
      );
      expect(info.endTime, equals(BigInt.from(1700100000)));
    });

    test('should support equality', () {
      final a = StakeInfo(
        amount: BigInt.from(1000),
        startTime: BigInt.from(100),
        endTime: null,
        isLocked: true,
      );
      final b = StakeInfo(
        amount: BigInt.from(1000),
        startTime: BigInt.from(100),
        endTime: null,
        isLocked: true,
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('should detect inequality', () {
      final a = StakeInfo(
        amount: BigInt.from(1000),
        startTime: BigInt.from(100),
        endTime: null,
        isLocked: true,
      );
      final c = StakeInfo(
        amount: BigInt.from(2000),
        startTime: BigInt.from(100),
        endTime: null,
        isLocked: true,
      );
      expect(a, isNot(equals(c)));
    });

    test('should have meaningful toString()', () {
      final info = StakeInfo(
        amount: BigInt.from(1000),
        startTime: BigInt.from(100),
        endTime: BigInt.from(200),
        isLocked: false,
      );
      final str = info.toString();
      expect(str, contains('StakeInfo'));
      expect(str, contains('amount'));
      expect(str, contains('startTime'));
      expect(str, contains('isLocked'));
    });

    test('should encode and decode StakeInfo', () {
      final original = StakeInfo(
        amount: BigInt.from(5000),
        startTime: BigInt.from(1700000000),
        endTime: null,
        isLocked: true,
      );

      final encoder = getStakeInfoEncoder();
      final decoder = getStakeInfoDecoder();

      final bytes = encoder.encode(original);
      final decoded = decoder.decode(bytes);

      expect(decoded.amount, equals(original.amount));
      expect(decoded.startTime, equals(original.startTime));
      expect(decoded.isLocked, equals(original.isLocked));
    });

    test('should round-trip through codec', () {
      final original = StakeInfo(
        amount: BigInt.from(9999),
        startTime: BigInt.from(1700000000),
        endTime: BigInt.from(1700100000),
        isLocked: false,
      );

      final codec = getStakeInfoCodec();
      final bytes = codec.encode(original);
      final decoded = codec.decode(bytes);

      expect(decoded.amount, equals(original.amount));
      expect(decoded.startTime, equals(original.startTime));
      expect(decoded.isLocked, equals(original.isLocked));
    });
  });

  group('Staking errors', () {
    test('should have correct error code for PoolNotActive', () {
      expect(stakingErrorPoolNotActive, equals(0x1770));
      expect(stakingErrorPoolNotActive, equals(6000));
    });

    test('should have correct error code for MaxStakersReached', () {
      expect(stakingErrorMaxStakersReached, equals(0x1771));
      expect(stakingErrorMaxStakersReached, equals(6001));
    });

    test('should have correct error code for StakeDurationNotMet', () {
      expect(stakingErrorStakeDurationNotMet, equals(0x1772));
      expect(stakingErrorStakeDurationNotMet, equals(6002));
    });

    test('should have correct error code for NoRewardsAvailable', () {
      expect(stakingErrorNoRewardsAvailable, equals(0x1773));
      expect(stakingErrorNoRewardsAvailable, equals(6003));
    });

    test('should have correct error code for InvalidStakeAmount', () {
      expect(stakingErrorInvalidStakeAmount, equals(0x1774));
      expect(stakingErrorInvalidStakeAmount, equals(6004));
    });

    test('should have correct error code for Unauthorized', () {
      expect(stakingErrorUnauthorized, equals(0x1775));
      expect(stakingErrorUnauthorized, equals(6005));
    });

    test('should return error message for known code', () {
      expect(
        getStakingErrorMessage(6000),
        equals('The staking pool is not active.'),
      );
      expect(
        getStakingErrorMessage(6005),
        equals('You are not authorized to perform this action.'),
      );
    });

    test('should return null for unknown code', () {
      expect(getStakingErrorMessage(9999), isNull);
    });

    test('should detect valid error codes with isStakingError', () {
      for (var code = 6000; code <= 6005; code++) {
        expect(
          isStakingError(code),
          isTrue,
          reason: 'Expected $code to be a staking error',
        );
      }
    });

    test('should reject invalid error codes with isStakingError', () {
      expect(isStakingError(0), isFalse);
      expect(isStakingError(5999), isFalse);
      expect(isStakingError(6006), isFalse);
    });
  });

  group('Staking program', () {
    test('should have correct program address', () {
      expect(
        stakingProgramAddress,
        equals(
          const Address('StaKe111111111111111111111111111111111111111'),
        ),
      );
    });

    test('should have correct account enum', () {
      expect(StakingAccount.values.length, equals(2));
      expect(StakingAccount.stakePool.index, equals(0));
      expect(StakingAccount.stakeAccount.index, equals(1));
    });

    test('should have correct instruction enum', () {
      expect(StakingInstruction.values.length, equals(4));
      expect(StakingInstruction.initializePool.index, equals(0));
      expect(StakingInstruction.stake.index, equals(1));
      expect(StakingInstruction.unstake.index, equals(2));
      expect(StakingInstruction.claimRewards.index, equals(3));
    });
  });
}
