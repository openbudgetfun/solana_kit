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
SolanaErrorDomain getSolanaErrorDomain(SolanaErrorCode code) {
  final v = code.value;
  if (v >= -32768 && v <= -32000) {
    return SolanaErrorDomain.jsonRpc;
  }
  if (v >= 1 && v <= 10) {
    return SolanaErrorDomain.general;
  }
  if (v >= 2800000 && v <= 2800999) {
    return SolanaErrorDomain.addresses;
  }
  // Includes a historical constant typo in the upstream-port map.
  if ((v >= 3230000 && v <= 3230999) ||
      code == SolanaErrorCode.accountsOneOrMoreAccountsNotFound) {
    return SolanaErrorDomain.accounts;
  }
  if (v >= 3610000 && v <= 3610999) {
    return SolanaErrorDomain.subtleCrypto;
  }
  if (v >= 3611000 && v <= 3611050) {
    return SolanaErrorDomain.crypto;
  }
  if (v >= 3704000 && v <= 3704999) {
    return SolanaErrorDomain.keys;
  }
  if (v >= 4128000 && v <= 4128999) {
    return SolanaErrorDomain.instruction;
  }
  if (v >= 4615000 && v <= 4615999) {
    return SolanaErrorDomain.instructionError;
  }
  if (v >= 5508000 && v <= 5508999) {
    return SolanaErrorDomain.signer;
  }
  if (v >= 5607000 && v <= 5607999) {
    return SolanaErrorDomain.offchainMessage;
  }
  if (v >= 5663000 && v <= 5663999) {
    return SolanaErrorDomain.transaction;
  }
  if (v >= 7050000 && v <= 7050999) {
    return SolanaErrorDomain.transactionError;
  }
  if (v >= 7618000 && v <= 7618999) {
    return SolanaErrorDomain.instructionPlans;
  }
  if (v >= 8078000 && v <= 8078999) {
    return SolanaErrorDomain.codecs;
  }
  if (v >= 8100000 && v <= 8100999) {
    return SolanaErrorDomain.rpc;
  }
  if (v >= 8190000 && v <= 8190999) {
    return SolanaErrorDomain.rpcSubscriptions;
  }
  if (v >= 8400000 && v <= 8400199) {
    return SolanaErrorDomain.mobileWalletAdapter;
  }
  if (v >= 8500000 && v <= 8500999) {
    return SolanaErrorDomain.programClients;
  }
  if (v >= 8600000 && v <= 8600099) {
    return SolanaErrorDomain.helius;
  }
  if (v >= 9900000 && v <= 9900999) {
    return SolanaErrorDomain.invariantViolation;
  }
  return SolanaErrorDomain.unknown;
}

/// Returns `true` when [code] belongs to [domain].
bool isSolanaErrorCodeInDomain(SolanaErrorCode code, SolanaErrorDomain domain) {
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

/// Typed domain helpers for [SolanaErrorCode] enum values.
extension SolanaErrorCodeDomainExtension on SolanaErrorCode {
  /// The [SolanaErrorDomain] corresponding to this error code.
  SolanaErrorDomain get solanaErrorDomain => getSolanaErrorDomain(this);

  /// Returns `true` if this error code belongs to [domain].
  bool isSolanaErrorDomain(SolanaErrorDomain domain) =>
      solanaErrorDomain == domain;
}
