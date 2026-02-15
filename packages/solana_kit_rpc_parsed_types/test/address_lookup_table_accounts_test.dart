import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_rpc_parsed_types/solana_kit_rpc_parsed_types.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:test/test.dart';

void main() {
  group('JsonParsedAddressLookupTableAccount', () {
    test('can be constructed with all fields', () {
      const account = JsonParsedAddressLookupTableAccount(
        info: JsonParsedAddressLookupTableInfo(
          addresses: [
            Address('F1Vc6AGoxXLwGB7QV8f4So3C5d8SXEk3KKGHxKGEJ8qn'),
            Address('FWscgV4VDSsMxkQg7jZ4HksqjLyadJS5RiCnAVZv2se9'),
          ],
          authority: Address('4msgK65vdz5ADUAB3eTQGpF388NuQUAoknLxutUQJd5B'),
          deactivationSlot: StringifiedBigInt('204699277'),
          lastExtendedSlot: StringifiedBigInt('204699234'),
          lastExtendedSlotStartIndex: 20,
        ),
      );

      expect(account.info.addresses, hasLength(2));
      expect(
        account.info.addresses[0].value,
        'F1Vc6AGoxXLwGB7QV8f4So3C5d8SXEk3KKGHxKGEJ8qn',
      );
      expect(
        account.info.addresses[1].value,
        'FWscgV4VDSsMxkQg7jZ4HksqjLyadJS5RiCnAVZv2se9',
      );
      expect(
        account.info.authority?.value,
        '4msgK65vdz5ADUAB3eTQGpF388NuQUAoknLxutUQJd5B',
      );
      expect(account.info.deactivationSlot.value, '204699277');
      expect(account.info.lastExtendedSlot.value, '204699234');
      expect(account.info.lastExtendedSlotStartIndex, 20);
    });

    test('can be constructed without optional authority', () {
      const account = JsonParsedAddressLookupTableAccount(
        info: JsonParsedAddressLookupTableInfo(
          addresses: [],
          deactivationSlot: StringifiedBigInt('0'),
          lastExtendedSlot: StringifiedBigInt('0'),
          lastExtendedSlotStartIndex: 0,
        ),
      );

      expect(account.info.authority, isNull);
      expect(account.info.addresses, isEmpty);
    });
  });
}
