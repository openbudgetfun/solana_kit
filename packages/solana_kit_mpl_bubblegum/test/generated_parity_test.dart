import 'package:solana_kit_mpl_bubblegum/solana_kit_mpl_bubblegum.dart';
import 'package:test/test.dart';

void main() {
  group('Bubblegum errors', () {
    test('exposes upstream collection seller-fee errors', () {
      expect(MplBubblegumError.collectionMustHaveRoyaltiesPlugin, 0x17a9);
      expect(
        MplBubblegumError.inheritedSellerFeeCannotHaveLeafCreators,
        0x17aa,
      );
      expect(
        MplBubblegumError.cannotRemoveFromCollectionWithInheritedSellerFee,
        0x17ab,
      );
    });

    test('maps new upstream collection seller-fee error messages', () {
      expect(
        getMplBubblegumErrorMessage(
          MplBubblegumError.collectionMustHaveRoyaltiesPlugin,
        ),
        'Core collections must have the Royalties plugin to inherit seller fee basis points',
      );
      expect(
        getMplBubblegumErrorMessage(
          MplBubblegumError.inheritedSellerFeeCannotHaveLeafCreators,
        ),
        'Inherited seller fee basis points cannot be used with leaf-level creators',
      );
      expect(
        getMplBubblegumErrorMessage(
          MplBubblegumError.cannotRemoveFromCollectionWithInheritedSellerFee,
        ),
        'Cannot remove from collection while seller fee basis points are inherited',
      );
    });

    test('recognizes the full contiguous upstream error range', () {
      expect(isMplBubblegumError(0x17a8), isTrue);
      expect(isMplBubblegumError(0x17a9), isTrue);
      expect(isMplBubblegumError(0x17aa), isTrue);
      expect(isMplBubblegumError(0x17ab), isTrue);
      expect(isMplBubblegumError(0x17ac), isFalse);
      expect(getMplBubblegumErrorMessage(0x17ac), isNull);
    });
  });

  group('Bubblegum instruction discriminators', () {
    final expected = <String, List<int>>{
      'burn': BurnInstructionDiscriminator,
      'burn_v2': BurnV2InstructionDiscriminator,
      'cancel_redeem': CancelRedeemInstructionDiscriminator,
      'close_tree_v2': CloseTreeV2InstructionDiscriminator,
      'collect_v2': CollectV2InstructionDiscriminator,
      'compress': CompressInstructionDiscriminator,
      'create_tree': CreateTreeInstructionDiscriminator,
      'create_tree_v2': CreateTreeV2InstructionDiscriminator,
      'decompress_v1': decompressV1InstructionDiscriminator,
      'delegate': DelegateInstructionDiscriminator,
      'delegate_and_freeze_v2': DelegateAndFreezeV2InstructionDiscriminator,
      'delegate_v2': DelegateV2InstructionDiscriminator,
      'freeze_v2': FreezeV2InstructionDiscriminator,
      'mint_to_collection_v1': mintToCollectionV1InstructionDiscriminator,
      'mint_v1': MintV1InstructionDiscriminator,
      'mint_v2': MintV2InstructionDiscriminator,
      'redeem': RedeemInstructionDiscriminator,
      'set_and_verify_collection':
          setAndVerifyCollectionInstructionDiscriminator,
      'set_collection_v2': SetCollectionV2InstructionDiscriminator,
      'set_decompressable_state':
          SetDecompressableStateInstructionDiscriminator,
      'set_decompressible_state':
          SetDecompressibleStateInstructionDiscriminator,
      'set_non_transferable_v2': SetNonTransferableV2InstructionDiscriminator,
      'set_tree_delegate': SetTreeDelegateInstructionDiscriminator,
      'thaw_and_revoke_v2': ThawAndRevokeV2InstructionDiscriminator,
      'thaw_v2': ThawV2InstructionDiscriminator,
      'transfer': TransferInstructionDiscriminator,
      'transfer_v2': TransferV2InstructionDiscriminator,
      'unverify_collection': unverifyCollectionInstructionDiscriminator,
      'unverify_creator': unverifyCreatorInstructionDiscriminator,
      'unverify_creator_v2': UnverifyCreatorV2InstructionDiscriminator,
      'update_asset_data_v2': UpdateAssetDataV2InstructionDiscriminator,
      'update_metadata': updateMetadataInstructionDiscriminator,
      'update_metadata_v2': UpdateMetadataV2InstructionDiscriminator,
      'verify_collection': verifyCollectionInstructionDiscriminator,
      'verify_creator': verifyCreatorInstructionDiscriminator,
      'verify_creator_v2': VerifyCreatorV2InstructionDiscriminator,
    };

    const upstream = <String, List<int>>{
      'burn': [116, 110, 29, 56, 107, 219, 42, 93],
      'burn_v2': [115, 210, 34, 240, 232, 143, 183, 16],
      'cancel_redeem': [111, 76, 232, 50, 39, 175, 48, 242],
      'close_tree_v2': [45, 172, 6, 94, 28, 90, 157, 70],
      'collect_v2': [21, 11, 159, 47, 4, 195, 106, 56],
      'compress': [82, 193, 176, 117, 176, 21, 115, 253],
      'create_tree': [165, 83, 136, 142, 89, 202, 47, 220],
      'create_tree_v2': [55, 99, 95, 215, 142, 203, 227, 205],
      'decompress_v1': [54, 85, 76, 70, 228, 250, 164, 81],
      'delegate': [90, 147, 75, 178, 85, 88, 4, 137],
      'delegate_and_freeze_v2': [17, 229, 35, 218, 190, 241, 250, 123],
      'delegate_v2': [95, 87, 125, 140, 181, 131, 128, 227],
      'freeze_v2': [200, 151, 244, 102, 16, 195, 255, 3],
      'mint_to_collection_v1': [153, 18, 178, 47, 197, 158, 86, 15],
      'mint_v1': [145, 98, 192, 118, 184, 147, 118, 104],
      'mint_v2': [120, 121, 23, 146, 173, 110, 199, 205],
      'redeem': [184, 12, 86, 149, 70, 196, 97, 225],
      'set_and_verify_collection': [235, 242, 121, 216, 158, 234, 180, 234],
      'set_collection_v2': [229, 35, 61, 91, 15, 14, 99, 160],
      'set_decompressable_state': [18, 135, 238, 168, 246, 195, 61, 115],
      'set_decompressible_state': [82, 104, 152, 6, 149, 111, 100, 13],
      'set_non_transferable_v2': [181, 141, 206, 58, 242, 199, 152, 168],
      'set_tree_delegate': [253, 118, 66, 37, 190, 49, 154, 102],
      'thaw_and_revoke_v2': [86, 214, 190, 37, 167, 4, 28, 116],
      'thaw_v2': [96, 133, 101, 93, 82, 220, 146, 191],
      'transfer': [163, 52, 200, 231, 140, 3, 69, 186],
      'transfer_v2': [119, 40, 6, 235, 234, 221, 248, 49],
      'unverify_collection': [250, 251, 42, 106, 41, 137, 186, 168],
      'unverify_creator': [107, 178, 57, 39, 105, 115, 112, 152],
      'unverify_creator_v2': [174, 112, 29, 142, 230, 100, 239, 7],
      'update_asset_data_v2': [59, 56, 111, 43, 95, 14, 11, 61],
      'update_metadata': [170, 182, 43, 239, 97, 78, 225, 186],
      'update_metadata_v2': [43, 103, 89, 42, 121, 242, 62, 72],
      'verify_collection': [56, 113, 101, 253, 79, 55, 122, 169],
      'verify_creator': [52, 17, 96, 132, 71, 4, 85, 194],
      'verify_creator_v2': [85, 138, 140, 42, 22, 241, 118, 102],
    };

    test('match Anchor 8-byte discriminators', () {
      expect(expected, upstream);
    });

    test('encoders include the 8-byte discriminator prefix', () {
      final data = BurnInstructionData(
        root: List<int>.filled(32, 1),
        dataHash: List<int>.filled(32, 2),
        creatorHash: List<int>.filled(32, 3),
        nonce: BigInt.zero,
        index: 0,
      );

      expect(
        getBurnInstructionDataEncoder().encode(data).take(8).toList(),
        BurnInstructionDiscriminator,
      );
    });
  });
}
