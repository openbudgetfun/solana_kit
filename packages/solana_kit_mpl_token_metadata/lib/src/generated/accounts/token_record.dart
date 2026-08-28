// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_accounts/solana_kit_accounts.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';

import '../types/key.dart';
import '../types/token_delegate_role.dart';
import '../types/token_state.dart';

@immutable
class TokenRecord {
  const TokenRecord({
    required this.key,
    required this.bump,
    required this.state,
    required this.ruleSetRevision,
    required this.delegate,
    required this.delegateRole,
    required this.lockedTransfer,
  });

  final Key key;
  final int bump;
  final TokenState state;
  final BigInt? ruleSetRevision;
  final Address? delegate;
  final TokenDelegateRole? delegateRole;
  final Address? lockedTransfer;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TokenRecord &&
          runtimeType == other.runtimeType &&
          key == other.key &&
          bump == other.bump &&
          state == other.state &&
          ruleSetRevision == other.ruleSetRevision &&
          delegate == other.delegate &&
          delegateRole == other.delegateRole &&
          lockedTransfer == other.lockedTransfer;

  @override
  int get hashCode => Object.hash(
    key,
    bump,
    state,
    ruleSetRevision,
    delegate,
    delegateRole,
    lockedTransfer,
  );

  @override
  String toString() =>
      'TokenRecord(key: $key, bump: $bump, state: $state, ruleSetRevision: $ruleSetRevision, delegate: $delegate, delegateRole: $delegateRole, lockedTransfer: $lockedTransfer)';
}

Encoder<TokenRecord> getTokenRecordEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('key', getKeyEncoder()),
    ('bump', getU8Encoder()),
    ('state', getTokenStateEncoder()),
    ('ruleSetRevision', getNullableEncoder<BigInt>(getU64Encoder())),
    ('delegate', getNullableEncoder<Address>(getAddressEncoder())),
    (
      'delegateRole',
      getNullableEncoder<TokenDelegateRole>(getTokenDelegateRoleEncoder()),
    ),
    ('lockedTransfer', getNullableEncoder<Address>(getAddressEncoder())),
  ]);

  return transformEncoder(
    structEncoder,
    (TokenRecord value) => <String, Object?>{
      'key': value.key,
      'bump': value.bump,
      'state': value.state,
      'ruleSetRevision': value.ruleSetRevision,
      'delegate': value.delegate,
      'delegateRole': value.delegateRole,
      'lockedTransfer': value.lockedTransfer,
    },
  );
}

Decoder<TokenRecord> getTokenRecordDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('key', getKeyDecoder()),
    ('bump', getU8Decoder()),
    ('state', getTokenStateDecoder()),
    ('ruleSetRevision', getNullableDecoder<BigInt>(getU64Decoder())),
    ('delegate', getNullableDecoder<Address>(getAddressDecoder())),
    (
      'delegateRole',
      getNullableDecoder<TokenDelegateRole>(getTokenDelegateRoleDecoder()),
    ),
    ('lockedTransfer', getNullableDecoder<Address>(getAddressDecoder())),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'tokenRecord account decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (TokenRecord, int) readTopLevel(Uint8List bytes, int offset) {
    final (map, newOffset) = structDecoder.read(bytes, offset);

    return (
      TokenRecord(
        key: map['key']! as Key,
        bump: map['bump']! as int,
        state: map['state']! as TokenState,
        ruleSetRevision: map['ruleSetRevision'] as BigInt?,
        delegate: map['delegate'] as Address?,
        delegateRole: map['delegateRole'] as TokenDelegateRole?,
        lockedTransfer: map['lockedTransfer'] as Address?,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() => FixedSizeDecoder<TokenRecord>(
      fixedSize: structDecoder.fixedSize,
      read: (bytes, offset) {
        final bytesLength = bytes.length - offset;
        if (bytesLength < structDecoder.fixedSize) {
          throwInvalidByteLength(structDecoder.fixedSize, bytesLength);
        }
        return readTopLevel(bytes, offset);
      },
    ),
    VariableSizeDecoder<Map<String, Object?>>() =>
      VariableSizeDecoder<TokenRecord>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<TokenRecord, TokenRecord> getTokenRecordCodec() {
  return combineCodec(getTokenRecordEncoder(), getTokenRecordDecoder());
}

Account<TokenRecord> decodeTokenRecord(EncodedAccount encodedAccount) {
  return decodeAccount(encodedAccount, getTokenRecordDecoder());
}
