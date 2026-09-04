---
title: Publish a dApp to the Solana Mobile dApp Store
description: Publish, resume, and automate dApp version releases to the Solana Mobile dApp Store with the solana_kit_dapp_publisher_cli.
---

Publishing a dApp to the [Solana Mobile dApp Store](https://solanamobile.com/developers) involves minting a release NFT, verifying its collection membership, and submitting it for store review. The `solana_kit_dapp_publisher_cli` package wraps that entire workflow behind a single CLI command backed by the [Solana Mobile Publisher Portal](https://publish.solanamobile.com).

## Installation

Install the CLI globally from pub.dev:

```bash
dart pub global activate solana_kit_dapp_publisher_cli
```

This exposes the `dapp-store` executable on your PATH. Verify:

```bash
dapp-store --version
```

## Prerequisites

Before you can publish, you need four things:

1. **A Publisher Portal account** with your dApp registered and its App NFT minted. Go to [publish.solanamobile.com](https://publish.solanamobile.com), create an account, and register your dApp with its Android package name (e.g. `com.example.myapp`).

2. **A portal API key**. Generate one from the [Publisher Portal settings](https://publish.solanamobile.com/dashboard/settings/api-keys). The CLI reads it from an environment variable or stdin — never from argv — so it won't leak into process listings or shell history.

3. **A signer keypair** in the Solana CLI JSON format (a 64-element JSON array of bytes). This keypair must be the publisher wallet registered in the portal. It signs the release mint and collection verification transactions locally.

4. **A release-ready APK** signed with your release key. Either a local file path or an HTTPS URL where the portal can download it.

## Quick start

### Publish from a local APK

```bash
export DAPP_STORE_API_KEY="your-api-key-here"

dapp-store \
  --apk-file ./build/app/outputs/flutter-apk/app-release.apk \
  --whats-new "Add dark mode and fix navigation crash on Android 14" \
  --keypair ~/.config/solana/id.json
```

### Publish from an externally hosted APK

If you host the APK on your own CDN or GitHub Releases:

```bash
dapp-store \
  --apk-url https://github.com/your-org/your-app/releases/download/v1.2.0/app-release.apk \
  --whats-new "Initial dApp Store release" \
  --keypair ~/.config/solana/id.json \
  --api-key-stdin <<< "$DAPP_STORE_API_KEY"
```

The portal downloads the APK from the URL and handles ingestion, so you don't need to upload the file yourself.

### Resume a partially completed publication

If the CLI is interrupted (network failure, CI timeout, manual abort), you can resume from where it left off using the release ID or session ID printed by the failed run:

```bash
dapp-store resume \
  --release-id <release-id-from-previous-run> \
  --keypair ~/.config/solana/id.json
```

Or with a session ID:

```bash
dapp-store resume \
  --session-id <session-id> \
  --keypair ~/.config/solana/id.json
```

## CLI reference

### Root command (publish a new version)

```
dapp-store [options]
```

| Flag                      | Description                                                                 | Required              |
| ------------------------- | --------------------------------------------------------------------------- | --------------------- |
| `--apk-file <path>`       | Path to the APK file to publish                                             | Yes (or `--apk-url`)  |
| `--apk-url <url>`         | HTTPS URL for an externally hosted APK                                      | Yes (or `--apk-file`) |
| `--whats-new <text>`      | Release notes for this version                                              | Yes                   |
| `--keypair <path>`        | Path to the Solana signer keypair (JSON)                                    | Yes                   |
| `--portal-url <url>`      | Portal base URL (default: production)                                       | No                    |
| `--api-key-env <name>`    | Env var containing the API key (default: `DAPP_STORE_API_KEY`)              | No                    |
| `--api-key-stdin`         | Read the API key from stdin                                                 | No                    |
| `--rpc-url <url>`         | RPC endpoint for the balance preflight (defaults to the Solana mainnet API) | No                    |
| `--local-dev`             | Allow localhost portal endpoints for local development                      | No                    |
| `--skip-self-update`      | Skip the self-update gate (local development only)                          | No                    |
| `--idempotency-key <key>` | Idempotency key for safe retries                                            | No                    |
| `--verbose`               | Print detailed publication identifiers                                      | No                    |

The portal base URL can also be set through the `DAPP_STORE_PORTAL_URL` environment variable instead of `--portal-url`.

### Resume command

```
dapp-store resume [options]
```

| Flag                    | Description                                  |
| ----------------------- | -------------------------------------------- |
| `--release-id <id>`     | Resume by release identifier                 |
| `--session-id <id>`     | Resume by publication session identifier     |
| `--resume-release <id>` | Alias for `--release-id`                     |
| `--resume-session <id>` | Alias for `--session-id`                     |
| `--keypair <path>`      | Path to the Solana signer keypair (required) |
| `--portal-url <url>`    | Portal base URL                              |
| `--api-key-env <name>`  | Env var containing the API key               |
| `--api-key-stdin`       | Read the API key from stdin                  |
| `--local-dev`           | Allow localhost portal endpoints             |
| `--verbose`             | Print detailed identifiers                   |

### Global flags

| Flag            | Description           |
| --------------- | --------------------- |
| `--version`     | Print the CLI version |
| `--help` / `-h` | Print help text       |

## How the publication works

The CLI drives a multi-step workflow through the Publisher Portal:

1. **APK ingestion** — the APK is uploaded to portal storage (or the portal downloads it from the external URL), then processed to extract the Android package name, version code, certificate fingerprint, permissions, and locales.

2. **Release metadata** — the portal builds a release NFT metadata document from the APK metadata and your portal configuration. The CLI uploads any media that isn't already on portal storage.

3. **Release NFT minting** — the portal prepares a Metaplex Token Metadata create transaction. The CLI validates it locally (blockhash, fee payer, signer set, program IDs, collection reference, pre-signed mint) and then signs it with your keypair before submitting it back to the portal for on-chain submission.

4. **Collection verification** — the portal prepares a verify-collection transaction. The CLI validates it and signs it.

5. **Attestation** — the CLI builds a signed attestation payload that binds the current blockhash and a unique request ID to prove the request originated from the publisher.

6. **Store submission** — the release is submitted to the dApp Store for review. You'll receive a HubSpot ticket ID for tracking.

## Using the Dart API programmatically

If you want to embed the publishing workflow in your own Dart code instead of shelling out to the CLI:

```dart
import 'dart:io';

import 'package:solana_kit_dapp_publisher_cli/solana_kit_dapp_publisher_cli.dart';

Future<void> main() async {
  // 1. Resolve the portal endpoint. Without a portal URL this defaults to
  //    the production portal (https://publish.solanamobile.com).
  final targets = resolvePortalTargets(localDev: false);

  // 2. Resolve the API key from DAPP_STORE_API_KEY (or pass apiKeyEnv:).
  final apiKey = await resolveApiKey(
    environment: Platform.environment,
  );

  // 3. Load the signer keypair from a Solana CLI JSON keypair file.
  final signer = loadSignerKeypair(
    Platform.environment['HOME']! + '/.config/solana/id.json',
    fileReader: (path) => File(path).readAsBytesSync(),
  );

  // 4. Run the balance preflight (optional but recommended).
  final warning = await ensurePublicationSignerBalance(
    publicKey: signer.address,
    localDev: false,
  );
  if (warning != null) {
    print('Warning: $warning');
  }

  // 5. Build the portal clients (workflow + attestation share the config).
  final config = PortalClientConfig(
    apiBaseUrl: targets.apiBaseUrl,
    apiKey: apiKey,
  );

  // 6. Start the publication workflow.
  final workflow = PublicationWorkflow(
    createPortalWorkflowClient(config),
    options: PublicationWorkflowOptions(
      logger: (message, {required step, required status}) {
        print('[$step/$status] $message');
      },
    ),
  );

  final result = await workflow.startPublication(
    PublicationWorkflowInput(
      source: ApkUrlSource(
        url: 'https://files.example.com/app.apk',
        fileName: 'app.apk',
      ),
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

The same pattern works for resuming: call `workflow.resumePublication(PublicationResumeInput(signer: ..., attestationClient: ..., releaseId: ...))` instead of `startPublication`.

## Automating publishing with GitHub Actions

### Basic setup

Add your portal API key and publisher keypair as repository secrets:

| Secret                         | Description                                                             |
| ------------------------------ | ----------------------------------------------------------------------- |
| `DAPP_STORE_API_KEY`           | Your portal API key from the Publisher Portal settings.                 |
| `DAPP_STORE_PUBLISHER_KEYPAIR` | The full contents of your Solana CLI keypair JSON file, base64-encoded. |

> **Security note**: Never commit your keypair to the repository. Use GitHub encrypted secrets, and scope the keypair to the `main` branch (or a dedicated publishing branch) so only trusted workflows can access it.

### Workflow: publish on version tag push

This workflow publishes a new dApp version whenever you push a version tag (e.g. `v1.2.0`). It builds the APK, then invokes the CLI:

```yaml
# .github/workflows/publish-dapp-store.yml
name: Publish to Solana dApp Store

on:
  push:
    tags:
      - "v[0-9]+.[0-9]+.[0-9]+*"

jobs:
  publish:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-java@v4
        with:
          distribution: zulu
          java-version: "17"

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
          echo "${{ secrets.DAPP_STORE_PUBLISHER_KEYPAIR }}" | base64 -d > /tmp/publisher-keypair.json
          chmod 600 /tmp/publisher-keypair.json

      - name: Extract version from tag
        id: version
        run: echo "version=${GITHUB_REF#refs/tags/v}" >> "$GITHUB_OUTPUT"

      - name: Publish to dApp Store
        env:
          DAPP_STORE_API_KEY: ${{ secrets.DAPP_STORE_API_KEY }}
        run: |
          dapp-store \
            --apk-file build/app/outputs/flutter-apk/app-release.apk \
            --whats-new "Release ${{ steps.version.outputs.version }}" \
            --keypair /tmp/publisher-keypair.json \
            --verbose

      - name: Clean up keypair
        if: always()
        run: rm -f /tmp/publisher-keypair.json
```

### Workflow: publish with an externally hosted APK

If your APK is already hosted (e.g. on GitHub Releases), skip the build step:

```yaml
name: Publish dApp Store release

on:
  workflow_dispatch:
    inputs:
      apk_url:
        description: HTTPS URL of the APK to publish
        required: true
        type: string
      whats_new:
        description: Release notes
        required: true
        type: string

jobs:
  publish:
    runs-on: ubuntu-latest
    steps:
      - name: Install dapp-store CLI
        run: dart pub global activate solana_kit_dapp_publisher_cli

      - name: Add pub global bin to PATH
        run: echo "$HOME/.pub-cache/bin" >> "$GITHUB_PATH"

      - name: Decode publisher keypair
        run: |
          echo "${{ secrets.DAPP_STORE_PUBLISHER_KEYPAIR }}" | base64 -d > /tmp/publisher-keypair.json
          chmod 600 /tmp/publisher-keypair.json

      - name: Publish
        env:
          DAPP_STORE_API_KEY: ${{ secrets.DAPP_STORE_API_KEY }}
        run: |
          dapp-store \
            --apk-url "${{ inputs.apk_url }}" \
            --whats-new "${{ inputs.whats_new }}" \
            --keypair /tmp/publisher-keypair.json

      - name: Clean up
        if: always()
        run: rm -f /tmp/publisher-keypair.json
```

### Workflow: build and publish on merge to main

For continuous deployment where every merge to `main` publishes a new version:

```yaml
name: Publish to dApp Store

on:
  push:
    branches: [main]

jobs:
  build-and-publish:
    runs-on: ubuntu-latest
    if: github.event.head_commit.message !~ /^\S*(chore|docs|ci|test)\(/
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-java@v4
        with:
          distribution: zulu
          java-version: 17

      - uses: subosito/flutter-action@v2
        with:
          channel: stable
          cache: true

      - name: Build release APK
        run: |
          flutter build apk --release \
            --build-number ${{ github.run_number }} \
            --dart-define=GIT_SHA=${{ github.sha }}

      - name: Install dapp-store CLI
        run: dart pub global activate solana_kit_dapp_publisher_cli

      - name: Add pub global bin to PATH
        run: echo "$HOME/.pub-cache/bin" >> "$GITHUB_PATH"

      - name: Decode publisher keypair
        run: |
          echo "${{ secrets.DAPP_STORE_PUBLISHER_KEYPAIR }}" | base64 -d > /tmp/publisher-keypair.json
          chmod 600 /tmp/publisher-keypair.json

      - name: Publish to dApp Store
        env:
          DAPP_STORE_API_KEY: ${{ secrets.DAPP_STORE_API_KEY }}
        run: |
          dapp-store \
            --apk-file build/app/outputs/flutter-apk/app-release.apk \
            --whats-new "Automated release from commit $(git rev-parse --short HEAD)" \
            --keypair /tmp/publisher-keypair.json \
            --idempotency-key "${{ github.sha }}" \
            --verbose

      - name: Upload APK artifact
        uses: actions/upload-artifact@v4
        with:
          name: app-release-apk
          path: build/app/outputs/flutter-apk/app-release.apk

      - name: Remove keypair
        if: always()
        run: rm -f /tmp/publisher-keypair.json
```

### Workflow: retry a failed publication

If a publication fails mid-way (e.g. the CI runner times out during ingestion), you can resume it:

```yaml
name: Resume dApp Store publication

on:
  workflow_dispatch:
    inputs:
      release_id:
        description: Release ID from the failed publication
        required: true
        type: string

jobs:
  resume:
    runs-on: ubuntu-latest
    steps:
      - name: Install dapp-store CLI
        run: dart pub global activate solana_kit_dapp_publisher_cli

      - name: Decode keypair
        run: |
          echo "${{ secrets.DAPP_STORE_PUBLISHER_KEYPAIR }}" | base64 -d > /tmp/publisher-keypair.json
          chmod 600 /tmp/publisher-keypair.json

      - name: Resume publication
        env:
          DAPP_STORE_API_KEY: ${{ secrets.DAPP_STORE_API_KEY }}
        run: |
          dapp-store resume \
            --release-id "${{ inputs.release_id }}" \
            --keypair /tmp/publisher-keypair.json \
            --verbose

      - name: Clean up
        if: always()
        run: rm -f /tmp/publisher-keypair.json
```

### Workflow: macOS runner with codesigned APK

If you build with Xcode and need to codesign, use a macOS runner:

```yaml
name: Publish iOS/Android to dApp Store

on:
  push:
    tags: ["v*"]

jobs:
  publish:
    runs-on: macos-latest
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
          echo "${{ secrets.DAPP_STORE_PUBLISHER_KEYPAIR }}" | base64 -d > /tmp/publisher-keypair.json
          chmod 600 /tmp/publisher-keypair.json

      - name: Publish
        env:
          DAPP_STORE_API_KEY: ${{ secrets.DAPP_STORE_API_KEY }}
        run: |
          dapp-store \
            --apk-file build/app/outputs/flutter-apk/app-release.apk \
            --whats-new "${{ github.ref_name }}" \
            --keypair /tmp/publisher-keypair.json

      - name: Remove keypair
        if: always()
        run: rm -f /tmp/publisher-keypair.json
```

## Setting up your own project for automated publishing

Here's a minimal checklist for a Flutter project that wants to publish to the Solana dApp Store on every release:

1. **Register your dApp** at [publish.solanamobile.com](https://publish.solanamobile.com). Note the Android package name — it must match the `applicationId` in your `build.gradle`.

2. **Generate an API key** in the Publisher Portal settings.

3. **Create a publisher keypair** (if you don't already have one):
   ```bash
   solana-keygen new --outfile ~/.config/solana/publisher.json
   ```

4. **Link the keypair to your Portal account** by setting the dApp wallet address to the publisher's public key.

5. **Add the secrets** to your GitHub repository (Settings → Secrets → Actions):
   - `DAPP_STORE_API_KEY` — the portal API key
   - `DAPP_STORE_PUBLISHER_KEYPAIR` — base64-encoded keypair (`base64 -w0 < publisher.json`)

6. **Add the workflow** (`.github/workflows/publish-dapp-store.yml`) from one of the examples above.

7. **Publish** by pushing a version tag:
   ```bash
   git tag v1.0.0 && git push origin v1.0.0
   ```

## Security considerations

- **Transaction validation**: The CLI validates every portal-prepared transaction locally before signing. It checks the blockhash, fee payer, required signer set, program IDs (only compute budget and token metadata are allowed), collection metadata reference, and PDA derivations. If the portal sends a modified or malicious transaction, signing fails.
- **HTTPS enforcement**: Portal endpoints must use HTTPS. Local development (`--local-dev`) is restricted to `localhost` only.
- **Keypair handling**: The keypair is loaded from disk, used to sign in memory, and never transmitted. Only the signature bytes are sent to the portal.
- **API key handling**: The API key is stored in a `SensitiveString` wrapper that redacts its value in `toString()` and uses constant-time comparison. It never appears in error messages or logs.

## Troubleshooting

| Problem                                          | Solution                                                               |
| ------------------------------------------------ | ---------------------------------------------------------------------- |
| `Portal API key is required`                     | Set `DAPP_STORE_API_KEY` or pass `--api-key-stdin`.                    |
| `Specify exactly one of --apk-file or --apk-url` | You must provide exactly one APK source.                               |
| `APK file not found`                             | Check that the path exists and the CI runner can read it.              |
| `Portal endpoints must use HTTPS`                | Use `https://` URLs, or pass `--local-dev` for localhost testing.      |
| `Publication signer mismatch`                    | The keypair doesn't match the publisher wallet in the portal.          |
| `Insufficient balance`                           | Fund the signer keypair with at least ~0.016 SOL for transaction fees. |
| `Timed out waiting for ingestion session`        | Large APKs can take tens of minutes to process. Try `resume` later.    |
