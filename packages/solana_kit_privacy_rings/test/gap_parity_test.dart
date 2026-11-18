import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';
import 'package:solana_kit_privacy_rings/solana_kit_privacy_rings.dart';
import 'package:test/test.dart';

File _fixture(String name) {
  final relative = 'test/fixtures/$name';
  final local = File(relative);
  if (local.existsSync()) return local;
  return File('packages/solana_kit_privacy_rings/$relative');
}

Uint8List _hex(String text) {
  final body = text.startsWith('0x') ? text.substring(2) : text;
  final even = body.length.isOdd ? '0$body' : body;
  final padded = even.padLeft(64, '0');
  final bytes = Uint8List(32);
  for (var i = 0; i < 32; i++) {
    bytes[i] = int.parse(padded.substring(i * 2, i * 2 + 2), radix: 16);
  }
  return bytes;
}

String _hexOf(List<int> bytes) =>
    bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();

Matcher _code(String code) => throwsA(
  isA<PrivacyRingsException>().having((error) => error.code, 'code', code),
);

String _b58(List<int> bytes) =>
    getBase58Decoder().decode(Uint8List.fromList(bytes));

void main() {
  final keys = jsonDecode(
    _fixture('key_derivation.json').readAsStringSync(),
  ) as Map<String, Object?>;
  final hashes = jsonDecode(
    _fixture('public_input_hash.json').readAsStringSync(),
  ) as Map<String, Object?>;

  test(
    'a derivation seed expands to the pinned nullifier and viewing secrets',
    () {
      final rail = keys['eddsa_rail']! as Map<String, Object?>;
      final message = ed25519DerivationMessage(
        _hex(rail['signer_pubkey']! as String),
      );
      expect(_hexOf(message), rail['derivation_message']);
      final roles = expandShieldedSeed(
        _raw(rail['derivation_seed']! as String),
      );
      expect(_hexOf(roles.nullifierSecret), rail['nullifier_secret']);
      expect(_hexOf(roles.viewingSecret), rail['viewing_secret']);
      final key = NullifierKey.fromSecret(roles.nullifierSecret);
      expect(_hexOf(key.publicKey()), rail['nullifier_pubkey']);
      key.destroy();
      expect(
        () => expandShieldedSeed(Uint8List(32)),
        _code('invalid_length'),
      );
      expect(
        () => ed25519DerivationMessage(Uint8List(31)),
        _code('invalid_length'),
      );
      expect(() => clampViewingSecret(Uint8List(31)), _code('invalid_length'));
      final clamped = clampViewingSecret(
        Uint8List(32)
          ..[0] = 0xff
          ..[31] = 0x01,
      );
      expect(clamped[0] & 7, 0);
      expect(clamped[31] & 0x40, 0x40);
      final guards = keys['derivation_input_guard']! as List;
      for (final entry in guards) {
        final guard = entry as Map<String, Object?>;
        expect(
          isDerivationInput(_raw(guard['message']! as String)),
          guard['is_derivation_input'],
          reason: guard['name']! as String,
        );
      }
    },
  );

  test('public input hashes match the transfer vectors', () {
    for (final entry in hashes['transfers']! as List) {
      final vector = entry as Map<String, Object?>;
      final cached = (vector['cached_inputs']! as List).cast<String>();
      final owners = vector['output_owner_pk_hashes'] as List?;
      final hash = transferPublicInputHash(
        nullifiers: _fields(vector['nullifiers']),
        outputHashes: _fields(vector['output_hashes']),
        outputTreeId: vector['output_tree_id']! as int,
        privateTxHash: _hex(vector['private_tx_hash']! as String),
        externalDataHash: _hex(vector['external_data_hash']! as String),
        publicAssets: _fields(vector['public_assets']),
        publicAmounts: _fields(vector['public_amounts']),
        ringProgramId: _hex(vector['ring_program_id']! as String),
        signerPublicKeyHashes: _fields(vector['signer_pk_hashes']),
        inputFlags: _hex(vector['input_flags']! as String),
        publishedOutputOwnerPublicKeyHashes: owners == null
            ? null
            : _fields(owners),
        cacheTreeId: _hex(cached[0]),
        cacheReadHashChain: _hex(cached[1]),
        treeSlots: [
          for (final slot in vector['tree_slots']! as List)
            ProofTreeSlot(
              id: (slot as Map)['id'] as int,
              utxoRoot: _hex(slot['utxo_root'] as String),
              nullifierRoot: _hex(slot['nullifier_root'] as String),
            ),
        ],
      );
      expect(
        _hexOf(hash),
        vector['public_input_hash']! as String,
        reason: vector['name']! as String,
      );
    }
    expect(
      () => hashChain4([Uint8List(31)]),
      _code('invalid_length'),
    );
    expect(_hexOf(rightHashChain(const [])), _hexOf(Uint8List(32)));
    expect(
      () => treeSlotsHashChain(const []),
      _code('invalid_length'),
    );
    expect(() => treeIdField(-1), _code('integer_range'));
    expect(() => treeIdField(0x10000), _code('integer_range'));
    expect(
      () => treeIdFromField(Uint8List(32)..[0] = 1),
      _code('integer_range'),
    );
    expect(
      () => ProofTreeSlot(
        id: 0x10000,
        utxoRoot: Uint8List(32),
        nullifierRoot: Uint8List(32),
      ),
      _code('integer_range'),
    );
    expect(
      () => transferPublicInputHash(
        nullifiers: [Uint8List(32)],
        outputHashes: [Uint8List(32)],
        outputTreeId: 0,
        privateTxHash: Uint8List(32),
        externalDataHash: Uint8List(32),
        publicAssets: [Uint8List(32)],
        publicAmounts: const [],
        ringProgramId: Uint8List(32),
        signerPublicKeyHashes: const [],
        inputFlags: Uint8List(32),
        treeSlots: List.generate(
          inputTreeCount,
          (_) => ProofTreeSlot(
            id: 0,
            utxoRoot: Uint8List(32),
            nullifierRoot: Uint8List(32),
          ),
        ),
      ),
      _code('invalid_length'),
    );
    expect(
      () => transferPublicInputs(
        nullifiers: [Uint8List(32)],
        outputHashes: [Uint8List(32)],
        outputTreeId: 0,
        privateTxHash: Uint8List(32),
        externalDataHash: Uint8List(32),
        publicAssets: const [],
        publicAmounts: const [],
        ringProgramId: Uint8List(32),
        signerPublicKeyHashes: const [],
        inputFlags: Uint8List(32),
        publishedOutputOwnerPublicKeyHashes: const [],
      ),
      _code('invalid_length'),
    );
  });

  test('notes and Merkle paths rebuild the transfer-2x2 witness', () {
    final fixture = jsonDecode(
      _fixture('transfer-2x2.json').readAsStringSync(),
    ) as Map<String, Object?>;
    final slots = fixture['treeSlots']! as List<Object?>;
    final firstSlot = slots.first! as Map<String, Object?>;
    final inputTree = _hex(firstSlot['id']! as String);
    final outputTree = _hex(fixture['outputTreeId']! as String);
    final inputs = [
      for (final raw in fixture['inputs']! as List)
        _witnessInput(raw as Map<String, Object?>, inputTree),
    ];
    final outputs = [
      for (final raw in fixture['outputs']! as List)
        _witnessOutput(raw as Map<String, Object?>, outputTree),
    ];
    final built = confidentialTransferWitness(
      inputs: inputs,
      outputs: outputs,
      outputTreeId: _hex(fixture['outputTreeId']! as String),
      externalDataHash: _hex(fixture['externalDataHash']! as String),
      privateTxHash: _hex(fixture['privateTxHash']! as String),
      blindingSeed: _hex(fixture['blindingSeed']! as String),
      ringProgramId: _hex(fixture['ringProgramId']! as String),
      publicAssets: _fields(fixture['publicAssets']),
      publicAmounts: _fields(fixture['publicAmounts']),
      signerPublicKeyHashes: _fields(fixture['signerPkHashes']),
      inputFlags: _hex(fixture['inputFlags']! as String),
      publishedOutputOwnerPublicKeyHashes: _fields(
        fixture['publishedOutputOwnerPkHashes'],
      ),
      cacheTreeId: _hex(fixture['cacheTreeId']! as String),
      cacheReadHashChain: _hex(fixture['cacheReadHashChain']! as String),
      cacheReadHashes: _fields(fixture['cacheReadHashes']),
      cacheIsCached: _fields(fixture['cacheIsCached']),
      cacheReadIndex: _fields(fixture['cacheReadIndex']),
      treeSlots: [
        for (final raw in fixture['treeSlots']! as List)
          _slot(raw as Map<String, Object?>),
      ],
    );
    expect(_same(built, fixture), isTrue);
  });

  test(
    'page walks stop on an empty token and refuse a truncated history',
    () async {
      final pages = [
        const HistoryPage(items: [1], paginationToken: 'next'),
        const HistoryPage(items: [2], paginationToken: ''),
      ];
      var step = 0;
      final collected = await collectPages((token) async {
        expect(token, step == 0 ? isNull : 'next');
        return pages[step++];
      }, maxPages: 3);
      expect(collected, [1, 2]);
      expect(
        () => collectPages(
          (_) async => const HistoryPage(items: [1]),
          maxPages: 0,
        ),
        _code('invalid_request'),
      );
      expect(
        () => collectPages(
          (_) async => const HistoryPage(items: [1], paginationToken: 'more'),
          maxPages: 1,
        ),
        _code('history_truncated'),
      );
    },
  );

  test('spent nullifiers reject a short value and collapse duplicates', () {
    final first = _b58(Uint8List(32)..[0] = 2);
    final second = _b58(Uint8List(32)..[0] = 1);
    final events = [
      _event([first, second]),
      _event([first]),
    ];
    final spent = spentNullifiers(events);
    expect(spent, hasLength(2));
    expect(spent.first[0], 1);
    expect(
      () => spentNullifiers([
        _event(['1']),
      ]),
      _code('invalid_length'),
    );
    expect(
      () => spentNullifiers([
        _event(['0']),
      ]),
      _code('invalid_length'),
    );
  });

  test(
    'getNullifierQueueElements posts the tree, sequence, and limit',
    () async {
      late Map<String, Object?> body;
      final hash = _b58(Uint8List(32)..[0] = 9);
      final client = PrivacyIndexerClient(
        endpoint: Uri.parse('http://127.0.0.1:8784'),
        httpClient: MockClient((request) async {
          body = jsonDecode(request.body) as Map<String, Object?>;
          expect(request.url.path, '/getNullifierQueueElements');
          return http.Response(
            jsonEncode({
              'jsonrpc': '2.0',
              'id': body['id'],
              'result': {
                'context': {'blockTime': 4, 'slot': 8},
                'elements': [
                  {'seq': 3, 'value': hash},
                ],
              },
            }),
            200,
          );
        }),
      );
      final page = await client.getNullifierQueueElements(
        treeAccount: stateMerkleTree,
        startSeq: 3,
        limit: 1000,
      );
      final params = body['params']! as Map<String, Object?>;
      expect(params['treeAccount'], stateMerkleTree.toString());
      expect(params['startSeq'], 3);
      expect(params['limit'], 1000);
      expect(body['method'], 'getNullifierQueueElements');
      expect(page.elements.single.seq, BigInt.from(3));
      expect(page.elements.single.value, hash);
      client.close();
      final refused = PrivacyIndexerClient(
        endpoint: Uri.parse('http://127.0.0.1:8784'),
        httpClient: MockClient((_) async => http.Response('{}', 200)),
      );
      expect(
        () => refused.getNullifierQueueElements(
          treeAccount: stateMerkleTree,
          startSeq: -1,
          limit: 1,
        ),
        _code('integer_range'),
      );
      expect(
        () => refused.getNullifierQueueElements(
          treeAccount: stateMerkleTree,
          limit: 1001,
        ),
        _code('invalid_limit'),
      );
      expect(
        refused.getNullifierQueueElements(
          treeAccount: stateMerkleTree,
          limit: 1,
        ),
        _code('invalid_response'),
      );
      refused.close();
    },
  );

  test('cluster URLs, base64, and the remaining PDAs match Rust', () async {
    expect(
      PrivacyRingsCluster.mainnet.indexerUrl('getEncryptedUtxosByTags'),
      'https://mainnet.helius-rpc.com/v1/spr/getEncryptedUtxosByTags',
    );
    expect(
      PrivacyRingsCluster.devnet.proverUrl,
      'https://devnet.helius-rpc.com/v1/spr',
    );
    expect(
      PrivacyRingsCluster.mainnet.rpcOrigin,
      'https://mainnet.helius-rpc.com',
    );
    expect(localProverUrl, 'http://127.0.0.1:3001');
    expect(
      localIndexerUrl('getUserRecords'),
      'http://127.0.0.1:8784/getUserRecords',
    );
    expect(() => localIndexerUrl(''), _code('invalid_request'));
    expect(
      () => PrivacyRingsCluster.devnet.indexerUrl('get/user'),
      _code('invalid_request'),
    );
    expect(hexEncode([0, 15, 255]), '000fff');
    expect(decodeBase64('  YQ==  '), [97]);
    expect(() => decodeBase64('!!!'), _code('base64'));
    final tree = await stateTreePda(0);
    expect(tree.address, stateMerkleTree);
    expect(() => stateTreePda(-1), _code('integer_range'));
    expect(() => stateTreePda(0x10000), _code('integer_range'));
    final record = await userRecordPda(userRegistryProgramId);
    expect(record.bump, inInclusiveRange(0, 255));
    expect(record.address, isNot(userRegistryProgramId));
  });
}

Uint8List _raw(String text) {
  final bytes = Uint8List(text.length ~/ 2);
  for (var i = 0; i < bytes.length; i++) {
    bytes[i] = int.parse(text.substring(i * 2, i * 2 + 2), radix: 16);
  }
  return bytes;
}

List<Uint8List> _fields(Object? value) => [
  for (final item in value! as List) _hex(item as String),
];

WitnessInput _witnessInput(Map<String, Object?> raw, Uint8List treeId) {
  final utxo = raw['utxo']! as Map<String, Object?>;
  final secret = _hex(raw['nullifierSecret']! as String).sublist(1);
  return WitnessInput(
    note: CircuitNote(
      domain: _hex(utxo['domain']! as String),
      owner: _hex(utxo['owner']! as String),
      asset: _hex(utxo['asset']! as String),
      amount: _hex(utxo['amount']! as String),
      blinding: _hex(utxo['blinding']! as String),
      dataHash: _hex(utxo['dataHash']! as String),
      ringDataHash: _hex(utxo['ringDataHash']! as String),
      ringProgramId: _hex(utxo['ringProgramId']! as String),
    ),
    treeSlot: _hex(raw['treeSlot']! as String),
    treeId: treeId,
    ownerPublicKeyHash: _hex(raw['ownerPkHash']! as String),
    nullifierSecret: secret,
    statePathElements: _fields(raw['statePathElements']),
    statePathIndex: _hex(raw['statePathIndex']! as String),
    nullifierLowValue: _hex(raw['nullifierLowValue']! as String),
    nullifierNextValue: _hex(raw['nullifierNextValue']! as String),
    nullifierLowPathElements: _fields(raw['nullifierLowPathElements']),
    nullifierLowPathIndex: _hex(raw['nullifierLowPathIndex']! as String),
  );
}

WitnessOutput _witnessOutput(Map<String, Object?> raw, Uint8List treeId) {
  final utxo = raw['utxo']! as Map<String, Object?>;
  return WitnessOutput(
    note: CircuitNote(
      domain: _hex(utxo['domain']! as String),
      owner: _hex(utxo['owner']! as String),
      asset: _hex(utxo['asset']! as String),
      amount: _hex(utxo['amount']! as String),
      blinding: Uint8List(32),
      dataHash: _hex(utxo['dataHash']! as String),
      ringDataHash: _hex(utxo['ringDataHash']! as String),
      ringProgramId: _hex(utxo['ringProgramId']! as String),
    ),
    treeId: treeId,
    ownerPublicKeyHash: _hex(raw['ownerPkHash']! as String),
    nullifierPublicKey: _hex(raw['nullifierPk']! as String),
  );
}

ProofTreeSlot _slot(Map<String, Object?> raw) {
  final id = _hex(raw['id']! as String);
  return ProofTreeSlot(
    id: (id[30] << 8) | id[31],
    utxoRoot: _hex(raw['utxoRoot']! as String),
    nullifierRoot: _hex(raw['nullifierRoot']! as String),
  );
}

ShieldedTransaction _event(List<String> nullifiers) {
  return ShieldedTransaction(
    slot: BigInt.one,
    txSignature: 'sig',
    outputSlots: const [],
    messages: const [],
    nullifiers: nullifiers,
    proofless: false,
  );
}

bool _same(Object? left, Object? right) {
  if (left is Map && right is Map) {
    if (left.length != right.length) return false;
    for (final key in left.keys) {
      if (!_same(left[key], right[key])) return false;
    }
    return true;
  }
  if (left is List && right is List) {
    if (left.length != right.length) return false;
    for (var i = 0; i < left.length; i++) {
      if (!_same(left[i], right[i])) return false;
    }
    return true;
  }
  if (left is String &&
      right is String &&
      left.startsWith('0x') &&
      right.startsWith('0x')) {
    return BigInt.parse(left.substring(2), radix: 16) ==
        BigInt.parse(right.substring(2), radix: 16);
  }
  return left == right;
}
