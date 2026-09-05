# solana_kit_dapp_publisher_cli

[![pub.dev](https://img.shields.io/pub/v/solana_kit_dapp_publisher_cli.svg)](https://pub.dev/packages/solana_kit_dapp_publisher_cli) [![CI](https://github.com/openbudgetfun/solana_kit/actions/workflows/test.yml/badge.svg?branch=main)](https://github.com/openbudgetfun/solana_kit/actions) [![Coverage](https://codecov.io/gh/openbudgetfun/solana_kit/branch/main/graph/badge.svg?flag=solana_kit_dapp_publisher_cli)](https://codecov.io/gh/openbudgetfun/solana_kit)

Portal-backed CLI for publishing dApp versions to the [Solana Mobile dApp Store](https://solanamobile.com/developers).

The CLI drives the full publication workflow through the [Solana Mobile Publisher Portal](https://publish.solanamobile.com): APK upload and ingestion, release NFT minting, collection verification, attestation, and store submission. Your local keypair only signs the two security-critical on-chain transactions, which are validated locally before signing.

> Full documentation — including GitHub Actions recipes for every CI surface and an automated-publishing setup checklist — lives in the [Publish a dApp to the Solana dApp Store guide](https://openbudgetfun.github.io/solana_kit/guides/publish-dapp-store).

## Installation

Install the CLI globally from pub.dev:

```bash
dart pub global activate solana_kit_dapp_publisher_cli
```

Make sure `~/.pub-cache/bin` is on your `PATH`, then verify:

```bash
dapp-store --version
```

## Prerequisites

| Requirement                                                                        | Where to get it                                                                           |
| ---------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------- |
| A dApp registered in the Publisher Portal, with its App NFT minted                 | [publish.solanamobile.com](https://publish.solanamobile.com)                              |
| A portal API key                                                                   | [Publisher Portal settings](https://publish.solanamobile.com/dashboard/settings/api-keys) |
| A signer keypair (Solana CLI JSON format) whose public key is the publisher wallet | `solana-keygen new --outfile ~/.config/solana/id.json`                                    |
| A release-ready APK — a local file or an HTTPS URL the portal can download         | Your build output or a CDN / GitHub Release                                               |

The signer keypair must be funded with a small amount of SOL (~0.016 SOL) for transaction fees. The CLI runs a balance preflight before uploading and warns if the balance is low.

## Usage

### Publish a new version from a local APK

```bash
export DAPP_STORE_API_KEY="your-api-key-here"

dapp-store \
  --apk-file ./build/app/outputs/flutter-apk/app-release.apk \
  --whats-new "Add dark mode and fix a navigation crash" \
  --keypair ~/.config/solana/id.json
```

### Publish from an externally hosted APK

If you host the APK yourself (CDN, GitHub Releases, S3), let the portal download it:

```bash
dapp-store \
  --apk-url https://github.com/your-org/your-app/releases/download/v1.2.0/app.apk \
  --whats-new "Initial dApp Store release" \
  --keypair ~/.config/solana/id.json \
  --api-key-stdin <<< "$DAPP_STORE_API_KEY"
```

### Resume a partially completed publication

If a run is interrupted (network failure, CI timeout, manual abort), resume where it left off with the release ID or session ID printed by the failed run:

```bash
dapp-store resume \
  --release-id <release-id-from-previous-run> \
  --keypair ~/.config/solana/id.json
```

### CLI reference

```text
dapp-store - Portal-backed CLI for Solana Mobile dApp version publishing

Usage:
  dapp-store --apk-file ./app.apk --whats-new "Bug fixes" --keypair ./keypair.json
  dapp-store --apk-url https://example.com/app.apk --whats-new "Bug fixes" --keypair ./keypair.json
  dapp-store resume --release-id <release-id> [--session-id <session-id>]

Options:
  --apk-file <path>      Path to the APK file to publish
  --apk-url <url>        HTTPS URL for an externally hosted APK
  --whats-new <text>     What changed in this version
  --portal-url <url>     Publishing portal base URL
  --api-key-env <name>   Environment variable with the portal API key
                         (default: DAPP_STORE_API_KEY)
  --api-key-stdin        Read the portal API key from stdin
  --keypair <path>       Path to the Solana signer keypair
  --rpc-url <url>        RPC endpoint for the balance preflight
  --local-dev            Allow localhost portal endpoints
  --skip-self-update     Skip the self-update check (local development)
  --idempotency-key <k>  Idempotency key for safe retries
  --verbose              Print detailed publication identifiers
```

The portal base URL defaults to the production portal and can also be set with the `DAPP_STORE_PORTAL_URL` environment variable. The target app must already exist in the portal with its App NFT minted.

`--api-key-stdin` accepts the key on stdin:

```bash
echo "$DAPP_STORE_API_KEY" | dapp-store --api-key-stdin --apk-file ./app.apk ...
```

### Exit codes

| Code | Meaning                                                                                                                         |
| ---- | ------------------------------------------------------------------------------------------------------------------------------- |
| `0`  | Publication completed (or help/version was printed).                                                                            |
| `1`  | The publication failed. The error message is printed to stdout. Re-run `dapp-store resume` with the printed release/session ID. |

## How it works

1. **APK ingestion** — the APK is uploaded to portal storage (or downloaded by the portal from the external URL), then processed to extract the package name, version code, certificate fingerprint, permissions, and locales.
2. **Release metadata** — the portal builds the release NFT metadata document; the CLI uploads any media not already on portal storage.
3. **Release NFT minting** — the portal prepares a Metaplex Token Metadata create transaction. The CLI validates it locally and signs it with your keypair.
4. **Collection verification** — the portal prepares a verify-collection transaction. The CLI validates and signs it.
5. **Attestation** — the CLI builds an Ed25519-signed payload binding the current blockhash and a unique request ID.
6. **Store submission** — the release is submitted for dApp Store review; the CLI prints the HubSpot ticket ID for tracking.

## Programmatic usage

The same workflow is available as a Dart API, so you can embed publishing in your own tooling:

```dart
import 'dart:io';

import 'package:solana_kit_dapp_publisher_cli/solana_kit_dapp_publisher_cli.dart';

Future<void> main() async {
  // Resolve the portal endpoint (defaults to production).
  final targets = resolvePortalTargets(localDev: false);

  // Read the API key from DAPP_STORE_API_KEY.
  final apiKey = await resolveApiKey(environment: Platform.environment);

  // Load the signer keypair from a Solana CLI JSON keypair file.
  final signer = loadSignerKeypair(
    '${Platform.environment['HOME']}/.config/solana/id.json',
    fileReader: (path) => File(path).readAsBytesSync(),
  );

  // Optional: warn when the signer balance is too low to publish.
  final warning = await ensurePublicationSignerBalance(
    publicKey: signer.address,
    localDev: false,
  );
  if (warning != null) print('Warning: $warning');

  final config = PortalClientConfig(
    apiBaseUrl: targets.apiBaseUrl,
    apiKey: apiKey,
  );

  final result = await PublicationWorkflow(
    createPortalWorkflowClient(config),
    options: PublicationWorkflowOptions(
      logger: (message, {required step, required status}) =>
          print('[$step/$status] $message'),
    ),
  ).startPublication(
    PublicationWorkflowInput(
      source: ApkUrlSource(url: 'https://files.example.com/app.apk'),
      whatsNew: 'Add dark mode',
      signer: signer,
      attestationClient: createPortalAttestationClient(config),
    ),
  );

  print('Release: ${result.releaseId}');
  print('Mint: ${result.releaseMintAddress}');
  print('Ticket: ${result.hubspotTicketId}');
}
```

To resume instead, call `resumePublication(PublicationResumeInput(signer: ..., attestationClient: ..., releaseId: ...))`.

## GitHub Actions

### Secrets

| Secret                         | Description                                                                        |
| ------------------------------ | ---------------------------------------------------------------------------------- |
| `DAPP_STORE_API_KEY`           | Your portal API key.                                                               |
| `DAPP_STORE_PUBLISHER_KEYPAIR` | Your Solana CLI keypair JSON file, base64-encoded (`base64 -w0 < publisher.json`). |

### Publish on version tag push

```yaml
# .github/workflows/publish-dapp-store.yml
name: Publish to Solana dApp Store

on:
  push:
    tags: ["v[0-9]+.[0-9]+.[0-9]+*"]

jobs:
  publish:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: subosito/flutter-action@v2
        with:
          channel: stable

      - name: Build release APK
        run: flutter build apk --release

      - name: Install dapp-store CLI
        run: dart pub global activate solana_kit_dapp_publisher_cli

      - name: Add pub global bin to PATH
        run: echo "$HOME/.pub-cache/bin" >> "$GITHUB_PATH"

      - name: Decode publisher keypair
        run: |
          echo "${{ secrets.DAPP_STORE_PUBLISHER_KEYPAIR }}" \
            | base64 -d > /tmp/publisher-keypair.json
          chmod 600 /tmp/publisher-keypair.json

      - name: Publish to dApp Store
        env:
          DAPP_STORE_API_KEY: ${{ secrets.DAPP_STORE_API_KEY }}
        run: |
          dapp-store \
            --apk-file build/app/outputs/flutter-apk/app-release.apk \
            --whats-new "Release ${GITHUB_REF#refs/tags/}" \
            --keypair /tmp/publisher-keypair.json \
            --verbose

      - name: Remove keypair
        if: always()
        run: rm -f /tmp/publisher-keypair.json
```

### Publish from an externally hosted APK (no build step)

```yaml
on:
  workflow_dispatch:
    inputs:
      apk_url: { description: HTTPS URL of the APK, required: true }
      whats_new: { description: Release notes, required: true }

jobs:
  publish:
    runs-on: ubuntu-latest
    steps:
      - run: dart pub global activate solana_kit_dapp_publisher_cli
      - run: echo "$HOME/.pub-cache/bin" >> "$GITHUB_PATH"
      - run: |
          echo "${{ secrets.DAPP_STORE_PUBLISHER_KEYPAIR }}" \
            | base64 -d > /tmp/publisher-keypair.json
          chmod 600 /tmp/publisher-keypair.json
      - env:
          DAPP_STORE_API_KEY: ${{ secrets.DAPP_STORE_API_KEY }}
        run: |
          dapp-store \
            --apk-url "${{ inputs.apk_url }}" \
            --whats-new "${{ inputs.whats_new }}" \
            --keypair /tmp/publisher-keypair.json
      - if: always()
        run: rm -f /tmp/publisher-keypair.json
```

### Resume a failed publication

```yaml
on:
  workflow_dispatch:
    inputs:
      release_id: {
        description: Release ID from the failed run,
        required: true,
      }

jobs:
  resume:
    runs-on: ubuntu-latest
    steps:
      - run: dart pub global activate solana_kit_dapp_publisher_cli
      - run: echo "$HOME/.pub-cache/bin" >> "$GITHUB_PATH"
      - run: |
          echo "${{ secrets.DAPP_STORE_PUBLISHER_KEYPAIR }}" \
            | base64 -d > /tmp/publisher-keypair.json
          chmod 600 /tmp/publisher-keypair.json
      - env:
          DAPP_STORE_API_KEY: ${{ secrets.DAPP_STORE_API_KEY }}
        run: |
          dapp-store resume \
            --release-id "${{ inputs.release_id }}" \
            --keypair /tmp/publisher-keypair.json
      - if: always()
        run: rm -f /tmp/publisher-keypair.json
```

More CI surfaces — continuous publishing on merge to `main` with an idempotency key, macOS runners, and a full automated-publishing setup checklist — are covered in the [dApp Store publishing guide](https://openbudgetfun.github.io/solana_kit/guides/publish-dapp-store).

## Security

- **Local transaction validation**: every portal-prepared transaction is verified before signing — blockhash, fee payer, exact signer set, program ID allowlist (compute budget + token metadata only), Create-instruction collection match, pre-signed mint signature, and verify-collection PDA derivations. A tampered transaction from the portal is never signed.
- **HTTPS enforcement**: portal and APK endpoints must use HTTPS. `--local-dev` allows only localhost endpoints.
- **Keypair handling**: the keypair is loaded from disk and used to sign in memory; only signature bytes leave the machine.
- **API key handling**: the key lives in a `SensitiveString` wrapper with constant-time comparison and a redacting `toString()`. It is read from an environment variable or stdin, never from argv, and never appears in logs or error messages.

## Key APIs

| API                              | Description                                                                      |
| -------------------------------- | -------------------------------------------------------------------------------- |
| `runDappStoreCli`                | Runs the CLI with the given arguments and dependencies.                          |
| `PublicationWorkflow`            | Drives the full publication workflow (`startPublication` / `resumePublication`). |
| `createPortalWorkflowClient`     | Creates the portal-backed workflow client.                                       |
| `createPortalAttestationClient`  | Creates the attestation block-data provider.                                     |
| `PublicationSigner`              | Signs transactions and messages.                                                 |
| `signPreparedTransaction`        | Validates and signs a prepared portal transaction.                               |
| `buildReleaseMetadataDocument`   | Builds the release NFT metadata document.                                        |
| `ensurePublicationSignerBalance` | Checks the signer balance before publishing.                                     |
| `resolvePortalTargets`           | Resolves and validates the portal endpoint.                                      |
| `resolveApiKey`                  | Reads the portal API key from the environment or stdin.                          |
| `loadSignerKeypair`              | Loads a publication signer from a keypair file.                                  |

## Troubleshooting

| Problem                                          | Solution                                                       |
| ------------------------------------------------ | -------------------------------------------------------------- |
| `Portal API key is required`                     | Set `DAPP_STORE_API_KEY` or pass `--api-key-stdin`.            |
| `Specify exactly one of --apk-file or --apk-url` | Provide exactly one APK source.                                |
| `Portal endpoints must use HTTPS`                | Use `https://` URLs, or `--local-dev` for localhost testing.   |
| `Publication signer mismatch`                    | The keypair does not match the publisher wallet in the portal. |
| Balance warning                                  | Fund the signer with at least ~0.016 SOL.                      |
| Ingestion timeout                                | Large APKs take a while to process; `dapp-store resume` later. |

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
