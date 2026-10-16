# Codebase Improvements and Feature Roadmap

## Status: Proposed

Created: 2026-10-16 Source audit: full-workspace sweep for stub patterns, silent fallbacks, dead error codes, and ignored parameters, plus a local deep-eval of every CI surface (`lint:all`, `test:all`, `upstream:parity` against `@solana/kit@8.4.0`, `test:integration`).

Fixes from the first pass of this audit shipped in [#312](https://github.com/openbudgetfun/solana_kit/pull/312): the Android compile check no longer downloads an NDK mid-build, five corrupted READMEs were repaired, and six packages stopped silently defaulting malformed external data (Helius checkout money amounts, DAS proof fields, address/base58 validation, transaction wire guards, Anchor IDL names, `stringifyJsonWithBigInts`'s ignored `space` parameter).

The codebase is in unusually good shape for its size: zero stubs, zero `UnimplementedError` escape hatches, no empty catches, and every `*Factory` performs real computation. What follows is everything the audit found that is worth doing next, ordered by expected value.

---

## Part 1 — Correctness and parity gaps (defined-but-never-thrown error codes)

The error-code enum defines 360 codes; 61 are never constructed anywhere in `packages/*/lib`. Most mark real validation gaps. Each item below was verified by grepping every throw site and checking the upstream message template.

### High value

- [ ] **FIX-01: `solana_kit_fixed_points` throws the wrong error type entirely**
  - All 13 `fixedPoints*` codes (8090000–8090012) are dead. The package throws bare `ArgumentError`, `RangeError`, and `FormatException` (`binary_fixed_point.dart:134-349`, `fixed_point_formatting.dart:36-92`) instead of `SolanaError` with the `fixedPoints*` codes, so callers cannot match fixed-point failures the way they match every other package's failures, and `strict`-mode precision loss (`fixedPointsStrictModePrecisionLoss`) surfaces as a plain `FormatException` at `binary_fixed_point.dart:315`.
  - Migration is technically breaking for callers that catch `ArgumentError` today; do it behind a changeset with a migration note, or gate on the next minor.

- [ ] **FIX-02: Mobile Wallet Adapter protocol errors never map to `SolanaError`**
  - Seven `mwa*` codes are dead: `mwaWalletNotFound` (8400005), `mwaProtocolAuthorizationFailed`/`InvalidPayloads`/`NotSigned`/`NotSubmitted`/`TooManyPayloads`/`AttestOriginAndroid` (8400100–8400105). `protocol_error.dart` defines `MwaProtocolErrorCode` and `MwaProtocolError`, but wallet-request results and the association scenarios surface the raw exception; consumers cannot pattern-match MWA failures against the standard error-code table.
  - Expected throwers: `local_association_scenario.dart` / `remote_association_scenario.dart` result handling and `intent_launcher.dart`.

- [ ] **FIX-03: Durable-nonce transaction validation is missing**
  - `transactionInvalidNonceTransactionInstructionsMissing` (5663013) and `transactionInvalidNonceTransactionFirstInstructionMustBeAdvanceNonce` (5663014) are dead. Upstream ships `assertIsDurableNonceTransaction`; the port has no equivalent anywhere in `solana_kit_transaction_messages` (`durable_nonce.dart` has no assertion helper).

- [ ] **FIX-04: Wallet-adapter operates a parallel error system**
  - `walletNotConnected`/`walletNoSignerConnected`/`walletSignerNotAvailable`/`walletAccountNotAvailable` (8900000–8900003) are dead because `controller.dart:78-224` throws `WalletStandardException(WalletStandardErrorCode.disconnected, ...)` instead. Two error systems for one concept means callers write two catch paths. Either throw the `wallet*` codes (preferred for parity) or deprecate the codes.

- [ ] **FIX-05: Websocket send path lacks the closed-channel guard**
  - `rpcSubscriptionsChannelClosedBeforeMessageBuffered` (8190002) is dead. `websocket_channel.dart:224+` checks `isClosed` internally but never guards before buffering a send; upstream fails fast with this code when the socket closes between the guard and the buffer write.

- [ ] **FIX-06: `WalletAccountSigner` multi-sign methods lack the upstream guard**
  - `signerWalletMultisignUnimplemented` (5508011) is dead; upstream's wallet-account signers throw it when asked to sign multiple messages at once. The port's `WalletAccountSigner` implements the multi-sign methods with no guard — confirm current behavior against upstream before deciding whether to throw (behavior-preserving audit first).

- [ ] **FIX-07: `subscribable` substitutes `StateError('Unknown error')`**
  - `subscribableStreamClosedWithoutError` (8195001) is dead; `async_iterable.dart:53` substitutes a bare `StateError` where upstream throws the dedicated code. Similarly the five reachable `invariantViolation*` codes (9900000–9900004) are `StateError`s in the Dart port. (`subscribableRetryNotSupported` 8195000 appears obsoleted upstream — consider deprecating.)

- [ ] **FIX-08: `writeKeyPair` has no environment guard**
  - `keysWriteKeyPairUnsupportedEnvironment` (3704006) is dead; `key_pair.dart:276` uses `dart:io` `File` directly. On web (dart2js/wasm) this fails with an opaque error. Guard with the dedicated code so the failure is at least diagnosable, and note web support in the package README.

### Lower value / accept-as-is

- `codecsExpectedZeroValueToMatchItemFixedSize` (8078019) and the two enum-codec codes (8078010, 8078022): verified that the pinned upstream `@solana/kit@8.4.0` also never throws them from the kit repo (the throw sites live in `@solana/options`/`@solana/codecs` internals or were removed). Dead-by-upstream-design; re-check on each upstream bump.
- `invariantViolationSwitchMustBeExhaustive` / `...PlanKind` codes (9900003, 9900005, 9900006): structurally unnecessary in Dart thanks to exhaustive `switch` over `sealed` hierarchies. Dead by design.
- The 10 `subtleCrypto*`/`cryptoRandomValues*`/`fsUnsupportedEnvironment` codes (3610000–3611000, 3712000): guard WebCrypto/Node availability that Dart's pointycastle/`dart:io` implementations make moot. Dead by design.
- Program-client codes `programClientsInsufficientAccountMetas`/`UnrecognizedInstructionType`/`UnrecognizedAccountType`/`FailedToIdentifyAccount` (8500000–8500006): belong in the codama renderer's generated code; see FEAT-02.

---

## Part 2 — Robustness and API-shape improvements

- [ ] **ROB-01: `pollCheckoutCompletion` cannot distinguish timeout from still-confirming**
  - `checkout.dart:489-495` converts a polling timeout into a synthetic `CheckoutStatusResponse(status: 'pending', phase: 'confirming', message: 'Polling timed out')`. Callers must string-match `message`. Return a richer outcome (or throw `TimeoutException`) so UI code does not keep showing "confirming" forever.

- [ ] **ROB-02: `getAssetWithProof` wraps fetch failures in `ParallelWaitError`**
  - `das_api.dart:407-410` awaits the asset and proof futures with record-`.wait`, so any single failure surfaces as `ParallelWaitError<(DasAsset?, DasAssetProof?), ...>` instead of the underlying error. Await sequentially or unwrap the first error; the wrapped type is awkward for callers to handle.

- [ ] **ROB-03: CI's `android-plugin-compile` still auto-installs the platform it needs**
  - #312 removed the NDK download; the job pre-installs `platforms;android-34`/`build-tools;34.0.0` and relies on AGP's auto-installer for anything newer the Flutter template wants. Consider pinning the template's `compileSdk` in the check script (the same rewrite that strips `ndkVersion`) so the job never auto-installs mid-build.

- [ ] **ROB-04: mdt 0.9.6 will reformat 41 consumer blocks**
  - The devenv pin is mdt 0.9.5; 0.9.6 adds the unmatched-tag validation (the #312 README repairs make the tree clean under it) but also reformats 41 generated blocks. Schedule a dedicated `docs:update` run together with the next mdt pin bump so the bump is a mechanical diff instead of a broken lint.

- [ ] **ROB-05: `getTuple2Decoder` guards length only with an `assert`**
  - `tuple.dart:134-136` — the length check vanishes in release builds. It guards a structural invariant `getTupleDecoder` guarantees by construction, so leaving it is defensible; converting to a real check costs one comparison per decode if ever in doubt.

---

## Part 3 — New features

- [ ] **FEAT-01: Port `getEnumCodec`**
  - Upstream `codecs-data-structures/src/enum.ts` ships a full enum codec (string or numeric discriminants, `INVALID_ENUM_VARIANT` validation at enum.ts:124) that the port never brought over — only discriminated/literal unions exist. Every Anchor-style program with Rust enums wants this. Verified present in the pinned `.repos/kit` clone.

- [ ] **FEAT-02: Emit account-resolution validation in the codama Dart renderer**
  - Generated program clients only throw `programClientsFailedToIdentifyInstruction`. Upstream's renderer also emits `insufficientAccountMetas` guards, `unrecognizedInstructionType`/`unrecognizedAccountType` parsers, and `failedToIdentifyAccount` decoders (codes 8500000–8500006, all dead in the port). Belongs in `packages/codama-renderers-dart` templates so every generated program gains the guards at once.

- [ ] **FEAT-03: Durable-nonce helpers**
  - Beyond FIX-03's assertions, upstream's nonce-tooling (`isDurableNonceTransaction`, decompile paths that recover the nonce from a compiled message) would complete the nonce story for introspection consumers (`transactionAddressMissing`, 5663010, is the related dead code in decompile paths).

- [ ] **FEAT-04: Web (dart2js/dart2wasm) support audit**
  - `solana_kit_keys`' `writeKeyPair` (FIX-08) and any other `dart:io` reaches in hand-written code are the blockers for a documented web target. A CI job compiling the umbrella package to JS/wasm would keep the target honest.

- [ ] **FEAT-05: Expand executable parity beyond the cheap surfaces**
  - The parity harness explicitly excludes live RPC timing, subscription transport behavior, and mobile platform adapters (documented in `upstream-compatibility.md`). A hermetic subscription-transport parity suite (fake websocket, scripted frames, comparing notification ordering/coalescing against upstream fixtures) would cover the highest-risk remaining divergence class.

- [ ] **FEAT-06: MWA `mwaWalletNotFound` UX path**
  - Once FIX-02 maps protocol errors, surface `mwaWalletNotFound` distinctly (dedicated exception type or error-code matching) so dApps can route to a "no wallet installed" screen instead of a generic association failure.

---

## Non-findings worth recording

The audit explicitly verified these as clean, so future passes should not re-flag them: `estimateResourceLimitsFactory` (real simulation, throws on missing `unitsConsumed`), `resolvePriorityFee`'s negative/NaN cap handling (documented decision-by-decision), `parseJsonWithBigIntsAsync`'s `UnsupportedError` fallback (documented same-isolate fallback, rethrows everything else), `allowInsecureWs` (doc and body agree — it throws in product mode), all MWA crypto paths, confirmation-strategy factories, `subscribable` stores (errors routed to state), Jupiter `getPrices` (throws on malformed entries), and the `dapp_publisher_cli` lenient translators (documented mirrors of upstream TS).
