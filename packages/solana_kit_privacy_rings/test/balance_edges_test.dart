import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';
import 'package:solana_kit_privacy_rings/solana_kit_privacy_rings.dart';
import 'package:test/test.dart';

Matcher _code(String code) => throwsA(
  isA<PrivacyRingsException>().having((error) => error.code, 'code', code),
);

String _b58(int length, int marker) =>
    getBase58Decoder().decode(Uint8List(length)..[0] = marker);

Uint8List _u64(int value) {
  final data = ByteData(8)..setUint64(0, value, Endian.little);
  return data.buffer.asUint8List();
}

Uint8List _frame(int encoding, int scheme, List<int> body) {
  final blob = [scheme, ...body];
  final length = ByteData(4)..setUint32(0, blob.length, Endian.little);
  return Uint8List.fromList([
    encoding,
    ...length.buffer.asUint8List(),
    ...blob,
  ]);
}

OutputSlot _slot(Uint8List payload, int marker) {
  final hash = _b58(32, marker);
  return OutputSlot(
    viewTag: hash,
    outputContext: OutputContext(
      treeId: 1,
      hash: hash,
      tree: stateMerkleTree,
      leafIndex: BigInt.zero,
    ),
    payload: payload,
  );
}

void main() {
  test('balance reads skip notes they cannot open', () async {
    final key = ViewingKey.fromBytes(Uint8List(32)..[0] = 4);
    final other = ViewingKey.fromBytes(Uint8List(32)..[0] = 5);
    final salt = Uint8List(16)..[0] = 2;
    final plaintext = Uint8List.fromList([
      ..._u64(2),
      ..._u64(5),
      ...Uint8List(32),
      0,
      0,
    ]);
    final ciphertext = await other.encryptSlot(
      recipientPublicKey: await key.publicKey(),
      plaintext: plaintext,
      salt: salt,
      slotIndex: 0,
    );
    final embedded = Uint8List.fromList([
      ...await other.publicKey(),
      ...ciphertext,
    ]);
    final signature = _b58(64, 9);
    ShieldedTransaction transaction({
      required bool proofless,
      required Uint8List payload,
      Uint8List? viewing,
      Uint8List? txSalt,
    }) {
      return ShieldedTransaction(
        slot: BigInt.one,
        txSignature: signature,
        outputSlots: [_slot(payload, 3)],
        messages: const [],
        nullifiers: const [],
        proofless: proofless,
        txViewingPk: viewing,
        salt: txSalt,
      );
    }

    final skippedFlag = await readConfidentialNotes(
      viewingKey: key,
      transactions: [
        transaction(
          proofless: true,
          payload: _frame(encryptedEncoding, confidentialScheme, embedded),
        ),
        transaction(
          proofless: false,
          payload: _frame(encryptedEncoding, confidentialScheme, embedded),
        ),
      ],
    );
    expect(skippedFlag.notes, isEmpty);
    expect(skippedFlag.skipped, 2);

    final noted = await readConfidentialNotes(
      viewingKey: key,
      transactions: [
        transaction(
          proofless: false,
          viewing: await other.publicKey(),
          txSalt: salt,
          payload: _frame(encryptedEncoding, ringConfidentialScheme, embedded),
        ),
        transaction(
          proofless: false,
          viewing: await other.publicKey(),
          txSalt: salt,
          payload: _frame(plaintextEncoding, confidentialScheme, embedded),
        ),
      ],
      mints: {BigInt.two: stateMerkleTree},
    );
    expect(noted.notes.single.mint, stateMerkleTree);
    expect(noted.notes.single.amount, BigInt.from(5));
    expect(noted.skipped, 1);

    final unmapped = await readConfidentialNotes(
      viewingKey: key,
      transactions: [
        transaction(
          proofless: false,
          viewing: await other.publicKey(),
          txSalt: salt,
          payload: _frame(encryptedEncoding, confidentialScheme, embedded),
        ),
      ],
    );
    expect(unmapped.balances.single.mint, isNull);
    expect(unmapped.balances.single.assetId, BigInt.two);

    final garbage = await other.encryptSlot(
      recipientPublicKey: await key.publicKey(),
      plaintext: [1, 2, 3],
      salt: salt,
      slotIndex: 0,
    );
    final undecodable = await readConfidentialNotes(
      viewingKey: key,
      transactions: [
        transaction(
          proofless: false,
          viewing: await other.publicKey(),
          txSalt: salt,
          payload: _frame(encryptedEncoding, confidentialScheme, [
            ...await other.publicKey(),
            ...garbage,
          ]),
        ),
      ],
    );
    expect(undecodable.skipped, 1);

    expect(
      readConfidentialNotes(
        viewingKey: key,
        transactions: [
          transaction(
            proofless: false,
            viewing: await other.publicKey(),
            txSalt: salt,
            payload: Uint8List.fromList([1]),
          ),
        ],
      ),
      _code('truncated'),
    );

    final clear = EncryptedUtxoMatch(
      slot: BigInt.one,
      txSignature: signature,
      outputSlot: _slot(
        _frame(plaintextEncoding, confidentialScheme, [1]),
        4,
      ),
    );
    final deposits = await readProoflessDeposits([clear]);
    expect(deposits.notes, isEmpty);
    expect(deposits.skipped, 1);
  });

  test('the facade pages both histories and posts a witness', () async {
    final hash = _b58(32, 1);
    final signature = _b58(64, 2);
    final pin = provingKeySha256('transfer_confidential_1_2')!;
    final httpClient = MockClient((request) async {
      if (request.url.path.contains('/prove')) {
        return http.Response(
          jsonEncode({
            'ar': ['0x0', '0x0'],
            'bs': [
              ['0x0', '0x0'],
              ['0x0', '0x0'],
            ],
            'krs': ['0x1', '0x2'],
            'provingKeySha256': pin,
          }),
          200,
        );
      }
      final body = jsonDecode(request.body) as Map<String, Object?>;
      final method = body['method'];
      final child = method == 'getEncryptedUtxosByTags' ? 'outputs' : 'events';
      return http.Response(
        jsonEncode({
          'jsonrpc': '2.0',
          'id': body['id'],
          'result': {
            'context': {'blockTime': 1, 'slot': 2},
            'paginationToken': null,
            'data': [
              {
                'slot': 1,
                'signature': signature,
                child: <Object?>[],
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
    expect(
      rings.readPrivateBalance(
        expectedOwner: Uint8List(32),
        verifyConfidentialNote: (note, context) => false,
        viewingKey: ViewingKey.fromBytes(Uint8List(32)..[0] = 1),
        tags: [hash],
        maxPages: 0,
      ),
      _code('invalid_request'),
    );
    final report = await rings.readPrivateBalance(
      expectedOwner: Uint8List(32),
      verifyConfidentialNote: (note, context) => false,
      viewingKey: ViewingKey.fromBytes(Uint8List(32)..[0] = 1),
      tags: [hash],
    );
    expect(report.notes, isEmpty);
    final proof = await rings.prove(
      circuit: 'transfer_confidential_1_2',
      witness: const {},
    );
    expect(proof.c[31], 1);

    final truncating = PrivacyRings(
      indexerUrl: Uri.parse('http://127.0.0.1:8784'),
      proverUrl: Uri.parse('http://127.0.0.1:3001'),
      httpClient: MockClient((request) async {
        final body = jsonDecode(request.body) as Map<String, Object?>;
        final deposits = body['method'] == 'getEncryptedUtxosByTags';
        return http.Response(
          jsonEncode({
            'jsonrpc': '2.0',
            'id': body['id'],
            'result': {
              'context': {'blockTime': 1, 'slot': 2},
              'paginationToken': deposits ? 'next' : null,
              'data': <Object?>[],
            },
          }),
          200,
        );
      }),
    );
    expect(
      truncating.readPrivateBalance(
        expectedOwner: Uint8List(32),
        verifyConfidentialNote: (note, context) => false,
        viewingKey: ViewingKey.fromBytes(Uint8List(32)..[0] = 1),
        tags: [hash],
        maxPages: 1,
      ),
      _code('history_truncated'),
    );
    PrivacyRings(
      indexerUrl: Uri.parse('http://127.0.0.1:8784'),
      proverUrl: Uri.parse('http://127.0.0.1:3001'),
    ).close();
  });
}
