# solana_kit_dapp_publisher_cli

[![pub.dev](https://img.shields.io/pub/v/solana_kit_dapp_publisher_cli.svg)](https://pub.dev/packages/solana_kit_dapp_publisher_cli) [![CI](https://github.com/openbudgetfun/solana_kit/actions/workflows/test.yml/badge.svg?branch=main)](https://github.com/openbudgetfun/solana_kit/actions) [![Coverage](https://codecov.io/gh/openbudgetfun/solana_kit/branch/main/graph/badge.svg?flag=solana_kit_dapp_publisher_cli)](https://codecov.io/gh/openbudgetfun/solana_kit)

Portal-backed CLI for publishing dApp versions to the [Solana Mobile dApp Store](https://solanamobile.com/developers).

## Installation

```bash
dart pub global activate solana_kit_dapp_publisher_cli
```

## Usage

Publish a new dApp version:

```bash
dapp-store \
  --apk-file ./app.apk \
  --whats-new "Bug fixes" \
  --keypair ./keypair.json \
  --api-key-env DAPP_STORE_API_KEY
```

Or with an externally hosted APK:

```bash
dapp-store \
  --apk-url https://files.example.com/app.apk \
  --whats-new "Bug fixes" \
  --keypair ./keypair.json \
  --api-key-stdin
```

Resume a partially completed publication:

```bash
dapp-store resume --release-id <release-id> --keypair ./keypair.json
```

## How it works

The CLI talks to the [Solana Mobile Publisher Portal](https://publish.solanamobile.com) API, which handles APK ingestion, release NFT minting, collection verification, and store submission. Your local keypair only signs the two on-chain transactions (release mint and collection verification); the portal submits them to the network.

### Prerequisites

- An app already created in the [Publisher Portal](https://publish.solanamobile.com) with its App NFT minted.
- A release-ready APK signed with your release key.
- A signer keypair file (Solana CLI keypair JSON).
- A portal API key from the [Publisher Portal settings](https://publish.solanamobile.com/dashboard/settings/api-keys).

### Secrets

The portal API key is read from the `DAPP_STORE_API_KEY` environment variable, or from the variable named by `--api-key-env`, or from stdin via `--api-key-stdin`. It is never passed as a command-line argument or written to disk.

### Security

- Portal endpoints must use HTTPS unless `--local-dev` is set (localhost only).
- The APK URL must use HTTPS.
- Portal transactions are validated locally before signing: the blockhash, fee payer, signer set, program IDs, and collection metadata are all verified to prevent signing modified or malicious transactions.
- The portal API key is held in a redacting wrapper and never appears in logs.

## Key APIs

| API                              | Description                                             |
| -------------------------------- | ------------------------------------------------------- |
| `runDappStoreCli`                | Runs the CLI with the given arguments and dependencies. |
| `PublicationWorkflow`            | Drives the full publication workflow.                   |
| `PortalWorkflowClient`           | Portal-backed workflow client.                          |
| `PortalAttestationClient`        | Attestation block data provider.                        |
| `PublicationSigner`              | Signs transactions and messages.                        |
| `signPreparedTransaction`        | Validates and signs a prepared portal transaction.      |
| `buildReleaseMetadataDocument`   | Builds the release NFT metadata document.               |
| `ensurePublicationSignerBalance` | Checks the signer balance before publishing.            |
| `resolvePortalTargets`           | Resolves and validates the portal endpoint.             |

## Development

```bash
# Run tests
dart test

# Analyze
dart analyze

# Format
dart format lib bin test
```

## License

MIT
