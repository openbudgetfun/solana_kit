// Auto-generated. Do not edit.
// ignore_for_file: type=lint


import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_accounts/solana_kit_accounts.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

import '../types/account_state.dart';
import '../types/extension.dart';


@immutable
class Token {
  const Token({
    required this.mint,
    required this.owner,
    required this.amount,
    required this.delegate,
    required this.state,
    required this.isNative,
    required this.delegatedAmount,
    required this.closeAuthority,
    required this.extensions,
  });

  final Address mint;
  final Address owner;
  final BigInt amount;
  final Address? delegate;
  final AccountState state;
  final BigInt? isNative;
  final BigInt delegatedAmount;
  final Address? closeAuthority;
  final List<Extension>? extensions;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Token &&
          runtimeType == other.runtimeType &&
          mint == other.mint &&
          owner == other.owner &&
          amount == other.amount &&
          delegate == other.delegate &&
          state == other.state &&
          isNative == other.isNative &&
          delegatedAmount == other.delegatedAmount &&
          closeAuthority == other.closeAuthority &&
          extensions == other.extensions;

  @override
  int get hashCode => Object.hash(mint, owner, amount, delegate, state, isNative, delegatedAmount, closeAuthority, extensions);

  @override
  String toString() => 'Token(mint: $mint, owner: $owner, amount: $amount, delegate: $delegate, state: $state, isNative: $isNative, delegatedAmount: $delegatedAmount, closeAuthority: $closeAuthority, extensions: $extensions)';
}

/// This account has a size discriminator of 165 bytes.


Encoder<Token> getTokenEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('mint', getAddressEncoder()),
    ('owner', getAddressEncoder()),
    ('amount', getU64Encoder()),
    ('delegate', getNullableEncoder<Address>(getAddressEncoder(), prefix: getU32Encoder(), noneValue: const ZeroesNoneValue())),
    ('state', getAccountStateEncoder()),
    ('isNative', getNullableEncoder<BigInt>(getU64Encoder(), prefix: getU32Encoder(), noneValue: const ZeroesNoneValue())),
    ('delegatedAmount', getU64Encoder()),
    ('closeAuthority', getNullableEncoder<Address>(getAddressEncoder(), prefix: getU32Encoder(), noneValue: const ZeroesNoneValue())),
    ('extensions', getNullableEncoder<List<Extension>>(getHiddenPrefixEncoder(getArrayEncoder(getExtensionEncoder(), size: RemainderArraySize()), [getConstantEncoder(getU8Encoder().encode(2))]), hasPrefix: false)),
  ]);

  return transformEncoder(
    structEncoder,
    (Token value) => <String, Object?>{
      'mint': value.mint,
      'owner': value.owner,
      'amount': value.amount,
      'delegate': value.delegate,
      'state': value.state,
      'isNative': value.isNative,
      'delegatedAmount': value.delegatedAmount,
      'closeAuthority': value.closeAuthority,
      'extensions': value.extensions,
    },
  );
}

Decoder<Token> getTokenDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('mint', getAddressDecoder()),
    ('owner', getAddressDecoder()),
    ('amount', getU64Decoder()),
    ('delegate', getNullableDecoder<Address>(getAddressDecoder(), prefix: getU32Decoder(), noneValue: const ZeroesNoneValue())),
    ('state', getAccountStateDecoder()),
    ('isNative', getNullableDecoder<BigInt>(getU64Decoder(), prefix: getU32Decoder(), noneValue: const ZeroesNoneValue())),
    ('delegatedAmount', getU64Decoder()),
    ('closeAuthority', getNullableDecoder<Address>(getAddressDecoder(), prefix: getU32Decoder(), noneValue: const ZeroesNoneValue())),
    ('extensions', getNullableDecoder<List<Extension>>(getHiddenPrefixDecoder(getArrayDecoder(getExtensionDecoder(), size: RemainderArraySize()), [getConstantDecoder(getU8Encoder().encode(2))]), hasPrefix: false)),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => Token(
      mint: map['mint']! as Address,
      owner: map['owner']! as Address,
      amount: map['amount']! as BigInt,
      delegate: map['delegate'] as Address?,
      state: map['state']! as AccountState,
      isNative: map['isNative'] as BigInt?,
      delegatedAmount: map['delegatedAmount']! as BigInt,
      closeAuthority: map['closeAuthority'] as Address?,
      extensions: map['extensions'] as List<Extension>?,
    ),
  );
}

Codec<Token, Token> getTokenCodec() {
  return combineCodec(getTokenEncoder(), getTokenDecoder());
}

Account<Token> decodeToken(EncodedAccount encodedAccount) {
  return decodeAccount(encodedAccount, getTokenDecoder());
}
