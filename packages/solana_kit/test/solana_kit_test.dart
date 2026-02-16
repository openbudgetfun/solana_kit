import 'package:solana_kit/solana_kit.dart';
import 'package:test/test.dart';

void main() {
  group('solana_kit umbrella exports', () {
    test('re-exports Address from solana_kit_addresses', () {
      const address = Address('11111111111111111111111111111111');
      expect(address.toString(), '11111111111111111111111111111111');
    });

    test('re-exports SolanaError from solana_kit_errors', () {
      final error = SolanaError(1);
      expect(error.code, 1);
    });

    test('re-exports Instruction from solana_kit_instructions', () {
      const instruction = Instruction(
        programAddress: Address('11111111111111111111111111111111'),
      );
      expect(instruction.programAddress, isNotNull);
    });

    test(
      're-exports TransactionMessage from solana_kit_transaction_messages',
      () {
        const message = TransactionMessage(
          version: TransactionVersion.v0,
          feePayer: Address('11111111111111111111111111111111'),
        );
        expect(message.version, TransactionVersion.v0);
      },
    );

    test('re-exports Lamports from solana_kit_rpc_types', () {
      final lamports = Lamports(BigInt.from(1000000));
      expect(lamports.value, BigInt.from(1000000));
    });

    test('re-exports pipe from solana_kit_functional', () {
      final result = 1.pipe((int n) => n + 1).pipe((int n) => n * 2);
      expect(result, 4);
    });
  });

  group('getMinimumBalanceForRentExemption', () {
    test('calculates rent exemption for 0 bytes', () {
      final lamports = getMinimumBalanceForRentExemption(0);
      // (128 + 0) * 3480 * 2 = 890880
      expect(lamports.value, BigInt.from(890880));
    });

    test('calculates rent exemption for 165 bytes (token account)', () {
      final lamports = getMinimumBalanceForRentExemption(165);
      // (128 + 165) * 3480 * 2 = 2039280
      expect(lamports.value, BigInt.from(2039280));
    });

    test('calculates rent exemption for 200 bytes', () {
      final lamports = getMinimumBalanceForRentExemption(200);
      // (128 + 200) * 3480 * 2 = 2282880
      expect(lamports.value, BigInt.from(2282880));
    });

    test('matches known Solana token account rent exemption', () {
      // The well-known rent exemption for a token account (165 bytes) is
      // 2039280 lamports.
      final lamports = getMinimumBalanceForRentExemption(165);
      expect(lamports.value, BigInt.from(2039280));
    });
  });
}
