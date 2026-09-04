---
"solana_kit_keys": patch
"solana_kit_addresses": patch
---

# Harden key verification and publication

Reject small-order Ed25519 public keys and signature nonce points, including non-canonical aliases, to prevent weak-key signature forgery. Publish key files from a mode-`0700` staging directory so destination replacement cannot redirect secret bytes and readers of a file reservation cannot retain access to the completed key file.

Correct PDA documentation to state that callers may supply at most 15 seeds, reserving the sixteenth seed for the automatically appended bump.
