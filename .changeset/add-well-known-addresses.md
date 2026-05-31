---
"solana_kit_address": patch
"solana_kit_address_constants": patch
"solana_kit_addresses": minor
"solana_kit": patch
"solana_kit_address_lookup_table": patch
"solana_kit_associated_token_account": patch
"solana_kit_compute_budget": patch
"solana_kit_config": patch
"solana_kit_loader": patch
"solana_kit_memo": patch
"solana_kit_mpl_bubblegum": patch
"solana_kit_spl_account_compression": patch
"solana_kit_stake": patch
"solana_kit_system": patch
"solana_kit_sysvars": patch
"solana_kit_token": patch
"solana_kit_token_2022": patch
"solana_kit_transaction_messages": patch
"solana_kit_transactions": patch
"codama-renderers-dart": minor
---

# Add well-known program, sysvar, SPL, Metaplex, and token mint address constants

Add centralized address constants to `solana_kit_addresses` so that any package can reference well-known on-chain addresses without importing the full domain package or hardcoding strings.

New exports:

- `program_addresses.dart` — All Agave/Solana native program addresses (system, ALT, BPF loaders, compute budget, config, stake, vote, etc.)
- `sysvar_addresses.dart` — All sysvar addresses (clock, rent, recentBlockhashes, fees, rewards, etc.) plus the sysvar owner address
- `spl_addresses.dart` — SPL program addresses (Token, Token-2022, ATA, Memo, Memo Legacy)
- `metaplex_addresses.dart` — Metaplex program addresses (Token Metadata, Bubblegum, Auth Rules, Core, SPL Account Compression, Noop)
- `well_known_addresses.dart` — Well-known token mint addresses (Wrapped SOL, USDC, USDT)

Also re-exports from `solana_kit_address` (Address type, codecs, comparator, PublicKey) and `solana_kit_address_constants` (well-known address constants).
