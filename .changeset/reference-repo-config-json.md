---
default: patch
---

Move reference repo pins out of `devenv.nix` into `config/reference-repos.json`, and teach `clone:repos` to read that config and report repo status.
