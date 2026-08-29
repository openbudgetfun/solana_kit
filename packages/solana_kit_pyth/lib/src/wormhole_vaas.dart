import 'dart:typed_data';

import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';
import 'package:solana_kit_pyth/src/exceptions.dart';

/// Version byte of a Wormhole VAA (v1).
const int wormholeVaaVersion = 1;

/// Size of a single guardian signature entry in a VAA: one guardian index
/// byte, 64 signature bytes, and one recovery-id byte.
const int vaaSignatureSize = 66;

/// Default number of signatures to keep when trimming a VAA.
///
/// Five signatures is the maximum that still lets the VAA be posted inside a
/// single Solana transaction; it also is the value recommended by Pyth for
/// partially verified updates.
const int defaultReducedGuardianSetSize = 5;

/// Emitter chain id of Pythnet, the network that publishes Pyth prices.
const int emitterChainPythnet = 26;

/// A guardian signature contained in a Wormhole VAA.
class WormholeVaaSignature {
  /// Creates a [WormholeVaaSignature].
  const WormholeVaaSignature({
    required this.guardianIndex,
    required this.signature,
    required this.recoveryId,
  });

  /// Index of the signing guardian in the guardian set.
  final int guardianIndex;

  /// The 64-byte ECDSA signature.
  final Uint8List signature;

  /// The ECDSA recovery id used to recover the guardian's public key.
  final int recoveryId;

  @override
  String toString() =>
      'WormholeVaaSignature(guardianIndex: $guardianIndex, '
      'recoveryId: $recoveryId)';
}

/// A parsed Wormhole VAA (v1) envelope.
///
/// The layout (all integers big-endian):
///
/// | offset | size | field              |
/// | ------ | ---- | ------------------ |
/// | 0      | 1    | version (must be 1)|
/// | 1      | 4    | guardian set index |
/// | 5      | 1    | signature count    |
/// | 6      | n×66 | signatures         |
/// | +0     | 4    | timestamp          |
/// | +4     | 4    | nonce              |
/// | +8     | 2    | emitter chain      |
/// | +10    | 32   | emitter address    |
/// | +42    | 8    | sequence           |
/// | +50    | 1    | consistency level  |
/// | +51    | rest | payload            |
class WormholeVaa {
  /// Creates a [WormholeVaa].
  const WormholeVaa({
    required this.version,
    required this.guardianSetIndex,
    required this.signatures,
    required this.timestamp,
    required this.nonce,
    required this.emitterChain,
    required this.emitterAddress,
    required this.sequence,
    required this.consistencyLevel,
    required this.payload,
  });

  /// VAA format version (always [wormholeVaaVersion] for known VAAs).
  final int version;

  /// Index of the guardian set that signed this VAA.
  final int guardianSetIndex;

  /// Guardian signatures, ordered by guardian index.
  final List<WormholeVaaSignature> signatures;

  /// Unix timestamp (in seconds) at which the VAA was signed.
  final int timestamp;

  /// Deduplication nonce assigned by the emitter.
  final int nonce;

  /// Chain id of the emitter, e.g. [emitterChainPythnet] for Pyth prices.
  final int emitterChain;

  /// The 32-byte address of the emitter on [emitterChain].
  final Uint8List emitterAddress;

  /// Monotonically increasing sequence number of the message.
  final BigInt sequence;

  /// Consistency level requested by the emitter.
  final int consistencyLevel;

  /// The message payload; for Pyth price updates this is a Pyth wormhole
  /// message (see [parsePythWormholeMessage]).
  final Uint8List payload;

  /// Number of guardian signatures contained in this VAA.
  int get signatureCount => signatures.length;

  @override
  String toString() =>
      'WormholeVaa(version: $version, '
      'guardianSetIndex: $guardianSetIndex, '
      'signatures: ${signatures.length}, '
      'emitterChain: $emitterChain, sequence: $sequence)';
}

/// Reads the index of the guardian set that signed [vaa] without fully
/// parsing the envelope.
///
/// This mirrors the `getGuardianSetIndex` helper of the upstream
/// `@pythnetwork/pyth-solana-receiver` SDK.
int getGuardianSetIndex(Uint8List vaa) {
  if (vaa.length < 5) {
    throw const PythDecodeException(
      'VAA is too short to contain a guardian set index',
    );
  }
  return (vaa[1] << 24) | (vaa[2] << 16) | (vaa[3] << 8) | vaa[4];
}

/// Reads the signature count of [vaa] without fully parsing the envelope.
int getVaaSignatureCount(Uint8List vaa) {
  if (vaa.length < 6) {
    throw const PythDecodeException(
      'VAA is too short to contain a signature count',
    );
  }
  return vaa[5];
}

/// Parses a Wormhole VAA (v1) envelope into a [WormholeVaa].
///
/// Throws a [PythDecodeException] when the byte layout is invalid.
WormholeVaa parseWormholeVaa(Uint8List vaa) {
  if (vaa.length < 6) {
    throw PythDecodeException('VAA is too short (${vaa.length} bytes)');
  }
  final version = vaa[0];
  if (version != wormholeVaaVersion) {
    throw PythDecodeException(
      'Unsupported VAA version $version (expected $wormholeVaaVersion)',
    );
  }
  final guardianSetIndex = getGuardianSetIndex(vaa);
  final signatureCount = getVaaSignatureCount(vaa);

  var cursor = 6;
  final signatures = <WormholeVaaSignature>[];
  for (var i = 0; i < signatureCount; i++) {
    if (cursor + vaaSignatureSize > vaa.length) {
      throw PythDecodeException(
        'VAA is truncated inside signature $i of $signatureCount',
      );
    }
    signatures.add(
      WormholeVaaSignature(
        guardianIndex: vaa[cursor],
        signature: Uint8List.sublistView(vaa, cursor + 1, cursor + 65),
        recoveryId: vaa[cursor + 65],
      ),
    );
    cursor += vaaSignatureSize;
  }

  if (cursor + 51 > vaa.length) {
    throw const PythDecodeException('VAA body is truncated');
  }
  final timestamp = _readUint32(vaa, cursor);
  cursor += 4;
  final nonce = _readUint32(vaa, cursor);
  cursor += 4;
  final emitterChain = (vaa[cursor] << 8) | vaa[cursor + 1];
  cursor += 2;
  final emitterAddress = Uint8List.sublistView(vaa, cursor, cursor + 32);
  cursor += 32;
  var sequence = BigInt.zero;
  for (var i = 0; i < 8; i++) {
    sequence = (sequence << 8) | BigInt.from(vaa[cursor + i]);
  }
  cursor += 8;
  final consistencyLevel = vaa[cursor];
  cursor += 1;
  final payload = Uint8List.sublistView(vaa, cursor);

  return WormholeVaa(
    version: version,
    guardianSetIndex: guardianSetIndex,
    signatures: signatures,
    timestamp: timestamp,
    nonce: nonce,
    emitterChain: emitterChain,
    emitterAddress: emitterAddress,
    sequence: sequence,
    consistencyLevel: consistencyLevel,
    payload: payload,
  );
}

/// Returns the same [vaa] except with only the first [count] signatures.
///
/// VAAs typically carry signatures from two thirds of the guardians, which
/// can exceed the size limit of a single Solana transaction. The Pyth
/// receiver program supports partially verified updates, so trimming
/// signatures to [defaultReducedGuardianSetSize] keeps the update small
/// enough to post atomically. Mirrors `trimSignatures` from the upstream
/// receiver SDK.
///
/// Returns [vaa] unchanged when it already has at most [count] signatures.
Uint8List trimVaaSignatures(
  Uint8List vaa, {
  int count = defaultReducedGuardianSetSize,
}) {
  final currentCount = getVaaSignatureCount(vaa);
  if (count >= currentCount) return vaa;

  final bodyStart = 6 + currentCount * vaaSignatureSize;
  if (bodyStart > vaa.length) {
    throw const PythDecodeException('VAA is truncated inside its signatures');
  }
  final prefixLength = 6 + count * vaaSignatureSize;
  final trimmed = Uint8List(prefixLength + (vaa.length - bodyStart))
    ..setRange(0, prefixLength, vaa)
    ..setAll(prefixLength, Uint8List.sublistView(vaa, bodyStart));
  trimmed[5] = count;
  return trimmed;
}

/// The kind of payload carried by a Pyth wormhole message.
enum PythWormholeMessageKind {
  /// The message carries a 20-byte Keccak-160 merkle root that the price
  /// updates are committed against.
  merkleRoot._(0x01),

  /// The message carries raw accumulator update data.
  accumulator._(0x02);

  const PythWormholeMessageKind._(this.id);

  /// The payload kind byte used on the wire.
  final int id;

  /// Resolves a payload kind byte.
  static PythWormholeMessageKind fromId(int id) => values.firstWhere(
    (kind) => kind.id == id,
    orElse: () => throw PythDecodeException(
      'Unknown Pyth wormhole payload kind 0x${id.toRadixString(16)}',
    ),
  );
}

/// A parsed Pyth wormhole message (the payload of a price update VAA).
///
/// The wire format is one version byte (currently `0x01`) followed by a
/// payload kind byte and the payload body:
///
/// * kind `0x01` ([PythWormholeMessageKind.merkleRoot]) — a 20-byte
///   Keccak-160 merkle root.
/// * kind `0x02` ([PythWormholeMessageKind.accumulator]) — accumulator update
///   data bytes (see `parseAccumulatorUpdateData`).
class PythWormholeMessage {
  /// Creates a [PythWormholeMessage].
  const PythWormholeMessage({
    required this.version,
    required this.kind,
    required this.rawPayload,
    this.merkleRoot,
  });

  /// Version byte of the message (currently always `0x01`).
  final int version;

  /// The kind of payload carried by this message.
  final PythWormholeMessageKind kind;

  /// The 20-byte Keccak-160 merkle root, for [merkle-root] messages.
  final Uint8List? merkleRoot;

  /// The full raw message bytes.
  final Uint8List rawPayload;

  @override
  String toString() =>
      'PythWormholeMessage(version: $version, kind: ${kind.name})';
}

/// Parses the payload of a Pyth price update VAA.
PythWormholeMessage parsePythWormholeMessage(Uint8List payload) {
  if (payload.length < 2) {
    throw const PythDecodeException('Pyth wormhole message is too short');
  }
  final kind = PythWormholeMessageKind.fromId(payload[1]);
  final merkleRoot = kind == PythWormholeMessageKind.merkleRoot
      ? payload.length >= 22
            ? Uint8List.sublistView(payload, 2, 22)
            : throw const PythDecodeException(
                'Merkle root payload is truncated',
              )
      : null;
  return PythWormholeMessage(
    version: payload[0],
    kind: kind,
    merkleRoot: merkleRoot,
    rawPayload: payload,
  );
}

/// A parsed Pyth price feed message (wire format, all integers big-endian).
///
/// Layout:
///
/// | offset | size | field            |
/// | ------ | ---- | ---------------- |
/// | 0      | 1    | variant (0)      |
/// | 1      | 32   | feed id          |
/// | 33     | 8    | price (i64)      |
/// | 41     | 8    | confidence (u64) |
/// | 49     | 4    | exponent (i32)   |
/// | 53     | 8    | publish time     |
/// | 61     | 8    | prev publish time|
/// | 69     | 8    | ema price (i64)  |
/// | 77     | 8    | ema conf (u64)   |
class PythPriceFeedMessage {
  /// Creates a [PythPriceFeedMessage].
  const PythPriceFeedMessage._({
    required this.feedId,
    required this.price,
    required this.confidence,
    required this.exponent,
    required this.publishTime,
    required this.prevPublishTime,
    required this.emaPrice,
    required this.emaConf,
  });

  /// The 32-byte price feed id.
  final Uint8List feedId;

  /// Price component, scaled with [exponent].
  final BigInt price;

  /// Confidence interval around [price], scaled with [exponent].
  final BigInt confidence;

  /// Exponent for [price], [confidence] and the EMA values.
  final int exponent;

  /// Unix timestamp (in seconds) of the price.
  final BigInt publishTime;

  /// Unix timestamp (in seconds) of the previous price.
  final BigInt prevPublishTime;

  /// EMA price component, scaled with [exponent].
  final BigInt emaPrice;

  /// EMA confidence component, scaled with [exponent].
  final BigInt emaConf;

  /// The feed id as a hex string (without a `0x` prefix).
  String get feedIdHex {
    final (hex, _) = getBase16Decoder().read(feedId, 0);
    return hex;
  }
}

/// Parses a wire-format price feed message, as embedded in a
/// `MerklePriceUpdate`.
///
/// Mirrors `parsePriceFeedMessage` from `@pythnetwork/price-service-sdk`.
PythPriceFeedMessage parsePythPriceFeedMessage(Uint8List message) {
  const size = 85;
  if (message.length < size) {
    throw PythDecodeException(
      'Price feed message is too short (${message.length} bytes)',
    );
  }
  final variant = message[0];
  if (variant != 0) {
    throw PythDecodeException('Not a price feed message (variant $variant)');
  }
  var cursor = 1;
  final feedId = Uint8List.sublistView(message, cursor, cursor + 32);
  cursor += 32;
  final price = _readBigInt(message, cursor, 8, signed: true);
  cursor += 8;
  final confidence = _readBigInt(message, cursor, 8);
  cursor += 8;
  final exponent = _readInt32(message, cursor);
  cursor += 4;
  final publishTime = _readBigInt(message, cursor, 8, signed: true);
  cursor += 8;
  final prevPublishTime = _readBigInt(message, cursor, 8, signed: true);
  cursor += 8;
  final emaPrice = _readBigInt(message, cursor, 8, signed: true);
  cursor += 8;
  final emaConf = _readBigInt(message, cursor, 8);

  return PythPriceFeedMessage._(
    feedId: feedId,
    price: price,
    confidence: confidence,
    exponent: exponent,
    publishTime: publishTime,
    prevPublishTime: prevPublishTime,
    emaPrice: emaPrice,
    emaConf: emaConf,
  );
}

int _readUint32(Uint8List bytes, int offset) =>
    (bytes[offset] << 24) |
    (bytes[offset + 1] << 16) |
    (bytes[offset + 2] << 8) |
    bytes[offset + 3];

int _readInt32(Uint8List bytes, int offset) {
  final value = _readUint32(bytes, offset);
  return value >= 0x80000000 ? value - 0x100000000 : value;
}

BigInt _readBigInt(
  Uint8List bytes,
  int offset,
  int length, {
  bool signed = false,
}) {
  var value = BigInt.zero;
  for (var i = 0; i < length; i++) {
    value = (value << 8) | BigInt.from(bytes[offset + i]);
  }
  if (signed && (bytes[offset] & 0x80) != 0) {
    value -= BigInt.one << (length * 8);
  }
  return value;
}
