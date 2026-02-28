# solana_kit_mobile_wallet_adapter example app

This is a runnable Flutter Android app for manual testing of
`solana_kit_mobile_wallet_adapter` against an MWA-compatible wallet.

## What this app tests

- Android MWA support detection (`isMwaSupported`)
- Wallet endpoint availability (`MwaClientHostApi.isWalletEndpointAvailable`)
- `authorize`
- `getCapabilities`
- `signMessages`
- `deauthorize`

## Prerequisites

1. Flutter Android environment configured:
   https://docs.flutter.dev/get-started/install/macos/mobile-android#configure-android-development
2. Android emulator or physical Android device.

## Install a mock MWA wallet (emulator/device testing)

Follow Solana Mobile's development setup instructions:
https://docs.solanamobile.com/get-started/development-setup#installation

The documented mock-wallet install flow is:

1. Clone mock wallet:

   ```bash
   git clone https://github.com/solana-mobile/mock-mwa-wallet.git
   ```

2. In Android Studio, open:
   `mock-mwa-wallet/android/build.gradle`
3. Select the `fakewallet` run/build configuration.
4. Run/install it on your emulator or device.

## Run this example app

From repo root:

```bash
cd packages/solana_kit_mobile_wallet_adapter/example
flutter pub get
flutter run
```

## Manual test flow

1. Tap `Refresh Wallet Status`.
2. Confirm `Wallet endpoint` is `Available`.
3. Tap `Authorize` and approve in the wallet app.
4. Tap `Get Capabilities`.
5. Enter a message and tap `Sign Message`.
6. Tap `Deauthorize`.

The in-app log panel shows operation results and failure reasons.

## Notes

- MWA is Android-only. On iOS, this plugin is a no-op.
- The Solana mock wallet is for development only and resets state between app restarts.
