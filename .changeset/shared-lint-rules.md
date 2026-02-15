---
solana_kit_lints: minor
---

Initial release of shared lint configuration package. Extends `very_good_analysis`
with project-specific overrides: disables `public_member_api_docs` (docs will be
added incrementally) and `lines_longer_than_80_chars` (allows longer lines for
readability in codec/RPC code). All 37 packages in the workspace depend on this
package via `dev_dependencies` for consistent static analysis.
