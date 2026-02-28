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

# Validate markdown templates and generated docs
docs:check

# Regenerate documentation template consumers and workspace docs
docs:update
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

- Latest supported `@solana/kit` version: `6.1.0`
- This Dart port tracks upstream APIs and behavior through `v6.1.0`.

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
