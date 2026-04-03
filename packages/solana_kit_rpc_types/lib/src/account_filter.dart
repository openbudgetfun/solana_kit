// ignore_for_file: public_member_api_docs
import 'package:solana_kit_rpc_types/src/encoded_bytes.dart';

/// Describes a slice of account data to retrieve.
class DataSlice {
  const DataSlice({required this.length, required this.offset});

  /// The number of bytes to return.
  final int length;

  /// The byte offset from which to start reading.
  final int offset;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DataSlice &&
          runtimeType == other.runtimeType &&
          length == other.length &&
          offset == other.offset;

  @override
  int get hashCode => Object.hash(runtimeType, length, offset);

  @override
  String toString() => 'DataSlice(length: $length, offset: $offset)';
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MemcmpFilterBase58 &&
          runtimeType == other.runtimeType &&
          bytes == other.bytes &&
          offset == other.offset;

  @override
  int get hashCode => Object.hash(runtimeType, bytes, offset);

  @override
  String toString() =>
      'MemcmpFilterBase58(bytes: $bytes, encoding: $encoding, offset: $offset)';
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MemcmpFilterBase64 &&
          runtimeType == other.runtimeType &&
          bytes == other.bytes &&
          offset == other.offset;

  @override
  int get hashCode => Object.hash(runtimeType, bytes, offset);

  @override
  String toString() =>
      'MemcmpFilterBase64(bytes: $bytes, encoding: $encoding, offset: $offset)';
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GetProgramAccountsMemcmpFilter &&
          runtimeType == other.runtimeType &&
          memcmp == other.memcmp;

  @override
  int get hashCode => Object.hash(runtimeType, memcmp);

  @override
  String toString() => 'GetProgramAccountsMemcmpFilter(memcmp: $memcmp)';
}

/// A data size filter for getProgramAccounts.
///
/// This filter matches when the account data length is equal to [dataSize].
class GetProgramAccountsDatasizeFilter {
  const GetProgramAccountsDatasizeFilter({required this.dataSize});

  /// The expected data size in bytes.
  final BigInt dataSize;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GetProgramAccountsDatasizeFilter &&
          runtimeType == other.runtimeType &&
          dataSize == other.dataSize;

  @override
  int get hashCode => Object.hash(runtimeType, dataSize);

  @override
  String toString() =>
      'GetProgramAccountsDatasizeFilter(dataSize: $dataSize)';
}
