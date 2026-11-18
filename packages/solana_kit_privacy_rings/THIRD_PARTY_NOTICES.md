# Third-party notices

The Dart SDK code is MIT licensed; see LICENSE.

`lib/src/poseidon/parameters.dart` contains generated BN254 x5 round constants and MDS matrices derived from Light Protocol's light-poseidon `src/parameters/bn254_x5.rs`, distributed under Apache License 2.0. The table is serialized into the PSDN base64 format for this port. See [LICENSE-APACHE-2.0](LICENSE-APACHE-2.0) and [light-poseidon](https://github.com/Lightprotocol/light-poseidon).

Protocol layouts and fixtures follow Helius Privacy Rings / zolana v0.8.0 (`6660d98397147531af80e94fb367a597c8d0082d`), including sdk-libs/instruction, sdk-libs/keypair, and program-libs/hasher. Rust parity was reviewed against [pina-rs/solana_kit](https://github.com/pina-rs/solana_kit) at `baa82f8f5771e9d0eae1aa64a0618b293d8dc1f0`. These references keep their own licenses and do not imply that the Dart implementation has an independent cryptographic certification.
