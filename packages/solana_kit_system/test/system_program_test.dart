// Comprehensive tests for the System Program instruction builder and codec.

import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_system/solana_kit_system.dart';
import 'package:test/test.dart';

const _payer = Address('GsbwXfJraMomNxBcpR3DBFsMki6Djb89kBbHFwNVBgkw');
const _newAccount = Address('Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB');
const _tokenProgram = Address('TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA');

void main() {
  // ── Program address ───────────────────────────────────────────────────────
  group('systemProgramAddress', () {
    test('is the canonical System Program address', () {
      expect(
        systemProgramAddress.value,
        '11111111111111111111111111111111',
      );
    });
  });

  // ── Instruction builder ───────────────────────────────────────────────────
  group('getCreateAccountInstruction', () {
    test('returns an Instruction with the system program address', () {
      final ix = getCreateAccountInstruction(
        payer: _payer,
        newAccount: _newAccount,
        lamports: BigInt.from(1461600),
        space: BigInt.from(82),
        programOwner: _tokenProgram,
      );
      expect(ix.programAddress, systemProgramAddress);
    });

    test('uses custom programAddress when provided', () {
      const custom = Address('11111111111111111111111111111112');
      final ix = getCreateAccountInstruction(
        payer: _payer,
        newAccount: _newAccount,
        lamports: BigInt.from(1000),
        space: BigInt.from(0),
        programOwner: _tokenProgram,
        programAddress: custom,
      );
      expect(ix.programAddress, custom);
    });

    test('has exactly 2 accounts', () {
      final ix = getCreateAccountInstruction(
        payer: _payer,
        newAccount: _newAccount,
        lamports: BigInt.from(1461600),
        space: BigInt.from(82),
        programOwner: _tokenProgram,
      );
      expect(ix.accounts, hasLength(2));
    });

    test('payer is first account with writableSigner role', () {
      final ix = getCreateAccountInstruction(
        payer: _payer,
        newAccount: _newAccount,
        lamports: BigInt.from(1461600),
        space: BigInt.from(82),
        programOwner: _tokenProgram,
      );
      expect(ix.accounts![0].address, _payer);
      expect(ix.accounts![0].role, AccountRole.writableSigner);
    });

    test('newAccount is second account with writableSigner role', () {
      final ix = getCreateAccountInstruction(
        payer: _payer,
        newAccount: _newAccount,
        lamports: BigInt.from(1461600),
        space: BigInt.from(82),
        programOwner: _tokenProgram,
      );
      expect(ix.accounts![1].address, _newAccount);
      expect(ix.accounts![1].role, AccountRole.writableSigner);
    });

    test('instruction data is non-null and non-empty', () {
      final ix = getCreateAccountInstruction(
        payer: _payer,
        newAccount: _newAccount,
        lamports: BigInt.from(1461600),
        space: BigInt.from(82),
        programOwner: _tokenProgram,
      );
      expect(ix.data, isNotNull);
      expect(ix.data!.isNotEmpty, isTrue);
    });

    test('discriminator is 0 (CreateAccount = 0 in System program)', () {
      final ix = getCreateAccountInstruction(
        payer: _payer,
        newAccount: _newAccount,
        lamports: BigInt.from(1461600),
        space: BigInt.from(82),
        programOwner: _tokenProgram,
      );
      // Discriminator is u32 little-endian at offset 0
      final disc = ByteData.view(ix.data!.buffer)
          .getUint32(0, Endian.little);
      expect(disc, 0);
    });
  });

  // ── Codec ─────────────────────────────────────────────────────────────────
  group('CreateAccountInstructionData codec', () {
    test('encoder produces 52 bytes (4 disc + 8 lamports + 8 space + 32 owner)', () {
      final data = CreateAccountInstructionData(
        lamports: BigInt.from(1461600),
        space: BigInt.from(82),
        programOwner: _tokenProgram,
      );
      final encoded = getCreateAccountInstructionDataEncoder().encode(data);
      expect(encoded.length, 52);
    });

    test('discriminator is always 0', () {
      final data = CreateAccountInstructionData(
        lamports: BigInt.zero,
        space: BigInt.zero,
        programOwner: systemProgramAddress,
      );
      final encoded = getCreateAccountInstructionDataEncoder().encode(data);
      final disc = ByteData.view(encoded.buffer).getUint32(0, Endian.little);
      expect(disc, 0);
    });

    test('round-trip preserves lamports', () {
      final lamports = BigInt.parse('2039280');
      final data = CreateAccountInstructionData(
        lamports: lamports,
        space: BigInt.from(165),
        programOwner: _tokenProgram,
      );
      final encoded = getCreateAccountInstructionDataEncoder().encode(data);
      final decoded = getCreateAccountInstructionDataDecoder().decode(encoded);
      expect(decoded.lamports, lamports);
    });

    test('round-trip preserves space', () {
      final space = BigInt.from(355);
      final data = CreateAccountInstructionData(
        lamports: BigInt.from(1000000),
        space: space,
        programOwner: _tokenProgram,
      );
      final encoded = getCreateAccountInstructionDataEncoder().encode(data);
      final decoded = getCreateAccountInstructionDataDecoder().decode(encoded);
      expect(decoded.space, space);
    });

    test('round-trip preserves programOwner', () {
      final data = CreateAccountInstructionData(
        lamports: BigInt.from(1461600),
        space: BigInt.from(82),
        programOwner: _tokenProgram,
      );
      final encoded = getCreateAccountInstructionDataEncoder().encode(data);
      final decoded = getCreateAccountInstructionDataDecoder().decode(encoded);
      expect(decoded.programOwner, _tokenProgram);
    });

    test('round-trip with getCreateAccountInstructionDataCodec', () {
      final data = CreateAccountInstructionData(
        lamports: BigInt.from(890880),
        space: BigInt.zero,
        programOwner: systemProgramAddress,
      );
      final codec = getCreateAccountInstructionDataCodec();
      final decoded = codec.decode(codec.encode(data));
      expect(decoded.lamports, BigInt.from(890880));
      expect(decoded.space, BigInt.zero);
      expect(decoded.programOwner, systemProgramAddress);
    });

    test('round-trip with max u64 lamports', () {
      final maxU64 = BigInt.parse('18446744073709551615');
      final data = CreateAccountInstructionData(
        lamports: maxU64,
        space: BigInt.from(10240),
        programOwner: _tokenProgram,
      );
      final encoded = getCreateAccountInstructionDataEncoder().encode(data);
      final decoded = getCreateAccountInstructionDataDecoder().decode(encoded);
      expect(decoded.lamports, maxU64);
    });

    test('round-trip with max u64 space', () {
      final maxSpace = BigInt.parse('18446744073709551615');
      final data = CreateAccountInstructionData(
        lamports: BigInt.from(1000),
        space: maxSpace,
        programOwner: _tokenProgram,
      );
      final encoded = getCreateAccountInstructionDataEncoder().encode(data);
      final decoded = getCreateAccountInstructionDataDecoder().decode(encoded);
      expect(decoded.space, maxSpace);
    });

    test('different lamports produce different encoded bytes', () {
      final data1 = CreateAccountInstructionData(
        lamports: BigInt.from(1000),
        space: BigInt.zero,
        programOwner: systemProgramAddress,
      );
      final data2 = CreateAccountInstructionData(
        lamports: BigInt.from(2000),
        space: BigInt.zero,
        programOwner: systemProgramAddress,
      );
      final encoded1 = getCreateAccountInstructionDataEncoder().encode(data1);
      final encoded2 = getCreateAccountInstructionDataEncoder().encode(data2);
      expect(encoded1, isNot(equals(encoded2)));
    });
  });

  // ── parse round-trip ──────────────────────────────────────────────────────
  group('parseCreateAccountInstruction', () {
    test('parses a built instruction and recovers all fields', () {
      final lamports = BigInt.from(1461600);
      final space = BigInt.from(82);

      final ix = getCreateAccountInstruction(
        payer: _payer,
        newAccount: _newAccount,
        lamports: lamports,
        space: space,
        programOwner: _tokenProgram,
      );

      final parsed = parseCreateAccountInstruction(ix);
      expect(parsed.lamports, lamports);
      expect(parsed.space, space);
      expect(parsed.programOwner, _tokenProgram);
    });

    test('parsed discriminator matches default value', () {
      final ix = getCreateAccountInstruction(
        payer: _payer,
        newAccount: _newAccount,
        lamports: BigInt.from(1000),
        space: BigInt.from(10),
        programOwner: systemProgramAddress,
      );
      final parsed = parseCreateAccountInstruction(ix);
      expect(parsed.discriminator, 0);
    });

    test('built → parsed → rebuilt produces identical data bytes', () {
      final lamports = BigInt.from(2039280);
      final space = BigInt.from(165);

      final original = getCreateAccountInstruction(
        payer: _payer,
        newAccount: _newAccount,
        lamports: lamports,
        space: space,
        programOwner: _tokenProgram,
      );
      final parsed = parseCreateAccountInstruction(original);
      final rebuilt = getCreateAccountInstruction(
        payer: _payer,
        newAccount: _newAccount,
        lamports: parsed.lamports,
        space: parsed.space,
        programOwner: parsed.programOwner,
      );

      expect(original.data, equals(rebuilt.data));
    });
  });

  // ── SystemInstruction enum ────────────────────────────────────────────────
  group('SystemInstruction', () {
    test('createAccount has index 0', () {
      expect(SystemInstruction.createAccount.index, 0);
    });
  });
}
