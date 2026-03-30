import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:test/test.dart';

void main() {
  group('createSolanaErrorContext', () {
    test('drops null values and preserves explicit context', () {
      final context = createSolanaErrorContext({
        SolanaErrorContextKeys.address: '11111111111111111111111111111111',
        SolanaErrorContextKeys.path: null,
      });

      expect(
        context,
        {SolanaErrorContextKeys.address: '11111111111111111111111111111111'},
      );
    });

    test('captures nested SolanaError details when wrapping a cause', () {
      final cause = SolanaError(SolanaErrorCode.blockHeightExceeded, {
        'slot': 55,
      });

      final context = createSolanaErrorContext(
        {SolanaErrorContextKeys.operation: 'testOperation'},
        cause: cause,
      );

      expect(context[SolanaErrorContextKeys.operation], 'testOperation');
      expect(context[SolanaErrorContextKeys.cause], cause.toString());
      expect(
        context[SolanaErrorContextKeys.causeCode],
        SolanaErrorCode.blockHeightExceeded,
      );
      expect(context[SolanaErrorContextKeys.causeContext], {'slot': 55});
      expect(context[SolanaErrorContextKeys.causeType], 'SolanaError');
    });
  });

  group('createSolanaError / wrapSolanaError', () {
    test('creates normalized SolanaError instances', () {
      final error = createSolanaError(
        SolanaErrorCode.accountsAccountNotFound,
        context: {
          SolanaErrorContextKeys.address:
              '11111111111111111111111111111111',
          SolanaErrorContextKeys.path: null,
        },
      );

      expect(error.code, SolanaErrorCode.accountsAccountNotFound);
      expect(
        error.context,
        {
          SolanaErrorContextKeys.address:
              '11111111111111111111111111111111',
        },
      );
    });

    test('wraps arbitrary causes consistently', () {
      final error = wrapSolanaError(
        SolanaErrorCode.accountsFailedToDecodeAccount,
        StateError('boom'),
        context: {SolanaErrorContextKeys.address: 'demo-address'},
      );

      expect(error.code, SolanaErrorCode.accountsFailedToDecodeAccount);
      expect(error.context[SolanaErrorContextKeys.address], 'demo-address');
      expect(
        error.context[SolanaErrorContextKeys.cause],
        contains('Bad state: boom'),
      );
      expect(error.context[SolanaErrorContextKeys.causeType], 'StateError');
    });
  });
}
