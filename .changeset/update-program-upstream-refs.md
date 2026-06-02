---
"solana_kit_system": minor
"solana_kit_stake": major
"solana_kit_memo": patch
---

# Update upstream program references

Update generated Solana program packages to the latest checked upstream refs:

```text
solana_kit_system: solana-program/system js@v0.12.2
solana_kit_stake: solana-program/stake js@v0.6.1
solana_kit_memo: solana-program/memo js@v0.11.1
```

`solana_kit_system` adds the `CreateAccountAllowPrefund` instruction helpers.
`solana_kit_stake` includes the authority seed `u64` size-prefix fix and updated stake delegation layout.
