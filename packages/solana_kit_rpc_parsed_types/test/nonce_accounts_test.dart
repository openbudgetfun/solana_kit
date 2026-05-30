import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_rpc_parsed_types/solana_kit_rpc_parsed_types.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:test/test.dart';

void main() {
  group('JsonParsedNonceAccount', () {
    test('can be constructed with all fields', () {
      const account = JsonParsedNonceAccount(
        info: JsonParsedNonceInfo(
          authority: Address('3xxDCjN8s6MgNHwdRExRLa6gHmmRTWPnUdzkbKfEgNAe'),
          blockhash: Blockhash('TcVy2wVcs7WqWVopv8LAJBHQfqVYZrm8UDqjDvBFQt8'),
          feeCalculator: JsonParsedNonceFeeCalculator(
            lamportsPerSignature: StringifiedBigInt('5000'),
          ),
        ),
      );

      expect(
        account.info.authority.value,
        '3xxDCjN8s6MgNHwdRExRLa6gHmmRTWPnUdzkbKfEgNAe',
      );
      expect(
        account.info.blockhash.value,
        'TcVy2wVcs7WqWVopv8LAJBHQfqVYZrm8UDqjDvBFQt8',
      );
      expect(account.info.feeCalculator.lamportsPerSignature.value, '5000');
    });

    test('JsonParsedNonceInfo equality, hashCode, and toString', () {
      const info1 = JsonParsedNonceInfo(
        authority: Address('3xxDCjN8s6MgNHwdRExRLa6gHmmRTWPnUdzkbKfEgNAe'),
        blockhash: Blockhash('TcVy2wVcs7WqWVopv8LAJBHQfqVYZrm8UDqjDvBFQt8'),
        feeCalculator: JsonParsedNonceFeeCalculator(
          lamportsPerSignature: StringifiedBigInt('5000'),
        ),
      );
      const info2 = JsonParsedNonceInfo(
        authority: Address('3xxDCjN8s6MgNHwdRExRLa6gHmmRTWPnUdzkbKfEgNAe'),
        blockhash: Blockhash('TcVy2wVcs7WqWVopv8LAJBHQfqVYZrm8UDqjDvBFQt8'),
        feeCalculator: JsonParsedNonceFeeCalculator(
          lamportsPerSignature: StringifiedBigInt('5000'),
        ),
      );
      const info3 = JsonParsedNonceInfo(
        authority: Address('3xxDCjN8s6MgNHwdRExRLa6gHmmRTWPnUdzkbKfEgNAe'),
        blockhash: Blockhash('DifferentBlockhash111111111111111111111111111'),
        feeCalculator: JsonParsedNonceFeeCalculator(
          lamportsPerSignature: StringifiedBigInt('5000'),
        ),
      );
      const info4 = JsonParsedNonceInfo(
        authority: Address('3xxDCjN8s6MgNHwdRExRLa6gHmmRTWPnUdzkbKfEgNAe'),
        blockhash: Blockhash('TcVy2wVcs7WqWVopv8LAJBHQfqVYZrm8UDqjDvBFQt8'),
        feeCalculator: JsonParsedNonceFeeCalculator(
          lamportsPerSignature: StringifiedBigInt('9999'),
        ),
      );

      expect(info1, equals(info2));
      expect(info1.hashCode, equals(info2.hashCode));
      expect(info1 == info3, isFalse);
      expect(info1 == info4, isFalse);
      expect(info1.toString(), contains('blockhash'));
    });

    test('JsonParsedNonceFeeCalculator equality, hashCode, and toString', () {
      const fc1 = JsonParsedNonceFeeCalculator(
        lamportsPerSignature: StringifiedBigInt('5000'),
      );
      const fc2 = JsonParsedNonceFeeCalculator(
        lamportsPerSignature: StringifiedBigInt('5000'),
      );
      const fc3 = JsonParsedNonceFeeCalculator(
        lamportsPerSignature: StringifiedBigInt('9999'),
      );

      expect(fc1, equals(fc2));
      expect(fc1.hashCode, equals(fc2.hashCode));
      expect(fc1 == fc3, isFalse);
      expect(fc1.toString(), contains('lamportsPerSignature'));
    });
  });
}
