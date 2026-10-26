---
"solana_kit_keys": patch
---

# Use trusted system permissions during key export

Use an absolute system path for chmod during key pair export so an inherited PATH cannot substitute an executable. Preserve private staging directory and key file permissions.
