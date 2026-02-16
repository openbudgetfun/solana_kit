import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:solana_kit_sysvars/solana_kit_sysvars.dart';
import 'package:test/test.dart';

void main() {
  group('rent', () {
    test('decode', () {
      // From TS test: rent-test.ts
      final rentState = Uint8List.fromList([
        // lamportsPerByteYear
        0, 225, 245, 5, 0, 0, 0, 0,
        // exemptionThreshold (f64: same bytes as lamportsPerByteYear)
        0, 225, 245, 5, 0, 0, 0, 0,
        // burnPercent
        8,
      ]);

      final result = getSysvarRentCodec().decode(rentState);
      expect(
        result.lamportsPerByteYear,
        equals(Lamports(BigInt.from(100000000))),
      );
      // The TS test expects 4.94065646e-316 which is a very small f64 value
      // produced by interpreting the bytes 0x00e1f50500000000 as a float64.
      expect(result.exemptionThreshold, closeTo(4.94065646e-316, 1e-322));
      expect(result.burnPercent, equals(8));
    });

    test('encode roundtrip', () {
      final rent = SysvarRent(
        lamportsPerByteYear: Lamports(BigInt.from(3480)),
        exemptionThreshold: 2,
        burnPercent: 50,
      );

      final codec = getSysvarRentCodec();
      final encoded = codec.encode(rent);
      final decoded = codec.decode(encoded);

      expect(decoded.lamportsPerByteYear, equals(rent.lamportsPerByteYear));
      expect(decoded.exemptionThreshold, equals(rent.exemptionThreshold));
      expect(decoded.burnPercent, equals(rent.burnPercent));
    });

    test('encoder has correct fixed size', () {
      final encoder = getSysvarRentEncoder();
      expect(encoder.fixedSize, equals(sysvarRentSize));
      expect(encoder.fixedSize, equals(17));
      expect(isFixedSize(encoder), isTrue);
    });

    test('SysvarRent equality', () {
      final a = SysvarRent(
        lamportsPerByteYear: Lamports(BigInt.from(3480)),
        exemptionThreshold: 2,
        burnPercent: 50,
      );
      final b = SysvarRent(
        lamportsPerByteYear: Lamports(BigInt.from(3480)),
        exemptionThreshold: 2,
        burnPercent: 50,
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });
}
