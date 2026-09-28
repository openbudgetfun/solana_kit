---
"solana_kit_mobile_wallet_adapter": patch
"solana_kit_mobile_wallet_adapter_protocol": patch
---

# Clear MWA session secrets on close and validate parsed association URIs

Closing a local or remote Mobile Wallet Adapter session now zeroes the AES session key (`Uint8List.fillRange`) and releases the handshake keypair references, so session secrets no longer outlive the session object. The P-256 private scalars live inside PointyCastle `BigInt`s, which Dart cannot zero deterministically, so only their references are dropped — the limitation stays documented in the workspace security policy.

`parseAssociationUri` now runs the same validators the URI builder uses: a crafted local association URI with a port outside the RFC 6335 dynamic range (49152-65535) or a reflector ID above 2^53-1 is rejected with the existing typed MWA errors instead of silently accepted, and the Android wallet bridge no longer reinterprets malformed base64 payloads as raw UTF-8 bytes — a corrupt address or auth token now fails the request instead of becoming a plausible-looking value.
