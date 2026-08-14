---
"solana_kit_transaction_confirmation": patch
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

## `solana_kit_integration_tests` (new, internal)

A non-published workspace package that runs the generated program clients
end-to-end against a local SurfPool Surfnet. It ships a shared
`IntegrationTestEnv` harness (funds a payer, builds/signs/sends/confirms
transactions) and initial on-chain suites for the Memo, System, and
Compute Budget program clients. The remaining builtin program clients
(token, token-2022, associated-token-account, address-lookup-table, stake,
loader) and the deployable clients (subscriptions, mpl-bubblegum) follow the
same pattern and will be added incrementally.
