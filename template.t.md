<!-- {@packageDocumentationSection:"package_name"} -->

## Documentation

- Package page: https://pub.dev/packages/{{ package_name }}
- API reference: https://pub.dev/documentation/{{ package_name }}/latest/
- Workspace docs: https://openbudgetfun.github.io/solana_kit/
- Package catalog entry: https://openbudgetfun.github.io/solana_kit/reference/package-catalog#{{ package_name }}
- Source code: https://github.com/openbudgetfun/solana_kit/tree/main/packages/{{ package_name }}

For architecture notes, getting-started guides, and cross-package examples, start with the workspace docs site and then drill down into the package README and API reference.

<!-- {/packageDocumentationSection} -->

<!-- {@packageInstallSection:"package_name"} -->

## Installation

Install the package directly:

```bash
dart pub add {{ package_name }}
```

If your app uses several Solana Kit packages together, you can also depend on the umbrella package instead:

```bash
dart pub add solana_kit
```

Inside this monorepo, Dart workspace resolution uses the local package automatically.

<!-- {/packageInstallSection} -->

<!-- {@packageExampleSection} -->

## Example

Use [`__EXAMPLE_PATH__`](./__EXAMPLE_PATH__) as a runnable starting point for `__PACKAGE__`.

- Import path: `__IMPORT_PATH__`
- This section is centrally maintained with `mdt` to keep package guidance aligned.
- After updating shared docs templates, run `docs:update` from the repo root.

## Maintenance

- Validate docs in CI and locally with `docs:check`.
- Keep examples focused on one workflow and reference package README sections for deeper API details.

<!-- {/packageExampleSection} -->

<!-- {@upstreamSupportSection} -->

## Upstream Compatibility

- Latest supported `@solana/kit` version: `__SOLANA_KIT_VERSION__`
- This Dart port tracks upstream APIs and behavior through `v__SOLANA_KIT_VERSION__`.

<!-- {/upstreamSupportSection} -->

<!-- {@typedRpcMethodsSection} -->

### Typed RPC methods

When working with an `Rpc`, prefer typed convenience helpers over stringly method calls:

```dart
import '__RPC_IMPORT_PATH__';

final rpc = createSolanaRpc(url: '__RPC_URL__');
final slot = await rpc.getSlot().send();
final blockHeight = await rpc.getBlockHeight().send();
```

These helpers forward to canonical params builders in `solana_kit_rpc_api` and return lazy `PendingRpcRequest<T>` values.

<!-- {/typedRpcMethodsSection} -->

<!-- {@typedUnionHelpersSection} -->

### Typed Union Helpers

Prefer typed union helpers when a codec has a fixed, small number of variants.
They improve IDE type inference and reduce downstream casting.

```dart
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

final codec = getUnion2Codec(
  getU8Codec(),
  getU32Codec(),
  (bytes, offset) => bytes.length - offset > 1 ? 1 : 0,
);

final encoded = codec.encode(const Union2Variant1<int, int>(1000));
final decoded = codec.decode(encoded);
```

<!-- {/typedUnionHelpersSection} -->

<!-- {@isolateJsonDecodeSection} -->

### Optional Isolate JSON Decoding

For large Solana RPC payloads, you can offload BigInt-aware JSON parsing to a
background isolate.

```dart
import '__RPC_TRANSPORT_IMPORT_PATH__';

final transport = createHttpTransportForSolanaRpc(
  url: '__RPC_URL__',
  decodeSolanaJsonInIsolate: true,
  solanaJsonIsolateThreshold: 262144,
);
```

For direct parsing, use `parseJsonWithBigIntsAsync(...)` with
`runInIsolate: true`.

<!-- {/isolateJsonDecodeSection} -->

<!-- {@errorDomainHelpersSection} -->

### Typed Error Domains

`solana_kit_errors` includes domain helpers layered over numeric error codes.
Use them to route error handling without hardcoding code ranges.

```dart
import 'package:solana_kit_errors/solana_kit_errors.dart';

try {
  // ...
} on SolanaError catch (e) {
  if (e.isInDomain(SolanaErrorDomain.rpc)) {
    // Handle transport/server concerns.
  }
}
```

<!-- {/errorDomainHelpersSection} -->

<!-- {@docsWorkspaceSetupSection} -->

```bash
# Clone the repository
git clone https://github.com/openbudgetfun/solana_kit.git
cd solana_kit

# Load devenv
direnv allow

# Install binary tools and Dart dependencies
install:all
dart pub get

# Pull reference repositories used for compatibility checks
clone:repos
```

<!-- {/docsWorkspaceSetupSection} -->

<!-- {@docsWorkspaceDevCommandsSection} -->

```bash
# Lint, docs drift, formatting, and analysis checks
lint:all

# Run all package tests
test:all

# Generate merged test coverage across all packages
test:coverage

# Validate markdown templates and generated docs
# (also runs mdt doctor and workspace docs drift checks)
docs:check

# Regenerate documentation template consumers and workspace docs
docs:update

# Inspect mdt provider/consumer state and cache reuse
mdt:info

# Run actionable mdt health checks
mdt:doctor

# Check tracked upstream compatibility metadata
upstream:check

# Run local benchmark scripts across benchmark-enabled packages
bench:all

# Fix formatting and lint issues where possible
fix:all
```

<!-- {/docsWorkspaceDevCommandsSection} -->

<!-- {@docsDocsSiteCommandsSection} -->

```bash
# Serve docs site locally at http://localhost:8080
docs:site:serve

# Build static docs output for GitHub Pages
docs:site:build

# Run a smoke test against the built docs site
docs:site:smoke
```

<!-- {/docsDocsSiteCommandsSection} -->

<!-- {@docsUpstreamCompatibilitySection} -->

## Upstream Compatibility

- Latest supported `@solana/kit` version: `6.5.0`
- This Dart port tracks upstream APIs and behavior through `v6.5.0`.

<!-- {/docsUpstreamCompatibilitySection} -->

<!-- {@docsTypedRpcSolanaKitSection} -->

### Typed RPC methods

When working with an `Rpc`, prefer typed convenience helpers over stringly method calls:

```dart
import 'package:solana_kit/solana_kit.dart';

final rpc = createSolanaRpc(url: 'https://api.mainnet-beta.solana.com');
final slot = await rpc.getSlot().send();
final blockHeight = await rpc.getBlockHeight().send();
```

These helpers forward to canonical params builders in `solana_kit_rpc_api` and return lazy `PendingRpcRequest<T>` values.

<!-- {/docsTypedRpcSolanaKitSection} -->

<!-- {@docsIsolateJsonDecodeHttpSection} -->

### Optional Isolate JSON Decoding

For large Solana RPC payloads, you can offload BigInt-aware JSON parsing to a
background isolate.

```dart
import 'package:solana_kit_rpc_transport_http/solana_kit_rpc_transport_http.dart';

final transport = createHttpTransportForSolanaRpc(
  url: 'https://api.mainnet-beta.solana.com',
  decodeSolanaJsonInIsolate: true,
  solanaJsonIsolateThreshold: 262144,
);
```

For direct parsing, use `parseJsonWithBigIntsAsync(...)` with
`runInIsolate: true`.

<!-- {/docsIsolateJsonDecodeHttpSection} -->

<!-- {@docsCreateRpcClientSection} -->

## Create an RPC client

Start with a typed RPC client. It gives you method-specific helpers instead of
building raw JSON-RPC requests by hand.

```dart
import 'package:solana_kit/solana_kit.dart';

final rpc = createSolanaRpc(url: 'https://api.devnet.solana.com');

final slot = await rpc.getSlot().send();
final latestBlockhash = await rpc.getLatestBlockhash().send();

print('Current slot: $slot');
print('Latest blockhash: ${latestBlockhash.value.blockhash}');
```

Use `solana_kit_rpc_subscriptions` alongside `solana_kit_rpc` when you also
need websocket notifications for accounts, signatures, logs, or slots.

<!-- {/docsCreateRpcClientSection} -->

<!-- {@docsGenerateSignerSection} -->

## Generate a signer

Most app flows need a signer for fee payment, message signing, or transaction
submission. `generateKeyPair()` creates a new Ed25519 key pair and returns a
`KeyPairSigner`.

```dart
import 'package:solana_kit/solana_kit.dart';

final signer = await generateKeyPair();

print('Address: ${signer.address}');
```

Use key-pair signers for local development, testing, and server-side flows.
For wallet-driven applications, you can also model fee-payer, partial, and
sending signers explicitly with `solana_kit_signers`.

<!-- {/docsGenerateSignerSection} -->

<!-- {@docsBuildTransactionSection} -->

## Build a transaction message

Transaction messages are assembled incrementally. The most common pattern is:

1. Create an empty message.
2. Set the fee payer.
3. Set a lifetime constraint using a recent blockhash.
4. Append one or more instructions.

```dart
import 'dart:typed_data';

import 'package:solana_kit/solana_kit.dart';

final rpc = createSolanaRpc(url: 'https://api.devnet.solana.com');
final feePayer = await generateKeyPair();
final latestBlockhash = await rpc.getLatestBlockhash().send();

final instruction = Instruction(
  programAddress: const Address('11111111111111111111111111111111'),
  accounts: [
    AccountMeta(address: feePayer.address, role: AccountRole.writableSigner),
  ],
  data: Uint8List(0),
);

final message = createTransactionMessage()
    .pipe(setTransactionMessageFeePayer(feePayer.address))
    .pipe(
      setTransactionMessageLifetimeUsingBlockhash(
        BlockhashLifetimeConstraint(
          blockhash: latestBlockhash.value.blockhash,
          lastValidBlockHeight: latestBlockhash.value.lastValidBlockHeight,
        ),
      ),
    )
    .pipe(appendTransactionMessageInstruction(instruction));
```

This separation keeps transaction construction explicit and makes it easier to
reason about fee payment, expiry, and instruction ordering.

<!-- {/docsBuildTransactionSection} -->

<!-- {@docsFetchAccountSection} -->

## Fetch an account

Use `fetchEncodedAccount` when you want the raw account bytes plus its Solana
metadata. Decode it later with the codec or parser that matches your program.

```dart
import 'dart:typed_data';

import 'package:solana_kit/solana_kit.dart';

final rpc = createSolanaRpc(url: 'https://api.devnet.solana.com');
const address = Address('11111111111111111111111111111111');

final maybeAccount = await fetchEncodedAccount(rpc, address);

switch (maybeAccount) {
  case ExistingAccount<Uint8List>(:final account):
    print('Owner: ${account.programAddress}');
    print('Bytes: ${account.data.length}');
  case NonExistingAccount():
    print('No account exists at $address');
}
```

Use `fetchJsonParsedAccount` when the RPC can return a structured
`jsonParsed` representation for a well-known program.

<!-- {/docsFetchAccountSection} -->

<!-- {@docsSendAndConfirmSection} -->

## Send and confirm a signed transaction

Once you have a signed `Transaction`, use the additive confirmation helper for
an end-to-end “send then wait for confirmation” flow.

```dart
import 'package:solana_kit/solana_kit.dart';

final signature = await sendAndConfirmTransaction(
  rpc: rpc,
  transaction: signedTransaction,
);

print('Confirmed signature: ${signature.value}');
```

For lower-level control, `solana_kit_transaction_confirmation` also exposes
strategy factories for block-height expiry, durable nonce invalidation,
signature notifications, and timeout racing.

<!-- {/docsSendAndConfirmSection} -->
