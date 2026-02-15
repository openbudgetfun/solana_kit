import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

/// The type of an address map entry.
enum AddressMapEntryType {
  /// The fee payer account.
  feePayer,

  /// A lookup table account.
  lookupTable,

  /// A static account.
  static_,
}

class _AddressMapEntry {
  _AddressMapEntry({
    required this.type,
    required this.role,
    this.lookupTableAddress,
    this.addressIndex,
  });

  AddressMapEntryType type;
  AccountRole role;
  Address? lookupTableAddress;
  int? addressIndex;
}

/// An ordered account from the address map.
///
/// This can represent either a static account or a lookup table account.
class OrderedAccount {
  /// Creates an [OrderedAccount].
  const OrderedAccount({
    required this.address,
    required this.role,
    required this.type,
    this.lookupTableAddress,
    this.addressIndex,
  });

  /// The account address.
  final Address address;

  /// The account role.
  final AccountRole role;

  /// The type of this entry.
  final AddressMapEntryType type;

  /// The lookup table address, if this is a lookup table account.
  final Address? lookupTableAddress;

  /// The index in the lookup table, if this is a lookup table account.
  final int? addressIndex;

  /// Whether this account is from a lookup table.
  bool get isLookupTable => type == AddressMapEntryType.lookupTable;
}

/// Builds an address map from the fee payer and instructions.
///
/// Accounts from lookup tables are identified by checking if the account
/// object has lookup table properties (via [AccountLookupMeta]).
Map<String, _AddressMapEntry> _buildAddressMap(
  Address feePayer,
  List<Instruction> instructions,
) {
  final addressMap = <String, _AddressMapEntry>{
    feePayer.value: _AddressMapEntry(
      type: AddressMapEntryType.feePayer,
      role: AccountRole.writableSigner,
    ),
  };
  final addressesOfInvokedPrograms = <String>{};

  for (final instruction in instructions) {
    final programAddr = instruction.programAddress.value;
    addressesOfInvokedPrograms.add(programAddr);

    _upsert(addressMap, programAddr, (entry) {
      if (entry != null) {
        if (isWritableRole(entry.role)) {
          switch (entry.type) {
            case AddressMapEntryType.feePayer:
              throw SolanaError(
                SolanaErrorCode.transactionInvokedProgramsCannotPayFees,
                {'programAddress': programAddr},
              );
            case AddressMapEntryType.lookupTable:
            case AddressMapEntryType.static_:
              throw SolanaError(
                SolanaErrorCode.transactionInvokedProgramsMustNotBeWritable,
                {'programAddress': programAddr},
              );
          }
        }
        if (entry.type == AddressMapEntryType.static_) {
          return entry;
        }
      }
      return _AddressMapEntry(
        type: AddressMapEntryType.static_,
        role: AccountRole.readonly,
      );
    });

    if (instruction.accounts == null) continue;

    Comparator<Address>? addressComparator;

    for (final account in instruction.accounts!) {
      final accountAddr = account.address.value;
      // Check if this is a lookup table account. AccountLookupMeta extends
      // AccountMeta, so the accounts list can contain both types.
      final lookupMeta = account is AccountLookupMeta ? account : null;

      _upsert(addressMap, accountAddr, (entry) {
        if (entry != null) {
          switch (entry.type) {
            case AddressMapEntryType.feePayer:
              return entry;
            case AddressMapEntryType.lookupTable:
              final nextRole = mergeRoles(entry.role, account.role);
              if (lookupMeta != null) {
                final shouldReplace =
                    entry.lookupTableAddress != lookupMeta.lookupTableAddress &&
                    (addressComparator ??= getAddressComparator())(
                          lookupMeta.lookupTableAddress,
                          entry.lookupTableAddress!,
                        ) <
                        0;
                if (shouldReplace) {
                  return _AddressMapEntry(
                    type: AddressMapEntryType.lookupTable,
                    role: nextRole,
                    lookupTableAddress: lookupMeta.lookupTableAddress,
                    addressIndex: lookupMeta.addressIndex,
                  );
                }
              } else if (isSignerRole(account.role)) {
                return _AddressMapEntry(
                  type: AddressMapEntryType.static_,
                  role: nextRole,
                );
              }
              if (entry.role != nextRole) {
                entry.role = nextRole;
              }
              return entry;
            case AddressMapEntryType.static_:
              final nextRole = mergeRoles(entry.role, account.role);
              if (addressesOfInvokedPrograms.contains(accountAddr)) {
                if (isWritableRole(account.role)) {
                  throw SolanaError(
                    SolanaErrorCode.transactionInvokedProgramsMustNotBeWritable,
                    {'programAddress': accountAddr},
                  );
                }
                if (entry.role != nextRole) {
                  entry.role = nextRole;
                }
                return entry;
              } else if (lookupMeta != null && !isSignerRole(entry.role)) {
                return _AddressMapEntry(
                  type: AddressMapEntryType.lookupTable,
                  role: nextRole,
                  lookupTableAddress: lookupMeta.lookupTableAddress,
                  addressIndex: lookupMeta.addressIndex,
                );
              } else {
                if (entry.role != nextRole) {
                  entry.role = nextRole;
                }
                return entry;
              }
          }
        }
        if (lookupMeta != null) {
          return _AddressMapEntry(
            type: AddressMapEntryType.lookupTable,
            role: account.role,
            lookupTableAddress: lookupMeta.lookupTableAddress,
            addressIndex: lookupMeta.addressIndex,
          );
        } else {
          return _AddressMapEntry(
            type: AddressMapEntryType.static_,
            role: account.role,
          );
        }
      });
    }
  }
  return addressMap;
}

void _upsert(
  Map<String, _AddressMapEntry> addressMap,
  String address,
  _AddressMapEntry Function(_AddressMapEntry? entry) update,
) {
  addressMap[address] = update(addressMap[address]);
}

/// Builds the address map from fee payer and instructions, then sorts the
/// entries into the canonical account ordering.
List<OrderedAccount> getOrderedAccountsFromInstructions(
  Address feePayer,
  List<Instruction> instructions,
) {
  final addressMap = _buildAddressMap(feePayer, instructions);
  return _getOrderedAccountsFromAddressMap(addressMap);
}

/// Sorts the address map entries into the canonical account ordering.
List<OrderedAccount> _getOrderedAccountsFromAddressMap(
  Map<String, _AddressMapEntry> addressMap,
) {
  Comparator<Address>? addressComparator;
  final entries = addressMap.entries.toList()
    ..sort((a, b) {
      final leftEntry = a.value;
      final rightEntry = b.value;

      // Step 1: Fee payer, then static, then lookups.
      if (leftEntry.type != rightEntry.type) {
        if (leftEntry.type == AddressMapEntryType.feePayer) return -1;
        if (rightEntry.type == AddressMapEntryType.feePayer) return 1;
        if (leftEntry.type == AddressMapEntryType.static_) return -1;
        if (rightEntry.type == AddressMapEntryType.static_) return 1;
      }

      // Step 2: Sort by signer-writability.
      final leftIsSigner = isSignerRole(leftEntry.role);
      final rightIsSigner = isSignerRole(rightEntry.role);
      if (leftIsSigner != rightIsSigner) {
        return leftIsSigner ? -1 : 1;
      }
      final leftIsWritable = isWritableRole(leftEntry.role);
      final rightIsWritable = isWritableRole(rightEntry.role);
      if (leftIsWritable != rightIsWritable) {
        return leftIsWritable ? -1 : 1;
      }

      // Step 3: Sort by address.
      addressComparator ??= getAddressComparator();
      if (leftEntry.type == AddressMapEntryType.lookupTable &&
          rightEntry.type == AddressMapEntryType.lookupTable &&
          leftEntry.lookupTableAddress != rightEntry.lookupTableAddress) {
        return addressComparator!(
          leftEntry.lookupTableAddress!,
          rightEntry.lookupTableAddress!,
        );
      }
      return addressComparator!(Address(a.key), Address(b.key));
    });

  return entries
      .map(
        (entry) => OrderedAccount(
          address: Address(entry.key),
          role: entry.value.role,
          type: entry.value.type,
          lookupTableAddress: entry.value.lookupTableAddress,
          addressIndex: entry.value.addressIndex,
        ),
      )
      .toList();
}
