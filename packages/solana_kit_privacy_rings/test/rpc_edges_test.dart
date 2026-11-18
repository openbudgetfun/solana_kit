import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';
import 'package:solana_kit_privacy_rings/solana_kit_privacy_rings.dart';
import 'package:test/test.dart';

Matcher _code(String code) => throwsA(
  isA<PrivacyRingsException>().having((error) => error.code, 'code', code),
);

String _b58(int length, int marker) =>
    getBase58Decoder().decode(Uint8List(length)..[0] = marker);

void main() {
  final hash = _b58(32, 1);
  final signature = _b58(64, 2);
  final tree = stateMerkleTree.toString();

  Map<String, Object?> outputSlot() => {
    'viewTag': hash,
    'outputContext': {
      'treeId': 1,
      'hash': hash,
      'tree': tree,
      'leafIndex': '9007199254740992',
    },
    'payload': base64.encode([1, 2, 3]),
  };

  Map<String, Object?> shielded({bool withOptionals = true}) => {
    'slot': 4,
    'txSignature': signature,
    'eventIndex': 2,
    'txViewingPk': withOptionals ? base64.encode(Uint8List(33)) : null,
    'salt': withOptionals ? base64.encode(Uint8List(16)) : null,
    'outputSlots': [outputSlot()],
    'messages': [
      {
        'viewTag': hash,
        'payload': base64.encode([9]),
      },
    ],
    'nullifiers': [hash],
    'proofless': false,
    'ringConfig': tree,
    'ringProgramId': tree,
  };

  Map<String, Object?> page(String child, Object? entry) => {
    'context': {'blockTime': 1, 'slot': '2'},
    'paginationToken': 'next',
    'outputTreeId': 3,
    'data': [
      {
        'slot': 4,
        'signature': signature,
        child: [entry],
      },
    ],
  };

  PrivacyIndexerClient client(
    Object? Function(Map<String, Object?> body) respond, {
    int status = 200,
    String? raw,
    Error? failure,
  }) {
    return PrivacyIndexerClient(
      endpoint: Uri.parse('http://127.0.0.1:8784/spr/?kept=1'),
      apiKey: 'secret-key',
      httpClient: MockClient((request) async {
        if (failure != null) throw failure;
        if (raw != null) return http.Response(raw, status);
        final body = jsonDecode(request.body) as Map<String, Object?>;
        return http.Response(
          jsonEncode({
            'jsonrpc': '2.0',
            'id': body['id'],
            'result': respond(body),
          }),
          status,
        );
      }),
    );
  }

  test(
    'paged methods decode proofs, filters, and large slot numbers',
    () async {
      late Map<String, Object?> sent;
      final indexer = client((body) {
        sent = body;
        final method = body['method'];
        if (method == 'getEncryptedUtxosByTags') {
          return page('outputs', {
            'slot': '8',
            'txSignature': signature,
            'outputSlot': outputSlot(),
            'txViewingPk': base64.encode(Uint8List(33)),
            'salt': base64.encode(Uint8List(16)),
          });
        }
        if (method == 'getShieldedTransactionsByNullifiers') {
          return page('events', shielded());
        }
        if (method == 'getMerkleProofs') {
          return {
            'context': {'blockTime': 1, 'slot': 2},
            'proofs': [
              {
                'leaf': hash,
                'merkleContext': {'treeType': 1, 'tree': tree},
                'path': [hash],
                'leafIndex': 7,
                'root': hash,
                'rootSeq': '9',
                'rootIndex': 1,
              },
            ],
          };
        }
        return {
          'context': {'blockTime': 1, 'slot': 2},
          'proofs': [
            {
              'leaf': hash,
              'merkleContext': {'treeType': 2, 'tree': tree},
              'path': [hash],
              'lowElement': hash,
              'lowElementIndex': 1,
              'highElement': hash,
              'highElementIndex': 2,
              'root': hash,
              'rootSeq': 3,
              'rootIndex': 4,
            },
          ],
        };
      });

      final deposits = await indexer.getEncryptedUtxosByTags(
        ringProgramId: stateMerkleTree,
        page: PageRequest(
          paginationToken: 'prev',
          limit: 2,
          filters: HistoryFilters(
            slot: SlotFilter(
              gt: BigInt.one,
              gte: BigInt.two,
              lt: BigInt.from(3),
              lte: BigInt.from(4),
            ),
          ),
          minContextSlot: BigInt.parse('9007199254740992'),
        ),
      );
      expect(deposits.outputTreeId, 3);
      expect(deposits.data.single.entries.single.txViewingPk, hasLength(33));
      final params = sent['params']! as Map<String, Object?>;
      expect(params['paginationToken'], 'prev');
      expect(params['minContextSlot'], '9007199254740992');
      expect(params['ringProgramId'], tree);
      expect((params['filters']! as Map)['slot'], isA<Map<dynamic, dynamic>>());

      final byNullifier = await indexer.getShieldedTransactionsByNullifiers(
        nullifiers: [hash],
      );
      final event = byNullifier.data.single.entries.single;
      expect(event.eventIndex, 2);
      expect(event.ringProgramId, stateMerkleTree);
      expect(event.messages.single.payload, [9]);

      final proofs = await indexer.getMerkleProofs(
        treeAccount: stateMerkleTree,
        leaves: [hash],
      );
      expect(proofs.proofs.single.leafIndex, BigInt.from(7));
      final absent = await indexer.getNonInclusionProofs(
        treeAccount: stateMerkleTree,
        leaves: [hash],
      );
      expect(absent.proofs.single.highElementIndex, BigInt.two);
    },
  );

  test('signature lookup decodes transactions and user records', () async {
    final indexer = client((body) {
      if (body['method'] == 'getUserRecords') {
        return {
          'context': {'blockTime': 1, 'slot': 2},
          'records': [
            null,
            {
              'owner': tree,
              'nullifierPubkey': hash,
              'viewingPubkey': base64.encode(Uint8List(33)..[0] = 4),
              'mergeEncryption': 1,
            },
          ],
        };
      }
      return {
        'context': {'blockTime': 1, 'slot': 2},
        'outputTreeId': 6,
        'transactions': [
          {'eventIndex': 1, 'transaction': shielded(withOptionals: false)},
        ],
      };
    });
    final found = await indexer.getShieldedTransactionsBySignature(signature);
    expect(found.outputTreeId, 6);
    expect(found.transactions.single.transaction.txViewingPk, isNull);
    final records = await indexer.getUserRecords([
      stateMerkleTree,
      userRegistryProgramId,
    ]);
    expect(records.records.first, isNull);
    expect(records.records.last!.mergeEncryption, 1);
    expect(const HistoryFilters().toJson(), isEmpty);
    expect(const SlotFilter().toJson(), isEmpty);
  });

  test('indexer requests reject bad arguments and bad responses', () async {
    final indexer = client((_) => <String, Object?>{});
    expect(indexer.getEncryptedUtxosByTags(), _code('invalid_request'));
    expect(
      indexer.getShieldedTransactionsByNullifiers(nullifiers: const []),
      _code('invalid_request'),
    );
    expect(
      indexer.getShieldedTransactionsByNullifiers(nullifiers: const ['0']),
      _code('invalid_request'),
    );
    expect(
      indexer.getMerkleProofs(
        treeAccount: stateMerkleTree,
        leaves: [_b58(1, 3)],
      ),
      _code('invalid_request'),
    );
    expect(
      indexer.getShieldedTransactionsByNullifiers(
        nullifiers: [hash.substring(0, 4)],
      ),
      _code('invalid_request'),
    );
    expect(
      indexer.getShieldedTransactionsBySignature(hash),
      _code('invalid_request'),
    );
    expect(
      indexer.getShieldedTransactionsBySignature('!!!'),
      _code('invalid_request'),
    );
    expect(
      indexer.getMerkleProofs(treeAccount: stateMerkleTree, leaves: const []),
      _code('invalid_request'),
    );
    expect(indexer.getUserRecords(const []), _code('invalid_request'));
    expect(
      indexer.getUserRecords([
        for (var i = 0; i < 101; i++) systemProgramAddress,
      ]),
      _code('invalid_request'),
    );
    expect(
      indexer.getEncryptedUtxosByTags(
        tags: [hash],
        page: const PageRequest(limit: 0),
      ),
      _code('invalid_limit'),
    );
    expect(
      indexer.getEncryptedUtxosByTags(
        tags: [hash],
        page: PageRequest(minContextSlot: BigInt.from(-1)),
      ),
      _code('integer_range'),
    );
    expect(
      () => PrivacyIndexerClient(
        endpoint: Uri.parse('http://127.0.0.1:8784/?api-key=a'),
        apiKey: 'b',
      ),
      _code('invalid_config'),
    );
    expect(
      () => PrivacyIndexerClient(
        endpoint: Uri.parse('http://127.0.0.1:8784'),
        apiKey: '',
      ),
      _code('invalid_config'),
    );
    PrivacyIndexerClient(
      endpoint: Uri.parse('http://127.0.0.1:8784'),
    ).close();

    expect(
      client(
        (_) => <String, Object?>{},
        failure: StateError('api-key=secret-key'),
      ).getEncryptedUtxosByTags(tags: [hash]),
      _code('indexer_transport'),
    );
    expect(
      client((_) => <String, Object?>{}, status: 503).getEncryptedUtxosByTags(
        tags: [hash],
      ),
      _code('indexer_http'),
    );
    expect(
      client((_) => <String, Object?>{}, raw: 'nope').getEncryptedUtxosByTags(
        tags: [hash],
      ),
      _code('invalid_response'),
    );
    expect(
      client((_) => <String, Object?>{}, raw: '[]').getEncryptedUtxosByTags(
        tags: [hash],
      ),
      _code('invalid_response'),
    );
    expect(
      client(
        (_) => <String, Object?>{},
        raw: jsonEncode({
          'jsonrpc': '2.0',
          'id': 1,
          'result': <String, Object?>{},
          'extra': 1,
        }),
      ).getEncryptedUtxosByTags(tags: [hash]),
      _code('invalid_response'),
    );
    expect(
      client(
        (_) => <String, Object?>{},
        raw: jsonEncode({
          'jsonrpc': '2.0',
          'id': 99,
          'result': <String, Object?>{},
        }),
      ).getEncryptedUtxosByTags(tags: [hash]),
      _code('invalid_response'),
    );
    expect(
      client(
        (_) => <String, Object?>{},
        raw: jsonEncode({
          'jsonrpc': '2.0',
          'id': 1,
          'result': <String, Object?>{},
          'error': {'code': 1, 'message': 'x'},
        }),
      ).getEncryptedUtxosByTags(tags: [hash]),
      _code('invalid_response'),
    );
    expect(
      client(
        (_) => <String, Object?>{},
        raw: jsonEncode({'jsonrpc': '2.0', 'id': 1, 'error': 'down'}),
      ).getEncryptedUtxosByTags(tags: [hash]),
      _code('indexer_error'),
    );
    expect(
      client(
        (_) => <String, Object?>{},
        raw: jsonEncode({'jsonrpc': '2.0', 'id': 1}),
      ).getEncryptedUtxosByTags(tags: [hash]),
      _code('invalid_response'),
    );
  });

  test('decoders reject malformed records', () {
    Object? resultOf(Object? result) => result;
    expect(
      () => decodeShieldedTransactions(resultOf('nope')),
      _code('invalid_response'),
    );
    expect(
      () => decodeEncryptedUtxos({
        'context': {'blockTime': 1, 'slot': 1},
        'paginationToken': '',
        'data': <Object?>[],
      }),
      _code('invalid_response'),
    );
    expect(
      () => decodeUserRecords({
        'context': {'blockTime': 1, 'slot': 1},
        'records': [
          {
            'owner': tree,
            'nullifierPubkey': hash,
            'viewingPubkey': base64.encode(Uint8List(33)),
            'mergeEncryption': 2,
          },
        ],
      }),
      _code('invalid_response'),
    );
    expect(
      () => decodeUserRecords({
        'context': {'blockTime': 1, 'slot': 1},
        'records': [
          {
            'owner': 'not-an-address',
            'nullifierPubkey': hash,
            'viewingPubkey': base64.encode(Uint8List(33)),
            'mergeEncryption': 0,
          },
        ],
      }),
      _code('invalid_response'),
    );
    expect(
      () => decodeMerkleProofs({
        'context': {'blockTime': -1, 'slot': 1},
        'proofs': <Object?>[],
      }),
      _code('invalid_response'),
    );
    expect(
      () => decodeMerkleProofs({
        'context': {'blockTime': '18446744073709551616', 'slot': 1},
        'proofs': <Object?>[],
      }),
      _code('invalid_response'),
    );
    expect(
      () => decodeMerkleProofs({
        'context': {'blockTime': true, 'slot': 1},
        'proofs': <Object?>[],
      }),
      _code('invalid_response'),
    );
    expect(
      () => decodeMerkleProofs({
        'context': {'blockTime': 1, 'slot': 1},
        'proofs': [
          {
            'leaf': hash,
            'merkleContext': {'treeType': 1, 'tree': tree},
            'path': <Object?>[],
            'leafIndex': 1,
            'root': hash,
            'rootSeq': 1,
            'rootIndex': '2147483648',
          },
        ],
      }),
      _code('invalid_response'),
    );
    expect(
      () => decodeNonInclusionProofs({
        'context': {'blockTime': 1, 'slot': 1},
        'proofs': [
          {
            'leaf': '',
            'merkleContext': {'treeType': 1, 'tree': tree},
            'path': <Object?>[],
            'lowElement': hash,
            'lowElementIndex': 1,
            'highElement': hash,
            'highElementIndex': 1,
            'root': hash,
            'rootSeq': 1,
            'rootIndex': 1,
          },
        ],
      }),
      _code('invalid_response'),
    );
    expect(
      () => decodeShieldedTransactions({
        'context': {'blockTime': 1, 'slot': 1},
        'data': [
          {
            'slot': 1,
            'signature': signature,
            'events': [
              {
                'slot': 1,
                'txSignature': signature,
                'outputSlots': <Object?>[],
                'messages': <Object?>[],
                'nullifiers': [_b58(1, 3)],
                'proofless': false,
              },
            ],
          },
        ],
      }),
      _code('invalid_response'),
    );
    expect(
      () => decodeShieldedTransactions({
        'context': {'blockTime': 1, 'slot': 1},
        'data': [
          {
            'slot': 1,
            'signature': '0',
            'events': <Object?>[],
          },
        ],
      }),
      _code('invalid_response'),
    );
    expect(
      () => decodeShieldedTransactions({
        'context': {'blockTime': 1, 'slot': 1},
        'data': [
          {
            'slot': 1,
            'signature': hash,
            'events': <Object?>[],
          },
        ],
      }),
      _code('invalid_response'),
    );
    expect(
      () => decodeShieldedTransactions({
        'context': {'blockTime': 1, 'slot': 1},
        'data': [
          {
            'slot': 1,
            'signature': signature,
            'events': [
              {
                'slot': 1,
                'txSignature': signature,
                'outputSlots': <Object?>[],
                'messages': <Object?>[],
                'nullifiers': ['0'],
                'proofless': false,
              },
            ],
          },
        ],
      }),
      _code('invalid_response'),
    );
    expect(
      () => decodeEncryptedUtxos({
        'context': {'blockTime': 1, 'slot': 1},
        'data': [
          {
            'slot': 1,
            'signature': signature,
            'outputs': [
              {
                'slot': 1,
                'txSignature': signature,
                'outputSlot': {
                  'viewTag': hash,
                  'outputContext': {
                    'treeId': 1,
                    'hash': hash,
                    'tree': tree,
                    'leafIndex': 1,
                  },
                  'payload': '****',
                },
              },
            ],
          },
        ],
      }),
      _code('invalid_response'),
    );
    expect(
      () => decodeEncryptedUtxos({
        'context': {'blockTime': 1, 'slot': 1},
        'data': [
          {
            'slot': 1,
            'signature': signature,
            'outputs': [
              {
                'slot': 1,
                'txSignature': signature,
                'outputSlot': {
                  'viewTag': hash,
                  'outputContext': {
                    'treeId': 1,
                    'hash': hash,
                    'tree': tree,
                    'leafIndex': 1,
                  },
                  'payload': base64.encode([1]),
                },
                'salt': base64.encode([1]),
              },
            ],
          },
        ],
      }),
      _code('invalid_response'),
    );
    expect(
      () => decodeShieldedTransactions({
        'context': {'blockTime': 1, 'slot': 1},
        'data': [
          {
            'slot': 1,
            'signature': signature,
            'events': [
              {
                'slot': 1,
                'txSignature': signature,
                'outputSlots': <Object?>[],
                'messages': <Object?>[],
                'nullifiers': <Object?>[],
                'proofless': 'no',
              },
            ],
          },
        ],
      }),
      _code('invalid_response'),
    );
    expect(
      () => decodeShieldedTransactionsBySignature({
        'context': 'nope',
        'transactions': <Object?>[],
      }),
      _code('invalid_response'),
    );
    expect(
      () => decodeUserRecords({
        'context': {'blockTime': 1, 'slot': 1},
        'records': 'nope',
      }),
      _code('invalid_response'),
    );
  });
}
