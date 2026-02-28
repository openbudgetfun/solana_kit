---
title: Transactions
description: Compose transaction messages and manage signing.
---

The transaction pipeline is intentionally modular:

- `solana_kit_instructions` defines `Instruction` and account metadata.
- `solana_kit_transaction_messages` builds and mutates message state.
- `solana_kit_transactions` compiles and serializes signed transactions.

## Recommended Flow

1. Build a message with fee payer and lifetime.
2. Append instructions in deterministic order.
3. Compile to wire format.
4. Sign with required signers.
5. Send and confirm with strategy-based confirmation utilities.

For confirmation tactics, see `solana_kit_transaction_confirmation`.
