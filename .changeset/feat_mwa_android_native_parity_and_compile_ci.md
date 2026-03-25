---
default: minor
---

Improve Android native wallet adapter parity and add CI Android compile verification.

- Replace wallet stub behavior with walletlib-backed scenario/request handling.
- Add Digital Asset Links native bridge and Dart API surface.
- Harden local/remote transport behavior and request routing.
- Add a CI check that compiles a temporary Flutter Android app using the plugin.
