// Auto-generated. Do not edit.
// ignore_for_file: type=lint


import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';


enum ExtensionType {
  uninitialized,
  transferFeeConfig,
  transferFeeAmount,
  mintCloseAuthority,
  confidentialTransferMint,
  confidentialTransferAccount,
  defaultAccountState,
  immutableOwner,
  memoTransfer,
  nonTransferable,
  interestBearingConfig,
  cpiGuard,
  permanentDelegate,
  nonTransferableAccount,
  transferHook,
  transferHookAccount,
  confidentialTransferFee,
  confidentialTransferFeeAmount,
  scaledUiAmountConfig,
  pausableConfig,
  pausableAccount,
  metadataPointer,
  tokenMetadata,
  groupPointer,
  tokenGroup,
  groupMemberPointer,
  tokenGroupMember,
}

Encoder<ExtensionType> getExtensionTypeEncoder() {
  return transformEncoder(
    getU16Encoder(),
    (ExtensionType value) => value.index,
  );
}

Decoder<ExtensionType> getExtensionTypeDecoder() {
  return transformDecoder(
    getU16Decoder(),
    (int value, Uint8List bytes, int offset) => ExtensionType.values[value],
  );
}

Codec<ExtensionType, ExtensionType> getExtensionTypeCodec() {
  return combineCodec(getExtensionTypeEncoder(), getExtensionTypeDecoder());
}
