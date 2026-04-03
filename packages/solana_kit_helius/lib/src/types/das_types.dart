// ignore_for_file: public_member_api_docs
import 'package:solana_kit_helius/src/internal/json_reader.dart';
import 'package:solana_kit_helius/src/types/enums.dart';

// ---------------------------------------------------------------------------
// Request types
// ---------------------------------------------------------------------------

/// Request parameters for the `getAsset` DAS method.
class GetAssetRequest {
  const GetAssetRequest({required this.id, this.displayOptions});

  factory GetAssetRequest.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return GetAssetRequest(
      id: r.requireString('id'),
      displayOptions: r.optBool('displayOptions'),
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
    final r = JsonReader(json);
    return GetAssetBatchRequest(
      ids: r.requireList<String>('ids'),
      displayOptions: r.optBool('displayOptions'),
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
    final r = JsonReader(json);
    return GetAssetProofRequest(id: r.requireString('id'));
  }

  final String id;

  Map<String, Object?> toJson() => {'id': id};
}

/// Request parameters for the `getAssetProofBatch` DAS method.
class GetAssetProofBatchRequest {
  const GetAssetProofBatchRequest({required this.ids});

  factory GetAssetProofBatchRequest.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return GetAssetProofBatchRequest(ids: r.requireList<String>('ids'));
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
    final r = JsonReader(json);
    return GetNftEditionsRequest(
      mint: r.requireString('mint'),
      page: r.optInt('page'),
      limit: r.optInt('limit'),
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
    final r = JsonReader(json);
    return GetSignaturesForAssetRequest(
      id: r.requireString('id'),
      page: r.optInt('page'),
      limit: r.optInt('limit'),
      before: r.optString('before'),
      after: r.optString('after'),
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
    final r = JsonReader(json);
    return GetTokenAccountsRequest(
      owner: r.optString('owner'),
      mint: r.optString('mint'),
      page: r.optInt('page'),
      limit: r.optInt('limit'),
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
    final r = JsonReader(json);
    return AssetContent(
      jsonUri: r.optString('json_uri'),
      files: r.optDecodedList('files', AssetFile.fromJson),
      metadata: r.optDecoded('metadata', AssetMetadata.fromJson),
      links: r.optMap('links'),
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
    final r = JsonReader(json);
    return AssetFile(
      uri: r.optString('uri'),
      cdnUri: r.optString('cdn_uri'),
      mime: r.optString('mime'),
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
    final r = JsonReader(json);
    return AssetMetadata(
      name: r.optString('name'),
      symbol: r.optString('symbol'),
      description: r.optString('description'),
      attributes: r.optDecodedList('attributes', AssetAttribute.fromJson),
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
    final r = JsonReader(json);
    return AssetAttribute(
      traitType: r.optString('trait_type'),
      value: r.raw('value'),
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
    final r = JsonReader(json);
    return AssetAuthority(
      address: r.requireString('address'),
      scopes: r.optList<String>('scopes'),
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
    final r = JsonReader(json);
    return AssetGrouping(
      groupKey: r.requireString('group_key'),
      groupValue: r.requireString('group_value'),
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
    final r = JsonReader(json);
    return AssetCreator(
      address: r.requireString('address'),
      share: r.requireInt('share'),
      verified: r.requireBool('verified'),
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
    final r = JsonReader(json);
    return AssetOwnership(
      frozen: r.optBool('frozen'),
      delegated: r.optBool('delegated'),
      delegate: r.optString('delegate'),
      ownershipModel: r.optString('ownership_model'),
      owner: r.optString('owner'),
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
    final r = JsonReader(json);
    return AssetSupply(
      printMaxSupply: r.optInt('print_max_supply'),
      printCurrentSupply: r.optInt('print_current_supply'),
      editionNonce: r.optInt('edition_nonce'),
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
    final r = JsonReader(json);
    return AssetPriceInfo(
      pricePerToken: r.optDouble('price_per_token'),
      totalPrice: r.optDouble('total_price'),
      currency: r.optString('currency'),
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
    final r = JsonReader(json);
    return AssetProof(
      root: r.requireString('root'),
      proof: r.requireList<String>('proof'),
      nodeIndex: r.requireInt('node_index'),
      leaf: r.requireString('leaf'),
      treeId: r.requireString('tree_id'),
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
    final r = JsonReader(json);
    return NftEdition(
      mint: r.requireString('mint'),
      edition: r.requireInt('edition'),
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
    final r = JsonReader(json);
    return AssetSignature(
      signature: r.requireString('signature'),
      type_: r.optString('type'),
      slot: r.optInt('slot'),
      timestamp: r.optInt('timestamp'),
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
    final r = JsonReader(json);
    return AssetSignatureList(
      total: r.requireInt('total'),
      limit: r.requireInt('limit'),
      page: r.optInt('page'),
      items: r.requireDecodedList('items', AssetSignature.fromJson),
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
    final r = JsonReader(json);
    return AssetList(
      total: r.requireInt('total'),
      limit: r.requireInt('limit'),
      page: r.optInt('page'),
      items: r.requireDecodedList('items', HeliusAsset.fromJson),
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
    final r = JsonReader(json);
    return TokenAccountList(
      total: r.requireInt('total'),
      limit: r.requireInt('limit'),
      page: r.optInt('page'),
      tokenAccounts: r.requireDecodedList('token_accounts', TokenAccount.fromJson),
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
