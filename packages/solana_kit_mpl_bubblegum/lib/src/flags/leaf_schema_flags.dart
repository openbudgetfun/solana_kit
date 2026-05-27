/// Leaf schema V2 flags for mpl-bubblegum compressed NFTs.
///
/// The flags byte in V2 leaf hashes indicates the presence of optional
/// fields. This is a bitwise flag field.
library;

/// Flags embedded in V2 leaf hashes to indicate the leaf schema variant.
///
/// These flags are stored as a single byte in the leaf hash input and
/// determine how the leaf data should be interpreted.
class LeafSchemaV2Flags {
  /// The raw flag value.
  final int value;

  const LeafSchemaV2Flags._(this.value);

  /// No flags set — this is a standard V2 leaf.
  static const none = LeafSchemaV2Flags._(0);

  /// The leaf has an associated collection.
  static const hasCollection = LeafSchemaV2Flags._(1);

  /// The leaf has custom asset data.
  static const hasAssetData = LeafSchemaV2Flags._(2);

  /// The leaf has both a collection and custom asset data.
  static const hasCollectionAndAssetData = LeafSchemaV2Flags._(3);

  /// All valid flag values.
  static const List<LeafSchemaV2Flags> values = [
    none,
    hasCollection,
    hasAssetData,
    hasCollectionAndAssetData,
  ];

  /// Whether the leaf has an associated collection.
  bool get hasCollectionFlag => (value & 1) != 0;

  /// Whether the leaf has custom asset data.
  bool get hasAssetDataFlag => (value & 2) != 0;

  @override
  bool operator ==(Object other) =>
      other is LeafSchemaV2Flags && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'LeafSchemaV2Flags($value)';
}

/// Validates that the given [flags] value is a valid LeafSchemaV2Flags.
///
/// Valid values are 0, 1, 2, or 3 (bitwise combinations of collection
/// and asset data flags).
bool isValidLeafSchemaV2Flags(int flags) {
  return flags >= 0 && flags <= 3;
}
