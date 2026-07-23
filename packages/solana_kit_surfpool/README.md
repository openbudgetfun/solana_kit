# solana_kit_surfpool

[![Coverage](https://codecov.io/gh/openbudgetfun/solana_kit/branch/main/graph/badge.svg?flag=solana_kit_surfpool)](https://codecov.io/gh/openbudgetfun/solana_kit?flag=solana_kit_surfpool)
[![website](https://img.shields.io/badge/website-solana__kit__docs-0A7EA4.svg)](https://openbudgetfun.github.io/solana_kit/reference/package-catalog#solana_kit_surfpool)

Surfpool SDK helpers for [Solana Kit](https://github.com/openbudgetfun/solana_kit)
Dart tests.

This package ports Surfpool's TypeScript/Rust SDK surface to idiomatic Dart by
using Surfpool's JSON-RPC cheatcodes. `Surfnet.start()` is CLI-backed: it starts
`surfpool start` on random ports and then talks to that process over HTTP. This
keeps the package pure Dart and avoids native napi or `flutter_rust_bridge`
bindings.

## Installation

<!-- {=packageInstallSection:"solana_kit_surfpool"} -->

## Installation

Install the package directly:

```yaml
dependencies:
  "solana_kit_surfpool": ^0.1.0
```

If your app uses several Solana Kit packages together, you can also depend on the umbrella package instead:

```bash
dart pub add solana_kit
```

Inside this monorepo, Dart workspace resolution uses the local package automatically.

<!-- {/packageInstallSection} -->

`solana_kit_surfpool` is not re-exported by the umbrella `solana_kit` package;
add and import this package directly when you need Surfpool helpers.

The CLI-backed runtime requires the `surfpool` executable to be available on
`PATH`. In this repository, use the configured `devenv` shell.

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

Connect to an existing Surfpool process when you manage `surfpool start`
yourself:

```dart
final surfnet = Surfnet.connect(
  rpcUrl: Uri.parse('http://127.0.0.1:8899'),
  wsUrl: Uri.parse('ws://127.0.0.1:8900'),
);
```

## Cheatcodes

```dart
import 'package:solana_kit_addresses/solana_kit_addresses.dart';

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
```

For advanced account fields, use the builder API:

```dart
import 'dart:typed_data';

await surfnet.execute(
  SetAccount(Surfnet.newKeypair().address)
      .withLamports(500_000)
      .withData(Uint8List.fromList([1, 2, 3]))
      .withOwner(surfnet.payer)
      .withRentEpoch(0)
      .withExecutable(executable: false),
);
```

## Deploy programs

```dart
final programId = await surfnet.deployProgram('my_program');
print('deployed at ${programId.value}');
```

`deployProgram` discovers conventional Anchor/Agave artifacts under
`target/deploy` and `target/idl`. Use `deploy` with `DeployOptions` when bytes
or paths live elsewhere.

## Runtime events

The upstream Rust and JS SDKs expose an in-process event channel. This Dart
package does not embed the Rust runtime, so `drainEvents()` currently returns
best-effort `stdoutLog` and `stderrLog` events captured from the CLI-backed
process. Use RPC assertions for deterministic tests.

## Key APIs

| API                                                              | Purpose                                                    |
| ---------------------------------------------------------------- | ---------------------------------------------------------- |
| `Surfnet.start()` / `Surfnet.startWithConfig()`                  | Start a CLI-backed local Surfnet.                          |
| `Surfnet.connect()`                                              | Attach to an existing Surfpool RPC endpoint.               |
| `fundSol`, `fundToken`, `setAccount`, `setTokenAccount`          | Mutate local account state through Surfpool cheatcodes.    |
| `resetAccount`, `streamAccount`                                  | Re-fetch or stream accounts from an upstream RPC.          |
| `timeTravelToSlot`, `timeTravelToEpoch`, `timeTravelToTimestamp` | Move the local Surfnet clock forward.                      |
| `deployProgram`, `deploy`                                        | Write program bytes and optionally register an Anchor IDL. |
