import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_rpc_spec_types/solana_kit_rpc_spec_types.dart';
import 'package:solana_kit_rpc_transformers/solana_kit_rpc_transformers.dart';
import 'package:test/test.dart';

void main() {
  group('getThrowSolanaErrorResponseTransformer', () {
    const request = RpcRequest<Object?>(methodName: 'getBalance', params: null);

    group('when the response contains a result', () {
      test('returns the response as-is', () {
        final transformer = getThrowSolanaErrorResponseTransformer();
        final response = <String, Object?>{
          'result': {'value': BigInt.from(123)},
        };

        final result = transformer(response, request);

        expect(result, equals(response));
      });

      test('returns complex result objects unchanged', () {
        final transformer = getThrowSolanaErrorResponseTransformer();
        final response = <String, Object?>{
          'result': {
            'context': {'slot': BigInt.from(123)},
            'value': [
              {'account': 'test', 'lamports': BigInt.from(456)},
            ],
          },
        };

        final result = transformer(response, request);

        expect(result, equals(response));
      });
    });

    group('when the response contains an error', () {
      test('throws a SolanaError for a standard RPC error', () {
        final transformer = getThrowSolanaErrorResponseTransformer();
        final errorResponse = <String, Object?>{
          'error': {'code': -32600, 'message': 'Invalid Request'},
        };

        expect(
          () => transformer(errorResponse, request),
          throwsA(isA<SolanaError>()),
        );
      });

      test('throws with correct error code', () {
        final transformer = getThrowSolanaErrorResponseTransformer();
        final errorResponse = <String, Object?>{
          'error': {'code': -32700, 'message': 'Parse error'},
        };

        try {
          transformer(errorResponse, request);
          fail('Expected SolanaError to be thrown');
        } on SolanaError catch (e) {
          expect(e.code, SolanaErrorCode.jsonRpcParseError);
        }
      });
    });

    group('when the response contains a sendTransaction preflight failure', () {
      test('transforms BigInt values in error.data before throwing for '
          'numeric error code', () {
        final transformer = getThrowSolanaErrorResponseTransformer();
        final errorResponse = <String, Object?>{
          'error': {
            'code': -32002,
            'message': 'Transaction simulation failed',
            'data': {
              'accounts': null,
              'err': 'InsufficientFundsForRent',
              'innerInstructions': null,
              'loadedAccountsDataSize': BigInt.from(100),
              'logs': ['log1', 'log2'],
              'replacementBlockhash': null,
              'returnData': null,
              'unitsConsumed': BigInt.from(5000),
            },
          },
        };

        try {
          transformer(errorResponse, request);
          fail('Expected SolanaError to be thrown');
        } on SolanaError catch (e) {
          expect(
            e.code,
            SolanaErrorCode.jsonRpcServerErrorSendTransactionPreflightFailure,
          );
        }
      });

      test('handles preflight failure without data field', () {
        final transformer = getThrowSolanaErrorResponseTransformer();
        final errorResponse = <String, Object?>{
          'error': {'code': -32002, 'message': 'Transaction simulation failed'},
        };

        expect(
          () => transformer(errorResponse, request),
          throwsA(isA<SolanaError>()),
        );
      });

      test('handles preflight failure with null data', () {
        final transformer = getThrowSolanaErrorResponseTransformer();
        final errorResponse = <String, Object?>{
          'error': {
            'code': -32002,
            'data': null,
            'message': 'Transaction simulation failed',
          },
        };

        expect(
          () => transformer(errorResponse, request),
          throwsA(isA<SolanaError>()),
        );
      });
    });

    group('edge cases', () {
      test('handles error without code property', () {
        final transformer = getThrowSolanaErrorResponseTransformer();
        final errorResponse = <String, Object?>{
          'error': {'message': 'Something went wrong'},
        };

        expect(
          () => transformer(errorResponse, request),
          throwsA(isA<SolanaError>()),
        );
      });

      test('handles null error', () {
        final transformer = getThrowSolanaErrorResponseTransformer();
        final errorResponse = <String, Object?>{'error': null};

        expect(
          () => transformer(errorResponse, request),
          throwsA(isA<SolanaError>()),
        );
      });

      test('handles error code that is not -32002', () {
        final transformer = getThrowSolanaErrorResponseTransformer();
        final errorResponse = <String, Object?>{
          'error': {'code': -32603, 'message': 'Internal error'},
        };

        expect(
          () => transformer(errorResponse, request),
          throwsA(isA<SolanaError>()),
        );
      });
    });
  });
}
