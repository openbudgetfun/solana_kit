# Program packages audit: compressed NFTs and generated clients

## Scope and method

Reviewed the hand-written Bubblegum Merkle proof, DAS, hashing, tree initialization, mint, transfer, burn, and delegation helpers; SPL Account Compression sizing; MPL Core external plugin and asset-signer PDA resolution; Token Metadata edition/delegate PDA resolution; and Squads PDA encoding and representative vault/spending-limit instruction account roles and account decoders. Generated code was sampled at signer, optional-account, integer, and discriminator boundaries rather than independently proving every instruction against its on-chain program. Anchor, Pyth, and SNS were reviewed in the companion oracle/event audit.

Reference layouts were inspected in the checked-out upstream repositories and primary documentation:

- [ConcurrentMerkleTree serializer](https://github.com/solana-program/account-compression/blob/b229799e395cb78867e3753cf27534ecac375843/account-compression/sdk/src/types/ConcurrentMerkleTree.ts)
- [Path serializer](https://github.com/solana-program/account-compression/blob/b229799e395cb78867e3753cf27534ecac375843/account-compression/sdk/src/types/Path.ts)
- [Canopy serializer](https://github.com/solana-program/account-compression/blob/b229799e395cb78867e3753cf27534ecac375843/account-compression/sdk/src/types/Canopy.ts)
- [Bubblegum getAssetWithProof](https://github.com/metaplex-foundation/mpl-bubblegum/blob/6a6a77e341a3ee32f3d4a5c233d18370e1da07bf/clients/js/src/getAssetWithProof.ts)
- [Metaplex DAS proof field semantics](https://www.metaplex.com/docs/smart-contracts/bubblegum-v2/fetch-cnfts)

## Fixed: malformed Merkle proofs could pass verification

Severity: medium for applications using the off-chain verifier as an authorization or membership check. The on-chain Bubblegum program is not bypassed by this SDK defect.

`MerkleTree.verify` consumed only as many low index bits as there were proof nodes. A valid depth-one proof for index 0 also verified at indices -2, 2, 4, and 4294967296. Applications relying on the advertised leaf position could therefore accept membership at a position absent from the tree. Hash lengths were unchecked: a 64-byte concatenation of two child hashes with an empty sibling verified against their parent, and empty zero-depth commitments verified successfully.

The regression suite was run against the unchanged implementation: six tests failed with actual `true` where rejection was expected. The verifier now rejects negative/out-of-depth indices and non-32-byte roots, leaves, or sibling hashes before hashing. Valid left/right and depth-zero proofs still pass.

Evidence: `/tmp/solana-audit-evidence/programs-mpl-merkle-before.log` and `programs-mpl-merkle-after.log`.

## Fixed: compression tree account sizes did not match the program layout

Severity: high functional impact on tree creation, without a demonstrated authorization bypass.

The helper used fictional 33-byte path nodes and incorrect padding, cached the wrong canopy levels, and silently allocated a full-depth canopy when omitted. A depth-14/buffer-64 tree without a canopy should use 31800 bytes, but the helper returned 557088 by default. With explicit canopy depth 10, it returned 65568 instead of 97272 bytes. Invalid account lengths can make tree initialization fail or cause incorrect rent estimates.

Seven exact size/default regressions failed before the fix. The implementation now matches the upstream 32-byte-node layouts, excludes the root from the canopy, and defaults to no canopy. Explicit canopy depth remains supported.

Evidence: `/tmp/solana-audit-evidence/programs-mpl-compression-before.log` and `programs-mpl-after.log`.

## Fixed: DAS helper returned unusable mutation parameters

Severity: high functional impact on compressed NFT transfer/burn/delegation flows, without a demonstrated authorization bypass.

The helper returned empty owner/delegate addresses, tried to extract a nonce from a 32-byte leaf hash and always obtained zero, and returned the global node index in place of the leaf index. Five regression tests failed against mocked DAS responses before the fix. Ownership is now retained, a missing delegate defaults to the owner, nonce uses `compression.leaf_id`, and the leaf index subtracts the leaf-layer offset from `node_index`.

Evidence: `/tmp/solana-audit-evidence/programs-mpl-das-before.log` and `programs-mpl-final-tests.log`.

## Remaining functional findings

The legacy Bubblegum composite instruction-plan helpers still need a coordinated API correction before they can serve complete transaction flows:

- The tree/create/mint/transfer/burn/delegate helpers pass the Merkle tree address where a distinct tree-authority PDA is required. The PDA API is asynchronous while these convenience helpers are synchronous.
- The V2 tree helper hardcodes incorrect Noop, compression, and system program addresses.
- Transfer/burn/delegate convenience inputs omit remaining Merkle proof accounts and do not promote the selected owner/delegate to signer. The generated low-level builders require callers to append the proof account metadata and select the signing authority explicitly.

These were identified in source inspection; no on-chain exploit or bypass is claimed. Use the generated instruction builders with derived PDAs, canonical program IDs, complete proof accounts, and explicit signer attachment until the composite API is corrected.

MPL Core, MPL Token Metadata, and Squads review did not establish an additional exploitable issue in the inspected boundaries. This is a source and regression-test audit, not an independent on-chain protocol audit.

## Validation

The existing Bubblegum and compression package suites passed 99 tests after the proof and sizing fixes. Final focused coverage after the DAS correction passed 34 tests. Both affected packages pass `dart analyze`. Executable changed-line coverage is 14/14 (100%): Merkle verification 5/5, DAS assembly 4/4, DAS ownership parsing 2/2, and compression sizing 3/3. Coverage is measured from VM LCOV entries intersected with added lines from `git diff HEAD`; no coverage-ignore directives were added.

Coverage artifacts: `/tmp/solana-audit-evidence/programs-mpl-lcov.info` and `/tmp/solana-audit-evidence/programs-mpl-patch-coverage.json`.
