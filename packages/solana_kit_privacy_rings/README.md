# solana_kit_privacy_rings

[![pub package](https://img.shields.io/pub/v/solana_kit_privacy_rings.svg)](https://pub.dev/packages/solana_kit_privacy_rings) [![docs](https://img.shields.io/badge/docs-pub.dev-0175C2.svg)](https://pub.dev/documentation/solana_kit_privacy_rings/latest/) [![website](https://img.shields.io/badge/website-solana__kit__docs-0A7EA4.svg)](https://openbudgetfun.github.io/solana_kit/reference/package-catalog#solana_kit_privacy_rings) [![CI](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml) [![coverage](https://codecov.io/gh/openbudgetfun/solana_kit/branch/main/graph/badge.svg?flag=solana_kit_privacy_rings)](https://codecov.io/gh/openbudgetfun/solana_kit?flag=solana_kit_privacy_rings)

Dart client for [Helius Solana Privacy Rings](https://www.helius.dev/docs/privacy/sdk). It builds shielded deposit, confidential transfer, and withdraw instructions on Solana Kit addresses and instructions, decrypts confidential notes with an X25519 viewing key, and calls the privacy indexer and remote prover.

Helius publishes TypeScript (`@heliuslabs/spr`) and Rust (`spr-client`) SDKs. This package is the Dart port of those clients. It is not a wrapper around them.

## What you get

- **Deposit** — a `deposit` instruction (tag 15) for native SOL and SPL or Token-2022, including the SOL interface account and per-mint SPL interface PDAs.
- **Confidential transfer and withdraw** — a single-tree `transact` instruction (tag 16). A transfer has no public settlement accounts. A withdraw adds the SOL or SPL settlement accounts.
- **Viewing-key decryption** — X25519, HKDF-SHA256, and AES-256-CTR with the `TSPP/hpke/TSPP/tx` info string. The same bytes are checked against `@noble`, which the TypeScript SDK uses.
- **Private balance read** — pages `getShieldedTransactionsByTags` and `getEncryptedUtxosByTags`, decrypts confidential slots by their output index, and reads proofless deposit amounts in the clear.
- **Indexer RPC** — typed calls for all seven privacy methods: `getEncryptedUtxosByTags`, `getShieldedTransactionsByTags`, `getShieldedTransactionsByNullifiers`, `getShieldedTransactionsBySignature`, `getMerkleProofs`, `getNonInclusionProofs`, and `getUserRecords`.
- **Remote prover** — `POST /prove/{circuit}` with `X-Sync: true`, a `429` fallback to `X-Async`, and status polling. The returned gnark proof is compressed into the `TransactProof` the instruction carries, and the reported proving-key SHA-256 must match the pin copied from the TypeScript SDK.

## What this package does not compute

Poseidon note commitments, `owner_hash`, nullifier derivation, and circuit witness assembly stay in the TypeScript and Rust SDKs. Those steps are the hash-to-field arithmetic the Groth16 witness is built from. A deposit takes the recipient `owner_hash` and view tag as arguments. A transfer or withdrawal takes a `TransactInstructionData` whose field elements you already have.

The remote prover proves a witness you post. It does not return the rest of the instruction. Attach the compressed proof with `TransactInstructionData.withProof`.

A prover that is not on a loopback address expects the attested session the TypeScript client calls `proverTee`. This package does not implement that session. `PrivacyProverClient` refuses a cleartext call to a remote prover unless `allowUnauthenticatedRemoteProver` is set. A local prover on `127.0.0.1:3001` accepts the JSON body directly.

G2 twist-subgroup membership is checked by the on-chain verifier. This client checks that G2 coordinates are canonical field elements and that G1 points satisfy `y² = x³ + 3`.

## Program addresses

Mainnet and devnet use the same addresses ([source](https://www.helius.dev/docs/privacy/addresses)):

| Account           | Address                                        |
| ----------------- | ---------------------------------------------- |
| Shielded pool     | `ring1GaLCuJnkUMVkX2JeZLTTX17wKsV4fZmPVzXANW`  |
| User registry     | `regy3WAeRXMYuMYxr5iK3Bf9Arr3PcxGxyzAddbiqDQ`  |
| State Merkle tree | `777pvSGe5LaBd9nCczvE2FXEauiwtfGJ5XRpjKyniGor` |
| SOL interface     | `CiNmas621VuyofiDSrEPfTXHKrdZuB6jMKECyNiMpLXE` |

<!-- {=packageInstallSection:"solana_kit_privacy_rings"} -->

## Installation

Install the package directly:

```yaml
dependencies:
  "solana_kit_privacy_rings": ^0.0.0
```

If your app uses several Solana Kit packages together, you can also depend on the umbrella package instead:

```bash
dart pub add solana_kit
```

Inside this monorepo, Dart workspace resolution uses the local package automatically.

<!-- {/packageInstallSection} -->

<!-- {=packageDocumentationSection:"solana_kit_privacy_rings"} -->

## Documentation

- Package page: https://pub.dev/packages/solana_kit_privacy_rings
- API reference: https://pub.dev/documentation/solana_kit_privacy_rings/latest/
- Workspace docs: https://openbudgetfun.github.io/solana_kit/
- Package catalog entry: https://openbudgetfun.github.io/solana_kit/reference/package-catalog#solana_kit_privacy_rings
- Source code: https://github.com/openbudgetfun/solana_kit/tree/main/packages/solana_kit_privacy_rings

For architecture notes, getting-started guides, and cross-package examples, start with the workspace docs site and then drill down into the package README and API reference.

<!-- {/packageDocumentationSection} -->

## Usage

```dart
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_privacy_rings/solana_kit_privacy_rings.dart';

Future<void> shieldSol({
  required Address depositor,
  required List<int> viewTag,
  required List<int> recipientOwnerHash,
}) async {
  final deposit = await depositInstruction(
    tree: stateMerkleTree,
    depositor: depositor,
    deposits: [
      AssetDeposit(
        asset: const SolDepositAsset(),
        viewTag: viewTag,
        recipientOwnerHash: recipientOwnerHash,
        amount: BigInt.from(1000000),
      ),
    ],
  );
  // Sign and send `deposit` with a Solana Kit transaction.
  print(deposit.programAddress);
}

Future<void> readBalance(List<int> viewingSecret, String viewTag) async {
  final rings = PrivacyRings(
    solanaRpcUrl: Uri.parse(
      'https://devnet.helius-rpc.com/?api-key=YOUR_API_KEY',
    ),
  );
  try {
    final report = await rings.readPrivateBalance(
      viewingKey: ViewingKey.fromBytes(viewingSecret),
      tags: [viewTag],
    );
    for (final balance in report.balances) {
      print('${balance.mint ?? balance.assetId}: ${balance.amount}');
    }
  } finally {
    rings.close();
  }
}
```

`viewTag` for the permissionless ring is the recipient wallet address as 32 bytes. `recipientOwnerHash` is the Poseidon owner hash from the shielded address; pass it in from a client that computes it.

A live indexer call needs a Helius API key. Tests in this package skip that call unless `HELIUS_PRIVACY_RINGS_LIVE=1` and `HELIUS_API_KEY` are both set, and no key is stored in the repository.
