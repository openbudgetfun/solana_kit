---
solana_kit_addresses: minor
solana_kit_keys: minor
solana_kit_signers: minor
solana_kit_codecs_core: minor
solana_kit_codecs_numbers: minor
solana_kit_codecs_strings: minor
solana_kit_codecs_data_structures: minor
solana_kit_codecs: minor
solana_kit_functional: minor
solana_kit_options: minor
solana_kit_fast_stable_stringify: minor
solana_kit_subscribable: minor
solana_kit_instructions: minor
solana_kit_instruction_plans: minor
solana_kit_transaction_messages: minor
solana_kit_transactions: minor
solana_kit_offchain_messages: minor
solana_kit_test_matchers: minor
---

Initial scaffold for 18 core packages forming the foundation and middle layers of
the Solana Kit dependency graph. Each package has its pubspec.yaml with correct
workspace dependencies, shared analysis_options.yaml, and an empty barrel export
file ready for implementation.

Package groups scaffolded:
- **Crypto & Identity**: addresses (base58), keys (Ed25519), signers (interfaces)
- **Codecs**: core interfaces, numbers, strings, data structures, umbrella re-export
- **Utilities**: functional (pipe/compose), options (Rust-like Option codec),
  fast_stable_stringify, subscribable (reactive patterns)
- **Transaction Building**: instructions, instruction_plans, transaction_messages,
  transactions (compilation & signing)
- **Other**: offchain_messages, test_matchers
