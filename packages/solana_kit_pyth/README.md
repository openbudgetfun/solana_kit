# solana_kit_pyth

[![pub package](https://img.shields.io/pub/v/solana_kit_pyth.svg)](https://pub.dev/packages/solana_kit_pyth) [![docs](https://img.shields.io/badge/docs-pub.dev-0175C2.svg)](https://pub.dev/documentation/solana_kit_pyth/latest/) [![website](https://img.shields.io/badge/website-solana__kit__docs-0A7EA4.svg)](https://openbudgetfun.github.io/solana_kit/reference/package-catalog#solana_kit_pyth) [![CI](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml) [![coverage](https://codecov.io/gh/openbudgetfun/solana_kit/branch/main/graph/badge.svg?flag=solana_kit_pyth)](https://codecov.io/gh/openbudgetfun/solana_kit?flag=solana_kit_pyth)

Pyth Network client for the [Solana Kit](https://github.com/openbudgetfun/solana_kit) Dart SDK.

Covers the pull-model Pyth integration surface:

- **Hermes price service client** — the official `v2` REST API for price feeds and binary price updates
- **Binary update parsing** — accumulator update blobs, Wormhole VAA envelopes, and wire-format price feed messages
- **On-chain account decoding** — the classic Pyth price account layout and the push oracle `PriceUpdateV2` price feed accounts
- **Update submission** — instruction builders for the Pyth Solana Receiver program

## Installation

<!-- {=packageInstallSection:"solana_kit_pyth"} -->

## Installation

Install the package directly:

```yaml
dependencies:
  "solana_kit_pyth": ^
```

If your app uses several Solana Kit packages together, you can also depend on the umbrella package instead:

```bash
dart pub add solana_kit
```

Inside this monorepo, Dart workspace resolution uses the local package automatically.

<!-- {/packageInstallSection} -->

## Usage

### Fetch a price from Hermes

```dart
import 'package:solana_kit_pyth/solana_kit_pyth.dart';

Future<void> main() async {
  final client = HermesClient(
    HermesConfig(),
  ); // defaults to https://hermes.pyth.network

  // Discover feeds by symbol.
  final feeds = await client.getPriceFeeds(query: 'bitcoin');
  print(feeds.single.id); // hex price feed id

  // Latest update, with the parsed price included.
  final update = await client.getLatestPriceUpdates(
    [feeds.single.id],
    encoding: HermesEncoding.hex,
    parsed: true,
  );
  final feed = update.parsed!.single;
  final price = feed.price;
  print('${price.price} ± ${price.conf} * 10^${price.expo}');
}
```

Hermes self-hosting and authenticated providers are supported via `HermesConfig(baseUrl: ..., accessToken: ...)`.

### Decode a binary update and post it on chain

The `binary` payload of a Hermes update is an accumulator update blob containing one Wormhole VAA plus merkle-committed price messages. Parse it, trim guardian signatures so the update fits in a single transaction, and submit it with the Pyth Solana Receiver's `post_update_atomic` instruction:

```dart
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';
import 'package:solana_kit_pyth/solana_kit_pyth.dart';

Future<void> publish(
  HermesPriceUpdate update,
  Address payer,
  Address priceUpdateAccount,
) async {
  // Decode binary.data[0] (hex or base64 per the response encoding).
  // In Solana Kit, "encoders" turn encoded strings into raw bytes.
  final bytes = switch (update.binaryEncoding) {
    HermesEncoding.hex => getBase16Encoder().encode(update.binaryData.single),
    HermesEncoding.base64 => getBase64Encoder().encode(update.binaryData.single),
  };

  final accumulator = parseAccumulatorUpdateData(bytes);
  for (final message in accumulator.updates) {
    final priceFeed = parsePythPriceFeedMessage(message.message);
    print('feed 0x${priceFeed.feedIdHex}: '
        '${priceFeed.price} ± ${priceFeed.confidence} * 10^${priceFeed.exponent}');

    final instruction = await getPostUpdateAtomicInstruction(
      payer: payer,
      vaa: trimVaaSignatures(accumulator.vaa), // 5 signatures by default
      update: message,
      priceUpdateAccount: priceUpdateAccount,
    );
    // Add the instruction to a transaction message and send it.
    print('post $instruction');
  }
}
```

The receiver program also supports `post_update`, which consumes an encoded-VAA account that was already verified by the Wormhole program.

### Decode on-chain price accounts

```dart
import 'dart:typed_data';

import 'package:solana_kit_pyth/solana_kit_pyth.dart';

void main() {
  // Raw bytes of a price account, e.g. fetched via solana_kit_rpc.
  final accountData = Uint8List(96);
  const slot = 123456789;

  // Classic Pyth oracle price accounts (magic 0xa1b2c3d4).
  final pyth1 = decodePythPriceAccount(accountData, currentSlot: slot);
  print(
    '${pyth1.aggregate.priceComponent} * 10^${pyth1.exponent}',
  );
  print(pyth1.status); // stale aggregates are demoted to unknown

  // Push oracle price feed accounts (PriceUpdateV2).
  final pyth2 = decodePriceUpdateV2Account(accountData);
  print('0x${pyth2.feedIdHex} @ ${pyth2.publishTime}');
  print(pyth2.verificationLevel); // full or partial(number of signatures)
}
```

## API overview

| Export                                                                    | Purpose                                                           |
| ------------------------------------------------------------------------- | ----------------------------------------------------------------- |
| `HermesClient` / `HermesConfig`                                           | Hermes v2 REST client (`price_feeds`, latest/timestamped updates) |
| `HermesEncoding`, `HermesAssetType`                                       | Query enums: `hex`/`base64` payloads, feed asset types            |
| `HermesPriceUpdate`, `HermesPriceFeed`, `HermesPriceFeedMetadata`         | Typed models for Hermes responses (`BigInt` price and confidence) |
| `parseAccumulatorUpdateData`                                              | Split a Hermes binary blob into its VAA and merkle price updates  |
| `parseWormholeVaa`, `trimVaaSignatures`                                   | Wormhole VAA (v1) envelope parsing and signature trimming         |
| `parsePythWormholeMessage`, `parsePythPriceFeedMessage`                   | Pythnet payload and wire-format price feed message parsing        |
| `decodePythPriceAccount`                                                  | Classic Pyth on-chain price account decoder                       |
| `decodePriceUpdateV2Account`                                              | Push oracle `PriceUpdateV2` price feed account decoder            |
| `getPostUpdateAtomicInstruction`, `getPostUpdateInstruction`              | Pyth Solana Receiver instruction builders                         |
| `getPythConfigAddress`, `getPythTreasuryAddress`, `getGuardianSetAddress` | Receiver and Wormhole PDA helpers                                 |

## Scope

- Hermes **v2 REST** endpoints only; the SSE streaming endpoint (`/v2/updates/price/stream`) is out of scope for v1.
- Update submission targets the deployed Pyth Solana Receiver (`post_update_atomic` / `post_update`). The historical `update_price_feeds`-style receiver interface is not part of the current program and is not implemented.
- The classic price account decoder targets layout **version 2** (the `@pythnetwork/client` v2 layout).
- No cryptographic signature verification happens client-side; guardian signatures are verified by the receiver program on chain.

## Upstream reference

Audited against:

- [`@pythnetwork/hermes-client`](https://github.com/pyth-network/pyth-crosschain) v3.1.0 (Hermes v2 REST surface)
- [`@pythnetwork/pyth-solana-receiver`](https://github.com/pyth-network/pyth-crosschain) v0.16.0 (receiver IDL, VAA helpers, PDA seeds)
- [`@pythnetwork/client`](https://github.com/pyth-network/pyth-crosschain) v2.22.1 (price account layout, magic constant)
- [`@pythnetwork/price-service-sdk`](https://github.com/pyth-network/pyth-crosschain) v1.9.0 (accumulator update parsing, wire message formats)
