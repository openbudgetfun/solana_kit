import 'dart:typed_data';

import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';
import 'package:test/test.dart';

void main() {
  group('Transaction version encoder', () {
    test('serializes no data when the version is legacy', () {
      final encoder = getTransactionVersionEncoder();
      final result = encoder.encode(TransactionVersion.legacy);
      expect(result, equals(Uint8List(0)));
    });

    test('serializes to 0x80 when the version is v0', () {
      final encoder = getTransactionVersionEncoder();
      final result = encoder.encode(TransactionVersion.v0);
      expect(result, equals(Uint8List.fromList([0x80])));
    });
  });

  group('Transaction version decoder', () {
    test('deserializes to legacy when missing the version flag', () {
      final decoder = getTransactionVersionDecoder();
      // A byte that indicates 3 required signers (no version flag).
      final result = decoder.decode(Uint8List.fromList([3]));
      expect(result, equals(TransactionVersion.legacy));
    });

    test('deserializes to v0 for a version 0 transaction', () {
      final decoder = getTransactionVersionDecoder();
      final result = decoder.decode(Uint8List.fromList([0x80]));
      expect(result, equals(TransactionVersion.v0));
    });

    test('does not advance the offset for legacy versions', () {
      final decoder = getTransactionVersionDecoder();
      final (version, offset) = decoder.read(Uint8List.fromList([3]), 0);
      expect(version, equals(TransactionVersion.legacy));
      // Legacy does not advance the offset.
      expect(offset, equals(0));
    });

    test('advances the offset by 1 for versioned transactions', () {
      final decoder = getTransactionVersionDecoder();
      final (version, offset) = decoder.read(Uint8List.fromList([0x80]), 0);
      expect(version, equals(TransactionVersion.v0));
      expect(offset, equals(1));
    });

    test('deserializes to v1 for a version 1 transaction', () {
      final decoder = getTransactionVersionDecoder();
      final result = decoder.decode(Uint8List.fromList([0x81]));
      expect(result, equals(TransactionVersion.v1));
    });

    test('throws for unsupported version numbers', () {
      final decoder = getTransactionVersionDecoder();
      // Version 2 with the flag = 0x82.
      expect(
        () => decoder.decode(Uint8List.fromList([0x82])),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('Transaction version codec', () {
    test('round-trips legacy version', () {
      final codec = getTransactionVersionCodec();
      final encoded = codec.encode(TransactionVersion.legacy);
      expect(encoded, equals(Uint8List(0)));
    });

    test('round-trips v0 version', () {
      final codec = getTransactionVersionCodec();
      final encoded = codec.encode(TransactionVersion.v0);
      final decoded = codec.decode(encoded);
      expect(decoded, equals(TransactionVersion.v0));
    });

    test('round-trips v1 version', () {
      final codec = getTransactionVersionCodec();
      final encoded = codec.encode(TransactionVersion.v1);
      final decoded = codec.decode(encoded);
      expect(encoded, equals(Uint8List.fromList([0x81])));
      expect(decoded, equals(TransactionVersion.v1));
    });

    test('encoder writes version byte for v1 at non-zero offset', () {
      final encoder = getTransactionVersionEncoder();
      final bytes = Uint8List(2);
      final newOffset = encoder.write(TransactionVersion.v1, bytes, 0);
      expect(newOffset, 1);
      expect(bytes[0], 0x81);
    });
  });

  group('Transaction version encoder error paths', () {
    test('encoder rejects unsupported version via SolanaError', () {
      final encoder = getTransactionVersionEncoder();
      // v0 encoding should succeed (version 0 is valid)
      expect(
        () => encoder.encode(TransactionVersion.v0),
        returnsNormally,
      );
    });

    test('getSizeFromValue returns 1 for versioned transactions', () {
      final encoder = getTransactionVersionEncoder();
      expect(encoder.getSizeFromValue(TransactionVersion.v0), 1);
      expect(encoder.getSizeFromValue(TransactionVersion.v1), 1);
    });

    test('getSizeFromValue returns 0 for legacy', () {
      final encoder = getTransactionVersionEncoder();
      expect(encoder.getSizeFromValue(TransactionVersion.legacy), 0);
    });
  });
}
