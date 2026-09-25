import 'package:solana_kit_helius/src/internal/json_reader.dart';
import 'package:solana_kit_helius/src/types/enums.dart';

// ---------------------------------------------------------------------------
// Request types
// ---------------------------------------------------------------------------

/// Request parameters for the `getAsset` DAS method.
class GetAssetRequest {
  /// Creates a `getAsset` request.
  const GetAssetRequest({required this.id, this.displayOptions});

  /// Builds a [GetAssetRequest] from the JSON returned by the Helius API.
  factory GetAssetRequest.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return GetAssetRequest(
      id: r.requireString('id'),
      displayOptions: r.optBool('displayOptions'),
    );
  }

  /// The asset id (mint address) to fetch.
  final String id;

  /// Whether to return extended display options.
  final bool? displayOptions;

  /// Serializes this request to a JSON map suitable for the Helius RPC call.
  Map<String, Object?> toJson() => {
    'id': id,
    if (displayOptions != null) 'displayOptions': displayOptions,
  };
}

/// Request parameters for the `getAssetBatch` DAS method.
class GetAssetBatchRequest {
  /// Creates a `getAssetBatch` request.
  const GetAssetBatchRequest({required this.ids, this.displayOptions});

  /// Builds a [GetAssetBatchRequest] from the JSON returned by the Helius API.
  factory GetAssetBatchRequest.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return GetAssetBatchRequest(
      ids: r.requireList<String>('ids'),
      displayOptions: r.optBool('displayOptions'),
    );
  }

  /// The asset ids (mint addresses) to fetch.
  final List<String> ids;

  /// Whether to return extended display options.
  final bool? displayOptions;

  /// Serializes this request to a JSON map suitable for the Helius RPC call.
  Map<String, Object?> toJson() => {
    'ids': ids,
    if (displayOptions != null) 'displayOptions': displayOptions,
  };
}

/// Request parameters for the `getAssetProof` DAS method.
class GetAssetProofRequest {
  /// Creates a `getAssetProof` request.
  const GetAssetProofRequest({required this.id});

  /// Builds a [GetAssetProofRequest] from the JSON returned by the Helius API.
  factory GetAssetProofRequest.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return GetAssetProofRequest(id: r.requireString('id'));
  }

  /// The asset id (mint address) to fetch the proof for.
  final String id;

  /// Serializes this request to a JSON map suitable for the Helius RPC call.
  Map<String, Object?> toJson() => {'id': id};
}

/// Request parameters for the `getAssetProofBatch` DAS method.
class GetAssetProofBatchRequest {
  /// Creates a `getAssetProofBatch` request.
  const GetAssetProofBatchRequest({required this.ids});

  /// Builds a [GetAssetProofBatchRequest] from the JSON returned by the Helius
  /// API.
  factory GetAssetProofBatchRequest.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return GetAssetProofBatchRequest(ids: r.requireList<String>('ids'));
  }

  /// The asset ids (mint addresses) to fetch proofs for.
  final List<String> ids;

  /// Serializes this request to a JSON map suitable for the Helius RPC call.
  Map<String, Object?> toJson() => {'ids': ids};
}

/// Request parameters for the `getAssetsByAuthority` DAS method.
class GetAssetsByAuthorityRequest {
  /// Creates a `getAssetsByAuthority` request.
  const GetAssetsByAuthorityRequest({
    required this.authorityAddress,
    this.page,
    this.limit,
    this.sortBy,
    this.sortDirection,
    this.before,
    this.after,
  });

  /// Builds a [GetAssetsByAuthorityRequest] from the JSON returned by the
  /// Helius API.
  factory GetAssetsByAuthorityRequest.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return GetAssetsByAuthorityRequest(
      authorityAddress: r.requireString('authorityAddress'),
      page: r.optInt('page'),
      limit: r.optInt('limit'),
      sortBy: r.optEnum('sortBy', AssetSortBy.fromJson),
      sortDirection: r.optEnum('sortDirection', AssetSortDirection.fromJson),
      before: r.optString('before'),
      after: r.optString('after'),
    );
  }

  /// The authority address to filter assets by.
  final String authorityAddress;

  /// The page number to return (zero-indexed).
  final int? page;

  /// The maximum number of assets to return per page.
  final int? limit;

  /// The field to sort results by.
  final AssetSortBy? sortBy;

  /// The direction to sort results.
  final AssetSortDirection? sortDirection;

  /// Return assets before this asset id (exclusive).
  final String? before;

  /// Return assets after this asset id (exclusive).
  final String? after;

  /// Serializes this request to a JSON map suitable for the Helius RPC call.
  Map<String, Object?> toJson() => {
    'authorityAddress': authorityAddress,
    if (page != null) 'page': page,
    if (limit != null) 'limit': limit,
    if (sortBy != null) 'sortBy': sortBy!.toJson(),
    if (sortDirection != null) 'sortDirection': sortDirection!.toJson(),
    if (before != null) 'before': before,
    if (after != null) 'after': after,
  };
}

/// Request parameters for the `getAssetsByCreator` DAS method.
class GetAssetsByCreatorRequest {
  /// Creates a `getAssetsByCreator` request.
  const GetAssetsByCreatorRequest({
    required this.creatorAddress,
    this.onlyVerified,
    this.page,
    this.limit,
    this.sortBy,
    this.sortDirection,
    this.before,
    this.after,
  });

  /// Builds a [GetAssetsByCreatorRequest] from the JSON returned by the Helius
  /// API.
  factory GetAssetsByCreatorRequest.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return GetAssetsByCreatorRequest(
      creatorAddress: r.requireString('creatorAddress'),
      onlyVerified: r.optBool('onlyVerified'),
      page: r.optInt('page'),
      limit: r.optInt('limit'),
      sortBy: r.optEnum('sortBy', AssetSortBy.fromJson),
      sortDirection: r.optEnum('sortDirection', AssetSortDirection.fromJson),
      before: r.optString('before'),
      after: r.optString('after'),
    );
  }

  /// The creator address to filter assets by.
  final String creatorAddress;

  /// Whether to only return assets from verified creators.
  final bool? onlyVerified;

  /// The page number to return (zero-indexed).
  final int? page;

  /// The maximum number of assets to return per page.
  final int? limit;

  /// The field to sort results by.
  final AssetSortBy? sortBy;

  /// The direction to sort results.
  final AssetSortDirection? sortDirection;

  /// Return assets before this asset id (exclusive).
  final String? before;

  /// Return assets after this asset id (exclusive).
  final String? after;

  /// Serializes this request to a JSON map suitable for the Helius RPC call.
  Map<String, Object?> toJson() => {
    'creatorAddress': creatorAddress,
    if (onlyVerified != null) 'onlyVerified': onlyVerified,
    if (page != null) 'page': page,
    if (limit != null) 'limit': limit,
    if (sortBy != null) 'sortBy': sortBy!.toJson(),
    if (sortDirection != null) 'sortDirection': sortDirection!.toJson(),
    if (before != null) 'before': before,
    if (after != null) 'after': after,
  };
}

/// Request parameters for the `getAssetsByGroup` DAS method.
class GetAssetsByGroupRequest {
  /// Creates a `getAssetsByGroup` request.
  const GetAssetsByGroupRequest({
    required this.groupKey,
    required this.groupValue,
    this.page,
    this.limit,
    this.sortBy,
    this.sortDirection,
    this.before,
    this.after,
  });

  /// Builds a [GetAssetsByGroupRequest] from the JSON returned by the Helius
  /// API.
  factory GetAssetsByGroupRequest.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return GetAssetsByGroupRequest(
      groupKey: r.requireString('groupKey'),
      groupValue: r.requireString('groupValue'),
      page: r.optInt('page'),
      limit: r.optInt('limit'),
      sortBy: r.optEnum('sortBy', AssetSortBy.fromJson),
      sortDirection: r.optEnum('sortDirection', AssetSortDirection.fromJson),
      before: r.optString('before'),
      after: r.optString('after'),
    );
  }

  /// The group key (e.g. `collection`) to filter assets by.
  final String groupKey;

  /// The group value associated with [groupKey].
  final String groupValue;

  /// The page number to return (zero-indexed).
  final int? page;

  /// The maximum number of assets to return per page.
  final int? limit;

  /// The field to sort results by.
  final AssetSortBy? sortBy;

  /// The direction to sort results.
  final AssetSortDirection? sortDirection;

  /// Return assets before this asset id (exclusive).
  final String? before;

  /// Return assets after this asset id (exclusive).
  final String? after;

  /// Serializes this request to a JSON map suitable for the Helius RPC call.
  Map<String, Object?> toJson() => {
    'groupKey': groupKey,
    'groupValue': groupValue,
    if (page != null) 'page': page,
    if (limit != null) 'limit': limit,
    if (sortBy != null) 'sortBy': sortBy!.toJson(),
    if (sortDirection != null) 'sortDirection': sortDirection!.toJson(),
    if (before != null) 'before': before,
    if (after != null) 'after': after,
  };
}

/// Request parameters for the `getAssetsByOwner` DAS method.
class GetAssetsByOwnerRequest {
  /// Creates a `getAssetsByOwner` request.
  const GetAssetsByOwnerRequest({
    required this.ownerAddress,
    this.page,
    this.limit,
    this.sortBy,
    this.sortDirection,
    this.before,
    this.after,
  });

  /// Builds a [GetAssetsByOwnerRequest] from the JSON returned by the Helius
  /// API.
  factory GetAssetsByOwnerRequest.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return GetAssetsByOwnerRequest(
      ownerAddress: r.requireString('ownerAddress'),
      page: r.optInt('page'),
      limit: r.optInt('limit'),
      sortBy: r.optEnum('sortBy', AssetSortBy.fromJson),
      sortDirection: r.optEnum('sortDirection', AssetSortDirection.fromJson),
      before: r.optString('before'),
      after: r.optString('after'),
    );
  }

  /// The owner address to filter assets by.
  final String ownerAddress;

  /// The page number to return (zero-indexed).
  final int? page;

  /// The maximum number of assets to return per page.
  final int? limit;

  /// The field to sort results by.
  final AssetSortBy? sortBy;

  /// The direction to sort results.
  final AssetSortDirection? sortDirection;

  /// Return assets before this asset id (exclusive).
  final String? before;

  /// Return assets after this asset id (exclusive).
  final String? after;

  /// Serializes this request to a JSON map suitable for the Helius RPC call.
  Map<String, Object?> toJson() => {
    'ownerAddress': ownerAddress,
    if (page != null) 'page': page,
    if (limit != null) 'limit': limit,
    if (sortBy != null) 'sortBy': sortBy!.toJson(),
    if (sortDirection != null) 'sortDirection': sortDirection!.toJson(),
    if (before != null) 'before': before,
    if (after != null) 'after': after,
  };
}

/// Request parameters for the `getNftEditions` DAS method.
class GetNftEditionsRequest {
  /// Creates a `getNftEditions` request.
  const GetNftEditionsRequest({required this.mint, this.page, this.limit});

  /// Builds a [GetNftEditionsRequest] from the JSON returned by the Helius API.
  factory GetNftEditionsRequest.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return GetNftEditionsRequest(
      mint: r.requireString('mint'),
      page: r.optInt('page'),
      limit: r.optInt('limit'),
    );
  }

  /// The master edition mint to fetch editions for.
  final String mint;

  /// The page number to return (zero-indexed).
  final int? page;

  /// The maximum number of editions to return per page.
  final int? limit;

  /// Serializes this request to a JSON map suitable for the Helius RPC call.
  Map<String, Object?> toJson() => {
    'mint': mint,
    if (page != null) 'page': page,
    if (limit != null) 'limit': limit,
  };
}

/// Request parameters for the `getSignaturesForAsset` DAS method.
class GetSignaturesForAssetRequest {
  /// Creates a `getSignaturesForAsset` request.
  const GetSignaturesForAssetRequest({
    required this.id,
    this.page,
    this.limit,
    this.before,
    this.after,
  });

  /// Builds a [GetSignaturesForAssetRequest] from the JSON returned by the
  /// Helius API.
  factory GetSignaturesForAssetRequest.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return GetSignaturesForAssetRequest(
      id: r.requireString('id'),
      page: r.optInt('page'),
      limit: r.optInt('limit'),
      before: r.optString('before'),
      after: r.optString('after'),
    );
  }

  /// The asset id (mint address) to fetch signatures for.
  final String id;

  /// The page number to return (zero-indexed).
  final int? page;

  /// The maximum number of signatures to return per page.
  final int? limit;

  /// Return signatures before this signature (exclusive).
  final String? before;

  /// Return signatures after this signature (exclusive).
  final String? after;

  /// Serializes this request to a JSON map suitable for the Helius RPC call.
  Map<String, Object?> toJson() => {
    'id': id,
    if (page != null) 'page': page,
    if (limit != null) 'limit': limit,
    if (before != null) 'before': before,
    if (after != null) 'after': after,
  };
}

/// Request parameters for the `getTokenAccounts` DAS method.
class GetTokenAccountsRequest {
  /// Creates a `getTokenAccounts` request.
  const GetTokenAccountsRequest({this.owner, this.mint, this.page, this.limit});

  /// Builds a [GetTokenAccountsRequest] from the JSON returned by the Helius
  /// API.
  factory GetTokenAccountsRequest.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return GetTokenAccountsRequest(
      owner: r.optString('owner'),
      mint: r.optString('mint'),
      page: r.optInt('page'),
      limit: r.optInt('limit'),
    );
  }

  /// The owner address to filter token accounts by.
  final String? owner;

  /// The mint address to filter token accounts by.
  final String? mint;

  /// The page number to return (zero-indexed).
  final int? page;

  /// The maximum number of token accounts to return per page.
  final int? limit;

  /// Serializes this request to a JSON map suitable for the Helius RPC call.
  Map<String, Object?> toJson() => {
    if (owner != null) 'owner': owner,
    if (mint != null) 'mint': mint,
    if (page != null) 'page': page,
    if (limit != null) 'limit': limit,
  };
}

/// Request parameters for the `searchAssets` DAS method.
class SearchAssetsRequest {
  /// Creates a `searchAssets` request.
  const SearchAssetsRequest({
    this.ownerAddress,
    this.creatorAddress,
    this.grouping,
    this.compressed,
    this.compressible,
    this.frozen,
    this.burnt,
    this.jsonUri,
    this.page,
    this.limit,
    this.sortBy,
    this.sortDirection,
    this.before,
    this.after,
  });

  /// Builds a [SearchAssetsRequest] from the JSON returned by the Helius API.
  factory SearchAssetsRequest.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return SearchAssetsRequest(
      ownerAddress: r.optString('ownerAddress'),
      creatorAddress: r.optString('creatorAddress'),
      grouping: r.optString('grouping'),
      compressed: r.optBool('compressed'),
      compressible: r.optBool('compressible'),
      frozen: r.optBool('frozen'),
      burnt: r.optBool('burnt'),
      jsonUri: r.optString('jsonUri'),
      page: r.optInt('page'),
      limit: r.optInt('limit'),
      sortBy: r.optEnum('sortBy', AssetSortBy.fromJson),
      sortDirection: r.optEnum('sortDirection', AssetSortDirection.fromJson),
      before: r.optString('before'),
      after: r.optString('after'),
    );
  }

  /// Filter assets owned by this address.
  final String? ownerAddress;

  /// Filter assets by this creator address.
  final String? creatorAddress;

  /// Filter assets by this grouping value.
  final String? grouping;

  /// Filter assets by whether they are compressed.
  final bool? compressed;

  /// Filter assets by whether they are compressible.
  final bool? compressible;

  /// Filter assets by whether they are frozen.
  final bool? frozen;

  /// Filter assets by whether they are burnt.
  final bool? burnt;

  /// Filter assets by their JSON metadata URI.
  final String? jsonUri;

  /// The page number to return (zero-indexed).
  final int? page;

  /// The maximum number of assets to return per page.
  final int? limit;

  /// The field to sort results by.
  final AssetSortBy? sortBy;

  /// The direction to sort results.
  final AssetSortDirection? sortDirection;

  /// Return assets before this asset id (exclusive).
  final String? before;

  /// Return assets after this asset id (exclusive).
  final String? after;

  /// Serializes this request to a JSON map suitable for the Helius RPC call.
  Map<String, Object?> toJson() => {
    if (ownerAddress != null) 'ownerAddress': ownerAddress,
    if (creatorAddress != null) 'creatorAddress': creatorAddress,
    if (grouping != null) 'grouping': grouping,
    if (compressed != null) 'compressed': compressed,
    if (compressible != null) 'compressible': compressible,
    if (frozen != null) 'frozen': frozen,
    if (burnt != null) 'burnt': burnt,
    if (jsonUri != null) 'jsonUri': jsonUri,
    if (page != null) 'page': page,
    if (limit != null) 'limit': limit,
    if (sortBy != null) 'sortBy': sortBy!.toJson(),
    if (sortDirection != null) 'sortDirection': sortDirection!.toJson(),
    if (before != null) 'before': before,
    if (after != null) 'after': after,
  };
}

// ---------------------------------------------------------------------------
// Response / model types
// ---------------------------------------------------------------------------

/// A digital asset returned by the Helius DAS API.
class HeliusAsset {
  /// Creates a [HeliusAsset].
  const HeliusAsset({
    required this.id,
    this.interface_,
    this.content,
    this.authorities,
    this.compression,
    this.grouping,
    this.royalty,
    this.creators,
    this.ownership,
    this.supply,
    this.mutable,
    this.burnt,
    this.tokenInfo,
    this.mintExtensions,
  });

  /// Builds a [HeliusAsset] from the JSON returned by the Helius API.
  factory HeliusAsset.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return HeliusAsset(
      id: r.requireString('id'),
      interface_: r.optString('interface'),
      content: r.optDecoded('content', AssetContent.fromJson),
      authorities: r.optDecodedList('authorities', AssetAuthority.fromJson),
      compression: r.optDecoded('compression', AssetCompression.fromJson),
      grouping: r.optDecodedList('grouping', AssetGrouping.fromJson),
      royalty: r.optDecoded('royalty', AssetRoyalty.fromJson),
      creators: r.optDecodedList('creators', AssetCreator.fromJson),
      ownership: r.optDecoded('ownership', AssetOwnership.fromJson),
      supply: r.optDecoded('supply', AssetSupply.fromJson),
      mutable: r.optBool('mutable'),
      burnt: r.optBool('burnt'),
      tokenInfo: r.optDecoded('token_info', AssetTokenInfo.fromJson),
      mintExtensions: r.optMap('mint_extensions'),
    );
  }

  /// The on-chain id (mint address) of the asset.
  final String id;

  /// The asset interface type (e.g. `Mint`, `ProgrammableNFT`).
  final String? interface_;

  /// Off-chain content metadata for the asset.
  final AssetContent? content;

  /// Authorities associated with the asset.
  final List<AssetAuthority>? authorities;

  /// Compression details for the asset (compressed NFTs / cNFTs).
  final AssetCompression? compression;

  /// Grouping records (e.g. collection membership) for the asset.
  final List<AssetGrouping>? grouping;

  /// Royalty configuration for the asset.
  final AssetRoyalty? royalty;

  /// Creators credited on the asset.
  final List<AssetCreator>? creators;

  /// Ownership information for the asset.
  final AssetOwnership? ownership;

  /// Supply (edition) information for the asset.
  final AssetSupply? supply;

  /// Whether the asset's metadata is mutable.
  final bool? mutable;

  /// Whether the asset has been burnt.
  final bool? burnt;

  /// Token-specific information for fungible token assets.
  final AssetTokenInfo? tokenInfo;

  /// Raw mint extensions data for Token-2022 assets.
  final Map<String, Object?>? mintExtensions;

  /// Serializes this asset to a JSON map matching the Helius DAS schema.
  Map<String, Object?> toJson() => {
    'id': id,
    if (interface_ != null) 'interface': interface_,
    if (content != null) 'content': content!.toJson(),
    if (authorities != null)
      'authorities': authorities!.map((a) => a.toJson()).toList(),
    if (compression != null) 'compression': compression!.toJson(),
    if (grouping != null) 'grouping': grouping!.map((g) => g.toJson()).toList(),
    if (royalty != null) 'royalty': royalty!.toJson(),
    if (creators != null) 'creators': creators!.map((c) => c.toJson()).toList(),
    if (ownership != null) 'ownership': ownership!.toJson(),
    if (supply != null) 'supply': supply!.toJson(),
    if (mutable != null) 'mutable': mutable,
    if (burnt != null) 'burnt': burnt,
    if (tokenInfo != null) 'token_info': tokenInfo!.toJson(),
    if (mintExtensions != null) 'mint_extensions': mintExtensions,
  };
}

/// Content metadata for a digital asset.
class AssetContent {
  /// Creates an [AssetContent].
  const AssetContent({this.jsonUri, this.files, this.metadata, this.links});

  /// Builds an [AssetContent] from the JSON returned by the Helius API.
  factory AssetContent.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return AssetContent(
      jsonUri: r.optString('json_uri'),
      files: r.optDecodedList('files', AssetFile.fromJson),
      metadata: r.optDecoded('metadata', AssetMetadata.fromJson),
      links: r.optMap('links'),
    );
  }

  /// The URI of the off-chain JSON metadata.
  final String? jsonUri;

  /// Files associated with the asset.
  final List<AssetFile>? files;

  /// On-chain and off-chain metadata for the asset.
  final AssetMetadata? metadata;

  /// Additional links (e.g. image, external URLs) for the asset.
  final Map<String, Object?>? links;

  /// Serializes this content to a JSON map matching the Helius DAS schema.
  Map<String, Object?> toJson() => {
    if (jsonUri != null) 'json_uri': jsonUri,
    if (files != null) 'files': files!.map((f) => f.toJson()).toList(),
    if (metadata != null) 'metadata': metadata!.toJson(),
    if (links != null) 'links': links,
  };
}

/// A file associated with an asset.
class AssetFile {
  /// Creates an [AssetFile].
  const AssetFile({this.uri, this.cdnUri, this.mime});

  /// Builds an [AssetFile] from the JSON returned by the Helius API.
  factory AssetFile.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return AssetFile(
      uri: r.optString('uri'),
      cdnUri: r.optString('cdn_uri'),
      mime: r.optString('mime'),
    );
  }

  /// The original URI of the file.
  final String? uri;

  /// The Helius CDN-cached URI for the file.
  final String? cdnUri;

  /// The MIME type of the file.
  final String? mime;

  /// Serializes this file to a JSON map matching the Helius DAS schema.
  Map<String, Object?> toJson() => {
    if (uri != null) 'uri': uri,
    if (cdnUri != null) 'cdn_uri': cdnUri,
    if (mime != null) 'mime': mime,
  };
}

/// On-chain and off-chain metadata for an asset.
class AssetMetadata {
  /// Creates an [AssetMetadata].
  const AssetMetadata({
    this.name,
    this.symbol,
    this.description,
    this.attributes,
  });

  /// Builds an [AssetMetadata] from the JSON returned by the Helius API.
  factory AssetMetadata.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return AssetMetadata(
      name: r.optString('name'),
      symbol: r.optString('symbol'),
      description: r.optString('description'),
      attributes: r.optDecodedList('attributes', AssetAttribute.fromJson),
    );
  }

  /// The name of the asset.
  final String? name;

  /// The symbol/ticker of the asset.
  final String? symbol;

  /// A human-readable description of the asset.
  final String? description;

  /// Trait attributes for the asset.
  final List<AssetAttribute>? attributes;

  /// Serializes this metadata to a JSON map matching the Helius DAS schema.
  Map<String, Object?> toJson() => {
    if (name != null) 'name': name,
    if (symbol != null) 'symbol': symbol,
    if (description != null) 'description': description,
    if (attributes != null)
      'attributes': attributes!.map((a) => a.toJson()).toList(),
  };
}

/// A single trait attribute on an asset.
class AssetAttribute {
  /// Creates an [AssetAttribute].
  const AssetAttribute({this.traitType, this.value});

  /// Builds an [AssetAttribute] from the JSON returned by the Helius API.
  factory AssetAttribute.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return AssetAttribute(
      traitType: r.optString('trait_type'),
      value: r.raw('value'),
    );
  }

  /// The trait type (name) of the attribute.
  final String? traitType;

  /// The trait value, which may be any JSON-encoded value.
  final Object? value;

  /// Serializes this attribute to a JSON map matching the Helius DAS schema.
  Map<String, Object?> toJson() => {
    if (traitType != null) 'trait_type': traitType,
    if (value != null) 'value': value,
  };
}

/// An authority record for an asset.
class AssetAuthority {
  /// Creates an [AssetAuthority].
  const AssetAuthority({required this.address, this.scopes});

  /// Builds an [AssetAuthority] from the JSON returned by the Helius API.
  factory AssetAuthority.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return AssetAuthority(
      address: r.requireString('address'),
      scopes: r.optList<String>('scopes'),
    );
  }

  /// The authority address.
  final String address;

  /// The scopes granted to this authority.
  final List<String>? scopes;

  /// Serializes this authority to a JSON map matching the Helius DAS schema.
  Map<String, Object?> toJson() => {
    'address': address,
    if (scopes != null) 'scopes': scopes,
  };
}

/// Compression information for an asset (compressed NFTs / cNFTs).
class AssetCompression {
  /// Creates an [AssetCompression].
  const AssetCompression({
    this.eligible,
    this.compressed,
    this.dataHash,
    this.creatorHash,
    this.assetHash,
    this.tree,
    this.seq,
    this.leafId,
  });

  /// Builds an [AssetCompression] from the JSON returned by the Helius API.
  factory AssetCompression.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return AssetCompression(
      eligible: r.optBool('eligible'),
      compressed: r.optBool('compressed'),
      dataHash: r.optString('data_hash'),
      creatorHash: r.optString('creator_hash'),
      assetHash: r.optString('asset_hash'),
      tree: r.optString('tree'),
      seq: r.optInt('seq'),
      leafId: r.optInt('leaf_id'),
    );
  }

  /// Whether the asset is eligible for compression.
  final bool? eligible;

  /// Whether the asset is compressed.
  final bool? compressed;

  /// The hash of the asset's data.
  final String? dataHash;

  /// The hash of the asset's creators.
  final String? creatorHash;

  /// The hash of the asset.
  final String? assetHash;

  /// The address of the merkle tree storing the asset.
  final String? tree;

  /// The sequence number of the asset in the merkle tree.
  final int? seq;

  /// The leaf id of the asset in the merkle tree.
  final int? leafId;

  /// Serializes this compression info to a JSON map matching the Helius DAS
  /// schema.
  Map<String, Object?> toJson() => {
    if (eligible != null) 'eligible': eligible,
    if (compressed != null) 'compressed': compressed,
    if (dataHash != null) 'data_hash': dataHash,
    if (creatorHash != null) 'creator_hash': creatorHash,
    if (assetHash != null) 'asset_hash': assetHash,
    if (tree != null) 'tree': tree,
    if (seq != null) 'seq': seq,
    if (leafId != null) 'leaf_id': leafId,
  };
}

/// A grouping record (e.g. collection) for an asset.
class AssetGrouping {
  /// Creates an [AssetGrouping].
  const AssetGrouping({required this.groupKey, required this.groupValue});

  /// Builds an [AssetGrouping] from the JSON returned by the Helius API.
  factory AssetGrouping.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return AssetGrouping(
      groupKey: r.requireString('group_key'),
      groupValue: r.requireString('group_value'),
    );
  }

  /// The group key (e.g. `collection`).
  final String groupKey;

  /// The value associated with [groupKey].
  final String groupValue;

  /// Serializes this grouping to a JSON map matching the Helius DAS schema.
  Map<String, Object?> toJson() => {
    'group_key': groupKey,
    'group_value': groupValue,
  };
}

/// Royalty configuration for an asset.
class AssetRoyalty {
  /// Creates an [AssetRoyalty].
  const AssetRoyalty({
    this.royaltyModel,
    this.target,
    this.percent,
    this.basisPoints,
    this.primarySaleHappened,
    this.locked,
  });

  /// Builds an [AssetRoyalty] from the JSON returned by the Helius API.
  factory AssetRoyalty.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return AssetRoyalty(
      royaltyModel: r.optString('royalty_model'),
      target: r.optString('target'),
      percent: r.optDouble('percent'),
      basisPoints: r.optInt('basis_points'),
      primarySaleHappened: r.optBool('primary_sale_happened'),
      locked: r.optBool('locked'),
    );
  }

  /// The royalty model used by the asset.
  final String? royaltyModel;

  /// The target address for royalty payments.
  final String? target;

  /// The royalty percentage.
  final double? percent;

  /// The royalty amount in basis points.
  final int? basisPoints;

  /// Whether a primary sale has occurred.
  final bool? primarySaleHappened;

  /// Whether the royalty configuration is locked.
  final bool? locked;

  /// Serializes this royalty to a JSON map matching the Helius DAS schema.
  Map<String, Object?> toJson() => {
    if (royaltyModel != null) 'royalty_model': royaltyModel,
    if (target != null) 'target': target,
    if (percent != null) 'percent': percent,
    if (basisPoints != null) 'basis_points': basisPoints,
    if (primarySaleHappened != null)
      'primary_sale_happened': primarySaleHappened,
    if (locked != null) 'locked': locked,
  };
}

/// A creator entry on an asset.
class AssetCreator {
  /// Creates an [AssetCreator].
  const AssetCreator({
    required this.address,
    required this.share,
    required this.verified,
  });

  /// Builds an [AssetCreator] from the JSON returned by the Helius API.
  factory AssetCreator.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return AssetCreator(
      address: r.requireString('address'),
      share: r.requireInt('share'),
      verified: r.requireBool('verified'),
    );
  }

  /// The creator address.
  final String address;

  /// The creator's share of the royalties (0-100).
  final int share;

  /// Whether the creator is verified.
  final bool verified;

  /// Serializes this creator to a JSON map matching the Helius DAS schema.
  Map<String, Object?> toJson() => {
    'address': address,
    'share': share,
    'verified': verified,
  };
}

/// Ownership information for an asset.
class AssetOwnership {
  /// Creates an [AssetOwnership].
  const AssetOwnership({
    this.frozen,
    this.delegated,
    this.delegate,
    this.ownershipModel,
    this.owner,
  });

  /// Builds an [AssetOwnership] from the JSON returned by the Helius API.
  factory AssetOwnership.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return AssetOwnership(
      frozen: r.optBool('frozen'),
      delegated: r.optBool('delegated'),
      delegate: r.optString('delegate'),
      ownershipModel: r.optString('ownership_model'),
      owner: r.optString('owner'),
    );
  }

  /// Whether the asset is frozen.
  final bool? frozen;

  /// Whether the asset is delegated.
  final bool? delegated;

  /// The delegate address authorized to manage the asset.
  final String? delegate;

  /// The ownership model (e.g. `token`, `proof`).
  final String? ownershipModel;

  /// The owner address of the asset.
  final String? owner;

  /// Serializes this ownership to a JSON map matching the Helius DAS schema.
  Map<String, Object?> toJson() => {
    if (frozen != null) 'frozen': frozen,
    if (delegated != null) 'delegated': delegated,
    if (delegate != null) 'delegate': delegate,
    if (ownershipModel != null) 'ownership_model': ownershipModel,
    if (owner != null) 'owner': owner,
  };
}

/// Supply information for an asset (editions).
class AssetSupply {
  /// Creates an [AssetSupply].
  const AssetSupply({
    this.printMaxSupply,
    this.printCurrentSupply,
    this.editionNonce,
  });

  /// Builds an [AssetSupply] from the JSON returned by the Helius API.
  factory AssetSupply.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return AssetSupply(
      printMaxSupply: r.optInt('print_max_supply'),
      printCurrentSupply: r.optInt('print_current_supply'),
      editionNonce: r.optInt('edition_nonce'),
    );
  }

  /// The maximum number of prints (editions) that can be minted.
  final int? printMaxSupply;

  /// The current number of prints (editions) minted.
  final int? printCurrentSupply;

  /// The edition nonce used for pNFTs.
  final int? editionNonce;

  /// Serializes this supply to a JSON map matching the Helius DAS schema.
  Map<String, Object?> toJson() => {
    if (printMaxSupply != null) 'print_max_supply': printMaxSupply,
    if (printCurrentSupply != null) 'print_current_supply': printCurrentSupply,
    if (editionNonce != null) 'edition_nonce': editionNonce,
  };
}

/// Token-specific information for an asset.
class AssetTokenInfo {
  /// Creates an [AssetTokenInfo].
  const AssetTokenInfo({
    this.supply,
    this.decimals,
    this.tokenProgram,
    this.associatedTokenAddress,
    this.mintAuthority,
    this.freezeAuthority,
    this.priceInfo,
  });

  /// Builds an [AssetTokenInfo] from the JSON returned by the Helius API.
  factory AssetTokenInfo.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return AssetTokenInfo(
      supply: r.optInt('supply'),
      decimals: r.optInt('decimals'),
      tokenProgram: r.optString('token_program'),
      associatedTokenAddress: r.optString('associated_token_address'),
      mintAuthority: r.optString('mint_authority'),
      freezeAuthority: r.optString('freeze_authority'),
      priceInfo: r.optDecoded('price_info', AssetPriceInfo.fromJson),
    );
  }

  /// The total supply of the token.
  final int? supply;

  /// The number of decimals used by the token.
  final int? decimals;

  /// The address of the token program owning the mint.
  final String? tokenProgram;

  /// The associated token account address of the owner.
  final String? associatedTokenAddress;

  /// The mint authority address.
  final String? mintAuthority;

  /// The freeze authority address.
  final String? freezeAuthority;

  /// Price information for the token.
  final AssetPriceInfo? priceInfo;

  /// Serializes this token info to a JSON map matching the Helius DAS schema.
  Map<String, Object?> toJson() => {
    if (supply != null) 'supply': supply,
    if (decimals != null) 'decimals': decimals,
    if (tokenProgram != null) 'token_program': tokenProgram,
    if (associatedTokenAddress != null)
      'associated_token_address': associatedTokenAddress,
    if (mintAuthority != null) 'mint_authority': mintAuthority,
    if (freezeAuthority != null) 'freeze_authority': freezeAuthority,
    if (priceInfo != null) 'price_info': priceInfo!.toJson(),
  };
}

/// Price information for a token asset.
class AssetPriceInfo {
  /// Creates an [AssetPriceInfo].
  const AssetPriceInfo({this.pricePerToken, this.totalPrice, this.currency});

  /// Builds an [AssetPriceInfo] from the JSON returned by the Helius API.
  factory AssetPriceInfo.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return AssetPriceInfo(
      pricePerToken: r.optDouble('price_per_token'),
      totalPrice: r.optDouble('total_price'),
      currency: r.optString('currency'),
    );
  }

  /// The price per token.
  final double? pricePerToken;

  /// The total price of the held supply.
  final double? totalPrice;

  /// The currency the prices are denominated in.
  final String? currency;

  /// Serializes this price info to a JSON map matching the Helius DAS schema.
  Map<String, Object?> toJson() => {
    if (pricePerToken != null) 'price_per_token': pricePerToken,
    if (totalPrice != null) 'total_price': totalPrice,
    if (currency != null) 'currency': currency,
  };
}

/// Merkle proof for a compressed asset.
class AssetProof {
  /// Creates an [AssetProof].
  const AssetProof({
    required this.root,
    required this.proof,
    required this.nodeIndex,
    required this.leaf,
    required this.treeId,
  });

  /// Builds an [AssetProof] from the JSON returned by the Helius API.
  factory AssetProof.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return AssetProof(
      root: r.requireString('root'),
      proof: r.requireList<String>('proof'),
      nodeIndex: r.requireInt('node_index'),
      leaf: r.requireString('leaf'),
      treeId: r.requireString('tree_id'),
    );
  }

  /// The merkle root hash of the tree.
  final String root;

  /// The proof path of hashes from the leaf to the root.
  final List<String> proof;

  /// The index of the leaf node in the merkle tree.
  final int nodeIndex;

  /// The hash of the leaf node.
  final String leaf;

  /// The address of the merkle tree storing the asset.
  final String treeId;

  /// Serializes this proof to a JSON map matching the Helius DAS schema.
  Map<String, Object?> toJson() => {
    'root': root,
    'proof': proof,
    'node_index': nodeIndex,
    'leaf': leaf,
    'tree_id': treeId,
  };
}

/// An NFT edition record.
class NftEdition {
  /// Creates an [NftEdition].
  const NftEdition({required this.mint, required this.edition});

  /// Builds an [NftEdition] from the JSON returned by the Helius API.
  factory NftEdition.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return NftEdition(
      mint: r.requireString('mint'),
      edition: r.requireInt('edition'),
    );
  }

  /// The mint address of the edition.
  final String mint;

  /// The edition number.
  final int edition;

  /// Serializes this edition to a JSON map matching the Helius DAS schema.
  Map<String, Object?> toJson() => {'mint': mint, 'edition': edition};
}

/// A transaction signature associated with an asset.
class AssetSignature {
  /// Creates an [AssetSignature].
  const AssetSignature({
    required this.signature,
    this.type_,
    this.slot,
    this.timestamp,
  });

  /// Builds an [AssetSignature] from the JSON returned by the Helius API.
  factory AssetSignature.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return AssetSignature(
      signature: r.requireString('signature'),
      type_: r.optString('type'),
      slot: r.optInt('slot'),
      timestamp: r.optInt('timestamp'),
    );
  }

  /// The transaction signature.
  final String signature;

  /// The type of the signature event.
  final String? type_;

  /// The slot in which the transaction was confirmed.
  final int? slot;

  /// The timestamp of the transaction.
  final int? timestamp;

  /// Serializes this signature to a JSON map matching the Helius DAS schema.
  Map<String, Object?> toJson() => {
    'signature': signature,
    if (type_ != null) 'type': type_,
    if (slot != null) 'slot': slot,
    if (timestamp != null) 'timestamp': timestamp,
  };
}

/// A paginated list of asset signatures.
class AssetSignatureList {
  /// Creates an [AssetSignatureList].
  const AssetSignatureList({
    required this.total,
    required this.limit,
    required this.items,
    this.page,
  });

  /// Builds an [AssetSignatureList] from the JSON returned by the Helius API.
  factory AssetSignatureList.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return AssetSignatureList(
      total: r.requireInt('total'),
      limit: r.requireInt('limit'),
      page: r.optInt('page'),
      items: r.requireDecodedList('items', AssetSignature.fromJson),
    );
  }

  /// The total number of signatures available.
  final int total;

  /// The maximum number of signatures returned per page.
  final int limit;

  /// The current page number (zero-indexed).
  final int? page;

  /// The signatures on the current page.
  final List<AssetSignature> items;

  /// Serializes this list to a JSON map matching the Helius DAS schema.
  Map<String, Object?> toJson() => {
    'total': total,
    'limit': limit,
    if (page != null) 'page': page,
    'items': items.map((i) => i.toJson()).toList(),
  };
}

/// A paginated list of digital assets.
class AssetList {
  /// Creates an [AssetList].
  const AssetList({
    required this.total,
    required this.limit,
    required this.items,
    this.page,
  });

  /// Builds an [AssetList] from the JSON returned by the Helius API.
  factory AssetList.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return AssetList(
      total: r.requireInt('total'),
      limit: r.requireInt('limit'),
      page: r.optInt('page'),
      items: r.requireDecodedList('items', HeliusAsset.fromJson),
    );
  }

  /// The total number of assets available.
  final int total;

  /// The maximum number of assets returned per page.
  final int limit;

  /// The current page number (zero-indexed).
  final int? page;

  /// The assets on the current page.
  final List<HeliusAsset> items;

  /// Serializes this list to a JSON map matching the Helius DAS schema.
  Map<String, Object?> toJson() => {
    'total': total,
    'limit': limit,
    if (page != null) 'page': page,
    'items': items.map((i) => i.toJson()).toList(),
  };
}

/// A paginated list of token accounts.
class TokenAccountList {
  /// Creates a [TokenAccountList].
  const TokenAccountList({
    required this.total,
    required this.limit,
    required this.tokenAccounts,
    this.page,
  });

  /// Builds a [TokenAccountList] from the JSON returned by the Helius API.
  factory TokenAccountList.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return TokenAccountList(
      total: r.requireInt('total'),
      limit: r.requireInt('limit'),
      page: r.optInt('page'),
      tokenAccounts: r.requireDecodedList(
        'token_accounts',
        TokenAccount.fromJson,
      ),
    );
  }

  /// The total number of token accounts available.
  final int total;

  /// The maximum number of token accounts returned per page.
  final int limit;

  /// The current page number (zero-indexed).
  final int? page;

  /// The token accounts on the current page.
  final List<TokenAccount> tokenAccounts;

  /// Serializes this list to a JSON map matching the Helius DAS schema.
  Map<String, Object?> toJson() => {
    'total': total,
    'limit': limit,
    if (page != null) 'page': page,
    'token_accounts': tokenAccounts.map((t) => t.toJson()).toList(),
  };
}

/// A single token account.
class TokenAccount {
  /// Creates a [TokenAccount].
  const TokenAccount({
    required this.address,
    required this.mint,
    required this.owner,
    required this.amount,
    this.delegatedAmount,
    this.frozen,
  });

  /// Builds a [TokenAccount] from the JSON returned by the Helius API.
  factory TokenAccount.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return TokenAccount(
      address: r.requireString('address'),
      mint: r.requireString('mint'),
      owner: r.requireString('owner'),
      amount: r.requireInt('amount'),
      delegatedAmount: r.optInt('delegated_amount'),
      frozen: r.optBool('frozen'),
    );
  }

  /// The token account address.
  final String address;

  /// The mint address of the token.
  final String mint;

  /// The owner of the token account.
  final String owner;

  /// The balance of the token account (raw units).
  final int amount;

  /// The amount delegated from this account.
  final int? delegatedAmount;

  /// Whether the token account is frozen.
  final bool? frozen;

  /// Serializes this token account to a JSON map matching the Helius DAS
  /// schema.
  Map<String, Object?> toJson() => {
    'address': address,
    'mint': mint,
    'owner': owner,
    'amount': amount,
    if (delegatedAmount != null) 'delegated_amount': delegatedAmount,
    if (frozen != null) 'frozen': frozen,
  };
}
