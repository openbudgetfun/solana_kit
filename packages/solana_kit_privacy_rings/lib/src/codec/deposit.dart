import 'dart:typed_data';

import 'package:solana_kit_privacy_rings/src/bytes.dart';
import 'package:solana_kit_privacy_rings/src/exception.dart';

/// Settlement group in a deposit instruction.
///
/// Wire layout: `DepositAssetKind` in
/// `program-libs/interface/src/instruction/instruction_data/deposit.rs`,
/// mirrored by `writeDepositData` in
/// `sdk-libs/ts/src/interface/codecs/index.ts`.
sealed class DepositAssetKind {
  const DepositAssetKind();
}

/// Native SOL settlement group. Tag `0`.
class SolAssetKind extends DepositAssetKind {
  /// Creates a SOL settlement group.
  const SolAssetKind();
}

/// SPL or Token-2022 settlement group. Tag `1`, then the interface bump.
class SplAssetKind extends DepositAssetKind {
  /// Creates an SPL settlement group with [splInterfaceBump].
  const SplAssetKind(this.splInterfaceBump);

  /// Canonical bump of the per-mint SPL interface PDA.
  final int splInterfaceBump;
}

/// One deposit output.
///
/// [recipientOwnerHash] is the recipient `owner_hash`. This package does not
/// compute that Poseidon hash; pass the value from the recipient's shielded
/// address.
class DepositEntry {
  /// Creates a deposit output.
  DepositEntry({
    required this.assetIndex,
    required List<int> viewTag,
    required List<int> recipientOwnerHash,
    required this.amount,
    List<int>? memo,
  }) : viewTag = copyBytes(viewTag, 32, 'viewTag'),
       recipientOwnerHash = copyBytes(
         recipientOwnerHash,
         32,
         'recipientOwnerHash',
       ),
       memo = memo == null ? null : Uint8List.fromList(memo) {
    if (assetIndex < 0 || assetIndex > 0xff) {
      throw PrivacyRingsException(
        'assetIndex is outside 0..255',
        code: 'integer_range',
      );
    }
    if (amount.isNegative || amount.bitLength > 64) {
      throw PrivacyRingsException(
        'amount is outside 0..2^64-1',
        code: 'integer_range',
      );
    }
    if (this.memo != null && this.memo!.length > 0xffff) {
      throw PrivacyRingsException(
        'memo is longer than 65535 bytes',
        code: 'invalid_length',
      );
    }
  }

  /// Index into the instruction's asset list.
  final int assetIndex;

  /// Indexer view tag. For a confidential ring this is the recipient's
  /// Solana public key.
  final Uint8List viewTag;

  /// Recipient `owner_hash`.
  final Uint8List recipientOwnerHash;

  /// Amount of the selected asset, in the asset's base units.
  final BigInt amount;

  /// Optional cleartext memo. It is not committed into a hash.
  final Uint8List? memo;
}

/// `DepositIxData` without the leading instruction tag.
class DepositInstructionData {
  /// Creates deposit instruction data.
  const DepositInstructionData({
    required this.assets,
    required this.deposits,
  });

  /// Settlement groups in account order.
  final List<DepositAssetKind> assets;

  /// Outputs funded by [assets].
  final List<DepositEntry> deposits;
}

/// Encodes [value] the way `encodeDepositInstructionData` does.
Uint8List encodeDepositInstructionData(DepositInstructionData value) {
  final writer = ByteWriter()..u8(value.assets.length, 'assets.length');
  for (final asset in value.assets) {
    switch (asset) {
      case SolAssetKind():
        writer.u8(0, 'asset.kind');
      case SplAssetKind(:final splInterfaceBump):
        writer
          ..u8(1, 'asset.kind')
          ..u8(splInterfaceBump, 'asset.splInterfaceBump');
    }
  }
  writer.u8(value.deposits.length, 'deposits.length');
  for (final deposit in value.deposits) {
    writer
      ..u8(deposit.assetIndex, 'deposit.assetIndex')
      ..bytes(deposit.viewTag, length: 32, name: 'deposit.viewTag')
      ..bytes(
        deposit.recipientOwnerHash,
        length: 32,
        name: 'deposit.recipientOwnerHash',
      )
      ..u64(deposit.amount, 'deposit.amount')
      ..option(deposit.memo, (output, memo) {
        output
          ..u16(memo.length, 'deposit.memo.length')
          ..bytes(memo);
      });
  }
  return writer.finish();
}

/// Decodes bytes produced by [encodeDepositInstructionData].
DepositInstructionData decodeDepositInstructionData(Uint8List bytes) {
  final reader = ByteReader(bytes);
  final assets = List<DepositAssetKind>.generate(reader.u8('assets.length'), (
    _,
  ) {
    final kind = reader.u8('asset.kind');
    if (kind == 0) return const SolAssetKind();
    if (kind == 1) return SplAssetKind(reader.u8('splInterfaceBump'));
    throw PrivacyRingsException(
      'unknown deposit asset kind $kind',
      code: 'invalid_discriminator',
    );
  });
  final deposits = List<DepositEntry>.generate(
    reader.u8('deposits.length'),
    (_) {
      final assetIndex = reader.u8('assetIndex');
      if (assetIndex >= assets.length) {
        throw PrivacyRingsException(
          'deposit assetIndex $assetIndex is out of range',
          code: 'invalid_asset_index',
        );
      }
      return DepositEntry(
        assetIndex: assetIndex,
        viewTag: reader.bytes(32, 'viewTag'),
        recipientOwnerHash: reader.bytes(32, 'recipientOwnerHash'),
        amount: reader.u64('amount'),
        memo: reader.option(
          () => reader.bytes(reader.u16('memo.length'), 'memo'),
        ),
      );
    },
  );
  reader.done();
  return DepositInstructionData(assets: assets, deposits: deposits);
}
