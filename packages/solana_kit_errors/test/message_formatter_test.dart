import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:test/test.dart';

void main() {
  group('getErrorMessage', () {
    test('returns message for known error code', () {
      final message = getErrorMessage(SolanaErrorCode.blockHeightExceeded);
      expect(message, isNotEmpty);
      expect(message, contains('block'));
    });

    test('returns fallback for unknown error code', () {
      final message = getErrorMessage(999999);
      expect(message, contains('999999'));
    });

    test('interpolates single variable', () {
      final message = getErrorMessage(SolanaErrorCode.accountsAccountNotFound, {
        'address': 'MyAddr',
      });
      expect(message, contains('MyAddr'));
      expect(message, isNot(contains(r'$address')));
    });

    test('interpolates multiple variables', () {
      final message = getErrorMessage(
        SolanaErrorCode.addressesMaxNumberOfPdaSeedsExceeded,
        {'maxSeeds': '16', 'actual': '20'},
      );
      expect(message, contains('16'));
      expect(message, contains('20'));
    });

    test('leaves unresolved variables as-is', () {
      final message = getErrorMessage(
        SolanaErrorCode.accountsAccountNotFound,
        {},
      );
      expect(message, contains(r'$address'));
    });

    test('handles empty message template', () {
      // instructionErrorUnknown has an empty message
      final message = getErrorMessage(SolanaErrorCode.instructionErrorUnknown);
      expect(message, contains('Solana error'));
    });

    test('handles numeric context values', () {
      final message = getErrorMessage(SolanaErrorCode.instructionErrorCustom, {
        'code': 42,
      });
      expect(message, contains('42'));
    });
  });
}
