# solana_kit_mobile_wallet_adapter example app

This is an Android-first Flutter example app for
`solana_kit_mobile_wallet_adapter`.

It demonstrates three app boundaries explicitly:

1. **platform support gating** — check `isMwaSupported()` and wallet endpoint
   availability before attempting wallet handoff.
2. **wallet session state** — keep authorize, capabilities, message signing,
   and deauthorize flows inside a dedicated controller/service boundary.
3. **transaction submission boundary** — prepare or fetch base64 transaction
   payloads outside the widget tree, then hand them to the wallet layer for
   sign-and-send.

Documentation website: https://openbudgetfun.github.io/solana_kit/

## Platform expectations

- **Android** — real Mobile Wallet Adapter handoff is supported.
- **iOS** — the plugin is a safe stub/no-op because the current Solana Mobile
  Wallet Adapter ecosystem does not expose an equivalent iOS integration target.

For mixed-platform Flutter apps, keep the rest of your app functional on iOS
and present a clear fallback such as browser-wallet guidance, a desktop-wallet
handoff, or an explicit unsupported-platform message.

## What the example covers

- Android MWA support detection (`isMwaSupported`)
- Wallet endpoint availability (`MwaClientHostApi.isWalletEndpointAvailable`)
- `authorize`
- `getCapabilities`
- `signMessages`
- `signAndSendTransactions`
- `deauthorize`
- explicit iOS fallback UX

## Prerequisites

1. Flutter Android environment configured:
   https://docs.flutter.dev/get-started/install/macos/mobile-android#configure-android-development
2. Android emulator or physical Android device.
3. An MWA-compatible wallet or Solana's mock wallet.

## Install a mock MWA wallet (emulator/device testing)

Follow Solana Mobile's development setup instructions:
https://docs.solanamobile.com/get-started/development-setup#installation

Typical mock-wallet flow:

1. Clone the wallet:

   ```bash
   git clone https://github.com/solana-mobile/mock-mwa-wallet.git
   ```

2. Open `mock-mwa-wallet/android/build.gradle` in Android Studio.
3. Select the `fakewallet` configuration.
4. Install it on your emulator or Android device.

## Run the example

From the repo root:

```bash
cd packages/solana_kit_mobile_wallet_adapter/example
flutter pub get
flutter run
```

## Suggested manual flow on Android

1. Tap **Refresh Wallet Status**.
2. Confirm **Wallet endpoint** becomes **Available**.
3. Tap **Authorize** and approve in the wallet app.
4. Tap **Get Capabilities**.
5. Sign a test message with **Sign Message**.
6. Paste a base64 transaction payload and tap **Sign & Send Transaction**.
7. Tap **Deauthorize**.

The in-app log explains each step and is useful for emulator/device validation.

## Suggested fallback UX on iOS

If you run the app on iOS, keep the app shell working and show a clear message
that Mobile Wallet Adapter handoff is unavailable on this platform today.

Recommended fallback actions:

- explain that MWA is Android-only at the current ecosystem level
- point users to a browser-wallet or desktop-wallet alternative
- keep read-only or non-wallet features available
