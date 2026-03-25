---
default: patch
---

Remove duplicate renderer devDependencies that are already provided by the root workspace, and update renderer scripts to invoke shared tools via `pnpm exec`.
