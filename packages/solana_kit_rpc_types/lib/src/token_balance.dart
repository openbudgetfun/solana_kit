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
}
