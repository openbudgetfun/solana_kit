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

    test('accepts BigInt error codes from bigint-aware transports', () {
      final error = getSolanaErrorFromJsonRpcError({
        'code': BigInt.from(-32602),
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

    test('converts unknown JSON-RPC code to malformed error', () {
      final error = getSolanaErrorFromJsonRpcError({
        'code': -39999,
        'message': 'Unknown server error',
      });
      expect(error.code, SolanaErrorCode.malformedJsonRpcError);
      expect(error.context['message'], 'Unknown server error');
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
      expect(error.context['fee'], isNull);
      expect(error.context['loadedAddresses'], isNull);
      expect(error.context['postBalances'], isNull);
      expect(error.context['postTokenBalances'], isNull);
      expect(error.context['preBalances'], isNull);
      expect(error.context['preTokenBalances'], isNull);
    });

    test('preserves Agave preflight metadata when present', () {
      final error = getSolanaErrorFromJsonRpcError({
        'code': -32002,
        'message': 'Transaction simulation failed',
        'data': {
          'err': 'BlockhashNotFound',
          'accounts': ['account'],
          'fee': 5000,
          'innerInstructions': ['inner'],
          'loadedAccountsDataSize': 32,
          'loadedAddresses': {'writable': <String>[], 'readonly': <String>[]},
          'logs': <String>[],
          'postBalances': [1],
          'postTokenBalances': ['postToken'],
          'preBalances': [2],
          'preTokenBalances': ['preToken'],
          'replacementBlockhash': {'blockhash': 'replacement'},
          'returnData': {'programId': 'program'},
          'unitsConsumed': 12,
        },
      });

      expect(error.context['accounts'], ['account']);
      expect(error.context['fee'], 5000);
      expect(error.context['loadedAddresses'], {
        'writable': <String>[],
        'readonly': <String>[],
      });
      expect(error.context['postBalances'], [1]);
      expect(error.context['postTokenBalances'], ['postToken']);
      expect(error.context['preBalances'], [2]);
      expect(error.context['preTokenBalances'], ['preToken']);
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

    test('converts preflight failure without data', () {
      final error = getSolanaErrorFromJsonRpcError({
        'code': -32002,
        'message': 'Transaction simulation failed',
      });
      expect(
        error.code,
        SolanaErrorCode.jsonRpcServerErrorSendTransactionPreflightFailure,
      );
      expect(error.context['logs'], isNull);
    });

    test('converts malformed error response', () {
      final error = getSolanaErrorFromJsonRpcError({'unexpected': 'format'});
      expect(error.code, SolanaErrorCode.malformedJsonRpcError);
    });

    test('preserves message from malformed error response', () {
      final error = getSolanaErrorFromJsonRpcError({'message': 'No code'});
      expect(error.code, SolanaErrorCode.malformedJsonRpcError);
      expect(error.context['message'], 'No code');
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
