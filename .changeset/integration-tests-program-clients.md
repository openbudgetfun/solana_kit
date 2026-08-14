---
"solana_kit_transaction_confirmation": patch
"solana_kit_errors": patch
"solana_kit_integration_tests": minor
---

# On-chain integration tests for program clients + sendTransaction encoding fix

## `solana_kit_transaction_confirmation` (patch)

Fix `sendAndConfirmTransaction` so the `sendTransaction` RPC call declares
`encoding: base64`. The helper encodes the transaction as base64 via
`getBase64EncodedWireTransaction` but previously left the `encoding` field
unset, so real RPC nodes (including SurfPool) defaulted to base58 and rejected
the payload with `invalid base58 encoding`. This path had only been exercised
against a mocked transport, so the bug was latent.

## `solana_kit_errors` (patch)

Fix `getSolanaErrorFromTransactionError` to handle instruction-error indices
returned as `BigInt` (as SurfPool does). The instruction index was cast
`as num`, which threw `_BigIntImpl is not a subtype of num` and masked the
real on-chain instruction error. It now converts `BigInt` indices to `int`.

## `solana_kit_integration_tests` (new, internal)

A non-published workspace package that runs every generated program client
end-to-end against a local SurfPool Surfnet. It ships a shared
`IntegrationTestEnv` harness (connects-or-starts SurfPool, funds a payer,
builds/signs/sends/confirms transactions, deploys programs) and on-chain suites
that assert the real on-chain outcome of each instruction:

- Builtin programs: Memo, System (transfer), Compute Budget, Token
  (createMint -> mintTo), Token-2022, Associated Token Account, Address Lookup
  Table, Stake (initialize), and BPF Loader (initializeBuffer).
- Subscriptions: the compiled program (`.so`) is committed under
  `config/programs/` and deployed on-chain; `initSubscriptionAuthority` runs
  and its PDA is verified on-chain.
- MPL Bubblegum: Bubblegum + SPL Account Compression + Noop are deployed
  on-chain (verified executable + owned by the BPF loader). A full
  `createTree` currently panics inside the deployed Bubblegum binary on
  SurfPool (`create_tree.rs:20`) — a program-internal issue tracked for
  upstream; the client's instruction builders are covered by encoding tests.

The compiled `.so` artifacts are committed (not rebuilt per run) and pinned to
`config/reference-repos.json`; see `config/programs/README.md` for how they
were obtained and when they must be regenerated.
