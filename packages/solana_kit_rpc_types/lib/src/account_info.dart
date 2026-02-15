import 'package:solana_kit_addresses/solana_kit_addresses.dart';

import 'package:solana_kit_rpc_types/src/encoded_bytes.dart';
import 'package:solana_kit_rpc_types/src/lamports.dart';

/// Base account information shared by all account info variants.
class AccountInfoBase {
  const AccountInfoBase({
    required this.executable,
    required this.lamports,
    required this.owner,
    required this.space,
  });

  /// Indicates if the account contains a program (and is strictly read-only).
  final bool executable;

  /// Number of lamports assigned to this account.
  final Lamports lamports;

  /// Address of the program this account has been assigned to.
  final Address owner;

  /// The size of the account data in bytes (excluding the 128 bytes of
  /// header).
  final BigInt space;
}

/// Account info with base58-encoded bytes as data.
@Deprecated('Use AccountInfoWithBase64EncodedData instead')
class AccountInfoWithBase58Bytes {
  @Deprecated('Use AccountInfoWithBase64EncodedData instead')
  const AccountInfoWithBase58Bytes({required this.data});

  /// The account data as base58-encoded bytes.
  final Base58EncodedBytes data;
}

/// Account info with base58-encoded data response.
@Deprecated('Use AccountInfoWithBase64EncodedData instead')
class AccountInfoWithBase58EncodedData {
  @Deprecated('Use AccountInfoWithBase64EncodedData instead')
  const AccountInfoWithBase58EncodedData({required this.data});

  /// The account data as a (base58String, 'base58') tuple.
  final Base58EncodedDataResponse data;
}

/// Account info with base64-encoded data.
class AccountInfoWithBase64EncodedData {
  const AccountInfoWithBase64EncodedData({required this.data});

  /// The account data as a (base64String, 'base64') tuple.
  final Base64EncodedDataResponse data;
}

/// Account info with base64-encoded zstd-compressed data.
class AccountInfoWithBase64EncodedZStdCompressedData {
  const AccountInfoWithBase64EncodedZStdCompressedData({required this.data});

  /// The account data as a (base64+zstdString, 'base64+zstd') tuple.
  final Base64EncodedZStdCompressedDataResponse data;
}

/// Parsed account data from jsonParsed encoding.
class ParsedAccountData {
  const ParsedAccountData({
    required this.type,
    required this.program,
    required this.space,
    this.info,
  });

  /// The parsed info, if available.
  final Map<String, Object?>? info;

  /// A label that indicates the type of the account data.
  final String type;

  /// Name of the program that owns this account.
  final String program;

  /// The size of the account data.
  final BigInt space;
}

/// Account info data for jsonParsed encoding - can be either parsed data or
/// fall back to base64 encoding.
sealed class AccountInfoJsonData {
  const AccountInfoJsonData();
}

/// Parsed account data variant.
class AccountInfoJsonDataParsed extends AccountInfoJsonData {
  const AccountInfoJsonDataParsed({required this.parsed});

  /// The parsed account data.
  final ParsedAccountData parsed;
}

/// Fallback base64-encoded data variant (used when jsonParsed encoding is
/// requested but a parser cannot be found).
class AccountInfoJsonDataBase64 extends AccountInfoJsonData {
  const AccountInfoJsonDataBase64({required this.data});

  /// The account data as a (base64String, 'base64') tuple.
  final Base64EncodedDataResponse data;
}

/// Account info with json-parsed data.
class AccountInfoWithJsonData {
  const AccountInfoWithJsonData({required this.data});

  /// The account data, either parsed or base64-encoded.
  final AccountInfoJsonData data;
}

/// Wraps account info with the account's public key.
class AccountInfoWithPubkey<TAccount extends AccountInfoBase> {
  const AccountInfoWithPubkey({required this.account, required this.pubkey});

  /// The account information.
  final TAccount account;

  /// The public key of the account.
  final Address pubkey;
}
