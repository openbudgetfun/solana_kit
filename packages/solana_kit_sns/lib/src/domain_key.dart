/// Derivation of Solana Name Service name-account addresses.
///
/// Name accounts are program-derived addresses of the SPL Name Service
/// program with seeds `[hash, class, parent]`, where `hash` is the
/// [getHashedName] of the account's name and missing class/parent seeds are
/// replaced by 32 zero bytes.
///
/// The domain algorithm mirrors `getSnsDomainKeySync` from the TypeScript SDK
/// (`js/src/utils/getSnsDomainKeySync.ts`):
///
/// - A TLD-trimmed name with a single label (e.g. `bonfida` for
///   `bonfida.sol`) is hashed once and seeded with the [snsRootDomainAddress]
///   as parent.
/// - A two-label name (e.g. `dex.bonfida`) is derived as a subdomain: the
///   first label is prefixed with a NUL byte (`\x00`), hashed, and seeded
///   with the first label's name account as parent.
/// - A two-label name with a record version (e.g. `url.bonfida`) is derived
///   as a record account: the first label is prefixed with `\x01` (V1) or
///   `\x02` (V2) and V2 records additionally use the
///   [centralStateSnsRecordsAddress] as class seed.
/// - A three-label name with a record version (e.g. `url.dex.bonfida`) is
///   derived as a subdomain record: `dex` is derived as a subdomain of
///   `bonfida`, and the record label is derived as a record of `dex`.
library;

import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';

import 'package:solana_kit_sns/src/hash.dart';
import 'package:solana_kit_sns/src/program_address.dart';

/// The name-account seed placeholder used in place of an absent class or
/// parent key.
final Uint8List _emptyAddressBytes = Uint8List(32);

/// The version of an SNS record account that a name is being derived for.
///
/// The enum value matches the one-byte prefix prepended to the record label
/// before hashing.
enum SnsRecordVersion {
  /// A V1 record account, derived with the `\x01` label prefix.
  v1(1),

  /// A V2 record account (SNS-IP 1), derived with the `\x02` label prefix and
  /// the records central state as class seed.
  v2(2);

  const SnsRecordVersion(this.prefixByte);

  /// The one-byte UTF-8 prefix prepended to the record label before hashing.
  final int prefixByte;
}

/// A name-account address and the hash used to derive it.
typedef DerivedNameAddress = (Address address, Uint8List hash);

/// A derived SNS name-account address and the data used to derive it.
class SnsDomainKey {
  /// Creates a domain key.
  const SnsDomainKey({
    required this.address,
    required this.hash,
    required this.isSub,
    this.isSubRecord = false,
    this.parentAddress,
  });

  /// The derived name-account address.
  final Address address;

  /// The hash (`[getHashedName]`) used as the first PDA seed.
  final Uint8List hash;

  /// Whether the input was a subdomain or record (more than one dot-label).
  final bool isSub;

  /// Whether the input was a record of a subdomain (a three-label input such
  /// as `url.dex.bonfida`).
  final bool isSubRecord;

  /// The parent domain account for a subdomain or subdomain record.
  final Address? parentAddress;
}

/// Derives a name-account address from [hashedName] and optional
/// [classAddress] and [parentAddress] seeds.
///
/// Seeds are `[hashedName, class?, parent?]` in that order; missing class or
/// parent seeds are replaced by 32 zero bytes. This mirrors
/// `getNameAccountKeySync` from the TypeScript SDK.
Future<Address> findNameAccountKey(
  Uint8List hashedName, {
  Address? classAddress,
  Address? parentAddress,
}) async {
  final addressEncoder = getAddressEncoder();
  final (address, _) = await getProgramDerivedAddress(
    programAddress: nameProgramAddressObject,
    seeds: [
      hashedName,
      if (classAddress == null)
        _emptyAddressBytes
      else
        addressEncoder.encode(classAddress),
      if (parentAddress == null)
        _emptyAddressBytes
      else
        addressEncoder.encode(parentAddress),
    ],
  );
  return address;
}

/// Hashes [name] and derives its name-account address under the optional
/// [parentAddress] and [classAddress] seeds.
///
/// This mirrors the private `_deriveSync` helper of the TypeScript SDK.
Future<DerivedNameAddress> deriveNameAddress(
  String name, {
  Address? parentAddress,
  Address? classAddress,
}) async {
  final hash = getHashedName(name);
  final address = await findNameAccountKey(
    hash,
    classAddress: classAddress,
    parentAddress: parentAddress,
  );
  return (address, hash);
}

/// The one-character prefix string for a record (or subdomain) derivation.
String _recordPrefix(SnsRecordVersion? record) {
  final byte = record?.prefixByte ?? 0;
  return String.fromCharCode(byte);
}

/// Derives the SNS name-account address of a TLD-trimmed [domain].
///
/// The TLD suffix must be trimmed before calling this function: pass
/// `"bonfida"` instead of `"bonfida.sol"`, and `"dex.bonfida"` instead of
/// `"dex.bonfida.sol"`.
///
/// Pass [record] to derive the address of a V1 or V2 record with the same
/// label instead of the subdomain itself. For example
/// `findDomainKey('url.bonfida', record: SnsRecordVersion.v2)` derives the
/// V2 `url` record of `bonfida`.
///
/// ## Example
///
/// ```dart
/// final key = await findDomainKey('bonfida');
/// // Crf8hzfthWGbGbLTVCiqRqV5MVnbpHB1L9KQMd6gsinb
/// ```
///
/// Throws an [ArgumentError] when the domain has more than three dot-labels,
/// or exactly three labels without a record version, mirroring the
/// `InvalidInputError` of the TypeScript SDK.
Future<SnsDomainKey> findDomainKey(
  String domain, {
  SnsRecordVersion? record,
}) async {
  final labels = domain.split('.');

  switch (labels.length) {
    case 1:
      // Top-level domain, e.g. "bonfida" for "bonfida.sol".
      final (address, hash) = await deriveNameAddress(
        labels[0],
        parentAddress: snsRootDomainAddressObject,
      );
      return SnsDomainKey(address: address, hash: hash, isSub: false);

    case 2:
      // Subdomain or record of the second label.
      final (parentAddress, _) = await deriveNameAddress(
        labels[1],
        parentAddress: snsRootDomainAddressObject,
      );
      final (address, hash) = await deriveNameAddress(
        _recordPrefix(record) + labels[0],
        parentAddress: parentAddress,
        classAddress: record == SnsRecordVersion.v2
            ? centralStateSnsRecordsAddressObject
            : null,
      );
      return SnsDomainKey(
        address: address,
        hash: hash,
        isSub: true,
        parentAddress: parentAddress,
      );

    case 3 when record != null:
      // Parent domain.
      final (parentAddress, _) = await deriveNameAddress(
        labels[2],
        parentAddress: snsRootDomainAddressObject,
      );
      // Subdomain of the parent.
      final (subAddress, _) = await deriveNameAddress(
        String.fromCharCode(0) + labels[1],
        parentAddress: parentAddress,
      );
      // Record of the subdomain.
      final (address, hash) = await deriveNameAddress(
        _recordPrefix(record) + labels[0],
        parentAddress: subAddress,
        classAddress: record == SnsRecordVersion.v2
            ? centralStateSnsRecordsAddressObject
            : null,
      );
      return SnsDomainKey(
        address: address,
        hash: hash,
        isSub: true,
        isSubRecord: true,
        parentAddress: parentAddress,
      );
  }

  throw ArgumentError.value(
    domain,
    'domain',
    'The domain is malformed: nested domains support at most two labels '
        '(plus one more for a subdomain record)',
  );
}
