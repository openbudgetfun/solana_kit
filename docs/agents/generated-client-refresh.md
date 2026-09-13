# Generated client refresh

The Codama-generated program clients under `packages/*/lib/src/generated/` have drifted from what `scripts/generate_program_packages.mjs` produces. This note records the state of that drift so a refresh can be planned as a reviewed breaking migration rather than a mechanical regeneration.

Run the check yourself:

```bash
node scripts/generate_program_packages.mjs --check
```

## Current state

11 of the 12 generated packages differ from their committed output. Only `solana_kit_attestation_service` is current.

| Package                           | Generated diff (added/removed) |
| --------------------------------- | ------------------------------ |
| `solana_kit_token_2022`           | 8562 / 1812                    |
| `solana_kit_token`                | 2406 / 411                     |
| `solana_kit_stake`                | 1284 / 603                     |
| `solana_kit_system`               | 787 / 193                      |
| `solana_kit_loader`               | 569 / 109                      |
| `solana_kit_address_lookup_table` | 429 / 77                       |
| `solana_kit_compute_budget`       | 259 / 56                       |
| `solana_kit_memo`                 | 44 / 7                         |
| `solana_kit_mpl_token_metadata`   | 20 / 3                         |
| `solana_kit_mpl_core`             | 6 / 1                          |
| `solana_kit_squads`               | 0 / 0                          |

CI does not run `--check`, which is why the drift went unnoticed. Wiring it into CI has to come _after_ the refresh, otherwise it fails immediately.

## What kind of drift this is

Not a single fix. The renderer has accumulated several behavior changes since the committed clients were produced, and they alter the generated public API:

- **Escaped identifiers.** The built-in identifier `base` is now escaped, so `SystemTransferInstructionAccounts.base` became `base_`. The wire format is unchanged — the internal map key stays `'base'` — but every named parameter is renamed. This accounts for most of the `solana_kit_system` errors.
- **Defaulted struct fields.** `solana_kit_address_lookup_table` account fields that were required constructor parameters are now initialized fields with IDL-provided defaults:
  ```dart
  -    required this.discriminator,
  -    required this.padding,
  -  });
  +  }) : discriminator = 1,
  +       padding = 0;
  ```
- **Reworked extension modeling.** `solana_kit_token_2022`'s `types/extension.dart` is rewritten, and extension classes such as `MintCloseAuthority`, `TransferFeeConfig`, `DefaultAccountState`, `MetadataPointer`, and `PermanentDelegate` no longer exist as classes. This is the largest single change.
- **Added validation.** Decoders gained explicit byte-length guards throwing `SolanaError` with `codecsInvalidByteLength`, for example in `solana_kit_memo`'s `add_memo.dart`.
- **Renamed or dropped fields.** `solana_kit_stake` lost required fields including `epoch`, `unixTimestamp`, `stakeAuthorize`, `authoritySeed`, and `authorityOwner`, and gained `instructionType` and `data` fields on several instruction data types.

## Handwritten code that breaks

Regenerating and running `dart analyze` currently reports roughly 90 errors across five packages:

| Package                           | Files                                                                                    | Errors |
| --------------------------------- | ---------------------------------------------------------------------------------------- | ------ |
| `solana_kit_token_2022`           | `test/helpers_test.dart`, `lib/src/get_initialize_instructions_for_extensions.dart`      | 40     |
| `solana_kit_system`               | `test/identify_instruction_test.dart`, `test/system_test.dart`, and the integration test | 25     |
| `solana_kit_address_lookup_table` | `test/account_test.dart`                                                                 | 8      |
| `solana_kit_stake`                | `lib/src/helpers.dart`, `test/stake_test.dart`, and the integration test                 | 10     |
| `solana_kit_integration_tests`    | `test/integration/system_test.dart`, `test/integration/stake_test.dart`                  | 7      |

## Why it is not in the pin-refresh change

The refresh renames public parameters and removes public classes, so it is a breaking change for consumers of at least `solana_kit_system`, `solana_kit_address_lookup_table`, `solana_kit_stake`, and `solana_kit_token_2022`. Burying that in a reference-pin refresh would hide a breaking release inside a chore. It needs its own PR, its own `major` changesets with migration notes, and a green `dart analyze` plus full test run across the affected packages.

Note also that `solana_kit_token_2022` needs this migration before its pin can move to `js@v0.17.0`: that release renames the program node to camelCase, and regenerating against it removes `generated/token_2022.dart` in favour of `generated/token2022.dart`.

## Generator fixes already made

`scripts/generate_program_packages.mjs` could not even generate `solana_kit_stake`; it failed with `Duplicate generated path`. Two collisions are fixed:

- The IDL now declares `stakeStateAccount`, and `prepareStakeRoot` appended a second synthesized account with the same name. The synthesized node (which carries `size: 200`, and therefore the generated `stakeStateAccountSize` constant) now replaces the IDL's node instead of being appended.
- The IDL now declares `epoch` and `unixTimestamp`, and `prepareStakeRoot` prepended synthesized copies. The shims are now only added when the IDL is missing them, so older IDL revisions still work.

With those fixes, `--check` runs across all 12 packages and reports drift instead of aborting at `stake`.
