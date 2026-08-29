import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_pyth/solana_kit_pyth.dart';
import 'package:test/test.dart';

final Address payer = getAddressCodec().decode(
  Uint8List.fromList(List<int>.filled(32, 0x01)),
);
final Address otherSigner = getAddressCodec().decode(
  Uint8List.fromList(List<int>.filled(32, 0x02)),
);
final Address configAddress = getAddressCodec().decode(
  Uint8List.fromList(List<int>.filled(32, 0x03)),
);
final Address treasuryAddress = getAddressCodec().decode(
  Uint8List.fromList(List<int>.filled(32, 0x04)),
);
final Address guardianSetAddress = getAddressCodec().decode(
  Uint8List.fromList(List<int>.filled(32, 0x05)),
);
final Address encodedVaaAddress = getAddressCodec().decode(
  Uint8List.fromList(List<int>.filled(32, 0x06)),
);
final Address priceUpdateAddress = getAddressCodec().decode(
  Uint8List.fromList(List<int>.filled(32, 0x07)),
);

/// A VAA with guardian set index 2 and a single signature.
final vaa = Uint8List.fromList([
  1,
  0, 0, 0, 2, // guardian set index 2 (big-endian)
  1, // one signature
  7, ...List.filled(64, 0x77), 0, // signature entry
  0, 0, 0, 0, // timestamp
  0, 0, 0, 0, // nonce
  0, 26, // emitter chain 26 (pythnet)
  ...List.filled(32, 0), // emitter
  0, 0, 0, 0, 0, 0, 0, 1, // sequence 1
  1, // consistency level
  0x01, 0x01, ...List.filled(20, 0x10), // merkle root message
]);

final update = MerklePriceUpdate(
  message: Uint8List.fromList([9, 8, 7]),
  proof: [
    Uint8List.fromList(List<int>.filled(20, 0xA1)),
    Uint8List.fromList(List<int>.filled(20, 0xA2)),
  ],
);

List<int> encodedProof() => [
  2, 0, 0, 0, // proof count
  ...List.filled(20, 0xA1),
  ...List.filled(20, 0xA2),
];

void main() {
  group('PostUpdateAtomicParams encoder', () {
    test('encodes the borsh vec layout', () {
      final data = PostUpdateAtomicParams.encoder
          .encode(
            PostUpdateAtomicParams(vaa: vaa, merklePriceUpdate: update),
          )
          .toList();

      // vaa: borsh Vec<u8> = u32 length prefix + bytes.
      const cursor = 0;
      expect(data.sublist(cursor, cursor + 4), [vaa.length, 0, 0, 0]);
      expect(data.sublist(cursor + 4, cursor + 4 + vaa.length), vaa);
      var offset = cursor + 4 + vaa.length;

      // merklePriceUpdate.message: Vec<u8>.
      expect(data.sublist(offset, offset + 4), [3, 0, 0, 0]);
      expect(data.sublist(offset + 4, offset + 7), [9, 8, 7]);
      offset += 4 + 3;

      // merklePriceUpdate.proof: Vec<[u8; 20]>.
      expect(data.sublist(offset, offset + 4), [2, 0, 0, 0]);
      expect(
        data.sublist(offset + 4, offset + 4 + 40),
        encodedProof().sublist(4),
      );
      offset += 4 + 40;

      // treasuryId: u8.
      expect(data[offset], defaultTreasuryId);
      expect(data.length, offset + 1);
    });

    test('honors a custom treasury id', () {
      final data = PostUpdateAtomicParams.encoder
          .encode(
            PostUpdateAtomicParams(
              vaa: vaa,
              merklePriceUpdate: update,
              treasuryId: 7,
            ),
          )
          .toList();
      expect(data.last, 7);
    });
  });

  group('PostUpdateParams encoder', () {
    test('encodes without a vaa field', () {
      final data = PostUpdateParams.encoder
          .encode(PostUpdateParams(merklePriceUpdate: update))
          .toList();
      var offset = 0;
      expect(data.sublist(offset, offset + 4), [3, 0, 0, 0]);
      expect(data.sublist(offset + 4, offset + 7), [9, 8, 7]);
      offset += 7;
      expect(data.sublist(offset, offset + 4), [2, 0, 0, 0]);
      offset += 4 + 40;
      expect(data.last, defaultTreasuryId);
      expect(data.length, offset + 1);
    });
  });

  group('getPostUpdateAtomicInstruction', () {
    test('builds accounts in the IDL order with the right roles', () async {
      final instruction = await getPostUpdateAtomicInstruction(
        payer: payer,
        vaa: vaa,
        update: update,
        priceUpdateAccount: priceUpdateAddress,
        config: configAddress,
        treasury: treasuryAddress,
        guardianSet: guardianSetAddress,
      );
      expect(instruction.programAddress, pythSolanaReceiverProgramAddress);
      expect(instruction.accounts, hasLength(7));
      final roles = instruction.accounts!.map((meta) => meta.role).toList();
      expect(roles[0], AccountRole.writableSigner); // payer
      expect(roles[1], AccountRole.readonly); // guardian set
      expect(roles[2], AccountRole.readonly); // config
      expect(roles[3], AccountRole.writable); // treasury
      expect(roles[4], AccountRole.writable); // price update account
      expect(roles[5], AccountRole.readonly); // system program
      expect(roles[6], AccountRole.readonlySigner); // write authority
      expect(instruction.accounts![0].address, payer);
      expect(instruction.accounts![1].address, guardianSetAddress);
      expect(instruction.accounts![2].address, configAddress);
      expect(instruction.accounts![3].address, treasuryAddress);
      expect(instruction.accounts![4].address, priceUpdateAddress);
      expect(instruction.accounts![5].address, systemProgramAddress);
      expect(instruction.accounts![6].address, payer);
      expect(instruction.data, isNotNull);
      expect(instruction.data!.sublist(0, 8), postUpdateAtomicDiscriminator);
    });

    test('uses an explicit write authority', () async {
      final instruction = await getPostUpdateAtomicInstruction(
        payer: payer,
        vaa: vaa,
        update: update,
        priceUpdateAccount: priceUpdateAddress,
        config: configAddress,
        treasury: treasuryAddress,
        guardianSet: guardianSetAddress,
        writeAuthority: otherSigner,
      );
      expect(instruction.accounts![6].address, otherSigner);
    });

    test('derives the guardian set from the VAA when omitted', () async {
      final (guardianSet, _) = await getProgramDerivedAddress(
        programAddress: pythWormholeProgramAddress,
        seeds: [
          'GuardianSet',
          Uint8List.fromList([0, 0, 0, 2]),
        ],
      );
      final instruction = await getPostUpdateAtomicInstruction(
        payer: payer,
        vaa: vaa,
        update: update,
        priceUpdateAccount: priceUpdateAddress,
        config: configAddress,
        treasury: treasuryAddress,
      );
      expect(instruction.accounts![1].address, guardianSet);
    });
  });

  group('getPostUpdateInstruction', () {
    test('builds the encoded-vaa post instruction', () async {
      final instruction = await getPostUpdateInstruction(
        payer: payer,
        encodedVaa: encodedVaaAddress,
        update: update,
        priceUpdateAccount: priceUpdateAddress,
        config: configAddress,
        treasury: treasuryAddress,
      );
      expect(instruction.programAddress, pythSolanaReceiverProgramAddress);
      expect(instruction.accounts, hasLength(7));
      expect(instruction.accounts![0].address, payer);
      expect(instruction.accounts![1].address, encodedVaaAddress);
      expect(instruction.accounts![2].address, configAddress);
      expect(instruction.accounts![3].address, treasuryAddress);
      expect(instruction.accounts![4].address, priceUpdateAddress);
      expect(instruction.accounts![5].address, systemProgramAddress);
      expect(instruction.accounts![6].address, payer);
      expect(instruction.data!.sublist(0, 8), postUpdateDiscriminator);
    });
  });

  group('program addresses', () {
    test('matches the deployed Pyth program ids', () {
      expect(
        pythSolanaReceiverProgramAddress.value,
        'rec5EKMGg6MxZYaMdyBfgwp4d5rB9T1VQH5pJv5LtFJ',
      );
      expect(
        pythWormholeProgramAddress.value,
        'HDwcJBJXjL9FpJ7UBsYBtaDjsBUhuLCUYoz3zr8SWWaQ',
      );
      expect(
        pythPushOracleProgramAddress.value,
        'pythWSnswVUd12oZpeFP8e9CVaEqJg25g1Vtc2biRsT',
      );
    });
  });

  group('PDA helpers', () {
    test('derive stable addresses', () async {
      final config1 = await getPythConfigAddress();
      final config2 = await getPythConfigAddress();
      expect(config1, config2);

      final treasury0 = await getPythTreasuryAddress(0);
      final treasury1 = await getPythTreasuryAddress(1);
      expect(treasury0, isNot(treasury1));

      final guardian0 = await getGuardianSetAddress(0);
      final guardian1 = await getGuardianSetAddress(1);
      expect(guardian0, isNot(guardian1));

      // Guardian sets live on the Wormhole program, the others on the
      // receiver program.
      final (derivedGuardian, _) = await getProgramDerivedAddress(
        programAddress: pythWormholeProgramAddress,
        seeds: [
          'GuardianSet',
          Uint8List.fromList([0, 0, 0, 1]),
        ],
      );
      expect(guardian1, derivedGuardian);
    });
  });

  group('randomTreasuryId', () {
    test('returns values in the range [0, 255]', () {
      final values = {
        randomTreasuryId(),
        randomTreasuryId(),
        randomTreasuryId(),
        randomTreasuryId(),
        randomTreasuryId(),
      };
      expect(
        values.every((value) => value >= 0 && value <= 255),
        isTrue,
      );
    });
  });

  group('accumulator update truncation', () {
    Uint8List bytes(List<int> byteList) => Uint8List.fromList([
      0x50, 0x4e, 0x41, 0x55, // 'PNAU'
      0x01, 0x00, // version 1.0
      0x00, // trailing payload size
      0x00, // proof type
      0x00, 0x00, // vaa size 0
      ...byteList,
    ]);

    test('rejects header-truncated updates', () {
      // One update announced, but nothing follows the count byte.
      expect(
        () => parseAccumulatorUpdateData(bytes([1])),
        throwsA(
          isA<PythDecodeException>().having(
            (e) => e.message,
            'message',
            'Accumulator update 0 is truncated in its header',
          ),
        ),
      );
    });

    test('rejects messages larger than the remaining bytes', () {
      // The 3-byte header parses, but the message claims 10 bytes.
      expect(
        () => parseAccumulatorUpdateData(
          bytes([1, 0x00, 0x0a, 0xff]),
        ),
        throwsA(
          isA<PythDecodeException>().having(
            (e) => e.message,
            'message',
            'Accumulator update 0 message is truncated',
          ),
        ),
      );
    });

    test('rejects a missing proof count', () {
      // The message fits, but nothing is left for the proof count.
      expect(
        () => parseAccumulatorUpdateData(
          bytes([1, 0x00, 0x01, 0xaa]),
        ),
        throwsA(
          isA<PythDecodeException>().having(
            (e) => e.message,
            'message',
            'Accumulator update 0 proof count is missing',
          ),
        ),
      );
    });

    test('rejects proofs larger than the remaining bytes', () {
      // Two proofs are claimed but only one 20-byte hash follows.
      expect(
        () => parseAccumulatorUpdateData(
          bytes([1, 0x00, 0x01, 0xaa, 2, ...List.filled(20, 0xa1)]),
        ),
        throwsA(
          isA<PythDecodeException>().having(
            (e) => e.message,
            'message',
            'Accumulator update 0 proofs are truncated',
          ),
        ),
      );
    });
  });

  group('params debug representations', () {
    test('PostUpdateAtomicParams renders the treasury id', () {
      expect(
        PostUpdateAtomicParams(
          vaa: vaa,
          merklePriceUpdate: update,
          treasuryId: 3,
        ).toString(),
        'PostUpdateAtomicParams(treasuryId: 3)',
      );
    });

    test('PostUpdateParams renders the treasury id', () {
      expect(
        PostUpdateParams(merklePriceUpdate: update).toString(),
        'PostUpdateParams(treasuryId: 0)',
      );
    });
  });

  group('instruction PDA derivation', () {
    test(
      'getPostUpdateAtomicInstruction derives config and treasury when omitted',
      () async {
        final instruction = await getPostUpdateAtomicInstruction(
          payer: payer,
          vaa: vaa,
          update: update,
          priceUpdateAccount: priceUpdateAddress,
        );
        expect(instruction.accounts![2].address, await getPythConfigAddress());
        expect(
          instruction.accounts![3].address,
          await getPythTreasuryAddress(defaultTreasuryId),
        );
      },
    );

    test(
      'getPostUpdateInstruction derives config and treasury when omitted',
      () async {
        final instruction = await getPostUpdateInstruction(
          payer: payer,
          encodedVaa: encodedVaaAddress,
          update: update,
          priceUpdateAccount: priceUpdateAddress,
        );
        expect(instruction.accounts![2].address, await getPythConfigAddress());
        expect(
          instruction.accounts![3].address,
          await getPythTreasuryAddress(defaultTreasuryId),
        );
      },
    );
  });
}
