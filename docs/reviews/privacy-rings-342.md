# Privacy Rings PR #342 audit

Reviewed 2026-11-13 against `origin/main`, after rebasing the five original commits. The implementation is a native Dart client; it does not invoke Rust, TypeScript, or an external SDK to implement its public API.

## References and scope

- Dart PR: https://github.com/openbudgetfun/solana_kit/pull/342
- Rust reference: https://github.com/pina-rs/solana_kit/tree/baa82f8f5771e9d0eae1aa64a0618b293d8dc1f0/crates/solana_kit_privacy_rings
- Rust trust-boundary documentation: https://github.com/pina-rs/solana_kit/blob/baa82f8f5771e9d0eae1aa64a0618b293d8dc1f0/docs/book/services/privacy-rings.md
- Protocol reference: Helius zolana / Privacy Rings v0.8.0, `6660d98397147531af80e94fb367a597c8d0082d`.

Read instruction builders and codecs, RPC models and pagination, balance assembly, viewing and seed derivation, Poseidon and witness construction, proof compression and pins, HPKE and Nitro verification, release configuration, and package tests. Compared the Rust implementations and retained the existing independent byte, ciphertext, hash, witness, CBOR, and HPKE vectors.

## Findings fixed

1. **Spent-note resurrection:** read helpers excluded spent leaves only from totals, leaving them in `notes`; combining reports rebuilt totals from those notes. Helpers now exclude spent leaves from both collections.
2. **Incomplete spend discovery:** receipt-tag history cannot establish whether every received note was spent. With a nullifier key, the facade now queries paginated history by derived nullifier, in batches, including transactions absent from tag history.
3. **Balance ownership and integrity:** proofless deposits were counted by tag without checking owner, and parseable AES-CTR plaintext was treated as a note without authentication. The facade requires an expected owner hash and a confidential-note verifier. Low-level unverified reads explicitly document caller obligations, following the Rust SDK. A regression mutates an amount ciphertext byte while preserving parseability and checks commitment rejection.
4. **Missing settlement accounts:** a tag-16 public deposit could pass the confidential-transfer helper without its funding accounts. All interface legs now require matching settlement accounts or the withdrawal target.
5. **Unbounded HTTP operations:** `maxWait` bounded gaps between polls but not stalled submission, attestation, or status requests. A single deadline now bounds the whole proving operation. Typed security failures retain their code.
6. **Credential handling:** API keys are now headers on indexer, prover, attestation, and status requests, following the Rust transport design. Legacy query-key input is accepted but removed from outgoing URLs. Known keys are redacted even when an upstream error echoes them without a URL label.
7. **Mutable attestation trust:** policy images, anchors, PCRs, the AWS root, and cached attested keys now use immutable copied bytes so caller mutation cannot change accepted trust or the encryption recipient.
8. **Malformed input handling:** truncated offchain signer lists return false; oversized CBOR arguments fail before integer overflow; HPKE rejects a non-contributory shared secret; incomplete witness paths and negative indexed context slots fail instead of being silently omitted or sent.
9. **Packaging and documentation:** pub's OAuth-token detector matched public base64 Poseidon constants. A file-specific `false_secrets` entry documents that false positive; the publish check remains enabled. Added attribution and the Apache-2.0 license for generated light-poseidon constants. Set `publish_to: none` to actually prevent publication: `tag = false` and `release = false` alone do not do so. Installation instructions now correctly describe an unpublished Git dependency, not a pub.dev release or an umbrella re-export. The facade accepts a TEE session. Variable-time P-384 signing helpers are internal test support and are not exported as a wallet signing API.

## Validation and limits

Local results: `lint:all`, `test:all`, `monochange step validate`, and `monochange step publish-packages --dry-run --all` pass. The publish dry run excludes Privacy Rings. Package tests pass 71 cases, with two opt-in tests skipped, and coverage reports 2984/2984 executable library lines (100%). The GitHub checks on the final pushed head remain the merge gate.

Local validation uses `devenv` and the repository's FVM toolchain. Package tests exercise positive flows, malformed inputs, simulated transport failures, and recorded independent vectors. Workspace lint includes docs, format, analysis, Kotlin, workflow security, and monochange checks. Workspace tests include the Flutter examples. CI also validates release preparation, package publishing, renderer tests, coverage, upstream parity, Android compilation, and integration.

Live Helius and a real local prover are opt-in tests; neither is enabled by this audit. Recorded proof/hash/witness vectors and mocked encrypted transport do not prove on-chain execution. No live transaction is submitted.

This review is not an independent cryptographic certification. Before production funds are used, prioritize an independent review of the custom P-384 / X.509 / CBOR verifier and cross-language fuzz testing, and add reproducible local-prover and on-chain execution tests with authenticated note commitments. Balance reads still depend on trusted indexer finality and are not atomic across pages. G2 subgroup and Groth16 verification remain on-chain. Merge, split, ring-transfer assembly, dstack attestation, and wallet synchronization are outside this public API rather than represented by stubs. Keep the package unpublished until its production-readiness criteria are explicitly met.
