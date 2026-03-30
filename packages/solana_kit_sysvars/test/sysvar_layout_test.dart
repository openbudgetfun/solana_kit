import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_sysvars/src/sysvar_layout.dart';
import 'package:test/test.dart';

void main() {
  group('sysvar layout helpers', () {
    test('mapFixedSizeStructCodec bridges typed fixed-layout models', () {
      final structEncoder =
          getStructEncoder([
                ('slot', getU64Encoder()),
                ('warmup', getBooleanEncoder()),
              ])
              as FixedSizeEncoder<Map<String, Object?>>;
      final structDecoder =
          getStructDecoder([
                ('slot', getU64Decoder()),
                ('warmup', getBooleanDecoder()),
              ])
              as FixedSizeDecoder<Map<String, Object?>>;

      final codec = mapFixedSizeStructCodec<_ExampleLayout>(
        fixedSize: structEncoder.fixedSize,
        structEncoder: structEncoder,
        structDecoder: structDecoder,
        toFields: (value) => {
          'slot': value.slot,
          'warmup': value.warmup,
        },
        fromFields: (fields) => _ExampleLayout(
          slot: fields['slot']! as BigInt,
          warmup: fields['warmup']! as bool,
        ),
      );

      final encoded = codec.encode(
        _ExampleLayout(slot: BigInt.from(42), warmup: true),
      );
      final decoded = codec.decode(encoded);

      expect(decoded.slot, BigInt.from(42));
      expect(decoded.warmup, isTrue);
    });

    test('formatStructuredFields renders readable named output', () {
      expect(
        formatStructuredFields('Example', {
          'slot': BigInt.from(5),
          'warmup': false,
        }),
        'Example(slot: 5, warmup: false)',
      );
    });
  });
}

class _ExampleLayout {
  const _ExampleLayout({required this.slot, required this.warmup});

  final BigInt slot;
  final bool warmup;
}
