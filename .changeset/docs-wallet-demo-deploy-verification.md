---
"solana_kit_wallet_ui": patch
---

# Verify deployed docs pages and the wallet demo

The docs site smoke test now builds the embedded wallet demo for the deployment base path and verifies, browser-style, that the demo's base href matches where it is served and that every asset it references resolves. It also walks every documented content page and asserts the shared site chrome renders, and a widget test connects the deterministic demo wallet and signs a message through the example app. The demo build script accepts `--base-path` in both `--flag value` and `--flag=value` spellings again, so deployments under a GitHub Pages subdirectory keep resolvable asset URLs.
