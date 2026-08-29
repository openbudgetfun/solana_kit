import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_squads/solana_kit_squads.dart';
import 'package:test/test.dart';

/// PDA derivation vectors for the Squads V4 multisig program.
///
/// All expected addresses and bumps were produced by running the exact
/// algorithm used by the upstream TypeScript SDK (`@sqds/multisig`,
/// `sdk/multisig/src/pda.ts`) — `PublicKey.findProgramAddressSync` from
/// `@solana/web3.js` over the same byte seeds (UTF-8 string seeds, address
/// bytes, and little-endian integer seeds) — and cross-checked against the
/// Rust `squads-client` reference implementation.
void main() {
  const createKey = Address('9WzDXwBbmkg8ZTbNMqUxvQRAyrZzDsGYdLVL9zYtAWWM');
  const otherKey = Address('4Nd1mBQtrMJVYVfKf2PJy9NZUZdTAsp7ua4s6guT976W');
  const multisigPda = Address('6UehsLJKSycvwYp6sZ8CRvwJcKKqTKctY4woHrpeo59S');
  const transactionPda = Address(
    '9fQZjAFkNJLNe1QmFVzHvSCHAgCBjBtw23NCtprK3RTp',
  );
  const proposalPda = Address('EbUsKkAycv9QYS7WKqEkXNATLRcQ8UbDptr5W18tWfQi');

  group('findProgramConfigPda', () {
    test('derives the well-known singleton program config PDA', () async {
      final (address, bump) = await findProgramConfigPda();
      expect(address.value, 'BSTq9w3kZwNwpBXJEvTZz2G9ZTNyKBvoSeXMvwb4cNZr');
      expect(bump, 255);
    });
  });

  group('findMultisigPda', () {
    test('matches the upstream TypeScript derivation', () async {
      final (address, bump) = await findMultisigPda(createKey: createKey);
      expect(address.value, '6UehsLJKSycvwYp6sZ8CRvwJcKKqTKctY4woHrpeo59S');
      expect(bump, 253);
    });

    test('is deterministic', () async {
      final first = await findMultisigPda(createKey: createKey);
      final second = await findMultisigPda(createKey: createKey);
      expect(first.$1.value, second.$1.value);
      expect(first.$2, second.$2);
    });
  });

  group('findVaultPda', () {
    test('matches the upstream TypeScript derivation', () async {
      final expected = <int, String>{
        0: 'ByYrV5HaZZK9ZtcFimMdMEXkN5SnS3GDhPiVMwdqQdAt',
        1: '6zywKNzgA72dRWJt3QikJmt2AuGUsokmZYBM2Y79jF5D',
        20: '95gxHnzZLP9Xkt4j8ZeW6Aohfx1mtxakipDR5EzZd7Hk',
        255: 'FCbm1eG1MRa6J5kdJjXRKcYUMFocfnHbAebDUuTwEEdR',
      };
      for (final entry in expected.entries) {
        final (address, bump) = await findVaultPda(
          multisig: multisigPda,
          index: entry.key,
        );
        expect(address.value, entry.value, reason: 'vault index ${entry.key}');
        expect(bump, 255);
      }
    });

    test('throws for an out-of-range vault index', () async {
      expect(
        () => findVaultPda(multisig: multisigPda, index: 256),
        throwsArgumentError,
      );
      expect(
        () => findVaultPda(multisig: multisigPda, index: -1),
        throwsArgumentError,
      );
    });
  });

  group('findTransactionPda', () {
    test('matches the upstream TypeScript derivation', () async {
      final (address, bump) = await findTransactionPda(
        multisig: multisigPda,
        index: BigInt.one,
      );
      expect(address.value, '9fQZjAFkNJLNe1QmFVzHvSCHAgCBjBtw23NCtprK3RTp');
      expect(bump, 253);
    });

    test('encodes the index as little-endian u64 bytes', () async {
      final (indexZero, _) = await findTransactionPda(
        multisig: multisigPda,
        index: BigInt.zero,
      );
      expect(indexZero.value, '3tStHabqH2rhjGaYdcn8NAiDKTLtuBwqMkrzZvmCmKy9');
      final (largeIndex, _) = await findTransactionPda(
        multisig: multisigPda,
        index: BigInt.from(4294967296),
      );
      expect(largeIndex.value, 'GufkBaoGAMWz1zXZVgg1EjiUbbWtMVfaVVqXabqVfjQq');
    });
  });

  group('findProposalPda', () {
    test('matches the upstream TypeScript derivation', () async {
      final (address, bump) = await findProposalPda(
        multisig: multisigPda,
        transactionIndex: BigInt.one,
      );
      expect(address.value, proposalPda.value);
      expect(bump, 253);
    });
  });

  group('findBatchTransactionPda', () {
    test('matches the upstream TypeScript derivation', () async {
      final (address, bump) = await findBatchTransactionPda(
        multisig: multisigPda,
        batchIndex: BigInt.from(3),
        transactionIndex: 7,
      );
      expect(address.value, 'GmFr7TUkRYVkBroXtC35hffVeqJeVkANg8xQQrBn6Qa9');
      expect(bump, 255);
    });
  });

  group('findEphemeralSignerPda', () {
    test('matches the upstream TypeScript derivation', () async {
      final (address, bump) = await findEphemeralSignerPda(
        transaction: transactionPda,
        ephemeralSignerIndex: 0,
      );
      expect(address.value, '3T68qwCCoU3XYVRqgFmWpgLNMERAFCqDb6ceXvUbke9M');
      expect(bump, 254);
    });
  });

  group('findSpendingLimitPda', () {
    test('matches the upstream TypeScript derivation', () async {
      final (address, bump) = await findSpendingLimitPda(
        multisig: multisigPda,
        createKey: otherKey,
      );
      expect(address.value, '4ACySHNMmzaYWkauuzJksoTUBSExB9FipUqkurEHhpfc');
      expect(bump, 255);
    });
  });

  group('program addresses', () {
    test('expose the canonical Squads V4 program address', () {
      expect(
        squadsMultisigProgramAddress,
        'SQDS4ep65T869zMMBKyuUq6aD6EgTu8psMjkvj52pCf',
      );
      expect(
        squadsMultisigProgramAddressObject.value,
        'SQDS4ep65T869zMMBKyuUq6aD6EgTu8psMjkvj52pCf',
      );
    });
  });

  group('instruction roundtrips', () {
    const program = squadsMultisigProgramAddressObject;

    test('multisigCreate encodes and parses its discriminator', () {
      final instruction = getMultisigCreateInstruction(
        programAddress: program,
        null_: createKey,
      );

      expect(instruction.programAddress.value, squadsMultisigProgramAddress);

      expect(instruction.accounts, hasLength(1));
      expect(instruction.accounts!.first.address, createKey);
      expect(instruction.accounts!.first.role, AccountRole.readonly);

      final parsed = parseMultisigCreateInstruction(instruction);
      expect(
        parsed.discriminator,
        Uint8List.fromList([0x7a, 0x4d, 0x50, 0x9f, 0x54, 0x58, 0x5a, 0xc5]),
      );
    });

    test('configTransactionCreate roundtrips actions and memo', () {
      final instruction = getConfigTransactionCreateInstruction(
        programAddress: program,
        multisig: multisigPda,
        transaction: transactionPda,
        creator: createKey,
        rentPayer: createKey,
        systemProgram: systemProgramAddress,
        actions: [
          const ConfigActionChangeThreshold(newThreshold: 2),
        ],
        memo: 'change threshold',
      );

      expect(instruction.accounts, hasLength(5));
      expect(instruction.accounts![0].role, AccountRole.writable);
      expect(instruction.accounts![2].role, AccountRole.readonlySigner);
      expect(instruction.accounts![3].role, AccountRole.writableSigner);
      expect(instruction.accounts![4].role, AccountRole.readonly);

      final parsed = parseConfigTransactionCreateInstruction(instruction);
      expect(
        parsed.discriminator,
        Uint8List.fromList([0x9b, 0xec, 0x57, 0xe4, 0x89, 0x4b, 0x51, 0x27]),
      );
      expect(
        parsed.actions.single,
        const ConfigActionChangeThreshold(newThreshold: 2),
      );
      expect(parsed.memo, 'change threshold');
    });

    test('proposalCreate roundtrips transactionIndex and draft', () {
      final instruction = getProposalCreateInstruction(
        programAddress: program,
        multisig: multisigPda,
        proposal: proposalPda,
        creator: createKey,
        rentPayer: createKey,
        systemProgram: systemProgramAddress,
        transactionIndex: BigInt.one,
        draft: false,
      );

      expect(instruction.accounts!.first.address, multisigPda);

      final parsed = parseProposalCreateInstruction(instruction);
      expect(
        parsed.discriminator,
        Uint8List.fromList([0xdc, 0x3c, 0x49, 0xe0, 0x1e, 0x6c, 0x4f, 0x9f]),
      );
      expect(parsed.transactionIndex, BigInt.one);
      expect(parsed.draft, isFalse);
    });

    test('the program-level parser recognizes built instructions', () {
      final instruction = getProposalCreateInstruction(
        programAddress: program,
        multisig: multisigPda,
        proposal: proposalPda,
        creator: createKey,
        rentPayer: createKey,
        systemProgram: systemProgramAddress,
        transactionIndex: BigInt.from(2),
        draft: true,
      );

      final parsed = parseSquadsMultisigInstruction(instruction);
      expect(parsed, isA<ParsedProposalCreate>());
      expect(parsed.instructionType, SquadsMultisigInstruction.proposalCreate);
      expect(
        (parsed as ParsedProposalCreate).data.draft,
        isTrue,
      );
    });
  });

  group('errors', () {
    test('expose upstream error codes', () {
      expect(squadsMultisigErrorDuplicateMember, 6000);
      expect(squadsMultisigErrorInvalidThreshold, 6003);
      expect(squadsMultisigErrorUnauthorized, 6004);
      expect(squadsMultisigErrorNotAMember, 0x1775);
      expect(squadsMultisigErrorMultisigCreateDeprecated, 6044);
    });

    test('map to upstream messages', () {
      expect(
        getSquadsMultisigErrorMessage(6004),
        'Attempted to perform an unauthorized action',
      );
      expect(
        getSquadsMultisigErrorMessage(6000),
        'Found multiple members with the same pubkey',
      );
    });

    test('recognize the contiguous Squads error range', () {
      expect(isSquadsMultisigError(6000), isTrue);
      expect(isSquadsMultisigError(6004), isTrue);
      expect(isSquadsMultisigError(6044), isTrue);
      expect(isSquadsMultisigError(5999), isFalse);
      expect(isSquadsMultisigError(6045), isFalse);
      expect(getSquadsMultisigErrorMessage(6045), isNull);
    });
  });
}
