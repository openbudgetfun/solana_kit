# Committed Solana program artifacts

Compiled Solana program binaries (`.so`) used by the on-chain integration
tests in `packages/solana_kit_integration_tests`. They are committed to the
repository so the integration suite does not need to compile or fetch them
on every run.

## Programs

| Artifact                                                    | Program                                                                                     | Pin / version                                                                         |
| ----------------------------------------------------------- | ------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------- |
| `subscriptions-ts-client-v0.5.0.so`                         | [solana-foundation/subscriptions](https://github.com/solana-foundation/subscriptions)       | `ts-client-v0.5.0` (see `config/reference-repos.json`)                                |
| `mpl_bubblegum-68e4bc204099718f318d5fe258f60be09737416d.so` | [metaplex-foundation/mpl-bubblegum](https://github.com/metaplex-foundation/mpl-bubblegum)   | commit `68e4bc204099718f318d5fe258f60be09737416d` (see `config/reference-repos.json`) |
| `spl_account_compression-ac-mainnet-tag.so`                 | [solana-program/account-compression](https://github.com/solana-program/account-compression) | `ac-mainnet-tag` (see `config/reference-repos.json`)                                  |
| `noop.so`                                                   | [solana-program-library/noop](https://github.com/solana-labs/solana-program-library)        | deployed mainnet binary (no pinned reference)                                         |

## How these were obtained

These are the **currently deployed mainnet binaries**, downloaded from the
chain: each program's `programData` account (found via
`getAccountInfo` → `jsonParsed` → `parsed.info.programData`) was fetched with
`encoding: base64` and a `dataSlice` starting at offset 45 (skipping the
upgradeable loader's 4-byte tag + 8-byte slot + 33-byte authority header).

## Regeneration

**When the pinned version of any of these programs changes, the `.so` artifact
must be regenerated** — the committed binary is version-locked to the pin in
`config/reference-repos.json` (or, for `noop`, to whatever is currently
deployed on mainnet).

To regenerate:

1. Bump the reference pin in `config/reference-repos.json` (or update `noop`
   to the new upstream version).
2. Re-download the deployed binary from mainnet:

   ```bash
   # 1. Resolve the programData account for the program ID:
   #    curl -X POST https://api.mainnet-beta.solana.com -H "Content-Type: application/json" \
   #      -d '{"jsonrpc":"2.0","id":1,"method":"getAccountInfo","params":["<PROGRAM_ID>",{"encoding":"jsonParsed"}]}'
   #    → parsed.info.programData
   #
   # 2. Fetch the code (skipping the 45-byte loader header):
   curl -X POST https://api.mainnet-beta.solana.com -H "Content-Type: application/json" \
     -d '{"jsonrpc":"2.0","id":1,"method":"getAccountInfo","params":["<PROGRAM_DATA>",{"encoding":"base64","dataSlice":{"offset":45,"length":99999999}}]}' \
     | jq -r '.result.value.data[0]' | base64 -d > config/programs/<name>-<pin>.so
   ```

3. Update the artifact filename to match the new pin and update the tests that
   reference it.

## Canonical program IDs

The on-chain tests deploy these programs at their canonical addresses (the
programs bake their program ID into the binary, so PDA derivation only works
when deployed at the baked-in address):

- Subscriptions: `De1egAFMkMWZSN5rYXRj9CAdheBamobVNubTsi9avR44`
- MPL Bubblegum: `BGUMAp9Gq7iTEuizy4pqaxsTyUCBK68MDfK752saRPUY`
- SPL Account Compression: `cmtDvXumGCrqC1Age74AVPhSRVXJMd8PJS91L8KbNCK`
- Noop: `noopb9bkMVfRPU8AsbpTUg8AQkHtKwMYZiFUjNRtMmV`

The `solana_kit_address_constants` package ships these canonical IDs.
