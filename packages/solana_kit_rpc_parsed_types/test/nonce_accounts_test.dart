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
  });
}
