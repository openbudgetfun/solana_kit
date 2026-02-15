import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:test/test.dart';

void main() {
  group('getSolanaErrorFromJsonRpcError', () {
    test('converts standard JSON-RPC internal error', () {
      final error = getSolanaErrorFromJsonRpcError({
        'code': -32603,
        'message': 'Internal error',
      });
      expect(error.code, SolanaErrorCode.jsonRpcInternalError);
      expect(error.context['__serverMessage'], 'Internal error');
    });

    test('converts invalid params error', () {
      final error = getSolanaErrorFromJsonRpcError({
        'code': -32602,
        'message': 'Invalid params',
      });
      expect(error.code, SolanaErrorCode.jsonRpcInvalidParams);
    });

    test('converts parse error', () {
      final error = getSolanaErrorFromJsonRpcError({
        'code': -32700,
        'message': 'Parse error',
      });
      expect(error.code, SolanaErrorCode.jsonRpcParseError);
    });

    test('converts preflight failure with transaction error cause', () {
      final error = getSolanaErrorFromJsonRpcError({
        'code': -32002,
        'message': 'Transaction simulation failed',
        'data': {
          'err': 'BlockhashNotFound',
          'logs': <String>[],
          'unitsConsumed': 0,
        },
      });
      expect(
        error.code,
        SolanaErrorCode.jsonRpcServerErrorSendTransactionPreflightFailure,
      );
      expect(error.context['cause'], isA<SolanaError>());
    });

    test('converts preflight failure without transaction error', () {
      final error = getSolanaErrorFromJsonRpcError({
        'code': -32002,
        'message': 'Transaction simulation failed',
        'data': {'err': null, 'logs': <String>[]},
      });
      expect(
        error.code,
        SolanaErrorCode.jsonRpcServerErrorSendTransactionPreflightFailure,
      );
    });

    test('converts malformed error response', () {
      final error = getSolanaErrorFromJsonRpcError({'unexpected': 'format'});
      expect(error.code, SolanaErrorCode.malformedJsonRpcError);
    });

    test('converts null error response', () {
      final error = getSolanaErrorFromJsonRpcError(null);
      expect(error.code, SolanaErrorCode.malformedJsonRpcError);
    });

    test('handles server error with object data', () {
      final error = getSolanaErrorFromJsonRpcError({
        'code': -32017,
        'message': 'Epoch rewards period active',
        'data': {
          'currentBlockHeight': 100,
          'rewardsCompleteBlockHeight': 200,
          'slot': 50,
        },
      });
      expect(
        error.code,
        SolanaErrorCode.jsonRpcServerErrorEpochRewardsPeriodActive,
      );
    });
  });
}
