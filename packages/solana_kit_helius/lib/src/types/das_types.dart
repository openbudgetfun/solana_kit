import 'package:solana_kit_helius/src/types/enums.dart';

// ---------------------------------------------------------------------------
// Request types
// ---------------------------------------------------------------------------

/// Request parameters for the `getAsset` DAS method.
class GetAssetRequest {
  const GetAssetRequest({required this.id, this.displayOptions});

  factory GetAssetRequest.fromJson(Map<String, Object?> json) {
    return GetAssetRequest(
      id: json['id']! as String,
      displayOptions: json['displayOptions'] as bool?,
    );
  }

  final String id;
  final bool? displayOptions;

  Map<String, Object?> toJson() => {
    'id': id,
    if (displayOptions != null) 'displayOptions': displayOptions,
  };
}

/// Request parameters for the `getAssetBatch` DAS method.
class GetAssetBatchRequest {
  const GetAssetBatchRequest({required this.ids, this.displayOptions});

  factory GetAssetBatchRequest.fromJson(Map<String, Object?> json) {
    return GetAssetBatchRequest(
      ids: (json['ids']! as List<Object?>).cast<String>(),
      displayOptions: json['displayOptions'] as bool?,
    );
  }

  final List<String> ids;
  final bool? displayOptions;

  Map<String, Object?> toJson() => {
    'ids': ids,
    if (displayOptions != null) 'displayOptions': displayOptions,
  };
}

/// Request parameters for the `getAssetProof` DAS method.
class GetAssetProofRequest {
  const GetAssetProofRequest({required this.id});

  factory GetAssetProofRequest.fromJson(Map<String, Object?> json) {
    return GetAssetProofRequest(id: json['id']! as String);
  }

  final String id;

  Map<String, Object?> toJson() => {'id': id};
}

/// Request parameters for the `getAssetProofBatch` DAS method.
class GetAssetProofBatchRequest {
  const GetAssetProofBatchRequest({required this.ids});

  factory GetAssetProofBatchRequest.fromJson(Map<String, Object?> json) {
    return GetAssetProofBatchRequest(
      ids: (json['ids']! as List<Object?>).cast<String>(),
    );
  }

  final List<String> ids;

  Map<String, Object?> toJson() => {'ids': ids};
}

/// Request parameters for the `getAssetsByAuthority` DAS method.
class GetAssetsByAuthorityRequest {
  const GetAssetsByAuthorityRequest({
    required this.authorityAddress,
    this.page,
    this.limit,
    this.sortBy,
    this.sortDirection,
    this.before,
    this.after,
  });

  factory GetAssetsByAuthorityRequest.fromJson(Map<String, Object?> json) {
    return GetAssetsByAuthorityRequest(
      authorityAddress: json['authorityAddress']! as String,
      page: json['page'] as int?,
      limit: json['limit'] as int?,
      sortBy: json['sortBy'] != null
          ? AssetSortBy.fromJson(json['sortBy']! as String)
          : null,
      sortDirection: json['sortDirection'] != null
          ? AssetSortDirection.fromJson(json['sortDirection']! as String)
          : null,
      before: json['before'] as String?,
      after: json['after'] as String?,
    );
  }

  final String authorityAddress;
  final int? page;
  final int? limit;
  final AssetSortBy? sortBy;
  final AssetSortDirection? sortDirection;
  final String? before;
  final String? after;

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

  factory GetAssetsByCreatorRequest.fromJson(Map<String, Object?> json) {
    return GetAssetsByCreatorRequest(
      creatorAddress: json['creatorAddress']! as String,
      onlyVerified: json['onlyVerified'] as bool?,
      page: json['page'] as int?,
      limit: json['limit'] as int?,
      sortBy: json['sortBy'] != null
          ? AssetSortBy.fromJson(json['sortBy']! as String)
          : null,
      sortDirection: json['sortDirection'] != null
          ? AssetSortDirection.fromJson(json['sortDirection']! as String)
          : null,
      before: json['before'] as String?,
      after: json['after'] as String?,
    );
  }

  final String creatorAddress;
  final bool? onlyVerified;
  final int? page;
  final int? limit;
  final AssetSortBy? sortBy;
  final AssetSortDirection? sortDirection;
  final String? before;
  final String? after;

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

  factory GetAssetsByGroupRequest.fromJson(Map<String, Object?> json) {
    return GetAssetsByGroupRequest(
      groupKey: json['groupKey']! as String,
      groupValue: json['groupValue']! as String,
      page: json['page'] as int?,
      limit: json['limit'] as int?,
      sortBy: json['sortBy'] != null
          ? AssetSortBy.fromJson(json['sortBy']! as String)
          : null,
      sortDirection: json['sortDirection'] != null
          ? AssetSortDirection.fromJson(json['sortDirection']! as String)
          : null,
      before: json['before'] as String?,
      after: json['after'] as String?,
    );
  }

  final String groupKey;
  final String groupValue;
  final int? page;
  final int? limit;
  final AssetSortBy? sortBy;
  final AssetSortDirection? sortDirection;
  final String? before;
  final String? after;

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
  const GetAssetsByOwnerRequest({
    required this.ownerAddress,
    this.page,
    this.limit,
    this.sortBy,
    this.sortDirection,
    this.before,
    this.after,
  });

  factory GetAssetsByOwnerRequest.fromJson(Map<String, Object?> json) {
    return GetAssetsByOwnerRequest(
      ownerAddress: json['ownerAddress']! as String,
      page: json['page'] as int?,
      limit: json['limit'] as int?,
      sortBy: json['sortBy'] != null
          ? AssetSortBy.fromJson(json['sortBy']! as String)
          : null,
      sortDirection: json['sortDirection'] != null
          ? AssetSortDirection.fromJson(json['sortDirection']! as String)
          : null,
      before: json['before'] as String?,
      after: json['after'] as String?,
    );
  }

  final String ownerAddress;
  final int? page;
  final int? limit;
  final AssetSortBy? sortBy;
  final AssetSortDirection? sortDirection;
  final String? before;
  final String? after;

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
  const GetNftEditionsRequest({required this.mint, this.page, this.limit});

  factory GetNftEditionsRequest.fromJson(Map<String, Object?> json) {
    return GetNftEditionsRequest(
      mint: json['mint']! as String,
      page: json['page'] as int?,
      limit: json['limit'] as int?,
    );
  }

  final String mint;
  final int? page;
  final int? limit;

  Map<String, Object?> toJson() => {
    'mint': mint,
    if (page != null) 'page': page,
    if (limit != null) 'limit': limit,
  };
}

/// Request parameters for the `getSignaturesForAsset` DAS method.
class GetSignaturesForAssetRequest {
  const GetSignaturesForAssetRequest({
    required this.id,
    this.page,
    this.limit,
    this.before,
    this.after,
  });

  factory GetSignaturesForAssetRequest.fromJson(Map<String, Object?> json) {
    return GetSignaturesForAssetRequest(
      id: json['id']! as String,
      page: json['page'] as int?,
      limit: json['limit'] as int?,
      before: json['before'] as String?,
      after: json['after'] as String?,
    );
  }

  final String id;
  final int? page;
  final int? limit;
  final String? before;
  final String? after;

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
  const GetTokenAccountsRequest({this.owner, this.mint, this.page, this.limit});

  factory GetTokenAccountsRequest.fromJson(Map<String, Object?> json) {
    return GetTokenAccountsRequest(
      owner: json['owner'] as String?,
      mint: json['mint'] as String?,
      page: json['page'] as int?,
      limit: json['limit'] as int?,
    );
  }

  final String? owner;
  final String? mint;
  final int? page;
  final int? limit;

  Map<String, Object?> toJson() => {
    if (owner != null) 'owner': owner,
    if (mint != null) 'mint': mint,
    if (page != null) 'page': page,
    if (limit != null) 'limit': limit,
  };
}

/// Request parameters for the `searchAssets` DAS method.
class SearchAssetsRequest {
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

  factory SearchAssetsRequest.fromJson(Map<String, Object?> json) {
    return SearchAssetsRequest(
      ownerAddress: json['ownerAddress'] as String?,
      creatorAddress: json['creatorAddress'] as String?,
      grouping: json['grouping'] as String?,
      compressed: json['compressed'] as bool?,
      compressible: json['compressible'] as bool?,
      frozen: json['frozen'] as bool?,
      burnt: json['burnt'] as bool?,
      jsonUri: json['jsonUri'] as String?,
      page: json['page'] as int?,
      limit: json['limit'] as int?,
      sortBy: json['sortBy'] != null
          ? AssetSortBy.fromJson(json['sortBy']! as String)
          : null,
      sortDirection: json['sortDirection'] != null
          ? AssetSortDirection.fromJson(json['sortDirection']! as String)
          : null,
      before: json['before'] as String?,
      after: json['after'] as String?,
    );
  }

  final String? ownerAddress;
  final String? creatorAddress;
  final String? grouping;
  final bool? compressed;
  final bool? compressible;
  final bool? frozen;
  final bool? burnt;
  final String? jsonUri;
  final int? page;
  final int? limit;
  final AssetSortBy? sortBy;
  final AssetSortDirection? sortDirection;
  final String? before;
  final String? after;

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

  factory HeliusAsset.fromJson(Map<String, Object?> json) {
    return HeliusAsset(
      id: json['id']! as String,
      interface_: json['interface'] as String?,
      content: json['content'] != null
          ? AssetContent.fromJson(json['content']! as Map<String, Object?>)
          : null,
      authorities: json['authorities'] != null
          ? (json['authorities']! as List<Object?>)
                .cast<Map<String, Object?>>()
                .map(AssetAuthority.fromJson)
                .toList()
          : null,
      compression: json['compression'] != null
          ? AssetCompression.fromJson(
              json['compression']! as Map<String, Object?>,
            )
          : null,
      grouping: json['grouping'] != null
          ? (json['grouping']! as List<Object?>)
                .cast<Map<String, Object?>>()
                .map(AssetGrouping.fromJson)
                .toList()
          : null,
      royalty: json['royalty'] != null
          ? AssetRoyalty.fromJson(json['royalty']! as Map<String, Object?>)
          : null,
      creators: json['creators'] != null
          ? (json['creators']! as List<Object?>)
                .cast<Map<String, Object?>>()
                .map(AssetCreator.fromJson)
                .toList()
          : null,
      ownership: json['ownership'] != null
          ? AssetOwnership.fromJson(json['ownership']! as Map<String, Object?>)
          : null,
      supply: json['supply'] != null
          ? AssetSupply.fromJson(json['supply']! as Map<String, Object?>)
          : null,
      mutable: json['mutable'] as bool?,
      burnt: json['burnt'] as bool?,
      tokenInfo: json['token_info'] != null
          ? AssetTokenInfo.fromJson(json['token_info']! as Map<String, Object?>)
          : null,
      mintExtensions: json['mint_extensions'] as Map<String, Object?>?,
    );
  }

  final String id;
  final String? interface_;
  final AssetContent? content;
  final List<AssetAuthority>? authorities;
  final AssetCompression? compression;
  final List<AssetGrouping>? grouping;
  final AssetRoyalty? royalty;
  final List<AssetCreator>? creators;
  final AssetOwnership? ownership;
  final AssetSupply? supply;
  final bool? mutable;
  final bool? burnt;
  final AssetTokenInfo? tokenInfo;
  final Map<String, Object?>? mintExtensions;

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
  const AssetContent({this.jsonUri, this.files, this.metadata, this.links});

  factory AssetContent.fromJson(Map<String, Object?> json) {
    return AssetContent(
      jsonUri: json['json_uri'] as String?,
      files: json['files'] != null
          ? (json['files']! as List<Object?>)
                .cast<Map<String, Object?>>()
                .map(AssetFile.fromJson)
                .toList()
          : null,
      metadata: json['metadata'] != null
          ? AssetMetadata.fromJson(json['metadata']! as Map<String, Object?>)
          : null,
      links: json['links'] as Map<String, Object?>?,
    );
  }

  final String? jsonUri;
  final List<AssetFile>? files;
  final AssetMetadata? metadata;
  final Map<String, Object?>? links;

  Map<String, Object?> toJson() => {
    if (jsonUri != null) 'json_uri': jsonUri,
    if (files != null) 'files': files!.map((f) => f.toJson()).toList(),
    if (metadata != null) 'metadata': metadata!.toJson(),
    if (links != null) 'links': links,
  };
}

/// A file associated with an asset.
class AssetFile {
  const AssetFile({this.uri, this.cdnUri, this.mime});

  factory AssetFile.fromJson(Map<String, Object?> json) {
    return AssetFile(
      uri: json['uri'] as String?,
      cdnUri: json['cdn_uri'] as String?,
      mime: json['mime'] as String?,
    );
  }

  final String? uri;
  final String? cdnUri;
  final String? mime;

  Map<String, Object?> toJson() => {
    if (uri != null) 'uri': uri,
    if (cdnUri != null) 'cdn_uri': cdnUri,
    if (mime != null) 'mime': mime,
  };
}

/// On-chain and off-chain metadata for an asset.
class AssetMetadata {
  const AssetMetadata({
    this.name,
    this.symbol,
    this.description,
    this.attributes,
  });

  factory AssetMetadata.fromJson(Map<String, Object?> json) {
    return AssetMetadata(
      name: json['name'] as String?,
      symbol: json['symbol'] as String?,
      description: json['description'] as String?,
      attributes: json['attributes'] != null
          ? (json['attributes']! as List<Object?>)
                .cast<Map<String, Object?>>()
                .map(AssetAttribute.fromJson)
                .toList()
          : null,
    );
  }

  final String? name;
  final String? symbol;
  final String? description;
  final List<AssetAttribute>? attributes;

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
  const AssetAttribute({this.traitType, this.value});

  factory AssetAttribute.fromJson(Map<String, Object?> json) {
    return AssetAttribute(
      traitType: json['trait_type'] as String?,
      value: json['value'],
    );
  }

  final String? traitType;
  final Object? value;

  Map<String, Object?> toJson() => {
    if (traitType != null) 'trait_type': traitType,
    if (value != null) 'value': value,
  };
}

/// An authority record for an asset.
class AssetAuthority {
  const AssetAuthority({required this.address, this.scopes});

  factory AssetAuthority.fromJson(Map<String, Object?> json) {
    return AssetAuthority(
      address: json['address']! as String,
      scopes: json['scopes'] != null
          ? (json['scopes']! as List<Object?>).cast<String>()
          : null,
    );
  }

  final String address;
  final List<String>? scopes;

  Map<String, Object?> toJson() => {
    'address': address,
    if (scopes != null) 'scopes': scopes,
  };
}

/// Compression information for an asset (compressed NFTs / cNFTs).
class AssetCompression {
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

  factory AssetCompression.fromJson(Map<String, Object?> json) {
    return AssetCompression(
      eligible: json['eligible'] as bool?,
      compressed: json['compressed'] as bool?,
      dataHash: json['data_hash'] as String?,
      creatorHash: json['creator_hash'] as String?,
      assetHash: json['asset_hash'] as String?,
      tree: json['tree'] as String?,
      seq: json['seq'] as int?,
      leafId: json['leaf_id'] as int?,
    );
  }

  final bool? eligible;
  final bool? compressed;
  final String? dataHash;
  final String? creatorHash;
  final String? assetHash;
  final String? tree;
  final int? seq;
  final int? leafId;

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
  const AssetGrouping({required this.groupKey, required this.groupValue});

  factory AssetGrouping.fromJson(Map<String, Object?> json) {
    return AssetGrouping(
      groupKey: json['group_key']! as String,
      groupValue: json['group_value']! as String,
    );
  }

  final String groupKey;
  final String groupValue;

  Map<String, Object?> toJson() => {
    'group_key': groupKey,
    'group_value': groupValue,
  };
}

/// Royalty configuration for an asset.
class AssetRoyalty {
  const AssetRoyalty({
    this.royaltyModel,
    this.target,
    this.percent,
    this.basisPoints,
    this.primarySaleHappened,
    this.locked,
  });

  factory AssetRoyalty.fromJson(Map<String, Object?> json) {
    return AssetRoyalty(
      royaltyModel: json['royalty_model'] as String?,
      target: json['target'] as String?,
      percent: (json['percent'] as num?)?.toDouble(),
      basisPoints: json['basis_points'] as int?,
      primarySaleHappened: json['primary_sale_happened'] as bool?,
      locked: json['locked'] as bool?,
    );
  }

  final String? royaltyModel;
  final String? target;
  final double? percent;
  final int? basisPoints;
  final bool? primarySaleHappened;
  final bool? locked;

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
  const AssetCreator({
    required this.address,
    required this.share,
    required this.verified,
  });

  factory AssetCreator.fromJson(Map<String, Object?> json) {
    return AssetCreator(
      address: json['address']! as String,
      share: json['share']! as int,
      verified: json['verified']! as bool,
    );
  }

  final String address;
  final int share;
  final bool verified;

  Map<String, Object?> toJson() => {
    'address': address,
    'share': share,
    'verified': verified,
  };
}

/// Ownership information for an asset.
class AssetOwnership {
  const AssetOwnership({
    this.frozen,
    this.delegated,
    this.delegate,
    this.ownershipModel,
    this.owner,
  });

  factory AssetOwnership.fromJson(Map<String, Object?> json) {
    return AssetOwnership(
      frozen: json['frozen'] as bool?,
      delegated: json['delegated'] as bool?,
      delegate: json['delegate'] as String?,
      ownershipModel: json['ownership_model'] as String?,
      owner: json['owner'] as String?,
    );
  }

  final bool? frozen;
  final bool? delegated;
  final String? delegate;
  final String? ownershipModel;
  final String? owner;

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
  const AssetSupply({
    this.printMaxSupply,
    this.printCurrentSupply,
    this.editionNonce,
  });

  factory AssetSupply.fromJson(Map<String, Object?> json) {
    return AssetSupply(
      printMaxSupply: json['print_max_supply'] as int?,
      printCurrentSupply: json['print_current_supply'] as int?,
      editionNonce: json['edition_nonce'] as int?,
    );
  }

  final int? printMaxSupply;
  final int? printCurrentSupply;
  final int? editionNonce;

  Map<String, Object?> toJson() => {
    if (printMaxSupply != null) 'print_max_supply': printMaxSupply,
    if (printCurrentSupply != null) 'print_current_supply': printCurrentSupply,
    if (editionNonce != null) 'edition_nonce': editionNonce,
  };
}

/// Token-specific information for an asset.
class AssetTokenInfo {
  const AssetTokenInfo({
    this.supply,
    this.decimals,
    this.tokenProgram,
    this.associatedTokenAddress,
    this.mintAuthority,
    this.freezeAuthority,
    this.priceInfo,
  });

  factory AssetTokenInfo.fromJson(Map<String, Object?> json) {
    return AssetTokenInfo(
      supply: json['supply'] as int?,
      decimals: json['decimals'] as int?,
      tokenProgram: json['token_program'] as String?,
      associatedTokenAddress: json['associated_token_address'] as String?,
      mintAuthority: json['mint_authority'] as String?,
      freezeAuthority: json['freeze_authority'] as String?,
      priceInfo: json['price_info'] != null
          ? AssetPriceInfo.fromJson(json['price_info']! as Map<String, Object?>)
          : null,
    );
  }

  final int? supply;
  final int? decimals;
  final String? tokenProgram;
  final String? associatedTokenAddress;
  final String? mintAuthority;
  final String? freezeAuthority;
  final AssetPriceInfo? priceInfo;

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
  const AssetPriceInfo({this.pricePerToken, this.totalPrice, this.currency});

  factory AssetPriceInfo.fromJson(Map<String, Object?> json) {
    return AssetPriceInfo(
      pricePerToken: (json['price_per_token'] as num?)?.toDouble(),
      totalPrice: (json['total_price'] as num?)?.toDouble(),
      currency: json['currency'] as String?,
    );
  }

  final double? pricePerToken;
  final double? totalPrice;
  final String? currency;

  Map<String, Object?> toJson() => {
    if (pricePerToken != null) 'price_per_token': pricePerToken,
    if (totalPrice != null) 'total_price': totalPrice,
    if (currency != null) 'currency': currency,
  };
}

/// Merkle proof for a compressed asset.
class AssetProof {
  const AssetProof({
    required this.root,
    required this.proof,
    required this.nodeIndex,
    required this.leaf,
    required this.treeId,
  });

  factory AssetProof.fromJson(Map<String, Object?> json) {
    return AssetProof(
      root: json['root']! as String,
      proof: (json['proof']! as List<Object?>).cast<String>(),
      nodeIndex: json['node_index']! as int,
      leaf: json['leaf']! as String,
      treeId: json['tree_id']! as String,
    );
  }

  final String root;
  final List<String> proof;
  final int nodeIndex;
  final String leaf;
  final String treeId;

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
  const NftEdition({required this.mint, required this.edition});

  factory NftEdition.fromJson(Map<String, Object?> json) {
    return NftEdition(
      mint: json['mint']! as String,
      edition: json['edition']! as int,
    );
  }

  final String mint;
  final int edition;

  Map<String, Object?> toJson() => {'mint': mint, 'edition': edition};
}

/// A transaction signature associated with an asset.
class AssetSignature {
  const AssetSignature({
    required this.signature,
    this.type_,
    this.slot,
    this.timestamp,
  });

  factory AssetSignature.fromJson(Map<String, Object?> json) {
    return AssetSignature(
      signature: json['signature']! as String,
      type_: json['type'] as String?,
      slot: json['slot'] as int?,
      timestamp: json['timestamp'] as int?,
    );
  }

  final String signature;
  final String? type_;
  final int? slot;
  final int? timestamp;

  Map<String, Object?> toJson() => {
    'signature': signature,
    if (type_ != null) 'type': type_,
    if (slot != null) 'slot': slot,
    if (timestamp != null) 'timestamp': timestamp,
  };
}

/// A paginated list of asset signatures.
class AssetSignatureList {
  const AssetSignatureList({
    required this.total,
    required this.limit,
    required this.items,
    this.page,
  });

  factory AssetSignatureList.fromJson(Map<String, Object?> json) {
    return AssetSignatureList(
      total: json['total']! as int,
      limit: json['limit']! as int,
      page: json['page'] as int?,
      items: (json['items']! as List<Object?>)
          .cast<Map<String, Object?>>()
          .map(AssetSignature.fromJson)
          .toList(),
    );
  }

  final int total;
  final int limit;
  final int? page;
  final List<AssetSignature> items;

  Map<String, Object?> toJson() => {
    'total': total,
    'limit': limit,
    if (page != null) 'page': page,
    'items': items.map((i) => i.toJson()).toList(),
  };
}

/// A paginated list of digital assets.
class AssetList {
  const AssetList({
    required this.total,
    required this.limit,
    required this.items,
    this.page,
  });

  factory AssetList.fromJson(Map<String, Object?> json) {
    return AssetList(
      total: json['total']! as int,
      limit: json['limit']! as int,
      page: json['page'] as int?,
      items: (json['items']! as List<Object?>)
          .cast<Map<String, Object?>>()
          .map(HeliusAsset.fromJson)
          .toList(),
    );
  }

  final int total;
  final int limit;
  final int? page;
  final List<HeliusAsset> items;

  Map<String, Object?> toJson() => {
    'total': total,
    'limit': limit,
    if (page != null) 'page': page,
    'items': items.map((i) => i.toJson()).toList(),
  };
}

/// A paginated list of token accounts.
class TokenAccountList {
  const TokenAccountList({
    required this.total,
    required this.limit,
    required this.tokenAccounts,
    this.page,
  });

  factory TokenAccountList.fromJson(Map<String, Object?> json) {
    return TokenAccountList(
      total: json['total']! as int,
      limit: json['limit']! as int,
      page: json['page'] as int?,
      tokenAccounts: (json['token_accounts']! as List<Object?>)
          .cast<Map<String, Object?>>()
          .map(TokenAccount.fromJson)
          .toList(),
    );
  }

  final int total;
  final int limit;
  final int? page;
  final List<TokenAccount> tokenAccounts;

  Map<String, Object?> toJson() => {
    'total': total,
    'limit': limit,
    if (page != null) 'page': page,
    'token_accounts': tokenAccounts.map((t) => t.toJson()).toList(),
  };
}

/// A single token account.
class TokenAccount {
  const TokenAccount({
    required this.address,
    required this.mint,
    required this.owner,
    required this.amount,
    this.delegatedAmount,
    this.frozen,
  });

  factory TokenAccount.fromJson(Map<String, Object?> json) {
    return TokenAccount(
      address: json['address']! as String,
      mint: json['mint']! as String,
      owner: json['owner']! as String,
      amount: json['amount']! as int,
      delegatedAmount: json['delegated_amount'] as int?,
      frozen: json['frozen'] as bool?,
    );
  }

  final String address;
  final String mint;
  final String owner;
  final int amount;
  final int? delegatedAmount;
  final bool? frozen;

  Map<String, Object?> toJson() => {
    'address': address,
    'mint': mint,
    'owner': owner,
    'amount': amount,
    if (delegatedAmount != null) 'delegated_amount': delegatedAmount,
    if (frozen != null) 'frozen': frozen,
  };
}
