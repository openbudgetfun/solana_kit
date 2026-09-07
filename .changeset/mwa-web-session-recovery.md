---
"solana_kit_mobile_wallet_adapter": minor
---

# Keep the mobile-browser association retry alive while the pairing sheet is up

On web, the Mobile Wallet Adapter pairing sheet can appear before the wallet app is foreground — Chrome keeps the page alive in the background while the user switches to the wallet, and the session establishes as soon as the wallet activity resumes. The association retry window on web is extended to 3 minutes (native stays at 30 seconds), so the first-time pairing no longer fails with a faded, uninteractive sheet while the wallet app waits for the dApp session. `transact` accepts a `connectionTimeout` override, and the example README documents pairing revocation.
