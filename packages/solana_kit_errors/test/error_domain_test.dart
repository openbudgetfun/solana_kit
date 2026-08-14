import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:test/test.dart';

void main() {
  group('getSolanaErrorDomain', () {
    test('classifies JSON-RPC codes', () {
      expect(
        getSolanaErrorDomain(SolanaErrorCode.jsonRpcInternalError),
        SolanaErrorDomain.jsonRpc,
      );
    });

    test('classifies transaction codes', () {
      expect(
        getSolanaErrorDomain(SolanaErrorCode.transactionSignaturesMissing),
        SolanaErrorDomain.transaction,
      );
    });

    test('classifies subscribable codes', () {
      expect(
        getSolanaErrorDomain(SolanaErrorCode.subscribableRetryNotSupported),
        SolanaErrorDomain.subscribable,
      );
    });

    test('classifies wallet codes', () {
      expect(
        getSolanaErrorDomain(SolanaErrorCode.walletAccountNotAvailable),
        SolanaErrorDomain.wallet,
      );
    });

    test('classifies new JSON-RPC server codes', () {
      expect(
        getSolanaErrorDomain(
          SolanaErrorCode.jsonRpcServerErrorNoSlotHistory,
        ),
        SolanaErrorDomain.jsonRpc,
      );
    });

    test('classifies new transaction estimation codes', () {
      expect(
        getSolanaErrorDomain(
          SolanaErrorCode
              .transactionFailedToEstimateLoadedAccountsDataSizeLimit,
        ),
        SolanaErrorDomain.transaction,
      );
    });

    test('classifies codecs codes', () {
      expect(
        getSolanaErrorDomain(SolanaErrorCode.codecsUnionVariantOutOfRange),
        SolanaErrorDomain.codecs,
      );
    });

    // Added in @solana/kit v7.0.0: the configurable instruction-count limit on
    // transaction planners and message packers.
    test('classifies new instruction-plans max-instructions codes', () {
      expect(
        getSolanaErrorDomain(
          SolanaErrorCode.instructionPlansMaxInstructionsPerTransactionExceeded,
        ),
        SolanaErrorDomain.instructionPlans,
      );
      expect(
        getSolanaErrorDomain(
          SolanaErrorCode.instructionPlansInvalidMaxInstructionsPerTransaction,
        ),
        SolanaErrorDomain.instructionPlans,
      );
    });

    // Added in @solana/kit v7.0.0 for the new transaction-introspection package.
    test('classifies new transaction-introspection codes', () {
      expect(
        getSolanaErrorDomain(
          SolanaErrorCode
              .transactionIntrospectionCannotDecodeJsonParsedTransaction,
        ),
        SolanaErrorDomain.transactionIntrospection,
      );
      expect(
        getSolanaErrorDomain(
          SolanaErrorCode
              .transactionIntrospectionUnrecognizedGetTransactionResponse,
        ),
        SolanaErrorDomain.transactionIntrospection,
      );
    });

    test('classifies new transaction decompile account index code', () {
      expect(
        getSolanaErrorDomain(
          SolanaErrorCode
              .transactionFailedToDecompileInstructionAccountIndexOutOfRange,
        ),
        SolanaErrorDomain.transaction,
      );
    });

    // Note: SolanaErrorDomain.unknown is only reachable via getSolanaErrorDomain
    // for enum values whose numeric value falls outside all known ranges.
    // All current enum members map to a known domain.
  });

  group('domain helpers', () {
    test('classifies SolanaError instances by domain', () {
      final error = SolanaError(SolanaErrorCode.rpcTransportHttpError, {
        'statusCode': 500,
      });

      expect(error.domain, SolanaErrorDomain.rpc);
      expect(error.isInDomain(SolanaErrorDomain.rpc), isTrue);
      expect(isSolanaErrorInDomain(error, SolanaErrorDomain.rpc), isTrue);
      expect(
        isSolanaErrorInDomain(error, SolanaErrorDomain.transaction),
        isFalse,
      );
    });

    test('classifies raw code extension helpers', () {
      expect(
        SolanaErrorCode.heliusRpcError.solanaErrorDomain,
        SolanaErrorDomain.helius,
      );
      expect(
        SolanaErrorCode.heliusRpcError.isSolanaErrorDomain(
          SolanaErrorDomain.helius,
        ),
        isTrue,
      );
    });

    test('isSolanaErrorCodeInDomain returns true for matching domain', () {
      expect(
        isSolanaErrorCodeInDomain(
          SolanaErrorCode.jsonRpcInternalError,
          SolanaErrorDomain.jsonRpc,
        ),
        isTrue,
      );
    });

    test('isSolanaErrorCodeInDomain returns false for non-matching domain', () {
      expect(
        isSolanaErrorCodeInDomain(
          SolanaErrorCode.jsonRpcInternalError,
          SolanaErrorDomain.transaction,
        ),
        isFalse,
      );
    });

    test('isSolanaErrorInDomain returns false for non-SolanaError', () {
      expect(
        isSolanaErrorInDomain('not a SolanaError', SolanaErrorDomain.rpc),
        isFalse,
      );
    });
  });
}
