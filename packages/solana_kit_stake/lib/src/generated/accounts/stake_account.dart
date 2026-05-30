// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_accounts/solana_kit_accounts.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';

import '../types/stake_state_v2.dart';

/// Decoded data for a Stake program account.
@immutable
class StakeAccount {
  /// Creates a [StakeAccount].
  const StakeAccount({required this.state});

  /// The stake account state.
  final StakeStateV2 state;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is StakeAccount && state == other.state;

  @override
  int get hashCode => state.hashCode;

  @override
  String toString() => 'StakeAccount(state: $state)';
}

/// The canonical stake account data size in bytes.
const int stakeAccountSize = 200;

/// Returns the encoder for [StakeAccount].
Encoder<StakeAccount> getStakeAccountEncoder() {
  return transformEncoder(
    getStakeStateV2Encoder(),
    (StakeAccount value) => value.state,
  );
}

/// Returns the decoder for [StakeAccount].
Decoder<StakeAccount> getStakeAccountDecoder() {
  return transformDecoder(
    getStakeStateV2Decoder(),
    (StakeStateV2 state, Uint8List bytes, int offset) =>
        StakeAccount(state: state),
  );
}

/// Returns the codec for [StakeAccount].
Codec<StakeAccount, StakeAccount> getStakeAccountCodec() {
  return combineCodec(getStakeAccountEncoder(), getStakeAccountDecoder());
}

/// Decodes an encoded account as a [StakeAccount].
Account<StakeAccount> decodeStakeAccount(EncodedAccount encodedAccount) {
  return decodeAccount(encodedAccount, getStakeAccountDecoder());
}
