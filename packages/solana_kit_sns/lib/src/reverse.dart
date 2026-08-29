/// Reverse-lookup derivations and decoding for Solana Name Service domains.
///
/// Every SNS domain can have a companion *reverse* name account whose data
/// holds the human-readable domain name. Deriving its address hashes the
/// base58 string of the domain address itself and seeds the name account with
/// the [reverseLookupClassAddress] class.
///
/// The algorithm mirrors `getReverseAddressFromDomainAddress` from the
/// TypeScript SDK (`js-kit/src/utils/getReverseAddressFromDomainAddress.ts`).
library;

import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';

import 'package:solana_kit_sns/src/domain_key.dart';
import 'package:solana_kit_sns/src/hash.dart';
import 'package:solana_kit_sns/src/program_address.dart';
import 'package:solana_kit_sns/src/registry.dart';

/// Derives the reverse-lookup account address of a domain account.
///
/// The [domainAddress] seed is the base58 string of the domain's name
/// account. For subdomain reverse accounts, pass the subdomain's direct
/// [parentAddress] as the parent seed, mirroring the TypeScript SDK.
///
/// ## Example
///
/// ```dart
/// final domainKey = await findDomainKey('bonfida');
/// final reverseAddress = await findReverseAddress(
///   domainAddress: domainKey.address,
/// );
/// ```
Future<Address> findReverseAddress({
  required Address domainAddress,
  Address? parentAddress,
}) {
  final hashed = getHashedName(domainAddress.value);
  return findNameAccountKey(
    hashed,
    classAddress: reverseLookupClassAddressObject,
    parentAddress: parentAddress,
  );
}

/// Derives the reverse-lookup account address of a TLD-trimmed [domain].
///
/// The TLD suffix must be trimmed before calling this function: pass
/// `"dex.bonfida"` instead of `"dex.bonfida.sol"`. Subdomains automatically
/// use their parent domain account as the parent seed.
///
/// ## Example
///
/// ```dart
/// final address = await findReverseAddressForDomain('bonfida');
/// ```
Future<Address> findReverseAddressForDomain(String domain) async {
  final key = await findDomainKey(domain);
  return findReverseAddress(
    domainAddress: key.address,
    parentAddress: key.parentAddress,
  );
}

/// Decodes the value stored in a reverse-lookup account's data section.
///
/// The value is a u32-length-prefixed UTF-8 string. When [trimLeadingNullByte]
/// is true, the NUL marker of a subdomain reverse record is removed from the
/// start of the name; when false, it is preserved.
///
/// Mirrors `deserializeReverse` from the TypeScript SDK.
String decodeReverseValue(
  Uint8List data, {
  bool trimLeadingNullByte = false,
}) {
  final value = decodeNameValue(data);
  if (value.isEmpty) {
    return value;
  }
  final firstCodeUnit = value.codeUnitAt(0);
  if (firstCodeUnit != 0) {
    return value;
  }
  return trimLeadingNullByte ? value.substring(1) : value;
}

/// Encodes a [value] for storage in a reverse-lookup account's data section.
///
/// When [isSubdomain] is true, the value is prefixed with a NUL byte, matching
/// the convention used by the TypeScript SDK's reverse-record builders.
Uint8List encodeReverseValue(String value, {bool isSubdomain = false}) {
  return encodeNameValue(isSubdomain ? String.fromCharCode(0) + value : value);
}
