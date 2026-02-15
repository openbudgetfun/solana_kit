import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:test/test.dart';

void main() {
  group('assertIsLamports()', () {
    test('throws when supplied a negative number', () {
      expect(
        () => assertIsLamports(-BigInt.one),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.lamportsOutOfRange,
          ),
        ),
      );
      expect(
        () => assertIsLamports(-BigInt.from(1000)),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.lamportsOutOfRange,
          ),
        ),
      );
    });

    test('throws when supplied a too large number', () {
      expect(
        () => assertIsLamports(BigInt.two.pow(64)),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.lamportsOutOfRange,
          ),
        ),
      );
    });

    test('does not throw when supplied zero lamports', () {
      expect(() => assertIsLamports(BigInt.zero), returnsNormally);
    });

    test(
      'does not throw when supplied a valid non-zero number of lamports',
      () {
        expect(
          () => assertIsLamports(BigInt.from(1000000000)),
          returnsNormally,
        );
      },
    );

    test('does not throw when supplied the max valid number of lamports', () {
      expect(
        () => assertIsLamports(BigInt.two.pow(64) - BigInt.one),
        returnsNormally,
      );
    });
  });

  group('isLamports()', () {
    test('returns true for zero', () {
      expect(isLamports(BigInt.zero), isTrue);
    });

    test('returns true for a valid value', () {
      expect(isLamports(BigInt.from(1000000000)), isTrue);
    });

    test('returns true for max u64', () {
      expect(isLamports(BigInt.two.pow(64) - BigInt.one), isTrue);
    });

    test('returns false for negative', () {
      expect(isLamports(-BigInt.one), isFalse);
    });

    test('returns false for too large', () {
      expect(isLamports(BigInt.two.pow(64)), isFalse);
    });
  });

  group('lamports()', () {
    test('can coerce to Lamports', () {
      final coerced = lamports(BigInt.from(1234));
      expect(coerced.value, equals(BigInt.from(1234)));
    });

    test('throws on invalid Lamports', () {
      expect(
        () => lamports(-BigInt.from(5)),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.lamportsOutOfRange,
          ),
        ),
      );
    });
  });

  group('getDefaultLamportsEncoder', () {
    test('encodes a lamports value using the default u64 encoder', () {
      final lamportsValue = lamports(BigInt.from(1000000000));
      final encoder = getDefaultLamportsEncoder();
      final buffer = encoder.encode(lamportsValue);
      expect(buffer, equals(Uint8List.fromList([0, 202, 154, 59, 0, 0, 0, 0])));
    });

    test('has a fixed size of 8', () {
      final encoder = getDefaultLamportsEncoder();
      expect(encoder.fixedSize, equals(8));
    });
  });

  group('getLamportsEncoder', () {
    test('encodes a lamports value using a passed u8 encoder', () {
      final lamportsValue = lamports(BigInt.from(100));
      final encoder = getLamportsEncoder(getU8Encoder());
      final buffer = encoder.encode(lamportsValue);
      expect(buffer, equals(Uint8List.fromList([100])));
    });

    test('encodes a lamports value using a passed big-endian u16 encoder', () {
      final lamportsValue = lamports(BigInt.from(100));
      final encoder = getLamportsEncoder(
        getU16Encoder(const NumberCodecConfig(endian: Endian.big)),
      );
      final buffer = encoder.encode(lamportsValue);
      expect(buffer, equals(Uint8List.fromList([0, 100])));
    });

    test('encodes a lamports value using a passed u64 encoder', () {
      final lamportsValue = lamports(
        BigInt.parse('ffffffffffffffff', radix: 16),
      );
      final encoder = getLamportsEncoder(getU64Encoder());
      final buffer = encoder.encode(lamportsValue);
      expect(
        buffer,
        equals(Uint8List.fromList([255, 255, 255, 255, 255, 255, 255, 255])),
      );
    });

    test('has a fixed size of 1 for a passed u8 encoder', () {
      final encoder = getLamportsEncoder(getU8Encoder());
      expect((encoder as FixedSizeEncoder).fixedSize, equals(1));
    });
  });

  group('getDefaultLamportsDecoder', () {
    test('decodes an 8-byte buffer into a lamports value '
        'using the default u64 decoder', () {
      final buffer = Uint8List.fromList([0, 29, 50, 247, 69, 0, 0, 0]);
      final decoder = getDefaultLamportsDecoder();
      final lamportsValue = decoder.decode(buffer);
      expect(lamportsValue, equals(lamports(BigInt.from(300500000000))));
    });

    test('has a fixed size of 8', () {
      final decoder = getDefaultLamportsDecoder();
      expect(decoder.fixedSize, equals(8));
    });
  });

  group('getLamportsDecoder', () {
    test('decodes a 1-byte buffer into a lamports value using u8 decoder', () {
      final buffer = Uint8List.fromList([100]);
      final decoder = getLamportsDecoder(getU8Decoder());
      final lamportsValue = decoder.decode(buffer);
      expect(lamportsValue, equals(lamports(BigInt.from(100))));
    });

    test('decodes a 2-byte buffer into a lamports value '
        'using big-endian u16 decoder', () {
      final buffer = Uint8List.fromList([0, 100]);
      final decoder = getLamportsDecoder(
        getU16Decoder(const NumberCodecConfig(endian: Endian.big)),
      );
      final lamportsValue = decoder.decode(buffer);
      expect(lamportsValue, equals(lamports(BigInt.from(100))));
    });

    test(
      'decodes an 8-byte buffer into a lamports value using u64 decoder',
      () {
        final buffer = Uint8List.fromList([
          255,
          255,
          255,
          255,
          255,
          255,
          255,
          255,
        ]);
        final decoder = getLamportsDecoder(getU64Decoder());
        final lamportsValue = decoder.decode(buffer);
        expect(
          lamportsValue,
          equals(lamports(BigInt.parse('ffffffffffffffff', radix: 16))),
        );
      },
    );

    test('has a fixed size of 1 for a passed u8 decoder', () {
      final decoder = getLamportsDecoder(getU8Decoder());
      expect((decoder as FixedSizeDecoder).fixedSize, equals(1));
    });
  });

  group('getDefaultLamportsCodec', () {
    test('encodes a lamports value using the default u64 encoder', () {
      final lamportsValue = lamports(BigInt.from(1000000000));
      final codec = getDefaultLamportsCodec();
      final buffer = codec.encode(lamportsValue);
      expect(buffer, equals(Uint8List.fromList([0, 202, 154, 59, 0, 0, 0, 0])));
    });

    test('decodes an 8-byte buffer into a lamports value '
        'using the default u64 decoder', () {
      final buffer = Uint8List.fromList([0, 29, 50, 247, 69, 0, 0, 0]);
      final codec = getDefaultLamportsCodec();
      final lamportsValue = codec.decode(buffer);
      expect(lamportsValue, equals(lamports(BigInt.from(300500000000))));
    });

    test('has a fixed size of 8', () {
      final codec = getDefaultLamportsCodec();
      expect(codec.fixedSize, equals(8));
    });
  });

  group('getLamportsCodec', () {
    test('encodes a lamports value using a passed u8 codec', () {
      final lamportsValue = lamports(BigInt.from(100));
      final codec = getLamportsCodec(getU8Codec());
      final buffer = codec.encode(lamportsValue);
      expect(buffer, equals(Uint8List.fromList([100])));
    });

    test('encodes a lamports value using a passed big-endian u16 codec', () {
      final lamportsValue = lamports(BigInt.from(100));
      final codec = getLamportsCodec(
        getU16Codec(const NumberCodecConfig(endian: Endian.big)),
      );
      final buffer = codec.encode(lamportsValue);
      expect(buffer, equals(Uint8List.fromList([0, 100])));
    });

    test('encodes a lamports value using a passed u64 codec', () {
      final lamportsValue = lamports(
        BigInt.parse('ffffffffffffffff', radix: 16),
      );
      final codec = getLamportsCodec(getU64Codec());
      final buffer = codec.encode(lamportsValue);
      expect(
        buffer,
        equals(Uint8List.fromList([255, 255, 255, 255, 255, 255, 255, 255])),
      );
    });

    test('decodes a 1-byte buffer into a lamports value using u8 codec', () {
      final buffer = Uint8List.fromList([100]);
      final codec = getLamportsCodec(getU8Codec());
      final lamportsValue = codec.decode(buffer);
      expect(lamportsValue, equals(lamports(BigInt.from(100))));
    });

    test('decodes a 2-byte buffer into a lamports value '
        'using big-endian u16 codec', () {
      final buffer = Uint8List.fromList([0, 100]);
      final codec = getLamportsCodec(
        getU16Codec(const NumberCodecConfig(endian: Endian.big)),
      );
      final lamportsValue = codec.decode(buffer);
      expect(lamportsValue, equals(lamports(BigInt.from(100))));
    });

    test('decodes an 8-byte buffer into a lamports value using u64 codec', () {
      final buffer = Uint8List.fromList([
        255,
        255,
        255,
        255,
        255,
        255,
        255,
        255,
      ]);
      final codec = getLamportsCodec(getU64Codec());
      final lamportsValue = codec.decode(buffer);
      expect(
        lamportsValue,
        equals(lamports(BigInt.parse('ffffffffffffffff', radix: 16))),
      );
    });

    test('has a fixed size of 1 for a passed u8 codec', () {
      final codec = getLamportsCodec(getU8Codec());
      expect((codec as FixedSizeCodec).fixedSize, equals(1));
    });
  });
}
