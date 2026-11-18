import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';
import 'package:solana_kit_privacy_rings/solana_kit_privacy_rings.dart';
import 'package:test/test.dart';

import 'nitro_quote.dart';

String _b58(List<int> value) =>
    getBase58Decoder().decode(Uint8List.fromList(value));
Uint8List _u64(int value) =>
    (ByteData(8)..setUint64(0, value, Endian.little)).buffer.asUint8List();
Uint8List _frame(int encoding, int scheme, List<int> body) =>
    Uint8List.fromList([
      encoding,
      ...(ByteData(
        4,
      )..setUint32(0, body.length + 1, Endian.little)).buffer.asUint8List(),
      scheme,
      ...body,
    ]);
Matcher _code(String code) =>
    throwsA(isA<PrivacyRingsException>().having((e) => e.code, 'code', code));

void main() {
  test('known credentials are redacted even without a URL query label', () {
    expect(
      redactSecrets('rejected test-key', apiKey: 'test-key'),
      'rejected [REDACTED]',
    );
    expect(
      redactSecrets('https://x/?key=test-key', apiKey: ''),
      isNot(contains('test-key')),
    );
    expect(
      redactSecrets('HTTPS://user:secret@example.com'),
      isNot(contains('user:secret')),
    );
  });
  final owner = fieldU32(9);
  final blinding = fieldU32(3);
  final commitment = fieldU32(4);
  final signature = _b58(Uint8List(64));
  OutputSlot deposit(int leaf, {Uint8List? recipient}) => OutputSlot(
    viewTag: _b58(Uint8List(32)),
    outputContext: OutputContext(
      treeId: 0,
      hash: _b58(commitment),
      tree: stateMerkleTree,
      leafIndex: BigInt.from(leaf),
    ),
    payload: _frame(plaintextEncoding, prooflessScheme, [
      ...recipient ?? owner,
      ...blinding,
      ...getAddressEncoder().encode(solMint),
      ..._u64(7),
      0,
      0,
      0,
      0,
      0,
      0,
    ]),
  );
  EncryptedUtxoMatch match(OutputSlot slot) => EncryptedUtxoMatch(
    slot: BigInt.one,
    txSignature: signature,
    outputSlot: slot,
  );

  test('report composition cannot restore explicitly spent deposits', () async {
    final report = await readProoflessDeposits(
      [match(deposit(0)), match(deposit(1))],
      expectedOwner: owner,
      spent: {SpentLeaf(0, BigInt.zero)},
    );
    final combined = combineBalanceReports(
      report,
      const PrivateBalanceReport(notes: [], balances: [], skipped: 0),
    );
    expect(combined.notes.single.leafIndex, BigInt.one);
    expect(combined.balances.single.amount, BigInt.from(7));
  });

  test('proofless tags do not establish deposit ownership', () async {
    final report = await readProoflessDeposits([
      match(deposit(0)),
      match(deposit(1, recipient: fieldU32(8))),
    ], expectedOwner: owner);
    expect(report.notes, hasLength(1));
    expect(report.skipped, 1);
    await expectLater(
      readProoflessDeposits([], expectedOwner: Uint8List(31)),
      _code('invalid_length'),
    );
  });

  test('balance facade finds a spend absent from tag history', () async {
    final key = NullifierKey.fromSecret(Uint8List(31)..[30] = 5);
    addTearDown(key.destroy);
    final nullifier = key.nullifier(commitment, blinding);
    var lookedUp = false;
    final rings = PrivacyRings(
      httpClient: MockClient((request) async {
        final body = jsonDecode(request.body) as Map<String, Object?>;
        final method = body['method'];
        final isSpend = method == 'getShieldedTransactionsByNullifiers';
        if (isSpend) {
          lookedUp = true;
          expect((body['params']! as Map)['nullifiers'], [_b58(nullifier)]);
        }
        return http.Response(
          jsonEncode({
            'jsonrpc': '2.0',
            'id': body['id'],
            'result': {
              'context': {'blockTime': 1, 'slot': 1},
              'paginationToken': null,
              'data': method == 'getEncryptedUtxosByTags'
                  ? [
                      {
                        'slot': 1,
                        'signature': signature,
                        'outputs': [
                          {
                            'slot': 1,
                            'txSignature': signature,
                            'outputSlot': {
                              'viewTag': _b58(Uint8List(32)),
                              'payload': base64Encode(deposit(0).payload),
                              'outputContext': {
                                'treeId': 0,
                                'hash': _b58(commitment),
                                'tree': stateMerkleTree.value,
                                'leafIndex': 0,
                              },
                            },
                          },
                        ],
                      },
                    ]
                  : isSpend
                  ? [
                      {
                        'slot': 1,
                        'signature': signature,
                        'events': [
                          {
                            'slot': 1,
                            'txSignature': signature,
                            'outputSlots': <Object?>[],
                            'messages': <Object?>[],
                            'nullifiers': [_b58(nullifier)],
                            'proofless': false,
                          },
                        ],
                      },
                    ]
                  : <Object?>[],
            },
          }),
          200,
        );
      }),
    );
    final report = await rings.readPrivateBalance(
      viewingKey: ViewingKey.fromBytes(Uint8List(32)),
      tags: [_b58(Uint8List(32))],
      expectedOwner: owner,
      verifyConfidentialNote: (_, _) => fail('no confidential outputs'),
      nullifierKey: key,
    );
    expect(lookedUp, isTrue);
    expect(report.notes, isEmpty);
    expect(report.balances, isEmpty);
  });

  test(
    'parseable CTR tampering is excluded by commitment verification',
    () async {
      final sender = ViewingKey.fromBytes(Uint8List(32)..[0] = 1);
      final recipient = ViewingKey.fromBytes(Uint8List(32)..[0] = 2);
      final mintHash = hashBytes(getAddressEncoder().encode(solMint));
      Uint8List hash(ConfidentialPlaintext note) => utxoCommitment(
        domain: fieldU32(1),
        treeId: fieldU32(0),
        assetHash: mintHash,
        amount: fieldU32(note.amount.toInt()),
        dataHash: Uint8List(32),
        ringDataHash: Uint8List(32),
        ringProgramId: Uint8List(32),
        owner: owner,
        blinding: note.blinding,
      );
      final plaintext = Uint8List.fromList([
        ..._u64(1),
        ..._u64(7),
        ...blinding,
        0,
        0,
      ]);
      final expected = hash(decodeConfidentialPlaintext(plaintext));
      final salt = Uint8List(16);
      final ciphertext = await sender.encryptSlot(
        recipientPublicKey: await recipient.publicKey(),
        plaintext: plaintext,
        salt: salt,
        slotIndex: 0,
      );
      Future<PrivateBalanceReport> read(List<int> encrypted) async =>
          readConfidentialNotes(
            viewingKey: recipient,
            verifyNote: (note, context) => _b58(hash(note)) == context.hash,
            transactions: [
              ShieldedTransaction(
                slot: BigInt.one,
                txSignature: signature,
                messages: const [],
                nullifiers: const [],
                proofless: false,
                txViewingPk: await sender.publicKey(),
                salt: salt,
                outputSlots: [
                  OutputSlot(
                    viewTag: _b58(Uint8List(32)),
                    outputContext: OutputContext(
                      treeId: 0,
                      hash: _b58(expected),
                      tree: stateMerkleTree,
                      leafIndex: BigInt.zero,
                    ),
                    payload: _frame(encryptedEncoding, confidentialScheme, [
                      ...await sender.publicKey(),
                      ...encrypted,
                    ]),
                  ),
                ],
              ),
            ],
          );
      expect((await read(ciphertext)).balances.single.amount, BigInt.from(7));
      final modified = Uint8List.fromList(ciphertext)..[8] ^= 1;
      final rejected = await read(modified);
      expect(rejected.notes, isEmpty);
      expect(rejected.skipped, 1);
    },
  );

  test('public deposits in transact require settlement accounts', () async {
    final data = TransactInstructionData(
      expiryUnixTs: BigInt.zero,
      txViewingPk: Uint8List(33),
      salt: Uint8List(16),
      interfaceTransfers: [SolDepositTransfer(BigInt.one)],
      outputs: const [],
      messages: const [],
      privateTxHash: Uint8List(32),
      circuit: CircuitId.confidentialSigner(
        inputs: 0,
        outputs: 0,
        publicAssetSlots: 3,
      ),
      proof: TransactProof.zeroed(),
      inputs: const [],
      treeContexts: const [
        TreeContext(utxoTreeRootIndex: 0, nullifierTreeRootIndex: 0),
      ],
    );
    await expectLater(
      confidentialTransferInstruction(
        payer: stateMerkleTree,
        inputTree: stateMerkleTree,
        outputTree: stateMerkleTree,
        ownerSigners: [],
        data: data,
      ),
      _code('withdrawal_mismatch'),
    );
  });

  test('hung HTTP submission and polling respect maxWait', () async {
    for (final queued in [false, true]) {
      final client = PrivacyProverClient(
        endpoint: Uri.parse(localProverUrl),
        maxWait: const Duration(milliseconds: 40),
        httpClient: MockClient((request) {
          if (queued && request.method == 'POST') {
            return Future.value(http.Response('{"jobId":"job1"}', 200));
          }
          return Completer<http.Response>().future;
        }),
      );
      await expectLater(
        client.prove(circuit: 'transfer_confidential_1_2', witness: const {}),
        _code('prover_timeout'),
      );
    }
  });

  test('invalid polling configuration fails before HTTP', () async {
    final client = PrivacyProverClient(
      endpoint: Uri.parse(localProverUrl),
      pollInterval: const Duration(seconds: -1),
      httpClient: MockClient((_) => fail('must not send a witness')),
    );
    await expectLater(
      client.prove(circuit: 'transfer_confidential_1_2', witness: const {}),
      _code('invalid_config'),
    );
  });

  test(
    'a transient status failure retries within the overall deadline',
    () async {
      var polls = 0;
      final client = PrivacyProverClient(
        endpoint: Uri.parse(localProverUrl),
        pollInterval: Duration.zero,
        httpClient: MockClient((request) async {
          if (request.method == 'POST') {
            return http.Response('{"jobId":"retry1"}', 200);
          }
          if (polls++ == 0) return http.Response('temporary failure', 503);
          return http.Response(
            jsonEncode({
              'status': 'completed',
              'result': {
                'ar': ['0x0', '0x0'],
                'bs': [
                  ['0x0', '0x0'],
                  ['0x0', '0x0'],
                ],
                'krs': ['0x1', '0x2'],
                'provingKeySha256': provingKeySha256(
                  'transfer_confidential_1_2',
                ),
              },
            }),
            200,
          );
        }),
      );
      expect(
        await client.prove(
          circuit: 'transfer_confidential_1_2',
          witness: const {},
        ),
        isA<TransactProof>(),
      );
      expect(polls, 2);
    },
  );

  test('partial witness paths are rejected instead of silently omitted', () {
    final zero = Uint8List(32);
    final note = CircuitNote(
      domain: zero,
      owner: zero,
      asset: zero,
      amount: zero,
      blinding: zero,
      dataHash: zero,
      ringDataHash: zero,
      ringProgramId: zero,
    );
    for (final nonInclusion in [false, true]) {
      expect(
        () => confidentialTransferWitness(
          inputs: [
            WitnessInput(
              note: note,
              treeSlot: zero,
              treeId: zero,
              ownerPublicKeyHash: zero,
              nullifierSecret: Uint8List(31),
              statePathIndex: nonInclusion ? null : zero,
              nullifierLowValue: nonInclusion ? zero : null,
            ),
          ],
          outputs: [],
          outputTreeId: zero,
          externalDataHash: zero,
          privateTxHash: zero,
          blindingSeed: zero,
          ringProgramId: zero,
          publicAssets: [],
          publicAmounts: [],
          signerPublicKeyHashes: [],
          inputFlags: zero,
          publishedOutputOwnerPublicKeyHashes: [],
          cacheTreeId: zero,
          cacheReadHashChain: zero,
          cacheReadHashes: [],
          cacheIsCached: [],
          cacheReadIndex: [],
        ),
        _code('invalid_shape'),
      );
    }
    expect(
      () => indexedProofRequest(
        prepared: {},
        trees: [],
        lookups: [],
        publicInputs: [],
        minContextSlot: -BigInt.one,
      ),
      _code('integer_range'),
    );
  });

  test('oversized CBOR arguments fail with an attestation error', () {
    expect(
      () => verifyNitroAttestation(
        document: [0x9b, ...List<int>.filled(8, 255)],
        measurements: [nitroMeasurement()],
        nonce: Uint8List(32),
        hpkePublicKey: Uint8List(32),
        nowSecs: 1,
      ),
      _code('malformed_attestation'),
    );
  });

  test('HPKE rejects a non-contributory recipient key', () async {
    await expectLater(
      encryptProverRequest(
        hpkePublicKey: Uint8List(32),
        method: 'POST',
        requestUri: '/prove/test',
        plaintext: [],
        ephemeralSeed: Uint8List(32)..[0] = 1,
      ),
      _code('non_contributory_key'),
    );
  });

  test('truncated offchain signer arrays return false without throwing', () {
    final message = ed25519DerivationMessage(Uint8List(32));
    for (var length = 0; length < 85; length++) {
      expect(isDerivationInput(message.sublist(0, length)), isFalse);
    }
    message[50] = 255;
    expect(isDerivationInput(message), isFalse);
  });

  test('caller mutation cannot change the attestation policy', () {
    final image = Uint8List.fromList(nitroPcr0);
    final anchor = Uint8List.fromList(nitroTestRoot);
    final pcr = Uint8List.fromList(nitroPcr0);
    final measurement = NitroMeasurement(
      pcr0: pcr,
      pcr1: nitroPcr1,
      pcr2: nitroPcr2,
    );
    final policy = TeePolicy(
      platform: 'aws-nitro',
      imageIds: [image],
      anchors: [anchor],
      measurements: [measurement],
    );
    image[0] = 99;
    anchor[0] = 99;
    pcr[0] = 99;
    expect(policy.imageIds.single, nitroPcr0);
    expect(policy.anchors!.single, nitroTestRoot);
    expect(measurement.pcr0, nitroPcr0);
    expect(() => policy.imageIds.single[0] = 99, throwsUnsupportedError);
    expect(() => awsNitroRoot[0] = 99, throwsUnsupportedError);
  });
}
