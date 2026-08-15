import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_system/solana_kit_system.dart';
import 'package:test/test.dart';

void main() {
  const program = Address('11111111111111111111111111111111');
  const account = Address('TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA');
  const other = Address('ATokenGPvbdGVxr1b2hvZbsiqW5xWH25efTNsLJA8knL');
  const sysvar = Address('SysvarRecentB1ockHashes11111111111111111111');
  const rent = Address('SysvarRent111111111111111111111111111111111');

  group('identifySystemInstruction', () {
    test('identifies every instruction discriminator', () {
      final cases = <(SystemInstruction, Instruction)>[
        (
          SystemInstruction.createAccount,
          getCreateAccountInstruction(
            instructionProgramAddress: program,
            payer: account,
            newAccount: other,
            lamports: BigInt.one,
            space: BigInt.zero,
            programAddress: program,
          ),
        ),
        (
          SystemInstruction.assign,
          getAssignInstruction(
            instructionProgramAddress: program,
            account: account,
            programAddress: program,
          ),
        ),
        (
          SystemInstruction.transferSol,
          getTransferSolInstruction(
            programAddress: program,
            source: account,
            destination: other,
            amount: BigInt.one,
          ),
        ),
        (
          SystemInstruction.createAccountWithSeed,
          getCreateAccountWithSeedInstruction(
            instructionProgramAddress: program,
            payer: account,
            newAccount: other,
            base: account,
            seed: 'seed',
            amount: BigInt.one,
            space: BigInt.zero,
            programAddress: program,
          ),
        ),
        (
          SystemInstruction.advanceNonceAccount,
          getAdvanceNonceAccountInstruction(
            programAddress: program,
            nonceAccount: account,
            recentBlockhashesSysvar: sysvar,
            nonceAuthority: other,
          ),
        ),
        (
          SystemInstruction.withdrawNonceAccount,
          getWithdrawNonceAccountInstruction(
            programAddress: program,
            nonceAccount: account,
            recipientAccount: other,
            recentBlockhashesSysvar: sysvar,
            rentSysvar: rent,
            nonceAuthority: other,
            withdrawAmount: BigInt.one,
          ),
        ),
        (
          SystemInstruction.initializeNonceAccount,
          getInitializeNonceAccountInstruction(
            programAddress: program,
            nonceAccount: account,
            recentBlockhashesSysvar: sysvar,
            rentSysvar: rent,
            nonceAuthority: other,
          ),
        ),
        (
          SystemInstruction.authorizeNonceAccount,
          getAuthorizeNonceAccountInstruction(
            programAddress: program,
            nonceAccount: account,
            nonceAuthority: other,
            newNonceAuthority: account,
          ),
        ),
        (
          SystemInstruction.allocate,
          getAllocateInstruction(
            programAddress: program,
            newAccount: account,
            space: BigInt.zero,
          ),
        ),
        (
          SystemInstruction.allocateWithSeed,
          getAllocateWithSeedInstruction(
            instructionProgramAddress: program,
            newAccount: account,
            baseAccount: other,
            base: other,
            seed: 'seed',
            space: BigInt.zero,
            programAddress: program,
          ),
        ),
        (
          SystemInstruction.assignWithSeed,
          getAssignWithSeedInstruction(
            instructionProgramAddress: program,
            account: account,
            baseAccount: other,
            base: other,
            seed: 'seed',
            programAddress: program,
          ),
        ),
        (
          SystemInstruction.transferSolWithSeed,
          getTransferSolWithSeedInstruction(
            programAddress: program,
            source: account,
            baseAccount: other,
            destination: other,
            amount: BigInt.one,
            fromSeed: 'seed',
            fromOwner: program,
          ),
        ),
        (
          SystemInstruction.upgradeNonceAccount,
          getUpgradeNonceAccountInstruction(
            programAddress: program,
            nonceAccount: account,
          ),
        ),
        (
          SystemInstruction.createAccountAllowPrefund,
          getCreateAccountAllowPrefundInstruction(
            instructionProgramAddress: program,
            newAccount: account,
            space: BigInt.zero,
            programAddress: program,
          ),
        ),
      ];

      for (final (expected, instruction) in cases) {
        expect(
          identifySystemInstruction(instruction.data!),
          expected,
          reason: 'expected $expected for ${instruction.data}',
        );
      }
    });

    test('throws on an unknown discriminator', () {
      expect(
        () => identifySystemInstruction(Uint8List.fromList([0xff, 0xff])),
        throwsA(isA<SolanaError>()),
      );
    });
  });

  group('parseSystemInstruction', () {
    test('parses every instruction type into its typed result', () {
      final cases = <(Type, Instruction)>[
        (
          ParsedCreateAccount,
          getCreateAccountInstruction(
            instructionProgramAddress: program,
            payer: account,
            newAccount: other,
            lamports: BigInt.one,
            space: BigInt.zero,
            programAddress: program,
          ),
        ),
        (
          ParsedAssign,
          getAssignInstruction(
            instructionProgramAddress: program,
            account: account,
            programAddress: program,
          ),
        ),
        (
          ParsedTransferSol,
          getTransferSolInstruction(
            programAddress: program,
            source: account,
            destination: other,
            amount: BigInt.one,
          ),
        ),
        (
          ParsedCreateAccountWithSeed,
          getCreateAccountWithSeedInstruction(
            instructionProgramAddress: program,
            payer: account,
            newAccount: other,
            base: account,
            seed: 'seed',
            amount: BigInt.one,
            space: BigInt.zero,
            programAddress: program,
          ),
        ),
        (
          ParsedAdvanceNonceAccount,
          getAdvanceNonceAccountInstruction(
            programAddress: program,
            nonceAccount: account,
            recentBlockhashesSysvar: sysvar,
            nonceAuthority: other,
          ),
        ),
        (
          ParsedWithdrawNonceAccount,
          getWithdrawNonceAccountInstruction(
            programAddress: program,
            nonceAccount: account,
            recipientAccount: other,
            recentBlockhashesSysvar: sysvar,
            rentSysvar: rent,
            nonceAuthority: other,
            withdrawAmount: BigInt.one,
          ),
        ),
        (
          ParsedInitializeNonceAccount,
          getInitializeNonceAccountInstruction(
            programAddress: program,
            nonceAccount: account,
            recentBlockhashesSysvar: sysvar,
            rentSysvar: rent,
            nonceAuthority: other,
          ),
        ),
        (
          ParsedAuthorizeNonceAccount,
          getAuthorizeNonceAccountInstruction(
            programAddress: program,
            nonceAccount: account,
            nonceAuthority: other,
            newNonceAuthority: account,
          ),
        ),
        (
          ParsedAllocate,
          getAllocateInstruction(
            programAddress: program,
            newAccount: account,
            space: BigInt.zero,
          ),
        ),
        (
          ParsedAllocateWithSeed,
          getAllocateWithSeedInstruction(
            instructionProgramAddress: program,
            newAccount: account,
            baseAccount: other,
            base: other,
            seed: 'seed',
            space: BigInt.zero,
            programAddress: program,
          ),
        ),
        (
          ParsedAssignWithSeed,
          getAssignWithSeedInstruction(
            instructionProgramAddress: program,
            account: account,
            baseAccount: other,
            base: other,
            seed: 'seed',
            programAddress: program,
          ),
        ),
        (
          ParsedTransferSolWithSeed,
          getTransferSolWithSeedInstruction(
            programAddress: program,
            source: account,
            baseAccount: other,
            destination: other,
            amount: BigInt.one,
            fromSeed: 'seed',
            fromOwner: program,
          ),
        ),
        (
          ParsedUpgradeNonceAccount,
          getUpgradeNonceAccountInstruction(
            programAddress: program,
            nonceAccount: account,
          ),
        ),
        (
          ParsedCreateAccountAllowPrefund,
          getCreateAccountAllowPrefundInstruction(
            instructionProgramAddress: program,
            newAccount: account,
            space: BigInt.zero,
            programAddress: program,
          ),
        ),
      ];

      for (final (expectedType, instruction) in cases) {
        final parsed = parseSystemInstruction(instruction);
        expect(parsed.runtimeType, expectedType, reason: 'for $expectedType');
      }
    });
  });
}
