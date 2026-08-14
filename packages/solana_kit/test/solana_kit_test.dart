import 'package:solana_kit/solana_kit.dart';
import 'package:test/test.dart';

void main() {
  group('solana_kit umbrella exports', () {
    test('re-exports Address from solana_kit_addresses', () {
      const address = Address('11111111111111111111111111111111');
      expect(address.toString(), '11111111111111111111111111111111');
    });

    test('re-exports SolanaError from solana_kit_errors', () {
      final error = SolanaError(SolanaErrorCode.blockHeightExceeded);
      expect(error.code, SolanaErrorCode.blockHeightExceeded);
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

    test('re-exports pipe via solana_kit_transaction_messages', () {
      final result = 1.pipe((n) => n + 1).pipe((n) => n * 2);
      expect(result, 4);
    });
  });

  // The local `getMinimumBalanceForRentExemption` helper was removed in
  // @solana/kit v7.0.0 because rent exemption is becoming dynamic (see
  // SIMD-0437/0194/0389). Use the `getMinimumBalanceForRentExemption` RPC
  // method (via `solana_kit_rpc_api`) or a `ClientWithGetMinimumBalance`
  // plugin instead.
}
