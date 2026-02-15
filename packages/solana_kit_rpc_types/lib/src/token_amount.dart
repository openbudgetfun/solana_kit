import 'package:solana_kit_rpc_types/src/stringified_bigint.dart';
import 'package:solana_kit_rpc_types/src/stringified_number.dart';

/// Represents a token amount as returned by the Solana RPC.
class TokenAmount {
  const TokenAmount({
    required this.amount,
    required this.decimals,
    required this.uiAmountString,
    @Deprecated('Use uiAmountString instead') this.uiAmount,
  });

  /// The quantity, in fractional units.
  ///
  /// If the token in question is configured to have 6 decimal places, the
  /// value `1_000_000` would indicate a balance of one whole token.
  final StringifiedBigInt amount;

  /// A power of ten, the inverse of which defines the smallest fractional
  /// unit of this token.
  ///
  /// A token configured to have 6 decimals is made up of fractional units
  /// each representing 10^(-6) tokens.
  final int decimals;

  /// The balance as a floating-point number.
  @Deprecated('Use uiAmountString instead')
  final double? uiAmount;

  /// The balance of whole tokens, as a string.
  ///
  /// The string representation will use a decimal when necessary, but will
  /// never contain trailing zeros to the right of the decimal place.
  final StringifiedNumber uiAmountString;
}
