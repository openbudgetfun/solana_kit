// ignore_for_file: public_member_api_docs
import 'package:solana_kit_addresses/solana_kit_addresses.dart';

import 'package:solana_kit_rpc_types/src/token_amount.dart';

/// Represents a token balance for an account at a specific index in a
/// transaction.
class TokenBalance {
  const TokenBalance({
    required this.accountIndex,
    required this.mint,
    required this.uiTokenAmount,
    this.owner,
    this.programId,
  });

  /// Index of the account in which the token balance is provided for.
  final int accountIndex;

  /// Address of the token's mint.
  final Address mint;

  /// Address of token balance's owner.
  final Address? owner;

  /// Address of the Token program that owns the account.
  final Address? programId;

  /// The token amount details.
  final TokenAmount uiTokenAmount;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TokenBalance &&
          runtimeType == other.runtimeType &&
          accountIndex == other.accountIndex &&
          mint == other.mint &&
          owner == other.owner &&
          programId == other.programId &&
          uiTokenAmount == other.uiTokenAmount;

  @override
  int get hashCode => Object.hash(
    runtimeType,
    accountIndex,
    mint,
    owner,
    programId,
    uiTokenAmount,
  );

  @override
  String toString() =>
      'TokenBalance(accountIndex: $accountIndex, mint: $mint, '
      'owner: $owner, programId: $programId, uiTokenAmount: $uiTokenAmount)';
}
