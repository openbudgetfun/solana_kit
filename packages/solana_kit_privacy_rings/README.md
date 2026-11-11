# solana_kit_privacy_rings

[![pub package](https://img.shields.io/pub/v/solana_kit_privacy_rings.svg)](https://pub.dev/packages/solana_kit_privacy_rings) [![docs](https://img.shields.io/badge/docs-pub.dev-0175C2.svg)](https://pub.dev/documentation/solana_kit_privacy_rings/latest/) [![website](https://img.shields.io/badge/website-solana__kit__docs-0A7EA4.svg)](https://openbudgetfun.github.io/solana_kit/reference/package-catalog#solana_kit_privacy_rings) [![CI](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml) [![coverage](https://codecov.io/gh/openbudgetfun/solana_kit/branch/main/graph/badge.svg?flag=solana_kit_privacy_rings)](https://codecov.io/gh/openbudgetfun/solana_kit?flag=solana_kit_privacy_rings)

Dart client for [Helius Solana Privacy Rings](https://www.helius.dev/docs/privacy/sdk). It builds shielded deposit, confidential transfer, and withdraw instructions on Solana Kit addresses and instructions, decrypts confidential notes with an X25519 viewing key, and calls the privacy indexer and remote prover.

Helius publishes TypeScript (`@heliuslabs/spr`) and Rust (`spr-client`) SDKs. This package is the Dart port of those clients. It is not a wrapper around them.

## What you get

- **Deposit** — a `deposit` instruction (tag 15) for native SOL and SPL or Token-2022, including the SOL interface account and per-mint SPL interface PDAs.
- **Confidential transfer and withdraw** — a `transact` instruction (tag 16) for one or two input trees and up to 32 public settlement legs. Tag 16 accepts a confidential signer or confidential EdDSA selector, including the cached forms, and appends the cache account tail. Ring selectors are rejected.
- **Poseidon witness** — circom x5 Poseidon over the BN254 scalar field, `owner_hash`, nullifier derivation, output blinding, UTXO commitments, the transfer public-input hash, and `confidentialTransferWitness`, which builds the gnark witness from notes and Merkle paths. The rebuilt `transfer-2x2` witness matches the published fixture.
- **Viewing-key decryption** — X25519, HKDF-SHA256, and AES-256-CTR with the `TSPP/hpke/TSPP/tx` info string. The same bytes are checked against `@noble`, which the TypeScript SDK uses.
- **Private balance read** — pages `getShieldedTransactionsByTags` and `getEncryptedUtxosByTags`, decrypts confidential slots by their output index, and reads proofless deposit amounts in the clear. A leaf is counted once. `subtractNullifiedNotes` drops a leaf whose derived nullifier is already in history, and `retainNonInclusion` keeps a leaf whose nullifier has a non-inclusion proof.
- **Indexer RPC** — typed calls for the privacy methods: `getEncryptedUtxosByTags`, `getShieldedTransactionsByTags`, `getShieldedTransactionsByNullifiers`, `getShieldedTransactionsBySignature`, `getMerkleProofs`, `getNonInclusionProofs`, `getUserRecords`, and `getNullifierQueueElements`. `collectPages` walks those pages and refuses a history that still has a token after the page limit. `spentNullifiers` returns the sorted unique nullifiers. `PrivacyRingsCluster` and `localIndexerUrl` build the method URL and refuse a name that is not alphanumeric. `decodeBase64` reads a standard-base64 indexer field.
- **Remote prover** — `POST /prove/{circuit}` with `X-Sync: true`, a `429` fallback to `X-Async`, and status polling. `proveIndexed` posts `POST /prove/{circuit}/indexed`. The returned gnark proof is compressed into the `TransactProof` the instruction carries, and the reported proving-key SHA-256 must match the pin copied from the TypeScript SDK.
- **Attested prover session** — HPKE (DHKEM(X25519, HKDF-SHA256), AES-256-GCM) with the `Spr-Tee: v1` headers. For `aws-nitro`, the session verifies the COSE_Sign1 document, the certificate chain, the PCR measurement, and the SHA-512 `report_data` binding. Nitro hosts no GPU, so a policy cannot require one and a quote that carries a GPU token is refused.
- **Shielded seed expansion** — `expandShieldedSeed` derives the nullifier and viewing secrets from a 64-byte ed25519 seed. `ownerHash` and `NullifierKey` consume those secrets. `stateTreePda` and `userRecordPda` derive the state-tree and user-registry accounts. `hexEncode` is the lowercase hex the attested session puts on its headers.

## Boundaries

`TeePolicy` accepts `aws-nitro` only. The session verifies that platform's COSE document against `awsNitroRoot`, or against anchors a test supplies. dstack quotes are not verified here.

Wallet sync, merge, split, and ring-transfer assembly from the TypeScript SDK are not in this package, and the Rust crate does not export them either. The public API does not stand in for them.

A prover that is not on a loopback address refuses a cleartext call unless `allowUnauthenticatedRemoteProver` is set or a `TeeSession` is attached. A local prover on `127.0.0.1` accepts the JSON body directly. The live Helius prover is not called unless you opt in.

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

`viewTag` for the permissionless ring is the recipient wallet address as 32 bytes. `recipientOwnerHash` is `ownerHash` of the shielded address. `expandShieldedSeed` derives the nullifier and viewing secrets that hash uses.

A live indexer call needs a Helius API key. Tests in this package skip that call unless `HELIUS_PRIVACY_RINGS_LIVE=1` and `HELIUS_API_KEY` are both set, and no key is stored in the repository.
