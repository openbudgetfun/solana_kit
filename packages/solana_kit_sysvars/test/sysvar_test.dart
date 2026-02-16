import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_sysvars/solana_kit_sysvars.dart';
import 'package:test/test.dart';

void main() {
  group('sysvar addresses', () {
    test('sysvarClockAddress is correct', () {
      expect(
        sysvarClockAddress.value,
        equals('SysvarC1ock11111111111111111111111111111111'),
      );
      expect(isAddress(sysvarClockAddress.value), isTrue);
    });
    test('sysvarEpochRewardsAddress is correct', () {
      expect(
        sysvarEpochRewardsAddress.value,
        equals('SysvarEpochRewards1111111111111111111111111'),
      );
      expect(isAddress(sysvarEpochRewardsAddress.value), isTrue);
    });
    test('sysvarEpochScheduleAddress is correct', () {
      expect(
        sysvarEpochScheduleAddress.value,
        equals('SysvarEpochSchedu1e111111111111111111111111'),
      );
      expect(isAddress(sysvarEpochScheduleAddress.value), isTrue);
    });
    test('sysvarInstructionsAddress is correct', () {
      expect(
        sysvarInstructionsAddress.value,
        equals('Sysvar1nstructions1111111111111111111111111'),
      );
      expect(isAddress(sysvarInstructionsAddress.value), isTrue);
    });
    test('sysvarLastRestartSlotAddress is correct', () {
      expect(
        sysvarLastRestartSlotAddress.value,
        equals('SysvarLastRestartS1ot1111111111111111111111'),
      );
      expect(isAddress(sysvarLastRestartSlotAddress.value), isTrue);
    });
    test('sysvarRecentBlockhashesAddress is correct', () {
      expect(
        sysvarRecentBlockhashesAddress.value,
        equals('SysvarRecentB1ockHashes11111111111111111111'),
      );
      expect(isAddress(sysvarRecentBlockhashesAddress.value), isTrue);
    });
    test('sysvarRentAddress is correct', () {
      expect(
        sysvarRentAddress.value,
        equals('SysvarRent111111111111111111111111111111111'),
      );
      expect(isAddress(sysvarRentAddress.value), isTrue);
    });
    test('sysvarSlotHashesAddress is correct', () {
      expect(
        sysvarSlotHashesAddress.value,
        equals('SysvarS1otHashes111111111111111111111111111'),
      );
      expect(isAddress(sysvarSlotHashesAddress.value), isTrue);
    });
    test('sysvarSlotHistoryAddress is correct', () {
      expect(
        sysvarSlotHistoryAddress.value,
        equals('SysvarS1otHistory11111111111111111111111111'),
      );
      expect(isAddress(sysvarSlotHistoryAddress.value), isTrue);
    });
    test('sysvarStakeHistoryAddress is correct', () {
      expect(
        sysvarStakeHistoryAddress.value,
        equals('SysvarStakeHistory1111111111111111111111111'),
      );
      expect(isAddress(sysvarStakeHistoryAddress.value), isTrue);
    });
  });
}
