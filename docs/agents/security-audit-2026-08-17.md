# Security audit: recent merges and workspace review (2026-08-17)

## Scope

This review covered every pull request merged from 2026-07-17 through
2026-08-17, the direct release commits in the same window, and a broader
security pass over the workspace. No pull requests were closed without being
merged during that period.

Reviewed merged pull requests:

- #198, #199: generated releases
- #200: devenv/nixpkgs maintenance
- #201, #202, #203: local release and token-check workflow changes
- #204, #206: `@solana/kit` 7.0 and 7.1 parity ports
- #205: Surfpool-backed integration tests
- #207: Helius v3 auth, checkout, and payment helpers
- #208, #211: Surfpool client and per-instance workdir lifecycle
- #210: Bubblegum lifecycle and signer attachment

The review also covered the direct release fixes between #198 and #199,
including the trusted-publishing, direct-tag, release-tag, and aborted-publish
changes.

## Method

- Inspected each merged diff, its discussion, and its first-parent integration
  point. The recent pull requests had Codecov automation but no substantive
  human review comments.
- Compared Helius auth/payment code with `helius-labs/helius-sdk` v3.0.0 at
  commit `4c0c55b86eab0e3abde7896c0aa23c4b6515e9b0`.
- Checked the tracked `@solana/kit` 7.1.0 metadata, generated upstream parity
  fixtures, and upstream commits after the pinned release.
- Scanned all tracked history (585 commits at review time) with gitleaks; no
  committed secrets were found.
- Scanned every Dart and pnpm lockfile with OSV Scanner. The initial scan found
  20 known vulnerabilities (13 high, 4 medium, 3 low); the remediated scan
  reports zero.
- Ran analyzer/lint, dependency, upstream, package regression, and workspace
  benchmark checks. The full workspace run passed 6,730 tests with one
  intentionally skipped test.
- Manually searched security-sensitive boundaries: key generation/storage,
  signing, auth headers, URL construction, HTTP/WebSocket transport, process
  and temporary-directory lifecycle, untrusted RPC decoding, and release
  publishing.

## Findings fixed in this change

### High: Helius generated invalid Ed25519 keypairs

`AuthClient.generateKeypair()` generated 64 unrelated random bytes and treated
the last 32 as a public key. The resulting value was almost never a valid
Ed25519 keypair, despite the public API claiming otherwise. This originated in
#34.

The implementation now uses `solana_kit_keys.generateKeyPair`, emits the
Solana CLI 64-byte private-seed/public-key format, validates it in regression
tests by signing and verifying, and clears temporary key copies.

### High: Helius project API keys were confused with bearer JWTs

The v3 auth port in #207 called the legacy `/auth/wallet-signup` API and mapped
its project API key to `jwt`. It then sent that value as an `Authorization:
Bearer` credential to checkout APIs. Existing-project and post-payment
provisioning also called legacy API-key-authenticated project endpoints instead
of the v3 JWT endpoints.

The flow now matches upstream:

- `POST /v0/wallet-signup` with `message`, `signature`, and `userID`
- use the returned `token` as the JWT and `refId` as the checkout reference
- `GET /v0/projects` and `GET /v0/projects/:id` with the bearer JWT
- `POST /v0/projects/:id/add-key` with the bearer JWT

The code preserves the legacy Dart positional parameters for compatibility,
but never reuses a project API key as a bearer token. It also validates plan,
period, wallet address, contact fields, payment memo/intent consistency, and
positive unsigned transfer amounts.

### High: WebSocket SSRF filters were bypassable and Helius errors exposed URLs

The literal-host protection introduced in #163 blocked only a subset of local
ranges. Loopback addresses outside `127.0.0.1`, CGNAT, reserved ranges,
alternate numeric IPv4 forms (`127.1`, integer, octal, hexadecimal),
IPv4-mapped IPv6, IPv6 link-local, and multicast literals could pass. The
separate `HeliusWebSocket` implementation did not apply private-host checks and
included the full endpoint (commonly containing `api-key`) in connection error
messages.

The shared validator now rejects those non-public literal forms. The higher
level RPC subscriptions factory now propagates an explicit
`allowPrivateHosts` setting (the missing propagation previously broke local
channels), Surfpool opts into it only for its local validator, and Helius uses
the same policy. Helius also redacts endpoint credentials from connection
errors.

### Medium: RPC transaction introspection silently discarded malformed data

The JSON decoder added in #204 used `whereType` and `continue` paths that
silently dropped malformed accounts, instruction indices, table lookups, and
inner instructions. `walkInstructions` appended inner groups that did not
belong to any outer instruction. A malformed or mismatched RPC response could
therefore be presented as a valid but different instruction/account trace.

JSON transaction decoding now fails closed on mixed types, invalid header
counts, unsupported versions, missing fields, invalid indices, malformed
loaded addresses, and unmatched inner-instruction groups.

### Medium: private-key lifecycle and key-file creation left avoidable exposure

The key finalizer work in #159 did not dispose rejected key-grinding candidates,
which can accumulate millions of private keys until GC. Key-file writes used a
separate existence check and open, allowing a race, did not reject symbolic
links on explicit overwrite, and ignored `chmod` failure. Helius signing,
payment, and Surfpool lifecycle paths also retained temporary keypairs or
secret-key copies longer than necessary.

The changes:

- dispose every rejected grind candidate immediately;
- reduce redundant private-key copies;
- create new key files exclusively, reject overwrite symlinks, require
  successful POSIX mode `0600` before writing, and zero write buffers;
- dispose temporary Helius signing/transfer keypairs and clear decoded keys;
- clear Surfnet's owned payer-secret copy on every shutdown path;
- dispose only payers owned by a freshly created `SurfpoolClient`, preserving
  caller-owned signers passed to `connectSurfpoolClient`;
- clear PointyCastle RNG seeds and duplicate decrypted plaintext buffers in the
  mobile-wallet protocol.

### Medium: known vulnerable JavaScript dependency graphs

Both pnpm lockfiles contained vulnerable versions of `brace-expansion`,
`esbuild`, `nanoid`, `postcss`, and `vite`. Workspace overrides now pin fixed
releases in both the root and standalone renderer lockfiles. The only package
with an install script, `esbuild`, is explicitly allowlisted instead of relying
on pnpm's implicit or interactive build-script approval.

## Pull-request review outcome

- #204 and #206: the transaction-introspection fail-open paths above were the
  material regression. Other v7/v7.1 migrations and generated packages did
  not reveal an additional exploitable regression in this review.
- #207: the JWT/API-key confusion, payment validation, key lifecycle, and URL
  handling findings above were material.
- #208 and #211: payer ownership/cleanup was the material lifecycle gap. The
  per-instance workdir isolation itself correctly reduces cross-test state
  collisions.
- #210: signer attachment and Bubblegum lifecycle changes did not reveal an
  exploitable regression. Manual signer promotion is intentional for generated
  instruction account metadata.
- #205: test-only changes did not introduce a production security boundary.
- #198-#203 and direct release fixes: no credential was committed, actions are
  pinned, release ancestry is checked, and npm publishing uses OIDC. No code
  change is required from this audit.

## Upstream status

- `@solana/kit` 7.1.0 compatibility metadata and runtime fixtures pass.
- The only functional upstream package commit after the tracked 7.1.0 commit
  is `9f8e4d0` (avoid treating JavaScript protocol hooks as RPC methods). It is
  specific to JavaScript `Proxy` property lookup and has no Dart analogue.
- The Helius v3 JWT project/auth flow is now aligned with the pinned v3.0.0
  source. The previous workspace audit's statement that auth/checkout/payment
  primitives were still gaps was stale after #207 and is corrected in package
  documentation.

## Performance review

No new asymptotic regression was found in the recent merges. Strict RPC
validation remains linear in response size. Immediate grind-candidate disposal
reduces peak private-key retention, and removing redundant byte copies reduces
allocation pressure in key restoration. The workspace benchmarks complete;
they cover address validation, BigInt JSON parsing, transaction compilation,
and base64 wire encoding.

## Residual risks and recommended follow-up

1. **Helius smart-transaction façade (high correctness risk).** The legacy
   `createSmartTransaction` helper only returns a recent blockhash, while
   `sendSmartTransaction` submits the instruction list where Solana RPC expects
   a serialized signed transaction. This does not match Helius v3. Replacing
   it requires a deliberately breaking, typed API using `Instruction`,
   `TransactionSigner`, compute-budget estimation, priority-fee capping, final
   blockhash refresh, compilation, and signing. The README now warns callers
   not to use these helpers for value transfers.
2. **DNS-based SSRF and rebinding (medium).** Literal WebSocket destinations
   are filtered, but portable Dart WebSocket APIs do not expose a resolved-IP
   hook that can be pinned through connection. Applications must not accept
   arbitrary endpoint hostnames from untrusted input. The generic HTTP RPC
   transport likewise validates HTTPS but does not block private DNS/IP
   destinations.
3. **Transport resource bounds (medium).** Shared HTTP clients do not impose a
   workspace-level timeout or maximum response size. Callers operating across
   trust boundaries should provide a bounded `http.Client`; a future transport
   change should add opt-in request deadlines and streaming response limits.
4. **In-memory secret erasure is best effort (low).** Dart strings, immutable
   `BigInt` private scalars in PointyCastle, cryptographic package internals,
   and VM copies cannot be deterministically zeroed. The patch removes copies
   under SDK control, but it cannot provide process-memory isolation.
5. **Windows key-file ACLs (low).** POSIX writes require mode `0600`; Windows
   relies on inherited ACLs. A future Windows-specific implementation should
   create the file with an explicit user-only ACL.

This review is a source and automated-tool audit, not a formal cryptographic
proof or external penetration test.
