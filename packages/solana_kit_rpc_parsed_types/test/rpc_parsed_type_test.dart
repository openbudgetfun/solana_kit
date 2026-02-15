import 'package:solana_kit_rpc_parsed_types/solana_kit_rpc_parsed_types.dart';
import 'package:test/test.dart';

void main() {
  group('RpcParsedType', () {
    test('stores type and info', () {
      const parsed = RpcParsedType(type: 'myType', info: 'myInfo');

      expect(parsed.type, 'myType');
      expect(parsed.info, 'myInfo');
    });
  });

  group('RpcParsedInfo', () {
    test('stores info', () {
      const parsed = RpcParsedInfo(info: 'myInfo');

      expect(parsed.info, 'myInfo');
    });
  });
}
