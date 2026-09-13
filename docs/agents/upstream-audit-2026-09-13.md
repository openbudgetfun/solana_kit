# Upstream audit — @solana/kit v8.2.0 → v8.3.0

`@solana/kit` v8.3.0 was released on 2026-09-09. This note maps every change in that release to its Dart counterpart, including the items that are deliberately not ported, so the compatibility claim can be audited.

Status: the workspace tracks `v8.3.0`; `upstream:parity` passes against `@solana/kit@8.3.0`.

## Ported

| Upstream change                                                                 | Dart counterpart                                                                                                                                                                                                              |
| ------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `u256` / `i256` number codecs (`@solana/codecs-numbers`)                        | `getU256Codec`, `getU256Encoder`, `getU256Decoder`, `getI256Codec`, `getI256Encoder`, `getI256Decoder` in `solana_kit_codecs_numbers`. 32-byte fixed-size, `endian` option, full-range validation on encode, `BigInt` decode. |
| `tap` codec helpers (`@solana/codecs-core`)                                     | `tapEncoder`, `tapDecoder`, `tapCodec`, `tapEncoderBytes`, `tapDecoderBytes`, `tapCodecBytes` in `solana_kit_codecs_core`. Each preserves the wrapped codec's size characteristics.                                           |
| `getAgGenesisCert` RPC method (`@solana/rpc-api`, `@solana/rpc-transport-http`) | Landed earlier in `solana_kit_rpc_api` and `solana_kit_rpc`; `isSolanaRequest` recognises it.                                                                                                                                 |
| `getTransactionsForAddress` `bigint` parsing fix (`@solana/rpc-transport-http`) | Same change: `isSolanaRequest` recognises `getTransactionsForAddress`, so its responses go through the numeric allow-list. Landed earlier.                                                                                    |

## Not applicable in Dart

| Upstream change                                                                                                                                                            | Why there is nothing to port                                                                                                                                                                                                                                        |
| -------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| New `HasAddress` type; fee payer typed with it (`@solana/addresses`, `@solana/transaction-messages`)                                                                       | TypeScript structural typing. Dart has no structural types, and the port's fee payer slot already accepts any address-bearing value.                                                                                                                                |
| `InstructionAccountInput` / `InstructionSignerInput`, `ResolvedInstructionAccountMeta`, `InstructionAccountInputAddress` (`@solana/errors`, `@solana/program-client-core`) | Type-level widening of what generated clients accept. `ResolvedInstructionAccount` already wraps an `Object` value, so addresses, address-bearing objects, `ProgramDerivedAddress` values, and `AccountMeta` role overrides are accepted at runtime without a cast. |
| `AccountNonSignerMeta` type; `role` marked `readonly` (`@solana/instructions`)                                                                                             | `AccountMeta.role` is already a `final` field, so the mutability contract holds. The non-signer guarantee is expressed through `isSignerRole` and `downgradeRoleToNonSigner` in `solana_kit_instructions`.                                                          |
| `createLazyKeyPairSignerFromBytes` (`@solana/signers`)                                                                                                                     | Exists upstream to defer an asynchronous WebCrypto `CryptoKey` import. `createKeyPairSignerFromBytes` is synchronous in this port, so there is nothing to defer.                                                                                                    |

## Ported with a stricter default

Both upstream options below are implemented with upstream's names and semantics. Where upstream's default is lenient this port keeps the stricter default, so both ports are purely additive: no existing behavior changes, and code that wants upstream's leniency asks for it explicitly. The only difference is a default, not a capability.

| Upstream change                                                                                                  | How it maps                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| ---------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `requireSizePrefix` on the array, map, and set codecs (`@solana/codecs-data-structures`)                         | A named parameter on `getArrayDecoder`, `getArrayCodec`, `getSetDecoder`, `getSetCodec`, `getMapDecoder`, and `getMapCodec`. Upstream defaults it to `false`, so an exhausted byte array decodes as an empty collection; this port defaults to `true` and throws, preserving existing behavior. Pass `requireSizePrefix: false` for upstream's leniency.                                                                                                                                                                                                                                    |
| `fatal`, `ignoreBOM`, and `removeNullCharacters` on the UTF-8 codec (`@solana/codecs-strings`, `@solana/errors`) | `Utf8CodecConfig` carries all three and is accepted by `getUtf8Encoder`, `getUtf8Decoder`, and `getUtf8Codec`. `ignoreBOM` defaults to `false` in both, matching Dart's `Utf8Decoder`, which already strips a leading byte order mark. `fatal` defaults to `true` here and `false` upstream, and `removeNullCharacters` defaults to `false` here and `true` upstream; both divergences exist so malformed or null-padded data cannot decode silently. `fatal: true` raises a `FormatException` from decoding and, for lone surrogates, from encoding, rather than upstream's `SolanaError`. |

To opt into upstream's behavior:

```dart
final codec = getUtf8Codec(
  const Utf8CodecConfig(fatal: false, removeNullCharacters: true),
);
final array = getArrayCodec(getU8Codec(), requireSizePrefix: false);
```

## Reference pins

Refreshed alongside this audit. `kit` moved from a moving `main` branch to tag `v8.3.0`. See `docs/agents/reference-repos.md` for the full pin set.
