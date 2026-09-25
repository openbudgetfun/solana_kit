import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_options/solana_kit_options.dart';
import 'package:test/test.dart';

import 'setup.dart';

void main() {
  group('getOptionCodec', () {
    group('with prefix', () {
      test('encodes option numbers', () {
        final codec = getOptionCodec(getU16Codec());
        expect(hex(codec.encode(0)), equals('010000'));
        expect(hex(codec.encode(some(0))), equals('010000'));
        expect(hex(codec.encode(42)), equals('012a00'));
        expect(hex(codec.encode(some(42))), equals('012a00'));
        expect(hex(codec.encode(null)), equals('00'));
        expect(hex(codec.encode(none<num>())), equals('00'));
      });

      test('decodes option numbers', () {
        final codec = getOptionCodec(getU16Codec());
        expect(codec.decode(b('010000')), equals(some(0)));
        expect(codec.decode(b('012a00')), equals(some(42)));
        expect(codec.decode(b('00')), equals(none<int>()));
      });

      test('encodes option numbers with explicit prefix', () {
        final codec = getOptionCodec(getU16Codec(), prefix: getU8Codec());
        expect(hex(codec.encode(0)), equals('010000'));
        expect(hex(codec.encode(some(0))), equals('010000'));
        expect(hex(codec.encode(42)), equals('012a00'));
        expect(hex(codec.encode(some(42))), equals('012a00'));
        expect(hex(codec.encode(null)), equals('00'));
        expect(hex(codec.encode(none<num>())), equals('00'));
      });

      test('decodes option numbers with explicit prefix', () {
        final codec = getOptionCodec(getU16Codec(), prefix: getU8Codec());
        expect(codec.decode(b('010000')), equals(some(0)));
        expect(codec.decode(b('012a00')), equals(some(42)));
        expect(codec.decode(b('00')), equals(none<int>()));
      });

      test('encodes option numbers with custom prefix', () {
        final codec = getOptionCodec(getU16Codec(), prefix: getU32Codec());
        expect(hex(codec.encode(0)), equals('010000000000'));
        expect(hex(codec.encode(some(0))), equals('010000000000'));
        expect(hex(codec.encode(42)), equals('010000002a00'));
        expect(hex(codec.encode(some(42))), equals('010000002a00'));
        expect(hex(codec.encode(null)), equals('00000000'));
        expect(hex(codec.encode(none<num>())), equals('00000000'));
      });

      test('decodes option numbers with custom prefix', () {
        final codec = getOptionCodec(getU16Codec(), prefix: getU32Codec());
        expect(codec.decode(b('010000000000')), equals(some(0)));
        expect(codec.decode(b('010000002a00')), equals(some(42)));
        expect(codec.decode(b('00000000')), equals(none<int>()));
      });

      test('encodes nested option numbers', () {
        final codec = getOptionCodec(getOptionCodec(getU16Codec()));
        expect(hex(codec.encode(42)), equals('01012a00'));
        expect(hex(codec.encode(some(42))), equals('01012a00'));
        expect(hex(codec.encode(some(some(42)))), equals('01012a00'));
        expect(hex(codec.encode(some<Object?>(null))), equals('0100'));
        expect(hex(codec.encode(some(none<int>()))), equals('0100'));
        expect(hex(codec.encode(null)), equals('00'));
        expect(hex(codec.encode(none<Object?>())), equals('00'));
      });

      test('decodes nested option numbers', () {
        final codec = getOptionCodec(getOptionCodec(getU16Codec()));
        expect(codec.decode(b('01012a00')), equals(some(some(42))));
        expect(codec.decode(b('0100')), equals(some(none<int>())));
        expect(codec.decode(b('00')), equals(none<Option<int>>()));
      });

      test('pushes the offset forward when writing', () {
        final codec = getOptionCodec(getU16Codec());
        expect(codec.write(257, Uint8List(10), 3), equals(6));
        expect(codec.write(null, Uint8List(10), 3), equals(4));
      });

      test('pushes the offset forward when reading', () {
        final codec = getOptionCodec(getU16Codec());
        expect(codec.read(b('ffff01010100'), 2), equals((some(257), 5)));
        expect(codec.read(b('ffff00'), 2), equals((none<int>(), 3)));
      });

      test('returns a variable size codec with max size', () {
        final codec = getOptionCodec(getU16Codec());
        expect(codec, isA<VariableSizeCodec<Object?, Option<int>>>());
        final varCodec = codec as VariableSizeCodec<Object?, Option<int>>;
        expect(varCodec.getSizeFromValue(null), equals(1));
        expect(varCodec.getSizeFromValue(42), equals(3));
        expect(varCodec.maxSize, equals(3));
      });
    });

    group('with zeroable none value', () {
      test('encodes option numbers', () {
        final codec = getOptionCodec(
          getU16Codec(),
          noneValue: const ZeroesOptionNoneValue(),
          hasPrefix: false,
        );
        expect(hex(codec.encode(42)), equals('2a00'));
        expect(hex(codec.encode(some(42))), equals('2a00'));
        expect(hex(codec.encode(null)), equals('0000'));
        expect(hex(codec.encode(none<num>())), equals('0000'));
      });

      test('decodes option numbers', () {
        final codec = getOptionCodec(
          getU16Codec(),
          noneValue: const ZeroesOptionNoneValue(),
          hasPrefix: false,
        );
        expect(codec.decode(b('2a00')), equals(some(42)));
        expect(codec.decode(b('0000')), equals(none<int>()));
      });

      test('can end up encoding the none value', () {
        final codec = getOptionCodec(
          getU16Codec(),
          noneValue: const ZeroesOptionNoneValue(),
          hasPrefix: false,
        );
        expect(hex(codec.encode(0)), equals('0000'));
      });

      test('encodes nested option numbers', () {
        final codec = getOptionCodec(
          getOptionCodec(
            getU16Codec(),
            noneValue: const ZeroesOptionNoneValue(),
            hasPrefix: false,
          ),
          noneValue: const ZeroesOptionNoneValue(),
          hasPrefix: false,
        );
        expect(hex(codec.encode(42)), equals('2a00'));
        expect(hex(codec.encode(some(42))), equals('2a00'));
        expect(hex(codec.encode(some(some(42)))), equals('2a00'));
        expect(hex(codec.encode(some<Object?>(null))), equals('0000'));
        expect(hex(codec.encode(some(none<int>()))), equals('0000'));
        expect(hex(codec.encode(null)), equals('0000'));
        expect(hex(codec.encode(none<Object?>())), equals('0000'));
      });

      test('decodes nested option numbers', () {
        final codec = getOptionCodec(
          getOptionCodec(
            getU16Codec(),
            noneValue: const ZeroesOptionNoneValue(),
            hasPrefix: false,
          ),
          noneValue: const ZeroesOptionNoneValue(),
          hasPrefix: false,
        );
        expect(codec.decode(b('2a00')), equals(some(some(42))));
        expect(codec.decode(b('0000')), equals(none<Option<int>>()));
      });

      test('pushes the offset forward when writing', () {
        final codec = getOptionCodec(
          getU16Codec(),
          noneValue: const ZeroesOptionNoneValue(),
          hasPrefix: false,
        );
        expect(codec.write(257, Uint8List(10), 3), equals(5));
        expect(codec.write(null, Uint8List(10), 3), equals(5));
      });

      test('pushes the offset forward when reading', () {
        final codec = getOptionCodec(
          getU16Codec(),
          noneValue: const ZeroesOptionNoneValue(),
          hasPrefix: false,
        );
        expect(codec.read(b('ffff010100'), 2), equals((some(257), 4)));
        expect(codec.read(b('ffff000000'), 2), equals((none<int>(), 4)));
      });

      test('returns a fixed size codec', () {
        final codec = getOptionCodec(
          getU16Codec(),
          noneValue: const ZeroesOptionNoneValue(),
          hasPrefix: false,
        );
        expect(codec, isA<FixedSizeCodec<Object?, Option<int>>>());
        expect(
          (codec as FixedSizeCodec<Object?, Option<int>>).fixedSize,
          equals(2),
        );
      });

      test('fails if the item is not fixed', () {
        // Variable-size items cannot use zeroes none value.
        expect(
          () => getOptionCodec(
            _getVariableSizeCodec(),
            noneValue: const ZeroesOptionNoneValue(),
            hasPrefix: false,
          ),
          throwsA(
            isA<SolanaError>().having(
              (e) => e.code,
              'code',
              equals(SolanaErrorCode.codecsExpectedFixedLength),
            ),
          ),
        );
      });
    });

    group('with custom none value', () {
      test('encodes option numbers', () {
        final codec = getOptionCodec(
          getU16Codec(),
          noneValue: ConstantOptionNoneValue(b('ffff')),
          hasPrefix: false,
        );
        expect(hex(codec.encode(42)), equals('2a00'));
        expect(hex(codec.encode(some(42))), equals('2a00'));
        expect(hex(codec.encode(null)), equals('ffff'));
        expect(hex(codec.encode(none<num>())), equals('ffff'));
      });

      test('decodes option numbers', () {
        final codec = getOptionCodec(
          getU16Codec(),
          noneValue: ConstantOptionNoneValue(b('ffff')),
          hasPrefix: false,
        );
        expect(codec.decode(b('2a00')), equals(some(42)));
        expect(codec.decode(b('ffff')), equals(none<int>()));
      });

      test('can end up encoding the none value', () {
        final codec = getOptionCodec(
          getU16Codec(),
          noneValue: ConstantOptionNoneValue(b('ffff')),
          hasPrefix: false,
        );
        expect(hex(codec.encode(65535)), equals('ffff'));
      });

      test('encodes nested option numbers', () {
        final codec = getOptionCodec(
          getOptionCodec(
            getU16Codec(),
            noneValue: ConstantOptionNoneValue(b('ffff')),
            hasPrefix: false,
          ),
          noneValue: ConstantOptionNoneValue(b('ffff')),
          hasPrefix: false,
        );
        expect(hex(codec.encode(42)), equals('2a00'));
        expect(hex(codec.encode(some(42))), equals('2a00'));
        expect(hex(codec.encode(some(some(42)))), equals('2a00'));
        expect(hex(codec.encode(some<Object?>(null))), equals('ffff'));
        expect(hex(codec.encode(some(none<int>()))), equals('ffff'));
        expect(hex(codec.encode(null)), equals('ffff'));
        expect(hex(codec.encode(none<Object?>())), equals('ffff'));
      });

      test('decodes nested option numbers', () {
        final codec = getOptionCodec(
          getOptionCodec(
            getU16Codec(),
            noneValue: ConstantOptionNoneValue(b('ffff')),
            hasPrefix: false,
          ),
          noneValue: ConstantOptionNoneValue(b('ffff')),
          hasPrefix: false,
        );
        expect(codec.decode(b('2a00')), equals(some(some(42))));
        expect(codec.decode(b('ffff')), equals(none<Option<int>>()));
      });

      test('pushes the offset forward when writing', () {
        final codec = getOptionCodec(
          getU16Codec(),
          noneValue: ConstantOptionNoneValue(b('ffff')),
          hasPrefix: false,
        );
        expect(codec.write(257, Uint8List(10), 3), equals(5));
        expect(codec.write(null, Uint8List(10), 3), equals(5));
      });

      test('pushes the offset forward when reading', () {
        final codec = getOptionCodec(
          getU16Codec(),
          noneValue: ConstantOptionNoneValue(b('aaaa')),
          hasPrefix: false,
        );
        expect(codec.read(b('ffff010100'), 2), equals((some(257), 4)));
        expect(codec.read(b('ffffaaaa00'), 2), equals((none<int>(), 4)));
      });

      test('returns a variable size codec for different-length none value', () {
        final codec = getOptionCodec(
          getU16Codec(),
          noneValue: ConstantOptionNoneValue(b('ffffffff')),
          hasPrefix: false,
        );
        expect(codec, isA<VariableSizeCodec<Object?, Option<int>>>());
        final varCodec = codec as VariableSizeCodec<Object?, Option<int>>;
        expect(varCodec.getSizeFromValue(null), equals(4));
        expect(varCodec.getSizeFromValue(42), equals(2));
        expect(varCodec.maxSize, equals(4));
      });
    });

    group('with prefix and zeroable none value', () {
      test('encodes option numbers', () {
        final codec = getOptionCodec(
          getU16Codec(),
          noneValue: const ZeroesOptionNoneValue(),
        );
        expect(hex(codec.encode(0)), equals('010000'));
        expect(hex(codec.encode(some(0))), equals('010000'));
        expect(hex(codec.encode(42)), equals('012a00'));
        expect(hex(codec.encode(some(42))), equals('012a00'));
        expect(hex(codec.encode(null)), equals('000000'));
        expect(hex(codec.encode(none<num>())), equals('000000'));
      });

      test('decodes option numbers', () {
        final codec = getOptionCodec(
          getU16Codec(),
          noneValue: const ZeroesOptionNoneValue(),
        );
        expect(codec.decode(b('010000')), equals(some(0)));
        expect(codec.decode(b('012a00')), equals(some(42)));
        expect(codec.decode(b('000000')), equals(none<int>()));
      });

      test('encodes option numbers with explicit prefix', () {
        final codec = getOptionCodec(
          getU16Codec(),
          noneValue: const ZeroesOptionNoneValue(),
          prefix: getU8Codec(),
        );
        expect(hex(codec.encode(0)), equals('010000'));
        expect(hex(codec.encode(some(0))), equals('010000'));
        expect(hex(codec.encode(42)), equals('012a00'));
        expect(hex(codec.encode(some(42))), equals('012a00'));
        expect(hex(codec.encode(null)), equals('000000'));
        expect(hex(codec.encode(none<num>())), equals('000000'));
      });

      test('decodes option numbers with explicit prefix', () {
        final codec = getOptionCodec(
          getU16Codec(),
          noneValue: const ZeroesOptionNoneValue(),
          prefix: getU8Codec(),
        );
        expect(codec.decode(b('010000')), equals(some(0)));
        expect(codec.decode(b('012a00')), equals(some(42)));
        expect(codec.decode(b('000000')), equals(none<int>()));
      });

      test('encodes option numbers with custom prefix', () {
        final codec = getOptionCodec(
          getU16Codec(),
          noneValue: const ZeroesOptionNoneValue(),
          prefix: getU32Codec(),
        );
        expect(hex(codec.encode(0)), equals('010000000000'));
        expect(hex(codec.encode(42)), equals('010000002a00'));
        expect(hex(codec.encode(null)), equals('000000000000'));
      });

      test('decodes option numbers with custom prefix', () {
        final codec = getOptionCodec(
          getU16Codec(),
          noneValue: const ZeroesOptionNoneValue(),
          prefix: getU32Codec(),
        );
        expect(codec.decode(b('010000000000')), equals(some(0)));
        expect(codec.decode(b('010000002a00')), equals(some(42)));
        expect(codec.decode(b('000000000000')), equals(none<int>()));
      });

      test('encodes nested option numbers', () {
        final codec = getOptionCodec(
          getOptionCodec(
            getU16Codec(),
            noneValue: const ZeroesOptionNoneValue(),
          ),
          noneValue: const ZeroesOptionNoneValue(),
        );
        expect(hex(codec.encode(42)), equals('01012a00'));
        expect(hex(codec.encode(some(42))), equals('01012a00'));
        expect(hex(codec.encode(some(some(42)))), equals('01012a00'));
        expect(hex(codec.encode(some<Object?>(null))), equals('01000000'));
        expect(hex(codec.encode(some(none<int>()))), equals('01000000'));
        expect(hex(codec.encode(null)), equals('00000000'));
        expect(hex(codec.encode(none<Object?>())), equals('00000000'));
      });

      test('decodes nested option numbers', () {
        final codec = getOptionCodec(
          getOptionCodec(
            getU16Codec(),
            noneValue: const ZeroesOptionNoneValue(),
          ),
          noneValue: const ZeroesOptionNoneValue(),
        );
        expect(codec.decode(b('01012a00')), equals(some(some(42))));
        expect(codec.decode(b('01000000')), equals(some(none<int>())));
        expect(codec.decode(b('00000000')), equals(none<Option<int>>()));
      });

      test('pushes the offset forward when writing', () {
        final codec = getOptionCodec(
          getU16Codec(),
          noneValue: const ZeroesOptionNoneValue(),
        );
        expect(codec.write(257, Uint8List(10), 3), equals(6));
        expect(codec.write(null, Uint8List(10), 3), equals(6));
      });

      test('pushes the offset forward when reading', () {
        final codec = getOptionCodec(
          getU16Codec(),
          noneValue: const ZeroesOptionNoneValue(),
        );
        expect(codec.read(b('ffff01010100'), 2), equals((some(257), 5)));
        expect(codec.read(b('ffff00000000'), 2), equals((none<int>(), 5)));
      });

      test('returns a fixed size codec if the prefix is fixed', () {
        final codec = getOptionCodec(
          getU16Codec(),
          noneValue: const ZeroesOptionNoneValue(),
        );
        expect(codec, isA<FixedSizeCodec<Object?, Option<int>>>());
        expect(
          (codec as FixedSizeCodec<Object?, Option<int>>).fixedSize,
          equals(3),
        );
      });

      test('fails if the item is not fixed', () {
        expect(
          () => getOptionCodec(
            _getVariableSizeCodec(),
            noneValue: const ZeroesOptionNoneValue(),
          ),
          throwsA(
            isA<SolanaError>().having(
              (e) => e.code,
              'code',
              equals(SolanaErrorCode.codecsExpectedFixedLength),
            ),
          ),
        );
      });
    });

    group('with prefix and custom none value', () {
      test('encodes option numbers', () {
        final codec = getOptionCodec(
          getU16Codec(),
          noneValue: ConstantOptionNoneValue(b('ffff')),
        );
        expect(hex(codec.encode(0)), equals('010000'));
        expect(hex(codec.encode(some(0))), equals('010000'));
        expect(hex(codec.encode(42)), equals('012a00'));
        expect(hex(codec.encode(some(42))), equals('012a00'));
        expect(hex(codec.encode(null)), equals('00ffff'));
        expect(hex(codec.encode(none<num>())), equals('00ffff'));
      });

      test('decodes option numbers', () {
        final codec = getOptionCodec(
          getU16Codec(),
          noneValue: ConstantOptionNoneValue(b('ffff')),
        );
        expect(codec.decode(b('010000')), equals(some(0)));
        expect(codec.decode(b('012a00')), equals(some(42)));
        expect(codec.decode(b('00ffff')), equals(none<int>()));
      });

      test('encodes option numbers with explicit prefix', () {
        final codec = getOptionCodec(
          getU16Codec(),
          noneValue: ConstantOptionNoneValue(b('ffff')),
          prefix: getU8Codec(),
        );
        expect(hex(codec.encode(0)), equals('010000'));
        expect(hex(codec.encode(some(0))), equals('010000'));
        expect(hex(codec.encode(42)), equals('012a00'));
        expect(hex(codec.encode(some(42))), equals('012a00'));
        expect(hex(codec.encode(null)), equals('00ffff'));
        expect(hex(codec.encode(none<num>())), equals('00ffff'));
      });

      test('decodes option numbers with explicit prefix', () {
        final codec = getOptionCodec(
          getU16Codec(),
          noneValue: ConstantOptionNoneValue(b('ffff')),
          prefix: getU8Codec(),
        );
        expect(codec.decode(b('010000')), equals(some(0)));
        expect(codec.decode(b('012a00')), equals(some(42)));
        expect(codec.decode(b('00ffff')), equals(none<int>()));
      });

      test('encodes option numbers with custom prefix', () {
        final codec = getOptionCodec(
          getU16Codec(),
          noneValue: ConstantOptionNoneValue(b('ffff')),
          prefix: getU32Codec(),
        );
        expect(hex(codec.encode(0)), equals('010000000000'));
        expect(hex(codec.encode(some(0))), equals('010000000000'));
        expect(hex(codec.encode(42)), equals('010000002a00'));
        expect(hex(codec.encode(some(42))), equals('010000002a00'));
        expect(hex(codec.encode(null)), equals('00000000ffff'));
        expect(hex(codec.encode(none<num>())), equals('00000000ffff'));
      });

      test('decodes option numbers with custom prefix', () {
        final codec = getOptionCodec(
          getU16Codec(),
          noneValue: ConstantOptionNoneValue(b('ffff')),
          prefix: getU32Codec(),
        );
        expect(codec.decode(b('010000000000')), equals(some(0)));
        expect(codec.decode(b('010000002a00')), equals(some(42)));
        expect(codec.decode(b('00000000ffff')), equals(none<int>()));
      });

      test('encodes nested option numbers', () {
        final codec = getOptionCodec(
          getOptionCodec(
            getU16Codec(),
            noneValue: ConstantOptionNoneValue(b('ffff')),
          ),
          noneValue: ConstantOptionNoneValue(b('ffff')),
        );
        expect(hex(codec.encode(42)), equals('01012a00'));
        expect(hex(codec.encode(some(42))), equals('01012a00'));
        expect(hex(codec.encode(some(some(42)))), equals('01012a00'));
        expect(hex(codec.encode(some<Object?>(null))), equals('0100ffff'));
        expect(hex(codec.encode(some(none<int>()))), equals('0100ffff'));
        expect(hex(codec.encode(null)), equals('00ffff'));
        expect(hex(codec.encode(none<Object?>())), equals('00ffff'));
      });

      test('decodes nested option numbers', () {
        final codec = getOptionCodec(
          getOptionCodec(
            getU16Codec(),
            noneValue: ConstantOptionNoneValue(b('ffff')),
          ),
          noneValue: ConstantOptionNoneValue(b('ffff')),
        );
        expect(codec.decode(b('01012a00')), equals(some(some(42))));
        expect(codec.decode(b('0100ffff')), equals(some(none<int>())));
        expect(codec.decode(b('00ffff')), equals(none<Option<int>>()));
      });

      test('pushes the offset forward when writing', () {
        final codec = getOptionCodec(
          getU16Codec(),
          noneValue: ConstantOptionNoneValue(b('ffff')),
        );
        expect(codec.write(257, Uint8List(10), 3), equals(6));
        expect(codec.write(null, Uint8List(10), 3), equals(6));
      });

      test('pushes the offset forward when reading', () {
        final codec = getOptionCodec(
          getU16Codec(),
          noneValue: ConstantOptionNoneValue(b('aaaa')),
        );
        expect(codec.read(b('ffff01010100'), 2), equals((some(257), 5)));
        expect(codec.read(b('ffff00aaaa00'), 2), equals((none<int>(), 5)));
      });

      test('returns a variable size codec for different-length none value', () {
        final codec = getOptionCodec(
          getU16Codec(),
          noneValue: ConstantOptionNoneValue(b('ffffffff')),
        );
        expect(codec, isA<VariableSizeCodec<Object?, Option<int>>>());
        final varCodec = codec as VariableSizeCodec<Object?, Option<int>>;
        expect(varCodec.getSizeFromValue(null), equals(5));
        expect(varCodec.getSizeFromValue(42), equals(3));
        expect(varCodec.maxSize, equals(5));
      });
    });

    group('with no prefix nor none value', () {
      test('encodes option numbers', () {
        final codec = getOptionCodec(getU16Codec(), hasPrefix: false);
        expect(hex(codec.encode(42)), equals('2a00'));
        expect(hex(codec.encode(some(42))), equals('2a00'));
        expect(hex(codec.encode(null)), equals(''));
        expect(hex(codec.encode(none<num>())), equals(''));
      });

      test('decodes option numbers', () {
        final codec = getOptionCodec(getU16Codec(), hasPrefix: false);
        expect(codec.decode(b('2a00')), equals(some(42)));
        expect(codec.decode(b('')), equals(none<int>()));
      });

      test('encodes nested option numbers', () {
        final codec = getOptionCodec(
          getOptionCodec(getU16Codec(), hasPrefix: false),
          hasPrefix: false,
        );
        expect(hex(codec.encode(42)), equals('2a00'));
        expect(hex(codec.encode(some(42))), equals('2a00'));
        expect(hex(codec.encode(some(some(42)))), equals('2a00'));
        expect(hex(codec.encode(some<Object?>(null))), equals(''));
        expect(hex(codec.encode(some(none<int>()))), equals(''));
        expect(hex(codec.encode(null)), equals(''));
        expect(hex(codec.encode(none<Object?>())), equals(''));
      });

      test('decodes nested option numbers', () {
        final codec = getOptionCodec(
          getOptionCodec(getU16Codec(), hasPrefix: false),
          hasPrefix: false,
        );
        expect(codec.decode(b('2a00')), equals(some(some(42))));
        expect(codec.decode(b('')), equals(none<Option<int>>()));
      });

      test('pushes the offset forward when writing', () {
        final codec = getOptionCodec(getU16Codec(), hasPrefix: false);
        expect(codec.write(257, Uint8List(10), 3), equals(5));
        expect(codec.write(null, Uint8List(10), 3), equals(3));
      });

      test('pushes the offset forward when reading', () {
        final codec = getOptionCodec(getU16Codec(), hasPrefix: false);
        expect(codec.read(b('ffff010100'), 2), equals((some(257), 4)));
        expect(codec.read(b('ffff'), 2), equals((none<int>(), 2)));
      });

      test('returns a variable size codec', () {
        final codec = getOptionCodec(getU16Codec(), hasPrefix: false);
        expect(codec, isA<VariableSizeCodec<Object?, Option<int>>>());
        final varCodec = codec as VariableSizeCodec<Object?, Option<int>>;
        expect(varCodec.getSizeFromValue(null), equals(0));
        expect(varCodec.getSizeFromValue(42), equals(2));
        expect(varCodec.maxSize, equals(2));
      });
    });
  });
}

/// Creates a variable-size codec for testing error cases.
VariableSizeCodec<String, String> _getVariableSizeCodec() {
  return VariableSizeCodec<String, String>(
    getSizeFromValue: (value) => value.length,
    write: (value, bytes, offset) {
      for (var i = 0; i < value.length; i++) {
        bytes[offset + i] = value.codeUnitAt(i);
      }
      return offset + value.length;
    },
    read: (bytes, offset) {
      final value = String.fromCharCodes(bytes, offset);
      return (value, bytes.length);
    },
  );
}
