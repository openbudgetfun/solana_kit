# solana_kit_mpl_bubblegum

[![pub package](https://img.shields.io/pub/v/solana_kit_mpl_bubblegum.svg)](https://pub.dev/packages/solana_kit_mpl_bubblegum)
[![docs](https://img.shields.io/badge/docs-pub.dev-0175C2.svg)](https://pub.dev/documentation/solana_kit_mpl_bubblegum/latest/)
[![website](https://img.shields.io/badge/website-solana__kit__docs-0A7EA4.svg)](https://openbudgetfun.github.io/solana_kit/)
[![CI](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml)
[![Coverage](https://codecov.io/gh/openbudgetfun/solana_kit/branch/main/graph/badge.svg?flag=solana_kit_mpl_bubblegum)](https://codecov.io/gh/openbudgetfun/solana_kit?flag=solana_kit_mpl_bubblegum)

mpl-bubblegum (compressed NFT) instruction builders and helpers for the Solana Kit Dart SDK.

## Features

- **V1 & V2 instruction builders** for minting, transferring, burning, and managing compressed NFTs
- **Composite helpers** for common operations (create tree, mint, transfer, burn, delegate)
- **DAS API abstraction** with Helius implementation
- **Hashing utilities** (Keccak-256) matching the on-chain program's hashing logic
- **Merkle tree** construction and proof verification
- **PDA derivation** for tree authority, leaf asset ID, and bubblegum signer

## Installation

<!-- {=packageInstallSection:"solana_kit_mpl_bubblegum"} -->

## Installation

Install the package directly:

```yaml
dependencies:
  "solana_kit_mpl_bubblegum": ^0.3.0
```

If your app uses several Solana Kit packages together, you can also depend on the umbrella package instead:

```bash
dart pub add solana_kit
```

Inside this monorepo, Dart workspace resolution uses the local package automatically.

<!-- {/packageInstallSection} -->

## Usage

### Creating a Tree

```dart
import 'package:solana_kit_mpl_bubblegum/solana_kit_mpl_bubblegum.dart';

// Create a V1 tree
final plan = getCreateTreeInstructionPlan(
  CreateTreeInput(
    merkleTree: merkleTreeAddress,
    payer: payerAddress,
    treeCreator: payerAddress,
    maxDepth: 14,
    maxBufferSize: 64,
  ),
);

// Create a V2 tree
final v2Plan = getCreateTreeV2InstructionPlan(
  CreateTreeV2Input(
    merkleTree: merkleTreeAddress,
    payer: payerAddress,
    treeCreator: payerAddress,
    maxDepth: 14,
    maxBufferSize: 64,
    isPublic: true,
  ),
);
```

### Minting a Compressed NFT

```dart
// Mint a V1 NFT
final plan = getMintV1InstructionPlan(
  MintV1Input(
    merkleTree: treeAddress,
    leafOwner: ownerAddress,
    leafDelegate: ownerAddress,
    payer: payerAddress,
    treeDelegate: treeDelegateAddress,
    name: 'My NFT',
    uri: 'https://example.com/metadata.json',
    creators: [
      Creator(address: creatorAddress, verified: false, share: 100),
    ],
  ),
);

// Mint a V2 NFT
final v2Plan = getMintV2InstructionPlan(
  MintV2Input(
    merkleTree: treeAddress,
    leafOwner: ownerAddress,
    leafDelegate: ownerAddress,
    payer: payerAddress,
    treeDelegate: treeDelegateAddress,
    collectionAuthority: collectionAuthorityAddress,
    name: 'My V2 NFT',
    uri: 'https://example.com/metadata.json',
    collection: collectionAddress,
  ),
);

// Mint into a collection
final collectionPlan = getMintToCollectionV1InstructionPlan(
  MintToCollectionV1Input(
    merkleTree: treeAddress,
    leafOwner: ownerAddress,
    leafDelegate: ownerAddress,
    payer: payerAddress,
    treeDelegate: treeDelegateAddress,
    collectionAuthority: collectionAuthorityAddress,
    collectionAuthorityRecordPda: recordPda,
    collectionMint: collectionMintAddress,
    collectionMetadata: metadataAddress,
    editionAccount: editionAddress,
    name: 'Collection NFT',
    uri: 'https://example.com/metadata.json',
  ),
);
```

### Transferring and Burning

```dart
// Transfer
final transferPlan = getTransferInstructionPlan(
  TransferInput(
    root: proof.root,
    dataHash: proof.dataHash,
    creatorHash: proof.creatorHash,
    nonce: proof.nonce,
    index: proof.index,
    leafOwner: ownerAddress,
    leafDelegate: ownerAddress,
    newLeafOwner: newOwnerAddress,
    merkleTree: treeAddress,
  ),
);

// Burn
final burnPlan = getBurnInstructionPlan(
  BurnInput(
    root: proof.root,
    dataHash: proof.dataHash,
    creatorHash: proof.creatorHash,
    nonce: proof.nonce,
    index: proof.index,
    leafOwner: ownerAddress,
    leafDelegate: ownerAddress,
    merkleTree: treeAddress,
  ),
);
```

### DAS API

```dart
// Using the Helius DAS client
final client = HeliusDasClient(
  rpcUrl: 'https://mainnet.helius-rpc.com/?api-key=YOUR_API_KEY',
);

final asset = await client.getAsset(assetId);
final proof = await client.getAssetProof(assetId);

// Get complete asset with proof
final assetWithProof = await getAssetWithProof(
  dasClient: client,
  assetId: assetId,
);
```

### Hashing Utilities

```dart
// Hash a V1 leaf
final v1Hash = hashLeafV1(
  leafAssetId: leafAssetId,
  owner: ownerAddress,
  delegate: delegateAddress,
  leafIndex: 0,
  metadataHash: metadataHash,
);

// Hash a V2 leaf
final v2Hash = hashLeafV2(
  leafAssetId: leafAssetId,
  owner: ownerAddress,
  leafIndex: 0,
  metadataHashV2: metadataHash,
  flags: LeafSchemaV2Flags.hasCollection,
  collection: collectionAddress,
);
```

## Program Addresses

```dart
// MPL Bubblegum program
const mplBubblegumProgramAddress = 'BGUMAp9Gph7G9Jn2tU58R5L2qPG1Mj9HP7G3G7VYV2Ma';

// Token Metadata program
const tokenMetadataProgramAddress = 'metaqbxxUerdq28cj1RbAWkYQm3ybzjb6a8bt518x1s';
```

## License

MIT
