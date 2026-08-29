/// Pyth Network client for Solana Kit Dart.
///
/// Provides a Hermes price service HTTP client (the official price feed REST
/// API), decoders for the on-chain price accounts maintained by the classic
/// Pyth oracle and the push oracle (`PriceUpdateV2`), parsing for Wormhole
/// VAA price updates and accumulator update blobs, and instruction builders
/// for the Pyth Solana Receiver (`post_update_atomic` / `post_update`).
///
/// ## Fetch and decode a price
///
/// ```dart
/// import 'package:solana_kit_pyth/solana_kit_pyth.dart';
///
/// final client = HermesClient(HermesConfig());
/// final update = await client.getLatestPriceUpdates(
///   [solUsdPriceFeedId],
///   parsed: true,
/// );
/// final feed = update.parsed!.first;
/// print('${feed.price.price} * 10^${feed.price.expo}');
/// ```
///
/// ## Submit an update on chain
///
/// ```dart
/// // Parse the Hermes binary payload, trim guardian signatures so the
/// // update fits in one transaction, and post it with the receiver program.
/// final (bytes, _) = getBase16Decoder().read(
///   Uint8List.fromList(update.binaryData.single.codeUnits),
///   0,
/// );
/// final accumulator = parseAccumulatorUpdateData(bytes);
/// final instruction = await getPostUpdateAtomicInstruction(
///   payer: payer,
///   vaa: trimVaaSignatures(accumulator.vaa),
///   update: accumulator.updates.single,
///   priceUpdateAccount: ephemeralAccount.address,
/// );
/// ```
library;

export 'src/encoding.dart';
export 'src/exceptions.dart';
export 'src/hermes_client.dart';
export 'src/hermes_config.dart';
export 'src/price_account.dart';
export 'src/price_feed.dart';
export 'src/update_price_feeds.dart';
export 'src/wormhole_vaas.dart';
