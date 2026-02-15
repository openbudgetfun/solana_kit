# Solana Kit Dart SDK

[![CI](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml/badge.svg)](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml)

A Dart port of the [Solana TypeScript SDK](https://github.com/anza-xyz/kit) (`@solana/kit`). This monorepo contains ~37 packages that mirror the upstream TS package structure, built with modern Dart 3.10+ features.

## Getting Started

### Prerequisites

- [devenv](https://devenv.sh/) for the development environment
- [direnv](https://direnv.net/) for automatic environment loading

### Setup

```bash
# Clone the repository
git clone https://github.com/openbudgetfun/solana_kit.git
cd solana_kit

# Allow direnv (loads devenv automatically)
direnv allow

# Install binary dependencies
install:all

# Resolve Dart dependencies
dart pub get

# Clone reference repositories
clone:repos
```

### Development

```bash
# Run all lint checks
lint:all

# Run all tests
test:all

# Fix formatting and lint issues
fix:all
```

## Packages

| Package                             | Description                         |
| ----------------------------------- | ----------------------------------- |
| `solana_kit`                        | Umbrella re-exporting all packages  |
| `solana_kit_errors`                 | Error codes and SolanaError class   |
| `solana_kit_addresses`              | Base58 address utilities            |
| `solana_kit_keys`                   | Key pair and Ed25519 operations     |
| `solana_kit_codecs`                 | Umbrella for all codec sub-packages |
| `solana_kit_codecs_core`            | Core codec interfaces               |
| `solana_kit_codecs_numbers`         | Numeric codecs                      |
| `solana_kit_codecs_strings`         | String codecs                       |
| `solana_kit_codecs_data_structures` | Struct, enum, tuple codecs          |
| `solana_kit_rpc`                    | Primary RPC client                  |
| `solana_kit_rpc_subscriptions`      | Subscription client                 |
| `solana_kit_transactions`           | Transaction compilation and signing |
| `solana_kit_transaction_messages`   | Building transaction messages       |
| `solana_kit_signers`                | Signer interfaces                   |
| `solana_kit_accounts`               | Account fetching and decoding       |
| `solana_kit_programs`               | Program utilities                   |
| `solana_kit_functional`             | Pipe, compose utilities             |
| `solana_kit_options`                | Rust-like Option type codec         |
| ...and more                         | See `packages/` directory           |

## License

MIT
