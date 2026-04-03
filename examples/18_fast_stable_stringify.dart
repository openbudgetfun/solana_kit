// ignore_for_file: avoid_print
/// Example 18: Deterministic JSON serialisation with fastStableStringify.
///
/// [fastStableStringify] produces the same JSON output regardless of insertion
/// order by sorting object keys alphabetically.  This is important for
/// canonical hashing and signature payloads.
///
/// Run:
///   dart examples/18_fast_stable_stringify.dart
library;

import 'package:solana_kit_fast_stable_stringify/solana_kit_fast_stable_stringify.dart';

void main() {
  // ── 1. Object with out-of-order keys ──────────────────────────────────────
  final unsorted = {
    'z': 3,
    'a': 1,
    'm': 2,
  };

  final json = fastStableStringify(unsorted);
  print('Sorted keys: $json');
  // Expected: {"a":1,"m":2,"z":3}

  // ── 2. Nested objects ─────────────────────────────────────────────────────
  final nested = {
    'transaction': {
      'version': 0,
      'feePayer': '11111111111111111111111111111111',
      'instructions': <Object?>[],
    },
    'slot': 250000000,
  };

  print('Nested: ${fastStableStringify(nested)}');

  // ── 3. Arrays are preserved in order ──────────────────────────────────────
  final withArray = {
    'items': [3, 1, 2],
    'name': 'test',
  };
  print('Array order preserved: ${fastStableStringify(withArray)}');

  // ── 4. Null and boolean values ────────────────────────────────────────────
  final withNulls = {
    'c': null,
    'b': false,
    'a': true,
  };
  print('Null/bool: ${fastStableStringify(withNulls)}');

  // ── 5. Determinism check ──────────────────────────────────────────────────
  final map1 = {'b': 2, 'a': 1};
  final map2 = {'a': 1, 'b': 2};
  final json1 = fastStableStringify(map1);
  final json2 = fastStableStringify(map2);
  print('\nDeterminism: json1 == json2 → ${json1 == json2}');
  print('Output: $json1');
}
