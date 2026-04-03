# Solana Kit – Dart Examples

Standalone Dart scripts that demonstrate the Solana Kit SDK.
Each file is self-contained and runnable with:

```sh
dart examples/<file>.dart
```

> **Devnet-safe by default.** Examples that contact the network target
> `api.devnet.solana.com`. Helius examples require a real API key – see the
> comments in each file.

---

## Example index

| #  | File                                                                         | What it shows                                                                                      |
| -- | ---------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------- |
| 01 | [01_create_address.dart](01_create_address.dart)                             | Construct, validate and compare Solana `Address` values; catch `SolanaError` on invalid input      |
| 02 | [02_generate_keypair.dart](02_generate_keypair.dart)                         | Generate Ed25519 key pairs, read byte slices, and reconstruct a key pair from private-key bytes    |
| 03 | [03_sign_and_verify.dart](03_sign_and_verify.dart)                           | Sign arbitrary bytes with `signBytes`, verify with `verifySignature`, encode as base58 `Signature` |
| 04 | [04_program_derived_address.dart](04_program_derived_address.dart)           | Derive PDAs with `getProgramDerivedAddress`, detect off-curve addresses, build an ATA PDA          |
| 05 | [05_number_codecs.dart](05_number_codecs.dart)                               | Encode/decode u8, u16, u32, u64, i8, i64, and f64 with little-endian codecs                        |
| 06 | [06_string_codecs.dart](06_string_codecs.dart)                               | Base58, base64, base16/hex, and UTF-8 codecs; fixed-size base58 for address encoding               |
| 07 | [07_struct_codec.dart](07_struct_codec.dart)                                 | Build a `getStructCodec` to model a token-account layout; round-trip encode/decode                 |
| 08 | [08_option_type.dart](08_option_type.dart)                                   | Rust-style `Option<T>` — `Some`, `None`, `unwrapOption`, `unwrapOptionOr`, and `getOptionCodec`    |
| 09 | [09_error_handling.dart](09_error_handling.dart)                             | `SolanaError`, `SolanaErrorCode`, `SolanaErrorDomain` routing, and `isSolanaError`                 |
| 10 | [10_keypair_signer.dart](10_keypair_signer.dart)                             | Create a `KeyPairSigner`, sign messages, reconstruct from private key, deduplicate signers         |
| 11 | [11_build_transaction.dart](11_build_transaction.dart)                       | Full offline pipeline: build message → set fee payer → blockhash → instruction → compile → sign    |
| 12 | [12_sysvars.dart](12_sysvars.dart)                                           | Well-known sysvar addresses; encode/decode `SysvarClock`, `SysvarRent`, `SysvarEpochSchedule`      |
| 13 | [13_offchain_messages.dart](13_offchain_messages.dart)                       | Sign-in-with-Solana messages: `OffchainMessageV0`, `OffchainMessageV1`, envelope codec             |
| 14 | [14_rpc_client.dart](14_rpc_client.dart)                                     | `createSolanaRpc` → `getSlot`, `getLatestBlockhash`, `getBalance`, `getEpochInfo` (devnet)         |
| 15 | [15_get_account_info.dart](15_get_account_info.dart)                         | `getAccountInfo`, `getAccountInfoValue`, `getMultipleAccountsValue` (devnet)                       |
| 16 | [16_rpc_subscriptions.dart](16_rpc_subscriptions.dart)                       | `createSolanaRpcSubscriptions`, `slotNotifications`, `AbortController` for clean teardown          |
| 17 | [17_functional_pipe.dart](17_functional_pipe.dart)                           | `.pipe()` extension for readable left-to-right composition of transaction-message builders         |
| 18 | [18_fast_stable_stringify.dart](18_fast_stable_stringify.dart)               | `fastStableStringify` for deterministic JSON serialisation                                         |
| 19 | [19_address_comparator.dart](19_address_comparator.dart)                     | `getAddressComparator` for base58-collation sorting of address lists                               |
| 20 | [20_helius_client_setup.dart](20_helius_client_setup.dart)                   | Construct a `HeliusClient` from `HeliusConfig`; inspect available sub-clients                      |
| 21 | [21_helius_das.dart](21_helius_das.dart)                                     | Helius DAS: `getAssetsByOwner`, `getAsset` (API key required)                                      |
| 22 | [22_helius_priority_fee.dart](22_helius_priority_fee.dart)                   | Helius priority-fee estimates for a list of account keys (API key required)                        |
| 23 | [23_transaction_send_and_confirm.dart](23_transaction_send_and_confirm.dart) | Full end-to-end devnet: airdrop → build → compile → sign → send → confirm                          |
| 24 | [24_fetch_encoded_account.dart](24_fetch_encoded_account.dart)               | `fetchEncodedAccount`, `fetchEncodedAccounts`, `ExistingAccount` / `NonExistingAccount` (devnet)   |
| 25 | [25_union_codec.dart](25_union_codec.dart)                                   | `Union2` typed variants and `getDiscriminatedUnionEncoder/Decoder` for Anchor-style discriminators |
| 26 | [26_transaction_serialization.dart](26_transaction_serialization.dart)       | Base64 wire format, `getTransactionSize`, `isFullySignedTransaction`, raw message bytes            |

---

## Running the examples

### Prerequisites

Ensure you have Dart SDK ≥ 3.10 available (the workspace uses [FVM](https://fvm.app/)).

```sh
# From the repo root, install all dependencies:
devenv shell -- dart pub get

# Run any offline example:
dart examples/01_create_address.dart

# Run devnet examples (internet required):
dart examples/14_rpc_client.dart
dart examples/23_transaction_send_and_confirm.dart
```

### Helius examples

Helius examples guard all network calls behind an early return when the
placeholder key is detected:

```dart
const apiKey = 'YOUR_API_KEY'; // ← fill in
if (apiKey == 'YOUR_API_KEY') {
  print('Set a real Helius API key to run this example.');
  return;
}
```

Get a free API key at <https://helius.dev> and replace the placeholder.

---

## Package map

| Example area                 | Package(s) used                                                                                                                              |
| ---------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------- |
| Addresses                    | `solana_kit_addresses`                                                                                                                       |
| Keys & signatures            | `solana_kit_keys`                                                                                                                            |
| Signers                      | `solana_kit_signers`                                                                                                                         |
| Codecs                       | `solana_kit_codecs`, `solana_kit_codecs_core`, `solana_kit_codecs_numbers`, `solana_kit_codecs_strings`, `solana_kit_codecs_data_structures` |
| Options                      | `solana_kit_options`                                                                                                                         |
| Errors                       | `solana_kit_errors`                                                                                                                          |
| Sysvars                      | `solana_kit_sysvars`                                                                                                                         |
| Transaction messages         | `solana_kit_transaction_messages`                                                                                                            |
| Transactions                 | `solana_kit_transactions`                                                                                                                    |
| RPC                          | `solana_kit_rpc`, `solana_kit_rpc_api`, `solana_kit_rpc_types`                                                                               |
| RPC subscriptions            | `solana_kit_rpc_subscriptions`, `solana_kit_rpc_subscriptions_channel_websocket`                                                             |
| Transaction confirmation     | `solana_kit_transaction_confirmation`                                                                                                        |
| Accounts                     | `solana_kit_accounts`                                                                                                                        |
| Offchain messages            | `solana_kit_offchain_messages`                                                                                                               |
| Helius                       | `solana_kit_helius`                                                                                                                          |
| Functional (deprecated shim) | `solana_kit_functional`                                                                                                                      |
| Stringify                    | `solana_kit_fast_stable_stringify`                                                                                                           |
