---
solana_kit_lints: patch
---

Add a `solana_kit_lints` workspace dependency checker and run it as part of
`lint:all` to ensure internal package dependencies use `workspace: true` in
`pubspec.yaml` files.
