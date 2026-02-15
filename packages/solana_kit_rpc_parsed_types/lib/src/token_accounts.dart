import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_rpc_parsed_types/src/rpc_parsed_type.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

/// The state of a token account.
enum TokenAccountState {
  /// The account is frozen and cannot be used.
  frozen,

  /// The account is initialized and can be used.
  initialized,

  /// The account has not been initialized.
  uninitialized,
}

/// Parsed account data for a Token program account.
///
/// This is a discriminated union that can be:
/// - [JsonParsedTokenAccountVariant] ('account')
/// - [JsonParsedMintAccount] ('mint')
/// - [JsonParsedMultisigAccount] ('multisig')
sealed class JsonParsedTokenProgramAccount {
  const JsonParsedTokenProgramAccount();
}

/// A parsed Token program 'account' variant.
class JsonParsedTokenAccountVariant
    extends RpcParsedType<String, JsonParsedTokenAccount>
    implements JsonParsedTokenProgramAccount {
  /// Creates a new [JsonParsedTokenAccountVariant].
  const JsonParsedTokenAccountVariant({required super.info})
    : super(type: 'account');
}

/// The info payload for a parsed token account.
class JsonParsedTokenAccount {
  /// Creates a new [JsonParsedTokenAccount].
  const JsonParsedTokenAccount({
    required this.isNative,
    required this.mint,
    required this.owner,
    required this.state,
    required this.tokenAmount,
    this.closeAuthority,
    this.delegate,
    this.delegatedAmount,
    this.extensions,
    this.rentExemptReserve,
  });

  /// The optional close authority address.
  final Address? closeAuthority;

  /// The optional delegate address.
  final Address? delegate;

  /// The amount delegated, if any.
  final TokenAmount? delegatedAmount;

  /// The list of token extensions, if any.
  final List<Object?>? extensions;

  /// Whether this is a native SOL token account.
  final bool isNative;

  /// The mint address for this token account.
  final Address mint;

  /// The owner address of this token account.
  final Address owner;

  /// The rent-exempt reserve amount, if applicable.
  final TokenAmount? rentExemptReserve;

  /// The state of the token account.
  final TokenAccountState state;

  /// The token balance.
  final TokenAmount tokenAmount;
}

/// A parsed Token program 'mint' variant.
class JsonParsedMintAccount extends RpcParsedType<String, JsonParsedMintInfo>
    implements JsonParsedTokenProgramAccount {
  /// Creates a new [JsonParsedMintAccount].
  const JsonParsedMintAccount({required super.info}) : super(type: 'mint');
}

/// The info payload for a parsed mint account.
class JsonParsedMintInfo {
  /// Creates a new [JsonParsedMintInfo].
  const JsonParsedMintInfo({
    required this.decimals,
    required this.isInitialized,
    required this.supply,
    this.extensions,
    this.freezeAuthority,
    this.mintAuthority,
  });

  /// The number of decimal places.
  final int decimals;

  /// The list of token extensions, if any.
  final List<Object?>? extensions;

  /// The freeze authority address, or `null` if none.
  final Address? freezeAuthority;

  /// Whether the mint is initialized.
  final bool isInitialized;

  /// The mint authority address, or `null` if none.
  final Address? mintAuthority;

  /// The total supply.
  final StringifiedBigInt supply;
}

/// A parsed Token program 'multisig' variant.
class JsonParsedMultisigAccount
    extends RpcParsedType<String, JsonParsedMultisigInfo>
    implements JsonParsedTokenProgramAccount {
  /// Creates a new [JsonParsedMultisigAccount].
  const JsonParsedMultisigAccount({required super.info})
    : super(type: 'multisig');
}

/// The info payload for a parsed multisig account.
class JsonParsedMultisigInfo {
  /// Creates a new [JsonParsedMultisigInfo].
  const JsonParsedMultisigInfo({
    required this.isInitialized,
    required this.numRequiredSigners,
    required this.numValidSigners,
    required this.signers,
  });

  /// Whether the multisig is initialized.
  final bool isInitialized;

  /// The number of required signers.
  final int numRequiredSigners;

  /// The number of valid signers.
  final int numValidSigners;

  /// The list of signer addresses.
  final List<Address> signers;
}
