import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_offchain_messages/solana_kit_offchain_messages.dart';
import 'package:test/test.dart';

OffchainMessageSignatory _signatory(String address) =>
    OffchainMessageSignatory(address: Address(address));

void main() {
  group('assertOffchainMessageV1Equal', () {
    test('passes for identical messages', () {
      final message = OffchainMessageV1(
        content: 'hello',
        requiredSignatories: [
          _signatory('11111111111111111111111111111111'),
          _signatory('22222222222222222222222222222222'),
        ],
      );
      expect(() => assertOffchainMessageV1Equal(message, message), returnsNormally);
    });

    test('passes when signatories are in a different order', () {
      final received = OffchainMessageV1(
        content: 'hello',
        requiredSignatories: [
          _signatory('11111111111111111111111111111111'),
          _signatory('22222222222222222222222222222222'),
        ],
      );
      final expected = OffchainMessageV1(
        content: 'hello',
        requiredSignatories: [
          _signatory('22222222222222222222222222222222'),
          _signatory('11111111111111111111111111111111'),
        ],
      );
      expect(
        () => assertOffchainMessageV1Equal(received, expected),
        returnsNormally,
      );
    });

    test('throws when the content differs', () {
      final received = OffchainMessageV1(
        content: 'hello',
        requiredSignatories: [
          _signatory('11111111111111111111111111111111'),
        ],
      );
      final expected = OffchainMessageV1(
        content: 'world',
        requiredSignatories: [
          _signatory('11111111111111111111111111111111'),
        ],
      );
      expect(
        () => assertOffchainMessageV1Equal(received, expected),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.offchainMessageContentDoesNotMatchExpected,
          ),
        ),
      );
    });

    test('throws when the signatories differ', () {
      final received = OffchainMessageV1(
        content: 'hello',
        requiredSignatories: [
          _signatory('11111111111111111111111111111111'),
        ],
      );
      final expected = OffchainMessageV1(
        content: 'hello',
        requiredSignatories: [
          _signatory('22222222222222222222222222222222'),
        ],
      );
      expect(
        () => assertOffchainMessageV1Equal(received, expected),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.offchainMessageRequiredSignatoriesDoNotMatchExpected,
          ),
        ),
      );
    });
  });
}
