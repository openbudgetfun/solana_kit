# Architecture

## Workspace shape

- This repository is a Dart workspace rooted at `pubspec.yaml`.
- SDK packages live under `packages/`.
- SDK package names use the `solana_kit_` prefix, except the umbrella package `solana_kit`.
- Renderer tooling lives separately in `packages/codama-renderers-dart`.

## Design constraints

- Port upstream `@solana/kit` behavior into idiomatic Dart.
- Do not introduce code generation (`freezed`, `build_runner`, etc.).

## Core dependency flow

```text
solana_kit_errors
  ├── solana_kit_addresses
  │     └── solana_kit_keys
  │           └── solana_kit_signers
  ├── solana_kit_codecs_core
  │     ├── solana_kit_codecs_numbers
  │     ├── solana_kit_codecs_strings
  │     ├── solana_kit_codecs_data_structures
  │     └── solana_kit_codecs
  ├── solana_kit_rpc_types
  │     ├── solana_kit_rpc_spec_types
  │     ├── solana_kit_rpc_spec
  │     ├── solana_kit_rpc_api
  │     └── solana_kit_rpc
  ├── solana_kit_mobile_wallet_adapter_protocol
  │     └── solana_kit_mobile_wallet_adapter
  └── solana_kit
```
