# Integration Tests

End-to-end integration tests that run against a local Solana validator.

## Prerequisites

These tests require [SurfPool](https://github.com/nicfol/surfpool) as the
local validator. Install it according to the SurfPool documentation.

## Running

```bash
# Start SurfPool in a separate terminal
surfpool

# Run integration tests
dart test integration_test/
```

## Test coverage

| Area                               | Status     |
| ---------------------------------- | ---------- |
| `getBalance` / `getAccountInfo`    | ✅         |
| `requestAirdrop` → verify balance  | ✅         |
| Build → sign → send → confirm      | 🔜 Planned |
| Account subscription notifications | 🔜 Planned |
| Nonce-based transaction lifetime   | 🔜 Planned |

## CI

Integration tests are **not** run automatically in CI. They require a running
validator and are intended for local development and manual CI triggers.
