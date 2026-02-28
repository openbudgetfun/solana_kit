import 'package:solana_kit_errors/src/codes.dart';
import 'package:solana_kit_errors/src/error.dart';

/// High-level categories for [SolanaErrorCode] values.
enum SolanaErrorDomain {
  /// General core errors.
  general,

  /// JSON-RPC protocol and server errors.
  jsonRpc,

  /// Address parsing and PDA derivation errors.
  addresses,

  /// Account parsing and decode errors.
  accounts,

  /// Subtle crypto adapter errors.
  subtleCrypto,

  /// Cryptographic random/source errors.
  crypto,

  /// Key pair and signature errors.
  keys,

  /// Instruction shape/assertion errors.
  instruction,

  /// Program instruction execution errors.
  instructionError,

  /// Signer and signing flow errors.
  signer,

  /// Offchain message signing errors.
  offchainMessage,

  /// Transaction construction errors.
  transaction,

  /// Transaction execution errors.
  transactionError,

  /// Transaction planning and execution pipeline errors.
  instructionPlans,

  /// Serialization codec errors.
  codecs,

  /// RPC and transport-level errors.
  rpc,

  /// RPC subscription and channel errors.
  rpcSubscriptions,

  /// Program client resolution errors.
  programClients,

  /// Mobile Wallet Adapter protocol/session errors.
  mobileWalletAdapter,

  /// Helius integration errors.
  helius,

  /// Invariant violations that indicate internal SDK logic issues.
  invariantViolation,

  /// Unknown or uncategorized code.
  unknown,
}

/// Returns the [SolanaErrorDomain] for an error [code].
SolanaErrorDomain getSolanaErrorDomain(int code) {
  if (code >= -32768 && code <= -32000) {
    return SolanaErrorDomain.jsonRpc;
  }
  if (code >= 1 && code <= 10) {
    return SolanaErrorDomain.general;
  }
  if (code >= 2800000 && code <= 2800999) {
    return SolanaErrorDomain.addresses;
  }
  // Includes a historical constant typo in the upstream-port map.
  if ((code >= 3230000 && code <= 3230999) ||
      code == SolanaErrorCode.accountsOneOrMoreAccountsNotFound) {
    return SolanaErrorDomain.accounts;
  }
  if (code >= 3610000 && code <= 3610999) {
    return SolanaErrorDomain.subtleCrypto;
  }
  if (code >= 3611000 && code <= 3611050) {
    return SolanaErrorDomain.crypto;
  }
  if (code >= 3704000 && code <= 3704999) {
    return SolanaErrorDomain.keys;
  }
  if (code >= 4128000 && code <= 4128999) {
    return SolanaErrorDomain.instruction;
  }
  if (code >= 4615000 && code <= 4615999) {
    return SolanaErrorDomain.instructionError;
  }
  if (code >= 5508000 && code <= 5508999) {
    return SolanaErrorDomain.signer;
  }
  if (code >= 5607000 && code <= 5607999) {
    return SolanaErrorDomain.offchainMessage;
  }
  if (code >= 5663000 && code <= 5663999) {
    return SolanaErrorDomain.transaction;
  }
  if (code >= 7050000 && code <= 7050999) {
    return SolanaErrorDomain.transactionError;
  }
  if (code >= 7618000 && code <= 7618999) {
    return SolanaErrorDomain.instructionPlans;
  }
  if (code >= 8078000 && code <= 8078999) {
    return SolanaErrorDomain.codecs;
  }
  if (code >= 8100000 && code <= 8100999) {
    return SolanaErrorDomain.rpc;
  }
  if (code >= 8190000 && code <= 8190999) {
    return SolanaErrorDomain.rpcSubscriptions;
  }
  if (code >= 8400000 && code <= 8400199) {
    return SolanaErrorDomain.mobileWalletAdapter;
  }
  if (code >= 8500000 && code <= 8500999) {
    return SolanaErrorDomain.programClients;
  }
  if (code >= 8600000 && code <= 8600099) {
    return SolanaErrorDomain.helius;
  }
  if (code >= 9900000 && code <= 9900999) {
    return SolanaErrorDomain.invariantViolation;
  }
  return SolanaErrorDomain.unknown;
}

/// Returns `true` when [code] belongs to [domain].
bool isSolanaErrorCodeInDomain(int code, SolanaErrorDomain domain) {
  return getSolanaErrorDomain(code) == domain;
}

/// Returns `true` when [error] is a [SolanaError] in [domain].
bool isSolanaErrorInDomain(Object? error, SolanaErrorDomain domain) {
  return error is SolanaError && error.domain == domain;
}

/// Typed domain helpers for [SolanaError].
extension SolanaErrorDomainExtension on SolanaError {
  /// The high-level domain for this [SolanaError].
  SolanaErrorDomain get domain => getSolanaErrorDomain(code);

  /// Returns `true` if this error belongs to [domain].
  bool isInDomain(SolanaErrorDomain domain) => this.domain == domain;
}

/// Typed domain helpers for raw integer error codes.
extension SolanaErrorCodeDomainExtension on int {
  /// The [SolanaErrorDomain] corresponding to this numeric code.
  SolanaErrorDomain get solanaErrorDomain => getSolanaErrorDomain(this);

  /// Returns `true` if this numeric code belongs to [domain].
  bool isSolanaErrorDomain(SolanaErrorDomain domain) =>
      solanaErrorDomain == domain;
}
