import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_privacy_rings/solana_kit_privacy_rings.dart';
import 'package:test/test.dart';

import 'nitro_quote.dart';

Matcher _code(String code) => throwsA(
  isA<PrivacyRingsException>().having((error) => error.code, 'code', code),
);

File _fixture(String name) {
  final relative = 'test/fixtures/$name';
  final local = File(relative);
  if (local.existsSync()) return local;
  return File('packages/solana_kit_privacy_rings/$relative');
}

String _b58(List<int> bytes) =>
    getBase58Decoder().decode(Uint8List.fromList(bytes));

Uint8List _hex(String text) {
  final bytes = Uint8List(text.length ~/ 2);
  for (var i = 0; i < bytes.length; i++) {
    bytes[i] = int.parse(text.substring(i * 2, i * 2 + 2), radix: 16);
  }
  return bytes;
}

String _hexOf(List<int> bytes) =>
    bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();

Uint8List _frame(List<int> body) {
  final blob = [prooflessScheme, ...body];
  final length = ByteData(4)..setUint32(0, blob.length, Endian.little);
  return Uint8List.fromList([
    plaintextEncoding,
    ...length.buffer.asUint8List(),
    ...blob,
  ]);
}

TransactInstructionData _data({
  List<InterfaceTransfer> transfers = const [],
  CircuitId? circuit,
  List<InputUtxo> inputs = const [],
  List<TreeContext> trees = const [
    TreeContext(utxoTreeRootIndex: 1, nullifierTreeRootIndex: 1),
  ],
  List<TransactOutput> outputs = const [],
}) {
  return TransactInstructionData(
    expiryUnixTs: BigInt.one,
    txViewingPk: Uint8List(33)..[0] = 4,
    salt: Uint8List(16),
    interfaceTransfers: transfers,
    outputs: outputs,
    messages: const [],
    privateTxHash: Uint8List(32),
    circuit:
        circuit ??
        CircuitId.confidentialSigner(
          inputs: 0,
          outputs: 0,
          publicAssetSlots: 3,
        ),
    proof: TransactProof.zeroed(),
    inputs: inputs,
    treeContexts: trees,
  );
}

Future<Instruction> _build(
  TransactInstructionData data, {
  WithdrawalTarget? withdrawal,
  List<Address>? inputTrees,
  List<PublicSettlement>? settlements,
  Address? readCache,
  CacheWriter? writeCache,
}) {
  return transactInstruction(
    payer: userRegistryProgramId,
    inputTree: stateMerkleTree,
    outputTree: stateMerkleTree,
    ownerSigners: const [],
    data: data,
    withdrawal: withdrawal,
    inputTrees: inputTrees,
    settlements: settlements,
    readCache: readCache,
    writeCache: writeCache,
  );
}

void main() {
  final tee = jsonDecode(
    _fixture('tee-vectors.json').readAsStringSync(),
  ) as Map<String, Object?>;

  test(
    'settlement legs, cache selectors, and tree bounds match the Rust builder',
    () async {
      final emptyCache = CacheAccess(
        readBitmap: BigInt.zero,
        writeSlots: List.generate(
          16,
          (_) => const CacheWriteSlot(output: 0xff, slot: 0xff),
        ),
      );
      expect(
        _build(
          _data(
            circuit: CircuitId(
              kind: 4,
              inputs: 0,
              outputs: 0,
              publicAssetSlots: 3,
              cacheAccess: emptyCache,
            ),
          ),
        ),
        _code('transact_cache'),
      );
      expect(
        _build(_data(), inputTrees: const []),
        _code('invalid_shape'),
      );
      expect(
        _build(
          _data(),
          inputTrees: [stateMerkleTree, stateMerkleTree, stateMerkleTree],
        ),
        _code('invalid_shape'),
      );
      expect(
        _build(
          _data(
            inputs: [InputUtxo(nullifierHash: Uint8List(32), treeIndex: 1)],
          ),
        ),
        _code('invalid_shape'),
      );
      expect(
        _build(
          _data(
            outputs: List.generate(
              17,
              (_) => TransactOutput(
                utxoHash: Uint8List(32),
                ownerTag: InlineOwnerTag(Uint8List(32)),
              ),
            ),
          ),
        ),
        _code('invalid_length'),
      );
      expect(
        _build(
          _data(transfers: [SolWithdrawalTransfer(BigInt.one)]),
          withdrawal: const SolWithdrawalTarget(userRegistryProgramId),
          settlements: [
            SolWithdrawalSettlement(
              recipient: userRegistryProgramId,
              amount: BigInt.one,
            ),
          ],
        ),
        _code('withdrawal_mismatch'),
      );
      expect(
        _build(
          _data(),
          settlements: List.generate(
            33,
            (_) => SolDepositSettlement(
              funder: userRegistryProgramId,
              amount: BigInt.one,
            ),
          ),
        ),
        _code('invalid_length'),
      );
      final spl = await _build(
        _data(
          transfers: [
            SplDepositTransfer(BigInt.one, 3),
            SplWithdrawalTransfer(BigInt.two, 4),
          ],
          trees: const [
            TreeContext(utxoTreeRootIndex: 1, nullifierTreeRootIndex: 1),
            TreeContext(utxoTreeRootIndex: 2, nullifierTreeRootIndex: 2),
          ],
          inputs: [InputUtxo(nullifierHash: Uint8List(32), treeIndex: 1)],
        ),
        inputTrees: [stateMerkleTree, shieldedPoolProgramId],
        settlements: [
          SplDepositSettlement(
            mint: solMint,
            splInterface: stateMerkleTree,
            tokenAuthority: userRegistryProgramId,
            source: shieldedPoolProgramId,
            tokenProgram: userRegistryProgramId,
            amount: BigInt.one,
            interfaceBump: 3,
          ),
          SplWithdrawalSettlement(
            mint: solMint,
            splInterface: stateMerkleTree,
            recipientTokenAccount: shieldedPoolProgramId,
            tokenProgram: userRegistryProgramId,
            amount: BigInt.two,
            interfaceBump: 4,
          ),
        ],
      );
      expect(spl.accounts!.length, greaterThan(8));
      expect(
        _build(
          _data(transfers: [SplDepositTransfer(BigInt.one, 3)]),
          settlements: [
            SplDepositSettlement(
              mint: solMint,
              splInterface: stateMerkleTree,
              tokenAuthority: userRegistryProgramId,
              source: shieldedPoolProgramId,
              tokenProgram: userRegistryProgramId,
              amount: BigInt.one,
              interfaceBump: 9,
            ),
          ],
        ),
        _code('settlement_mismatch'),
      );
      expect(
        _build(
          _data(transfers: [SolDepositTransfer(BigInt.one)]),
          settlements: [
            SolDepositSettlement(
              funder: userRegistryProgramId,
              amount: BigInt.one,
            ),
            SolDepositSettlement(
              funder: userRegistryProgramId,
              amount: BigInt.one,
            ),
          ],
        ),
        _code('settlement_mismatch'),
      );
      expect(privateTxBlinding(Uint8List(32), Uint8List(32)).length, 32);
    },
  );

  test('a witness carries Merkle paths and the indexed envelope', () {
    final secret = Uint8List(31)..[0] = 4;
    final witness = confidentialTransferWitness(
      inputs: [
        WitnessInput(
          note: CircuitNote(
            domain: fieldU32(1),
            owner: Uint8List(32),
            asset: Uint8List(32),
            amount: fieldU32(1),
            blinding: Uint8List(32),
            dataHash: Uint8List(32),
            ringDataHash: Uint8List(32),
            ringProgramId: Uint8List(32),
          ),
          treeSlot: fieldU32(0),
          treeId: fieldU32(0),
          ownerPublicKeyHash: Uint8List(32),
          nullifierSecret: secret,
          isDummy: true,
          statePathElements: [Uint8List(32)..[0] = 1],
          statePathIndex: fieldU32(2),
          nullifierLowValue: Uint8List(32),
          nullifierNextValue: Uint8List(32)..[0] = 2,
          nullifierLowPathElements: [Uint8List(32)],
          nullifierLowPathIndex: fieldU32(1),
        ),
      ],
      outputs: [
        WitnessOutput(
          note: CircuitNote(
            domain: fieldU32(1),
            owner: Uint8List(32),
            asset: Uint8List(32),
            amount: fieldU32(1),
            blinding: Uint8List(32),
            dataHash: Uint8List(32),
            ringDataHash: Uint8List(32),
            ringProgramId: Uint8List(32),
          ),
          treeId: fieldU32(0),
          ownerPublicKeyHash: Uint8List(32),
          nullifierPublicKey: Uint8List(32),
          isDummy: true,
        ),
      ],
      outputTreeId: Uint8List(32),
      externalDataHash: Uint8List(32),
      privateTxHash: Uint8List(32),
      blindingSeed: Uint8List(32),
      ringProgramId: Uint8List(32),
      publicAssets: const [],
      publicAmounts: const [],
      signerPublicKeyHashes: const [],
      inputFlags: Uint8List(32),
      publishedOutputOwnerPublicKeyHashes: const [],
      cacheTreeId: Uint8List(32),
      cacheReadHashChain: Uint8List(32),
      cacheReadHashes: const [],
      cacheIsCached: const [],
      cacheReadIndex: const [],
    );
    final input = (witness['inputs']! as List).first as Map;
    expect(input['statePathElements'], isNotEmpty);
    expect(input['nullifierLowPathIndex'], isNotNull);
    final indexed = indexedProofRequest(
      prepared: witness,
      trees: [(tree: _b58(Uint8List(32)), id: 1)],
      lookups: [
        (treeSlot: 0, commitment: _b58(Uint8List(32)), nullifier: null),
      ],
      publicInputs: [Uint8List(32)],
      minContextSlot: BigInt.from(9),
    );
    expect(indexed['minContextSlot'], 9);
    expect((indexed['publicInputs']! as List).single, '0x0');
  });

  test('spent leaves and nullifiers leave the balance once', () async {
    final left = PrivateNote(
      amount: BigInt.one,
      mint: solMint,
      signature: 'sig',
      treeId: 4,
      leafIndex: BigInt.two,
      blinding: Uint8List(32)..[0] = 1,
      commitment: Uint8List(32)..[0] = 1,
    );
    final same = PrivateNote(
      amount: BigInt.one,
      mint: solMint,
      signature: 'sig',
      treeId: 4,
      leafIndex: BigInt.two,
      blinding: Uint8List.fromList(left.blinding!),
      commitment: Uint8List.fromList(left.commitment!),
    );
    final duplicated = combineBalanceReports(
      PrivateBalanceReport(notes: [left, same], balances: const [], skipped: 0),
      const PrivateBalanceReport(notes: [], balances: [], skipped: 0),
    );
    expect(duplicated.balances.single.notes, 1);
    expect(
      () => combineBalanceReports(
        PrivateBalanceReport(
          notes: [
            left,
            PrivateNote(
              amount: BigInt.one,
              mint: solMint,
              signature: 'sig',
              treeId: 4,
              leafIndex: BigInt.two,
              blinding: Uint8List(4),
              commitment: Uint8List(32),
            ),
          ],
          balances: const [],
          skipped: 0,
        ),
        const PrivateBalanceReport(notes: [], balances: [], skipped: 0),
      ),
      _code('conflicting_leaf'),
    );
    expect(
      () => combineBalanceReports(
        PrivateBalanceReport(
          notes: [
            left,
            PrivateNote(
              amount: BigInt.one,
              mint: solMint,
              signature: 'sig',
              treeId: 4,
              leafIndex: BigInt.two,
              blinding: Uint8List(32)..[0] = 9,
              commitment: Uint8List.fromList(left.commitment!),
            ),
          ],
          balances: const [],
          skipped: 0,
        ),
        const PrivateBalanceReport(notes: [], balances: [], skipped: 0),
      ),
      _code('conflicting_leaf'),
    );
    expect(SpentLeaf(1, BigInt.one), SpentLeaf(1, BigInt.one));
    expect(SpentLeaf(1, BigInt.one) == Object(), isFalse);
    expect(
      SpentLeaf(1, BigInt.one).hashCode,
      SpentLeaf(1, BigInt.one).hashCode,
    );
    expect(SpentLeaf(2, BigInt.one) == SpentLeaf(1, BigInt.one), isFalse);

    final hash = Uint8List(32)..[0] = 7;
    final otherHash = Uint8List(32)..[0] = 8;
    final blinding = Uint8List(32)..[1] = 3;
    final secret = Uint8List(31)..[2] = 5;
    final key = NullifierKey.fromSecret(secret);
    final spentNullifier = key.nullifier(hash, blinding);
    final body = Uint8List.fromList([
      ...Uint8List(32),
      ...blinding,
      ...getAddressEncoder().encode(solMint),
      ...Uint8List(8)..buffer.asByteData().setUint64(0, 4, Endian.little),
      0,
      0,
      0,
      0,
      0,
      0,
    ]);
    OutputSlot slot(Uint8List commitment, int leaf) {
      return OutputSlot(
        viewTag: _b58(Uint8List(32)),
        outputContext: OutputContext(
          treeId: 1,
          hash: _b58(commitment),
          tree: stateMerkleTree,
          leafIndex: BigInt.from(leaf),
        ),
        payload: _frame(body),
      );
    }

    final signature = _b58(Uint8List(64)..[0] = 1);
    final kept = await readProoflessDeposits(
      [
        EncryptedUtxoMatch(
          slot: BigInt.one,
          txSignature: signature,
          outputSlot: slot(hash, 0),
        ),
        EncryptedUtxoMatch(
          slot: BigInt.one,
          txSignature: signature,
          outputSlot: slot(hash, 0),
        ),
        EncryptedUtxoMatch(
          slot: BigInt.one,
          txSignature: signature,
          outputSlot: slot(otherHash, 1),
        ),
      ],
      spent: {SpentLeaf(1, BigInt.one)},
    );
    expect(kept.notes, hasLength(3));
    expect(kept.balances.single.amount, BigInt.from(4));
    expect(kept.balances.single.notes, 1);

    final rings = PrivacyRings(
      indexerUrl: Uri.parse('http://127.0.0.1:8784'),
      proverUrl: Uri.parse('http://127.0.0.1:3001'),
      httpClient: MockClient((request) async {
        final decoded = jsonDecode(request.body) as Map<String, Object?>;
        final deposits = decoded['method'] == 'getEncryptedUtxosByTags';
        final output = {
          'viewTag': _b58(Uint8List(32)),
          'payload': base64Encode(_frame(body)),
          'outputContext': {
            'treeId': 1,
            'hash': _b58(hash),
            'tree': _b58(getAddressEncoder().encode(stateMerkleTree)),
            'leafIndex': 0,
          },
        };
        final other = {
          'viewTag': _b58(Uint8List(32)),
          'payload': base64Encode(_frame(body)),
          'outputContext': {
            'treeId': 1,
            'hash': _b58(otherHash),
            'tree': _b58(getAddressEncoder().encode(stateMerkleTree)),
            'leafIndex': 2,
          },
        };
        return http.Response(
          jsonEncode({
            'jsonrpc': '2.0',
            'id': decoded['id'],
            'result': {
              'context': {'blockTime': 1, 'slot': 2},
              'paginationToken': null,
              'data': [
                {
                  'slot': 1,
                  'signature': signature,
                  if (deposits)
                    'outputs': [
                      {
                        'slot': 1,
                        'txSignature': signature,
                        'outputSlot': output,
                      },
                      {
                        'slot': 1,
                        'txSignature': signature,
                        'outputSlot': other,
                      },
                    ]
                  else
                    'events': [
                      {
                        'slot': 1,
                        'txSignature': signature,
                        'outputSlots': <Object?>[],
                        'messages': <Object?>[],
                        'nullifiers': [_b58(spentNullifier)],
                        'proofless': false,
                      },
                    ],
                },
              ],
            },
          }),
          200,
        );
      }),
    );
    final report = await rings.readPrivateBalance(
      viewingKey: ViewingKey.fromBytes(Uint8List(32)..[0] = 1),
      tags: [_b58(Uint8List(32)..[0] = 9)],
      nullifierKey: key,
      spentLeaves: {SpentLeaf(1, BigInt.zero)},
    );
    expect(report.notes, hasLength(1));
    expect(report.balances.single.amount, BigInt.from(4));
  });

  test('nullifier maps and non-inclusion proofs filter the same leaves', () {
    final spentLeaf = PrivateNote(
      amount: BigInt.one,
      mint: solMint,
      signature: 'sig',
      treeId: 1,
      leafIndex: BigInt.two,
    );
    final open = PrivateNote(
      amount: BigInt.one,
      mint: solMint,
      signature: 'sig',
      treeId: 1,
      leafIndex: BigInt.from(3),
    );
    final unnamed = PrivateNote(
      amount: BigInt.one,
      mint: solMint,
      signature: 'sig',
    );
    final nine = Uint8List(32)..[0] = 9;
    final eight = Uint8List(32)..[0] = 8;
    final derived = {
      SpentLeaf(1, BigInt.two): nine,
      SpentLeaf(1, BigInt.from(3)): eight,
    };
    final dropped = subtractNullifiedNotes(
      [spentLeaf, open, unnamed],
      {SpentLeaf(1, BigInt.two): nine},
      [nine],
    );
    expect(dropped, hasLength(2));
    final kept = retainNonInclusion([spentLeaf, open], derived, [nine]);
    expect(kept, hasLength(1));
    expect(kept.single.leafIndex, BigInt.two);
    expect(
      retainNonInclusion(
        [spentLeaf, unnamed],
        {
          SpentLeaf(1, BigInt.two): nine,
        },
        [nine],
      ),
      hasLength(2),
    );
  });

  test('HPKE rejects a short or unauthenticated ciphertext', () async {
    final ikm = _hex(tee['ikm']! as String);
    await expectLater(
      openProverCiphertext(
        ikm: ikm,
        enc: _hex(tee['enc']! as String),
        ciphertext: Uint8List(8),
        method: 'POST',
        requestUri: tee['request_uri']! as String,
      ),
      _code('tee_encryption'),
    );
    final tampered = _hex(tee['ciphertext']! as String)..last ^= 1;
    await expectLater(
      openProverCiphertext(
        ikm: ikm,
        enc: _hex(tee['enc']! as String),
        ciphertext: tampered,
        method: tee['method']! as String,
        requestUri: tee['request_uri']! as String,
      ),
      _code('tee_encryption'),
    );
    final key = _hex(tee['response_key']! as String);
    final nonce = Uint8List(12)..[0] = 1;
    final box = await AesGcm.with256bits().encrypt(
      [1],
      secretKey: SecretKey(key),
      nonce: nonce,
    );
    await expectLater(
      decryptProverResponse(
        key,
        Uint8List.fromList([
          ...box.nonce,
          ...box.cipherText,
          ...box.mac.bytes,
        ]),
      ),
      _code('tee_encryption'),
    );
  });

  test(
    'an attested session opens an encrypted response and rejects a bad quote',
    () async {
      final ikm = _hex(tee['ikm']! as String);
      final seed = Uint8List(32)..[0] = 6;
      final policy = nitroPolicy();
      var attestations = 0;
      Future<http.Response> quote(http.Request request) async {
        attestations++;
        final nonce = _hex(request.url.queryParameters['nonce']!);
        final key = await proverRecipientPublicKey(ikm);
        return http.Response(
          jsonEncode(nitroAttestation(nonce: nonce, hpke: key)),
          200,
        );
      }

      Future<http.Response> sealed(
        http.Request request,
        List<int> clear,
      ) async {
        final key = await proverRecipientPublicKey(ikm);
        final preview = await encryptProverRequest(
          hpkePublicKey: key,
          method: request.method,
          requestUri: request.url.hasQuery
              ? '${request.url.path}?${request.url.query}'
              : request.url.path,
          plaintext: request.method == 'GET'
              ? utf8.encode('')
              : request.bodyBytes,
          ephemeralSeed: seed,
        );
        final box = await AesGcm.with256bits().encrypt(
          clear,
          secretKey: SecretKey(preview.responseKey),
          nonce: Uint8List(12)..[0] = 2,
        );
        return http.Response.bytes(
          Uint8List.fromList([
            ...box.nonce,
            ...box.cipherText,
            ...box.mac.bytes,
          ]),
          200,
          headers: {'spr-tee': 'v1'},
        );
      }

      final session = TeeSession(policy, ephemeralSeed: seed);
      final client = MockClient((request) async {
        if (request.url.path.endsWith('/attestation')) return quote(request);
        return sealed(request, [0, 200, ...utf8.encode('{"ok":true}')]);
      });
      final url = Uri.parse(
        'http://127.0.0.1:3001/prove/transfer_confidential_1_2',
      );
      final first = await session.send(
        client: client,
        attestationUrl: Uri.parse('http://127.0.0.1:3001/attestation'),
        url: url,
        route: url.path,
        method: 'POST',
        headers: const {},
        body: '{}',
      );
      expect(utf8.decode(first.bodyBytes), '{"ok":true}');
      final second = await session.send(
        client: client,
        attestationUrl: Uri.parse('http://127.0.0.1:3001/attestation'),
        url: url,
        route: url.path,
        method: 'GET',
        headers: const {},
      );
      expect(second.statusCode, 200);
      expect(attestations, 1);

      await expectLater(
        session.send(
          client: MockClient((request) async {
            if (request.url.path.endsWith('/attestation')) {
              return quote(request);
            }
            return http.Response('clear', 200);
          }),
          attestationUrl: Uri.parse('http://127.0.0.1:3001/attestation'),
          url: url,
          route: url.path,
          method: 'POST',
          headers: const {},
          body: '{}',
        ),
        _code('tee_encryption'),
      );

      final fresh = TeeSession(policy, ephemeralSeed: seed);
      var failed = false;
      final retried = await fresh.send(
        client: MockClient((request) async {
          if (request.url.path.endsWith('/attestation')) return quote(request);
          if (!failed) {
            failed = true;
            return http.Response('tee_decryption_failed', 400);
          }
          return sealed(request, [0, 200, ...utf8.encode('{"ok":true}')]);
        }),
        attestationUrl: Uri.parse('http://127.0.0.1:3001/attestation'),
        url: url,
        route: url.path,
        method: 'POST',
        headers: const {},
        body: '{}',
      );
      expect(retried.statusCode, 200);
      await expectLater(
        fresh.send(
          client: MockClient((request) async {
            if (request.url.path.endsWith('/attestation')) {
              return quote(request);
            }
            return sealed(request, [0, 50]);
          }),
          attestationUrl: Uri.parse('http://127.0.0.1:3001/attestation'),
          url: url,
          route: url.path,
          method: 'POST',
          headers: const {},
          body: '{}',
        ),
        _code('tee_encryption'),
      );

      Future<void> reject(
        String code,
        Map<String, Object?> Function(Uint8List nonce, Uint8List key) body,
      ) {
        return expectLater(
          TeeSession(policy).attest(
            Uri.parse('http://127.0.0.1:3001/attestation'),
            MockClient((request) async {
              final nonce = _hex(request.url.queryParameters['nonce']!);
              final key = await proverRecipientPublicKey(ikm);
              return http.Response(jsonEncode(body(nonce, key)), 200);
            }),
          ),
          _code(code),
        );
      }

      await expectLater(
        TeeSession(policy).attest(
          Uri.parse('http://127.0.0.1:3001/attestation'),
          MockClient((_) async => http.Response('no', 500)),
        ),
        _code('tee_unavailable'),
      );
      await expectLater(
        TeeSession(policy).attest(
          Uri.parse('http://127.0.0.1:3001/attestation'),
          MockClient((_) async => http.Response('no', 200)),
        ),
        _code('malformed_attestation'),
      );
      await expectLater(
        TeeSession(policy).attest(
          Uri.parse('http://127.0.0.1:3001/attestation'),
          MockClient((_) async => http.Response('[]', 200)),
        ),
        _code('malformed_attestation'),
      );
      await expectLater(
        TeeSession(policy).attest(
          Uri.parse('http://127.0.0.1:3001/attestation'),
          MockClient((_) async => http.Response('{"attestation":[]}', 200)),
        ),
        _code('malformed_attestation'),
      );
      await reject('tee_platform', (nonce, key) {
        return {
          ...nitroAttestation(nonce: nonce, hpke: key),
          'platform': 'other',
        };
      });
      await reject('measurement', (nonce, key) {
        return nitroAttestation(
          nonce: nonce,
          hpke: key,
          pcr0: Uint8List(48)..[0] = 9,
        );
      });
      await expectLater(
        TeeSession(
          nitroPolicy(imageIds: [Uint8List(48)..[0] = 9]),
        ).attest(
          Uri.parse('http://127.0.0.1:3001/attestation'),
          MockClient((request) async {
            final nonce = _hex(request.url.queryParameters['nonce']!);
            final key = await proverRecipientPublicKey(ikm);
            return http.Response(
              jsonEncode(nitroAttestation(nonce: nonce, hpke: key)),
              200,
            );
          }),
        ),
        _code('tee_image'),
      );
      await reject('malformed_attestation', (nonce, key) {
        return {
          'platform': 'aws-nitro',
          'hpke_public_key': _hexOf(key),
          'gpu': 1,
        };
      });
      await reject('tee_report', (nonce, key) {
        return nitroAttestation(
          nonce: nonce,
          hpke: key,
          userData: Uint8List(64),
        );
      });
      await reject('malformed_attestation', (nonce, key) {
        return {
          'platform': 'aws-nitro',
          'hpke_public_key': 'abc',
          'gpu': null,
        };
      });
      await reject('malformed_attestation', (nonce, key) {
        return {
          'platform': 'aws-nitro',
          'hpke_public_key': 'aa',
          'gpu': null,
        };
      });
      expect(() => nitroPolicy(gpu: 'required'), _code('invalid_config'));
      expect(
        () => TeePolicy(
          platform: 'other',
          imageIds: [nitroPcr0],
          measurements: [nitroMeasurement()],
        ),
        _code('invalid_config'),
      );
      expect(
        () => TeePolicy(
          platform: 'aws-nitro',
          imageIds: [nitroPcr0],
          measurements: const [],
        ),
        _code('invalid_config'),
      );
      expect(
        () => TeePolicy(
          platform: 'aws-nitro',
          imageIds: [nitroPcr0],
          measurements: [nitroMeasurement()],
          anchors: const [],
        ),
        _code('invalid_config'),
      );
      await reject('malformed_attestation', (nonce, key) {
        return {
          'platform': 'aws-nitro',
          'hpke_public_key': _hexOf(key),
        };
      });
      await reject('malformed_attestation', (nonce, key) {
        return {
          'platform': 'aws-nitro',
          'hpke_public_key': _hexOf(key),
          'gpu': null,
        };
      });
      await reject('malformed_attestation', (nonce, key) {
        return nitroAttestation(nonce: nonce, hpke: key, gpu: 'device');
      });
      final quoted = await TeeSession(policy).attest(
        Uri.parse('http://127.0.0.1:3001/attestation'),
        MockClient((request) async {
          final nonce = _hex(request.url.queryParameters['nonce']!);
          final key = await proverRecipientPublicKey(ikm);
          return http.Response(
            jsonEncode({
              'attestation': nitroAttestation(nonce: nonce, hpke: key),
            }),
            200,
          );
        }),
      );
      expect(quoted.gpuVerified, isFalse);
      expect(
        () => nitroPolicy(gpu: 'maybe'),
        _code('invalid_config'),
      );
      final expired = nitroPolicy(maxAge: Duration.zero);
      var expiredQuotes = 0;
      final expiring = TeeSession(expired, ephemeralSeed: seed);
      final expiringClient = MockClient((request) async {
        if (request.url.path.endsWith('/attestation')) {
          expiredQuotes++;
          return quote(request);
        }
        return sealed(request, [0, 200, ...utf8.encode('{"ok":true}')]);
      });
      await expiring.send(
        client: expiringClient,
        attestationUrl: Uri.parse('http://127.0.0.1:3001/attestation'),
        url: url,
        route: url.path,
        method: 'POST',
        headers: const {},
        body: '{}',
      );
      await expiring.send(
        client: expiringClient,
        attestationUrl: Uri.parse('http://127.0.0.1:3001/attestation'),
        url: url,
        route: url.path,
        method: 'POST',
        headers: const {},
        body: '{}',
      );
      expect(expiredQuotes, 2);
    },
  );

  test('a TeeSession proves against a remote https prover', () async {
    final ikm = _hex(tee['ikm']! as String);
    final seed = Uint8List(32)..[0] = 3;
    final policy = nitroPolicy();
    final session = TeeSession(policy, ephemeralSeed: seed);
    final pin = provingKeySha256('transfer_confidential_1_2');
    var posts = 0;
    Future<http.Response> sealed(http.Request request, String json) async {
      final key = await proverRecipientPublicKey(ikm);
      final preview = await encryptProverRequest(
        hpkePublicKey: key,
        method: request.method,
        requestUri: request.url.hasQuery
            ? '${request.url.path}?${request.url.query}'
            : request.url.path,
        plaintext: utf8.encode(''),
        ephemeralSeed: seed,
      );
      final box = await AesGcm.with256bits().encrypt(
        [0, 200, ...utf8.encode(json)],
        secretKey: SecretKey(preview.responseKey),
        nonce: Uint8List(12)..[0] = 4,
      );
      return http.Response.bytes(
        Uint8List.fromList([
          ...box.nonce,
          ...box.cipherText,
          ...box.mac.bytes,
        ]),
        200,
        headers: {'spr-tee': 'v1'},
      );
    }

    final proof = jsonEncode({
      'ar': ['0x1', '0x2'],
      'bs': [
        ['0x0', '0x0'],
        ['0x0', '0x0'],
      ],
      'krs': ['0x1', '0x2'],
      'provingKeySha256': pin,
    });
    final client = MockClient((request) async {
      if (request.url.path.endsWith('/attestation')) {
        final nonce = _hex(request.url.queryParameters['nonce']!);
        final key = await proverRecipientPublicKey(ikm);
        return http.Response(
          jsonEncode(nitroAttestation(nonce: nonce, hpke: key)),
          200,
        );
      }
      posts++;
      if (posts == 1) {
        return sealed(request, '{"jobId":"job-1"}');
      }
      return sealed(
        request,
        jsonEncode({
          'status': 'completed',
          'result': jsonDecode(proof),
        }),
      );
    });
    final prover = PrivacyProverClient(
      endpoint: Uri.parse('https://prover.example/v1/spr'),
      httpClient: client,
      tee: session,
      pollInterval: Duration.zero,
      maxPollInterval: Duration.zero,
    );
    final proved = await prover.prove(
      circuit: 'transfer_confidential_1_2',
      witness: const {'circuitType': 'transfer-confidential'},
    );
    expect(proved.a[31], 1);
    expect(posts, 2);
    expect(
      () => PrivacyProverClient(
        endpoint: Uri.parse('http://prover.example/v1/spr'),
        tee: TeeSession(policy),
      ).prove(circuit: 'transfer_confidential_1_2', witness: const {}),
      _code('invalid_config'),
    );
  });
}
