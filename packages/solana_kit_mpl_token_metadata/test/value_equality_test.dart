import 'dart:typed_data';

import 'package:solana_kit_mpl_token_metadata/solana_kit_mpl_token_metadata.dart';
import 'package:test/test.dart';

void main() {
  test('generated nested byte lists have structural value equality', () {
    final first = ProofInfo(
      proof: [Uint8List.fromList(List<int>.filled(32, 7))],
    );
    final second = ProofInfo(
      proof: [Uint8List.fromList(List<int>.filled(32, 7))],
    );

    expect(first, second);
    expect(first.hashCode, second.hashCode);
  });
}
