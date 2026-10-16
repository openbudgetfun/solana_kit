---
"solana_kit_anchor": patch
"solana_kit_jupiter": patch
"solana_kit_mpl_core": patch
"solana_kit_mpl_token_metadata": patch
"solana_kit_squads": patch
---

# Repair corrupted README documentation sections

Five package READMEs carried a mangled documentation region: a duplicated Installation section with an unfilled `^` version placeholder, a stray `:::` container marker, and an orphaned `packageDocumentationSection` closing tag with no opening tag. The sections now match the mdt consumer-block structure the rest of the workspace uses, so `mdt check` passes with validators that flag unmatched tags (mdt 0.9.6+) and the published READMEs no longer show two conflicting Installation sections.
