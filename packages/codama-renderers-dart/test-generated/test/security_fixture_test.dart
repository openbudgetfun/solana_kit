import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:test/test.dart';
import 'package:test_generated/src/security_fixture/accounts/exact_state.dart';
import 'package:test_generated/src/security_fixture/accounts/secure_state.dart';
import 'package:test_generated/src/security_fixture/instructions/exact_action.dart';
import 'package:test_generated/src/security_fixture/instructions/legacy_optional_action.dart';
import 'package:test_generated/src/security_fixture/instructions/secure_action.dart';

const programAddress = Address('11111111111111111111111111111111');
const beforeAddress = Address('SysvarRent111111111111111111111111111111111');
const optionalAddress = Address('SysvarC1ock11111111111111111111111111111111');
const afterAddress = Address('SysvarRecentB1ockHashes11111111111111111111');

void main() {
  group('discriminator validation', () {
    test('account encoder owns omitted discriminator', () {
      final bytes = getSecureStateEncoder().encode(
        const SecureState(value: 42),
      );

      expect(bytes, orderedEquals([7, 42, 0]));
      expect(getSecureStateDecoder().decode(bytes).discriminator, 7);
    });

    test('account decoder rejects the wrong discriminator', () {
      expect(
        () => getSecureStateDecoder().decode(Uint8List.fromList([8, 42, 0])),
        throwsA(isA<SolanaError>()),
      );
    });

    test('account decoder rejects the wrong discriminator size', () {
      expect(
        () => getSecureStateDecoder().decode(
          Uint8List.fromList([7, 42, 0, 0]),
        ),
        throwsA(isA<SolanaError>()),
      );
    });

    test('instruction encoder owns omitted discriminator', () {
      final instruction = getSecureActionInstruction(
        programAddress: programAddress,
        before: beforeAddress,
        after: afterAddress,
        amount: 513,
      );

      expect(instruction.data, orderedEquals([9, 1, 2]));
      expect(parseSecureActionInstruction(instruction).discriminator, 9);
    });

    test('instruction parser rejects the wrong discriminator', () {
      final instruction = getSecureActionInstruction(
        programAddress: programAddress,
        before: beforeAddress,
        after: afterAddress,
        amount: 513,
      );
      final invalid = Instruction(
        programAddress: instruction.programAddress,
        accounts: instruction.accounts,
        data: Uint8List.fromList([10, 1, 2]),
      );

      expect(
        () => parseSecureActionInstruction(invalid),
        throwsA(isA<SolanaError>()),
      );
    });
  });

  group('exact top-level decoding', () {
    test('account decoder rejects trailing bytes', () {
      expect(
        () => getExactStateDecoder().decode(Uint8List.fromList([42, 0, 99])),
        throwsA(isA<SolanaError>()),
      );
    });

    test('account decoder rejects truncated bytes', () {
      expect(
        () => getExactStateDecoder().decode(Uint8List.fromList([42])),
        throwsA(isA<SolanaError>()),
      );
    });

    test('instruction decoder rejects trailing bytes', () {
      expect(
        () => getExactActionInstructionDataDecoder().decode(
          Uint8List.fromList([1, 2, 99]),
        ),
        throwsA(isA<SolanaError>()),
      );
    });

    test('instruction decoder rejects truncated bytes', () {
      expect(
        () => getExactActionInstructionDataDecoder().decode(
          Uint8List.fromList([1]),
        ),
        throwsA(isA<SolanaError>()),
      );
    });
  });

  group('optional account positions', () {
    test('programId strategy preserves an absent middle account slot', () {
      final instruction = getSecureActionInstruction(
        programAddress: programAddress,
        before: beforeAddress,
        after: afterAddress,
        amount: 1,
      );
      final accounts = instruction.accounts!;

      expect(accounts, hasLength(3));
      expect(accounts[0].address, beforeAddress);
      expect(accounts[1].address, programAddress);
      expect(accounts[1].role, AccountRole.readonly);
      expect(accounts[2].address, afterAddress);
      expect(accounts[2].role, AccountRole.readonlySigner);
    });

    test('programId strategy keeps a present middle account in place', () {
      final instruction = getSecureActionInstruction(
        programAddress: programAddress,
        before: beforeAddress,
        optionalMiddle: optionalAddress,
        after: afterAddress,
        amount: 1,
      );
      final accounts = instruction.accounts!;

      expect(accounts, hasLength(3));
      expect(accounts[1].address, optionalAddress);
      expect(accounts[1].role, AccountRole.writable);
      expect(accounts[2].address, afterAddress);
    });

    test('explicit omitted strategy removes the absent account slot', () {
      final instruction = getLegacyOptionalActionInstruction(
        programAddress: programAddress,
        before: beforeAddress,
        after: afterAddress,
      );
      final accounts = instruction.accounts!;

      expect(accounts, hasLength(2));
      expect(accounts[0].address, beforeAddress);
      expect(accounts[1].address, afterAddress);
    });
  });
}
