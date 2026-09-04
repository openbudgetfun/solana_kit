# solana_kit_surfpool

[![Coverage](https://codecov.io/gh/openbudgetfun/solana_kit/branch/main/graph/badge.svg?flag=solana_kit_surfpool)](https://codecov.io/gh/openbudgetfun/solana_kit?flag=solana_kit_surfpool) [![website](https://img.shields.io/badge/website-solana__kit__docs-0A7EA4.svg)](https://openbudgetfun.github.io/solana_kit/reference/package-catalog#solana_kit_surfpool)

Surfpool SDK helpers for [Solana Kit](https://github.com/openbudgetfun/solana_kit) Dart tests.

This package ports Surfpool's TypeScript/Rust SDK surface to idiomatic Dart by using Surfpool's JSON-RPC cheatcodes. `Surfnet.start()` is CLI-backed: it starts `surfpool start` on random ports and then talks to that process over HTTP. This keeps the package pure Dart and avoids native napi or `flutter_rust_bridge` bindings.

## Installation

<!-- {=packageInstallSection:"solana_kit_surfpool"} -->

## Installation

Install the package directly:

```yaml
dependencies:
  "solana_kit_surfpool": ^0.3.1
```

If your app uses several Solana Kit packages together, you can also depend on the umbrella package instead:

```bash
dart pub add solana_kit
```

Inside this monorepo, Dart workspace resolution uses the local package automatically.

<!-- {/packageInstallSection} -->

`solana_kit_surfpool` is not re-exported by the umbrella `solana_kit` package; add and import this package directly when you need Surfpool helpers.

The CLI-backed runtime requires the `surfpool` executable to be available on `PATH`. In this repository, use the configured `devenv` shell.

`startupTimeout` bounds readiness health checks, including stalled HTTP requests. Failed startup stops the child process and cleans its temporary working directory. Cheatcode responses must contain a JSON-RPC 2.0 envelope with the matching request ID and exactly one result or error; malformed responses raise `SurfpoolRpcException` instead of confirming account mutations.

## Usage

```dart
import 'package:solana_kit_surfpool/solana_kit_surfpool.dart';

Future<void> main() async {
  final surfnet = await Surfnet.start();
  final alice = Surfnet.newKeypair();

  try {
    await surfnet.fundSol(alice.address, 1_000_000_000);

    final epoch = await surfnet.timeTravelToSlot(1_000);
    print('RPC: ${surfnet.rpcUrl}');
    print('Payer: ${surfnet.payer.value}');
    print('Slot: ${epoch.absoluteSlot}');
  } finally {
    await surfnet.stop();
  }
}
```

Connect to an existing Surfpool process when you manage `surfpool start` yourself:

```dart
import 'package:solana_kit_surfpool/solana_kit_surfpool.dart';

void main() {
  final surfnet = Surfnet.connect(
    rpcUrl: Uri.parse('http://127.0.0.1:8899'),
    wsUrl: Uri.parse('ws://127.0.0.1:8900'),
  );
  print(surfnet.rpcUrl);
}
```

## Solana Kit client (kit plugin)

`createSurfpoolClient()` mirrors the `@solana/surfpool/kit` plugin for TypeScript: it starts a fresh Surfnet and returns a `SurfpoolClient` with a Solana Kit RPC client, an RPC subscriptions client, the Surfnet's pre-funded payer signer, and a typed cheatcode RPC — so tests can build, sign, send, and confirm transactions without managing a validator or RPC plumbing by hand.

```dart
import 'package:solana_kit/solana_kit.dart';
import 'package:solana_kit_surfpool/solana_kit_surfpool.dart';

Future<void> main() async {
  final client = await createSurfpoolClient();
  try {
    // Pre-funded payer installed by the plugin.
    final payer = client.payer;

    // Standard Solana RPC and subscriptions clients.
    final slot = await client.rpc.getSlot().send();
    print('Slot: $slot');

    // Surfpool cheatcodes with the `surfnet_` prefix stripped.
    await client.cheatcodes.pauseClock();

    // Helpers.
    await client.airdrop(payer.address, BigInt.from(1_000_000_000));
    final rent = await client.getMinimumBalance(BigInt.zero);
    print('Rent-exempt minimum: $rent');
  } finally {
    await client.stop();
  }
}
```

Stopping a freshly created client clears Surfnet's in-memory payer bytes and disposes the client-owned payer signer. A signer supplied to `connectSurfpoolClient` remains caller-owned and is not disposed.

Attach to an already-running Surfpool with `connectSurfpoolClient`; the [`payer`] must be a funded signer you provide:

```dart
import 'package:solana_kit_signers/solana_kit_signers.dart';
import 'package:solana_kit_surfpool/solana_kit_surfpool.dart';

void main() {
  final myFundedSigner = generateKeyPairSigner();
  final client = connectSurfpoolClient(
    rpcUrl: Uri.parse('http://127.0.0.1:8899'),
    payer: myFundedSigner,
  );
  print(client.payer.address);
}
```

## Cheatcodes

`SurfnetCheatcodes` unwraps RPC context envelopes and returns their `value`, including `null` when a profile is absent. `profileTransaction` accepts a `config` without a `tag` and preserves the optional argument positions on the wire.

```dart
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_surfpool/solana_kit_surfpool.dart';

Future<void> main() async {
  final surfnet = await Surfnet.start();
  try {
    final owner = Surfnet.newKeypair().address;
    final mint = address('EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v');

    await surfnet.fundToken(owner, mint, 5_000_000);

    final ata = surfnet.getAta(owner, mint);
    print('ATA: ${ata.value}');

    await surfnet.setTokenAccount(
      owner,
      mint,
      const SetTokenAccountUpdate(
        state: 'initialized',
        delegatedAmount: 500_000,
      ),
    );
  } finally {
    await surfnet.stop();
  }
}
```

For advanced account fields, use the builder API:

```dart
import 'dart:typed_data';

import 'package:solana_kit_surfpool/solana_kit_surfpool.dart';

Future<void> main() async {
  final surfnet = await Surfnet.start();
  try {
    await surfnet.execute(
      SetAccount(Surfnet.newKeypair().address)
          .withLamports(500_000)
          .withData(Uint8List.fromList([1, 2, 3]))
          .withOwner(surfnet.payer)
          .withRentEpoch(0)
          .withExecutable(executable: false),
    );
  } finally {
    await surfnet.stop();
  }
}
```

## Deploy programs

```dart
import 'package:solana_kit_surfpool/solana_kit_surfpool.dart';

Future<void> main() async {
  final surfnet = await Surfnet.start();
  try {
    final programId = await surfnet.deployProgram('my_program');
    print('deployed at ${programId.value}');
  } finally {
    await surfnet.stop();
  }
}
```

`deployProgram` discovers conventional Anchor/Agave artifacts under `target/deploy` and `target/idl`. Use `deploy` with `DeployOptions` when bytes or paths live elsewhere.

## Runtime events

The upstream Rust and JS SDKs expose an in-process event channel. This Dart package does not embed the Rust runtime, so `drainEvents()` currently returns best-effort `stdoutLog` and `stderrLog` events captured from the CLI-backed process. Use RPC assertions for deterministic tests.

## Key APIs

| API                                                                | Purpose                                                            |
| ------------------------------------------------------------------ | ------------------------------------------------------------------ |
| `createSurfpoolClient()` / `connectSurfpoolClient()`               | Kit-plugin style client: RPC + subscriptions + payer + cheatcodes. |
| `SurfpoolClient.rpc` / `rpcSubscriptions` / `payer` / `cheatcodes` | Wired Solana Kit clients and the pre-funded payer.                 |
| `SurfpoolClient.airdrop` / `getMinimumBalance`                     | Funding and rent-exemption helpers.                                |
| `Surfnet.start()` / `Surfnet.startWithConfig()`                    | Start a CLI-backed local Surfnet.                                  |
| `Surfnet.connect()`                                                | Attach to an existing Surfpool RPC endpoint.                       |
| `fundSol`, `fundToken`, `setAccount`, `setTokenAccount`            | Mutate local account state through Surfpool cheatcodes.            |
| `resetAccount`, `streamAccount`                                    | Re-fetch or stream accounts from an upstream RPC.                  |
| `timeTravelToSlot`, `timeTravelToEpoch`, `timeTravelToTimestamp`   | Move the local Surfnet clock forward.                              |
| `deployProgram`, `deploy`                                          | Write program bytes and optionally register an Anchor IDL.         |
