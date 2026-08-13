// Auto-generated. Do not edit.
// ignore_for_file: type=lint


import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';


enum AuthorityType {
  mintTokens,
  freezeAccount,
  accountOwner,
  closeAccount,
  transferFeeConfig,
  withheldWithdraw,
  closeMint,
  interestRate,
  permanentDelegate,
  confidentialTransferMint,
  transferHookProgramId,
  confidentialTransferFeeConfig,
  metadataPointer,
  groupPointer,
  groupMemberPointer,
  scaledUiAmount,
  pause,
  permissionedBurn,
}

Encoder<AuthorityType> getAuthorityTypeEncoder() {
  return transformEncoder(
    getU8Encoder(),
    (AuthorityType value) => value.index,
  );
}

Decoder<AuthorityType> getAuthorityTypeDecoder() {
  return transformDecoder(
    getU8Decoder(),
    (int value, Uint8List bytes, int offset) => AuthorityType.values[value],
  );
}

Codec<AuthorityType, AuthorityType> getAuthorityTypeCodec() {
  return combineCodec(getAuthorityTypeEncoder(), getAuthorityTypeDecoder());
}
