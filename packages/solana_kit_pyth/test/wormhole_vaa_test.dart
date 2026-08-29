import 'dart:typed_data';

import 'package:solana_kit_pyth/solana_kit_pyth.dart';
import 'package:test/test.dart';

/// Builds a synthetic Wormhole VAA (v1) for testing.
Uint8List buildVaa({
  required int guardianSetIndex,
  required int signatureCount,
  required Uint8List payload,
  int version = 1,
  int timestamp = 1700000000,
  int nonce = 42,
  int emitterChain = emitterChainPythnet,
  List<int> emitterAddress = const [0xAA],
  int sequence = 123456789,
  int consistencyLevel = 1,
}) {
  final buffer = BytesBuilder()
    ..addByte(version)
    ..addUint32BE(guardianSetIndex)
    ..addByte(signatureCount);
  for (var i = 0; i < signatureCount; i++) {
    buffer
      ..addByte(i) // guardian index
      ..add(Uint8List.fromList(List.filled(64, 0x42 + i)))
      ..addByte(0); // recovery id
  }
  buffer
    ..addUint32BE(timestamp)
    ..addUint32BE(nonce)
    ..addByte(emitterChain >> 8)
    ..addByte(emitterChain & 0xff)
    ..add(Uint8List.fromList(List.filled(32, emitterAddress.first)))
    ..add(_uint64be(BigInt.from(sequence)))
    ..addByte(consistencyLevel)
    ..add(payload);
  return buffer.toBytes();
}

extension _BytesBuilderX on BytesBuilder {
  void addUint32BE(int value) {
    addByte((value >> 24) & 0xff);
    addByte((value >> 16) & 0xff);
    addByte((value >> 8) & 0xff);
    addByte(value & 0xff);
  }
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

void main() {
  group('parseWormholeVaa', () {
    final payload = Uint8List.fromList([0x01, 0x01, ...List.filled(20, 0x10)]);
    final vaaBytes = buildVaa(
      guardianSetIndex: 3,
      signatureCount: 2,
      payload: payload,
    );

    test('decodes header fields', () {
      final vaa = parseWormholeVaa(vaaBytes);
      expect(vaa.version, 1);
      expect(vaa.guardianSetIndex, 3);
      expect(vaa.signatureCount, 2);
      expect(vaa.timestamp, 1700000000);
      expect(vaa.nonce, 42);
      expect(vaa.emitterChain, emitterChainPythnet);
      expect(vaa.consistencyLevel, 1);
      expect(
        vaa.emitterAddress,
        Uint8List.fromList(List<int>.filled(32, 0xAA)),
      );
    });

    test('decodes signatures in order', () {
      final vaa = parseWormholeVaa(vaaBytes);
      final first = vaa.signatures.first;
      final second = vaa.signatures.last;
      expect(first.guardianIndex, 0);
      expect(first.recoveryId, 0);
      expect(first.signature, everyElement(0x42));
      expect(second.guardianIndex, 1);
      expect(second.signature, everyElement(0x43));
    });

    test('decodes sequence and payload', () {
      final vaa = parseWormholeVaa(vaaBytes);
      expect(vaa.sequence, BigInt.from(123456789));
      expect(vaa.payload, payload);
    });

    test('renders signature debug representations', () {
      final vaa = parseWormholeVaa(vaaBytes);
      expect(
        vaa.signatures.first.toString(),
        'WormholeVaaSignature(guardianIndex: 0, recoveryId: 0)',
      );
      expect(
        vaa.signatures.last.toString(),
        'WormholeVaaSignature(guardianIndex: 1, recoveryId: 0)',
      );
    });

    test('renders an envelope debug representation', () {
      final vaa = parseWormholeVaa(vaaBytes);
      expect(
        vaa.toString(),
        'WormholeVaa(version: 1, guardianSetIndex: 3, signatures: 2, '
        'emitterChain: 26, sequence: 123456789)',
      );
    });

    test('rejects VAAs truncated inside a signature', () {
      final truncated = vaaBytes.sublist(0, 6 + vaaSignatureSize + 10);
      expect(
        () => parseWormholeVaa(truncated),
        throwsA(
          isA<PythDecodeException>().having(
            (e) => e.message,
            'message',
            'VAA is truncated inside signature 1 of 2',
          ),
        ),
      );
    });

    test(
      'getGuardianSetIndex and getVaaSignatureCount agree with the parse',
      () {
        expect(getGuardianSetIndex(vaaBytes), 3);
        expect(getVaaSignatureCount(vaaBytes), 2);
      },
    );

    test('rejects truncated data', () {
      expect(
        () => parseWormholeVaa(Uint8List.fromList([1, 0])),
        throwsA(isA<PythDecodeException>()),
      );
    });

    test('rejects unknown versions', () {
      final vaa = buildVaa(
        guardianSetIndex: 0,
        signatureCount: 1,
        payload: payload,
        version: 2,
      );
      expect(() => parseWormholeVaa(vaa), throwsA(isA<PythDecodeException>()));
    });
  });

  group('trimVaaSignatures', () {
    test('reduces the signature count to the target', () {
      final vaa = buildVaa(
        guardianSetIndex: 7,
        signatureCount: 13,
        payload: Uint8List.fromList([1, 2, 3]),
      );
      final trimmed = trimVaaSignatures(vaa);
      expect(trimmed[5], 5);
      expect(parseWormholeVaa(trimmed).signatureCount, 5);
      expect(
        trimmed.sublist(6 + 5 * vaaSignatureSize),
        vaa.sublist(6 + 13 * vaaSignatureSize),
      );
      // The kept signatures must be verbatim copies of the original ones
      // (byte 5, the signature count, is intentionally rewritten).
      expect(
        trimmed.sublist(0, 5),
        vaa.sublist(0, 5),
      );
      expect(
        trimmed.sublist(6, 6 + 5 * vaaSignatureSize),
        vaa.sublist(6, 6 + 5 * vaaSignatureSize),
      );
    });

    test('uses the default reduced guardian set size of 5', () {
      final vaa = buildVaa(
        guardianSetIndex: 0,
        signatureCount: 9,
        payload: Uint8List(0),
      );
      final trimmed = trimVaaSignatures(vaa);
      expect(trimmed[5], defaultReducedGuardianSetSize);
    });

    test('returns the input untouched when already small enough', () {
      final vaa = buildVaa(
        guardianSetIndex: 0,
        signatureCount: 4,
        payload: Uint8List(0),
      );
      expect(identical(trimVaaSignatures(vaa), vaa), isTrue);
    });
  });

  group('parsePythWormholeMessage', () {
    test('parses a merkle root payload', () {
      final root = Uint8List.fromList(List.filled(20, 0x55));
      final payload = Uint8List.fromList([0x01, 0x01, ...root]);
      final message = parsePythWormholeMessage(payload);
      expect(message.version, 1);
      expect(message.kind, PythWormholeMessageKind.merkleRoot);
      expect(message.merkleRoot, root);
    });

    test('recognizes accumulator payloads', () {
      final message = parsePythWormholeMessage(
        Uint8List.fromList([0x01, 0x02, 0x50, 0x4e, 0x41, 0x55]),
      );
      expect(message.kind, PythWormholeMessageKind.accumulator);
      expect(message.merkleRoot, isNull);
    });

    test('rejects unknown kinds', () {
      expect(
        () => parsePythWormholeMessage(Uint8List.fromList([0x01, 0x09])),
        throwsA(isA<PythDecodeException>()),
      );
    });

    test('renders a debug representation', () {
      final merkleMessage = parsePythWormholeMessage(
        Uint8List.fromList([0x01, 0x01, ...List.filled(20, 0x10)]),
      );
      expect(
        merkleMessage.toString(),
        'PythWormholeMessage(version: 1, kind: merkleRoot)',
      );
      final accumulatorMessage = parsePythWormholeMessage(
        Uint8List.fromList([0x01, 0x02, 0x50, 0x4e, 0x41, 0x55]),
      );
      expect(
        accumulatorMessage.toString(),
        'PythWormholeMessage(version: 1, kind: accumulator)',
      );
    });
  });
}
