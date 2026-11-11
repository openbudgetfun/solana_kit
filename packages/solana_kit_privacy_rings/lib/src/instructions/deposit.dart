import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

import 'package:solana_kit_privacy_rings/src/codec/deposit.dart';
import 'package:solana_kit_privacy_rings/src/constants.dart';
import 'package:solana_kit_privacy_rings/src/exception.dart';
import 'package:solana_kit_privacy_rings/src/pdas.dart';

/// Asset funded by one deposit output.
sealed class DepositAsset {
  const DepositAsset();
}

/// Native SOL.
class SolDepositAsset extends DepositAsset {
  /// Creates a SOL deposit asset.
  const SolDepositAsset();
}

/// An SPL or Token-2022 mint.
class SplDepositAsset extends DepositAsset {
  /// Creates an SPL deposit asset.
  const SplDepositAsset({
    required this.mint,
    required this.sourceTokenAccount,
    required this.tokenProgram,
  });

  /// Mint being deposited.
  final Address mint;

  /// Depositor's token account.
  final Address sourceTokenAccount;

  /// Token program that owns [mint]. Token or Token-2022.
  final Address tokenProgram;
}

/// One public deposit into a private balance.
class AssetDeposit {
  /// Creates a deposit output.
  const AssetDeposit({
    required this.asset,
    required this.viewTag,
    required this.recipientOwnerHash,
    required this.amount,
    this.memo,
  });

  /// SOL or an SPL mint.
  final DepositAsset asset;

  /// 32-byte indexer tag. For the permissionless ring this is the
  /// recipient wallet's public key.
  final List<int> viewTag;

  /// Recipient `owner_hash`.
  final List<int> recipientOwnerHash;

  /// Amount in base units.
  final BigInt amount;

  /// Optional cleartext memo.
  final List<int>? memo;
}

class _SplGroup {
  _SplGroup(this.asset);
  final SplDepositAsset asset;
}

class _DepositLayout {
  _DepositLayout({required this.hasSol, required this.splGroups});

  final bool hasSol;
  final List<_SplGroup> splGroups;

  int indexOf(DepositAsset asset) {
    if (asset is SolDepositAsset) return 0;
    final spl = asset as SplDepositAsset;
    final found = splGroups.indexWhere(
      (group) => group.asset.mint == spl.mint,
    );
    if (found < 0) {
      // The layout is built from the same deposits, so a miss is a bug.
      // coverage:ignore-start
      throw PrivacyRingsException(
        'deposit asset is missing from the settlement layout',
        code: 'serialization',
      );
      // coverage:ignore-end
    }
    return (hasSol ? 1 : 0) + found;
  }
}

_DepositLayout _layout(List<AssetDeposit> deposits) {
  if (deposits.isEmpty) {
    throw PrivacyRingsException(
      'deposit batch contains no entries',
      code: 'empty_deposit_batch',
    );
  }
  if (deposits.length > maxDepositEntries) {
    throw PrivacyRingsException(
      'deposit batch has ${deposits.length} entries; the wire format '
      'supports at most $maxDepositEntries',
      code: 'too_many_entries',
    );
  }
  var hasSol = false;
  final groups = <_SplGroup>[];
  for (final deposit in deposits) {
    switch (deposit.asset) {
      case SolDepositAsset():
        hasSol = true;
      case SplDepositAsset(
        :final mint,
        :final sourceTokenAccount,
        :final tokenProgram,
      ):
        final existing = groups.where((group) => group.asset.mint == mint);
        if (existing.isEmpty) {
          groups.add(_SplGroup(deposit.asset as SplDepositAsset));
          continue;
        }
        final first = existing.first.asset;
        if (first.tokenProgram != tokenProgram) {
          throw PrivacyRingsException(
            'SPL mint $mint uses conflicting token programs',
            code: 'conflicting_token_program',
          );
        }
        if (first.sourceTokenAccount != sourceTokenAccount) {
          throw PrivacyRingsException(
            'SPL mint $mint uses conflicting source token accounts',
            code: 'conflicting_spl_source',
          );
        }
    }
  }
  final assetCount = (hasSol ? 1 : 0) + groups.length;
  if (assetCount > maxDepositAssets) {
    throw PrivacyRingsException(
      'deposit batch has $assetCount assets; at most $maxDepositAssets '
      'are supported',
      code: 'too_many_assets',
    );
  }
  return _DepositLayout(hasSol: hasSol, splGroups: groups);
}

/// Builds a `deposit` instruction.
///
/// A deposit does not request a zero-knowledge proof. The owner signs the
/// Solana transaction that carries this instruction. Account order matches
/// `Deposit::instruction` in
/// `sdk-libs/instruction/src/instruction/deposit.rs`.
Future<Instruction> depositInstruction({
  required Address tree,
  required Address depositor,
  required List<AssetDeposit> deposits,
}) async {
  final layout = _layout(deposits);
  final assets = <DepositAssetKind>[
    if (layout.hasSol) const SolAssetKind(),
  ];
  final accounts = <AccountMeta>[
    AccountMeta(address: tree, role: AccountRole.writable),
    AccountMeta(address: depositor, role: AccountRole.writableSigner),
    const AccountMeta(
      address: shieldedPoolProgramId,
      role: AccountRole.readonly,
    ),
  ];
  if (layout.hasSol) {
    accounts
      ..add(
        const AccountMeta(
          address: systemProgramAddress,
          role: AccountRole.readonly,
        ),
      )
      ..add(
        const AccountMeta(
          address: solInterfaceAddress,
          role: AccountRole.writable,
        ),
      );
  }
  for (final group in layout.splGroups) {
    final derived = await splInterfacePda(group.asset.mint);
    assets.add(SplAssetKind(derived.bump));
    accounts
      ..add(
        AccountMeta(
          address: group.asset.tokenProgram,
          role: AccountRole.readonly,
        ),
      )
      ..add(AccountMeta(address: group.asset.mint, role: AccountRole.readonly))
      ..add(
        AccountMeta(
          address: group.asset.sourceTokenAccount,
          role: AccountRole.writable,
        ),
      )
      ..add(AccountMeta(address: derived.address, role: AccountRole.writable));
  }
  final data = encodeDepositInstructionData(
    DepositInstructionData(
      assets: assets,
      deposits: [
        for (final deposit in deposits)
          DepositEntry(
            assetIndex: layout.indexOf(deposit.asset),
            viewTag: deposit.viewTag,
            recipientOwnerHash: deposit.recipientOwnerHash,
            amount: deposit.amount,
            memo: deposit.memo,
          ),
      ],
    ),
  );
  return Instruction(
    programAddress: shieldedPoolProgramId,
    accounts: accounts,
    data: Uint8List.fromList([depositInstructionTag, ...data]),
  );
}
