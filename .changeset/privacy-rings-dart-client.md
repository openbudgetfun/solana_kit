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

`getNullifierQueueElements` reads the nullifier queue. `confidentialTransferWitness` builds the gnark witness, including the public-input hash, from notes and Merkle paths, and the published `transfer-2x2` witness matches. `TeeSession` verifies an AWS Nitro COSE_Sign1 document before it encrypts a request. `expandShieldedSeed` derives the nullifier and viewing secrets. `collectPages` walks indexer pages and refuses a truncated history, and `spentNullifiers` returns the sorted unique nullifiers. `proverGpuNonce` matches the published TEE vector. `PrivacyRingsCluster`, `localIndexerUrl`, and `localProverUrl` build the cluster and local-stack URLs. `stateTreePda` and `userRecordPda` derive those accounts, and `decodeBase64` reads an indexer field.
