---
"solana_kit_loader": patch
---

# Fix multi-transaction loader uploads

Allow deploy and upgrade plans to upload program buffers across sequential transactions before finalizing, making normal program binaries executable with the standard transaction planner and executor.
