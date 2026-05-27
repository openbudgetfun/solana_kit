import 'dart:typed_data';

import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:test/test.dart';

void main() {
  group('sol', () {
    test('parses whole and fractional SOL values', () {
      expect(sol('1').raw, BigInt.from(1000000000));
      expect(sol('1.5').raw, BigInt.from(1500000000));
      expect(sol('.000000001').raw, BigInt.one);
    });

    test(
      'rejects negative, malformed, and precision-losing values by default',
      () {
        expect(() => sol('-1'), throwsFormatException);
        expect(() => sol('1.2.3'), throwsFormatException);
        expect(() => sol('abc'), throwsFormatException);
        expect(() => sol('1.0000000001'), throwsFormatException);
      },
    );

    test('supports explicit rounding modes', () {
      expect(
        sol('1.0000000009', rounding: RoundingMode.down).raw,
        BigInt.from(1000000000),
      );
      expect(
        sol('1.0000000001', rounding: RoundingMode.up).raw,
        BigInt.from(1000000001),
      );
      expect(
        sol('1.0000000005', rounding: RoundingMode.halfUp).raw,
        BigInt.from(1000000001),
      );
      expect(
        sol('1.0000000004', rounding: RoundingMode.halfUp).raw,
        BigInt.from(1000000000),
      );
    });
  });

  group('Sol', () {
    test('formats to a decimal string', () {
      expect(sol('0').toDecimalString(), '0');
      expect(sol('1.5').toDecimalString(), '1.5');
      expect(sol('0.000000001').toDecimalString(), '0.000000001');
    });
  });

  group('SOL and Lamports conversions', () {
    test('convert losslessly', () {
      final solValue = sol('2.25');
      final lamportsValue = solToLamports(solValue);

      expect(lamportsValue.value, BigInt.from(2250000000));
      expect(lamportsToSol(lamportsValue).raw, solValue.raw);
    });
  });

  group('getSolEncoder', () {
    test('encodes SOL and Lamports values as little-endian u64 lamports', () {
      final encoder = getSolEncoder();

      expect(encoder.fixedSize, 8);
      expect(
        encoder.encode(sol('1')),
        Uint8List.fromList([0, 202, 154, 59, 0, 0, 0, 0]),
      );
      expect(
        encoder.encode(lamports(BigInt.from(500))),
        Uint8List.fromList([244, 1, 0, 0, 0, 0, 0, 0]),
      );
    });

    test('rejects unsupported values', () {
      expect(() => getSolEncoder().encode('1'), throwsArgumentError);
    });
  });

  group('getSolDecoder', () {
    test('decodes little-endian u64 lamports as SOL', () {
      final decoder = getSolDecoder();
      final decoded = decoder.decode(
        Uint8List.fromList([0, 202, 154, 59, 0, 0, 0, 0]),
      );

      expect(decoder.fixedSize, 8);
      expect(decoded.raw, BigInt.from(1000000000));
    });
  });

  group('getSolCodec', () {
    test('encodes SOL and decodes SOL', () {
      final codec = getSolCodec();
      final encoded = codec.encode(sol('0.000000001'));
      final decoded = codec.decode(encoded);

      expect(encoded, Uint8List.fromList([1, 0, 0, 0, 0, 0, 0, 0]));
      expect(decoded.raw, BigInt.one);
    });
  });
}
