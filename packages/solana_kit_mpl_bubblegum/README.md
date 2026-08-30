# solana_kit_mpl_bubblegum

[![pub package](https://img.shields.io/pub/v/solana_kit_mpl_bubblegum.svg)](https://pub.dev/packages/solana_kit_mpl_bubblegum) [![docs](https://img.shields.io/badge/docs-pub.dev-0175C2.svg)](https://pub.dev/documentation/solana_kit_mpl_bubblegum/latest/) [![website](https://img.shields.io/badge/website-solana__kit__docs-0A7EA4.svg)](https://openbudgetfun.github.io/solana_kit/reference/package-catalog#solana_kit_mpl_bubblegum) [![CI](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml) [![Coverage](https://codecov.io/gh/openbudgetfun/solana_kit/branch/main/graph/badge.svg?flag=solana_kit_mpl_bubblegum)](https://codecov.io/gh/openbudgetfun/solana_kit?flag=solana_kit_mpl_bubblegum)

Compressed NFT instruction builders, DAS API helpers, hashing, Merkle tree utilities, and PDA derivation for the Solana Kit Dart SDK.

<!-- {=packageInstallSection:"solana_kit_mpl_bubblegum"} -->

## Installation

Install the package directly:

```yaml
dependencies:
  "solana_kit_mpl_bubblegum": ^0.5.1
```

If your app uses several Solana Kit packages together, you can also depend on the umbrella package instead:

```bash
dart pub add solana_kit
```

Inside this monorepo, Dart workspace resolution uses the local package automatically.

<!-- {/packageInstallSection} -->

## Usage

Create a V1 tree for compressed NFTs:

```dart
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_mpl_bubblegum/solana_kit_mpl_bubblegum.dart';

void main() {
  const merkleTree = Address('11111111111111111111111111111111');
  const payer = Address('11111111111111111111111111111112');

  final input = CreateTreeInput(
    merkleTree: merkleTree,
    payer: payer,
    treeCreator: payer,
    maxDepth: 14,
    maxBufferSize: 64,
  );
  final plan = getCreateTreeInstructionPlan(input);
  print(plan.kind);
}
```

Mint a compressed NFT with the V1 instruction plan:

```dart
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_mpl_bubblegum/solana_kit_mpl_bubblegum.dart';

void main() {
  const treeAddress = Address('11111111111111111111111111111111');
  const ownerAddress = Address('11111111111111111111111111111112');
  const payerAddress = Address('11111111111111111111111111111113');
  const treeDelegateAddress = Address('11111111111111111111111111111114');

  final input = MintV1Input(
    merkleTree: treeAddress,
    leafOwner: ownerAddress,
    leafDelegate: ownerAddress,
    payer: payerAddress,
    treeDelegate: treeDelegateAddress,
    name: 'My NFT',
    uri: 'https://example.com/metadata.json',
    creators: [Creator(address: payerAddress, verified: false, share: 100)],
  );
  final plan = getMintV1InstructionPlan(input);
  print(plan.kind);
}
```

Derive PDA addresses for tree authority and the bubblegum signer:

```dart
import 'package:solana_kit_mpl_bubblegum/solana_kit_mpl_bubblegum.dart';

void main() {
  print(mplBubblegumProgramAddress);
  print(tokenMetadataProgramAddress);
}
```

Look up a compressed NFT error by enum or code:

```dart
import 'package:solana_kit_mpl_bubblegum/solana_kit_mpl_bubblegum.dart';

void main() {
  final message = getMplBubblegumErrorMessage(
    MplBubblegumError.collectionMustHaveRoyaltiesPlugin,
  );
  print(message);

  if (isMplBubblegumError(0x17a9)) {
    print('matched bubblegum error');
  }
}
```

## Key APIs

- `getCreateTreeInstructionPlan`, `getCreateTreeV2InstructionPlan`, `getMintV1InstructionPlan`, `getMintV2InstructionPlan`, `getMintToCollectionV1InstructionPlan`, `getTransferInstructionPlan`, `getBurnInstructionPlan`, `getDelegateInstructionPlan`
- `hashLeafV1`, `hashLeafV2`, `bubblegumHash` for Keccak-256 hashing
- `findTreeAuthorityPda`, `findLeafAssetIdV2Pda`, `findBubblegumSignerPda` for PDA derivation
- `HeliusDasClient`, `getAssetWithProof` for DAS API access
- `mplBubblegumProgramAddress`, `tokenMetadataProgramAddress` constants
- `isMplBubblegumError`, `getMplBubblegumErrorMessage` for error handling

## License

MIT
