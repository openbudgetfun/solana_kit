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
  });
}
