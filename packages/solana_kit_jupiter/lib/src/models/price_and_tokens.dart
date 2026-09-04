/// A price quote from Jupiter's Price API v3.
class JupiterPrice {
  /// Creates a price entry.
  const JupiterPrice({
    required this.usdPrice,
    required this.blockId,
    required this.decimals,
    required this.priceChange24h,
  });

  /// Builds a price entry from a Price API JSON object.
  factory JupiterPrice.fromJson(Map<String, Object?> json) {
    int? parseInt(Object? value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }

    return JupiterPrice(
      usdPrice: (json['usdPrice'] as num?)?.toDouble(),
      blockId: (json['blockId'] is String)
          ? json['blockId']! as String
          : json['blockId']?.toString(),
      decimals: parseInt(json['decimals']),
      priceChange24h: (json['priceChange24h'] as num?)?.toDouble(),
    );
  }

  /// The current USD price of the mint.
  final double? usdPrice;

  /// The block id backing this price, as a string-encoded 64-bit value.
  final String? blockId;

  /// The decimals of the priced mint.
  final int? decimals;

  /// The 24-hour price change, or `null` when unavailable.
  final double? priceChange24h;
}

/// Token metadata from Jupiter's Token API v2.
class JupiterTokenItem {
  /// Creates a token item.
  const JupiterTokenItem({
    required this.id,
    required this.name,
    required this.symbol,
    required this.icon,
    required this.decimals,
    required this.tags,
    required this.organicScore,
    required this.organicScoreLabel,
    required this.isVerified,
    required this.holderCount,
    required this.usdPrice,
    required this.mcap,
    required this.liquidity,
  });

  /// Builds a token item from a Token API JSON object.
  factory JupiterTokenItem.fromJson(Map<String, Object?> json) {
    double? parseDouble(Object? value) => (value as num?)?.toDouble();
    int? parseInt(Object? value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }

    // Prices may arrive as integer strings for small decimals like 0.
    double? priceFromDynamic(Object? value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      if (value is String) {
        final parsed = double.tryParse(value);
        if (parsed != null) return parsed;
      }
      return null;
    }

    return JupiterTokenItem(
      id: json['id'] as String?,
      name: json['name'] as String?,
      symbol: json['symbol'] as String?,
      icon: json['icon'] as String?,
      decimals: parseInt(json['decimals']),
      tags: (json['tags'] as List<Object?>?)?.cast<String>().toList(
        growable: false,
      ),
      organicScore: parseDouble(json['organicScore']),
      organicScoreLabel: json['organicScoreLabel'] as String?,
      isVerified: json['isVerified'] as bool?,
      holderCount: parseInt(json['holderCount']),
      usdPrice: priceFromDynamic(json['usdPrice']),
      mcap: priceFromDynamic(json['mcap']),
      liquidity: priceFromDynamic(json['liquidity']),
    );
  }

  /// The mint address of the token.
  final String? id;

  /// The token name.
  final String? name;

  /// The token symbol.
  final String? symbol;

  /// The token icon URL, or `null`.
  final String? icon;

  /// The token decimals.
  final int? decimals;

  /// Tags such as `verified`, `strict`, or `lfg`.
  final List<String>? tags;

  /// The organic token score in the range 0–100.
  final double? organicScore;

  /// A label describing the organic score (for example `low`).
  final String? organicScoreLabel;

  /// Whether the token is verified.
  final bool? isVerified;

  /// The number of holders.
  final int? holderCount;

  /// The current token price in USD.
  final double? usdPrice;

  /// The token market capitalization in USD.
  final double? mcap;

  /// The available liquidity for the token in USD.
  final double? liquidity;
}
