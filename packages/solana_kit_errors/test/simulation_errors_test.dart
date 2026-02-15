import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:test/test.dart';

void main() {
  group('unwrapSimulationError', () {
    test('unwraps preflight failure error with cause', () {
      final cause = SolanaError(
        SolanaErrorCode.transactionErrorBlockhashNotFound,
      );
      final error = SolanaError(
        SolanaErrorCode.jsonRpcServerErrorSendTransactionPreflightFailure,
        {'cause': cause, 'logs': <String>[]},
      );
      final unwrapped = unwrapSimulationError(error);
      expect(unwrapped, same(cause));
    });

    test('unwraps compute limit estimation error with cause', () {
      final cause = SolanaError(
        SolanaErrorCode.transactionErrorBlockhashNotFound,
      );
      final error = SolanaError(
        SolanaErrorCode.transactionFailedWhenSimulatingToEstimateComputeLimit,
        {'cause': cause},
      );
      final unwrapped = unwrapSimulationError(error);
      expect(unwrapped, same(cause));
    });

    test('returns original error if not simulation error', () {
      final error = SolanaError(SolanaErrorCode.blockHeightExceeded);
      final unwrapped = unwrapSimulationError(error);
      expect(unwrapped, same(error));
    });

    test('returns original error if simulation error has no cause', () {
      final error = SolanaError(
        SolanaErrorCode.jsonRpcServerErrorSendTransactionPreflightFailure,
        {'logs': <String>[]},
      );
      final unwrapped = unwrapSimulationError(error);
      expect(unwrapped, same(error));
    });

    test('returns non-SolanaError unchanged', () {
      final error = Exception('test');
      expect(unwrapSimulationError(error), same(error));
    });

    test('returns null unchanged', () {
      expect(unwrapSimulationError(null), isNull);
    });
  });
}
