/// Models for the Hermes v2 REST API responses.
///
/// The binary update payload is composed of [HermesPriceUpdate.binaryData]
/// strings in the encoding named by [HermesPriceUpdate.binaryEncoding]. The
/// same update may carry parsed price feeds
/// (https://docs.pyth.network) when requested with `parsed=true`.
library;

import 'package:solana_kit_pyth/src/encoding.dart';

/// A parsed price attached to a [HermesPriceFeed].
///
/// The underlying Hermes JSON carries `price` and `conf` as decimal strings;
/// both are surfaced as [BigInt] here. `expo` (the price exponent) and
/// `publishTime` (Unix timestamp in seconds) are 32-bit integers.
class HermesPrice {
  /// Creates a [HermesPrice].
  const HermesPrice({
    required this.price,
    required this.conf,
    required this.expo,
    required this.publishTime,
  });

  /// Decodes a `price` object from the Hermes `parsed` JSON.
  ///
  /// The `price` and `conf` JSON fields are decimal strings parsed into
  /// [BigInt]s.
  factory HermesPrice.fromJson(Map<String, Object?> json) {
    return HermesPrice(
      price: _parseBigint(json['price'], 'price'),
      conf: _parseBigint(json['conf'], 'conf'),
      expo: _parseInt(json['expo'], 'expo'),
      publishTime: _parseInt(json['publish_time'], 'publish_time'),
    );
  }

  /// The aggregate price component, expressed as an integer to be scaled by
  /// `10^expo`.
  final BigInt price;

  /// The confidence interval (one sigma) around [price], scaled like [price].
  final BigInt conf;

  /// The exponent used to convert [price] and [conf] into decimal values.
  final int expo;

  /// Unix timestamp (in seconds) at which the price was published.
  final int publishTime;

  /// Converts this fixed-point price into a decimal number.
  ///
  /// Warning: this conversion is lossy for large components because Dart
  /// doubles only carry 52 bits of integer precision.
  double get asDouble => price.toDouble() * _pow10(expo) * 1.0;

  @override
  String toString() =>
      'HermesPrice(price: $price, conf: $conf, expo: $expo, '
      'publishTime: $publishTime)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HermesPrice &&
          price == other.price &&
          conf == other.conf &&
          expo == other.expo &&
          publishTime == other.publishTime;

  @override
  int get hashCode => Object.hash(price, conf, expo, publishTime);
}

double _pow10(int exponent) {
  var result = 1.0;
  if (exponent >= 0) {
    for (var i = 0; i < exponent; i++) {
      result *= 10;
    }
    return result;
  }
  for (var i = 0; i < -exponent; i++) {
    result /= 10;
  }
  return result;
}

ParsedHermesPriceMetadata? _parseMetadata(Object? json) {
  if (json == null) return null;
  if (json is! Map<String, Object?>) {
    throw ArgumentError.value(json, 'metadata', 'Expected a JSON object');
  }
  return ParsedHermesPriceMetadata(
    slot: _optionalInt(json['slot'], 'slot'),
    prevPublishTime: _optionalInt(
      json['prev_publish_time'],
      'prev_publish_time',
    ),
    proofAvailableTime: _optionalInt(
      json['proof_available_time'],
      'proof_available_time',
    ),
  );
}

/// Metadata attached to a parsed Hermes price update.
class ParsedHermesPriceMetadata {
  /// Creates [ParsedHermesPriceMetadata].
  const ParsedHermesPriceMetadata({
    this.slot,
    this.prevPublishTime,
    this.proofAvailableTime,
  });

  /// The Pythnet slot number the price was published in, when available.
  final int? slot;

  /// The publish time of the previous price, when available.
  final int? prevPublishTime;

  /// The earliest time a merkle proof for this update is available, when
  /// available.
  final int? proofAvailableTime;

  @override
  String toString() =>
      'ParsedHermesPriceMetadata(slot: $slot, '
      'prevPublishTime: $prevPublishTime, '
      'proofAvailableTime: $proofAvailableTime)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ParsedHermesPriceMetadata &&
          slot == other.slot &&
          prevPublishTime == other.prevPublishTime &&
          proofAvailableTime == other.proofAvailableTime;

  @override
  int get hashCode => Object.hash(slot, prevPublishTime, proofAvailableTime);
}

/// A single parsed price feed entry inside a Hermes price update response.
class HermesPriceFeed {
  /// Creates a [HermesPriceFeed].
  const HermesPriceFeed({
    required this.id,
    required this.price,
    required this.emaPrice,
    this.metadata,
  });

  /// Decodes one entry of the `parsed` array of a Hermes price update.
  factory HermesPriceFeed.fromJson(Map<String, Object?> json) {
    return HermesPriceFeed(
      id: json['id'] as String? ?? (throw ArgumentError('id is required')),
      price: HermesPrice.fromJson(_object(json['price'], 'price')),
      emaPrice: HermesPrice.fromJson(_object(json['ema_price'], 'ema_price')),
      metadata: _parseMetadata(json['metadata']),
    );
  }

  /// The hex-encoded price feed ID this update belongs to.
  final String id;

  /// The latest aggregate price and confidence interval.
  final HermesPrice price;

  /// The latest exponentially moving average price and confidence interval.
  final HermesPrice emaPrice;

  /// Optional metadata (slot numbers, previous publish time, proof
  /// availability) for this update.
  final ParsedHermesPriceMetadata? metadata;

  @override
  String toString() => 'HermesPriceFeed(id: $id, price: $price)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HermesPriceFeed &&
          id == other.id &&
          price == other.price &&
          emaPrice == other.emaPrice &&
          metadata == other.metadata;

  @override
  int get hashCode => Object.hash(id, price, emaPrice, metadata);
}

/// A complete Hermes price update response (`/v2/updates/price/...`).
class HermesPriceUpdate {
  /// Creates a [HermesPriceUpdate].
  const HermesPriceUpdate({
    required this.binaryData,
    required this.binaryEncoding,
    this.parsed,
  });

  /// Decodes a Hermes price update response.
  ///
  /// Throws a [FormatException] when the JSON structure does not match the
  /// documented schema.
  factory HermesPriceUpdate.fromJson(Map<String, Object?> json) {
    final binary = _object(json['binary'], 'binary');
    final parsed = json['parsed'];
    return HermesPriceUpdate(
      binaryData: [
        for (final data in (binary['data'] as List<Object?>?) ?? const [])
          data as String? ?? (throw ArgumentError('binary.data is required')),
      ],
      binaryEncoding: HermesEncoding.fromName(
        binary['encoding'] as String? ??
            (throw ArgumentError('binary.encoding is required')),
      ),
      parsed: parsed == null
          ? null
          : [
              for (final feed in parsed as List<Object?>)
                HermesPriceFeed.fromJson(_object(feed, 'parsed[]')),
            ],
    );
  }

  /// The binary update payload, one string element per update chunk.
  ///
  /// A single element contains the full accumulator update data (or VAA for
  /// legacy responses) in [binaryEncoding] representation, ready to be
  /// submitted to the Pyth receiver program.
  final List<String> binaryData;

  /// The encoding of [binaryData] (`hex` or `base64`).
  final HermesEncoding binaryEncoding;

  /// Parsed price feeds included in the response, when requested.
  final List<HermesPriceFeed>? parsed;

  @override
  String toString() =>
      'HermesPriceUpdate(binaryEncoding: $binaryEncoding, '
      'binaryData: ${binaryData.length} chunk(s), '
      'parsed: ${parsed?.length ?? 'n/a'})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HermesPriceUpdate &&
          binaryEncoding == other.binaryEncoding &&
          _listsEqual(binaryData, other.binaryData) &&
          _parsedEquals(parsed, other.parsed);

  @override
  int get hashCode => Object.hash(
    binaryEncoding,
    Object.hashAll(binaryData),
    parsed == null ? null : Object.hashAll(parsed!),
  );
}

/// Metadata describing an available price feed in the `/v2/price_feeds`
/// listing.
class HermesPriceFeedMetadata {
  /// Creates a [HermesPriceFeedMetadata].
  const HermesPriceFeedMetadata({
    required this.id,
    required this.attributes,
    this.assetType,
    this.base,
    this.description,
    this.displaySymbol,
    this.genericSymbol,
    this.quote,
    this.symbol,
  });

  /// Decodes one entry of the `/v2/price_feeds` response.
  factory HermesPriceFeedMetadata.fromJson(Map<String, Object?> json) {
    final attributes = json['attributes'];
    return HermesPriceFeedMetadata(
      id: json['id'] as String? ?? (throw ArgumentError('id is required')),
      attributes: attributes is Map<String, Object?>
          ? Map<String, String>.from(attributes.cast<String, Object>())
          : const {},
      assetType: json['asset_type'] as String?,
      base: json['base'] as String?,
      description: json['description'] as String?,
      displaySymbol: json['display_symbol'] as String?,
      genericSymbol: json['generic_symbol'] as String?,
      quote: json['quote'] as String?,
      symbol: json['symbol'] as String?,
    );
  }

  /// The hex-encoded price feed ID.
  final String id;

  /// Extra feed attributes (display symbols, country, ...).
  final Map<String, String> attributes;

  /// The asset type of the feed, when present.
  final String? assetType;

  /// The base token of the feed, when available.
  final String? base;

  /// Human readable feed description, when available.
  final String? description;

  /// Display symbol of the feed, when available.
  final String? displaySymbol;

  /// Generic symbol of the feed, when available.
  final String? genericSymbol;

  /// The quote token of the feed, when available.
  final String? quote;

  /// The `base/quote` symbol of the feed, when available.
  final String? symbol;

  @override
  String toString() => 'HermesPriceFeedMetadata(id: $id, symbol: $symbol)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HermesPriceFeedMetadata &&
          id == other.id &&
          assetType == other.assetType &&
          base == other.base &&
          description == other.description &&
          displaySymbol == other.displaySymbol &&
          genericSymbol == other.genericSymbol &&
          quote == other.quote &&
          symbol == other.symbol;

  @override
  int get hashCode => Object.hash(
    id,
    assetType,
    base,
    description,
    displaySymbol,
    genericSymbol,
    quote,
    symbol,
  );
}

Map<String, Object?> _object(Object? json, String field) {
  if (json is Map<String, Object?>) return json;
  throw ArgumentError.value(json, field, 'Expected a JSON object');
}

BigInt _parseBigint(Object? value, String field) {
  if (value is int) return BigInt.from(value);
  if (value is String) return BigInt.parse(value);
  throw ArgumentError.value(value, field, 'Expected a decimal string');
}

int _parseInt(Object? value, String field) {
  if (value is int) return value;
  throw ArgumentError.value(value, field, 'Expected an integer');
}

int? _optionalInt(Object? value, String field) =>
    value == null ? null : _parseInt(value, field);

bool _listsEqual(List<String> a, List<String> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

bool _parsedEquals(List<HermesPriceFeed>? a, List<HermesPriceFeed>? b) {
  if (identical(a, b)) return true;
  if (a == null || b == null || a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
