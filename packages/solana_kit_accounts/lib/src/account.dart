import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

/// The number of bytes required to store the [BaseAccount] information without
/// its data.
///
/// ```dart
/// final myTotalAccountSize = myAccountDataSize + baseAccountSize;
/// ```
const int baseAccountSize = 128;

/// Defines the attributes common to all Solana accounts. Namely, it contains
/// everything stored on-chain except the account data itself.
@immutable
class BaseAccount {
  /// Creates a new [BaseAccount].
  const BaseAccount({
    required this.executable,
    required this.lamports,
    required this.programAddress,
    required this.space,
  });

  /// Indicates if the account contains a program (and is strictly read-only).
  final bool executable;

  /// Number of lamports assigned to this account.
  final Lamports lamports;

  /// Address of the program this account has been assigned to.
  final Address programAddress;

  /// The size of the account data in bytes (excluding the 128 bytes of
  /// header).
  final BigInt space;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BaseAccount &&
          runtimeType == other.runtimeType &&
          executable == other.executable &&
          lamports == other.lamports &&
          programAddress == other.programAddress &&
          space == other.space;

  @override
  int get hashCode => Object.hash(executable, lamports, programAddress, space);

  @override
  String toString() =>
      'BaseAccount(executable: $executable, lamports: $lamports, '
      'programAddress: $programAddress, space: $space)';
}

/// Contains all the information relevant to a Solana account. It includes
/// the account's address and data, as well as the properties of
/// [BaseAccount].
///
/// The type parameter [TData] defines the nature of this account's data. It
/// can be represented as either a [Uint8List] (meaning the account is encoded)
/// or a custom data type (meaning the account is decoded).
@immutable
class Account<TData> extends BaseAccount {
  /// Creates a new [Account].
  const Account({
    required this.address,
    required this.data,
    required super.executable,
    required super.lamports,
    required super.programAddress,
    required super.space,
  });

  /// The address of this account.
  final Address address;

  /// The account data, either encoded as [Uint8List] or decoded as [TData].
  final TData data;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Account<TData> &&
          runtimeType == other.runtimeType &&
          address == other.address &&
          executable == other.executable &&
          this.lamports == other.lamports &&
          programAddress == other.programAddress &&
          space == other.space &&
          _dataEquals(data, other.data);

  @override
  int get hashCode => Object.hash(
    address,
    executable,
    this.lamports,
    programAddress,
    space,
    data is Uint8List ? Object.hashAll(data as Uint8List) : data,
  );

  @override
  String toString() =>
      'Account(address: $address, data: $data, executable: $executable, '
      'lamports: ${this.lamports}, programAddress: $programAddress, '
      'space: $space)';
}

/// Represents an encoded account, equivalent to an [Account] with [Uint8List]
/// account data.
typedef EncodedAccount = Account<Uint8List>;

/// Compares data values, handling [Uint8List] equality specially.
bool _dataEquals<T>(T a, T b) {
  if (a is Uint8List && b is Uint8List) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
  return a == b;
}
