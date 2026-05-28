---
"solana_kit_helius": patch
---

# Redact API keys in Helius config output

SEC-01: Redact API keys in `HeliusConfig.toString()` output to prevent accidental exposure in logs, error messages, or debug output.

- Added `SensitiveString` wrapper class that redacts its value in `toString()` output
- `HeliusConfig` now wraps the API key in `SensitiveString` internally
- `HeliusConfig.toString()` now shows redacted key (e.g., `****123`) instead of the full key
- `HeliusConfig.apiKey` still returns the raw key for legitimate API calls
- Removed `const` from `HeliusConfig` constructor (breaking change for `const` usage)
