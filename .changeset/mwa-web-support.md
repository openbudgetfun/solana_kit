---
"solana_kit_mobile_wallet_adapter": minor
"solana_kit_wallet_adapter": minor
"solana_kit_mobile_wallet_adapter_example": patch
---

# Use the Mobile Wallet Adapter from mobile browsers

The Mobile Wallet Adapter now works from Chrome (and other Chromium browsers) on Android devices, not just from native apps:

- `isMwaSupported()` returns `true` on web pages in a secure context (HTTPS or localhost), and the association intent is launched through a hidden iframe with page-blur detection mirroring the reference JS implementation; app-link URLs navigate directly.
- `transact` accepts an optional `launchIntent` override replacing the removed `clientApi` parameter.
- The wallet adapter's default web registry registers the Mobile Wallet Adapter wallet alongside browser-registered Wallet Standard wallets when the page runs in a mobile browser on Android, so mobile users keep wallet-app access from the picker.
- The example app gains the web platform so the flow can be tried in Chrome on a device.
