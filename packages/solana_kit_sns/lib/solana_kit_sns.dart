/// Solana Name Service (SNS) client for the Solana Kit Dart SDK.
///
/// Provides address derivation, state codecs, and record helpers for
/// interacting with the [Solana Name Service](https://www.sns.id), the
/// `.sol` domain-name protocol on Solana.
///
/// ## Key features
///
/// - **Domain hashing** ([getHashedName], [sha256]) using the exact
///   `SPL Name Service` hash prefix of the protocol
/// - **Name-account derivation** ([findDomainKey], [findNameAccountKey],
///   [deriveNameAddress]) for top-level domains, subdomains, and V1/V2
///   records, byte-identical to the SNS TypeScript SDK
/// - **Record derivations** ([findRecordV1Address], [findRecordV2Address])
///   for all 28 record keys (`url`, `SOL`, `twitter`, `IPFS`, …)
/// - **State codecs** ([getNameRegistryStateCodec],
///   [getSnsRecordHeaderCodec], [getNameValueCodec]) built with
///   `solana_kit_codecs`
/// - **Reverse lookups** ([findReverseAddress], [decodeReverseValue])
/// - **Record content** ([decodeRecordContent], [encodeRecordContent])
///
/// ## Scope
///
/// This package covers the offline side of the protocol: address
/// derivations, account-codec parsing, and content (de)serialization. RPC
/// access, instruction builders, and resolution flows (owning wallet →
/// domain list) live in the RPC layer and are out of scope here.
///
/// ## Example
///
/// ```dart
/// import 'package:solana_kit_sns/solana_kit_sns.dart';
///
/// Future<void> main() async {
///   // Domain account: bonfida.sol → Crf8hzfthWGbGbLTVCiqRqV5MVnbpHB1L9KQMd6gsinb
///   final domainKey = await findDomainKey('bonfida');
///
///   // V2 record of the SOL wallet for the domain.
///   final solRecord = await findRecordV2Address(
///     domain: 'bonfida',
///     record: SnsRecord.sol,
///   );
///
///   // Reverse-lookup account of the domain.
///   final reverse = await findReverseAddress(
///     domainAddress: domainKey.address,
///   );
///
///   print('domain: $domainKey');
///   print('SOL record: $solRecord');
///   print('reverse: $reverse');
/// }
/// ```
///
/// ### Resolve a .sol domain key
///
/// Domain keys handle top-level domains, subdomains, and V1/V2 records with the same derivation the official SDK uses.
///
/// ```dart
/// import 'package:solana_kit_sns/solana_kit_sns.dart';
///
/// Future<void> main() async {
///   final domainKey = await findDomainKey('mysite.sol');
///   print(domainKey);
/// }
/// ```
///
/// Feed the derived keys to `getNameRegistryStateCodec` or the record codecs when you need parsed owner, class, and content data.
///

/// <!-- {=docsSnsSection -->
///
/// ### Resolve a .sol domain key
///
/// Domain keys handle top-level domains, subdomains, and V1/V2 records with the same derivation the official SDK uses.
///
/// ```dart
/// import 'package:solana_kit_sns/solana_kit_sns.dart';
///
/// Future<void> main() async {
///   final domainKey = await findDomainKey('mysite.sol');
///   print(domainKey);
/// }
/// ```
///
/// Feed the derived keys to `getNameRegistryStateCodec` or the record codecs when you need parsed owner, class, and content data.
///
/// <!-- {/docsSnsSection -->
library;

// ignore_for_file: comment_references

///
// Program and protocol addresses.
///
///
///
/// ### Resolve a .sol domain key
///
/// Domain keys handle top-level domains, subdomains, and V1/V2 records with the same derivation the official SDK uses.
///
/// ```dart
/// import 'package:solana_kit_sns/solana_kit_sns.dart';
///
/// Future<void> main() async {
///   final domainKey = await findDomainKey('mysite.sol');
///   print(domainKey);
/// }
/// ```
///
/// Feed the derived keys to `getNameRegistryStateCodec` or the record codecs when you need parsed owner, class, and content data.
///
///
export 'src/domain_key.dart';
export 'src/hash.dart';
export 'src/program_address.dart';
export 'src/records.dart';
export 'src/registry.dart';
export 'src/reverse.dart';
export 'src/sha256.dart';
