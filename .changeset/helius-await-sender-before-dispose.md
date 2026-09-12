---
"solana_kit_helius": patch
---

# Await the sender service call before disposing the signing keypair

`buildTokenTransfer` now awaits `sendViaSender` inside the `try` block instead of returning the Future directly, so the ephemeral keypair is disposed after the send completes rather than at return time. Signing already finishes before the call, so this is a lifecycle hygiene change with no observable behavior difference; it satisfies the Dart 3.13 `unawaited_return_in_try_block` diagnostic that the Flutter 3.47 toolchain enables.
