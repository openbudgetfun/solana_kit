---
"solana_kit_errors": minor
---

# Track `@solana/errors` v8.4.0: three new error codes

Ports the three error codes added upstream in `@solana/kit` v8.4.0:

- `codecsSentinelMissingAtEndOfBytes(8078028)` — thrown when a collection codec using a sentinel size strategy reaches the end of the byte array without encountering the sentinel.
- `codecsSentinelMustNotBeEmpty(8078029)` — thrown when constructing a collection codec with an empty sentinel.
- `instructionPlansMessageRejectedByPacker(7618012)` — thrown by a custom message packer to reject a transaction message for a reason other than the standard capacity limits.

Each code keeps its upstream `SolanaErrorCode` number so error codes remain interoperable across implementations. The features that throw them ship in this release too: the sentinel size strategy in `solana_kit_codecs_data_structures` and the custom message packer helpers in `solana_kit_instruction_plans`.
