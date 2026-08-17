---
"codama-renderers-dart": patch
"solana_kit_helius": patch
"solana_kit_keys": patch
"solana_kit_mobile_wallet_adapter_protocol": patch
"solana_kit_rpc_subscriptions": patch
"solana_kit_rpc_subscriptions_channel_websocket": patch
"solana_kit_surfpool": patch
"solana_kit_transaction_introspection": patch
---

# Harden credentials, keys, transports, and untrusted RPC decoding

Align Helius signup and project provisioning with the v3 bearer-JWT API,
generate valid Ed25519 authentication keypairs, validate payment inputs, and
redact WebSocket credentials.

Dispose or clear SDK-owned key material deterministically, create key files
exclusively with safe POSIX permissions, and preserve caller ownership of
Surfpool signers.

Reject malformed RPC transaction and inner-instruction data instead of
silently dropping it, expand private WebSocket literal filtering, and update
JavaScript dependency overrides to releases without the audited advisories.
Make the standalone Codama renderer workspace declare its own build tools and
explicitly allow only esbuild's required install script.
