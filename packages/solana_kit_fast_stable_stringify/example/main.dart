// Examples intentionally print CLI output for demonstration purposes.
// ignore_for_file: avoid_print
import 'package:solana_kit_fast_stable_stringify/solana_kit_fast_stable_stringify.dart';

void main() {
  final payload = <String, Object?>{
    'z': true,
    'a': 1,
    'nested': <String, Object?>{
      'b': 2,
      'a': 1,
    },
  };

  final stableJson = fastStableStringify(payload);
  print(stableJson);
}
