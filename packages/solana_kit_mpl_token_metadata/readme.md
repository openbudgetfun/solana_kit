# solana_kit_mpl_token_metadata

[![pub package](https://img.shields.io/pub/v/solana_kit_mpl_token_metadata.svg)](https://pub.dev/packages/solana_kit_mpl_token_metadata) [![docs](https://img.shields.io/badge/docs-pub.dev-0175C2.svg)](https://pub.dev/documentation/solana_kit_mpl_token_metadata/latest/) [![website](https://img.shields.io/badge/website-solana__kit__docs-0A7EA4.svg)](https://openbudgetfun.github.io/solana_kit/reference/package-catalog#solana_kit_mpl_token_metadata) [![CI](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml) [![coverage](https://codecov.io/gh/openbudgetfun/solana_kit/branch/main/graph/badge.svg?flag=solana_kit_mpl_token_metadata)](https://codecov.io/gh/openbudgetfun/solana_kit?flag=solana_kit_mpl_token_metadata)

Token Metadata program client for the Solana Kit Dart SDK: instruction builders, account codecs, error helpers, and PDA derivations for the [Metaplex Token Metadata](https://github.com/metaplex-foundation/mpl-token-metadata) program, which manages the metadata of mint accounts on Solana.

## What you get

- **Instruction builders** for creating and updating metadata, master editions, delegates, collection verification, and programmable assets — 58 instructions from the shank IDL, including `createMetadataAccountV3`, `updateMetadataAccountV2`, `verifyCollection`, `setAndVerifyCollection`, and the V1 `create`, `update`, `delegate`, and `burn` family
- **Account codecs** for metadata, master editions, edition markers, delegate records, token records, and collection authorities
- **PDA derivations** matching the on-chain program's seeds exactly: metadata, master edition, edition markers (V1 and V2), collection and use authority records, token records, metadata delegate records, holder delegate records, and program-as-burner
- **Error helpers** with all 203 program error codes
- **Instruction parsing** via `parseMplTokenMetadataInstruction` and `identifyMplTokenMetadataInstruction`

<!-- {=packageInstallSection:"solana_kit_mpl_token_metadata"} -->

## Installation

Install the package directly:

```yaml
dependencies:
  "solana_kit_mpl_token_metadata": ^
```

If your app uses several Solana Kit packages together, you can also depend on the umbrella package instead:

```bash
dart pub add solana_kit
```

Inside this monorepo, Dart workspace resolution uses the local package automatically.

<!-- {/packageInstallSection} -->

:::

## Installation

Install the package directly:

```yaml
dependencies:
  "solana_kit_mpl_token_metadata": ^
```

If your app uses several Solana Kit packages together, you can also depend on the umbrella package instead:

```bash
dart pub add solana_kit
```

Inside this monorepo, Dart workspace resolution uses the local package automatically.

## Documentation

- Package page: https://pub.dev/packages/solana_kit_mpl_token_metadata
- API reference: https://pub.dev/documentation/solana_kit_mpl_token_metadata/latest/
- Workspace docs: https://openbudgetfun.github.io/solana_kit/
- Package catalog entry: https://openbudgetfun.github.io/solana_kit/reference/package-catalog#solana_kit_mpl_token_metadata
- Source code: https://github.com/openbudgetfun/solana_kit/tree/main/packages/solana_kit_mpl_token_metadata

For architecture notes, getting-started guides, and cross-package examples, start with the workspace docs site and then drill down into the package README and API reference.

<!-- {/packageDocumentationSection} -->

## Usage

<!-- {=docsMplTokenMetadataSection} -->

### Derive the metadata PDA

Token metadata lives in a PDA derived from the mint. Hero derivation helpers mirror the on-chain seed structure exactly.

```dart
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_mpl_token_metadata/solana_kit_mpl_token_metadata.dart';

Future<void> main() async {
  final mint = Address('So11111111111111111111111111111111111111111');
  final (metadata, bump) = await findMetadataPda(mint: mint);

  print(metadata);
  print(bump);
}
```

Instruction builders such as `getCreateMetadataAccountV3Instruction`, `getUpdateMetadataAccountV2Instruction`, and `getVerifyCollectionInstruction` take explicit program and account addresses, keeping fee payment, signing, and account ordering visible in your transaction messages.

<!-- {/docsMplTokenMetadataSection} -->

## Key APIs

- `findMetadataPda`, `findMasterEditionPda`, `findEditionMarkerPda`, `findEditionMarkerV2Pda`, `findCollectionAuthorityRecordPda`, `findUseAuthorityRecordPda`, `findTokenRecordPda`, `findMetadataDelegateRecordPda`, `findHolderDelegateRecordPda`, `findProgramAsBurnerPda`
- `getCreateMetadataAccountV3Instruction`, `getUpdateMetadataAccountV2Instruction`, `getVerifyCollectionInstruction`, and the rest of the generated builders
- `parseMplTokenMetadataInstruction`, `identifyMplTokenMetadataInstruction`
- `getMplTokenMetadataErrorMessage`, `MplTokenMetadataError`

## Reference

Generated with `codama-renderers-dart` from the metaplex-foundation / mpl-token-metadata shank IDL (program `metaqbxxUerdq28cj1RbAWkYQm3ybzjb6a8bt518x1s`), mirroring the upstream TypeScript client, including the `newUpdateAuthority` argument naming used by the official SDK.
