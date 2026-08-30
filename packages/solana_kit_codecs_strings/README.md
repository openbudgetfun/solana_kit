# solana_kit_codecs_strings

[![pub package](https://img.shields.io/pub/v/solana_kit_codecs_strings.svg)](https://pub.dev/packages/solana_kit_codecs_strings) [![docs](https://img.shields.io/badge/docs-pub.dev-0175C2.svg)](https://pub.dev/documentation/solana_kit_codecs_strings/latest/) [![website](https://img.shields.io/badge/website-solana__kit__docs-0A7EA4.svg)](https://openbudgetfun.github.io/solana_kit/reference/package-catalog#solana_kit_codecs_strings) [![CI](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml) [![coverage](https://codecov.io/gh/openbudgetfun/solana_kit/branch/main/graph/badge.svg?flag=solana_kit_codecs_strings)](https://codecov.io/gh/openbudgetfun/solana_kit?flag=solana_kit_codecs_strings)

String and base-encoding codecs for Solana binary data in Dart. A port of [`@solana/codecs-strings`](https://github.com/anza-xyz/kit/tree/main/packages/codecs-strings) from the Solana TypeScript SDK.

<!-- {=packageInstallSection:"solana_kit_codecs_strings"} -->

## Installation

Install the package directly:

```yaml
dependencies:
  "solana_kit_codecs_strings": ^0.9.0
```

If your app uses several Solana Kit packages together, you can also depend on the umbrella package instead:

```bash
dart pub add solana_kit
```

Inside this monorepo, Dart workspace resolution uses the local package automatically.

<!-- {/packageInstallSection} -->

<!-- {=packageDocumentationSection:"solana_kit_codecs_strings"} -->

## Documentation

- Package page: https://pub.dev/packages/solana_kit_codecs_strings
- API reference: https://pub.dev/documentation/solana_kit_codecs_strings/latest/
- Workspace docs: https://openbudgetfun.github.io/solana_kit/
- Package catalog entry: https://openbudgetfun.github.io/solana_kit/reference/package-catalog#solana_kit_codecs_strings
- Source code: https://github.com/openbudgetfun/solana_kit/tree/main/packages/solana_kit_codecs_strings

For architecture notes, getting-started guides, and cross-package examples, start with the workspace docs site and then drill down into the package README and API reference.

<!-- {/packageDocumentationSection} -->

<!-- {=docsStringCodecSection} -->

## Encode base58 and UTF-8 strings

Use the string codecs for base58/base64/base16 conversions plus UTF-8 handling when a Solana API crosses between bytes and text.

```dart
import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';

void main() {
  final codec = getBase58Codec();

  final encoded = codec.encode('11111111111111111111111111111111');
  final decoded = codec.decode(encoded);

  print(decoded);
}
```

These codecs are especially useful for addresses, signatures, blockhashes, and other values that appear as base-encoded strings at API boundaries.

For UTF-8 specifically, `getUtf8Codec()` preserves embedded null characters and rejects malformed byte sequences, so decoded values retain their exact text semantics.

<!-- {/docsStringCodecSection} -->

## Codec examples

Base58 (Solana addresses, signatures, transaction hashes):

```dart
import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';

void main() {
  final base58 = getBase58Codec();
  final addressBytes = base58.encode('TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA');
  final decoded = base58.decode(addressBytes);
  print(decoded); // 'TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA'
}
```

Base64 (transaction payloads, account data):

```dart
import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';

void main() {
  final base64 = getBase64Codec();
  final encoded = base64.encode('SGVsbG8gU29sYW5h');
  final decoded = base64.decode(encoded);
  print(decoded); // 'SGVsbG8gU29sYW5h'
}
```

UTF-8 with a length prefix (for instruction layouts):

```dart
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

void main() {
  final utf8 = getUtf8Codec();
  final sizedUtf8 = addCodecSizePrefix(utf8, getU32Codec());
  final encoded = sizedUtf8.encode('memo text');
  // First 4 bytes: length as u32, remaining bytes: UTF-8 data
  print(encoded.length);
}
```

Base10 (decimal string amounts) and base16 (hex debugging) work the same way. For custom alphabets, use `getBaseXCodec` or `getBaseXResliceCodec`.

## Key APIs

| Function               | Alphabet             | Typical use                          |
| ---------------------- | -------------------- | ------------------------------------ |
| `getBase58Codec`       | Base58 (Bitcoin)     | Addresses, signatures, blockhashes   |
| `getBase64Codec`       | Base64 (RFC 4648)    | Transaction payloads, account data   |
| `getBase16Codec`       | 0-9, a-f             | Debugging, hex dumps                 |
| `getBase10Codec`       | 0-9                  | Decimal string amounts               |
| `getUtf8Codec`         | UTF-8                | String data in instruction layouts   |
| `getBaseXCodec`        | Custom alphabet      | Arbitrary base encodings             |
| `getBaseXResliceCodec` | Custom, bit-resliced | Non-power-of-2 alphabets like base58 |

<!-- {=packageExampleSection|replace:"__PACKAGE__":"solana_kit_codecs_strings"|replace:"__EXAMPLE_PATH__":"example/main.dart"|replace:"__IMPORT_PATH__":"package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart"} -->

## Example

Use [`example/main.dart`](./example/main.dart) as a runnable starting point for `solana_kit_codecs_strings`.

- Import path: `package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart`
- This section is centrally maintained with `mdt` to keep package guidance aligned.
- After updating shared docs templates, run `docs:update` from the repo root.

## Maintenance

- Validate docs in CI and locally with `docs:check`.
- Keep examples focused on one workflow and reference package README sections for deeper API details.

<!-- {/packageExampleSection} -->
