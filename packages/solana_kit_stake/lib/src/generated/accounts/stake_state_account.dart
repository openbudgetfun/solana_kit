// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_accounts/solana_kit_accounts.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';

import '../types/stake_state_v2.dart';

@immutable
class StakeStateAccount {
  const StakeStateAccount({
    required this.state,
  });

  final StakeStateV2 state;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StakeStateAccount &&
          runtimeType == other.runtimeType &&
          state == other.state;

  @override
  int get hashCode => state.hashCode;

  @override
  String toString() => 'StakeStateAccount(state: $state)';
}

/// The size of the [StakeStateAccount] account data in bytes.
const int stakeStateAccountSize = 200;

Encoder<StakeStateAccount> getStakeStateAccountEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('state', getStakeStateV2Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (StakeStateAccount value) => <String, Object?>{
      'state': value.state,
    },
  );
}

Decoder<StakeStateAccount> getStakeStateAccountDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('state', getStakeStateV2Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        StakeStateAccount(
          state: map['state']! as StakeStateV2,
        ),
  );
}

Codec<StakeStateAccount, StakeStateAccount> getStakeStateAccountCodec() {
  return combineCodec(
    getStakeStateAccountEncoder(),
    getStakeStateAccountDecoder(),
  );
}

Account<StakeStateAccount> decodeStakeStateAccount(
  EncodedAccount encodedAccount,
) {
  return decodeAccount(encodedAccount, getStakeStateAccountDecoder());
}
