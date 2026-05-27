// Auto-generated. Do not edit.
// ignore_for_file: type=lint

export 'package:solana_kit_mpl_bubblegum/src/program_address.dart'
    show mplBubblegumProgramAddress, mplBubblegumProgramAddressObject;

/// MPL Bubblegum instruction discriminators (Anchor instruction indices).
enum MplBubblegumInstruction {
  burn(0),
  burnV2(1),
  cancelRedeem(2),
  closeTreeV2(3),
  collectV2(4),
  compress(5),
  createTree(6),
  createTreeV2(7),
  decompressV1(8),
  delegate(9),
  delegateAndFreezeV2(10),
  delegateV2(11),
  freezeV2(12),
  mintToCollectionV1(13),
  mintV1(14),
  mintV2(15),
  redeem(16),
  setAndVerifyCollection(17),
  setCollectionV2(18),
  setDecompressableState(19),
  setDecompressibleState(20),
  setNonTransferableV2(21),
  setTreeDelegate(22),
  thawAndRevokeV2(23),
  thawV2(24),
  transfer(25),
  transferV2(26),
  unverifyCollection(27),
  unverifyCreator(28),
  unverifyCreatorV2(29),
  updateAssetDataV2(30),
  updateMetadata(31),
  updateMetadataV2(32),
  verifyCollection(33),
  verifyCreator(34),
  verifyCreatorV2(35);

  const MplBubblegumInstruction(this.discriminator);

  /// The Anchor instruction discriminator (8-bit index).
  final int discriminator;
}

/// MPL Bubblegum account discriminators.
enum MplBubblegumAccount {
  treeConfig(0),
  voucher(1);

  const MplBubblegumAccount(this.discriminator);

  /// The Anchor account discriminator.
  final int discriminator;
}