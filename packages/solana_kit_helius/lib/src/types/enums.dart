// Enums for the Helius SDK, mirroring the Helius TypeScript SDK enum
// definitions.
//
// Each enum provides a [toJson] instance method that returns the API string
// representation, and a static [fromJson] factory that parses from JSON.

/// Helius cluster target for API requests.
enum HeliusCluster {
  /// Solana mainnet-beta.
  mainnet('mainnet-beta'),

  /// Solana devnet.
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
  /// Metaplex Token Metadata v1 NFT.
  v1Nft('V1_NFT'),

  /// Custom asset interface.
  custom('Custom'),

  /// Metaplex Token Metadata v1 print edition.
  v1Print('V1_PRINT'),

  /// Legacy NFT standard.
  legacyNft('Legacy_NFT'),

  /// Metaplex Token Metadata v2 NFT.
  v2Nft('V2_NFT'),

  /// Fungible asset standard.
  fungibleAsset('FungibleAsset'),

  /// Identity asset standard.
  identity('Identity'),

  /// Executable asset standard.
  executable('Executable'),

  /// Programmable NFT standard.
  programmableNft('ProgrammableNFT'),

  /// Fungible token standard.
  fungibleToken('FungibleToken'),

  /// Metaplex Core asset standard.
  mplCoreAsset('MplCoreAsset'),

  /// Metaplex Core collection standard.
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
  /// Single owner holding the asset.
  single('single'),

  /// Ownership tracked via token balances.
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
  /// Royalties split across creators.
  creators('creators'),

  /// Royalties fanned out to holders.
  fanout('fanout'),

  /// Royalty owed to a single recipient.
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
  /// Full authority over the asset.
  full('full'),

  /// Authority limited to royalties.
  royalty('royalty'),

  /// Authority limited to metadata.
  metadata('metadata'),

  /// Authority limited to extensions.
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
  /// Burn the asset on use.
  burn('Burn'),

  /// Single use only.
  single_('Single'),

  /// Multiple uses allowed.
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
  /// Default wallet rendering context.
  walletDefault('wallet-default'),

  /// Desktop web rendering context.
  webDesktop('web-desktop'),

  /// Mobile web rendering context.
  webMobile('web-mobile'),

  /// Mobile app rendering context.
  appMobile('app-mobile'),

  /// Desktop app rendering context.
  appDesktop('app-desktop'),

  /// Generic app rendering context.
  app('app'),

  /// Virtual reality rendering context.
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
  /// Sort by asset identifier.
  id('id'),

  /// Sort by creation time.
  created('created'),

  /// Sort by last update time.
  updated('updated'),

  /// Sort by most recent action.
  recentAction('recent_action'),

  /// No sorting.
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
  /// Ascending order.
  asc('asc'),

  /// Descending order.
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
  /// Programmable non-fungible token.
  programmableNonFungible('ProgrammableNonFungible'),

  /// Non-fungible token.
  nonFungible('NonFungible'),

  /// Fungible token.
  fungible('Fungible'),

  /// Fungible asset.
  fungibleAsset('FungibleAsset'),

  /// Non-fungible edition.
  nonFungibleEdition('NonFungibleEdition'),

  /// Unrecognized token standard.
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
  /// Minimum priority fee level.
  min('Min'),

  /// Low priority fee level.
  low('Low'),

  /// Medium priority fee level.
  medium('Medium'),

  /// High priority fee level.
  high('High'),

  /// Very high priority fee level.
  veryHigh('VeryHigh'),

  /// Maximum priority fee level, may be unsafe.
  unsafeMax('UnsafeMax'),

  /// Default priority fee level.
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
  /// Binary encoding.
  binary('binary'),

  /// Base64 encoding.
  base64('base64'),

  /// Base58 encoding.
  base58('base58'),

  /// JSON encoding.
  json('json'),

  /// Parsed JSON encoding.
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
  /// Enhanced transaction payload on mainnet.
  enhanced('enhanced'),

  /// Enhanced transaction payload on devnet.
  enhancedDevnet('enhancedDevnet'),

  /// Raw transaction payload on mainnet.
  raw('raw'),

  /// Raw transaction payload on devnet.
  rawDevnet('rawDevnet'),

  /// Discord-formatted payload on mainnet.
  discord('discord'),

  /// Discord-formatted payload on devnet.
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
  /// Deliver all transactions.
  all('all'),

  /// Deliver only successful transactions.
  success('success'),

  /// Deliver only failed transactions.
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
  /// Processed by the current node.
  processed('processed'),

  /// Confirmed by a supermajority of the cluster.
  confirmed('confirmed'),

  /// Finalized by the cluster.
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
