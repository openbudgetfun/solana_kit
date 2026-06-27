// Enums for the Helius SDK, mirroring the Helius TypeScript SDK enum
// definitions.
//
// Each enum provides a [toJson] instance method that returns the API string
// representation, and a static [fromJson] factory that parses from JSON.

/// Helius cluster target for API requests.
enum HeliusCluster {
  mainnet('mainnet-beta'),
  devnet('devnet');

  const HeliusCluster(this.value);

  /// The wire-format string sent to / received from the Helius API.
  final String value;

  /// Serializes this value to its API string representation.
  String toJson() => value;

  /// Deserializes an API string to a [HeliusCluster].
  ///
  /// Throws [ArgumentError] if [json] is not a recognized value.
  static HeliusCluster fromJson(String json) => switch (json) {
    'mainnet-beta' => mainnet,
    'devnet' => devnet,
    _ => throw ArgumentError.value(json, 'json', 'Unknown HeliusCluster'),
  };
}

/// Asset interface type -- identifies the on-chain program standard.
enum HeliusAssetInterface {
  v1Nft('V1_NFT'),
  custom('Custom'),
  v1Print('V1_PRINT'),
  legacyNft('Legacy_NFT'),
  v2Nft('V2_NFT'),
  fungibleAsset('FungibleAsset'),
  identity('Identity'),
  executable('Executable'),
  programmableNft('ProgrammableNFT'),
  fungibleToken('FungibleToken'),
  mplCoreAsset('MplCoreAsset'),
  mplCoreCollection('MplCoreCollection');

  const HeliusAssetInterface(this.value);

  /// The wire-format string sent to / received from the Helius API.
  final String value;

  /// Serializes this value to its API string representation.
  String toJson() => value;

  /// Deserializes an API string to a [HeliusAssetInterface].
  ///
  /// Throws [ArgumentError] if [json] is not a recognized value.
  static HeliusAssetInterface fromJson(String json) => switch (json) {
    'V1_NFT' => v1Nft,
    'Custom' => custom,
    'V1_PRINT' => v1Print,
    'Legacy_NFT' => legacyNft,
    'V2_NFT' => v2Nft,
    'FungibleAsset' => fungibleAsset,
    'Identity' => identity,
    'Executable' => executable,
    'ProgrammableNFT' => programmableNft,
    'FungibleToken' => fungibleToken,
    'MplCoreAsset' => mplCoreAsset,
    'MplCoreCollection' => mplCoreCollection,
    _ => throw ArgumentError.value(
      json,
      'json',
      'Unknown HeliusAssetInterface',
    ),
  };
}

/// How ownership of an asset is modeled.
enum HeliusOwnershipModel {
  single('single'),
  token('token');

  const HeliusOwnershipModel(this.value);

  /// The wire-format string sent to / received from the Helius API.
  final String value;

  /// Serializes this value to its API string representation.
  String toJson() => value;

  /// Deserializes an API string to a [HeliusOwnershipModel].
  ///
  /// Throws [ArgumentError] if [json] is not a recognized value.
  static HeliusOwnershipModel fromJson(String json) => switch (json) {
    'single' => single,
    'token' => token,
    _ => throw ArgumentError.value(
      json,
      'json',
      'Unknown HeliusOwnershipModel',
    ),
  };
}

/// Royalty distribution model for an asset.
enum HeliusRoyaltyModel {
  creators('creators'),
  fanout('fanout'),
  single_('single');

  const HeliusRoyaltyModel(this.value);

  /// The wire-format string sent to / received from the Helius API.
  final String value;

  /// Serializes this value to its API string representation.
  String toJson() => value;

  /// Deserializes an API string to a [HeliusRoyaltyModel].
  ///
  /// Throws [ArgumentError] if [json] is not a recognized value.
  static HeliusRoyaltyModel fromJson(String json) => switch (json) {
    'creators' => creators,
    'fanout' => fanout,
    'single' => single_,
    _ => throw ArgumentError.value(json, 'json', 'Unknown HeliusRoyaltyModel'),
  };
}

/// Authority scope level for an asset.
enum HeliusScope {
  full('full'),
  royalty('royalty'),
  metadata('metadata'),
  extension_('extension');

  const HeliusScope(this.value);

  /// The wire-format string sent to / received from the Helius API.
  final String value;

  /// Serializes this value to its API string representation.
  String toJson() => value;

  /// Deserializes an API string to a [HeliusScope].
  ///
  /// Throws [ArgumentError] if [json] is not a recognized value.
  static HeliusScope fromJson(String json) => switch (json) {
    'full' => full,
    'royalty' => royalty,
    'metadata' => metadata,
    'extension' => extension_,
    _ => throw ArgumentError.value(json, 'json', 'Unknown HeliusScope'),
  };
}

/// Method governing how an asset's uses are consumed.
enum HeliusUseMethod {
  burn('Burn'),
  single_('Single'),
  multiple('Multiple');

  const HeliusUseMethod(this.value);

  /// The wire-format string sent to / received from the Helius API.
  final String value;

  /// Serializes this value to its API string representation.
  String toJson() => value;

  /// Deserializes an API string to a [HeliusUseMethod].
  ///
  /// Throws [ArgumentError] if [json] is not a recognized value.
  static HeliusUseMethod fromJson(String json) => switch (json) {
    'Burn' => burn,
    'Single' => single_,
    'Multiple' => multiple,
    _ => throw ArgumentError.value(json, 'json', 'Unknown HeliusUseMethod'),
  };
}

/// Display context in which a file or asset is intended to be rendered.
enum HeliusContext {
  walletDefault('wallet-default'),
  webDesktop('web-desktop'),
  webMobile('web-mobile'),
  appMobile('app-mobile'),
  appDesktop('app-desktop'),
  app('app'),
  vr('vr');

  const HeliusContext(this.value);

  /// The wire-format string sent to / received from the Helius API.
  final String value;

  /// Serializes this value to its API string representation.
  String toJson() => value;

  /// Deserializes an API string to a [HeliusContext].
  ///
  /// Throws [ArgumentError] if [json] is not a recognized value.
  static HeliusContext fromJson(String json) => switch (json) {
    'wallet-default' => walletDefault,
    'web-desktop' => webDesktop,
    'web-mobile' => webMobile,
    'app-mobile' => appMobile,
    'app-desktop' => appDesktop,
    'app' => app,
    'vr' => vr,
    _ => throw ArgumentError.value(json, 'json', 'Unknown HeliusContext'),
  };
}

/// Field by which DAS asset queries can be sorted.
enum AssetSortBy {
  id('id'),
  created('created'),
  updated('updated'),
  recentAction('recent_action'),
  none_('none');

  const AssetSortBy(this.value);

  /// The wire-format string sent to / received from the Helius API.
  final String value;

  /// Serializes this value to its API string representation.
  String toJson() => value;

  /// Deserializes an API string to an [AssetSortBy].
  ///
  /// Throws [ArgumentError] if [json] is not a recognized value.
  static AssetSortBy fromJson(String json) => switch (json) {
    'id' => id,
    'created' => created,
    'updated' => updated,
    'recent_action' => recentAction,
    'none' => none_,
    _ => throw ArgumentError.value(json, 'json', 'Unknown AssetSortBy'),
  };
}

/// Sort direction for DAS asset queries.
enum AssetSortDirection {
  asc('asc'),
  desc('desc');

  const AssetSortDirection(this.value);

  /// The wire-format string sent to / received from the Helius API.
  final String value;

  /// Serializes this value to its API string representation.
  String toJson() => value;

  /// Deserializes an API string to an [AssetSortDirection].
  ///
  /// Throws [ArgumentError] if [json] is not a recognized value.
  static AssetSortDirection fromJson(String json) => switch (json) {
    'asc' => asc,
    'desc' => desc,
    _ => throw ArgumentError.value(json, 'json', 'Unknown AssetSortDirection'),
  };
}

/// Token standard classification.
enum TokenStandard {
  programmableNonFungible('ProgrammableNonFungible'),
  nonFungible('NonFungible'),
  fungible('Fungible'),
  fungibleAsset('FungibleAsset'),
  nonFungibleEdition('NonFungibleEdition'),
  unknownStandard('UnknownStandard');

  const TokenStandard(this.value);

  /// The wire-format string sent to / received from the Helius API.
  final String value;

  /// Serializes this value to its API string representation.
  String toJson() => value;

  /// Deserializes an API string to a [TokenStandard].
  ///
  /// Throws [ArgumentError] if [json] is not a recognized value.
  static TokenStandard fromJson(String json) => switch (json) {
    'ProgrammableNonFungible' => programmableNonFungible,
    'NonFungible' => nonFungible,
    'Fungible' => fungible,
    'FungibleAsset' => fungibleAsset,
    'NonFungibleEdition' => nonFungibleEdition,
    'UnknownStandard' => unknownStandard,
    _ => throw ArgumentError.value(json, 'json', 'Unknown TokenStandard'),
  };
}

/// Priority fee level hint for the `getPriorityFeeEstimate` API.
enum PriorityLevel {
  min('Min'),
  low('Low'),
  medium('Medium'),
  high('High'),
  veryHigh('VeryHigh'),
  unsafeMax('UnsafeMax'),
  default_('Default');

  const PriorityLevel(this.value);

  /// The wire-format string sent to / received from the Helius API.
  final String value;

  /// Serializes this value to its API string representation.
  String toJson() => value;

  /// Deserializes an API string to a [PriorityLevel].
  ///
  /// Throws [ArgumentError] if [json] is not a recognized value.
  static PriorityLevel fromJson(String json) => switch (json) {
    'Min' => min,
    'Low' => low,
    'Medium' => medium,
    'High' => high,
    'VeryHigh' => veryHigh,
    'UnsafeMax' => unsafeMax,
    'Default' => default_,
    _ => throw ArgumentError.value(json, 'json', 'Unknown PriorityLevel'),
  };
}

/// Transaction encoding format for UI / RPC requests.
enum UiTransactionEncoding {
  binary('binary'),
  base64('base64'),
  base58('base58'),
  json('json'),
  jsonParsed('jsonParsed');

  const UiTransactionEncoding(this.value);

  /// The wire-format string sent to / received from the Helius API.
  final String value;

  /// Serializes this value to its API string representation.
  String toJson() => value;

  /// Deserializes an API string to a [UiTransactionEncoding].
  ///
  /// Throws [ArgumentError] if [json] is not a recognized value.
  static UiTransactionEncoding fromJson(String json) => switch (json) {
    'binary' => binary,
    'base64' => base64,
    'base58' => base58,
    'json' => UiTransactionEncoding.json,
    'jsonParsed' => jsonParsed,
    _ => throw ArgumentError.value(
      json,
      'json',
      'Unknown UiTransactionEncoding',
    ),
  };
}

/// Delivery format for Helius webhook payloads.
enum WebhookType {
  enhanced('enhanced'),
  enhancedDevnet('enhancedDevnet'),
  raw('raw'),
  rawDevnet('rawDevnet'),
  discord('discord'),
  discordDevnet('discordDevnet');

  const WebhookType(this.value);

  /// The wire-format string sent to / received from the Helius API.
  final String value;

  /// Serializes this value to its API string representation.
  String toJson() => value;

  /// Deserializes an API string to a [WebhookType].
  ///
  /// Throws [ArgumentError] if [json] is not a recognized value.
  static WebhookType fromJson(String json) => switch (json) {
    'enhanced' => enhanced,
    'enhancedDevnet' => enhancedDevnet,
    'raw' => raw,
    'rawDevnet' => rawDevnet,
    'discord' => discord,
    'discordDevnet' => discordDevnet,
    _ => throw ArgumentError.value(json, 'json', 'Unknown WebhookType'),
  };
}

/// Filter by transaction status for webhook subscriptions.
enum TransactionStatus {
  all('all'),
  success('success'),
  failed('failed');

  const TransactionStatus(this.value);

  /// The wire-format string sent to / received from the Helius API.
  final String value;

  /// Serializes this value to its API string representation.
  String toJson() => value;

  /// Deserializes an API string to a [TransactionStatus].
  ///
  /// Throws [ArgumentError] if [json] is not a recognized value.
  static TransactionStatus fromJson(String json) => switch (json) {
    'all' => all,
    'success' => success,
    'failed' => failed,
    _ => throw ArgumentError.value(json, 'json', 'Unknown TransactionStatus'),
  };
}

/// Commitment level for Solana RPC requests via Helius.
enum CommitmentLevel {
  processed('processed'),
  confirmed('confirmed'),
  finalized('finalized');

  const CommitmentLevel(this.value);

  /// The wire-format string sent to / received from the Helius API.
  final String value;

  /// Serializes this value to its API string representation.
  String toJson() => value;

  /// Deserializes an API string to a [CommitmentLevel].
  ///
  /// Throws [ArgumentError] if [json] is not a recognized value.
  static CommitmentLevel fromJson(String json) => switch (json) {
    'processed' => processed,
    'confirmed' => confirmed,
    'finalized' => finalized,
    _ => throw ArgumentError.value(json, 'json', 'Unknown CommitmentLevel'),
  };
}
