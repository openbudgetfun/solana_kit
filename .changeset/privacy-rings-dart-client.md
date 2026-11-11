---
"solana_kit_privacy_rings": major
---

# Add a Dart client for Helius Solana Privacy Rings

`solana_kit_privacy_rings` builds shielded deposit, confidential transfer, and withdraw instructions, decrypts confidential notes with an X25519 viewing key, and calls the privacy indexer plus the remote prover. Deposit blinding matches the pinned Rust vector, and the viewing-key ciphertext matches `@noble`, which the TypeScript SDK uses.

```dart
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
```

The package starts at version 0.0.0 and is not published. It hashes confidential-transfer witnesses with Poseidon, opens an attested prover session, and posts that witness to the remote prover. Attach the compressed proof with `TransactInstructionData.withProof`. `subtractNullifiedNotes` drops a leaf whose caller-derived nullifier is already spent, and `retainNonInclusion` keeps a leaf whose nullifier has a non-inclusion proof.
