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

When you already have an `Rpc`, prefer typed convenience helpers over raw
method-name strings. They keep parameter builders and response models attached
to the method itself, which makes refactors and autocomplete significantly
safer.

```dart
import '__RPC_IMPORT_PATH__';

Future<void> main() async {
  final rpc = createSolanaRpc(url: '__RPC_URL__');

  final slot = await rpc.getSlot().send();
  final epochInfo = await rpc.getEpochInfo().send();
  final latestBlockhash = await rpc.getLatestBlockhashValue().send();

  print('Slot: $slot');
  print('Epoch: ${epochInfo['epoch']}');
  print('Latest blockhash: ${latestBlockhash.value.blockhash}');
}
```

These helpers forward to canonical request builders in `solana_kit_rpc_api`,
return lazy `PendingRpcRequest<T>` values, and make it clear which Solana RPC
shape each call expects.

<!-- {/typedRpcMethodsSection} -->

<!-- {@typedUnionHelpersSection} -->

### Typed Union Helpers

Prefer typed union helpers when a codec has a fixed, small number of variants.
They improve IDE type inference, make exhaustive matching easier, and reduce
unstructured casting in downstream code.

```dart
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

void main() {
  final codec = getUnion2Codec(
    getU8Codec(),
    getU32Codec(),
    (bytes, offset) => bytes.length - offset > 1 ? 1 : 0,
  );

  final encoded = codec.encode(const Union2Variant1<int, int>(1000));
  final decoded = codec.decode(encoded);

  print(encoded);
  print(decoded);
}
```

Use these helpers when your wire format has “one of a few known cases” and you
want the Dart type system to preserve that fact.

<!-- {/typedUnionHelpersSection} -->

<!-- {@isolateJsonDecodeSection} -->

### Optional Isolate JSON Decoding

For large Solana RPC payloads, you can offload BigInt-aware JSON parsing to a
background isolate so the main isolate stays responsive.

```dart
import '__RPC_TRANSPORT_IMPORT_PATH__';

void main() {
  final transport = createHttpTransportForSolanaRpc(
    url: '__RPC_URL__',
    decodeSolanaJsonInIsolate: true,
    solanaJsonIsolateThreshold: 262144,
  );

  print(transport);
}
```

For direct parsing, use `parseJsonWithBigIntsAsync(...)` with
`runInIsolate: true`. Reserve isolate parsing for larger payloads where the
extra hop is worth the reduced UI or server-request blocking.

<!-- {/isolateJsonDecodeSection} -->

<!-- {@errorDomainHelpersSection} -->

### Typed Error Domains

`solana_kit_errors` includes domain helpers layered over numeric error codes.
Use them to route error handling without hardcoding code ranges throughout your
application.

```dart
import 'package:solana_kit_errors/solana_kit_errors.dart';

void handleSolanaFailure(SolanaError error) {
  if (error.isInDomain(SolanaErrorDomain.rpc)) {
    print('RPC failure: $error');
    return;
  }

  if (error.isInDomain(SolanaErrorDomain.transaction)) {
    print('Transaction failure: $error');
    return;
  }

  print('Unhandled Solana error: $error');
}
```

This keeps your error-routing logic readable while still preserving the exact
numeric code and context payload when you need lower-level diagnostics.

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

# Enforce risk-tier package coverage floors
coverage:check

# Run doc-comment snippet checks extracted from synchronized library docs
test:doc-snippets

# Validate markdown templates, Dart doc comments, and generated docs
# (also runs mdt doctor and workspace docs drift checks)
docs:check

# Regenerate documentation template consumers, Dart doc comments, and workspace docs
docs:update

# Inspect mdt provider/consumer state and cache reuse
mdt:info

# Run actionable mdt health checks
mdt:doctor

# Check tracked upstream compatibility metadata
upstream:check

# Compare selected Dart behaviors against the tracked @solana/kit release
upstream:parity

# Audit current Dart and pnpm lockfiles for known vulnerabilities
audit:deps

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

<!-- {@preferredDartPathCalloutSection} -->

> **Preferred Dart path**
>
> PREFERRED_PATH_TOKEN
>
> ESCAPE_HATCH_GUIDANCE_TOKEN

<!-- {/preferredDartPathCalloutSection} -->

<!-- {@compatibilityNoteCalloutSection} -->

> **Compatibility note**
>
> COMPATIBILITY_BEHAVIOR_TOKEN
>
> PREFERRED_BEHAVIOR_TOKEN

<!-- {/compatibilityNoteCalloutSection} -->

<!-- {@securityNoteCalloutSection} -->

> **Security note**
>
> SECURITY_GUIDANCE_TOKEN
>
> SECURITY_AVOIDANCE_TOKEN

<!-- {/securityNoteCalloutSection} -->

<!-- {@androidOnlyMwaCalloutSection} -->

> **Android-only Mobile Wallet Adapter**
>
> Real wallet handoff is available only on Android today.
>
> On iOS, `solana_kit_mobile_wallet_adapter` remains a safe stub/no-op because
> the current Solana MWA ecosystem does not expose an equivalent iOS
> integration target.
>
> MWA_FALLBACK_GUIDANCE_TOKEN

<!-- {/androidOnlyMwaCalloutSection} -->

<!-- {@parityStatusCalloutSection} -->

> **Parity status**
>
> PARITY_STATUS_TOKEN
>
> PARITY_NEXT_TOKEN

<!-- {/parityStatusCalloutSection} -->

<!-- {@docsTypedRpcSolanaKitSection} -->

### Typed RPC methods

When you already have an `Rpc`, prefer typed convenience helpers over raw
method-name strings. They keep parameter builders and response models attached
to the method itself, which makes refactors and autocomplete significantly
safer.

```dart
import 'package:solana_kit/solana_kit.dart';

Future<void> main() async {
  final rpc = createSolanaRpc(url: 'https://api.mainnet-beta.solana.com');

  final slot = await rpc.getSlot().send();
  final epochInfo = await rpc.getEpochInfo().send();
  final latestBlockhash = await rpc.getLatestBlockhashValue().send();

  print('Slot: $slot');
  print('Epoch: ${epochInfo['epoch']}');
  print('Latest blockhash: ${latestBlockhash.value.blockhash}');
}
```

These helpers forward to canonical request builders in `solana_kit_rpc_api`,
return lazy `PendingRpcRequest<T>` values, and make it clear which Solana RPC
shape each call expects.

<!-- {/docsTypedRpcSolanaKitSection} -->

<!-- {@docsIsolateJsonDecodeHttpSection} -->

### Optional Isolate JSON Decoding

For large Solana RPC payloads, you can offload BigInt-aware JSON parsing to a
background isolate so the main isolate stays responsive.

```dart
import 'package:solana_kit_rpc_transport_http/solana_kit_rpc_transport_http.dart';

void main() {
  final transport = createHttpTransportForSolanaRpc(
    url: 'https://api.mainnet-beta.solana.com',
    decodeSolanaJsonInIsolate: true,
    solanaJsonIsolateThreshold: 262144,
  );

  print(transport);
}
```

For direct parsing, use `parseJsonWithBigIntsAsync(...)` with
`runInIsolate: true`. Reserve isolate parsing for larger payloads where the
extra hop is worth the reduced UI or server-request blocking.

<!-- {/docsIsolateJsonDecodeHttpSection} -->

<!-- {@docsCreateRpcClientSection} -->

## Create an RPC client

Start with a typed RPC client. It gives you method-specific helpers instead of
building raw JSON-RPC requests by hand, while still letting you swap transports
or request middleware later.

```dart
import 'package:solana_kit/solana_kit.dart';

Future<void> main() async {
  final rpc = createSolanaRpc(url: 'https://api.devnet.solana.com');

  final slot = await rpc.getSlot().send();
  final latestBlockhash = await rpc.getLatestBlockhashValue().send();

  print('Current slot: $slot');
  print('Latest blockhash: ${latestBlockhash.value.blockhash}');
}
```

A call like `rpc.getSlot()` builds a typed request first and only hits the
network when you call `.send()`. That separation makes it easier to compose,
cache, batch, or decorate RPC interactions.

Use `solana_kit_rpc_subscriptions` alongside `solana_kit_rpc` when you also
need websocket notifications for accounts, signatures, logs, or slots.

<!-- {/docsCreateRpcClientSection} -->

<!-- {@docsGenerateSignerSection} -->

## Generate a signer

Most app flows need a signer for fee payment, message signing, or transaction
submission. `generateKeyPairSigner()` creates a new Ed25519 key-pair-backed
`KeyPairSigner`.

```dart
import 'package:solana_kit/solana_kit.dart';

Future<void> main() async {
  final signer = generateKeyPairSigner();

  print('Address: ${signer.address}');
}
```

Use key-pair signers for local development, tests, automation, and server-side
flows. For wallet-driven applications, you can also model fee-payer, partial,
and sending signers explicitly with `solana_kit_signers`.

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

Future<void> main() async {
  final rpc = createSolanaRpc(url: 'https://api.devnet.solana.com');
  final feePayer = generateKeyPairSigner();
  final latestBlockhash = await rpc.getLatestBlockhashValue().send();

  final instruction = Instruction(
    programAddress: const Address('11111111111111111111111111111111'),
    accounts: [
      AccountMeta(
        address: feePayer.address,
        role: AccountRole.writableSigner,
      ),
    ],
    data: Uint8List(0),
  );

  final message = createTransactionMessage(version: TransactionVersion.v0)
      .withFeePayer(feePayer.address)
      .withBlockhashLifetime(
        BlockhashLifetimeConstraint(
          blockhash: latestBlockhash.value.blockhash.value,
          lastValidBlockHeight: latestBlockhash.value.lastValidBlockHeight,
        ),
      )
      .appendInstruction(instruction);

  print(message);
}
```

This separation keeps transaction construction explicit and makes it easier to
reason about fee payment, expiry, and instruction ordering. If you prefer a
more fluent style, the transaction-message extension methods build on the same
underlying model.

<!-- {/docsBuildTransactionSection} -->

<!-- {@docsFetchAccountSection} -->

## Fetch an account

Use `fetchEncodedAccount` when you want the raw account bytes plus its Solana
metadata. Decode it later with the codec or parser that matches your program.

```dart
import 'dart:typed_data';

import 'package:solana_kit/solana_kit.dart';

Future<void> main() async {
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
}
```

Use `fetchJsonParsedAccount` when the RPC can return a structured
`jsonParsed` representation for a well-known program. Use encoded reads when
you need byte-perfect custom decoding or when the RPC does not expose a parsed
view for your program.

<!-- {/docsFetchAccountSection} -->

<!-- {@docsSendAndConfirmSection} -->

## Send and confirm a signed transaction

Once you have a signed `Transaction`, use the additive confirmation helper for
an end-to-end “send then wait for confirmation” flow.

```dart
import 'package:solana_kit/solana_kit.dart';
import 'package:solana_kit_rpc_spec/solana_kit_rpc_spec.dart';

Future<void> sendAndWait(
  Rpc rpc,
  Transaction signedTransaction,
) async {
  final signature = await sendAndConfirmTransaction(
    rpc: rpc,
    transaction: signedTransaction,
  );

  print('Confirmed signature: ${signature.value}');
}
```

For lower-level control, `solana_kit_transaction_confirmation` also exposes
strategy factories for block-height expiry, durable nonce invalidation,
signature notifications, and timeout racing.

<!-- {/docsSendAndConfirmSection} -->

<!-- {@docsDecodeAccountSection} -->

## Decode a fetched account

Keep transport and binary-layout logic separate: fetch the encoded account
first, then decode it with the codec or decoder that matches your program.

```dart
import 'package:solana_kit/solana_kit.dart';
import 'package:solana_kit_rpc_spec/solana_kit_rpc_spec.dart';

Future<void> loadDecodedAccount(
  Rpc rpc,
  Address address,
  Decoder<int> decoder,
) async {
  final maybeEncoded = await fetchEncodedAccount(rpc, address);
  final maybeDecoded = decodeMaybeAccount(maybeEncoded, decoder);

  switch (maybeDecoded) {
    case ExistingAccount<int>(:final account):
      print('Decoded value: ${account.data}');
    case NonExistingAccount():
      print('Account not found: $address');
  }
}
```

This boundary keeps RPC concerns, existence handling, and binary decoding easy
to test independently.

<!-- {/docsDecodeAccountSection} -->

<!-- {@docsTransactionSignerHelpersSection} -->

## Sign a compiled transaction with explicit signers

Use the transaction-level signer helpers when your signers are resolved outside
of the message itself or when you need to work with a compiled `Transaction`
directly.

```dart
import 'package:solana_kit/solana_kit.dart';

Future<void> partiallySign(
  List<Object> signers,
  Transaction transaction,
) async {
  final partiallySigned = await partiallySignTransactionWithSigners(
    signers,
    transaction,
  );

  print(partiallySigned.signatures.length);
}
```

This is especially useful for wallet adapters, remote signers, or orchestration
layers that gather signatures in more than one step.

<!-- {/docsTransactionSignerHelpersSection} -->

<!-- {@docsPatternMatchCodecSection} -->

### Pattern-match codecs

Use pattern-match codecs when you need to choose a codec based on either the
incoming bytes or the value being encoded.

```dart
import 'dart:typed_data';

import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

void main() {
  final codec = getPatternMatchCodec<num, int>([
    ((value) => value < 256, (bytes) => bytes.length == 1, getU8Codec()),
    ((value) => value >= 256, (bytes) => bytes.length == 2, getU16Codec()),
  ]);

  final encoded = codec.encode(513);
  final decoded = codec.decode(Uint8List.fromList(encoded));

  print(decoded);
}
```

Reach for this when a layout cannot be described as a single fixed struct or
union discriminator alone.

<!-- {/docsPatternMatchCodecSection} -->

<!-- {@docsAddressPrimitivesSection} -->

## Derive and validate addresses

Use the address helpers when you need strongly typed account identifiers,
validation, or program-derived address derivation.

```dart
import 'package:solana_kit_addresses/solana_kit_addresses.dart';

Future<void> main() async {
  const programAddress = Address('11111111111111111111111111111111');

  final (pda, bump) = await getProgramDerivedAddress(
    programAddress: programAddress,
    seeds: ['vault', 'user-42'],
  );

  print('PDA: ${pda.value}');
  print('Bump: $bump');
}
```

Keep raw strings at the edges. Once a value is known to be a Solana address,
prefer carrying it as `Address` rather than repeatedly re-validating strings.

<!-- {/docsAddressPrimitivesSection} -->

<!-- {@docsCoreCodecSection} -->

## Compose core codecs

Use `solana_kit_codecs_core` when you need to adapt, wrap, or combine lower-
level encoders and decoders.

```dart
import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

void main() {
  final codec = addCodecSentinel(getU8Codec(), Uint8List.fromList([255]));

  final encoded = codec.encode(42);
  final decoded = codec.decode(encoded);

  print(encoded);
  print(decoded);
}
```

These helpers are the glue layer between simple primitive codecs and the more
specialized Solana-facing structures built on top of them.

<!-- {/docsCoreCodecSection} -->

<!-- {@docsNumberCodecSection} -->

## Encode fixed-width numbers

Use the number codecs when your binary format needs explicit integer widths and
endianness.

```dart
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

void main() {
  final codec = getU64Codec();

  final encoded = codec.encode(BigInt.from(1_000_000));
  final decoded = codec.decode(encoded);

  print(decoded);
}
```

Reach for these codecs in instruction layouts, account state structs, and any
wire format that needs exact byte-for-byte compatibility.

<!-- {/docsNumberCodecSection} -->

<!-- {@docsStringCodecSection} -->

## Encode base58 and UTF-8 strings

Use the string codecs for base58/base64/base16 conversions plus UTF-8 handling
when a Solana API crosses between bytes and text.

```dart
import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';

void main() {
  final codec = getBase58Codec();

  final encoded = codec.encode('11111111111111111111111111111111');
  final decoded = codec.decode(encoded);

  print(decoded);
}
```

These codecs are especially useful for addresses, signatures, blockhashes, and
other values that appear as base-encoded strings at API boundaries.

For UTF-8 specifically, `getUtf8Codec()` preserves `@solana/kit`
compatibility by stripping decoded null characters. Prefer
`getStrictUtf8Codec()` or
`getUtf8Codec(nullCharacterMode: Utf8NullCharacterMode.reject)` when silent
null-byte stripping would be risky.

<!-- {/docsStringCodecSection} -->

<!-- {@docsInstructionPrimitivesSection} -->

## Model an instruction

Use `Instruction` plus `AccountMeta` when you need to describe a program call
before building a full transaction message around it.

```dart
import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

void main() {
  const programAddress = Address('11111111111111111111111111111111');
  const signerAddress = Address('11111111111111111111111111111111');

  final instruction = Instruction(
    programAddress: programAddress,
    accounts: const [
      AccountMeta(
        address: signerAddress,
        role: AccountRole.writableSigner,
      ),
    ],
    data: Uint8List(0),
  );

  print(isInstructionForProgram(instruction, programAddress));
}
```

Keeping instruction construction explicit makes it easier to reason about
required signer privileges, writable accounts, and serialized program data.

<!-- {/docsInstructionPrimitivesSection} -->

<!-- {@docsKeyPairSection} -->

## Generate keys and verify signatures

Use the key primitives when you need raw Ed25519 key material or signature
verification outside the higher-level signer abstractions.

```dart
import 'dart:typed_data';

import 'package:solana_kit_keys/solana_kit_keys.dart';

void main() {
  final keyPair = generateKeyPair();
  final message = Uint8List.fromList([1, 2, 3]);

  final signature = signBytes(keyPair.privateKey, message);
  final verified = verifySignature(keyPair.publicKey, signature, message);

  print(verified);
}
```

This package is the right layer when you need direct access to key bytes,
public-key derivation, or low-level signature helpers.

<!-- {/docsKeyPairSection} -->

<!-- {@docsCompileTransactionSection} -->

## Compile a transaction for signing

Once a transaction message has a fee payer, lifetime, and instructions, compile
it into the wire-ready transaction shape that signers and senders consume.

```dart
import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';
import 'package:solana_kit_transactions/solana_kit_transactions.dart';

void main() {
  final message = createTransactionMessage(version: TransactionVersion.v0)
      .withFeePayer(const Address('11111111111111111111111111111111'))
      .withBlockhashLifetime(
        BlockhashLifetimeConstraint(
          blockhash: '11111111111111111111111111111111',
          lastValidBlockHeight: BigInt.zero,
        ),
      )
      .appendInstruction(
        Instruction(
          programAddress: const Address('11111111111111111111111111111111'),
          accounts: const [
            AccountMeta(
              address: Address('11111111111111111111111111111111'),
              role: AccountRole.readonly,
            ),
          ],
          data: Uint8List(0),
        ),
      );

  final transaction = compileTransaction(message);

  print(transaction.signatures.length);
}
```

Compilation is the boundary where account ordering, signer sets, and lifetime
constraints are frozen into the bytes that will actually be signed.

<!-- {/docsCompileTransactionSection} -->

<!-- {@docsSysvarSection} -->

## Work with sysvar codecs and addresses

Use `solana_kit_sysvars` when you need typed access to built-in cluster state
accounts such as `Clock`, `Rent`, or `EpochSchedule`.

```dart
import 'package:solana_kit_sysvars/solana_kit_sysvars.dart';

void main() {
  final clock = SysvarClock(
    slot: BigInt.from(100),
    epochStartTimestamp: BigInt.from(50),
    epoch: BigInt.from(2),
    leaderScheduleEpoch: BigInt.from(2),
    unixTimestamp: BigInt.from(1_700_000_000),
  );

  final encoded = getSysvarClockCodec().encode(clock);
  final decoded = getSysvarClockCodec().decode(encoded);

  print(sysvarClockAddress.value);
  print(decoded.slot);
}
```

These helpers keep sysvar access strongly typed and let you test sysvar layouts
without depending on live RPC responses.

<!-- {/docsSysvarSection} -->
