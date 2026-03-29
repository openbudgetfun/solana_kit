---
default: patch
---

Fix release tooling portability on macOS/BSD userlands by removing the Bash 4 `mapfile` dependency and GNU-awk-specific parsing from the workspace sync scripts. Also fix the mobile wallet adapter example and Android compile check to use local workspace overrides so CI can resolve unreleased `solana_kit_*` package versions correctly.
