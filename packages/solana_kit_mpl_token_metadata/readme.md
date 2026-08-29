# solana_kit_mpl_token_metadata

[![pub package](https://img.shields.io/pub/v/solana_kit_mpl_token_metadata.svg)](https://pub.dev/packages/solana_kit_mpl_token_metadata) [![docs](https://img.shields.io/badge/docs-pub.dev-0175C2.svg)](https://pub.dev/documentation/solana_kit_mpl_token_metadata/latest/) [![website](https://img.shields.io/badge/website-solana__kit__docs-0A7EA4.svg)](https://openbudgetfun.github.io/solana_kit/reference/package-catalog#solana_kit_mpl_token_metadata) [![CI](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml) [![coverage](https://codecov.io/gh/openbudgetfun/solana_kit/branch/main/graph/badge.svg?flag=solana_kit_mpl_token_metadata)](https://codecov.io/gh/openbudgetfun/solana_kit?flag=solana_kit_mpl_token_metadata)

Token Metadata program client for the Solana Kit Dart SDK: instruction builders, account codecs, error helpers, and PDA derivations for the [Metaplex Token Metadata](https://github.com/metaplex-foundation/mpl-token-metadata) program, which manages the metadata of mint accounts on Solana.

## What you get

- **Instruction builders** for creating and updating metadata, master editions, delegates, collection verification, and programmable assets — 58 instructions from the shank IDL, including `createMetadataAccountV3`, `updateMetadataAccountV2`, `verifyCollection`, `setAndVerifyCollection`, and the V1 `create`, `update`, `delegate`, and `burn` family
- **Account codecs** for metadata, master editions, edition markers, delegate records, token records, and collection authorities
- **PDA derivations** matching the on-chain program's seeds exactly: metadata, master edition, edition markers (V1 and V2), collection and use authority records, token records, metadata delegate records, holder delegate records, and program-as-burner
- **Error helpers** with all 203 program error codes
- **Instruction parsing** via `parseMplTokenMetadataInstruction` and `identifyMplTokenMetadataInstruction`

## Usage

### Derive the metadata PDA

```dart
final (metadata, bump) = await findMetadataPda(mint: mint);
```

### Create metadata for a mint

```dart
final instruction = getCreateMetadataAccountV3Instruction(
  programAddress: mplTokenMetadataProgramAddressObject,
  metadata: await findMetadataPda(mint: mint),
  masterEdition: await findMasterEditionPda(mint: mint),
  mint: mint,
  mintAuthority: payerAddress,
  payer: payerAddress,
  updateAuthority: payerAddress,
  data: DataV2(
    name: 'My NFT',
    symbol: 'NFT',
    uri: 'https://example.com/nft.json',
    sellerFeeBasisPoints: 500,
    creators: null,
    collection: null,
    uses: null,
  ),
  isMutable: true,
  collectionDetails: null,
);
```

## Key APIs

- `findMetadataPda`, `findMasterEditionPda`, `findEditionMarkerPda`, `findEditionMarkerV2Pda`, `findCollectionAuthorityRecordPda`, `findUseAuthorityRecordPda`, `findTokenRecordPda`, `findMetadataDelegateRecordPda`, `findHolderDelegateRecordPda`, `findProgramAsBurnerPda`
- `getCreateMetadataAccountV3Instruction`, `getUpdateMetadataAccountV2Instruction`, `getVerifyCollectionInstruction`, and the rest of the generated builders
- `parseMplTokenMetadataInstruction`, `identifyMplTokenMetadataInstruction`
- `getMplTokenMetadataErrorMessage`, `MplTokenMetadataError`

## Reference

Generated with `codama-renderers-dart` from the metaplex-foundation / mpl-token-metadata shank IDL (program `metaqbxxUerdq28cj1RbAWkYQm3ybzjb6a8bt518x1s`), mirroring the upstream TypeScript client, including the `newUpdateAuthority` argument naming used by the official SDK.
