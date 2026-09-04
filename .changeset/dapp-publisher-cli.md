---
"solana_kit_dapp_publisher_cli": major
---

# Add the Solana Mobile dApp publisher CLI

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
