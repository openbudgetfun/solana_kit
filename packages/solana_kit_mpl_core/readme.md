# solana_kit_mpl_core

[![pub package](https://img.shields.io/pub/v/solana_kit_mpl_core.svg)](https://pub.dev/packages/solana_kit_mpl_core) [![docs](https://img.shields.io/badge/docs-pub.dev-0175C2.svg)](https://pub.dev/documentation/solana_kit_mpl_core/latest/) [![website](https://img.shields.io/badge/website-solana__kit__docs-0A7EA4.svg)](https://openbudgetfun.github.io/solana_kit/reference/package-catalog#solana_kit_mpl_core) [![CI](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml) [![coverage](https://codecov.io/gh/openbudgetfun/solana_kit/branch/main/graph/badge.svg?flag=solana_kit_mpl_core)](https://codecov.io/gh/openbudgetfun/solana_kit?flag=solana_kit_mpl_core)

Metaplex Core program client for the Solana Kit Dart SDK: instruction builders, account codecs, error helpers, and PDA derivations for the [Metaplex Core](https://github.com/metaplex-foundation/mpl-core) program, a single-program standard for non-fungible assets with pluggable metadata.

## What you get

- **Instruction builders** for all 42 core instructions: creating assets and collections, minting, transferring, burning, plugin management (royalties, attributes, external plugin adapters), group/collection operations, and delegation
- **Account codecs** for `AssetV1`, `CollectionV1`, plugin headers, plugin registries, oracle, and external plugin adapter records
- **PDA derivations** for the asset signer, preconfigured plugin accounts (program, asset, collection, owner, and recipient scopes), dynamic extra accounts, and oracle accounts
- **Error helpers** for all 57 program errors
- **Program parsing** via the generated identification and parsing entry points

## Usage

### Derive the asset signer PDA

```dart
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_mpl_core/solana_kit_mpl_core.dart';

Future<void> main() async {
  const assetAddress = Address(
    'EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v',
  );

  final (assetSigner, bump) = await findAssetSignerPda(asset: assetAddress);
  print('asset signer PDA $assetSigner derived with bump $bump');
}
```

### Create an asset

```dart
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_mpl_core/solana_kit_mpl_core.dart';

Future<void> main() async {
  const assetAddress = Address(
    'EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v',
  );
  const collectionAddress = Address(
    'BCwHRRbWToKMcDPWnnW4n4YimYw9qVo7jVXNiZQopC3B',
  );
  const authorityAddress = Address(
    'Fgae9ichv1MpfL3tnr9jRCjpUy1E3J6matR6EBy4MasF',
  );
  const payerAddress = Address(
    'Fgae9ichv1MpfL3tnr9jRCjpUy1E3J6matR6EBy4MasF',
  );
  const ownerAddress = Address(
    'Fgae9ichv1MpfL3tnr9jRCjpUy1E3J6matR6EBy4MasF',
  );
  const systemProgram = Address('11111111111111111111111111111111');

  final instruction = getCreateV1Instruction(
    programAddress: mplCoreProgramAddressObject,
    asset: assetAddress,
    collection: collectionAddress,
    authority: authorityAddress,
    payer: payerAddress,
    owner: ownerAddress,
    updateAuthority: ownerAddress,
    systemProgram: systemProgram,
    dataState: DataState.accountState,
    name: 'My Asset',
    uri: 'https://example.com/asset.json',
    plugins: null,
  );
  print('instruction with ${instruction.accounts!.length} accounts');
}
```

## Key APIs

- `findAssetSignerPda`, `findPreconfiguredProgramPda`, `findPreconfiguredAssetPda`, `findPreconfiguredCollectionPda`, `findPreconfiguredOwnerPda`, `findPreconfiguredRecipientPda`, `findOracleAccount`, `deriveExtraAccountAddress`
- `getCreateV1Instruction`, `getCreateCollectionV1Instruction`, `getTransferV1Instruction`, `getUpdateV1Instruction`, and the rest of the generated builders
- `parseMplCoreInstruction`, `identifyMplCoreInstruction`
- `getMplCoreErrorMessage`, `MplCoreError`

## Reference

Generated with `codama-renderers-dart` from the metaplex-foundation / mpl-core shank IDL, mirroring the upstream TypeScript client. PDA seeds follow the on-chain Rust (`processor/execute.rs`, external plugin adapter prefixes) and were cross-verified against `@solana/web3.js` derivations.
