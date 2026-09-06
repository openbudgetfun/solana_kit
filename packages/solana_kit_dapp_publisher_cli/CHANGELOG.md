# Changelog

All notable changes to this project will be documented in this file.

This changelog is managed by [monochange](https://github.com/monochange/monochange).

## solana_kit_dapp_publisher_cli [0.1.0](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_dapp_publisher_cli/v0.1.0) (2026-09-06)

### 💥 Breaking Change

#### Add the Solana Mobile dApp publisher CLI

A new portal-backed CLI for publishing dApp versions to the Solana Mobile dApp Store, installable globally via `dart pub global activate solana_kit_dapp_publisher_cli`.

The CLI talks to the Solana Mobile Publisher Portal API and handles the full publication workflow: APK upload and ingestion, release NFT minting with local transaction validation, collection verification, attestation, and store submission. It supports publishing new versions, resuming partially completed publications, and cleaning up failed releases.

```bash
dart pub global activate solana_kit_dapp_publisher_cli

dapp-store \
  --apk-file ./build/app/outputs/flutter-apk/app-release.apk \
  --whats-new "Bug fixes" \
  --keypair ~/.config/solana/id.json
```

Key APIs include `runDappStoreCli` for the CLI entry point, `PublicationWorkflow` for programmatic use, `PortalWorkflowClient` for the portal-backed client, and `signPreparedTransaction` for security-critical local transaction validation before signing.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #242](https://github.com/openbudgetfun/solana_kit/pull/242)
