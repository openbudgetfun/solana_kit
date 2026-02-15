import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';

import 'package:solana_kit_transaction_messages/src/transaction_message.dart';

/// The header of a compiled transaction message, describing the account roles.
@immutable
class MessageHeader {
  /// Creates a [MessageHeader].
  const MessageHeader({
    required this.numSignerAccounts,
    required this.numReadonlySignerAccounts,
    required this.numReadonlyNonSignerAccounts,
  });

  /// The number of accounts that must sign this transaction.
  final int numSignerAccounts;

  /// The number of read-only accounts that must sign this transaction.
  final int numReadonlySignerAccounts;

  /// The number of read-only non-signer accounts.
  final int numReadonlyNonSignerAccounts;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageHeader &&
          numSignerAccounts == other.numSignerAccounts &&
          numReadonlySignerAccounts == other.numReadonlySignerAccounts &&
          numReadonlyNonSignerAccounts == other.numReadonlyNonSignerAccounts;

  @override
  int get hashCode => Object.hash(
    numSignerAccounts,
    numReadonlySignerAccounts,
    numReadonlyNonSignerAccounts,
  );
}

/// A compiled instruction with indices referencing the static accounts list.
@immutable
class CompiledInstruction {
  /// Creates a [CompiledInstruction].
  const CompiledInstruction({
    required this.programAddressIndex,
    this.accountIndices,
    this.data,
  });

  /// The index of the program address in the static accounts list.
  final int programAddressIndex;

  /// An ordered list of account indices.
  final List<int>? accountIndices;

  /// The instruction data.
  final Uint8List? data;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompiledInstruction &&
          programAddressIndex == other.programAddressIndex &&
          _listEquals(accountIndices, other.accountIndices) &&
          _uint8ListEquals(data, other.data);

  @override
  int get hashCode => Object.hash(
    programAddressIndex,
    accountIndices != null ? Object.hashAll(accountIndices!) : null,
    data != null ? Object.hashAll(data!) : null,
  );
}

bool _listEquals<T>(List<T>? a, List<T>? b) {
  if (identical(a, b)) return true;
  if (a == null || b == null) return a == b;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

bool _uint8ListEquals(Uint8List? a, Uint8List? b) {
  if (identical(a, b)) return true;
  if (a == null || b == null) return a == b;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// An address table lookup in a compiled transaction message.
@immutable
class AddressTableLookup {
  /// Creates an [AddressTableLookup].
  const AddressTableLookup({
    required this.lookupTableAddress,
    required this.writableIndexes,
    required this.readonlyIndexes,
  });

  /// The address of the address lookup table account.
  final Address lookupTableAddress;

  /// Indexes of accounts in a lookup table to load as writable.
  final List<int> writableIndexes;

  /// Indexes of accounts in a lookup table to load as read-only.
  final List<int> readonlyIndexes;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AddressTableLookup &&
          lookupTableAddress == other.lookupTableAddress &&
          _listEquals(writableIndexes, other.writableIndexes) &&
          _listEquals(readonlyIndexes, other.readonlyIndexes);

  @override
  int get hashCode => Object.hash(
    lookupTableAddress,
    Object.hashAll(writableIndexes),
    Object.hashAll(readonlyIndexes),
  );
}

/// A compiled transaction message suitable for encoding and execution on the
/// network.
@immutable
class CompiledTransactionMessage {
  /// Creates a [CompiledTransactionMessage].
  const CompiledTransactionMessage({
    required this.version,
    required this.header,
    required this.staticAccounts,
    required this.instructions,
    this.lifetimeToken,
    this.addressTableLookups,
  });

  /// The version of this compiled transaction message.
  final TransactionVersion version;

  /// The message header describing account roles.
  final MessageHeader header;

  /// The list of static account addresses.
  final List<Address> staticAccounts;

  /// The lifetime token (blockhash or nonce value).
  final String? lifetimeToken;

  /// The compiled instructions.
  final List<CompiledInstruction> instructions;

  /// The address table lookups (only for versioned messages).
  final List<AddressTableLookup>? addressTableLookups;
}
