import 'package:solana_kit_rpc_types/src/encoded_bytes.dart';

/// Describes a slice of account data to retrieve.
class DataSlice {
  const DataSlice({required this.length, required this.offset});

  /// The number of bytes to return.
  final int length;

  /// The byte offset from which to start reading.
  final int offset;
}

/// A memory comparison filter for account data, using base58 encoding.
class MemcmpFilterBase58 {
  const MemcmpFilterBase58({required this.bytes, required this.offset});

  /// The bytes to match, as a base-58 encoded string.
  ///
  /// Data is limited to a maximum of 128 decoded bytes.
  final Base58EncodedBytes bytes;

  /// The encoding used for the byte string.
  String get encoding => 'base58';

  /// The byte offset into the account data from which to start the
  /// comparison.
  final BigInt offset;
}

/// A memory comparison filter for account data, using base64 encoding.
class MemcmpFilterBase64 {
  const MemcmpFilterBase64({required this.bytes, required this.offset});

  /// The bytes to match, as a base-64 encoded string.
  ///
  /// Data is limited to a maximum of 128 decoded bytes.
  final Base64EncodedBytes bytes;

  /// The encoding used for the byte string.
  String get encoding => 'base64';

  /// The byte offset into the account data from which to start the
  /// comparison.
  final BigInt offset;
}

/// A memory comparison filter for getProgramAccounts.
///
/// This filter matches when the bytes supplied are equal to the account data
/// at the given offset.
class GetProgramAccountsMemcmpFilter {
  const GetProgramAccountsMemcmpFilter({required this.memcmp});

  /// The memory comparison parameters.
  ///
  /// Either a [MemcmpFilterBase58] or [MemcmpFilterBase64].
  final Object memcmp;
}

/// A data size filter for getProgramAccounts.
///
/// This filter matches when the account data length is equal to [dataSize].
class GetProgramAccountsDatasizeFilter {
  const GetProgramAccountsDatasizeFilter({required this.dataSize});

  /// The expected data size in bytes.
  final BigInt dataSize;
}
