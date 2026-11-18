import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

import 'package:solana_kit_privacy_rings/src/bytes.dart';
import 'package:solana_kit_privacy_rings/src/exception.dart';

/// Blinding of the deposit output at [leafIndex] in [tree].
///
/// `deposit_blinding` in
/// `program-libs/interface/src/instruction/instruction_data/deposit.rs`:
/// SHA-256 of `b"Deposit" || tree || leaf_index_be`, with the leading byte
/// cleared so the result is below the BN254 modulus.
Uint8List depositBlinding(List<int> tree, int leafIndex) {
  final treeBytes = copyBytes(tree, 32, 'tree');
  if (leafIndex < 0) {
    throw PrivacyRingsException(
      'leafIndex is negative',
      code: 'integer_range',
    );
  }
  final digest = sha256.convert([
    ...utf8.encode('Deposit'),
    ...treeBytes,
    ...u64be(leafIndex),
  ]);
  final blinding = Uint8List.fromList(digest.bytes);
  blinding[0] = 0;
  return blinding;
}
