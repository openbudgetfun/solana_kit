---
default: patch
---

# chore: add flutter example app for mobile wallet adapter manual testing

## Summary

Adds a runnable Flutter Android example app under `packages/solana_kit_mobile_wallet_adapter/example/` for manual Mobile Wallet Adapter (MWA) testing on device/emulator.

## What changed

- Scaffolded a full Flutter Android example app for `solana_kit_mobile_wallet_adapter`.
- Added manual-test UI flows for:
  - Wallet endpoint detection
  - `authorize`
  - `getCapabilities`
  - `signMessages`
  - `deauthorize`
- Added `example/README.md` with setup instructions and mock wallet installation guidance based on Solana Mobile docs.
- Updated package README with a dedicated "Manual testing app" section linking to the new example and setup guide.

## Why

The previous example was not a runnable Flutter app for end-to-end manual testing with real/emulated wallets. This adds a practical test harness for validating adapter behavior in development.

## Validation

- `flutter pub get` (example app)
- `flutter analyze` (example app)
- `flutter test` (example app)
- `devenv shell -- docs:check`
