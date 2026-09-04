# Security and flow audit (2026-09-04)

## Scope and method

This audit reviewed the complete workspace with focused passes over keys and signatures, transaction construction and inspection, wallets and Mobile Wallet Adapter, RPC transports and subscriptions, codecs, handwritten program helpers, generated program clients, the Codama renderer, generation/build scripts, and CI/release configuration. Generated instruction surfaces were sampled against their pinned upstream programs; this is not a formal proof of every generated instruction or an on-chain program audit.

Security findings were accepted only after a regression test reproduced the unsafe behavior on the original implementation. Those failure logs are stored under `/tmp/solana-audit-evidence`. Each fix has targeted LCOV evidence for all changed executable lines. The final workspace test, lint, dependency, secret, workflow, and merged coverage gates were then run from the separate `fix/security-audit` worktree.

No committed secret was found across 622 commits. OSV Scanner found no known vulnerability in the Dart or pnpm lockfiles. The offline GitHub Actions audit reported no findings.

## High-impact findings fixed

### Signature, transaction, and instruction integrity

- Ed25519 verification accepted attacker-generated signatures for small-order public keys, including the System Program address. Authentication systems that accepted one of those addresses could be forged. Normal generated wallet keys were not affected.
- Version-1 transaction decompilation discarded instructions and fee configuration. A policy or preview could approve apparently empty content before signing the original transaction.
- Instruction packing could silently omit an oversized prerequisite while retaining a later action.
- Transactions retained mutable caller buffers, so in-process mutation could change a reviewed payload before asynchronous signing.
- Lookup signer requirements, fee-payer replacement, and v1 signer attachment lost account roles or message configuration.
- Malformed lookup metadata shifted account identities during introspection. Offchain message verification parsed only the preamble and accepted signed but structurally invalid envelopes.

### Program and payment integrity

- Helius confirmation helpers treated confirmed or finalized transactions with an execution error as successful. Applications could grant purchases or benefits for failed transfers.
- Priority-fee inspection decoded unsigned values above `2^63 - 1` as negative, allowing excessive fees to pass an upper-bound check.
- Mint creation plans allowed account funding and initialization to be split into separate transactions, exposing a signerless initialization race.
- Anchor event decoding trusted matching log text without proving that the IDL program emitted it.
- Pyth confidence and slot fields were decoded as signed values; large confidence values became negative and could pass risk bounds.
- Bubblegum proof verification accepted malformed paths and compression sizing and DAS mappings produced incorrect account data.

### Code generation and local build integrity

- Untrusted IDL names, documentation, messages, string seeds, addresses, and numeric metadata could inject Dart code or traverse generated output paths.
- The formatter invoked a shell with an interpolated directory, allowing command execution.
- Predictable shared temporary Cargo dependency/archive paths allowed a local user to substitute build code or redirect an archive write.
- Duplicate generated paths silently overwrote signer logic, layouts, or barrel files.
- Generation check mode did not render or compare output, and renderer failures could exit successfully.

## Medium and availability findings fixed

- HTTP and Jupiter redirects forwarded API keys to another origin. Generic, Helius, and Jupiter transport exceptions exposed credential-bearing URLs.
- HTTP cancellation signals were ignored; subscription factories omitted the JSON-RPC handshake, filtering, and unsubscribe protocol.
- IPv6 literal variants bypassed private-host filtering. RPC stream, channel, cache, and confirmation failures could hang requests, leak listeners, poison retries, or escape error handlers.
- RPC BigInt conversion collided with ordinary `{"$n":"..."}` objects and expanded unbounded positive exponents.
- Wallet controller completion could resurrect disconnected or replaced wallets. Mobile batches ignored per-request account, chain, or policy; native callbacks crossed sessions; native message signing returned an entire `message || signature` envelope instead of its signature.
- Mobile Wallet Adapter ECDH accepted malformed P-256 points. SIWS fields accepted line breaks that made distinct structured requests serialize to the same signed bytes.
- Numeric codecs could read or write outside a supplied typed-data view. Noncanonical ShortU16, option, hexadecimal, size-prefix, fixed-point, and array inputs were accepted or silently corrupted. Array prefixes could request enormous zero-width lists, and remainder decoders could make no progress.
- Extreme Pyth/Hermes exponents could block synchronous execution.
- Account batch requests retained a mutable address list and could attach one account's returned data to another address.

## Broken flows fixed

The audit also repaired loader uploads that the standard executor rejected, version-1 transaction wire round trips, durable confirmation cleanup, Jupiter swap/build/token request contracts, Helius preconfirmation lifecycle, Surfpool response/startup/profiling handling, Mobile Wallet association paths, generated `isSigner: "either"` accounts, codec offsets/endianness/imports, and program generation drift checks. These are correctness or availability defects unless listed above with a demonstrated security consequence.

## Remaining limitations

- Helius's legacy smart-transaction facade remains incomplete: creation returns a blockhash placeholder, sending submits instructions rather than a serialized signed transaction, and compute estimation sends an incompatible object. Repair needs a deliberate typed signing API.
- DNS resolution/rebinding is not pinned by HTTP or WebSocket transports. Transport-wide response/frame limits and default deadlines remain caller responsibilities; the existing WebSocket send-buffer setting is unused.
- Durable-nonce invalidation can race a delayed successful signature response and report a false failure.
- Bubblegum composite helpers still need coordinated asynchronous PDA, proof-account, signer, and canonical program-default redesign.
- Generated Token and Token-2022 multisig flows still require callers to append remaining signer accounts manually.
- Mobile Wallet Adapter remote reflector IDs are represented as `int`, losing leading zeroes and very large opaque values. Native authorization returns only the first account, custom issuer configuration is not wired through, and iOS channel support remains incomplete.
- Browser wallet variadic registration handles only its first argument and unregister leaves event listeners. Browser coverage tooling did not produce usable LCOV, so that source was left unchanged.
- Invalid application-created base-X configurations can still request a one-character alphabet or zero reslice width and loop. Standard exported codecs use valid configurations.
- In-memory secret erasure remains best effort in Dart, and Windows key-file protection relies on inherited ACLs.

These residual items either require public API design, platform work, or did not have a demonstrated remotely reachable exploit in this audit.
