import 'dart:math';
import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_pyth/src/exceptions.dart';
import 'package:solana_kit_pyth/src/wormhole_vaas.dart';

/// Program address of the Pyth Solana Receiver.
///
/// The program is deployed at this address on Solana mainnet, devnet, and the
/// other supported SVM networks (see the Pyth contract addresses docs).
const pythSolanaReceiverProgramAddress = Address(
  'rec5EKMGg6MxZYaMdyBfgwp4d5rB9T1VQH5pJv5LtFJ',
);

/// Program address of the Wormhole core bridge used by the Pyth receiver at
/// the default deployment.
const pythWormholeProgramAddress = Address(
  'HDwcJBJXjL9FpJ7UBsYBtaDjsBUhuLCUYoz3zr8SWWaQ',
);

/// Program address of the Pyth push oracle, which maintains the long-lived
/// price feed accounts (PriceUpdateV2) on Solana.
const pythPushOracleProgramAddress = Address(
  'pythWSnswVUd12oZpeFP8e9CVaEqJg25g1Vtc2biRsT',
);

/// Anchor discriminator of the `post_update_atomic` instruction.
///
/// First 8 bytes of sha256('global:post_update_atomic').
const postUpdateAtomicDiscriminator = <int>[
  0x31,
  0xac,
  0x54,
  0xc0,
  0xaf,
  0xb4,
  0x34,
  0xea,
];

/// Anchor discriminator of the `post_update` instruction.
///
/// First 8 bytes of sha256('global:post_update').
const postUpdateDiscriminator = <int>[
  0x85,
  0x5f,
  0xcf,
  0xaf,
  0x0b,
  0x4f,
  0x76,
  0x2c,
];

/// Default treasury id used when submitting updates.
///
/// The receiver maintains one treasury PDA per u8 id to spread write locks.
const int defaultTreasuryId = 0;

/// Returns a random treasury id in the range [0, 255].
int randomTreasuryId() => Random().nextInt(256);

/// Seeds used to derive the receiver config PDA.
const List<String> configPdaSeeds = ['config'];

/// Seed prefix used to derive receiver treasury PDAs.
const String treasuryPdaSeed = 'treasury';

/// Seed prefix used to derive Wormhole guardian set PDAs on the Wormhole
/// program.
const String guardianSetPdaSeed = 'GuardianSet';

/// Returns the config PDA of the Pyth Solana Receiver program.
Future<Address> getPythConfigAddress({
  Address programAddress = pythSolanaReceiverProgramAddress,
}) async {
  final (pda, _) = await getProgramDerivedAddress(
    programAddress: programAddress,
    seeds: configPdaSeeds,
  );
  return pda;
}

/// Returns the treasury PDA for [treasuryId] of the Pyth Solana Receiver
/// program.
Future<Address> getPythTreasuryAddress(
  int treasuryId, {
  Address programAddress = pythSolanaReceiverProgramAddress,
}) async {
  _checkUint8(treasuryId, 'treasuryId');
  final (pda, _) = await getProgramDerivedAddress(
    programAddress: programAddress,
    seeds: [
      treasuryPdaSeed,
      Uint8List.fromList([treasuryId]),
    ],
  );
  return pda;
}

/// Returns the guardian set PDA for [guardianSetIndex] on the Wormhole
/// program.
///
/// The guardian set index is encoded as a big-endian u32 seed.
Future<Address> getGuardianSetAddress(
  int guardianSetIndex, {
  Address wormholeProgramAddress = pythWormholeProgramAddress,
}) {
  if (guardianSetIndex < 0 || guardianSetIndex > 0xffffffff) {
    throw ArgumentError.value(
      guardianSetIndex,
      'guardianSetIndex',
      'must be between 0 and 4294967295',
    );
  }
  final indexBytes = Uint8List(4)
    ..buffer.asByteData().setUint32(0, guardianSetIndex);
  return getProgramDerivedAddress(
    programAddress: wormholeProgramAddress,
    seeds: [guardianSetPdaSeed, indexBytes],
  ).then((result) => result.$1);
}

/// A merkle price update: a message committed against the merkle root
/// carried by the VAA payload, plus the merkle proof of the message.
class MerklePriceUpdate {
  /// Creates a [MerklePriceUpdate].
  const MerklePriceUpdate({required this.message, required this.proof});

  /// The message bytes (for example a price feed message).
  final Uint8List message;

  /// Keccak-160 merkle proof hashes, 20 bytes each.
  final List<Uint8List> proof;
}

/// A parsed accumulator update blob, as returned by the Hermes API.
///
/// Hermes returns one or more chunks of binary update data. Each chunk either
/// is an accumulator update (see [isAccumulatorUpdateData]) or, for legacy
/// responses, the VAA bytes directly.
class AccumulatorUpdateData {
  /// Creates an [AccumulatorUpdateData].
  const AccumulatorUpdateData({required this.vaa, required this.updates});

  /// The Wormhole VAA that attests the updates.
  final Uint8List vaa;

  /// The merkle-committed price updates.
  final List<MerklePriceUpdate> updates;
}

/// The magic header of accumulator update data: `PNAU` (0x504e4155).
const int accumulatorUpdateDataMagic = 0x504e4155;

/// Returns `true` when [updateBytes] starts with the accumulator update magic
/// (`PNAU`) and a compatible version header.
bool isAccumulatorUpdateData(Uint8List updateBytes) =>
    updateBytes.length >= 6 &&
    (updateBytes[0] << 24 |
            updateBytes[1] << 16 |
            updateBytes[2] << 8 |
            updateBytes[3]) ==
        accumulatorUpdateDataMagic &&
    updateBytes[4] == 1 && // major version
    updateBytes[5] == 0; // minor version

/// Parses an accumulator update blob into its VAA and merkle updates.
///
/// This mirrors `parseAccumulatorUpdateData` from
/// `@pythnetwork/price-service-sdk`:
///
/// * 4 bytes magic `PNAU`, then major + minor version bytes.
/// * one trailing payload size byte and that many bytes (skipped).
/// * one proof-type byte (skipped).
/// * a u16 big-endian VAA size followed by the VAA bytes.
/// * one update count byte, then per update a u16 big-endian message size,
///   the message bytes, a proof count byte, and that many 20-byte hashes.
AccumulatorUpdateData parseAccumulatorUpdateData(Uint8List data) {
  if (!isAccumulatorUpdateData(data)) {
    throw const PythDecodeException(
      'Invalid accumulator update data: unexpected magic or version',
    );
  }
  var cursor = 6;
  if (cursor >= data.length) {
    throw const PythDecodeException(
      'Accumulator update data is missing its trailing payload size',
    );
  }
  final trailingPayloadSize = data[cursor];
  cursor += 1 + trailingPayloadSize;
  if (cursor >= data.length) {
    throw const PythDecodeException('Accumulator update data is truncated');
  }
  cursor += 1; // proof type
  if (cursor + 2 > data.length) {
    throw const PythDecodeException(
      'Accumulator update data is missing its VAA size',
    );
  }
  final vaaSize = (data[cursor] << 8) | data[cursor + 1];
  cursor += 2;
  if (cursor + vaaSize > data.length) {
    throw const PythDecodeException('Accumulator update data VAA is truncated');
  }
  final vaa = Uint8List.sublistView(data, cursor, cursor + vaaSize);
  cursor += vaaSize;

  if (cursor >= data.length) {
    throw const PythDecodeException(
      'Accumulator update data is missing updates',
    );
  }
  final numUpdates = data[cursor];
  cursor += 1;

  final updates = <MerklePriceUpdate>[];
  for (var i = 0; i < numUpdates; i++) {
    if (cursor + 3 > data.length) {
      throw PythDecodeException(
        'Accumulator update $i is truncated in its header',
      );
    }
    final messageSize = (data[cursor] << 8) | data[cursor + 1];
    cursor += 2;
    if (cursor + messageSize > data.length) {
      throw PythDecodeException('Accumulator update $i message is truncated');
    }
    final message = Uint8List.sublistView(data, cursor, cursor + messageSize);
    cursor += messageSize;
    if (cursor >= data.length) {
      throw PythDecodeException('Accumulator update $i proof count is missing');
    }
    final numProofs = data[cursor];
    cursor += 1;
    const keccak160HashSize = 20;
    if (cursor + keccak160HashSize * numProofs > data.length) {
      throw PythDecodeException('Accumulator update $i proofs are truncated');
    }
    final proof = <Uint8List>[];
    for (var j = 0; j < numProofs; j++) {
      proof.add(
        Uint8List.sublistView(
          data,
          cursor,
          cursor + keccak160HashSize,
        ),
      );
      cursor += keccak160HashSize;
    }
    updates.add(MerklePriceUpdate(message: message, proof: proof));
  }
  if (cursor != data.length) {
    throw PythDecodeException(
      'Trailing ${data.length - cursor} byte(s) after accumulator updates',
    );
  }
  return AccumulatorUpdateData(vaa: vaa, updates: updates);
}

/// Parameters of the `post_update_atomic` instruction.
class PostUpdateAtomicParams {
  /// Creates [PostUpdateAtomicParams].
  const PostUpdateAtomicParams({
    required this.vaa,
    required this.merklePriceUpdate,
    this.treasuryId = defaultTreasuryId,
  });

  /// The (optionally signature-trimmed) Wormhole VAA attesting the update.
  final Uint8List vaa;

  /// The merkle-committed price update to post.
  final MerklePriceUpdate merklePriceUpdate;

  /// Id of the treasury PDA that receives the update fee.
  final int treasuryId;

  /// Returns the encoder for instruction data bytes.
  static Encoder<PostUpdateAtomicParams> get encoder => transformEncoder(
    _paramsFieldsEncoder(),
    (params) => <String, Object?>{
      'vaa': params.vaa,
      'merklePriceUpdate': params.merklePriceUpdate,
      'treasuryId': params.treasuryId,
    },
  );

  @override
  String toString() => 'PostUpdateAtomicParams(treasuryId: $treasuryId)';
}

/// Parameters of the `post_update` instruction.
///
/// Used after the VAA has already been posted and verified on the Wormhole
/// program; only the merkle price update is passed in.
class PostUpdateParams {
  /// Creates [PostUpdateParams].
  const PostUpdateParams({
    required this.merklePriceUpdate,
    this.treasuryId = defaultTreasuryId,
  });

  /// The merkle-committed price update to post.
  final MerklePriceUpdate merklePriceUpdate;

  /// Id of the treasury PDA that receives the update fee.
  final int treasuryId;

  /// Returns the encoder for instruction data bytes.
  static Encoder<PostUpdateParams> get encoder => transformEncoder(
    _postUpdateFieldsEncoder(),
    (params) => <String, Object?>{
      'merklePriceUpdate': params.merklePriceUpdate,
      'treasuryId': params.treasuryId,
    },
  );

  @override
  String toString() => 'PostUpdateParams(treasuryId: $treasuryId)';
}

Encoder<Map<String, Object?>> _paramsFieldsEncoder() {
  final proofItemEncoder = fixEncoderSize(getBytesEncoder(), 20);
  final nestedUpdateFieldsEncoder = getStructEncoder(
    <(String, Encoder<Object?>)>[
      ('message', getArrayEncoder(getU8Encoder())),
      ('proof', getArrayEncoder(proofItemEncoder)),
    ],
  );
  final updateEncoder =
      transformEncoder<Map<String, Object?>, MerklePriceUpdate>(
        nestedUpdateFieldsEncoder,
        (update) => <String, Object?>{
          'message': update.message,
          'proof': update.proof,
        },
      );
  return getStructEncoder(<(String, Encoder<Object?>)>[
    ('vaa', getArrayEncoder(getU8Encoder())),
    ('merklePriceUpdate', updateEncoder),
    ('treasuryId', getU8Encoder()),
  ]);
}

Encoder<Map<String, Object?>> _postUpdateFieldsEncoder() {
  final proofItemEncoder = fixEncoderSize(getBytesEncoder(), 20);
  final nestedUpdateFieldsEncoder = getStructEncoder(
    <(String, Encoder<Object?>)>[
      ('message', getArrayEncoder(getU8Encoder())),
      ('proof', getArrayEncoder(proofItemEncoder)),
    ],
  );
  final updateEncoder =
      transformEncoder<Map<String, Object?>, MerklePriceUpdate>(
        nestedUpdateFieldsEncoder,
        (update) => <String, Object?>{
          'message': update.message,
          'proof': update.proof,
        },
      );
  return getStructEncoder(<(String, Encoder<Object?>)>[
    ('merklePriceUpdate', updateEncoder),
    ('treasuryId', getU8Encoder()),
  ]);
}

/// Builds a `post_update_atomic` instruction for the Pyth Solana Receiver.
///
/// Posts [vaa] with its merkle [update] into the (yet uninitialized)
/// [priceUpdateAccount], paying the update fee from [payer]. The number of
/// guardian signatures in [vaa] does not need to reach Wormhole quorum;
/// consider trimming signatures to [defaultReducedGuardianSetSize] with
/// [trimVaaSignatures] to fit the update into one transaction.
///
/// Account order (per the program IDL):
/// 1. payer — writable signer
/// 2. guardianSet — readonly (PDA of the Wormhole program)
/// 3. config — readonly (receiver config PDA)
/// 4. treasury — writable (receiver treasury PDA)
/// 5. priceUpdateAccount — writable signer
/// 6. systemProgram — readonly
/// 7. writeAuthority — signer (defaults to the payer)
Future<Instruction> getPostUpdateAtomicInstruction({
  required Address payer,
  required Uint8List vaa,
  required MerklePriceUpdate update,
  required Address priceUpdateAccount,
  int treasuryId = defaultTreasuryId,
  Address? writeAuthority,
  Address? guardianSet,
  Address? config,
  Address? treasury,
  Address programAddress = pythSolanaReceiverProgramAddress,
  Address wormholeProgramAddress = pythWormholeProgramAddress,
}) async {
  _checkUint8(treasuryId, 'treasuryId');
  final effectiveGuardianSet =
      guardianSet ??
      await getGuardianSetAddress(
        getGuardianSetIndex(vaa),
        wormholeProgramAddress: wormholeProgramAddress,
      );
  final effectiveConfig =
      config ?? await getPythConfigAddress(programAddress: programAddress);
  final effectiveTreasury =
      treasury ??
      await getPythTreasuryAddress(treasuryId, programAddress: programAddress);
  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: payer, role: AccountRole.writableSigner),
      AccountMeta(address: effectiveGuardianSet, role: AccountRole.readonly),
      AccountMeta(address: effectiveConfig, role: AccountRole.readonly),
      AccountMeta(address: effectiveTreasury, role: AccountRole.writable),
      AccountMeta(
        address: priceUpdateAccount,
        role: AccountRole.writableSigner,
      ),
      const AccountMeta(
        address: systemProgramAddress,
        role: AccountRole.readonly,
      ),
      AccountMeta(
        address: writeAuthority ?? payer,
        role: AccountRole.readonlySigner,
      ),
    ],
    data: Uint8List.fromList([
      ...postUpdateAtomicDiscriminator,
      ...PostUpdateAtomicParams.encoder.encode(
        PostUpdateAtomicParams(
          vaa: vaa,
          merklePriceUpdate: update,
          treasuryId: treasuryId,
        ),
      ),
    ]),
  );
}

/// Builds a `post_update` instruction for the Pyth Solana Receiver.
///
/// Use this instruction when the VAA bytes have already been posted to the
/// Wormhole program and verified into the `encodedVaa` account; the receiver
/// then checks the VAA account instead of re-verifying guardian signatures.
Future<Instruction> getPostUpdateInstruction({
  required Address payer,
  required Address encodedVaa,
  required MerklePriceUpdate update,
  required Address priceUpdateAccount,
  int treasuryId = defaultTreasuryId,
  Address? writeAuthority,
  Address? config,
  Address? treasury,
  Address programAddress = pythSolanaReceiverProgramAddress,
}) async {
  _checkUint8(treasuryId, 'treasuryId');
  final effectiveConfig =
      config ?? await getPythConfigAddress(programAddress: programAddress);
  final effectiveTreasury =
      treasury ??
      await getPythTreasuryAddress(treasuryId, programAddress: programAddress);
  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: payer, role: AccountRole.writableSigner),
      AccountMeta(address: encodedVaa, role: AccountRole.readonly),
      AccountMeta(address: effectiveConfig, role: AccountRole.readonly),
      AccountMeta(address: effectiveTreasury, role: AccountRole.writable),
      AccountMeta(
        address: priceUpdateAccount,
        role: AccountRole.writableSigner,
      ),
      const AccountMeta(
        address: systemProgramAddress,
        role: AccountRole.readonly,
      ),
      AccountMeta(
        address: writeAuthority ?? payer,
        role: AccountRole.readonlySigner,
      ),
    ],
    data: Uint8List.fromList([
      ...postUpdateDiscriminator,
      ...PostUpdateParams.encoder.encode(
        PostUpdateParams(
          merklePriceUpdate: update,
          treasuryId: treasuryId,
        ),
      ),
    ]),
  );
}

void _checkUint8(int value, String name) {
  if (value < 0 || value > 255) {
    throw ArgumentError.value(value, name, 'must be between 0 and 255');
  }
}
