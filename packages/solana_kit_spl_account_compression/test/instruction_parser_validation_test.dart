import 'dart:typed_data';

import 'package:solana_kit_spl_account_compression/solana_kit_spl_account_compression.dart';
import 'package:test/test.dart';

void main() {
  final codec = getAppendInstructionDataCodec();
  final leaf = Uint8List(32);
  final valid = codec.encode(AppendInstructionData(leaf: leaf));

  test('append accepts its discriminator and preserves decoder metadata', () {
    expect(codec.decode(valid).leaf, leaf);
    final (decoded, end) = codec.read(Uint8List.fromList([99, ...valid]), 1);
    expect(decoded.leaf, leaf);
    expect(end, valid.length + 1);
  });

  test('append rejects another opcode with a compatible layout', () {
    final wrongOpcode = Uint8List.fromList(valid)..[0] = 5;
    expect(() => codec.decode(wrongOpcode), throwsA(anything));
  });

  test('append rejects trailing data', () {
    expect(
      () => codec.decode(Uint8List.fromList([...valid, 0])),
      throwsA(anything),
    );
  });

  test('append rejects a truncated leaf', () {
    expect(
      () => codec.decode(Uint8List.sublistView(valid, 0, valid.length - 1)),
      throwsA(anything),
    );
  });
}
