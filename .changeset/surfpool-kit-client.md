---
"solana_kit_surfpool": minor
---

# Kit-plugin style Surfpool client

Add `createSurfpoolClient()` / `connectSurfpoolClient()` returning a
`SurfpoolClient` wired up like the `@solana/surfpool/kit` plugin for
TypeScript:

- `rpc` / `rpcSubscriptions` — Solana Kit RPC and subscriptions clients
  pointed at the Surfnet.
- `payer` — the Surfnet's pre-funded `KeyPairSigner` (embedded mode) or a
  caller-provided funded signer (attach mode).
- `cheatcodes` — a typed `SurfnetCheatcodes` RPC covering every `surfnet_*`
  cheatcode with the prefix stripped (`timeTravel`, `pauseClock`, `setAccount`,
  `writeProgram`, …).
- `rpcUrl` / `wsUrl` — the Surfnet's HTTP and WebSocket URLs.
- `airdrop` / `getMinimumBalance` — funding and rent-exemption helpers.
- `stop()` — idempotent teardown that stops the Surfnet when this client
  started it.

`createSurfpoolClient` stops the Surfnet if wiring fails, so no orphaned
process or ports are left behind. The new API is fully unit-tested with 100%
patch coverage.
