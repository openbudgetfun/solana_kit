import 'dart:typed_data';

import 'package:solana_kit_pyth/solana_kit_pyth.dart';
import 'package:test/test.dart';

/// Builds a synthetic MerklePriceUpdate blob.
List<int> buildUpdate({
  required List<int> message,
  required List<List<int>> proof,
}) {
  final buffer = BytesBuilder()
    ..addByte((message.length >> 8) & 0xff)
    ..addByte(message.length & 0xff)
    ..add(message)
    ..addByte(proof.length);
  for (final hash in proof) {
    buffer.add(hash);
  }
  return buffer.toBytes().toList();
}

/// Builds a synthetic accumulator update blob.
List<int> buildAccumulatorUpdateData({
  required List<int> vaa,
  required List<List<int>> updates,
}) {
  final updateBytes = [
    for (final update in updates)
      buildUpdate(message: update, proof: [List.filled(20, 0xA0)]),
  ];
  final buffer = BytesBuilder()
    ..add(const [0x50, 0x4e, 0x41, 0x55]) // 'PNAU'
    ..add(const [0x01, 0x00]) // major.minor version
    ..addByte(0) // trailing payload size
    ..addByte(0) // proof type
    ..addByte((vaa.length >> 8) & 0xff)
    ..addByte(vaa.length & 0xff)
    ..add(vaa)
    ..addByte(updates.length);
  for (final update in updateBytes) {
    buffer.add(update);
  }
  return buffer.toBytes().toList();
}

/// Builds a synthetic wire-format price feed message.
List<int> buildPriceFeedMessage({
  int price = 3000123456789,
  int confidence = 48765432,
  int exponent = -8,
  int publishTime = 1700000000,
  int prevPublishTime = 1699999900,
}) {
  final buffer = BytesBuilder()
    ..addByte(0) // price feed message variant
    ..add(List.filled(32, 0x07)) // feed id
    ..add(_int64be(BigInt.from(price)))
    ..add(_uint64be(BigInt.from(confidence)))
    ..add(const [0xff, 0xff, 0xff, 0xf8]) // -8 as i32 big-endian
    ..add(_int64be(BigInt.from(publishTime)))
    ..add(_int64be(BigInt.from(prevPublishTime)))
    ..add(_int64be(BigInt.from(price)))
    ..add(_uint64be(BigInt.from(confidence)));
  return buffer.toBytes().toList();
}

Uint8List _int64be(BigInt value) {
  final bytes = Uint8List(8);
  var v = value;
  for (var i = 7; i >= 0; i--) {
    bytes[i] = (v & BigInt.from(0xff)).toInt();
    v >>= 8;
  }
  return bytes;
}

Uint8List _uint64be(BigInt value) {
  final bytes = Uint8List(8);
  var v = value;
  for (var i = 7; i >= 0; i--) {
    bytes[i] = (v & BigInt.from(0xff)).toInt();
    v >>= 8;
  }
  return bytes;
}

const dummyVaa = <int>[1, 0, 0, 0, 3, 1];

void main() {
  group('isAccumulatorUpdateData', () {
    test('detects the PNAU magic and version', () {
      final bytes = buildAccumulatorUpdateData(
        vaa: dummyVaa,
        updates: const [],
      );
      expect(isAccumulatorUpdateData(Uint8List.fromList(bytes)), isTrue);
    });

    test('rejects non-accumulator data', () {
      expect(
        isAccumulatorUpdateData(Uint8List.fromList([1, 2, 3, 4, 5, 6])),
        isFalse,
      );
      expect(
        isAccumulatorUpdateData(
          Uint8List.fromList(const [
            0x50,
            0x4e,
            0x41,
            0x55,
            0x02,
            0x00,
          ]),
        ),
        isFalse,
      );
    });
  });

  group('parseAccumulatorUpdateData', () {
    test('parses a single-update blob', () {
      final message = buildPriceFeedMessage();
      final vaa = Uint8List.fromList([1, 0, 0, 0, 3, 1, 9, 9, 9]);
      final bytes = Uint8List.fromList(
        buildAccumulatorUpdateData(vaa: vaa, updates: [message]),
      );
      final parsed = parseAccumulatorUpdateData(bytes);
      expect(parsed.vaa, vaa);
      expect(parsed.updates, hasLength(1));
      expect(parsed.updates.single.message, message);
      expect(parsed.updates.single.proof, hasLength(1));
      expect(
        parsed.updates.single.proof.single,
        Uint8List.fromList(List<int>.filled(20, 0xA0)),
      );
    });

    test('parses multiple updates', () {
      final bytes = Uint8List.fromList(
        buildAccumulatorUpdateData(
          vaa: dummyVaa,
          updates: const [
            [7, 7],
            [8, 8],
            [9],
          ],
        ),
      );
      final parsed = parseAccumulatorUpdateData(bytes);
      expect(parsed.updates.map((update) => update.message), [
        [7, 7],
        [8, 8],
        [9],
      ]);
    });

    test('rejects trailing bytes', () {
      final bytes = Uint8List.fromList([
        ...buildAccumulatorUpdateData(vaa: dummyVaa, updates: const []),
        0xff,
      ]);
      expect(
        () => parseAccumulatorUpdateData(bytes),
        throwsA(isA<PythDecodeException>()),
      );
    });

    test('rejects wrong magic', () {
      final bytes = Uint8List.fromList(
        buildAccumulatorUpdateData(vaa: dummyVaa, updates: const [])
          ..[3] = 0x58,
      );
      expect(
        () => parseAccumulatorUpdateData(bytes),
        throwsA(isA<PythDecodeException>()),
      );
    });
  });

  group('parsePythPriceFeedMessage', () {
    test('decodes all fields (big-endian wire format)', () {
      final message = parsePythPriceFeedMessage(
        Uint8List.fromList(buildPriceFeedMessage()),
      );
      expect(message.feedId, Uint8List.fromList(List<int>.filled(32, 0x07)));
      expect(message.feedIdHex, '07' * 32);
      expect(message.price, BigInt.from(3000123456789));
      expect(message.confidence, BigInt.from(48765432));
      expect(message.exponent, -8);
      expect(message.publishTime, BigInt.from(1700000000));
      expect(message.prevPublishTime, BigInt.from(1699999900));
      expect(message.emaPrice, BigInt.from(3000123456789));
      expect(message.emaConf, BigInt.from(48765432));
    });

    test('decodes negative prices', () {
      final message = parsePythPriceFeedMessage(
        Uint8List.fromList(buildPriceFeedMessage(price: -42)),
      );
      expect(message.price, BigInt.from(-42));
    });

    test('rejects unknown variants and short messages', () {
      final message = Uint8List.fromList([
        1,
        ...buildPriceFeedMessage().sublist(1),
      ]);
      expect(
        () => parsePythPriceFeedMessage(message),
        throwsA(isA<PythDecodeException>()),
      );
      expect(
        () => parsePythPriceFeedMessage(Uint8List.fromList([0, 1, 2])),
        throwsA(isA<PythDecodeException>()),
      );
    });
  });
}
