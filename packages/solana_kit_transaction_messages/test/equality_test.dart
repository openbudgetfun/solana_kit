import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';
import 'package:test/test.dart';

void main() {
  // ---------------------------------------------------------------------------
  // DurableNonceConfig
  // ---------------------------------------------------------------------------
  group('DurableNonceConfig equality', () {
    const a = DurableNonceConfig(
      nonce: 'abc',
      nonceAccountAddress: Address('11111111111111111111111111111111'),
      nonceAuthorityAddress: Address('22222222222222222222222222222222'),
    );
    const b = DurableNonceConfig(
      nonce: 'abc',
      nonceAccountAddress: Address('11111111111111111111111111111111'),
      nonceAuthorityAddress: Address('22222222222222222222222222222222'),
    );
    const diffNonce = DurableNonceConfig(
      nonce: 'XYZ',
      nonceAccountAddress: Address('11111111111111111111111111111111'),
      nonceAuthorityAddress: Address('22222222222222222222222222222222'),
    );
    const diffAccount = DurableNonceConfig(
      nonce: 'abc',
      nonceAccountAddress: Address('33333333333333333333333333333333'),
      nonceAuthorityAddress: Address('22222222222222222222222222222222'),
    );
    const diffAuthority = DurableNonceConfig(
      nonce: 'abc',
      nonceAccountAddress: Address('11111111111111111111111111111111'),
      nonceAuthorityAddress: Address('44444444444444444444444444444444'),
    );

    test('equal when all fields match', () {
      expect(a, equals(b));
    });

    test('hashCode matches for equal instances', () {
      expect(a.hashCode, equals(b.hashCode));
    });

    test('identical instance equals itself', () {
      expect(a, equals(a));
    });

    test('not equal when nonce differs', () {
      expect(a, isNot(equals(diffNonce)));
    });

    test('not equal when nonceAccountAddress differs', () {
      expect(a, isNot(equals(diffAccount)));
    });

    test('not equal when nonceAuthorityAddress differs', () {
      expect(a, isNot(equals(diffAuthority)));
    });

    test('not equal to a different type', () {
      expect(a, isNot(equals('abc')));
    });

    test('toString returns formatted string', () {
      final str = a.toString();
      expect(str, contains('DurableNonceConfig'));
      expect(str, contains('nonce: abc'));
      expect(str, contains('nonceAccountAddress:'));
      expect(str, contains('nonceAuthorityAddress:'));
    });
  });

  // ---------------------------------------------------------------------------
  // TransactionMessage
  // ---------------------------------------------------------------------------
  group('TransactionMessage equality', () {
    final instruction1 = Instruction(
      programAddress: const Address('11111111111111111111111111111111'),
      accounts: const [
        AccountMeta(
          address: Address('22222222222222222222222222222222'),
          role: AccountRole.readonly,
        ),
      ],
      data: Uint8List.fromList([1, 2, 3]),
    );
    final instruction2 = Instruction(
      programAddress: const Address('33333333333333333333333333333333'),
      data: Uint8List.fromList([4, 5, 6]),
    );

    final base = TransactionMessage(
      version: TransactionVersion.v0,
      instructions: [instruction1],
      feePayer: const Address('44444444444444444444444444444444'),
      lifetimeConstraint: BlockhashLifetimeConstraint(
        blockhash: 'hash1',
        lastValidBlockHeight: BigInt.from(100),
      ),
    );

    final same = TransactionMessage(
      version: TransactionVersion.v0,
      instructions: [instruction1],
      feePayer: const Address('44444444444444444444444444444444'),
      lifetimeConstraint: BlockhashLifetimeConstraint(
        blockhash: 'hash1',
        lastValidBlockHeight: BigInt.from(100),
      ),
    );

    test('equal when all fields match', () {
      expect(base, equals(same));
    });

    test('hashCode matches for equal instances', () {
      expect(base.hashCode, equals(same.hashCode));
    });

    test('identical instance equals itself', () {
      expect(base, equals(base));
    });

    test('not equal when version differs', () {
      final diff = TransactionMessage(
        version: TransactionVersion.legacy,
        instructions: [instruction1],
        feePayer: const Address('44444444444444444444444444444444'),
        lifetimeConstraint: BlockhashLifetimeConstraint(
          blockhash: 'hash1',
          lastValidBlockHeight: BigInt.from(100),
        ),
      );
      expect(base, isNot(equals(diff)));
    });

    test('not equal when instructions list differs', () {
      final diff = TransactionMessage(
        version: TransactionVersion.v0,
        instructions: [instruction1, instruction2],
        feePayer: const Address('44444444444444444444444444444444'),
        lifetimeConstraint: BlockhashLifetimeConstraint(
          blockhash: 'hash1',
          lastValidBlockHeight: BigInt.from(100),
        ),
      );
      expect(base, isNot(equals(diff)));
    });

    test('not equal when feePayer differs', () {
      final diff = TransactionMessage(
        version: TransactionVersion.v0,
        instructions: [instruction1],
        feePayer: const Address('55555555555555555555555555555555'),
        lifetimeConstraint: BlockhashLifetimeConstraint(
          blockhash: 'hash1',
          lastValidBlockHeight: BigInt.from(100),
        ),
      );
      expect(base, isNot(equals(diff)));
    });

    test('not equal when feePayer is null vs non-null', () {
      const diff = TransactionMessage(
        version: TransactionVersion.v0,
      );
      const withFeePayer = TransactionMessage(
        version: TransactionVersion.v0,
        feePayer: Address('44444444444444444444444444444444'),
      );
      expect(diff, isNot(equals(withFeePayer)));
    });

    test('not equal when lifetimeConstraint differs', () {
      final diff = TransactionMessage(
        version: TransactionVersion.v0,
        instructions: [instruction1],
        feePayer: const Address('44444444444444444444444444444444'),
        lifetimeConstraint: BlockhashLifetimeConstraint(
          blockhash: 'DIFFERENT',
          lastValidBlockHeight: BigInt.from(100),
        ),
      );
      expect(base, isNot(equals(diff)));
    });

    test('not equal when lifetimeConstraint is null vs non-null', () {
      const noConstraint = TransactionMessage(version: TransactionVersion.v0);
      expect(base, isNot(equals(noConstraint)));
    });

    test('equal when both have empty instructions and no optional fields', () {
      const msg1 = TransactionMessage(version: TransactionVersion.legacy);
      const msg2 = TransactionMessage(version: TransactionVersion.legacy);
      expect(msg1, equals(msg2));
    });

    test('not equal to a different type', () {
      expect(base, isNot(equals('not a TransactionMessage')));
    });
  });

  // ---------------------------------------------------------------------------
  // DurableNonceLifetimeConstraint
  // ---------------------------------------------------------------------------
  group('DurableNonceLifetimeConstraint equality', () {
    test('equal when nonce matches', () {
      const a = DurableNonceLifetimeConstraint(nonce: 'abc');
      const b = DurableNonceLifetimeConstraint(nonce: 'abc');
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('not equal when nonce differs', () {
      const a = DurableNonceLifetimeConstraint(nonce: 'abc');
      const b = DurableNonceLifetimeConstraint(nonce: 'xyz');
      expect(a, isNot(equals(b)));
    });

    test('identical instance equals itself', () {
      const a = DurableNonceLifetimeConstraint(nonce: 'abc');
      expect(a, equals(a));
    });

    test('not equal to a different type', () {
      const a = DurableNonceLifetimeConstraint(nonce: 'abc');
      expect(a, isNot(equals('abc')));
    });
  });

  // ---------------------------------------------------------------------------
  // CompiledInstruction
  // ---------------------------------------------------------------------------
  group('CompiledInstruction equality', () {
    test('equal when all fields match', () {
      const a = CompiledInstruction(
        programAddressIndex: 1,
        accountIndices: [2, 3],
      );
      const b = CompiledInstruction(
        programAddressIndex: 1,
        accountIndices: [2, 3],
      );
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('not equal when programAddressIndex differs', () {
      const a = CompiledInstruction(programAddressIndex: 1);
      const b = CompiledInstruction(programAddressIndex: 2);
      expect(a, isNot(equals(b)));
    });

    test('not equal when accountIndices differ', () {
      const a = CompiledInstruction(
        programAddressIndex: 1,
        accountIndices: [2],
      );
      const b = CompiledInstruction(
        programAddressIndex: 1,
        accountIndices: [3],
      );
      expect(a, isNot(equals(b)));
    });

    test('not equal when one has null accountIndices', () {
      const a = CompiledInstruction(programAddressIndex: 1);
      const b = CompiledInstruction(
        programAddressIndex: 1,
        accountIndices: [2],
      );
      expect(a, isNot(equals(b)));
    });

    test('not equal to a different type', () {
      const a = CompiledInstruction(programAddressIndex: 1);
      expect(a, isNot(equals('not an instruction')));
    });

    test('equal with null data', () {
      const a = CompiledInstruction(programAddressIndex: 1);
      const b = CompiledInstruction(programAddressIndex: 1);
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });
  });

  // ---------------------------------------------------------------------------
  // AddressTableLookup
  // ---------------------------------------------------------------------------
  group('AddressTableLookup equality', () {
    test('equal when all fields match', () {
      const a = AddressTableLookup(
        lookupTableAddress: Address('11111111111111111111111111111111'),
        writableIndexes: [0, 1],
        readonlyIndexes: [2],
      );
      const b = AddressTableLookup(
        lookupTableAddress: Address('11111111111111111111111111111111'),
        writableIndexes: [0, 1],
        readonlyIndexes: [2],
      );
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('not equal when lookupTableAddress differs', () {
      const a = AddressTableLookup(
        lookupTableAddress: Address('11111111111111111111111111111111'),
        writableIndexes: [0],
        readonlyIndexes: [],
      );
      const b = AddressTableLookup(
        lookupTableAddress: Address('22222222222222222222222222222222'),
        writableIndexes: [0],
        readonlyIndexes: [],
      );
      expect(a, isNot(equals(b)));
    });

    test('not equal when writableIndexes differ', () {
      const a = AddressTableLookup(
        lookupTableAddress: Address('11111111111111111111111111111111'),
        writableIndexes: [0],
        readonlyIndexes: [],
      );
      const b = AddressTableLookup(
        lookupTableAddress: Address('11111111111111111111111111111111'),
        writableIndexes: [1],
        readonlyIndexes: [],
      );
      expect(a, isNot(equals(b)));
    });

    test('not equal when readonlyIndexes differ', () {
      const a = AddressTableLookup(
        lookupTableAddress: Address('11111111111111111111111111111111'),
        writableIndexes: [],
        readonlyIndexes: [0],
      );
      const b = AddressTableLookup(
        lookupTableAddress: Address('11111111111111111111111111111111'),
        writableIndexes: [],
        readonlyIndexes: [1],
      );
      expect(a, isNot(equals(b)));
    });

    test('not equal to a different type', () {
      const a = AddressTableLookup(
        lookupTableAddress: Address('11111111111111111111111111111111'),
        writableIndexes: [],
        readonlyIndexes: [],
      );
      expect(a, isNot(equals('not a lookup')));
    });
  });

  // ---------------------------------------------------------------------------
  // V1InstructionHeader
  // ---------------------------------------------------------------------------
  group('V1InstructionHeader inequality', () {
    test('not equal when programAccountIndex differs', () {
      const a = V1InstructionHeader(
        programAccountIndex: 1,
        numInstructionAccounts: 2,
        numInstructionDataBytes: 3,
      );
      const b = V1InstructionHeader(
        programAccountIndex: 2,
        numInstructionAccounts: 2,
        numInstructionDataBytes: 3,
      );
      expect(a, isNot(equals(b)));
    });

    test('not equal to a different type', () {
      const a = V1InstructionHeader(
        programAccountIndex: 1,
        numInstructionAccounts: 2,
        numInstructionDataBytes: 3,
      );
      expect(a, isNot(equals('not a header')));
    });
  });

  // ---------------------------------------------------------------------------
  // V1InstructionPayload
  // ---------------------------------------------------------------------------
  group('V1InstructionPayload inequality', () {
    test('not equal when instructionData differs', () {
      final a = V1InstructionPayload(
        instructionAccountIndices: const [1],
        instructionData: Uint8List.fromList([1, 2]),
      );
      final b = V1InstructionPayload(
        instructionAccountIndices: const [1],
        instructionData: Uint8List.fromList([3, 4]),
      );
      expect(a, isNot(equals(b)));
    });

    test('not equal to a different type', () {
      final a = V1InstructionPayload(
        instructionAccountIndices: const [1],
        instructionData: Uint8List.fromList([1]),
      );
      expect(a, isNot(equals('not a payload')));
    });
  });
}
