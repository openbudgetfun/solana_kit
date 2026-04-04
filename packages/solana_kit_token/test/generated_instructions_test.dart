// Tests for all generated SPL Token instruction builders and codecs.
// Each test:
//  1. Constructs an instruction via the builder.
//  2. Verifies the discriminator byte is encoded correctly.
//  3. Verifies the accounts list shape (count, roles, addresses).
//  4. Round-trips the instruction data through encoder → decoder.

import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_token/solana_kit_token.dart';
import 'package:test/test.dart';

// ---------------------------------------------------------------------------
// Shared test addresses
// ---------------------------------------------------------------------------

const _prog = Address('TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA');
const _ataProg = Address('ATokenGPvbdGVxr1b2hvZbsiqW5xWH25efTNsLJe8bSe');
const _mint = Address('EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v');
const _owner = Address('11111111111111111111111111111111');
const _account = Address('22222222222222222222222222222222222222222222');
const _delegate = Address('33333333333333333333333333333333333333333333');
const _dest = Address('44444444444444444444444444444444444444444444');
const _rent = Address('SysvarRent111111111111111111111111111111111');
const _sysProg = Address('11111111111111111111111111111111');
const _ata = Address('55555555555555555555555555555555555555555555');

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Extracts the first byte (discriminator) from the instruction data.
int _disc(Instruction ix) => ix.data![0];

/// Extracts a u64 BigInt from bytes starting at [offset].
BigInt _u64At(Uint8List bytes, int offset) {
  var result = BigInt.zero;
  for (var i = 7; i >= 0; i--) {
    result = (result << 8) | BigInt.from(bytes[offset + i]);
  }
  return result;
}

void main() {
  // ── InitializeMint (disc=0) ──────────────────────────────────────────────
  group('getInitializeMintInstruction', () {
    test('discriminator is 0', () {
      final ix = getInitializeMintInstruction(
        programAddress: _prog,
        mint: _mint,
        rent: _rent,
        decimals: 6,
        mintAuthority: _owner,
      );
      expect(_disc(ix), 0);
    });

    test('has 2 accounts: mint (writable), rent (readonly)', () {
      final ix = getInitializeMintInstruction(
        programAddress: _prog,
        mint: _mint,
        rent: _rent,
        decimals: 6,
        mintAuthority: _owner,
      );
      expect(ix.accounts, hasLength(2));
      expect(ix.accounts![0].address, _mint);
      expect(ix.accounts![0].role, AccountRole.writable);
      expect(ix.accounts![1].address, _rent);
      expect(ix.accounts![1].role, AccountRole.readonly);
    });

    test('codec round-trip preserves decimals and mintAuthority', () {
      final data = InitializeMintInstructionData(decimals: 9, mintAuthority: _owner, freezeAuthority: null);
      final encoded = getInitializeMintInstructionDataEncoder().encode(data);
      final decoded = getInitializeMintInstructionDataDecoder().decode(encoded);
      expect(decoded.decimals, 9);
      expect(decoded.mintAuthority, _owner);
      expect(decoded.freezeAuthority, isNull);
    });

    test('codec round-trip with freezeAuthority', () {
      final data = InitializeMintInstructionData(
        decimals: 6,
        mintAuthority: _owner,
        freezeAuthority: _delegate,
      );
      final encoded = getInitializeMintInstructionDataEncoder().encode(data);
      final decoded = getInitializeMintInstructionDataDecoder().decode(encoded);
      expect(decoded.freezeAuthority, _delegate);
    });
  });

  // ── InitializeAccount (disc=1) ───────────────────────────────────────────
  group('getInitializeAccountInstruction', () {
    test('discriminator is 1', () {
      final ix = getInitializeAccountInstruction(
        programAddress: _prog,
        account: _account,
        mint: _mint,
        owner: _owner,
        rent: _rent,
      );
      expect(_disc(ix), 1);
    });

    test('has 4 accounts in correct order', () {
      final ix = getInitializeAccountInstruction(
        programAddress: _prog,
        account: _account,
        mint: _mint,
        owner: _owner,
        rent: _rent,
      );
      expect(ix.accounts, hasLength(4));
      expect(ix.accounts![0].address, _account);
      expect(ix.accounts![0].role, AccountRole.writable);
      expect(ix.accounts![1].address, _mint);
    });
  });

  // ── InitializeMultisig (disc=2) ──────────────────────────────────────────
  group('getInitializeMultisigInstruction', () {
    test('discriminator is 2', () {
      final ix = getInitializeMultisigInstruction(
        programAddress: _prog,
        multisig: _account,
        rent: _rent,
        m: 2,
      );
      expect(_disc(ix), 2);
    });

    test('codec round-trip preserves m value', () {
      final data = InitializeMultisigInstructionData(m: 3);
      final encoded = getInitializeMultisigInstructionDataEncoder().encode(data);
      final decoded = getInitializeMultisigInstructionDataDecoder().decode(encoded);
      expect(decoded.m, 3);
    });
  });

  // ── Transfer (disc=3) ────────────────────────────────────────────────────
  group('getTransferInstruction', () {
    test('discriminator is 3', () {
      final ix = getTransferInstruction(
        programAddress: _prog,
        source: _account,
        destination: _dest,
        authority: _owner,
        amount: BigInt.from(1000),
      );
      expect(_disc(ix), 3);
    });

    test('has 3 accounts', () {
      final ix = getTransferInstruction(
        programAddress: _prog,
        source: _account,
        destination: _dest,
        authority: _owner,
        amount: BigInt.from(1000),
      );
      expect(ix.accounts, hasLength(3));
      expect(ix.accounts![0].role, AccountRole.writable);
      expect(ix.accounts![1].role, AccountRole.writable);
      expect(ix.accounts![2].role, AccountRole.readonlySigner);
    });

    test('codec round-trip preserves amount', () {
      final amount = BigInt.parse('9999999999999999');
      final data = TransferInstructionData(amount: amount);
      final encoded = getTransferInstructionDataEncoder().encode(data);
      final decoded = getTransferInstructionDataDecoder().decode(encoded);
      expect(decoded.amount, amount);
    });

    test('amount encoded as little-endian u64 at offset 1', () {
      final ix = getTransferInstruction(
        programAddress: _prog,
        source: _account,
        destination: _dest,
        authority: _owner,
        amount: BigInt.from(500),
      );
      expect(_u64At(ix.data!, 1), BigInt.from(500));
    });
  });

  // ── Approve (disc=4) ─────────────────────────────────────────────────────
  group('getApproveInstruction', () {
    test('discriminator is 4', () {
      final ix = getApproveInstruction(
        programAddress: _prog,
        source: _account,
        delegate: _delegate,
        owner: _owner,
        amount: BigInt.from(200),
      );
      expect(_disc(ix), 4);
    });

    test('codec round-trip preserves amount', () {
      final data = ApproveInstructionData(amount: BigInt.from(42));
      final encoded = getApproveInstructionDataEncoder().encode(data);
      final decoded = getApproveInstructionDataDecoder().decode(encoded);
      expect(decoded.amount, BigInt.from(42));
    });
  });

  // ── Revoke (disc=5) ──────────────────────────────────────────────────────
  group('getRevokeInstruction', () {
    test('discriminator is 5', () {
      final ix = getRevokeInstruction(
        programAddress: _prog,
        source: _account,
        owner: _owner,
      );
      expect(_disc(ix), 5);
    });

    test('has 2 accounts', () {
      final ix = getRevokeInstruction(
        programAddress: _prog,
        source: _account,
        owner: _owner,
      );
      expect(ix.accounts, hasLength(2));
    });

    test('codec round-trip', () {
      final data = RevokeInstructionData();
      final encoded = getRevokeInstructionDataEncoder().encode(data);
      final decoded = getRevokeInstructionDataDecoder().decode(encoded);
      expect(decoded.discriminator, 5);
    });
  });

  // ── SetAuthority (disc=6) ────────────────────────────────────────────────
  group('getSetAuthorityInstruction', () {
    test('discriminator is 6', () {
      final ix = getSetAuthorityInstruction(
        programAddress: _prog,
        owned: _mint,
        owner: _owner,
        authorityType: AuthorityType.mintTokens,
        newAuthority: _delegate,
      );
      expect(_disc(ix), 6);
    });

    test('codec round-trip with authorityType=mintTokens and new authority', () {
      final data = SetAuthorityInstructionData(
        authorityType: AuthorityType.mintTokens,
        newAuthority: _delegate,
      );
      final encoded = getSetAuthorityInstructionDataEncoder().encode(data);
      final decoded = getSetAuthorityInstructionDataDecoder().decode(encoded);
      expect(decoded.authorityType, AuthorityType.mintTokens);
      expect(decoded.newAuthority, _delegate);
    });

    test('codec round-trip with null new authority', () {
      final data = SetAuthorityInstructionData(
        authorityType: AuthorityType.closeAccount,
        newAuthority: null,
      );
      final encoded = getSetAuthorityInstructionDataEncoder().encode(data);
      final decoded = getSetAuthorityInstructionDataDecoder().decode(encoded);
      expect(decoded.newAuthority, isNull);
    });
  });

  // ── MintTo (disc=7) ──────────────────────────────────────────────────────
  group('getMintToInstruction', () {
    test('discriminator is 7', () {
      final ix = getMintToInstruction(
        programAddress: _prog,
        mint: _mint,
        token: _account,
        mintAuthority: _owner,
        amount: BigInt.from(1000000),
      );
      expect(_disc(ix), 7);
    });

    test('has 3 accounts: mint (writable), token (writable), authority (signer)', () {
      final ix = getMintToInstruction(
        programAddress: _prog,
        mint: _mint,
        token: _account,
        mintAuthority: _owner,
        amount: BigInt.from(1),
      );
      expect(ix.accounts, hasLength(3));
      expect(ix.accounts![0].role, AccountRole.writable);
      expect(ix.accounts![1].role, AccountRole.writable);
      expect(ix.accounts![2].role, AccountRole.readonlySigner);
    });

    test('codec round-trip preserves amount', () {
      final amount = BigInt.from(1000000000);
      final data = MintToInstructionData(amount: amount);
      final encoded = getMintToInstructionDataEncoder().encode(data);
      final decoded = getMintToInstructionDataDecoder().decode(encoded);
      expect(decoded.amount, amount);
    });
  });

  // ── Burn (disc=8) ────────────────────────────────────────────────────────
  group('getBurnInstruction', () {
    test('discriminator is 8', () {
      final ix = getBurnInstruction(
        programAddress: _prog,
        account: _account,
        mint: _mint,
        authority: _owner,
        amount: BigInt.from(500),
      );
      expect(_disc(ix), 8);
    });

    test('codec round-trip preserves amount', () {
      final data = BurnInstructionData(amount: BigInt.from(777));
      final encoded = getBurnInstructionDataEncoder().encode(data);
      final decoded = getBurnInstructionDataDecoder().decode(encoded);
      expect(decoded.amount, BigInt.from(777));
    });
  });

  // ── CloseAccount (disc=9) ────────────────────────────────────────────────
  group('getCloseAccountInstruction', () {
    test('discriminator is 9', () {
      final ix = getCloseAccountInstruction(
        programAddress: _prog,
        account: _account,
        destination: _dest,
        owner: _owner,
      );
      expect(_disc(ix), 9);
    });

    test('has 3 accounts', () {
      final ix = getCloseAccountInstruction(
        programAddress: _prog,
        account: _account,
        destination: _dest,
        owner: _owner,
      );
      expect(ix.accounts, hasLength(3));
      expect(ix.accounts![0].address, _account);
      expect(ix.accounts![1].address, _dest);
      expect(ix.accounts![2].address, _owner);
    });
  });

  // ── FreezeAccount (disc=10) ──────────────────────────────────────────────
  group('getFreezeAccountInstruction', () {
    test('discriminator is 10', () {
      final ix = getFreezeAccountInstruction(
        programAddress: _prog,
        account: _account,
        mint: _mint,
        owner: _owner,
      );
      expect(_disc(ix), 10);
    });

    test('has 3 accounts', () {
      final ix = getFreezeAccountInstruction(
        programAddress: _prog,
        account: _account,
        mint: _mint,
        owner: _owner,
      );
      expect(ix.accounts, hasLength(3));
    });
  });

  // ── ThawAccount (disc=11) ────────────────────────────────────────────────
  group('getThawAccountInstruction', () {
    test('discriminator is 11', () {
      final ix = getThawAccountInstruction(
        programAddress: _prog,
        account: _account,
        mint: _mint,
        owner: _owner,
      );
      expect(_disc(ix), 11);
    });
  });

  // ── TransferChecked (disc=12) ────────────────────────────────────────────
  group('getTransferCheckedInstruction', () {
    test('discriminator is 12', () {
      final ix = getTransferCheckedInstruction(
        programAddress: _prog,
        source: _account,
        mint: _mint,
        destination: _dest,
        authority: _owner,
        amount: BigInt.from(100),
        decimals: 6,
      );
      expect(_disc(ix), 12);
    });

    test('has 4 accounts', () {
      final ix = getTransferCheckedInstruction(
        programAddress: _prog,
        source: _account,
        mint: _mint,
        destination: _dest,
        authority: _owner,
        amount: BigInt.from(100),
        decimals: 6,
      );
      expect(ix.accounts, hasLength(4));
    });

    test('codec round-trip preserves amount and decimals', () {
      final data = TransferCheckedInstructionData(
        amount: BigInt.from(12345),
        decimals: 9,
      );
      final encoded = getTransferCheckedInstructionDataEncoder().encode(data);
      final decoded = getTransferCheckedInstructionDataDecoder().decode(encoded);
      expect(decoded.amount, BigInt.from(12345));
      expect(decoded.decimals, 9);
    });
  });

  // ── ApproveChecked (disc=13) ─────────────────────────────────────────────
  group('getApproveCheckedInstruction', () {
    test('discriminator is 13', () {
      final ix = getApproveCheckedInstruction(
        programAddress: _prog,
        source: _account,
        mint: _mint,
        delegate: _delegate,
        owner: _owner,
        amount: BigInt.from(50),
        decimals: 6,
      );
      expect(_disc(ix), 13);
    });

    test('has 4 accounts', () {
      final ix = getApproveCheckedInstruction(
        programAddress: _prog,
        source: _account,
        mint: _mint,
        delegate: _delegate,
        owner: _owner,
        amount: BigInt.from(50),
        decimals: 6,
      );
      expect(ix.accounts, hasLength(4));
    });

    test('codec round-trip', () {
      final data = ApproveCheckedInstructionData(amount: BigInt.from(99), decimals: 2);
      final encoded = getApproveCheckedInstructionDataEncoder().encode(data);
      final decoded = getApproveCheckedInstructionDataDecoder().decode(encoded);
      expect(decoded.amount, BigInt.from(99));
      expect(decoded.decimals, 2);
    });
  });

  // ── MintToChecked (disc=14) ──────────────────────────────────────────────
  group('getMintToCheckedInstruction', () {
    test('discriminator is 14', () {
      final ix = getMintToCheckedInstruction(
        programAddress: _prog,
        mint: _mint,
        token: _account,
        mintAuthority: _owner,
        amount: BigInt.from(500),
        decimals: 6,
      );
      expect(_disc(ix), 14);
    });

    test('codec round-trip', () {
      final data = MintToCheckedInstructionData(
        amount: BigInt.from(1000000),
        decimals: 6,
      );
      final encoded = getMintToCheckedInstructionDataEncoder().encode(data);
      final decoded = getMintToCheckedInstructionDataDecoder().decode(encoded);
      expect(decoded.amount, BigInt.from(1000000));
      expect(decoded.decimals, 6);
    });
  });

  // ── BurnChecked (disc=15) ────────────────────────────────────────────────
  group('getBurnCheckedInstruction', () {
    test('discriminator is 15', () {
      final ix = getBurnCheckedInstruction(
        programAddress: _prog,
        account: _account,
        mint: _mint,
        authority: _owner,
        amount: BigInt.from(100),
        decimals: 6,
      );
      expect(_disc(ix), 15);
    });

    test('codec round-trip', () {
      final data = BurnCheckedInstructionData(amount: BigInt.from(250), decimals: 4);
      final encoded = getBurnCheckedInstructionDataEncoder().encode(data);
      final decoded = getBurnCheckedInstructionDataDecoder().decode(encoded);
      expect(decoded.amount, BigInt.from(250));
      expect(decoded.decimals, 4);
    });
  });

  // ── InitializeAccount2 (disc=16) ─────────────────────────────────────────
  group('getInitializeAccount2Instruction', () {
    test('discriminator is 16', () {
      final ix = getInitializeAccount2Instruction(
        programAddress: _prog,
        account: _account,
        mint: _mint,
        rent: _rent,
        owner: _owner,
      );
      expect(_disc(ix), 16);
    });

    test('codec round-trip preserves owner', () {
      final data = InitializeAccount2InstructionData(owner: _owner);
      final encoded = getInitializeAccount2InstructionDataEncoder().encode(data);
      final decoded = getInitializeAccount2InstructionDataDecoder().decode(encoded);
      expect(decoded.owner, _owner);
    });
  });

  // ── SyncNative (disc=17) ─────────────────────────────────────────────────
  group('getSyncNativeInstruction', () {
    test('discriminator is 17', () {
      final ix = getSyncNativeInstruction(
        programAddress: _prog,
        account: _account,
      );
      expect(_disc(ix), 17);
    });

    test('has 1 account (writable)', () {
      final ix = getSyncNativeInstruction(
        programAddress: _prog,
        account: _account,
      );
      expect(ix.accounts, hasLength(1));
      expect(ix.accounts![0].role, AccountRole.writable);
    });
  });

  // ── InitializeAccount3 (disc=18) ─────────────────────────────────────────
  group('getInitializeAccount3Instruction', () {
    test('discriminator is 18', () {
      final ix = getInitializeAccount3Instruction(
        programAddress: _prog,
        account: _account,
        mint: _mint,
        owner: _owner,
      );
      expect(_disc(ix), 18);
    });

    test('codec round-trip preserves owner', () {
      final data = InitializeAccount3InstructionData(owner: _owner);
      final encoded = getInitializeAccount3InstructionDataEncoder().encode(data);
      final decoded = getInitializeAccount3InstructionDataDecoder().decode(encoded);
      expect(decoded.owner, _owner);
    });
  });

  // ── InitializeMultisig2 (disc=19) ────────────────────────────────────────
  group('getInitializeMultisig2Instruction', () {
    test('discriminator is 19', () {
      final ix = getInitializeMultisig2Instruction(
        programAddress: _prog,
        multisig: _account,
        m: 2,
      );
      expect(_disc(ix), 19);
    });

    test('codec round-trip preserves m', () {
      final data = InitializeMultisig2InstructionData(m: 3);
      final encoded = getInitializeMultisig2InstructionDataEncoder().encode(data);
      final decoded = getInitializeMultisig2InstructionDataDecoder().decode(encoded);
      expect(decoded.m, 3);
    });
  });

  // ── InitializeMint2 (disc=20) ────────────────────────────────────────────
  group('getInitializeMint2Instruction', () {
    test('discriminator is 20', () {
      final ix = getInitializeMint2Instruction(
        programAddress: _prog,
        mint: _mint,
        decimals: 6,
        mintAuthority: _owner,
      );
      expect(_disc(ix), 20);
    });

    test('has 1 account (mint, writable)', () {
      final ix = getInitializeMint2Instruction(
        programAddress: _prog,
        mint: _mint,
        decimals: 6,
        mintAuthority: _owner,
      );
      expect(ix.accounts, hasLength(1));
      expect(ix.accounts![0].address, _mint);
      expect(ix.accounts![0].role, AccountRole.writable);
    });

    test('codec round-trip with and without freezeAuthority', () {
      final noFreeze = InitializeMint2InstructionData(
        decimals: 0,
        mintAuthority: _owner,
        freezeAuthority: null,
      );
      final encodedNoFreeze = getInitializeMint2InstructionDataEncoder().encode(noFreeze);
      final decodedNoFreeze = getInitializeMint2InstructionDataDecoder().decode(encodedNoFreeze);
      expect(decodedNoFreeze.freezeAuthority, isNull);

      final withFreeze = InitializeMint2InstructionData(
        decimals: 9,
        mintAuthority: _owner,
        freezeAuthority: _delegate,
      );
      final encodedWithFreeze = getInitializeMint2InstructionDataEncoder().encode(withFreeze);
      final decodedWithFreeze = getInitializeMint2InstructionDataDecoder().decode(encodedWithFreeze);
      expect(decodedWithFreeze.decimals, 9);
      expect(decodedWithFreeze.freezeAuthority, _delegate);
    });
  });

  // ── GetAccountDataSize (disc=21) ─────────────────────────────────────────
  group('getGetAccountDataSizeInstruction', () {
    test('discriminator is 21', () {
      final ix = getGetAccountDataSizeInstruction(
        programAddress: _prog,
        mint: _mint,
      );
      expect(_disc(ix), 21);
    });

    test('has 1 account (mint, readonly)', () {
      final ix = getGetAccountDataSizeInstruction(
        programAddress: _prog,
        mint: _mint,
      );
      expect(ix.accounts, hasLength(1));
      expect(ix.accounts![0].role, AccountRole.readonly);
    });
  });

  // ── InitializeImmutableOwner (disc=22) ───────────────────────────────────
  group('getInitializeImmutableOwnerInstruction', () {
    test('discriminator is 22', () {
      final ix = getInitializeImmutableOwnerInstruction(
        programAddress: _prog,
        account: _account,
      );
      expect(_disc(ix), 22);
    });

    test('has 1 account (writable)', () {
      final ix = getInitializeImmutableOwnerInstruction(
        programAddress: _prog,
        account: _account,
      );
      expect(ix.accounts, hasLength(1));
      expect(ix.accounts![0].role, AccountRole.writable);
    });
  });

  // ── AmountToUiAmount (disc=23) ───────────────────────────────────────────
  group('getAmountToUiAmountInstruction', () {
    test('discriminator is 23', () {
      final ix = getAmountToUiAmountInstruction(
        programAddress: _prog,
        mint: _mint,
        amount: BigInt.from(1000000),
      );
      expect(_disc(ix), 23);
    });

    test('codec round-trip preserves amount', () {
      final data = AmountToUiAmountInstructionData(amount: BigInt.from(500));
      final encoded = getAmountToUiAmountInstructionDataEncoder().encode(data);
      final decoded = getAmountToUiAmountInstructionDataDecoder().decode(encoded);
      expect(decoded.amount, BigInt.from(500));
    });
  });

  // ── UiAmountToAmount (disc=24) ───────────────────────────────────────────
  group('getUiAmountToAmountInstruction', () {
    test('discriminator is 24', () {
      final ix = getUiAmountToAmountInstruction(
        programAddress: _prog,
        mint: _mint,
        uiAmount: '1.5',
      );
      expect(_disc(ix), 24);
    });

    test('codec round-trip preserves uiAmount string', () {
      final data = UiAmountToAmountInstructionData(uiAmount: '2.5');
      final encoded = getUiAmountToAmountInstructionDataEncoder().encode(data);
      final decoded = getUiAmountToAmountInstructionDataDecoder().decode(encoded);
      expect(decoded.uiAmount, '2.5');
    });
  });

  // ── CreateAssociatedToken (disc=0 of ATA prog) ───────────────────────────
  group('getCreateAssociatedTokenInstruction', () {
    test('discriminator is 0', () {
      final ix = getCreateAssociatedTokenInstruction(
        programAddress: _ataProg,
        payer: _owner,
        ata: _ata,
        owner: _owner,
        mint: _mint,
        systemProgram: _sysProg,
        tokenProgram: _prog,
      );
      expect(_disc(ix), 0);
    });

    test('has 6 accounts', () {
      final ix = getCreateAssociatedTokenInstruction(
        programAddress: _ataProg,
        payer: _owner,
        ata: _ata,
        owner: _owner,
        mint: _mint,
        systemProgram: _sysProg,
        tokenProgram: _prog,
      );
      expect(ix.accounts, hasLength(6));
      expect(ix.accounts![0].address, _owner); // payer
      expect(ix.accounts![1].address, _ata);   // ata
      expect(ix.accounts![2].address, _owner); // owner
      expect(ix.accounts![3].address, _mint);  // mint
    });
  });

  // ── CreateAssociatedTokenIdempotent (disc=1 of ATA prog) ─────────────────
  group('getCreateAssociatedTokenIdempotentInstruction', () {
    test('discriminator is 1', () {
      final ix = getCreateAssociatedTokenIdempotentInstruction(
        programAddress: _ataProg,
        payer: _owner,
        ata: _ata,
        owner: _owner,
        mint: _mint,
        systemProgram: _sysProg,
        tokenProgram: _prog,
      );
      expect(_disc(ix), 1);
    });
  });

  // ── WithdrawExcessLamports (disc=38) ─────────────────────────────────────
  group('getWithdrawExcessLamportsInstruction', () {
    test('discriminator is 38', () {
      final ix = getWithdrawExcessLamportsInstruction(
        programAddress: _prog,
        source: _account,
        destination: _dest,
        authority: _owner,
      );
      expect(_disc(ix), 38);
    });

    test('has 3 accounts', () {
      final ix = getWithdrawExcessLamportsInstruction(
        programAddress: _prog,
        source: _account,
        destination: _dest,
        authority: _owner,
      );
      expect(ix.accounts, hasLength(3));
    });
  });

  // ── UnwrapLamports (disc=45) ─────────────────────────────────────────────
  group('getUnwrapLamportsInstruction', () {
    test('discriminator is 45', () {
      final ix = getUnwrapLamportsInstruction(
        programAddress: _prog,
        source: _account,
        destination: _dest,
        authority: _owner,
      );
      expect(_disc(ix), 45);
    });
  });
}
