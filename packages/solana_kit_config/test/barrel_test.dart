import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_config/solana_kit_config.dart';
import 'package:test/test.dart';

void main() {
  test('exports generated APIs and helpers', () {
    const key = ConfigKey(address: solanaConfigProgramAddress, isSigner: true);
    final instruction = getStoreConfigInstruction(
      configAccount: address('11111111111111111111111111111111'),
      keys: [key],
      configData: Uint8List.fromList([1]),
    );

    expect(identifySolanaConfigInstruction(instruction), isTrue);
    expect(parseStoreInstruction(instruction).keys, [key]);
  });
}
