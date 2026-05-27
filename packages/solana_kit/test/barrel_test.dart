import 'package:solana_kit/solana_kit.dart';
import 'package:test/test.dart';

void main() {
  group('solana_kit barrel', () {
    test('re-exports core SDK symbols', () {
      const address = Address('11111111111111111111111111111111');
      final error = SolanaError(SolanaErrorCode.accountsAccountNotFound);
      final lamports = Lamports(BigInt.one);
      final fixedPoint = decimalFixedPoint(
        FixedPointSignedness.unsigned,
        64,
        2,
      )('1.23');

      expect(address.value, '11111111111111111111111111111111');
      expect(error.code, SolanaErrorCode.accountsAccountNotFound);
      expect(lamports.value, BigInt.one);
      expect(fixedPoint.raw, BigInt.from(123));
    });

    test('re-exports pipe via transaction messages', () {
      final result = 'kit'.pipe((value) => value.toUpperCase());
      expect(result, 'KIT');
    });
  });
}
