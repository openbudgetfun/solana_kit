import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_privacy_rings/solana_kit_privacy_rings.dart';
import 'package:test/test.dart';

Uint8List _hex(String value) {
  final bytes = Uint8List(value.length ~/ 2);
  for (var i = 0; i < bytes.length; i++) {
    bytes[i] = int.parse(value.substring(i * 2, i * 2 + 2), radix: 16);
  }
  return bytes;
}

void main() {
  test('deposit blinding matches the pinned Rust vector', () {
    final blinding = depositBlinding(List<int>.filled(32, 1), 7);
    expect(
      blinding,
      _hex('004d1e40d2142411b39e40c763db9defb6ca70abeaad20674443d33f88be673a'),
    );
    expect(blinding[0], 0);
    expect(
      depositBlinding(List<int>.filled(32, 1), 8),
      isNot(orderedEquals(blinding)),
    );
  });

  test(
    'deposit instruction bytes and accounts match the wire format',
    () async {
      final instruction = await depositInstruction(
        tree: stateMerkleTree,
        depositor: userRegistryProgramId,
        deposits: [
          AssetDeposit(
            asset: const SolDepositAsset(),
            viewTag: List<int>.filled(32, 0x11),
            recipientOwnerHash: List<int>.filled(32, 0x22),
            amount: BigInt.from(1000),
          ),
        ],
      );
      final expected = <int>[
        depositInstructionTag,
        1,
        0,
        1,
        0,
        ...List<int>.filled(32, 0x11),
        ...List<int>.filled(32, 0x22),
        0xe8,
        0x03,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
      ];
      expect(instruction.programAddress, shieldedPoolProgramId);
      expect(instruction.data, expected);
      expect(instruction.accounts, [
        const AccountMeta(
          address: stateMerkleTree,
          role: AccountRole.writable,
        ),
        const AccountMeta(
          address: userRegistryProgramId,
          role: AccountRole.writableSigner,
        ),
        const AccountMeta(
          address: shieldedPoolProgramId,
          role: AccountRole.readonly,
        ),
        const AccountMeta(
          address: systemProgramAddress,
          role: AccountRole.readonly,
        ),
        const AccountMeta(
          address: solInterfaceAddress,
          role: AccountRole.writable,
        ),
      ]);
      final decoded = decodeDepositInstructionData(
        Uint8List.fromList(instruction.data!.sublist(1)),
      );
      expect(decoded.deposits.single.amount, BigInt.from(1000));
      expect(decoded.assets.single, isA<SolAssetKind>());
    },
  );

  test('a deposit memo round-trips and an empty batch is rejected', () async {
    final encoded = encodeDepositInstructionData(
      DepositInstructionData(
        assets: const [SolAssetKind()],
        deposits: [
          DepositEntry(
            assetIndex: 0,
            viewTag: Uint8List(32),
            recipientOwnerHash: Uint8List(32),
            amount: BigInt.one,
            memo: [9, 8],
          ),
        ],
      ),
    );
    final decoded = decodeDepositInstructionData(encoded);
    expect(decoded.deposits.single.memo, [9, 8]);
    expect(
      () => depositInstruction(
        tree: stateMerkleTree,
        depositor: userRegistryProgramId,
        deposits: const [],
      ),
      throwsA(
        isA<PrivacyRingsException>().having(
          (error) => error.code,
          'code',
          'empty_deposit_batch',
        ),
      ),
    );
  });

  test('the SOL interface PDA matches the pinned address and bump', () async {
    final derived = await deriveSolInterface();
    expect(derived.address, solInterfaceAddress);
    expect(derived.bump, solInterfaceBump);
  });

  test(
    'transact data round-trips and a withdrawal selects settlement accounts',
    () async {
      final data = TransactInstructionData(
        expiryUnixTs: BigInt.from(1_700_000_000),
        txViewingPk: Uint8List(33)..[0] = 4,
        salt: Uint8List(16),
        interfaceTransfers: [SolWithdrawalTransfer(BigInt.from(5))],
        outputs: const [],
        messages: const [],
        privateTxHash: Uint8List(32),
        circuit: CircuitId.confidentialSigner(
          inputs: 1,
          outputs: 0,
          publicAssetSlots: 3,
        ),
        proof: TransactProof.zeroed(),
        inputs: [
          InputUtxo(nullifierHash: Uint8List(32)..[0] = 3, treeIndex: 0),
        ],
        treeContexts: const [
          TreeContext(utxoTreeRootIndex: 4, nullifierTreeRootIndex: 5),
        ],
      );
      final decoded = decodeTransactInstructionData(
        encodeTransactInstructionData(data),
      );
      expect(decoded.expiryUnixTs, data.expiryUnixTs);
      expect(decoded.interfaceTransfers.single, isA<SolWithdrawalTransfer>());
      expect(decoded.circuit.kind, 0);
      expect(decoded.inputs.single.treeIndex, 0);
      expect(decoded.treeContexts.single.utxoTreeRootIndex, 4);

      final expiry = ByteData(8)..setUint64(0, 1700000000, Endian.little);
      final prefix = <int>[
        ...expiry.buffer.asUint8List(),
        4,
        ...List<int>.filled(32, 0),
        ...List<int>.filled(16, 0),
        0,
      ];
      expect(
        encodeTransactInstructionData(
          TransactInstructionData(
            expiryUnixTs: BigInt.from(1_700_000_000),
            txViewingPk: Uint8List(33)..[0] = 4,
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
        ).sublist(0, prefix.length),
        prefix,
      );

      const recipient = userRegistryProgramId;
      final instruction = await withdrawInstruction(
        payer: userRegistryProgramId,
        inputTree: stateMerkleTree,
        outputTree: stateMerkleTree,
        ownerSigners: const [shieldedPoolProgramId],
        withdrawal: const SolWithdrawalTarget(recipient),
        data: data,
      );
      expect(instruction.data!.first, transactInstructionTag);
      expect(instruction.accounts!.map((account) => account.role).toList(), [
        AccountRole.writableSigner,
        AccountRole.writable,
        AccountRole.readonly,
        AccountRole.readonly,
        AccountRole.writable,
        AccountRole.writable,
        AccountRole.readonlySigner,
        AccountRole.writable,
        AccountRole.writable,
      ]);
      expect(instruction.accounts!.last.address, recipient);
      expect(
        instruction.accounts![instruction.accounts!.length - 2].address,
        solInterfaceAddress,
      );
    },
  );

  test('a confidential transfer omits withdrawal accounts', () async {
    final instruction = await confidentialTransferInstruction(
      payer: userRegistryProgramId,
      inputTree: stateMerkleTree,
      outputTree: stateMerkleTree,
      ownerSigners: const [],
      data: TransactInstructionData(
        expiryUnixTs: BigInt.zero,
        txViewingPk: Uint8List(33)..[0] = 4,
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
        treeContexts: const [
          TreeContext(utxoTreeRootIndex: 0, nullifierTreeRootIndex: 0),
        ],
      ),
    );
    expect(
      instruction.accounts!.map((account) => account.address),
      isNot(contains(solInterfaceAddress)),
    );
  });
}
