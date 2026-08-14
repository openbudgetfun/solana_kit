// ignore_for_file: use_raw_strings
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:test/test.dart';

void main() {
  group('solanaErrorMessages (new codes)', () {
    test(
      'jsonRpcServerErrorNoSlotHistory message contains \$__serverMessage',
      () {
        final message =
            solanaErrorMessages[SolanaErrorCode
                .jsonRpcServerErrorNoSlotHistory];
        expect(message, isNotNull);
        expect(message, contains(r'$__serverMessage'));
      },
    );

    test(
      'jsonRpcServerErrorFilterTransactionNotFound message '
      'contains \$__serverMessage',
      () {
        final message =
            solanaErrorMessages[SolanaErrorCode
                .jsonRpcServerErrorFilterTransactionNotFound];
        expect(message, isNotNull);
        expect(message, contains(r'$__serverMessage'));
      },
    );

    test(
      'transactionFailedToEstimateLoadedAccountsDataSizeLimit has '
      'non-empty message',
      () {
        final message =
            solanaErrorMessages[SolanaErrorCode
                .transactionFailedToEstimateLoadedAccountsDataSizeLimit];
        expect(message, isNotNull);
        expect(message, isNotEmpty);
      },
    );

    test(
      'transactionFailedWhenSimulatingToEstimateResourceLimits has '
      'non-empty message',
      () {
        final message =
            solanaErrorMessages[SolanaErrorCode
                .transactionFailedWhenSimulatingToEstimateResourceLimits];
        expect(message, isNotNull);
        expect(message, isNotEmpty);
      },
    );

    test('subscribableRetryNotSupported message contains retry', () {
      final message =
          solanaErrorMessages[SolanaErrorCode.subscribableRetryNotSupported];
      expect(message, isNotNull);
      expect(message!.toLowerCase(), contains('retry'));
    });

    test(
      'walletAccountNotAvailable message contains \$address and \$walletName',
      () {
        final message =
            solanaErrorMessages[SolanaErrorCode.walletAccountNotAvailable];
        expect(message, isNotNull);
        expect(message, contains(r'$address'));
        expect(message, contains(r'$walletName'));
      },
    );

    // Added in @solana/kit v7.0.0: configurable instruction-count limit.
    test(
      'instructionPlansMaxInstructionsPerTransactionExceeded message '
      'contains \$numInstructions and \$maxInstructions',
      () {
        final message =
            solanaErrorMessages[SolanaErrorCode
                .instructionPlansMaxInstructionsPerTransactionExceeded];
        expect(message, isNotNull);
        expect(message, contains(r'$numInstructions'));
        expect(message, contains(r'$maxInstructions'));
      },
    );

    test(
      'instructionPlansInvalidMaxInstructionsPerTransaction message '
      'contains \$maxInstructions and \$transactionInstructionLimit',
      () {
        final message =
            solanaErrorMessages[SolanaErrorCode
                .instructionPlansInvalidMaxInstructionsPerTransaction];
        expect(message, isNotNull);
        expect(message, contains(r'$maxInstructions'));
        expect(message, contains(r'$transactionInstructionLimit'));
      },
    );

    // Added in @solana/kit v7.0.0: transaction-introspection package.
    test(
      'transactionIntrospectionCannotDecodeJsonParsedTransaction message '
      'mentions jsonParsed',
      () {
        final message =
            solanaErrorMessages[SolanaErrorCode
                .transactionIntrospectionCannotDecodeJsonParsedTransaction];
        expect(message, isNotNull);
        expect(message!.toLowerCase(), contains('jsonparsed'));
      },
    );

    test(
      'transactionIntrospectionUnrecognizedGetTransactionResponse message '
      'has non-empty message',
      () {
        final message =
            solanaErrorMessages[SolanaErrorCode
                .transactionIntrospectionUnrecognizedGetTransactionResponse];
        expect(message, isNotNull);
        expect(message, isNotEmpty);
      },
    );

    test(
      'transactionFailedToDecompileInstructionAccountIndexOutOfRange '
      'message contains \$index',
      () {
        final message =
            solanaErrorMessages[SolanaErrorCode
                .transactionFailedToDecompileInstructionAccountIndexOutOfRange];
        expect(message, isNotNull);
        expect(message, contains(r'$index'));
      },
    );
  });
}
