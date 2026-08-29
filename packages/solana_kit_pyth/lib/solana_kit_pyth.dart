/// Pyth Network client for Solana Kit Dart.
///
/// Provides the Hermes price service HTTP client (the official price feed
/// REST API), decoders for the on-chain price accounts maintained by the
/// classic Pyth oracle and the push oracle ([PriceUpdateV2]), parsing for
/// Wormhole VAA price updates and accumulator update blobs, and instruction
/// builders for the Pyth Solana Receiver.
///
///
/// ### Fetch a price from Hermes
///
/// ```dart
/// import 'package:solana_kit_pyth/solana_kit_pyth.dart';
///
/// Future<void> main() async {
///   final hermes = HermesClient(HermesConfig());
///
///   // Discover feeds by symbol.
///   final feeds = await hermes.getPriceFeeds(query: 'bitcoin');
///   print(feeds.single.id); // hex price feed id
///
///   // Latest update, with the parsed price included.
///   final update = await hermes.getLatestPriceUpdates(
///     [feeds.single.id],
///     encoding: HermesEncoding.hex,
///     parsed: true,
///   );
///   final feed = update.parsed!.single;
///   final price = feed.price;
///   print('${price.price} ± ${price.conf} * 10^${price.expo}');
/// }
/// ```
///
/// Decode a binary update and post it on chain
///
/// The `binary` payload of a Hermes update is an accumulator update blob containing one Wormhole VAA plus merkle-committed price messages. Parse it, trim guardian signatures so the update fits in a single transaction, and submit it with the Pyth Solana Receiver's `postUpdateAtomic` instruction:
///
/// ```dart
/// import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';
/// import 'package:solana_kit_addresses/solana_kit_addresses.dart';
/// import 'package:solana_kit_pyth/solana_kit_pyth.dart';
///
/// Future<void> publish(
///   HermesPriceUpdate update,
///   Address payer,
///   Address priceUpdateAccount,
/// ) async {
///   // Decode binary.data[0] (hex or base64 per the response encoding).
///   // In Solana Kit, "encoders" turn encoded strings into raw bytes.
///   final bytes = switch (update.binaryEncoding) {
///     HermesEncoding.hex => getBase16Encoder().encode(update.binaryData.single),
///     HermesEncoding.base64 => getBase64Encoder().encode(update.binaryData.single),
///   };
///
///   final accumulator = parseAccumulatorUpdateData(bytes);
///   for (final message in accumulator.updates) {
///     final priceFeed = parsePythPriceFeedMessage(message.message);
///     print('feed 0x${priceFeed.feedIdHex}: '
///         '${priceFeed.price} ± ${priceFeed.confidence} * 10^${priceFeed.exponent}');
///
///     final instruction = await getPostUpdateAtomicInstruction(
///       payer: payer,
///       vaa: trimVaaSignatures(accumulator.vaa), // 5 signatures by default
///       update: message,
///       priceUpdateAccount: priceUpdateAccount,
///     );
///     // Add the instruction to a transaction message and send it.
///     print('post $instruction');
///   }
/// }
/// ```
///
/// The receiver program also supports `post_update`, which consumes an encoded-VAA account that was already verified by the Wormhole program. On-chain price accounts decode with `decodePythPriceAccount` (classic layout) and `decodePriceUpdateV2Account` (push oracle `PriceUpdateV2`).
///

/// <!-- {=docsPythSection -->
///
/// ### Fetch a price from Hermes
///
/// ```dart
/// import 'package:solana_kit_pyth/solana_kit_pyth.dart';
///
/// Future<void> main() async {
///   final hermes = HermesClient(HermesConfig());
///
///   // Discover feeds by symbol.
///   final feeds = await hermes.getPriceFeeds(query: 'bitcoin');
///   print(feeds.single.id); // hex price feed id
///
///   // Latest update, with the parsed price included.
///   final update = await hermes.getLatestPriceUpdates(
///     [feeds.single.id],
///     encoding: HermesEncoding.hex,
///     parsed: true,
///   );
///   final feed = update.parsed!.single;
///   final price = feed.price;
///   print('${price.price} ± ${price.conf} * 10^${price.expo}');
/// }
/// ```
///
/// Decode a binary update and post it on chain
///
/// The `binary` payload of a Hermes update is an accumulator update blob containing one Wormhole VAA plus merkle-committed price messages. Parse it, trim guardian signatures so the update fits in a single transaction, and submit it with the Pyth Solana Receiver's `postUpdateAtomic` instruction:
///
/// ```dart
/// import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';
/// import 'package:solana_kit_addresses/solana_kit_addresses.dart';
/// import 'package:solana_kit_pyth/solana_kit_pyth.dart';
///
/// Future<void> publish(
///   HermesPriceUpdate update,
///   Address payer,
///   Address priceUpdateAccount,
/// ) async {
///   // Decode binary.data[0] (hex or base64 per the response encoding).
///   // In Solana Kit, "encoders" turn encoded strings into raw bytes.
///   final bytes = switch (update.binaryEncoding) {
///     HermesEncoding.hex => getBase16Encoder().encode(update.binaryData.single),
///     HermesEncoding.base64 => getBase64Encoder().encode(update.binaryData.single),
///   };
///
///   final accumulator = parseAccumulatorUpdateData(bytes);
///   for (final message in accumulator.updates) {
///     final priceFeed = parsePythPriceFeedMessage(message.message);
///     print('feed 0x${priceFeed.feedIdHex}: '
///         '${priceFeed.price} ± ${priceFeed.confidence} * 10^${priceFeed.exponent}');
///
///     final instruction = await getPostUpdateAtomicInstruction(
///       payer: payer,
///       vaa: trimVaaSignatures(accumulator.vaa), // 5 signatures by default
///       update: message,
///       priceUpdateAccount: priceUpdateAccount,
///     );
///     // Add the instruction to a transaction message and send it.
///     print('post $instruction');
///   }
/// }
/// ```
///
/// The receiver program also supports `post_update`, which consumes an encoded-VAA account that was already verified by the Wormhole program. On-chain price accounts decode with `decodePythPriceAccount` (classic layout) and `decodePriceUpdateV2Account` (push oracle `PriceUpdateV2`).
///
/// <!-- {/docsPythSection -->
library;

// ignore_for_file: comment_references

export 'src/encoding.dart';
export 'src/exceptions.dart';
export 'src/hermes_client.dart';
export 'src/hermes_config.dart';
export 'src/price_account.dart';
export 'src/price_feed.dart';
export 'src/update_price_feeds.dart';
export 'src/wormhole_vaas.dart';
