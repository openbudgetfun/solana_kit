import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_mpl_bubblegum/solana_kit_mpl_bubblegum.dart';
import 'package:test/test.dart';

const _hash = '11111111111111111111111111111111';
const _owner = '11111111111111111111111111111112';
const _delegate = '11111111111111111111111111111113';

Future<AssetWithProof> _fetch({
  String? delegate,
  bool frozen = false,
  Map<String, Object?>? extraAsset,
  Map<String, Object?>? extraCompression,
}) {
  return http.runWithClient(
    () => getAssetWithProof(
      dasClient: const HeliusDasClient(rpcUrl: 'https://example.com'),
      assetId: _hash,
    ),
    () => MockClient((request) async {
      final body = jsonDecode(request.body) as Map<String, Object?>;
      final result = body['method'] == 'getAsset'
          ? <String, Object?>{
              'id': _hash,
              'ownership': {
                'owner': _owner,
                'delegate': delegate,
                'frozen': frozen,
              },
              'compression': <String, Object?>{
                'compressed': true,
                'data_hash': _hash,
                'creator_hash': _hash,
                'asset_hash': _hash,
                'tree': _hash,
                'leaf_id': 5,
                ...?extraCompression,
              },
              ...?extraAsset,
            }
          : <String, Object?>{
              'root': _hash,
              'proof': [_hash, _hash, _hash],
              'node_index': 13,
              'leaf': _hash,
              'tree_id': _hash,
            };
      return http.Response(jsonEncode({'result': result}), 200);
    }),
  );
}

void main() {
  group('DAS fields used in compressed NFT instructions', () {
    test('retains the owner even while frozen', () async {
      expect((await _fetch(frozen: true)).leafOwner, _owner);
    });

    test('retains the actual delegate', () async {
      expect((await _fetch(delegate: _delegate)).leafDelegate, _delegate);
    });

    test('defaults an absent delegate to the owner', () async {
      expect((await _fetch()).leafDelegate, _owner);
    });

    test('uses the compression leaf ID as the nonce', () async {
      expect((await _fetch()).nonce, BigInt.from(5));
    });

    test('converts the DAS node index to a leaf index', () async {
      final asset = await _fetch();
      expect(asset.index, 5);
      expect(asset.root, hasLength(32));
      expect(asset.proof, hasLength(3));
      expect(asset.dataHash, hasLength(32));
      expect(asset.creatorHash, hasLength(32));
    });
  });

  group('DAS royalty and inherited leaf metadata', () {
    test('parses the royalty block and the raw leaf companions', () async {
      final asset = await _fetch(
        extraAsset: {
          'creators': [
            {'address': _owner, 'share': 100, 'verified': true},
          ],
          'creators_raw': [
            {'address': _delegate, 'share': 50, 'verified': false},
          ],
          'royalty': {
            'basis_points': 500,
            'basis_points_raw': 750,
            'primary_sale_happened': true,
            'sfbp_inherited': true,
          },
          'supports': false,
        },
      );

      expect(asset.rpcAsset.royalty?.basisPoints, 500);
      expect(asset.rpcAsset.royalty?.basisPointsRaw, 750);
      expect(asset.rpcAsset.royalty?.primarySaleHappened, isTrue);
      expect(asset.rpcAsset.royalty?.inherited, isTrue);
      expect(asset.inherited, isTrue);
      expect(asset.sellerFeeBasisPointsRaw, 750);
      expect(asset.creatorsRaw, hasLength(1));
      // The display metadata keeps the DAS display rate.
      expect(asset.metadata.sellerFeeBasisPoints, 500);
      // The leaf metadata takes the raw rate.
      expect(asset.currentMetadata.sellerFeeBasisPoints, 750);
    });

    test(
      'treats the inherit sentinel as inherited when DAS omits the flags',
      () async {
        final asset = await _fetch(
          extraAsset: {
            'creators': [
              {'address': _owner, 'share': 100, 'verified': true},
            ],
            'royalty': {'basis_points': 0xffff},
          },
        );

        expect(asset.inherited, isTrue);
        expect(asset.sellerFeeBasisPointsRaw, sellerFeeBasisPointsInherit);
        // DAS omitted creators_raw, so the leaf creator list is empty.
        expect(asset.creatorsRaw, isEmpty);
        expect(asset.currentMetadata.creators, isEmpty);
      },
    );

    test('leaves the raw fields null for an ordinary asset', () async {
      final asset = await _fetch(
        extraAsset: {
          'royalty': {'basis_points': 500},
        },
      );

      expect(asset.inherited, isFalse);
      expect(asset.sellerFeeBasisPointsRaw, isNull);
      expect(asset.creatorsRaw, isNull);
      expect(asset.currentMetadata.sellerFeeBasisPoints, 500);
    });

    test('parses content, collection, mutable, and edition nonce', () async {
      final asset = await _fetch(
        extraAsset: {
          'content': {
            'json_uri': 'https://example.com/nft.json',
            'metadata': {'name': 'NFT', 'symbol': 'N'},
          },
          'grouping': [
            {
              'group_key': 'collection',
              'group_value': _owner,
              'verified': true,
            },
          ],
          'mutable': false,
          'supply': {'edition_nonce': 7},
        },
      );

      expect(asset.rpcAsset.content?.jsonUri, 'https://example.com/nft.json');
      expect(asset.rpcAsset.collection?.key.toString(), _owner);
      expect(asset.rpcAsset.collection?.verified, isTrue);
      expect(asset.rpcAsset.mutable, isFalse);
      expect(asset.rpcAsset.editionNonce, 7);
      expect(asset.metadata.name, 'NFT');
      expect(asset.metadata.symbol, 'N');
      expect(asset.metadata.uri, 'https://example.com/nft.json');
      expect(asset.metadata.isMutable, isFalse);
      expect(asset.metadata.editionNonce, 7);
      expect(asset.metadata.collection?.key.toString(), _owner);
    });

    test('parses the V2 compression companions and validates flags', () async {
      final asset = await _fetch(
        extraCompression: {
          'collection_hash': _hash,
          'asset_data_hash': _hash,
          'flags': 3,
        },
      );

      expect(asset.collectionHash, isNotNull);
      expect(asset.assetDataHash, isNotNull);
      expect(asset.flags, 3);
    });

    test(
      'drops out-of-range leaf flags instead of passing them through',
      () async {
        final asset = await _fetch(extraCompression: {'flags': 9});

        // 9 sets a bit outside the known 0b111 range, so it is not usable.
        expect(asset.flags, isNull);
      },
    );

    test('ignores a collection grouping with an empty value', () async {
      final asset = await _fetch(
        extraAsset: {
          'grouping': [
            {'group_key': 'collection', 'group_value': ''},
          ],
        },
      );

      expect(asset.rpcAsset.collection, isNull);
    });
  });
}
