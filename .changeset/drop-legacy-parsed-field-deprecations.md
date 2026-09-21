---
"solana_kit_rpc_parsed_types": major
---

# Drop the deprecation markers on legacy parsed account fields

`JsonParsedStakeConfigInfo.slashPenalty`, `warmupCooldownRate`, and `JsonParsedRentInfo`'s `burnPercent`, `exemptionThreshold`, and `lamportsPerByteYear` are no longer marked `@Deprecated`. Their fields, types, and behavior are unchanged, so this is a source-compatible change unless you suppress deprecation warnings — the markers were also suppressing nothing useful, because these fields describe what pre-Agave-4.1.0 validators actually return.

Agave 4.1.0 reshaped both responses, and the fields are still the documented way to read a validator that predates it. The `@Deprecated` annotation could not express that "only on older validators" condition, so the doc comments now carry it instead. This matches how the workspace already models the same legacy rent fields in `solana_kit_sysvars` and how `solana_kit_rpc_transformers` still lists `slashPenalty`, `warmupCooldownRate`, `burnPercent`, and `exemptionThreshold` as numeric keypaths in parsed accounts.

```dart
// Narrow on which shape the validator returned before reading either side.
final info = rentSysvar.info;
final lamportsPerByte = info.lamportsPerByte; // Agave 4.1.0+
final legacy = info.burnPercent; // validators running earlier versions
```

Removing the fields outright would have deleted real wire support: a `jsonParsed` request to an older validator returns exactly these fields, and `JsonParsedStakeConfigInfo` has no others, so the type would have become an empty placeholder.
