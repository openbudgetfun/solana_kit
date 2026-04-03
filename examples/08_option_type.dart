// ignore_for_file: avoid_print
/// Example 08: Rust-style Option<T> types.
///
/// Solana programs often encode optional fields as explicit `Some`/`None`
/// values.  This example shows [Some], [None], [unwrapOption], and
/// [getOptionCodec].
///
/// Run:
///   dart examples/08_option_type.dart
library;

import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_options/solana_kit_options.dart';

void main() {
  // ── 1. Construct Some and None ────────────────────────────────────────────
  final Option<int> maybeValue = Some(42);
  final Option<int> noValue = None<int>();

  print('Some(42): $maybeValue');
  print('None    : $noValue');

  // ── 2. Pattern-match with a switch expression ─────────────────────────────
  String describe(Option<int> opt) => switch (opt) {
    Some(:final value) => 'has value: $value',
    None() => 'empty',
  };

  print(describe(maybeValue));
  print(describe(noValue));

  // ── 3. unwrapOption ───────────────────────────────────────────────────────
  // Returns the inner value or throws if None.
  final inner = unwrapOption(maybeValue);
  print('Unwrapped: $inner');

  // ── 4. unwrapOptionOr with a fallback ─────────────────────────────────────
  // unwrapOptionOr never returns null; calls the fallback for None.
  final withDefault = unwrapOptionOr(noValue, () => -1);
  print('Unwrap with default: $withDefault');

  // ── 5. Codec: encode / decode ─────────────────────────────────────────────
  // getOptionCodec wraps an inner codec with a 1-byte discriminator:
  //   0x00 = None, 0x01 = Some.
  final optU32Codec = getOptionCodec(getU32Codec());

  final encodedSome = optU32Codec.encode(Some(0xCAFEBABE));
  print('\nencoded Some(0xCAFEBABE): $encodedSome '
      '(${encodedSome.length} bytes)');

  final encodedNone = optU32Codec.encode(None<int>());
  print('encoded None: $encodedNone (${encodedNone.length} bytes)');

  final decodedSome = optU32Codec.decode(encodedSome);
  final decodedNone = optU32Codec.decode(encodedNone);
  // The codec's decode type is Option<Object?> since the generic is erased;
  // cast it back so our describe() helper can switch on Some/None.
  // ignore: avoid_as
  print('decoded Some: ${describe(decodedSome as Option<int>)}');
  // ignore: avoid_as
  print('decoded None: ${describe(decodedNone as Option<int>)}');

  // ── 6. Equality ───────────────────────────────────────────────────────────
  print('\nSome(1) == Some(1): ${Some(1) == Some(1)}');
  print('Some(1) == Some(2): ${Some(1) == Some(2)}');
  print('None == None      : ${None<int>() == None<int>()}');
}
