import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_config/solana_kit_config.dart';
import 'package:test/test.dart';

void main() {
  const authority = solanaConfigProgramAddress;
  const observer = Address('11111111111111111111111111111111');
  const keys = [
    ConfigKey(address: authority, isSigner: true),
    ConfigKey(address: observer, isSigner: false),
  ];

  test('encodes config keys with a shortU16 length prefix', () {
    final encoded = getConfigKeysEncoder().encode(keys);

    expect(encoded.first, 2);
    expect(encoded.length, 1 + (32 + 1) * 2);
    expect(getConfigKeysDecoder().decode(encoded), keys);
  });

  test('round-trips ConfigAccount data', () {
    final account = ConfigAccount(
      keys: keys,
      data: Uint8List.fromList([10, 20, 30, 40]),
    );

    final encoded = getConfigAccountEncoder().encode(account);
    final decoded = getConfigAccountDecoder().decode(encoded);

    expect(decoded, account);
    expect(decoded.data, [10, 20, 30, 40]);
  });

  test('round-trips Store instruction data', () {
    final data = StoreInstructionData(
      keys: keys,
      data: Uint8List.fromList([1, 1, 2, 3, 5, 8]),
    );

    final codec = getStoreInstructionDataCodec();
    final decoded = codec.decode(codec.encode(data));

    expect(decoded, data);
    expect(decoded.data, [1, 1, 2, 3, 5, 8]);
  });
}
