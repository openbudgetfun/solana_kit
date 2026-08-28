// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

import '../instructions/instructions.dart';

/// The address of the MplTokenMetadata program.
const mplTokenMetadataProgramAddress = Address(
  'metaqbxxUerdq28cj1RbAWkYQm3ybzjb6a8bt518x1s',
);

/// Known accounts for the MplTokenMetadata program.
enum MplTokenMetadataAccount {
  collectionAuthorityRecord,
  metadataDelegateRecord,
  holderDelegateRecord,
  edition,
  editionMarker,
  editionMarkerV2,
  tokenOwnedEscrow,
  masterEditionV2,
  masterEditionV1,
  metadata,
  tokenRecord,
  reservationListV2,
  reservationListV1,
  useAuthorityRecord,
}

/// Known instructions for the MplTokenMetadata program.
enum MplTokenMetadataInstruction {
  createMetadataAccount,
  updateMetadataAccount,
  deprecatedCreateMasterEdition,
  deprecatedMintNewEditionFromMasterEditionViaPrintingToken,
  updatePrimarySaleHappenedViaToken,
  deprecatedSetReservationList,
  deprecatedCreateReservationList,
  signMetadata,
  deprecatedMintPrintingTokensViaToken,
  deprecatedMintPrintingTokens,
  createMasterEdition,
  mintNewEditionFromMasterEditionViaToken,
  convertMasterEditionV1ToV2,
  mintNewEditionFromMasterEditionViaVaultProxy,
  puffMetadata,
  updateMetadataAccountV2,
  createMetadataAccountV2,
  createMasterEditionV3,
  verifyCollection,
  utilize,
  approveUseAuthority,
  revokeUseAuthority,
  unverifyCollection,
  approveCollectionAuthority,
  revokeCollectionAuthority,
  setAndVerifyCollection,
  freezeDelegatedAccount,
  thawDelegatedAccount,
  removeCreatorVerification,
  burnNft,
  verifySizedCollectionItem,
  unverifySizedCollectionItem,
  setAndVerifySizedCollectionItem,
  createMetadataAccountV3,
  setCollectionSize,
  setTokenStandard,
  bubblegumSetCollectionSize,
  burnEditionNft,
  createEscrowAccount,
  closeEscrowAccount,
  transferOutOfEscrow,
  burn,
  create,
  mint,
  delegate,
  revoke,
  lock,
  unlock,
  migrate,
  transfer,
  update,
  use,
  verify,
  unverify,
  collect,
  print,
  resize,
  closeAccounts,
}

/// Identifies the type of a MplTokenMetadata instruction.
MplTokenMetadataInstruction identifyMplTokenMetadataInstruction(
  Uint8List data,
) {
  if (containsBytes(data, getU8Encoder().encode(0), 0)) {
    return MplTokenMetadataInstruction.createMetadataAccount;
  }
  if (containsBytes(data, getU8Encoder().encode(1), 0)) {
    return MplTokenMetadataInstruction.updateMetadataAccount;
  }
  if (containsBytes(data, getU8Encoder().encode(2), 0)) {
    return MplTokenMetadataInstruction.deprecatedCreateMasterEdition;
  }
  if (containsBytes(data, getU8Encoder().encode(3), 0)) {
    return MplTokenMetadataInstruction
        .deprecatedMintNewEditionFromMasterEditionViaPrintingToken;
  }
  if (containsBytes(data, getU8Encoder().encode(4), 0)) {
    return MplTokenMetadataInstruction.updatePrimarySaleHappenedViaToken;
  }
  if (containsBytes(data, getU8Encoder().encode(5), 0)) {
    return MplTokenMetadataInstruction.deprecatedSetReservationList;
  }
  if (containsBytes(data, getU8Encoder().encode(6), 0)) {
    return MplTokenMetadataInstruction.deprecatedCreateReservationList;
  }
  if (containsBytes(data, getU8Encoder().encode(7), 0)) {
    return MplTokenMetadataInstruction.signMetadata;
  }
  if (containsBytes(data, getU8Encoder().encode(8), 0)) {
    return MplTokenMetadataInstruction.deprecatedMintPrintingTokensViaToken;
  }
  if (containsBytes(data, getU8Encoder().encode(9), 0)) {
    return MplTokenMetadataInstruction.deprecatedMintPrintingTokens;
  }
  if (containsBytes(data, getU8Encoder().encode(10), 0)) {
    return MplTokenMetadataInstruction.createMasterEdition;
  }
  if (containsBytes(data, getU8Encoder().encode(11), 0)) {
    return MplTokenMetadataInstruction.mintNewEditionFromMasterEditionViaToken;
  }
  if (containsBytes(data, getU8Encoder().encode(12), 0)) {
    return MplTokenMetadataInstruction.convertMasterEditionV1ToV2;
  }
  if (containsBytes(data, getU8Encoder().encode(13), 0)) {
    return MplTokenMetadataInstruction
        .mintNewEditionFromMasterEditionViaVaultProxy;
  }
  if (containsBytes(data, getU8Encoder().encode(14), 0)) {
    return MplTokenMetadataInstruction.puffMetadata;
  }
  if (containsBytes(data, getU8Encoder().encode(15), 0)) {
    return MplTokenMetadataInstruction.updateMetadataAccountV2;
  }
  if (containsBytes(data, getU8Encoder().encode(16), 0)) {
    return MplTokenMetadataInstruction.createMetadataAccountV2;
  }
  if (containsBytes(data, getU8Encoder().encode(17), 0)) {
    return MplTokenMetadataInstruction.createMasterEditionV3;
  }
  if (containsBytes(data, getU8Encoder().encode(18), 0)) {
    return MplTokenMetadataInstruction.verifyCollection;
  }
  if (containsBytes(data, getU8Encoder().encode(19), 0)) {
    return MplTokenMetadataInstruction.utilize;
  }
  if (containsBytes(data, getU8Encoder().encode(20), 0)) {
    return MplTokenMetadataInstruction.approveUseAuthority;
  }
  if (containsBytes(data, getU8Encoder().encode(21), 0)) {
    return MplTokenMetadataInstruction.revokeUseAuthority;
  }
  if (containsBytes(data, getU8Encoder().encode(22), 0)) {
    return MplTokenMetadataInstruction.unverifyCollection;
  }
  if (containsBytes(data, getU8Encoder().encode(23), 0)) {
    return MplTokenMetadataInstruction.approveCollectionAuthority;
  }
  if (containsBytes(data, getU8Encoder().encode(24), 0)) {
    return MplTokenMetadataInstruction.revokeCollectionAuthority;
  }
  if (containsBytes(data, getU8Encoder().encode(25), 0)) {
    return MplTokenMetadataInstruction.setAndVerifyCollection;
  }
  if (containsBytes(data, getU8Encoder().encode(26), 0)) {
    return MplTokenMetadataInstruction.freezeDelegatedAccount;
  }
  if (containsBytes(data, getU8Encoder().encode(27), 0)) {
    return MplTokenMetadataInstruction.thawDelegatedAccount;
  }
  if (containsBytes(data, getU8Encoder().encode(28), 0)) {
    return MplTokenMetadataInstruction.removeCreatorVerification;
  }
  if (containsBytes(data, getU8Encoder().encode(29), 0)) {
    return MplTokenMetadataInstruction.burnNft;
  }
  if (containsBytes(data, getU8Encoder().encode(30), 0)) {
    return MplTokenMetadataInstruction.verifySizedCollectionItem;
  }
  if (containsBytes(data, getU8Encoder().encode(31), 0)) {
    return MplTokenMetadataInstruction.unverifySizedCollectionItem;
  }
  if (containsBytes(data, getU8Encoder().encode(32), 0)) {
    return MplTokenMetadataInstruction.setAndVerifySizedCollectionItem;
  }
  if (containsBytes(data, getU8Encoder().encode(33), 0)) {
    return MplTokenMetadataInstruction.createMetadataAccountV3;
  }
  if (containsBytes(data, getU8Encoder().encode(34), 0)) {
    return MplTokenMetadataInstruction.setCollectionSize;
  }
  if (containsBytes(data, getU8Encoder().encode(35), 0)) {
    return MplTokenMetadataInstruction.setTokenStandard;
  }
  if (containsBytes(data, getU8Encoder().encode(36), 0)) {
    return MplTokenMetadataInstruction.bubblegumSetCollectionSize;
  }
  if (containsBytes(data, getU8Encoder().encode(37), 0)) {
    return MplTokenMetadataInstruction.burnEditionNft;
  }
  if (containsBytes(data, getU8Encoder().encode(38), 0)) {
    return MplTokenMetadataInstruction.createEscrowAccount;
  }
  if (containsBytes(data, getU8Encoder().encode(39), 0)) {
    return MplTokenMetadataInstruction.closeEscrowAccount;
  }
  if (containsBytes(data, getU8Encoder().encode(40), 0)) {
    return MplTokenMetadataInstruction.transferOutOfEscrow;
  }
  if (containsBytes(data, getU8Encoder().encode(41), 0)) {
    return MplTokenMetadataInstruction.burn;
  }
  if (containsBytes(data, getU8Encoder().encode(42), 0)) {
    return MplTokenMetadataInstruction.create;
  }
  if (containsBytes(data, getU8Encoder().encode(43), 0)) {
    return MplTokenMetadataInstruction.mint;
  }
  if (containsBytes(data, getU8Encoder().encode(44), 0)) {
    return MplTokenMetadataInstruction.delegate;
  }
  if (containsBytes(data, getU8Encoder().encode(45), 0)) {
    return MplTokenMetadataInstruction.revoke;
  }
  if (containsBytes(data, getU8Encoder().encode(46), 0)) {
    return MplTokenMetadataInstruction.lock;
  }
  if (containsBytes(data, getU8Encoder().encode(47), 0)) {
    return MplTokenMetadataInstruction.unlock;
  }
  if (containsBytes(data, getU8Encoder().encode(48), 0)) {
    return MplTokenMetadataInstruction.migrate;
  }
  if (containsBytes(data, getU8Encoder().encode(49), 0)) {
    return MplTokenMetadataInstruction.transfer;
  }
  if (containsBytes(data, getU8Encoder().encode(50), 0)) {
    return MplTokenMetadataInstruction.update;
  }
  if (containsBytes(data, getU8Encoder().encode(51), 0)) {
    return MplTokenMetadataInstruction.use;
  }
  if (containsBytes(data, getU8Encoder().encode(52), 0)) {
    return MplTokenMetadataInstruction.verify;
  }
  if (containsBytes(data, getU8Encoder().encode(53), 0)) {
    return MplTokenMetadataInstruction.unverify;
  }
  if (containsBytes(data, getU8Encoder().encode(54), 0)) {
    return MplTokenMetadataInstruction.collect;
  }
  if (containsBytes(data, getU8Encoder().encode(55), 0)) {
    return MplTokenMetadataInstruction.print;
  }
  if (containsBytes(data, getU8Encoder().encode(56), 0)) {
    return MplTokenMetadataInstruction.resize;
  }
  if (containsBytes(data, getU8Encoder().encode(57), 0)) {
    return MplTokenMetadataInstruction.closeAccounts;
  }

  throw SolanaError(
    SolanaErrorCode.programClientsFailedToIdentifyInstruction,
    {
      'instructionData': data,
      'programName': 'mplTokenMetadata',
    },
  );
}

/// A parsed instruction from the MplTokenMetadata program.
sealed class ParsedMplTokenMetadataInstruction {
  const ParsedMplTokenMetadataInstruction(this.instructionType);

  final MplTokenMetadataInstruction instructionType;
}

/// A parsed CreateMetadataAccount instruction.
final class ParsedCreateMetadataAccount
    extends ParsedMplTokenMetadataInstruction {
  const ParsedCreateMetadataAccount({required this.data})
    : super(MplTokenMetadataInstruction.createMetadataAccount);

  final CreateMetadataAccountInstructionData data;
}

/// A parsed UpdateMetadataAccount instruction.
final class ParsedUpdateMetadataAccount
    extends ParsedMplTokenMetadataInstruction {
  const ParsedUpdateMetadataAccount({required this.data})
    : super(MplTokenMetadataInstruction.updateMetadataAccount);

  final UpdateMetadataAccountInstructionData data;
}

/// A parsed DeprecatedCreateMasterEdition instruction.
final class ParsedDeprecatedCreateMasterEdition
    extends ParsedMplTokenMetadataInstruction {
  const ParsedDeprecatedCreateMasterEdition({required this.data})
    : super(MplTokenMetadataInstruction.deprecatedCreateMasterEdition);

  final DeprecatedCreateMasterEditionInstructionData data;
}

/// A parsed DeprecatedMintNewEditionFromMasterEditionViaPrintingToken instruction.
final class ParsedDeprecatedMintNewEditionFromMasterEditionViaPrintingToken
    extends ParsedMplTokenMetadataInstruction {
  const ParsedDeprecatedMintNewEditionFromMasterEditionViaPrintingToken({
    required this.data,
  }) : super(
         MplTokenMetadataInstruction
             .deprecatedMintNewEditionFromMasterEditionViaPrintingToken,
       );

  final DeprecatedMintNewEditionFromMasterEditionViaPrintingTokenInstructionData
  data;
}

/// A parsed UpdatePrimarySaleHappenedViaToken instruction.
final class ParsedUpdatePrimarySaleHappenedViaToken
    extends ParsedMplTokenMetadataInstruction {
  const ParsedUpdatePrimarySaleHappenedViaToken({required this.data})
    : super(MplTokenMetadataInstruction.updatePrimarySaleHappenedViaToken);

  final UpdatePrimarySaleHappenedViaTokenInstructionData data;
}

/// A parsed DeprecatedSetReservationList instruction.
final class ParsedDeprecatedSetReservationList
    extends ParsedMplTokenMetadataInstruction {
  const ParsedDeprecatedSetReservationList({required this.data})
    : super(MplTokenMetadataInstruction.deprecatedSetReservationList);

  final DeprecatedSetReservationListInstructionData data;
}

/// A parsed DeprecatedCreateReservationList instruction.
final class ParsedDeprecatedCreateReservationList
    extends ParsedMplTokenMetadataInstruction {
  const ParsedDeprecatedCreateReservationList({required this.data})
    : super(MplTokenMetadataInstruction.deprecatedCreateReservationList);

  final DeprecatedCreateReservationListInstructionData data;
}

/// A parsed SignMetadata instruction.
final class ParsedSignMetadata extends ParsedMplTokenMetadataInstruction {
  const ParsedSignMetadata({required this.data})
    : super(MplTokenMetadataInstruction.signMetadata);

  final SignMetadataInstructionData data;
}

/// A parsed DeprecatedMintPrintingTokensViaToken instruction.
final class ParsedDeprecatedMintPrintingTokensViaToken
    extends ParsedMplTokenMetadataInstruction {
  const ParsedDeprecatedMintPrintingTokensViaToken({required this.data})
    : super(MplTokenMetadataInstruction.deprecatedMintPrintingTokensViaToken);

  final DeprecatedMintPrintingTokensViaTokenInstructionData data;
}

/// A parsed DeprecatedMintPrintingTokens instruction.
final class ParsedDeprecatedMintPrintingTokens
    extends ParsedMplTokenMetadataInstruction {
  const ParsedDeprecatedMintPrintingTokens({required this.data})
    : super(MplTokenMetadataInstruction.deprecatedMintPrintingTokens);

  final DeprecatedMintPrintingTokensInstructionData data;
}

/// A parsed CreateMasterEdition instruction.
final class ParsedCreateMasterEdition
    extends ParsedMplTokenMetadataInstruction {
  const ParsedCreateMasterEdition({required this.data})
    : super(MplTokenMetadataInstruction.createMasterEdition);

  final CreateMasterEditionInstructionData data;
}

/// A parsed MintNewEditionFromMasterEditionViaToken instruction.
final class ParsedMintNewEditionFromMasterEditionViaToken
    extends ParsedMplTokenMetadataInstruction {
  const ParsedMintNewEditionFromMasterEditionViaToken({required this.data})
    : super(
        MplTokenMetadataInstruction.mintNewEditionFromMasterEditionViaToken,
      );

  final MintNewEditionFromMasterEditionViaTokenInstructionData data;
}

/// A parsed ConvertMasterEditionV1ToV2 instruction.
final class ParsedConvertMasterEditionV1ToV2
    extends ParsedMplTokenMetadataInstruction {
  const ParsedConvertMasterEditionV1ToV2({required this.data})
    : super(MplTokenMetadataInstruction.convertMasterEditionV1ToV2);

  final ConvertMasterEditionV1ToV2InstructionData data;
}

/// A parsed MintNewEditionFromMasterEditionViaVaultProxy instruction.
final class ParsedMintNewEditionFromMasterEditionViaVaultProxy
    extends ParsedMplTokenMetadataInstruction {
  const ParsedMintNewEditionFromMasterEditionViaVaultProxy({required this.data})
    : super(
        MplTokenMetadataInstruction
            .mintNewEditionFromMasterEditionViaVaultProxy,
      );

  final MintNewEditionFromMasterEditionViaVaultProxyInstructionData data;
}

/// A parsed PuffMetadata instruction.
final class ParsedPuffMetadata extends ParsedMplTokenMetadataInstruction {
  const ParsedPuffMetadata({required this.data})
    : super(MplTokenMetadataInstruction.puffMetadata);

  final PuffMetadataInstructionData data;
}

/// A parsed UpdateMetadataAccountV2 instruction.
final class ParsedUpdateMetadataAccountV2
    extends ParsedMplTokenMetadataInstruction {
  const ParsedUpdateMetadataAccountV2({required this.data})
    : super(MplTokenMetadataInstruction.updateMetadataAccountV2);

  final UpdateMetadataAccountV2InstructionData data;
}

/// A parsed CreateMetadataAccountV2 instruction.
final class ParsedCreateMetadataAccountV2
    extends ParsedMplTokenMetadataInstruction {
  const ParsedCreateMetadataAccountV2({required this.data})
    : super(MplTokenMetadataInstruction.createMetadataAccountV2);

  final CreateMetadataAccountV2InstructionData data;
}

/// A parsed CreateMasterEditionV3 instruction.
final class ParsedCreateMasterEditionV3
    extends ParsedMplTokenMetadataInstruction {
  const ParsedCreateMasterEditionV3({required this.data})
    : super(MplTokenMetadataInstruction.createMasterEditionV3);

  final CreateMasterEditionV3InstructionData data;
}

/// A parsed VerifyCollection instruction.
final class ParsedVerifyCollection extends ParsedMplTokenMetadataInstruction {
  const ParsedVerifyCollection({required this.data})
    : super(MplTokenMetadataInstruction.verifyCollection);

  final VerifyCollectionInstructionData data;
}

/// A parsed Utilize instruction.
final class ParsedUtilize extends ParsedMplTokenMetadataInstruction {
  const ParsedUtilize({required this.data})
    : super(MplTokenMetadataInstruction.utilize);

  final UtilizeInstructionData data;
}

/// A parsed ApproveUseAuthority instruction.
final class ParsedApproveUseAuthority
    extends ParsedMplTokenMetadataInstruction {
  const ParsedApproveUseAuthority({required this.data})
    : super(MplTokenMetadataInstruction.approveUseAuthority);

  final ApproveUseAuthorityInstructionData data;
}

/// A parsed RevokeUseAuthority instruction.
final class ParsedRevokeUseAuthority extends ParsedMplTokenMetadataInstruction {
  const ParsedRevokeUseAuthority({required this.data})
    : super(MplTokenMetadataInstruction.revokeUseAuthority);

  final RevokeUseAuthorityInstructionData data;
}

/// A parsed UnverifyCollection instruction.
final class ParsedUnverifyCollection extends ParsedMplTokenMetadataInstruction {
  const ParsedUnverifyCollection({required this.data})
    : super(MplTokenMetadataInstruction.unverifyCollection);

  final UnverifyCollectionInstructionData data;
}

/// A parsed ApproveCollectionAuthority instruction.
final class ParsedApproveCollectionAuthority
    extends ParsedMplTokenMetadataInstruction {
  const ParsedApproveCollectionAuthority({required this.data})
    : super(MplTokenMetadataInstruction.approveCollectionAuthority);

  final ApproveCollectionAuthorityInstructionData data;
}

/// A parsed RevokeCollectionAuthority instruction.
final class ParsedRevokeCollectionAuthority
    extends ParsedMplTokenMetadataInstruction {
  const ParsedRevokeCollectionAuthority({required this.data})
    : super(MplTokenMetadataInstruction.revokeCollectionAuthority);

  final RevokeCollectionAuthorityInstructionData data;
}

/// A parsed SetAndVerifyCollection instruction.
final class ParsedSetAndVerifyCollection
    extends ParsedMplTokenMetadataInstruction {
  const ParsedSetAndVerifyCollection({required this.data})
    : super(MplTokenMetadataInstruction.setAndVerifyCollection);

  final SetAndVerifyCollectionInstructionData data;
}

/// A parsed FreezeDelegatedAccount instruction.
final class ParsedFreezeDelegatedAccount
    extends ParsedMplTokenMetadataInstruction {
  const ParsedFreezeDelegatedAccount({required this.data})
    : super(MplTokenMetadataInstruction.freezeDelegatedAccount);

  final FreezeDelegatedAccountInstructionData data;
}

/// A parsed ThawDelegatedAccount instruction.
final class ParsedThawDelegatedAccount
    extends ParsedMplTokenMetadataInstruction {
  const ParsedThawDelegatedAccount({required this.data})
    : super(MplTokenMetadataInstruction.thawDelegatedAccount);

  final ThawDelegatedAccountInstructionData data;
}

/// A parsed RemoveCreatorVerification instruction.
final class ParsedRemoveCreatorVerification
    extends ParsedMplTokenMetadataInstruction {
  const ParsedRemoveCreatorVerification({required this.data})
    : super(MplTokenMetadataInstruction.removeCreatorVerification);

  final RemoveCreatorVerificationInstructionData data;
}

/// A parsed BurnNft instruction.
final class ParsedBurnNft extends ParsedMplTokenMetadataInstruction {
  const ParsedBurnNft({required this.data})
    : super(MplTokenMetadataInstruction.burnNft);

  final BurnNftInstructionData data;
}

/// A parsed VerifySizedCollectionItem instruction.
final class ParsedVerifySizedCollectionItem
    extends ParsedMplTokenMetadataInstruction {
  const ParsedVerifySizedCollectionItem({required this.data})
    : super(MplTokenMetadataInstruction.verifySizedCollectionItem);

  final VerifySizedCollectionItemInstructionData data;
}

/// A parsed UnverifySizedCollectionItem instruction.
final class ParsedUnverifySizedCollectionItem
    extends ParsedMplTokenMetadataInstruction {
  const ParsedUnverifySizedCollectionItem({required this.data})
    : super(MplTokenMetadataInstruction.unverifySizedCollectionItem);

  final UnverifySizedCollectionItemInstructionData data;
}

/// A parsed SetAndVerifySizedCollectionItem instruction.
final class ParsedSetAndVerifySizedCollectionItem
    extends ParsedMplTokenMetadataInstruction {
  const ParsedSetAndVerifySizedCollectionItem({required this.data})
    : super(MplTokenMetadataInstruction.setAndVerifySizedCollectionItem);

  final SetAndVerifySizedCollectionItemInstructionData data;
}

/// A parsed CreateMetadataAccountV3 instruction.
final class ParsedCreateMetadataAccountV3
    extends ParsedMplTokenMetadataInstruction {
  const ParsedCreateMetadataAccountV3({required this.data})
    : super(MplTokenMetadataInstruction.createMetadataAccountV3);

  final CreateMetadataAccountV3InstructionData data;
}

/// A parsed SetCollectionSize instruction.
final class ParsedSetCollectionSize extends ParsedMplTokenMetadataInstruction {
  const ParsedSetCollectionSize({required this.data})
    : super(MplTokenMetadataInstruction.setCollectionSize);

  final SetCollectionSizeInstructionData data;
}

/// A parsed SetTokenStandard instruction.
final class ParsedSetTokenStandard extends ParsedMplTokenMetadataInstruction {
  const ParsedSetTokenStandard({required this.data})
    : super(MplTokenMetadataInstruction.setTokenStandard);

  final SetTokenStandardInstructionData data;
}

/// A parsed BubblegumSetCollectionSize instruction.
final class ParsedBubblegumSetCollectionSize
    extends ParsedMplTokenMetadataInstruction {
  const ParsedBubblegumSetCollectionSize({required this.data})
    : super(MplTokenMetadataInstruction.bubblegumSetCollectionSize);

  final BubblegumSetCollectionSizeInstructionData data;
}

/// A parsed BurnEditionNft instruction.
final class ParsedBurnEditionNft extends ParsedMplTokenMetadataInstruction {
  const ParsedBurnEditionNft({required this.data})
    : super(MplTokenMetadataInstruction.burnEditionNft);

  final BurnEditionNftInstructionData data;
}

/// A parsed CreateEscrowAccount instruction.
final class ParsedCreateEscrowAccount
    extends ParsedMplTokenMetadataInstruction {
  const ParsedCreateEscrowAccount({required this.data})
    : super(MplTokenMetadataInstruction.createEscrowAccount);

  final CreateEscrowAccountInstructionData data;
}

/// A parsed CloseEscrowAccount instruction.
final class ParsedCloseEscrowAccount extends ParsedMplTokenMetadataInstruction {
  const ParsedCloseEscrowAccount({required this.data})
    : super(MplTokenMetadataInstruction.closeEscrowAccount);

  final CloseEscrowAccountInstructionData data;
}

/// A parsed TransferOutOfEscrow instruction.
final class ParsedTransferOutOfEscrow
    extends ParsedMplTokenMetadataInstruction {
  const ParsedTransferOutOfEscrow({required this.data})
    : super(MplTokenMetadataInstruction.transferOutOfEscrow);

  final TransferOutOfEscrowInstructionData data;
}

/// A parsed Burn instruction.
final class ParsedBurn extends ParsedMplTokenMetadataInstruction {
  const ParsedBurn({required this.data})
    : super(MplTokenMetadataInstruction.burn);

  final BurnInstructionData data;
}

/// A parsed Create instruction.
final class ParsedCreate extends ParsedMplTokenMetadataInstruction {
  const ParsedCreate({required this.data})
    : super(MplTokenMetadataInstruction.create);

  final CreateInstructionData data;
}

/// A parsed Mint instruction.
final class ParsedMint extends ParsedMplTokenMetadataInstruction {
  const ParsedMint({required this.data})
    : super(MplTokenMetadataInstruction.mint);

  final MintInstructionData data;
}

/// A parsed Delegate instruction.
final class ParsedDelegate extends ParsedMplTokenMetadataInstruction {
  const ParsedDelegate({required this.data})
    : super(MplTokenMetadataInstruction.delegate);

  final DelegateInstructionData data;
}

/// A parsed Revoke instruction.
final class ParsedRevoke extends ParsedMplTokenMetadataInstruction {
  const ParsedRevoke({required this.data})
    : super(MplTokenMetadataInstruction.revoke);

  final RevokeInstructionData data;
}

/// A parsed Lock instruction.
final class ParsedLock extends ParsedMplTokenMetadataInstruction {
  const ParsedLock({required this.data})
    : super(MplTokenMetadataInstruction.lock);

  final LockInstructionData data;
}

/// A parsed Unlock instruction.
final class ParsedUnlock extends ParsedMplTokenMetadataInstruction {
  const ParsedUnlock({required this.data})
    : super(MplTokenMetadataInstruction.unlock);

  final UnlockInstructionData data;
}

/// A parsed Migrate instruction.
final class ParsedMigrate extends ParsedMplTokenMetadataInstruction {
  const ParsedMigrate({required this.data})
    : super(MplTokenMetadataInstruction.migrate);

  final MigrateInstructionData data;
}

/// A parsed Transfer instruction.
final class ParsedTransfer extends ParsedMplTokenMetadataInstruction {
  const ParsedTransfer({required this.data})
    : super(MplTokenMetadataInstruction.transfer);

  final TransferInstructionData data;
}

/// A parsed Update instruction.
final class ParsedUpdate extends ParsedMplTokenMetadataInstruction {
  const ParsedUpdate({required this.data})
    : super(MplTokenMetadataInstruction.update);

  final UpdateInstructionData data;
}

/// A parsed Use instruction.
final class ParsedUse extends ParsedMplTokenMetadataInstruction {
  const ParsedUse({required this.data})
    : super(MplTokenMetadataInstruction.use);

  final UseInstructionData data;
}

/// A parsed Verify instruction.
final class ParsedVerify extends ParsedMplTokenMetadataInstruction {
  const ParsedVerify({required this.data})
    : super(MplTokenMetadataInstruction.verify);

  final VerifyInstructionData data;
}

/// A parsed Unverify instruction.
final class ParsedUnverify extends ParsedMplTokenMetadataInstruction {
  const ParsedUnverify({required this.data})
    : super(MplTokenMetadataInstruction.unverify);

  final UnverifyInstructionData data;
}

/// A parsed Collect instruction.
final class ParsedCollect extends ParsedMplTokenMetadataInstruction {
  const ParsedCollect({required this.data})
    : super(MplTokenMetadataInstruction.collect);

  final CollectInstructionData data;
}

/// A parsed Print instruction.
final class ParsedPrint extends ParsedMplTokenMetadataInstruction {
  const ParsedPrint({required this.data})
    : super(MplTokenMetadataInstruction.print);

  final PrintInstructionData data;
}

/// A parsed Resize instruction.
final class ParsedResize extends ParsedMplTokenMetadataInstruction {
  const ParsedResize({required this.data})
    : super(MplTokenMetadataInstruction.resize);

  final ResizeInstructionData data;
}

/// A parsed CloseAccounts instruction.
final class ParsedCloseAccounts extends ParsedMplTokenMetadataInstruction {
  const ParsedCloseAccounts({required this.data})
    : super(MplTokenMetadataInstruction.closeAccounts);

  final CloseAccountsInstructionData data;
}

/// Parses a MplTokenMetadata instruction.
ParsedMplTokenMetadataInstruction parseMplTokenMetadataInstruction(
  Instruction instruction,
) {
  return switch (identifyMplTokenMetadataInstruction(
    instruction.data ?? Uint8List(0),
  )) {
    MplTokenMetadataInstruction.createMetadataAccount =>
      ParsedCreateMetadataAccount(
        data: parseCreateMetadataAccountInstruction(instruction),
      ),
    MplTokenMetadataInstruction.updateMetadataAccount =>
      ParsedUpdateMetadataAccount(
        data: parseUpdateMetadataAccountInstruction(instruction),
      ),
    MplTokenMetadataInstruction.deprecatedCreateMasterEdition =>
      ParsedDeprecatedCreateMasterEdition(
        data: parseDeprecatedCreateMasterEditionInstruction(instruction),
      ),
    MplTokenMetadataInstruction
        .deprecatedMintNewEditionFromMasterEditionViaPrintingToken =>
      ParsedDeprecatedMintNewEditionFromMasterEditionViaPrintingToken(
        data:
            parseDeprecatedMintNewEditionFromMasterEditionViaPrintingTokenInstruction(
              instruction,
            ),
      ),
    MplTokenMetadataInstruction.updatePrimarySaleHappenedViaToken =>
      ParsedUpdatePrimarySaleHappenedViaToken(
        data: parseUpdatePrimarySaleHappenedViaTokenInstruction(instruction),
      ),
    MplTokenMetadataInstruction.deprecatedSetReservationList =>
      ParsedDeprecatedSetReservationList(
        data: parseDeprecatedSetReservationListInstruction(instruction),
      ),
    MplTokenMetadataInstruction.deprecatedCreateReservationList =>
      ParsedDeprecatedCreateReservationList(
        data: parseDeprecatedCreateReservationListInstruction(instruction),
      ),
    MplTokenMetadataInstruction.signMetadata => ParsedSignMetadata(
      data: parseSignMetadataInstruction(instruction),
    ),
    MplTokenMetadataInstruction.deprecatedMintPrintingTokensViaToken =>
      ParsedDeprecatedMintPrintingTokensViaToken(
        data: parseDeprecatedMintPrintingTokensViaTokenInstruction(instruction),
      ),
    MplTokenMetadataInstruction.deprecatedMintPrintingTokens =>
      ParsedDeprecatedMintPrintingTokens(
        data: parseDeprecatedMintPrintingTokensInstruction(instruction),
      ),
    MplTokenMetadataInstruction.createMasterEdition =>
      ParsedCreateMasterEdition(
        data: parseCreateMasterEditionInstruction(instruction),
      ),
    MplTokenMetadataInstruction.mintNewEditionFromMasterEditionViaToken =>
      ParsedMintNewEditionFromMasterEditionViaToken(
        data: parseMintNewEditionFromMasterEditionViaTokenInstruction(
          instruction,
        ),
      ),
    MplTokenMetadataInstruction.convertMasterEditionV1ToV2 =>
      ParsedConvertMasterEditionV1ToV2(
        data: parseConvertMasterEditionV1ToV2Instruction(instruction),
      ),
    MplTokenMetadataInstruction.mintNewEditionFromMasterEditionViaVaultProxy =>
      ParsedMintNewEditionFromMasterEditionViaVaultProxy(
        data: parseMintNewEditionFromMasterEditionViaVaultProxyInstruction(
          instruction,
        ),
      ),
    MplTokenMetadataInstruction.puffMetadata => ParsedPuffMetadata(
      data: parsePuffMetadataInstruction(instruction),
    ),
    MplTokenMetadataInstruction.updateMetadataAccountV2 =>
      ParsedUpdateMetadataAccountV2(
        data: parseUpdateMetadataAccountV2Instruction(instruction),
      ),
    MplTokenMetadataInstruction.createMetadataAccountV2 =>
      ParsedCreateMetadataAccountV2(
        data: parseCreateMetadataAccountV2Instruction(instruction),
      ),
    MplTokenMetadataInstruction.createMasterEditionV3 =>
      ParsedCreateMasterEditionV3(
        data: parseCreateMasterEditionV3Instruction(instruction),
      ),
    MplTokenMetadataInstruction.verifyCollection => ParsedVerifyCollection(
      data: parseVerifyCollectionInstruction(instruction),
    ),
    MplTokenMetadataInstruction.utilize => ParsedUtilize(
      data: parseUtilizeInstruction(instruction),
    ),
    MplTokenMetadataInstruction.approveUseAuthority =>
      ParsedApproveUseAuthority(
        data: parseApproveUseAuthorityInstruction(instruction),
      ),
    MplTokenMetadataInstruction.revokeUseAuthority => ParsedRevokeUseAuthority(
      data: parseRevokeUseAuthorityInstruction(instruction),
    ),
    MplTokenMetadataInstruction.unverifyCollection => ParsedUnverifyCollection(
      data: parseUnverifyCollectionInstruction(instruction),
    ),
    MplTokenMetadataInstruction.approveCollectionAuthority =>
      ParsedApproveCollectionAuthority(
        data: parseApproveCollectionAuthorityInstruction(instruction),
      ),
    MplTokenMetadataInstruction.revokeCollectionAuthority =>
      ParsedRevokeCollectionAuthority(
        data: parseRevokeCollectionAuthorityInstruction(instruction),
      ),
    MplTokenMetadataInstruction.setAndVerifyCollection =>
      ParsedSetAndVerifyCollection(
        data: parseSetAndVerifyCollectionInstruction(instruction),
      ),
    MplTokenMetadataInstruction.freezeDelegatedAccount =>
      ParsedFreezeDelegatedAccount(
        data: parseFreezeDelegatedAccountInstruction(instruction),
      ),
    MplTokenMetadataInstruction.thawDelegatedAccount =>
      ParsedThawDelegatedAccount(
        data: parseThawDelegatedAccountInstruction(instruction),
      ),
    MplTokenMetadataInstruction.removeCreatorVerification =>
      ParsedRemoveCreatorVerification(
        data: parseRemoveCreatorVerificationInstruction(instruction),
      ),
    MplTokenMetadataInstruction.burnNft => ParsedBurnNft(
      data: parseBurnNftInstruction(instruction),
    ),
    MplTokenMetadataInstruction.verifySizedCollectionItem =>
      ParsedVerifySizedCollectionItem(
        data: parseVerifySizedCollectionItemInstruction(instruction),
      ),
    MplTokenMetadataInstruction.unverifySizedCollectionItem =>
      ParsedUnverifySizedCollectionItem(
        data: parseUnverifySizedCollectionItemInstruction(instruction),
      ),
    MplTokenMetadataInstruction.setAndVerifySizedCollectionItem =>
      ParsedSetAndVerifySizedCollectionItem(
        data: parseSetAndVerifySizedCollectionItemInstruction(instruction),
      ),
    MplTokenMetadataInstruction.createMetadataAccountV3 =>
      ParsedCreateMetadataAccountV3(
        data: parseCreateMetadataAccountV3Instruction(instruction),
      ),
    MplTokenMetadataInstruction.setCollectionSize => ParsedSetCollectionSize(
      data: parseSetCollectionSizeInstruction(instruction),
    ),
    MplTokenMetadataInstruction.setTokenStandard => ParsedSetTokenStandard(
      data: parseSetTokenStandardInstruction(instruction),
    ),
    MplTokenMetadataInstruction.bubblegumSetCollectionSize =>
      ParsedBubblegumSetCollectionSize(
        data: parseBubblegumSetCollectionSizeInstruction(instruction),
      ),
    MplTokenMetadataInstruction.burnEditionNft => ParsedBurnEditionNft(
      data: parseBurnEditionNftInstruction(instruction),
    ),
    MplTokenMetadataInstruction.createEscrowAccount =>
      ParsedCreateEscrowAccount(
        data: parseCreateEscrowAccountInstruction(instruction),
      ),
    MplTokenMetadataInstruction.closeEscrowAccount => ParsedCloseEscrowAccount(
      data: parseCloseEscrowAccountInstruction(instruction),
    ),
    MplTokenMetadataInstruction.transferOutOfEscrow =>
      ParsedTransferOutOfEscrow(
        data: parseTransferOutOfEscrowInstruction(instruction),
      ),
    MplTokenMetadataInstruction.burn => ParsedBurn(
      data: parseBurnInstruction(instruction),
    ),
    MplTokenMetadataInstruction.create => ParsedCreate(
      data: parseCreateInstruction(instruction),
    ),
    MplTokenMetadataInstruction.mint => ParsedMint(
      data: parseMintInstruction(instruction),
    ),
    MplTokenMetadataInstruction.delegate => ParsedDelegate(
      data: parseDelegateInstruction(instruction),
    ),
    MplTokenMetadataInstruction.revoke => ParsedRevoke(
      data: parseRevokeInstruction(instruction),
    ),
    MplTokenMetadataInstruction.lock => ParsedLock(
      data: parseLockInstruction(instruction),
    ),
    MplTokenMetadataInstruction.unlock => ParsedUnlock(
      data: parseUnlockInstruction(instruction),
    ),
    MplTokenMetadataInstruction.migrate => ParsedMigrate(
      data: parseMigrateInstruction(instruction),
    ),
    MplTokenMetadataInstruction.transfer => ParsedTransfer(
      data: parseTransferInstruction(instruction),
    ),
    MplTokenMetadataInstruction.update => ParsedUpdate(
      data: parseUpdateInstruction(instruction),
    ),
    MplTokenMetadataInstruction.use => ParsedUse(
      data: parseUseInstruction(instruction),
    ),
    MplTokenMetadataInstruction.verify => ParsedVerify(
      data: parseVerifyInstruction(instruction),
    ),
    MplTokenMetadataInstruction.unverify => ParsedUnverify(
      data: parseUnverifyInstruction(instruction),
    ),
    MplTokenMetadataInstruction.collect => ParsedCollect(
      data: parseCollectInstruction(instruction),
    ),
    MplTokenMetadataInstruction.print => ParsedPrint(
      data: parsePrintInstruction(instruction),
    ),
    MplTokenMetadataInstruction.resize => ParsedResize(
      data: parseResizeInstruction(instruction),
    ),
    MplTokenMetadataInstruction.closeAccounts => ParsedCloseAccounts(
      data: parseCloseAccountsInstruction(instruction),
    ),
  };
}
