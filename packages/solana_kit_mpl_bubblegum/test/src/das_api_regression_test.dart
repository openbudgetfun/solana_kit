import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_mpl_bubblegum/solana_kit_mpl_bubblegum.dart';
import 'package:test/test.dart';

const _hash = '11111111111111111111111111111111';
const _owner = '11111111111111111111111111111112';
const _delegate = '11111111111111111111111111111113';

Future<AssetWithProof> _fetch({String? delegate, bool frozen = false}) {
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
              'compression': {
                'compressed': true,
                'data_hash': _hash,
                'creator_hash': _hash,
                'asset_hash': _hash,
                'tree': _hash,
                'leaf_id': 5,
              },
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
}
