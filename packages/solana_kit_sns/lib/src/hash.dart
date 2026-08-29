/// Name hashing for Solana Name Service address derivation.
///
/// The SPL Name Service program derives name accounts from a SHA-256 hash of
/// a domain (or seed string) salted with a fixed prefix. The prefix and
/// algorithm mirror the TypeScript SDK's `getHashedNameSync`
/// (`js/src/utils/getHashedNameSync.ts`).
library;

import 'dart:typed_data';

import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';

import 'package:solana_kit_sns/src/sha256.dart';

/// The UTF-8 prefix prepended to every name before hashing.
///
/// `'SNS_HASH_PREFIX'` in the TypeScript SDK; there is a single prefix for
/// both V1 and V2 accounts. Record-version differentiation happens through
/// the one-byte label prefix (`\x01` / `\x02` / `\x00`) prepended to record
/// names before hashing, not through a different hash prefix.
const snsHashPrefix = 'SPL Name Service';

/// Hashes [name] with the SNS name-service seed derivation.
///
/// The result is `sha256(utf8(snsHashPrefix + name))`, i.e. the first PDA
/// seed used by name-account derivations such as `findNameAccountKey` and
/// `findDomainKey` from `src/domain_key.dart`.
///
/// ## Example
///
/// ```dart
/// final hash = getHashedName('bonfida');
/// // 8ee2d25c3d2b2a83a1fc209b90377aed03dc2539e8e238355edda8d1b2edab98
/// ```
Uint8List getHashedName(String name) {
  final input = getUtf8Encoder().encode(snsHashPrefix + name);
  return sha256(input);
}
