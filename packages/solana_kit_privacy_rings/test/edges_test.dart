import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';
import 'package:solana_kit_privacy_rings/solana_kit_privacy_rings.dart';
import 'package:solana_kit_privacy_rings/src/bytes.dart';
import 'package:test/test.dart';

Matcher _code(String code) => throwsA(
  isA<PrivacyRingsException>().having((error) => error.code, 'code', code),
);

String _b58(List<int> bytes) =>
    getBase58Decoder().decode(Uint8List.fromList(bytes));

String _addr(int marker) => _b58(Uint8List(32)..[0] = marker);

Uint8List _u64(int value) {
  final data = ByteData(8)..setUint64(0, value, Endian.little);
  return data.buffer.asUint8List();
}

TransactInstructionData _transact({
  List<InterfaceTransfer> transfers = const [],
  List<TransactOutput> outputs = const [],
  List<TransactMessage> messages = const [],
  CircuitId? circuit,
  List<int>? dataHash,
  List<int>? ringDataHash,
  List<InputUtxo> inputs = const [],
  List<TreeContext> trees = const [
    TreeContext(utxoTreeRootIndex: 1, nullifierTreeRootIndex: 2),
  ],
}) {
  return TransactInstructionData(
    expiryUnixTs: BigInt.from(9),
    txViewingPk: Uint8List(33)..[0] = 4,
    salt: Uint8List(16),
    interfaceTransfers: transfers,
    dataHash: dataHash,
    ringDataHash: ringDataHash,
    outputs: outputs,
    messages: messages,
    privateTxHash: Uint8List(32)..[0] = 7,
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

List<CacheWriteSlot> _slots() => [
  for (var i = 0; i < 16; i++) CacheWriteSlot(output: i, slot: 0xff),
];

Bsb22Commitment _bsb() => Bsb22Commitment(
  commitment: Uint8List(32)..[0] = 1,
  commitmentPok: Uint8List(32)..[0] = 2,
);

void main() {
  test('byte codec rejects ranges, flags, and trailing bytes', () {
    final writer = ByteWriter()
      ..u8(1, 'u8')
      ..u16(0x0201, 'u16')
      ..u32(0x04030201, 'u32')
      ..u64(BigInt.parse('18446744073709551615'), 'u64')
      ..bytes([9])
      ..option<int>(null, (_, _) {})
      ..option(7, (output, value) => output.u8(value, 'inner'));
    final bytes = writer.finish();
    final reader = ByteReader(bytes);
    expect(reader.u8('u8'), 1);
    expect(reader.u16('u16'), 0x0201);
    expect(reader.u32('u32'), 0x04030201);
    expect(reader.u64('u64'), BigInt.parse('18446744073709551615'));
    expect(reader.bytes(1, 'b'), [9]);
    expect(reader.option(() => reader.u8('inner')), isNull);
    expect(reader.option(() => reader.u8('inner')), 7);
    reader.done();

    expect(() => ByteWriter()..u8(256, 'u8'), _code('integer_range'));
    expect(() => ByteWriter()..u16(-1, 'u16'), _code('integer_range'));
    expect(() => ByteWriter()..u32(-1, 'u32'), _code('integer_range'));
    expect(
      () => ByteWriter()..u64(BigInt.from(-1), 'u64'),
      _code('integer_range'),
    );
    expect(
      () => ByteWriter()..bytes([1], length: 2, name: 'b'),
      _code('invalid_length'),
    );
    expect(() => ByteReader(Uint8List(0)).u8('x'), _code('truncated'));
    expect(
      () => ByteReader(Uint8List.fromList([2])).flag('f'),
      _code('invalid_flag'),
    );
    expect(
      () => ByteReader(Uint8List.fromList([0, 1])).done(),
      _code('trailing_bytes'),
    );
    expect(() => copyBytes([1], 2, 'n'), _code('invalid_length'));
    expect(() => u64be(-1), _code('integer_range'));
    expect(u32be(0x01020304), [1, 2, 3, 4]);
  });

  test('deposit blinding and instruction data reject bad inputs', () {
    expect(() => depositBlinding([1], 0), _code('invalid_length'));
    expect(
      () => depositBlinding(Uint8List(32), -1),
      _code('integer_range'),
    );
    expect(
      () => DepositEntry(
        assetIndex: 256,
        viewTag: Uint8List(32),
        recipientOwnerHash: Uint8List(32),
        amount: BigInt.one,
      ),
      _code('integer_range'),
    );
    expect(
      () => DepositEntry(
        assetIndex: 0,
        viewTag: Uint8List(32),
        recipientOwnerHash: Uint8List(32),
        amount: BigInt.from(-1),
      ),
      _code('integer_range'),
    );
    expect(
      () => DepositEntry(
        assetIndex: 0,
        viewTag: Uint8List(32),
        recipientOwnerHash: Uint8List(32),
        amount: BigInt.one,
        memo: Uint8List(0x10000),
      ),
      _code('invalid_length'),
    );

    final encoded = encodeDepositInstructionData(
      DepositInstructionData(
        assets: const [SolAssetKind(), SplAssetKind(3)],
        deposits: [
          DepositEntry(
            assetIndex: 1,
            viewTag: Uint8List(32)..[0] = 4,
            recipientOwnerHash: Uint8List(32)..[0] = 5,
            amount: BigInt.two,
            memo: [9, 8],
          ),
        ],
      ),
    );
    final decoded = decodeDepositInstructionData(encoded);
    expect(decoded.assets[1], isA<SplAssetKind>());
    expect((decoded.assets[1] as SplAssetKind).splInterfaceBump, 3);
    expect(decoded.deposits.single.memo, [9, 8]);

    final unknown = Uint8List.fromList(encoded)..[1] = 9;
    expect(
      () => decodeDepositInstructionData(unknown),
      _code('invalid_discriminator'),
    );
    final outOfRange = encodeDepositInstructionData(
      DepositInstructionData(
        assets: const [SolAssetKind()],
        deposits: [
          DepositEntry(
            assetIndex: 4,
            viewTag: Uint8List(32),
            recipientOwnerHash: Uint8List(32),
            amount: BigInt.one,
          ),
        ],
      ),
    );
    expect(
      () => decodeDepositInstructionData(outOfRange),
      _code('invalid_asset_index'),
    );
  });

  test('output frames decode ring records and reject truncated bodies', () {
    final ring = getAddressEncoder().encode(stateMerkleTree);
    final confidential = decodeConfidentialPlaintext(
      Uint8List.fromList([
        ..._u64(1),
        ..._u64(3),
        ...Uint8List(32),
        1,
        ...ring,
        3,
        1,
        1,
        0,
        9,
        2,
        0,
        0,
        3,
        2,
        0,
        1,
        2,
      ]),
    );
    expect(confidential.knownMint, solMint);
    expect(confidential.ringProgramId, stateMerkleTree);
    expect(confidential.records.map((record) => record.kind), [
      'ringData',
      'utxoData',
      'memo',
    ]);
    expect(
      ConfidentialPlaintext(
        assetId: BigInt.two,
        amount: BigInt.one,
        blinding: Uint8List(32),
        records: const [],
      ).knownMint,
      isNull,
    );
    expect(
      () => decodeConfidentialPlaintext(
        Uint8List.fromList([..._u64(1), ..._u64(1), ...Uint8List(32), 0, 1, 9]),
      ),
      _code('invalid_discriminator'),
    );
    expect(
      () => readOutputFrame(Uint8List.fromList([0])),
      _code('truncated'),
    );
    expect(
      () => readOutputFrame(Uint8List.fromList([3, 0, 0, 0, 0])),
      _code('invalid_discriminator'),
    );
    expect(
      () => readOutputFrame(Uint8List.fromList([0, 0, 0, 0, 0])),
      _code('truncated'),
    );
    expect(
      () => splitEmbeddedViewingKey(Uint8List(2)),
      _code('truncated'),
    );

    final optional = Uint8List.fromList([
      ...Uint8List(32),
      ...Uint8List(32),
      ...ring,
      ..._u64(4),
      1,
      ...Uint8List(32),
      1,
      1,
      0,
      0,
      0,
      7,
      1,
      ...ring,
      1,
      ...Uint8List(32),
      1,
      1,
      0,
      0,
      0,
      8,
      1,
      2,
      0,
      0,
      0,
      6,
      6,
    ]);
    expect(decodeProoflessPlaintext(optional).amount, BigInt.from(4));
  });

  test('transact data round-trips every circuit payload and transfer leg', () {
    final cache = CacheAccess(readBitmap: BigInt.one, writeSlots: _slots());
    final circuits = [
      CircuitId(kind: 1, inputs: 0, outputs: 0, publicAssetSlots: 3),
      CircuitId(kind: 2, inputs: 0, outputs: 0, publicAssetSlots: 3),
      CircuitId(
        kind: 3,
        inputs: 1,
        outputs: 1,
        publicAssetSlots: 3,
        anonymous: (commitment: _bsb(), defaultOwnerTag: null),
      ),
      CircuitId(
        kind: 4,
        inputs: 1,
        outputs: 1,
        publicAssetSlots: 3,
        cacheAccess: cache,
      ),
      CircuitId(
        kind: 5,
        inputs: 1,
        outputs: 0,
        publicAssetSlots: 3,
        cacheAccess: cache,
      ),
      CircuitId(
        kind: 6,
        inputs: 1,
        outputs: 1,
        publicAssetSlots: 3,
        anonymous: (commitment: _bsb(), defaultOwnerTag: Uint8List(32)),
        cacheAccess: cache,
      ),
      CircuitId(
        kind: 7,
        inputs: 1,
        outputs: 1,
        publicAssetSlots: 3,
        eddsa: (commitment: _bsb(), ownerPk: Uint8List(32)..[0] = 3),
      ),
      CircuitId(
        kind: 8,
        inputs: 1,
        outputs: 1,
        publicAssetSlots: 3,
        eddsa: (commitment: _bsb(), ownerPk: Uint8List(32)),
        cacheAccess: cache,
      ),
    ];
    for (final circuit in circuits) {
      final decoded = decodeTransactInstructionData(
        encodeTransactInstructionData(_transact(circuit: circuit)),
      );
      expect(decoded.circuit.kind, circuit.kind);
    }

    final rich = _transact(
      transfers: [
        SolDepositTransfer(BigInt.one),
        SolWithdrawalTransfer(BigInt.two),
        SplDepositTransfer(BigInt.from(3), 4),
        SplWithdrawalTransfer(BigInt.from(5), 6),
      ],
      dataHash: Uint8List(32)..[0] = 1,
      ringDataHash: Uint8List(32)..[0] = 2,
      outputs: [
        TransactOutput(
          utxoHash: Uint8List(32)..[0] = 3,
          ownerTag: InlineOwnerTag(Uint8List(32)..[0] = 4),
          data: [1, 2],
        ),
        TransactOutput(
          utxoHash: Uint8List(32)..[0] = 5,
          ownerTag: AccountOwnerTag(2),
        ),
      ],
      messages: [
        TransactMessage(viewTag: Uint8List(32)..[0] = 6, data: [7]),
      ],
      inputs: [InputUtxo(nullifierHash: Uint8List(32), treeIndex: 0)],
    );
    final encoded = encodeTransactInstructionData(rich);
    final decoded = decodeTransactInstructionData(encoded);
    expect(decoded.interfaceTransfers, hasLength(4));
    expect(decoded.outputs[1].ownerTag, isA<AccountOwnerTag>());
    expect(decoded.messages.single.data, [7]);
    expect(decoded.dataHash, rich.dataHash);
    final replaced = decoded.withProof(
      TransactProof(
        a: Uint8List(32)..[0] = 9,
        b: Uint8List(128),
        c: Uint8List(32),
      ),
    );
    expect(replaced.proof.a[0], 9);

    final badKind = Uint8List.fromList(encoded)..[58] = 9;
    expect(
      () => decodeTransactInstructionData(badKind),
      _code('invalid_discriminator'),
    );
    final zeroAmount = Uint8List.fromList(encoded)..fillRange(59, 67, 0);
    expect(
      () => decodeTransactInstructionData(zeroAmount),
      _code('zero_transfer'),
    );
    expect(
      decodeTransactInstructionData(encoded).outputs.first.ownerTag,
      isA<InlineOwnerTag>(),
    );
    final badOwner = Uint8List.fromList(encoded);
    const ownerAt = 8 + 33 + 16 + 1 + 9 + 9 + 10 + 10 + 33 + 33 + 1 + 32;
    expect(encoded[ownerAt], 0);
    badOwner[ownerAt] = 9;
    expect(
      () => decodeTransactInstructionData(badOwner),
      _code('invalid_discriminator'),
    );
    expect(
      () => decodeTransactInstructionData(Uint8List.fromList([...encoded, 1])),
      _code('trailing_bytes'),
    );
  });

  test('transact builders reject shapes they do not settle', () async {
    expect(
      () => InputUtxo(nullifierHash: [1], treeIndex: 0),
      _code('invalid_length'),
    );
    expect(
      () => InputUtxo(nullifierHash: Uint8List(32), treeIndex: 256),
      _code('integer_range'),
    );
    expect(() => AccountOwnerTag(-1), _code('integer_range'));
    expect(
      () => TransactOutput(
        utxoHash: Uint8List(32),
        ownerTag: AccountOwnerTag(0),
        data: Uint8List(0x10000),
      ),
      _code('invalid_length'),
    );
    expect(
      () => TransactMessage(viewTag: Uint8List(32), data: Uint8List(0x10000)),
      _code('invalid_length'),
    );
    expect(
      () => CacheAccess(readBitmap: BigInt.from(-1), writeSlots: _slots()),
      _code('integer_range'),
    );
    expect(
      () => CacheAccess(
        readBitmap: BigInt.zero,
        writeSlots: _slots().take(1).toList(),
      ),
      _code('invalid_length'),
    );
    expect(
      () => CircuitId(kind: -1, inputs: 0, outputs: 0, publicAssetSlots: 3),
      _code('integer_range'),
    );
    expect(
      () => CircuitId(kind: 0, inputs: 256, outputs: 0, publicAssetSlots: 3),
      _code('integer_range'),
    );
    expect(
      () => encodeTransactInstructionData(
        _transact(
          circuit: CircuitId(
            kind: 7,
            inputs: 0,
            outputs: 0,
            publicAssetSlots: 3,
          ),
        ),
      ),
      _code('invalid_circuit'),
    );
    expect(
      () => encodeTransactInstructionData(
        _transact(
          circuit: CircuitId(
            kind: 3,
            inputs: 0,
            outputs: 0,
            publicAssetSlots: 3,
          ),
        ),
      ),
      _code('invalid_circuit'),
    );
    expect(
      () => encodeTransactInstructionData(
        _transact(
          circuit: CircuitId(
            kind: 4,
            inputs: 0,
            outputs: 0,
            publicAssetSlots: 3,
          ),
        ),
      ),
      _code('invalid_circuit'),
    );
    expect(
      () => TransactInstructionData(
        expiryUnixTs: BigInt.from(-1),
        txViewingPk: Uint8List(33),
        salt: Uint8List(16),
        interfaceTransfers: const [],
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
        treeContexts: const [],
      ),
      _code('integer_range'),
    );
    expect(
      () => _transact(
        transfers: [
          for (var i = 0; i < 33; i++) SolDepositTransfer(BigInt.one),
        ],
      ),
      _code('too_many_transfers'),
    );
    expect(
      () => _transact(transfers: [SolDepositTransfer(BigInt.zero)]),
      _code('zero_transfer'),
    );
    expect(
      () => _transact(transfers: [SolDepositTransfer(BigInt.from(-1))]),
      _code('integer_range'),
    );
    expect(
      () => _transact(
        transfers: [SolDepositTransfer(BigInt.parse('18446744073709551616'))],
      ),
      _code('integer_range'),
    );
    expect(
      () => TransactProof(a: [1], b: Uint8List(128), c: Uint8List(32)),
      _code('invalid_length'),
    );

    final data = _transact(
      transfers: [SolWithdrawalTransfer(BigInt.one)],
      inputs: [InputUtxo(nullifierHash: Uint8List(32), treeIndex: 0)],
    );
    expect(
      () => transactInstruction(
        payer: userRegistryProgramId,
        inputTree: stateMerkleTree,
        outputTree: stateMerkleTree,
        ownerSigners: const [],
        data: data,
      ),
      _code('withdrawal_mismatch'),
    );
    expect(
      () => withdrawInstruction(
        payer: userRegistryProgramId,
        inputTree: stateMerkleTree,
        outputTree: stateMerkleTree,
        ownerSigners: const [],
        withdrawal: const SolWithdrawalTarget(userRegistryProgramId),
        data: _transact(),
      ),
      _code('withdrawal_mismatch'),
    );
    expect(
      () => withdrawInstruction(
        payer: userRegistryProgramId,
        inputTree: stateMerkleTree,
        outputTree: stateMerkleTree,
        ownerSigners: const [],
        withdrawal: const SolWithdrawalTarget(userRegistryProgramId),
        data: _transact(transfers: [SplWithdrawalTransfer(BigInt.one, 1)]),
      ),
      _code('withdrawal_mismatch'),
    );
    expect(
      () => withdrawInstruction(
        payer: userRegistryProgramId,
        inputTree: stateMerkleTree,
        outputTree: stateMerkleTree,
        ownerSigners: const [],
        withdrawal: const SplWithdrawalTarget(
          mint: stateMerkleTree,
          recipientTokenAccount: userRegistryProgramId,
          tokenProgram: shieldedPoolProgramId,
          splInterface: stateMerkleTree,
        ),
        data: _transact(transfers: [SolWithdrawalTransfer(BigInt.one)]),
      ),
      _code('withdrawal_mismatch'),
    );
    expect(
      () => transactInstruction(
        payer: userRegistryProgramId,
        inputTree: stateMerkleTree,
        outputTree: stateMerkleTree,
        ownerSigners: const [],
        data: _transact(trees: const []),
      ),
      _code('invalid_shape'),
    );

    final spl = await splInterfacePda(stateMerkleTree);
    final withdrawn = await withdrawInstruction(
      payer: userRegistryProgramId,
      inputTree: stateMerkleTree,
      outputTree: stateMerkleTree,
      ownerSigners: const [],
      withdrawal: SplWithdrawalTarget(
        mint: stateMerkleTree,
        recipientTokenAccount: userRegistryProgramId,
        tokenProgram: shieldedPoolProgramId,
        splInterface: spl.address,
      ),
      data: _transact(transfers: [SplWithdrawalTransfer(BigInt.one, spl.bump)]),
    );
    expect(withdrawn.accounts!.last.address, shieldedPoolProgramId);
    expect(
      () => nullifierPda(stateMerkleTree, [1]),
      throwsArgumentError,
    );
  });

  test(
    'deposit batches settle SPL mints and reject conflicting ones',
    () async {
      expect(
        () => depositInstruction(
          tree: stateMerkleTree,
          depositor: userRegistryProgramId,
          deposits: const [],
        ),
        _code('empty_deposit_batch'),
      );
      expect(
        () => depositInstruction(
          tree: stateMerkleTree,
          depositor: userRegistryProgramId,
          deposits: [
            for (var i = 0; i < 256; i++)
              AssetDeposit(
                asset: const SolDepositAsset(),
                viewTag: Uint8List(32),
                recipientOwnerHash: Uint8List(32),
                amount: BigInt.one,
              ),
          ],
        ),
        _code('too_many_entries'),
      );
      final mints = [for (var i = 1; i <= 5; i++) address(_addr(i))];
      expect(
        () => depositInstruction(
          tree: stateMerkleTree,
          depositor: userRegistryProgramId,
          deposits: [
            for (final mint in mints)
              AssetDeposit(
                asset: SplDepositAsset(
                  mint: mint,
                  sourceTokenAccount: userRegistryProgramId,
                  tokenProgram: shieldedPoolProgramId,
                ),
                viewTag: Uint8List(32),
                recipientOwnerHash: Uint8List(32),
                amount: BigInt.one,
              ),
            AssetDeposit(
              asset: const SolDepositAsset(),
              viewTag: Uint8List(32),
              recipientOwnerHash: Uint8List(32),
              amount: BigInt.one,
            ),
          ],
        ),
        _code('too_many_assets'),
      );
      final mint = address(_addr(8));
      expect(
        () => depositInstruction(
          tree: stateMerkleTree,
          depositor: userRegistryProgramId,
          deposits: [
            AssetDeposit(
              asset: SplDepositAsset(
                mint: mint,
                sourceTokenAccount: userRegistryProgramId,
                tokenProgram: shieldedPoolProgramId,
              ),
              viewTag: Uint8List(32),
              recipientOwnerHash: Uint8List(32),
              amount: BigInt.one,
            ),
            AssetDeposit(
              asset: SplDepositAsset(
                mint: mint,
                sourceTokenAccount: userRegistryProgramId,
                tokenProgram: stateMerkleTree,
              ),
              viewTag: Uint8List(32),
              recipientOwnerHash: Uint8List(32),
              amount: BigInt.one,
            ),
          ],
        ),
        _code('conflicting_token_program'),
      );
      expect(
        () => depositInstruction(
          tree: stateMerkleTree,
          depositor: userRegistryProgramId,
          deposits: [
            AssetDeposit(
              asset: SplDepositAsset(
                mint: mint,
                sourceTokenAccount: userRegistryProgramId,
                tokenProgram: shieldedPoolProgramId,
              ),
              viewTag: Uint8List(32),
              recipientOwnerHash: Uint8List(32),
              amount: BigInt.one,
            ),
            AssetDeposit(
              asset: SplDepositAsset(
                mint: mint,
                sourceTokenAccount: stateMerkleTree,
                tokenProgram: shieldedPoolProgramId,
              ),
              viewTag: Uint8List(32),
              recipientOwnerHash: Uint8List(32),
              amount: BigInt.one,
            ),
          ],
        ),
        _code('conflicting_spl_source'),
      );
      final instruction = await depositInstruction(
        tree: stateMerkleTree,
        depositor: userRegistryProgramId,
        deposits: [
          AssetDeposit(
            asset: SplDepositAsset(
              mint: mint,
              sourceTokenAccount: userRegistryProgramId,
              tokenProgram: shieldedPoolProgramId,
            ),
            viewTag: Uint8List(32),
            recipientOwnerHash: Uint8List(32),
            amount: BigInt.from(11),
            memo: [1],
          ),
        ],
      );
      expect(instruction.accounts, hasLength(7));
      expect(instruction.data!.first, depositInstructionTag);
      expect(
        PrivacyRingsEndpoints.localnet().indexer,
        Uri.parse('http://127.0.0.1:8784'),
      );
      expect(
        resolvePrivacyRingsEndpoints(
          solanaRpcUrl: Uri.parse('http://example.test/already'),
        ).indexer.path,
        '/already',
      );
      expect(
        resolvePrivacyRingsEndpoints(
          solanaRpcUrl: Uri.parse('https://mainnet.helius-rpc.com/custom'),
          indexerUrl: Uri.parse('http://127.0.0.1:9'),
        ).indexer.port,
        9,
      );
    },
  );

  test('viewing keys reject bad points and open ring-deposit labels', () async {
    expect(() => ViewingKey.fromBytes([1]), _code('invalid_length'));
    final key = ViewingKey.fromBytes(Uint8List(32)..[0] = 3);
    expect(
      () => key.decryptSlot(
        txViewingPublicKey: [1],
        ciphertext: [1],
        salt: Uint8List(16),
        slotIndex: 0,
      ),
      _code('invalid_length'),
    );
    expect(
      () => key.encryptSlot(
        recipientPublicKey: Uint8List(33),
        plaintext: [1],
        salt: Uint8List(16),
        slotIndex: 0,
      ),
      _code('invalid_public_key'),
    );
    final nonCanonical = Uint8List(33)..fillRange(0, 33, 0xff);
    nonCanonical[0] = 4;
    expect(
      () => key.encryptSlot(
        recipientPublicKey: nonCanonical,
        plaintext: [1],
        salt: Uint8List(16),
        slotIndex: 0,
      ),
      _code('invalid_public_key'),
    );
    expect(
      key.decryptSlot(
        txViewingPublicKey: await key.publicKey(),
        ciphertext: [1],
        salt: Uint8List(16),
        slotIndex: -1,
      ),
      _code('integer_range'),
    );
    final opened = await key.decryptRingDeposit(
      txViewingPublicKey: await key.publicKey(),
      ciphertext: Uint8List(4),
      salt: Uint8List(16),
    );
    expect(opened, hasLength(4));
    expect(
      () => key.encryptSlot(
        recipientPublicKey: Uint8List(33)..[0] = 4,
        plaintext: [1],
        salt: Uint8List(16),
        slotIndex: 0,
      ),
      _code('non_contributory_key'),
    );
    expect(
      redactUri(Uri.parse('https://user:secret@example.test/?token=abc&x=1'))
          .toString(),
      isNot(contains('secret')),
    );
    expect(redactUri(Uri.parse('https://example.test/path')).path, '/path');
    expect(
      redactSecrets('https://user:pw@host/?password=no&ok=1'),
      isNot(contains('no')),
    );
  });
}
