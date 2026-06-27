import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:test/test.dart';

void main() {
  group('SolanaErrorCode.fromValue (new codes)', () {
    test('returns jsonRpcServerErrorNoSlotHistory for -32021', () {
      expect(
        SolanaErrorCode.fromValue(-32021),
        SolanaErrorCode.jsonRpcServerErrorNoSlotHistory,
      );
    });

    test('returns jsonRpcServerErrorFilterTransactionNotFound for -32020', () {
      expect(
        SolanaErrorCode.fromValue(-32020),
        SolanaErrorCode.jsonRpcServerErrorFilterTransactionNotFound,
      );
    });

    test('returns transactionFailedToEstimateLoadedAccountsDataSizeLimit '
        'for 5663036', () {
      expect(
        SolanaErrorCode.fromValue(5663036),
        SolanaErrorCode.transactionFailedToEstimateLoadedAccountsDataSizeLimit,
      );
    });

    test('returns transactionFailedWhenSimulatingToEstimateResourceLimits '
        'for 5663037', () {
      expect(
        SolanaErrorCode.fromValue(5663037),
        SolanaErrorCode.transactionFailedWhenSimulatingToEstimateResourceLimits,
      );
    });

    test('returns subscribableRetryNotSupported for 8195000', () {
      expect(
        SolanaErrorCode.fromValue(8195000),
        SolanaErrorCode.subscribableRetryNotSupported,
      );
    });

    test('returns walletAccountNotAvailable for 8900003', () {
      expect(
        SolanaErrorCode.fromValue(8900003),
        SolanaErrorCode.walletAccountNotAvailable,
      );
    });
  });

  group('new code numeric values', () {
    test('jsonRpcServerErrorNoSlotHistory has value -32021', () {
      expect(SolanaErrorCode.jsonRpcServerErrorNoSlotHistory.value, -32021);
    });

    test('jsonRpcServerErrorFilterTransactionNotFound has value -32020', () {
      expect(
        SolanaErrorCode.jsonRpcServerErrorFilterTransactionNotFound.value,
        -32020,
      );
    });

    test(
      'transactionFailedToEstimateLoadedAccountsDataSizeLimit has value 5663036',
      () {
        expect(
          SolanaErrorCode
              .transactionFailedToEstimateLoadedAccountsDataSizeLimit
              .value,
          5663036,
        );
      },
    );

    test(
      'transactionFailedWhenSimulatingToEstimateResourceLimits has value 5663037',
      () {
        expect(
          SolanaErrorCode
              .transactionFailedWhenSimulatingToEstimateResourceLimits
              .value,
          5663037,
        );
      },
    );

    test('subscribableRetryNotSupported has value 8195000', () {
      expect(SolanaErrorCode.subscribableRetryNotSupported.value, 8195000);
    });

    test('walletAccountNotAvailable has value 8900003', () {
      expect(SolanaErrorCode.walletAccountNotAvailable.value, 8900003);
    });
  });
}
