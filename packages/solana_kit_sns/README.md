# solana_kit_sns

[![pub package](https://img.shields.io/pub/v/solana_kit_sns.svg)](https://pub.dev/packages/solana_kit_sns) [![docs](https://img.shields.io/badge/docs-pub.dev-0175C2.svg)](https://pub.dev/documentation/solana_kit_sns/latest/) [![website](https://img.shields.io/badge/website-solana__kit__docs-0A7EA4.svg)](https://openbudgetfun.github.io/solana_kit/reference/package-catalog#solana_kit_sns) [![CI](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml) [![coverage](https://codecov.io/gh/openbudgetfun/solana_kit/branch/main/graph/badge.svg?flag=solana_kit_sns)](https://codecov.io/gh/openbudgetfun/solana_kit?flag=solana_kit_sns)

Solana Name Service (`.sol` domains) client for the [Solana Kit](https://github.com/openbudgetfun/solana_kit) Dart SDK.

## What you get

- **Domain hashing** — `getHashedName` applies the protocol's exact `SPL Name Service` hash prefix (plus a dependency-free SHA-256), matching `getHashedNameSync` in the SNS TypeScript SDK
- **Domain key derivation** — `findDomainKey` derives top-level domains, subdomains, and V1/V2 record accounts with the seed order `[hash, class, parent]`
- **Record keys** — `findRecordV1Address` / `findRecordV2Address` for all 28 record identifiers (`url`, `SOL`, `twitter`, `IPFS`, `ETH`, …)
- **State codecs** — `getNameRegistryStateCodec` parses the 96-byte name-registry header (`parentName` / `owner` / `class` + trailing data); `getSnsRecordHeaderCodec` and `SnsRecordV2` parse SNS-IP 1 V2 record payloads, including staleness and Right-of-Association identifiers
- **Reverse lookups** — `findReverseAddress` (plain and subdomain variants) and reverse-value (de)serialization
- **Record content** — encode/decode of UTF-8, Solana address, and `0x`-prefixed EVM record content

## Installation

<!-- {=packageInstallSection:"solana_kit_sns"} -->

## Installation

Install the package directly:

```yaml
dependencies:
  "solana_kit_sns": ^
```

If your app uses several Solana Kit packages together, you can also depend on the umbrella package instead:

```bash
dart pub add solana_kit
```

Inside this monorepo, Dart workspace resolution uses the local package automatically.

<!-- {/packageInstallSection} -->

## Usage

### Deriving domain and record addresses

```dart
import 'package:solana_kit_sns/solana_kit_sns.dart';

Future<void> main() async {
  // bonfida.sol → Crf8hzfthWGbGbLTVCiqRqV5MVnbpHB1L9KQMd6gsinb.
  // The TLD is trimmed: pass "bonfida", not "bonfida.sol".
  final domainKey = await findDomainKey('bonfida');

  // dex.bonfida.sol → subdomain derived under its parent domain.
  final subKey = await findDomainKey('dex.bonfida');

  // V2 SOL record (SNS-IP 1) of bonfida.sol.
  final solRecord = await findRecordV2Address(
    domain: 'bonfida',
    record: SnsRecord.sol,
  );

  // V1 url record of bonfida.sol.
  final urlRecordV1 = await findRecordV1Address(
    domain: 'bonfida',
    record: SnsRecord.url,
  );
}
```

### Resolving a record payload

Record V2 accounts are name registries whose data section begins after the 96-byte registry header. Decode header, validation identifiers, and content:

```dart
import 'package:solana_kit_sns/solana_kit_sns.dart';

void example(Uint8List accountData) {
  final record = SnsRecordV2.deserialize(accountData);
  print(record.header.stalenessValidation); // SnsValidation.solana, …
  print(record.stalenessId.length);

  // Decode the content to a human-readable value for the matching record
  // type.
  print(
    decodeRecordContent(content: record.content, record: SnsRecord.sol),
  ); // the wallet address stored in the SOL record
  print(decodeRecordContent(content: record.content, record: SnsRecord.url));
}
```

### Reverse lookups

```dart
Future<void> example() async {
  // Reverse account that stores the name for a domain account.
  final reverseAddress = await findReverseAddressForDomain('bonfida');

  // Decode the stored name (subdomain values carry a NUL marker).
  // final name = decodeReverseValue(accountData, trimLeadingNullByte: true);
}
```

### Parsing name registries

```dart
final registry = getNameRegistryStateCodec().decode(accountData);
print(registry.owner);        // current domain owner
print(registry.parentName);   // parent domain (zero address for TLDs)
print(registry.registryClass);// class key (zero when unset)
```

## Key APIs

| API                                                         | Description                                                                  |
| ----------------------------------------------------------- | ---------------------------------------------------------------------------- |
| `findDomainKey(domain, {record})`                           | Derives a domain, subdomain, or V1/V2 record address from a TLD-trimmed name |
| `findNameAccountKey(hashed, {classAddress, parentAddress})` | Derives a name-account PDA from a hash with `[hash, class, parent]` seeds    |
| `getHashedName(name)` / `sha256(data)`                      | SNS name hashing with the `SPL Name Service` prefix                          |
| `findRecordV1Address` / `findRecordV2Address`               | V1 and SNS-IP 1 V2 record account derivation                                 |
| `getSnsRecordHeaderCodec` / `SnsRecordV2.deserialize`       | V2 record header and payload decoding                                        |
| `decodeRecordContent` / `encodeRecordContent`               | UTF-8, Solana, and EVM record content                                        |
| `getNameRegistryStateCodec`                                 | 96-byte name-registry header + data parsing                                  |
| `findReverseAddress` / `findReverseAddressForDomain`        | Reverse-lookup account derivation                                            |
| `decodeReverseValue` / `encodeReverseValue`                 | Reverse-lookup value (de)serialization                                       |
| `nameProgramAddressObject`, `snsRootDomainAddressObject`, … | Protocol address constants from the TS SDK                                   |

## Upstream reference

Constants, hashing, and derivation algorithms mirror [SolanaNameService/sns-sdk](https://github.com/SolanaNameService/sns-sdk) (`js-kit` plus the `getSnsDomainKeySync` helpers and `RecordState` / `RegistryState` codecs of `js`), and the V2 record derivation matches the `getRecordKey` primitive published in [`@bonfida/sns-records`](https://www.npmjs.com/package/@bonfida/sns-records). Derivation vectors in the test suite are the TypeScript SDK's own `derivation.test.ts` expectations, cross-computed with `@solana/web3.js`.

## Scope

This package covers the offline side of the protocol: address derivation, account-codec parsing, and record-content (de)serialization. It currently does **not** include:

- RPC access or account fetching (use `solana_kit_rpc` and feed raw account data into the codecs here)
- Name-program or SNS-registrar instruction builders
- Signature verification for V2 records (`verifyStaleness` / `verifyRightOfAssociation`)
- bech32 (Injective), punycode (CNAME/TXT), and raw IP (`A` / `AAAA`) content decoding, and V1 record payload parsing
