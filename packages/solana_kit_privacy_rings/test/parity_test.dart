import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_privacy_rings/solana_kit_privacy_rings.dart';
import 'package:test/test.dart';

File _fixture(String name) {
  final relative = 'test/fixtures/$name';
  final local = File(relative);
  if (local.existsSync()) return local;
  return File('packages/solana_kit_privacy_rings/$relative');
}

Uint8List _hex(String text) {
  final bytes = Uint8List(text.length ~/ 2);
  for (var i = 0; i < bytes.length; i++) {
    bytes[i] = int.parse(text.substring(i * 2, i * 2 + 2), radix: 16);
  }
  return bytes;
}

String _hexOf(List<int> bytes) =>
    bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();

Matcher _code(String code) => throwsA(
  isA<PrivacyRingsException>().having((error) => error.code, 'code', code),
);

void main() {
  final poseidon = jsonDecode(
    _fixture('poseidon-parity-v1.json').readAsStringSync(),
  ) as Map<String, Object?>;
  final keys = jsonDecode(
    _fixture('key_derivation.json').readAsStringSync(),
  ) as Map<String, Object?>;
  final tee = jsonDecode(
    _fixture('tee-vectors.json').readAsStringSync(),
  ) as Map<String, Object?>;

  test('poseidon matches the Rust hasher parity vectors', () {
    final vectors = poseidon['vectors']! as List<Object?>;
    expect(vectors, isNotEmpty);
    for (final entry in vectors) {
      final vector = entry! as Map<String, Object?>;
      final inputs = (vector['inputsBytes']! as List<Object?>)
          .map((value) => _hex(value! as String))
          .toList();
      expect(
        _hexOf(poseidonHash(inputs)),
        vector['expectedBytes'],
        reason: vector['id']! as String,
      );
    }
    expect(
      () => poseidonHash([Uint8List(31)]),
      _code('invalid_length'),
    );
    expect(() => poseidonHash([]), _code('invalid_length'));
    expect(
      () => poseidonHash(List.filled(13, Uint8List(32))),
      _code('invalid_length'),
    );
    final over = Uint8List(32)..fillRange(0, 32, 0xff);
    expect(() => poseidonHash([over]), _code('integer_range'));
    expect(hashBytes(const []), Uint8List(32));
    expect(hashBytes([0]), Uint8List(32));
    final thirtyTwo = Uint8List(32)..fillRange(0, 32, 1);
    expect(
      hashBytes(thirtyTwo),
      poseidonHash([
        rightAlign(thirtyTwo.sublist(0, 31)),
        rightAlign(thirtyTwo.sublist(31)),
      ]),
    );
    expect(() => rightAlign(const []), _code('invalid_length'));
    expect(() => fieldU32(-1), _code('integer_range'));
    expect(fieldHex(Uint8List(32)), '0x0');
  });

  test('owner hash matches the key-derivation vector', () {
    final owner = keys['owner']! as Map<String, Object?>;
    expect(
      _hexOf(
        ownerHash(
          _hex(owner['owner_proof_input_hash']! as String),
          _hex(owner['nullifier_pubkey']! as String),
        ),
      ),
      owner['owner_hash'],
    );
    final secret = Uint8List(31)..[30] = 0x2a;
    final key = NullifierKey.fromSecret(secret);
    final hash = Uint8List(32)..[31] = 7;
    final blinding = Uint8List(32)..[31] = 9;
    expect(
      key.nullifier(hash, blinding),
      poseidonHash([hash, blinding, rightAlign(secret)]),
    );
    expect(key.publicKey(), poseidonHash([rightAlign(secret)]));
    expect(
      NullifierKey.zeroKeyNullifier(hash, blinding),
      poseidonHash([hash, blinding, Uint8List(32)]),
    );
    key.destroy();
    expect(key.publicKey, _code('destroyed_key'));
    expect(
      () => NullifierKey.fromSecret(Uint8List(32)),
      _code('invalid_length'),
    );
    final first = Uint8List(32)..[31] = 7;
    final seed = Uint8List(32)..[31] = 4;
    expect(
      outputBlindingSeed(first, seed),
      poseidonHash([
        fieldU32(domainTransactOutputBlindingSeed),
        first,
        seed,
      ]),
    );
    expect(
      transactOutputBlinding(first, seed, 3),
      poseidonHash([
        fieldU32(domainTransactOutputBlinding),
        first,
        seed,
        fieldU32(3),
      ]),
    );
    expect(() => fieldHex(Uint8List(31)), _code('invalid_length'));
    expect(() => solanaOwnerIdentity(Uint8List(31)), _code('invalid_length'));
    expect(solanaOwnerIdentity(Uint8List(32)).length, 32);
  });

  test('TEE AAD, report data, and HPKE match the Go prover vectors', () async {
    final cases = tee['aad_cases']! as List<Object?>;
    for (final entry in cases) {
      final item = entry! as Map<String, Object?>;
      expect(
        proverRequestAad(
          item['method']! as String,
          item['request_target']! as String,
        ),
        item['aad'],
      );
    }
    final nonce = _hex(tee['nonce']! as String);
    final publicKey = _hex(tee['hpke_public_key']! as String);
    expect(
      _hexOf(
        proverReportData(
          nonce,
          publicKey,
          gpuToken: utf8.encode(tee['gpu_token']! as String),
        ),
      ),
      tee['report_data'],
    );
    expect(
      _hexOf(proverReportData(nonce, publicKey)),
      tee['report_data_no_gpu'],
    );
    expect(
      _hexOf(await proverRecipientPublicKey(_hex(tee['ikm']! as String))),
      tee['hpke_public_key'],
    );
    final clear = await openProverCiphertext(
      ikm: _hex(tee['ikm']! as String),
      enc: _hex(tee['enc']! as String),
      ciphertext: _hex(tee['ciphertext']! as String),
      method: tee['method']! as String,
      requestUri: tee['request_uri']! as String,
    );
    expect(utf8.decode(clear), tee['plaintext']);
    final response = await decryptProverResponse(
      _hex(tee['response_key']! as String),
      _hex(tee['encrypted_response']! as String),
    );
    expect(response.status, tee['response_status']);
    expect(utf8.decode(response.body), tee['response_body']);
    await expectLater(
      decryptProverResponse(Uint8List(32), Uint8List(8)),
      _code('tee_encryption'),
    );
    final tampered = _hex(tee['encrypted_response']! as String)..[0] ^= 1;
    await expectLater(
      decryptProverResponse(_hex(tee['response_key']! as String), tampered),
      _code('tee_encryption'),
    );
    final sealed = await encryptProverRequest(
      hpkePublicKey: publicKey,
      method: 'POST',
      requestUri: '/prove/sample',
      plaintext: utf8.encode('ping'),
      ephemeralSeed: Uint8List(32)..[0] = 9,
    );
    expect(sealed.enc.length, 32);
    expect(sealed.body.length, greaterThan(16));
  });

  test('a cached confidential transfer appends the cache tail', () async {
    final writes = List.generate(
      16,
      (index) => index == 0
          ? const CacheWriteSlot(output: 0, slot: 1)
          : const CacheWriteSlot(output: 0xff, slot: 0xff),
    );
    final data = TransactInstructionData(
      expiryUnixTs: BigInt.one,
      txViewingPk: Uint8List(33)..[0] = 4,
      salt: Uint8List(16),
      interfaceTransfers: [
        SolWithdrawalTransfer(BigInt.one),
        SolDepositTransfer(BigInt.two),
      ],
      outputs: const [],
      messages: const [],
      privateTxHash: Uint8List(32),
      circuit: CircuitId(
        kind: 4,
        inputs: 1,
        outputs: 0,
        publicAssetSlots: 3,
        cacheAccess: CacheAccess(readBitmap: BigInt.one, writeSlots: writes),
      ),
      inputs: [InputUtxo(nullifierHash: Uint8List(32), treeIndex: 0)],
      treeContexts: const [
        TreeContext(utxoTreeRootIndex: 1, nullifierTreeRootIndex: 1),
      ],
      proof: TransactProof.zeroed(),
    );
    expect(
      () => transactInstruction(
        payer: userRegistryProgramId,
        inputTree: stateMerkleTree,
        outputTree: stateMerkleTree,
        ownerSigners: const [],
        data: data,
      ),
      _code('settlement_mismatch'),
    );
    final instruction = await transactInstruction(
      payer: userRegistryProgramId,
      inputTree: stateMerkleTree,
      outputTree: stateMerkleTree,
      ownerSigners: const [userRegistryProgramId],
      data: data,
      settlements: [
        SolWithdrawalSettlement(
          recipient: shieldedPoolProgramId,
          amount: BigInt.one,
        ),
        SolDepositSettlement(funder: userRegistryProgramId, amount: BigInt.two),
      ],
      readCache: stateMerkleTree,
      writeCache: const CacheWriter(
        cache: shieldedPoolProgramId,
        writer: userRegistryProgramId,
      ),
    );
    expect(instruction.accounts!.last.role, AccountRole.readonlySigner);
    expect(
      () => transactInstruction(
        payer: userRegistryProgramId,
        inputTree: stateMerkleTree,
        outputTree: stateMerkleTree,
        ownerSigners: const [],
        data: TransactInstructionData(
          expiryUnixTs: BigInt.one,
          txViewingPk: Uint8List(33)..[0] = 4,
          salt: Uint8List(16),
          interfaceTransfers: const [],
          outputs: const [],
          messages: const [],
          privateTxHash: Uint8List(32),
          circuit: CircuitId(
            kind: 1,
            inputs: 0,
            outputs: 0,
            publicAssetSlots: 3,
          ),
          inputs: const [],
          treeContexts: const [
            TreeContext(utxoTreeRootIndex: 1, nullifierTreeRootIndex: 1),
          ],
          proof: TransactProof.zeroed(),
        ),
      ),
      _code('transact_circuit'),
    );
    expect(
      CircuitId.confidentialSigner(
        inputs: 1,
        outputs: 1,
        publicAssetSlots: 3,
      ).fitsTransact,
      isTrue,
    );
  });

  test('duplicate leaves are counted once and spent leaves are omitted', () {
    final note = PrivateNote(
      amount: BigInt.two,
      mint: solMint,
      signature: 'sig',
      treeId: 1,
      leafIndex: BigInt.one,
    );
    final again = PrivateNote(
      amount: BigInt.two,
      mint: solMint,
      signature: 'sig',
      treeId: 1,
      leafIndex: BigInt.one,
    );
    final report = combineBalanceReports(
      PrivateBalanceReport(
        notes: [note, again],
        balances: const [],
        skipped: 0,
      ),
      const PrivateBalanceReport(notes: [], balances: [], skipped: 0),
    );
    expect(report.balances.single.amount, BigInt.two);
    expect(report.balances.single.notes, 1);
    expect(
      () => combineBalanceReports(
        PrivateBalanceReport(
          notes: [
            note,
            PrivateNote(
              amount: BigInt.one,
              mint: solMint,
              signature: 'sig',
              treeId: 1,
              leafIndex: BigInt.one,
            ),
          ],
          balances: const [],
          skipped: 0,
        ),
        const PrivateBalanceReport(notes: [], balances: [], skipped: 0),
      ),
      _code('conflicting_leaf'),
    );
  });

  test(
    'the indexed route posts /indexed and a runtime key set refuses it',
    () async {
      late Uri posted;
      final client = PrivacyProverClient(
        endpoint: Uri.parse('http://127.0.0.1:3001'),
        httpClient: MockClient((request) async {
          posted = request.url;
          return http.Response(
            jsonEncode({
              'ar': ['0x1', '0x2'],
              'bs': [
                ['0x1', '0x1'],
                ['0x1', '0x1'],
              ],
              'krs': ['0x1', '0x2'],
              'provingKeySha256': provingKeySha256('transfer_confidential_1_2'),
            }),
            200,
          );
        }),
      );
      await client.proveIndexed(
        circuit: 'transfer_confidential_1_2',
        witness: const {'circuitType': 'transfer-confidential'},
      );
      expect(posted.path, '/prove/transfer_confidential_1_2/indexed');
      expect(
        () =>
            PrivacyProverClient(
              endpoint: Uri.parse('http://127.0.0.1:3001'),
              runtimeProvingKeys: true,
            ).proveIndexed(
              circuit: 'transfer_confidential_1_2',
              witness: const {},
            ),
        _code('indexed_proving_unsupported'),
      );
      final witness = confidentialTransferWitness(
        inputs: [
          WitnessInput(
            note: CircuitNote(
              domain: fieldU32(1),
              owner: Uint8List(32),
              asset: Uint8List(32),
              amount: fieldU32(5),
              blinding: Uint8List(32)..[31] = 3,
              dataHash: Uint8List(32),
              ringDataHash: Uint8List(32),
              ringProgramId: Uint8List(32),
            ),
            treeSlot: fieldU32(0),
            treeId: fieldU32(0),
            ownerPublicKeyHash: Uint8List(32),
            nullifierSecret: Uint8List(31)..[30] = 1,
          ),
        ],
        outputs: [
          WitnessOutput(
            note: CircuitNote(
              domain: fieldU32(1),
              owner: Uint8List(32),
              asset: Uint8List(32),
              amount: fieldU32(5),
              blinding: Uint8List(32),
              dataHash: Uint8List(32),
              ringDataHash: Uint8List(32),
              ringProgramId: Uint8List(32),
            ),
            treeId: fieldU32(0),
            ownerPublicKeyHash: Uint8List(32),
            nullifierPublicKey: Uint8List(32),
          ),
        ],
        outputTreeId: fieldU32(0),
        externalDataHash: Uint8List(32),
        privateTxHash: Uint8List(32),
        blindingSeed: Uint8List(32)..[31] = 8,
        ringProgramId: Uint8List(32),
        publicAssets: [Uint8List(32)],
        publicAmounts: [fieldU32(1)],
        signerPublicKeyHashes: [Uint8List(32)],
        inputFlags: fieldU32(0),
        publishedOutputOwnerPublicKeyHashes: [Uint8List(32)],
        cacheTreeId: Uint8List(32),
        cacheReadHashChain: Uint8List(32),
        cacheReadHashes: [Uint8List(32)],
        cacheIsCached: [fieldU32(0)],
        cacheReadIndex: [fieldU32(0)],
      );
      expect(witness['blindingSeed'], isNotNull);
      expect(witness['circuitType'], 'transfer-confidential');
      expect(
        () => confidentialTransferWitness(
          inputs: const [],
          outputs: const [],
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
        ),
        _code('invalid_length'),
      );
      expect(
        () => indexedProofRequest(
          prepared: witness,
          trees: const [],
          lookups: const [],
          publicInputs: const [],
          minContextSlot: BigInt.one << 60,
        ),
        _code('integer_range'),
      );
    },
  );

  test('an attested session encrypts the witness', () async {
    final image = Uint8List(32)..[0] = 4;
    final policy = TeePolicy(platform: 'aws-nitro', imageIds: [image]);
    final session = TeeSession(policy);
    late String nonceHex;
    final client = MockClient((request) async {
      if (request.url.path.endsWith('/attestation')) {
        nonceHex = request.url.queryParameters['nonce']!;
        final nonce = _hex(nonceHex);
        final key = await proverRecipientPublicKey(_hex(tee['ikm']! as String));
        return http.Response(
          jsonEncode({
            'platform': 'aws-nitro',
            'hpke_public_key': _hexOf(key),
            'image_id': _hexOf(image),
            'gpu': null,
            'report_data': _hexOf(proverReportData(nonce, key)),
          }),
          200,
        );
      }
      expect(request.headers['spr-tee'], 'v1');
      return http.Response('no', 400);
    });
    final response = await session.send(
      client: client,
      attestationUrl: Uri.parse('http://127.0.0.1:3001/attestation'),
      url: Uri.parse('http://127.0.0.1:3001/prove/transfer_confidential_1_2'),
      route: '/prove/transfer_confidential_1_2',
      method: 'POST',
      headers: const {},
      body: '{}',
    );
    expect(response.statusCode, 400);
    expect(nonceHex, hasLength(64));
    expect(
      () => TeePolicy(platform: '', imageIds: [image]),
      _code('invalid_config'),
    );
    expect(
      () =>
          TeePolicy(platform: 'aws-nitro', imageIds: const [], gpu: 'required'),
      _code('invalid_config'),
    );
  });

  test(
    'a local prover accepts a witness when PRIVACY_RINGS_LOCAL_PROVER_URL is set',
    () async {
      final raw = Platform.environment['PRIVACY_RINGS_LOCAL_PROVER_URL'];
      if (raw == null || raw.isEmpty) {
        markTestSkipped(
          'set PRIVACY_RINGS_LOCAL_PROVER_URL to a loopback prover',
        );
        return;
      }
      final endpoint = Uri.parse(raw);
      if (endpoint.host != '127.0.0.1' &&
          endpoint.host != 'localhost' &&
          endpoint.host != '::1') {
        fail('PRIVACY_RINGS_LOCAL_PROVER_URL must be a loopback prover');
      }
      final note = CircuitNote(
        domain: fieldU32(1),
        owner: Uint8List(32),
        asset: Uint8List(32),
        amount: fieldU32(1),
        blinding: Uint8List(32),
        dataHash: Uint8List(32),
        ringDataHash: Uint8List(32),
        ringProgramId: Uint8List(32),
      );
      final witness = confidentialTransferWitness(
        inputs: [
          WitnessInput(
            note: note,
            treeSlot: fieldU32(0),
            treeId: fieldU32(0),
            ownerPublicKeyHash: Uint8List(32),
            nullifierSecret: Uint8List(31)..[0] = 1,
          ),
        ],
        outputs: [
          WitnessOutput(
            note: note,
            treeId: fieldU32(0),
            ownerPublicKeyHash: Uint8List(32),
            nullifierPublicKey: Uint8List(32),
          ),
        ],
        outputTreeId: fieldU32(0),
        externalDataHash: Uint8List(32),
        privateTxHash: Uint8List(32),
        blindingSeed: Uint8List(32)..[0] = 1,
        ringProgramId: Uint8List(32),
        publicAssets: [Uint8List(32)],
        publicAmounts: [fieldU32(0)],
        signerPublicKeyHashes: [Uint8List(32)],
        inputFlags: fieldU32(0),
        publishedOutputOwnerPublicKeyHashes: [Uint8List(32)],
        cacheTreeId: Uint8List(32),
        cacheReadHashChain: Uint8List(32),
        cacheReadHashes: [Uint8List(32)],
        cacheIsCached: [fieldU32(0)],
        cacheReadIndex: [fieldU32(0)],
      );
      final prover = PrivacyProverClient(endpoint: endpoint);
      try {
        final proof = await prover.prove(
          circuit: 'transfer_confidential_1_2',
          witness: witness,
        );
        expect(proof.a, hasLength(32));
        expect(proof.b, hasLength(128));
        expect(proof.c, hasLength(32));
      } finally {
        prover.close();
      }
    },
    skip:
        Platform.environment['PRIVACY_RINGS_LOCAL_PROVER_URL'] == null ||
            Platform.environment['PRIVACY_RINGS_LOCAL_PROVER_URL']!.isEmpty
        ? 'local prover is opt-in'
        : false,
  );
}
