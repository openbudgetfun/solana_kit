// Auto-generated. Do not edit.
// ignore_for_file: type=lint


import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';


enum AccountDiscriminator {
  subscriptionAuthority,
  plan,
  fixedDelegation,
  recurringDelegation,
  subscriptionDelegation,
}

Encoder<AccountDiscriminator> getAccountDiscriminatorEncoder() {
  return transformEncoder(
    getU8Encoder(),
    (AccountDiscriminator value) => value.index,
  );
}

Decoder<AccountDiscriminator> getAccountDiscriminatorDecoder() {
  return transformDecoder(
    getU8Decoder(),
    (int value, Uint8List bytes, int offset) => AccountDiscriminator.values[value],
  );
}

Codec<AccountDiscriminator, AccountDiscriminator> getAccountDiscriminatorCodec() {
  return combineCodec(getAccountDiscriminatorEncoder(), getAccountDiscriminatorDecoder());
}
