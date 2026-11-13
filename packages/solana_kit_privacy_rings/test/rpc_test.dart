import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';
import 'package:solana_kit_privacy_rings/solana_kit_privacy_rings.dart';
import 'package:test/test.dart';

String _b58(List<int> bytes) =>
    getBase58Decoder().decode(Uint8List.fromList(bytes));

void main() {
  final hash = _b58(List<int>.filled(32, 1));
  final signature = _b58(List<int>.filled(64, 2));

  test('a Helius RPC root becomes the /v1/spr indexer and prover', () {
    final endpoints = resolvePrivacyRingsEndpoints(
      solanaRpcUrl: Uri.parse(
        'https://devnet.helius-rpc.com/?api-key=secret-key',
      ),
    );
    expect(endpoints.indexer.path, '/v1/spr');
    expect(endpoints.indexer.queryParameters['api-key'], 'secret-key');
    expect(endpoints.prover.path, '/v1/spr');
    expect(
      redactSecrets(endpoints.indexer.toString()),
      isNot(contains('secret-key')),
    );
  });

  test(
    'indexer requests use the method as the path and the JSON-RPC method',
    () async {
      late Uri url;
      late Map<String, Object?> body;
      final httpClient = MockClient((request) async {
        expect(request.headers['x-api-key'], 'secret-key');
        url = request.url;
        body = jsonDecode(request.body) as Map<String, Object?>;
        return http.Response(
          jsonEncode({
            'jsonrpc': '2.0',
            'id': body['id'],
            'result': {
              'context': {'blockTime': 10, 'slot': 20},
              'records': [null],
            },
          }),
          200,
        );
      });
      final indexer = PrivacyIndexerClient(
        endpoint: Uri.parse('https://devnet.helius-rpc.com/v1/spr'),
        apiKey: 'secret-key',
        httpClient: httpClient,
      );
      final page = await indexer.getUserRecords([systemProgramAddress]);
      expect(url.path, '/v1/spr/getUserRecords');
      expect(url.queryParameters.containsKey('api-key'), isFalse);
      expect(body['method'], 'getUserRecords');
      expect(body['jsonrpc'], '2.0');
      expect(page.records, [null]);
      expect(page.context.slot, BigInt.from(20));
    },
  );

  test('an indexer error redacts an echoed API key', () async {
    final httpClient = MockClient((request) async {
      return http.Response(
        jsonEncode({
          'jsonrpc': '2.0',
          'id': 1,
          'error': {
            'code': -32600,
            'message': 'bad key at ${request.url}',
          },
        }),
        200,
      );
    });
    final indexer = PrivacyIndexerClient(
      endpoint: Uri.parse('http://127.0.0.1:8784/?api-key=secret-key'),
      httpClient: httpClient,
    );
    expect(
      indexer.getMerkleProofs(
        treeAccount: stateMerkleTree,
        leaves: [hash],
      ),
      throwsA(
        isA<PrivacyRingsException>()
            .having((error) => error.code, 'code', 'indexer_error')
            .having(
              (error) => error.toString(),
              'text',
              isNot(contains('secret-key')),
            ),
      ),
    );
  });

  test('shielded transaction pages decode and a short page stops', () async {
    final payload = base64.encode([0, 1, 0, 0, 0, 3]);
    final httpClient = MockClient((request) async {
      final body = jsonDecode(request.body) as Map<String, Object?>;
      return http.Response(
        jsonEncode({
          'jsonrpc': '2.0',
          'id': body['id'],
          'result': {
            'context': {'blockTime': '1', 'slot': 2},
            'paginationToken': null,
            'data': [
              {
                'slot': 2,
                'signature': signature,
                'events': [
                  {
                    'slot': 2,
                    'txSignature': signature,
                    'outputSlots': [
                      {
                        'viewTag': hash,
                        'outputContext': {
                          'treeId': 1,
                          'hash': hash,
                          'tree': stateMerkleTree.toString(),
                          'leafIndex': 7,
                        },
                        'payload': payload,
                      },
                    ],
                    'messages': <Object?>[],
                    'nullifiers': [hash],
                    'proofless': false,
                  },
                ],
              },
            ],
          },
        }),
        200,
      );
    });
    final rings = PrivacyRings(
      indexerUrl: Uri.parse('http://127.0.0.1:8784'),
      proverUrl: Uri.parse('http://127.0.0.1:3001'),
      httpClient: httpClient,
    );
    final page = await rings.indexer.getShieldedTransactionsByTags(
      tags: [hash],
    );
    expect(page.paginationToken, isNull);
    expect(page.data.single.entries.single.nullifiers, [hash]);
    expect(page.data.single.entries.single.outputSlots.single.payload, [
      0,
      1,
      0,
      0,
      0,
      3,
    ]);
  });

  test(
    'history that never ends is not returned as a partial balance',
    () async {
      final httpClient = MockClient((request) async {
        final body = jsonDecode(request.body) as Map<String, Object?>;
        final method = body['method'];
        final child = method == 'getEncryptedUtxosByTags'
            ? 'outputs'
            : 'events';
        return http.Response(
          jsonEncode({
            'jsonrpc': '2.0',
            'id': body['id'],
            'result': {
              'context': {'blockTime': 1, 'slot': 2},
              'paginationToken': 'next',
              'data': <Object?>[],
            },
          }),
          200,
          headers: {'x-child': child},
        );
      });
      final rings = PrivacyRings(
        indexerUrl: Uri.parse('http://127.0.0.1:8784'),
        proverUrl: Uri.parse('http://127.0.0.1:3001'),
        httpClient: httpClient,
      );
      expect(
        rings.readPrivateBalance(
          expectedOwner: Uint8List(32),
          verifyConfidentialNote: (note, context) => false,
          viewingKey: ViewingKey.fromBytes(Uint8List(32)..[0] = 1),
          tags: [hash],
          maxPages: 1,
        ),
        throwsA(
          isA<PrivacyRingsException>().having(
            (error) => error.code,
            'code',
            'history_truncated',
          ),
        ),
      );
    },
  );

  test('live devnet indexer is skipped unless HELIUS_API_KEY is set', () async {
    final live = Platform.environment['HELIUS_PRIVACY_RINGS_LIVE'];
    final apiKey = Platform.environment['HELIUS_API_KEY'];
    if (live != '1' || apiKey == null || apiKey.isEmpty) {
      markTestSkipped(
        'set HELIUS_PRIVACY_RINGS_LIVE=1 and HELIUS_API_KEY to call devnet',
      );
      return;
    }
    final rings = PrivacyRings(
      solanaRpcUrl: Uri.parse('https://devnet.helius-rpc.com/?api-key=$apiKey'),
    );
    addTearDown(rings.close);
    final records = await rings.indexer.getUserRecords([systemProgramAddress]);
    expect(records.records, hasLength(1));
  });
}
