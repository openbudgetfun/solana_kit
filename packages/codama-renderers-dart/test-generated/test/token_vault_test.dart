// ignore_for_file: type=lint

/// Tests for generated token_vault code.
///
/// These tests exercise the generated Dart code for the token_vault IDL:
/// - Struct construction with const constructors
/// - Enum values and variant iteration
/// - Encoder/decoder round-trip for struct types and enums
/// - Error code values and message lookup
/// - Program address constant
/// - Instruction data codec round-trips
library;

import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

// Import generated code
import 'package:test_generated/src/token_vault/types/vault_status.dart';
import 'package:test_generated/src/token_vault/types/vault_config.dart';
import 'package:test_generated/src/token_vault/errors/token_vault.dart';
import 'package:test_generated/src/token_vault/programs/token_vault.dart';

void main() {
  group('VaultStatus enum', () {
    test('should have 4 variants', () {
      expect(VaultStatus.values.length, equals(4));
    });

    test('should have correct variant names and indices', () {
      expect(VaultStatus.active.index, equals(0));
      expect(VaultStatus.paused.index, equals(1));
      expect(VaultStatus.closed.index, equals(2));
      expect(VaultStatus.frozen.index, equals(3));
    });

    test('should iterate all variants', () {
      final names = VaultStatus.values.map((v) => v.name).toList();
      expect(names, equals(['active', 'paused', 'closed', 'frozen']));
    });

    test('should encode and decode VaultStatus', () {
      final encoder = getVaultStatusEncoder();
      final decoder = getVaultStatusDecoder();

      for (final status in VaultStatus.values) {
        final bytes = encoder.encode(status);
        final decoded = decoder.decode(bytes);
        expect(decoded, equals(status));
      }
    });

    test('should round-trip through codec', () {
      final codec = getVaultStatusCodec();

      for (final status in VaultStatus.values) {
        final bytes = codec.encode(status);
        final decoded = codec.decode(bytes);
        expect(decoded, equals(status));
      }
    });

    test('should encode to single byte (U8)', () {
      final encoder = getVaultStatusEncoder();
      final activeBytes = encoder.encode(VaultStatus.active);
      expect(activeBytes.length, equals(1));
      expect(activeBytes[0], equals(0));

      final frozenBytes = encoder.encode(VaultStatus.frozen);
      expect(frozenBytes.length, equals(1));
      expect(frozenBytes[0], equals(3));
    });
  });

  group('VaultConfig struct', () {
    test('should construct with constructor', () {
      final config = VaultConfig(
        maxCapacity: BigInt.zero,
        minDeposit: BigInt.zero,
        feeRate: 0,
        isActive: false,
      );
      expect(config.maxCapacity, equals(BigInt.zero));
      expect(config.minDeposit, equals(BigInt.zero));
      expect(config.feeRate, equals(0));
      expect(config.isActive, isFalse);
    });

    test('should support equality', () {
      final a = VaultConfig(
        maxCapacity: BigInt.from(1000),
        minDeposit: BigInt.from(10),
        feeRate: 250,
        isActive: true,
      );
      final b = VaultConfig(
        maxCapacity: BigInt.from(1000),
        minDeposit: BigInt.from(10),
        feeRate: 250,
        isActive: true,
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('should detect inequality', () {
      final a = VaultConfig(
        maxCapacity: BigInt.from(1000),
        minDeposit: BigInt.from(10),
        feeRate: 250,
        isActive: true,
      );
      final c = VaultConfig(
        maxCapacity: BigInt.from(2000),
        minDeposit: BigInt.from(10),
        feeRate: 250,
        isActive: true,
      );
      expect(a, isNot(equals(c)));
    });

    test('should have meaningful toString()', () {
      final config = VaultConfig(
        maxCapacity: BigInt.from(100),
        minDeposit: BigInt.from(5),
        feeRate: 50,
        isActive: true,
      );
      final str = config.toString();
      expect(str, contains('VaultConfig'));
      expect(str, contains('maxCapacity'));
      expect(str, contains('minDeposit'));
      expect(str, contains('feeRate'));
      expect(str, contains('isActive'));
    });

    test('should encode and decode VaultConfig', () {
      final original = VaultConfig(
        maxCapacity: BigInt.from(5000),
        minDeposit: BigInt.from(100),
        feeRate: 500,
        isActive: true,
      );

      final encoder = getVaultConfigEncoder();
      final decoder = getVaultConfigDecoder();

      final bytes = encoder.encode(original);
      final decoded = decoder.decode(bytes);

      expect(decoded.maxCapacity, equals(original.maxCapacity));
      expect(decoded.minDeposit, equals(original.minDeposit));
      expect(decoded.feeRate, equals(original.feeRate));
      expect(decoded.isActive, equals(original.isActive));
    });

    test('should round-trip through codec', () {
      final original = VaultConfig(
        maxCapacity: BigInt.from(999999),
        minDeposit: BigInt.one,
        feeRate: 10000,
        isActive: false,
      );

      final codec = getVaultConfigCodec();
      final bytes = codec.encode(original);
      final decoded = codec.decode(bytes);

      expect(decoded, equals(original));
    });
  });

  group('Token Vault errors', () {
    test('should have correct error code for InvalidAuthority', () {
      expect(tokenVaultErrorInvalidAuthority, equals(0x1770));
      expect(tokenVaultErrorInvalidAuthority, equals(6000));
    });

    test('should have correct error code for VaultFull', () {
      expect(tokenVaultErrorVaultFull, equals(0x1771));
      expect(tokenVaultErrorVaultFull, equals(6001));
    });

    test('should have correct error code for InsufficientFunds', () {
      expect(tokenVaultErrorInsufficientFunds, equals(0x1772));
      expect(tokenVaultErrorInsufficientFunds, equals(6002));
    });

    test('should have correct error code for VaultNotActive', () {
      expect(tokenVaultErrorVaultNotActive, equals(0x1773));
      expect(tokenVaultErrorVaultNotActive, equals(6003));
    });

    test('should have correct error code for InvalidAmount', () {
      expect(tokenVaultErrorInvalidAmount, equals(0x1774));
      expect(tokenVaultErrorInvalidAmount, equals(6004));
    });

    test('should return error message for known code', () {
      expect(
        getTokenVaultErrorMessage(6000),
        equals(
          'The provided authority does not match the vault authority.',
        ),
      );
      expect(
        getTokenVaultErrorMessage(6001),
        equals('The vault has reached its maximum capacity.'),
      );
    });

    test('should return null for unknown code', () {
      expect(getTokenVaultErrorMessage(9999), isNull);
    });

    test('should detect valid error codes with isTokenVaultError', () {
      expect(isTokenVaultError(6000), isTrue);
      expect(isTokenVaultError(6001), isTrue);
      expect(isTokenVaultError(6002), isTrue);
      expect(isTokenVaultError(6003), isTrue);
      expect(isTokenVaultError(6004), isTrue);
    });

    test('should reject invalid error codes with isTokenVaultError', () {
      expect(isTokenVaultError(0), isFalse);
      expect(isTokenVaultError(5999), isFalse);
      expect(isTokenVaultError(6005), isFalse);
    });
  });

  group('Token Vault program', () {
    test('should have correct program address', () {
      expect(
        tokenVaultProgramAddress,
        equals(
          const Address('VauLT1111111111111111111111111111111111111111'),
        ),
      );
    });

    test('should have correct account enum', () {
      expect(TokenVaultAccount.values.length, equals(2));
      expect(TokenVaultAccount.vault.index, equals(0));
      expect(TokenVaultAccount.depositRecord.index, equals(1));
    });

    test('should have correct instruction enum', () {
      expect(TokenVaultInstruction.values.length, equals(4));
      expect(TokenVaultInstruction.initializeVault.index, equals(0));
      expect(TokenVaultInstruction.deposit.index, equals(1));
      expect(TokenVaultInstruction.withdraw.index, equals(2));
      expect(TokenVaultInstruction.updateVaultStatus.index, equals(3));
    });
  });
}
