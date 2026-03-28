import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

import 'test_helpers.dart';

void main() {
  group('das request types', () {
    expectJsonRoundTrip(
      'GetAssetRequest roundtrips',
      {'id': 'asset-1', 'displayOptions': true},
      GetAssetRequest.fromJson,
      (value) => value.toJson(),
    );
    expectJsonRoundTrip(
      'GetAssetBatchRequest roundtrips',
      {
        'ids': ['asset-1', 'asset-2'],
        'displayOptions': true,
      },
      GetAssetBatchRequest.fromJson,
      (value) => value.toJson(),
    );
    expectJsonRoundTrip(
      'GetAssetProofRequest roundtrips',
      {'id': 'asset-1'},
      GetAssetProofRequest.fromJson,
      (value) => value.toJson(),
    );
    expectJsonRoundTrip(
      'GetAssetProofBatchRequest roundtrips',
      {
        'ids': ['asset-1', 'asset-2'],
      },
      GetAssetProofBatchRequest.fromJson,
      (value) => value.toJson(),
    );

    final sortableJson = {
      'page': 1,
      'limit': 10,
      'sortBy': 'created',
      'sortDirection': 'asc',
      'before': 'cursor-before',
      'after': 'cursor-after',
    };

    expectJsonRoundTrip(
      'GetAssetsByAuthorityRequest roundtrips',
      {
        'authorityAddress': 'authority-1',
        ...sortableJson,
      },
      GetAssetsByAuthorityRequest.fromJson,
      (value) => value.toJson(),
    );
    expectJsonRoundTrip(
      'GetAssetsByCreatorRequest roundtrips',
      {
        'creatorAddress': 'creator-1',
        'onlyVerified': true,
        ...sortableJson,
      },
      GetAssetsByCreatorRequest.fromJson,
      (value) => value.toJson(),
    );
    expectJsonRoundTrip(
      'GetAssetsByGroupRequest roundtrips',
      {
        'groupKey': 'collection',
        'groupValue': 'value-1',
        ...sortableJson,
      },
      GetAssetsByGroupRequest.fromJson,
      (value) => value.toJson(),
    );
    expectJsonRoundTrip(
      'GetAssetsByOwnerRequest roundtrips',
      {
        'ownerAddress': 'owner-1',
        ...sortableJson,
      },
      GetAssetsByOwnerRequest.fromJson,
      (value) => value.toJson(),
    );
    expectJsonRoundTrip(
      'GetNftEditionsRequest roundtrips',
      {'mint': 'mint-1', 'page': 1, 'limit': 10},
      GetNftEditionsRequest.fromJson,
      (value) => value.toJson(),
    );
    expectJsonRoundTrip(
      'GetSignaturesForAssetRequest roundtrips',
      {
        'id': 'asset-1',
        'page': 1,
        'limit': 10,
        'before': 'cursor-before',
        'after': 'cursor-after',
      },
      GetSignaturesForAssetRequest.fromJson,
      (value) => value.toJson(),
    );
    expectJsonRoundTrip(
      'GetTokenAccountsRequest roundtrips',
      {'owner': 'owner-1', 'mint': 'mint-1', 'page': 1, 'limit': 10},
      GetTokenAccountsRequest.fromJson,
      (value) => value.toJson(),
    );
    expectJsonRoundTrip(
      'SearchAssetsRequest roundtrips',
      {
        'ownerAddress': 'owner-1',
        'creatorAddress': 'creator-1',
        'grouping': 'group-1',
        'compressed': true,
        'compressible': true,
        'frozen': false,
        'burnt': false,
        'jsonUri': 'https://example.com/metadata.json',
        ...sortableJson,
      },
      SearchAssetsRequest.fromJson,
      (value) => value.toJson(),
    );
  });

  group('das model types', () {
    expectJsonRoundTrip(
      'AssetFile roundtrips',
      {
        'uri': 'https://example.com/file.png',
        'cdn_uri': 'https://cdn.example.com/file.png',
        'mime': 'image/png',
      },
      AssetFile.fromJson,
      (value) => value.toJson(),
    );
    expectJsonRoundTrip(
      'AssetAttribute roundtrips dynamic value',
      {
        'trait_type': 'rarity',
        'value': 'legendary',
      },
      AssetAttribute.fromJson,
      (value) => value.toJson(),
    );
    expectJsonRoundTrip(
      'AssetMetadata roundtrips',
      {
        'name': 'Test NFT',
        'symbol': 'TNFT',
        'description': 'desc',
        'attributes': [
          {'trait_type': 'rarity', 'value': 'legendary'},
        ],
      },
      AssetMetadata.fromJson,
      (value) => value.toJson(),
    );
    expectJsonRoundTrip(
      'AssetContent roundtrips',
      {
        'json_uri': 'https://example.com/metadata.json',
        'files': [
          {
            'uri': 'https://example.com/file.png',
            'cdn_uri': 'https://cdn.example.com/file.png',
            'mime': 'image/png',
          },
        ],
        'metadata': {
          'name': 'Test NFT',
          'symbol': 'TNFT',
          'description': 'desc',
          'attributes': [
            {'trait_type': 'rarity', 'value': 'legendary'},
          ],
        },
        'links': {'image': 'https://example.com/image.png'},
      },
      AssetContent.fromJson,
      (value) => value.toJson(),
    );
    expectJsonRoundTrip(
      'AssetAuthority roundtrips',
      {
        'address': 'authority-1',
        'scopes': ['full', 'metadata'],
      },
      AssetAuthority.fromJson,
      (value) => value.toJson(),
    );
    expectJsonRoundTrip(
      'AssetCompression roundtrips',
      {
        'eligible': true,
        'compressed': false,
        'data_hash': 'data-hash',
        'creator_hash': 'creator-hash',
        'asset_hash': 'asset-hash',
        'tree': 'tree-1',
        'seq': 1,
        'leaf_id': 2,
      },
      AssetCompression.fromJson,
      (value) => value.toJson(),
    );
    expectJsonRoundTrip(
      'AssetGrouping roundtrips',
      {'group_key': 'collection', 'group_value': 'value-1'},
      AssetGrouping.fromJson,
      (value) => value.toJson(),
    );
    expectJsonRoundTrip(
      'AssetRoyalty roundtrips',
      {
        'royalty_model': 'creators',
        'target': 'wallet-1',
        'percent': 1.5,
        'basis_points': 500,
        'primary_sale_happened': true,
        'locked': false,
      },
      AssetRoyalty.fromJson,
      (value) => value.toJson(),
    );
    expectJsonRoundTrip(
      'AssetCreator roundtrips',
      {'address': 'creator-1', 'share': 50, 'verified': true},
      AssetCreator.fromJson,
      (value) => value.toJson(),
    );
    expectJsonRoundTrip(
      'AssetOwnership roundtrips',
      {
        'frozen': false,
        'delegated': true,
        'delegate': 'delegate-1',
        'ownership_model': 'single',
        'owner': 'owner-1',
      },
      AssetOwnership.fromJson,
      (value) => value.toJson(),
    );
    expectJsonRoundTrip(
      'AssetSupply roundtrips',
      {
        'print_max_supply': 10,
        'print_current_supply': 5,
        'edition_nonce': 2,
      },
      AssetSupply.fromJson,
      (value) => value.toJson(),
    );
    expectJsonRoundTrip(
      'AssetPriceInfo roundtrips',
      {
        'price_per_token': 1.5,
        'total_price': 7.5,
        'currency': 'SOL',
      },
      AssetPriceInfo.fromJson,
      (value) => value.toJson(),
    );
    expectJsonRoundTrip(
      'AssetTokenInfo roundtrips',
      {
        'supply': 100,
        'decimals': 6,
        'token_program': 'token-program',
        'associated_token_address': 'ata-1',
        'mint_authority': 'mint-auth',
        'freeze_authority': 'freeze-auth',
        'price_info': {
          'price_per_token': 1.5,
          'total_price': 7.5,
          'currency': 'SOL',
        },
      },
      AssetTokenInfo.fromJson,
      (value) => value.toJson(),
    );

    final assetJson = {
      'id': 'asset-1',
      'interface': 'V1_NFT',
      'content': {
        'json_uri': 'https://example.com/metadata.json',
        'files': [
          {
            'uri': 'https://example.com/file.png',
            'cdn_uri': 'https://cdn.example.com/file.png',
            'mime': 'image/png',
          },
        ],
        'metadata': {
          'name': 'Test NFT',
          'symbol': 'TNFT',
          'description': 'desc',
          'attributes': [
            {'trait_type': 'rarity', 'value': 'legendary'},
          ],
        },
        'links': {'image': 'https://example.com/image.png'},
      },
      'authorities': [
        {
          'address': 'authority-1',
          'scopes': ['full', 'metadata'],
        },
      ],
      'compression': {
        'eligible': true,
        'compressed': false,
        'data_hash': 'data-hash',
        'creator_hash': 'creator-hash',
        'asset_hash': 'asset-hash',
        'tree': 'tree-1',
        'seq': 1,
        'leaf_id': 2,
      },
      'grouping': [
        {'group_key': 'collection', 'group_value': 'value-1'},
      ],
      'royalty': {
        'royalty_model': 'creators',
        'target': 'wallet-1',
        'percent': 1.5,
        'basis_points': 500,
        'primary_sale_happened': true,
        'locked': false,
      },
      'creators': [
        {'address': 'creator-1', 'share': 50, 'verified': true},
      ],
      'ownership': {
        'frozen': false,
        'delegated': true,
        'delegate': 'delegate-1',
        'ownership_model': 'single',
        'owner': 'owner-1',
      },
      'supply': {
        'print_max_supply': 10,
        'print_current_supply': 5,
        'edition_nonce': 2,
      },
      'mutable': true,
      'burnt': false,
      'token_info': {
        'supply': 100,
        'decimals': 6,
        'token_program': 'token-program',
        'associated_token_address': 'ata-1',
        'mint_authority': 'mint-auth',
        'freeze_authority': 'freeze-auth',
        'price_info': {
          'price_per_token': 1.5,
          'total_price': 7.5,
          'currency': 'SOL',
        },
      },
      'mint_extensions': {'rule': 'value'},
    };

    expectJsonRoundTrip(
      'HeliusAsset roundtrips deep nested payload',
      assetJson,
      HeliusAsset.fromJson,
      (value) => value.toJson(),
    );
    expectJsonRoundTrip(
      'AssetProof roundtrips',
      {
        'root': 'root-1',
        'proof': ['a', 'b'],
        'node_index': 2,
        'leaf': 'leaf-1',
        'tree_id': 'tree-1',
      },
      AssetProof.fromJson,
      (value) => value.toJson(),
    );
    expectJsonRoundTrip(
      'NftEdition roundtrips',
      {'mint': 'mint-1', 'edition': 3},
      NftEdition.fromJson,
      (value) => value.toJson(),
    );
    expectJsonRoundTrip(
      'AssetSignature roundtrips',
      {
        'signature': 'sig-1',
        'type': 'mint',
        'slot': 9,
        'timestamp': 123456,
      },
      AssetSignature.fromJson,
      (value) => value.toJson(),
    );
    expectJsonRoundTrip(
      'AssetSignatureList roundtrips',
      {
        'total': 1,
        'limit': 10,
        'page': 1,
        'items': [
          {
            'signature': 'sig-1',
            'type': 'mint',
            'slot': 9,
            'timestamp': 123456,
          },
        ],
      },
      AssetSignatureList.fromJson,
      (value) => value.toJson(),
    );
    expectJsonRoundTrip(
      'AssetList roundtrips',
      {
        'total': 1,
        'limit': 10,
        'page': 1,
        'items': [assetJson],
      },
      AssetList.fromJson,
      (value) => value.toJson(),
    );
    expectJsonRoundTrip(
      'TokenAccount roundtrips',
      {
        'address': 'token-account-1',
        'mint': 'mint-1',
        'owner': 'owner-1',
        'amount': 42,
        'delegated_amount': 2,
        'frozen': false,
      },
      TokenAccount.fromJson,
      (value) => value.toJson(),
    );
    expectJsonRoundTrip(
      'TokenAccountList roundtrips',
      {
        'total': 1,
        'limit': 10,
        'page': 1,
        'token_accounts': [
          {
            'address': 'token-account-1',
            'mint': 'mint-1',
            'owner': 'owner-1',
            'amount': 42,
            'delegated_amount': 2,
            'frozen': false,
          },
        ],
      },
      TokenAccountList.fromJson,
      (value) => value.toJson(),
    );
  });
}
