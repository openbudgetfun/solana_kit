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
