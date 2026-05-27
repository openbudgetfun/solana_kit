import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

import 'package:solana_kit_rpc_types/src/lamports.dart';

/// The number of Lamports in one SOL.
final BigInt lamportsPerSol = BigInt.from(1000000000);

/// Rounding strategy used when parsing a decimal SOL string with more than
/// nine fractional digits.
enum RoundingMode {
  /// Reject values that cannot be represented exactly in Lamports.
  strict,

  /// Truncate extra fractional digits.
  down,

  /// Round away from zero when any truncated digit is non-zero.
  up,

  /// Round to the nearest Lamport, half up.
  halfUp,
}

/// Represents a fixed-point SOL amount with nine decimal places.
///
/// The raw value is the exact Lamports count, so conversions between [Sol] and
/// [Lamports] are lossless.
extension type const Sol(BigInt raw) implements Lamports, Object {
  /// Formats this value as a decimal SOL string.
  String toDecimalString() {
    final whole = raw ~/ lamportsPerSol;
    final fraction = (raw % lamportsPerSol).toString().padLeft(9, '0');
    final trimmedFraction = fraction.replaceFirst(RegExp(r'0+$'), '');
    return trimmedFraction.isEmpty
        ? whole.toString()
        : '$whole.$trimmedFraction';
  }
}

/// Parses [value] as a SOL fixed-point amount.
///
/// Values are unsigned and support up to nine fractional digits. Use [rounding]
/// to accept inputs with more fractional precision.
Sol sol(String value, {RoundingMode rounding = RoundingMode.strict}) {
  final trimmed = value.trim();
  if (trimmed.isEmpty || trimmed.startsWith('-')) {
    throw FormatException('Expected an unsigned SOL decimal string.', value);
  }

  final parts = trimmed.split('.');
  if (parts.length > 2) {
    throw FormatException('Expected an unsigned SOL decimal string.', value);
  }

  final wholePart = parts[0].isEmpty ? '0' : parts[0];
  final fractionPart = parts.length == 2 ? parts[1] : '';
  final digits = RegExp(r'^\d+$');
  if (!digits.hasMatch(wholePart) ||
      (fractionPart.isNotEmpty && !digits.hasMatch(fractionPart))) {
    throw FormatException('Expected an unsigned SOL decimal string.', value);
  }

  var paddedFraction = fractionPart;
  var increment = false;
  if (paddedFraction.length > 9) {
    final extra = paddedFraction.substring(9);
    switch (rounding) {
      case RoundingMode.strict:
        throw FormatException(
          'SOL value cannot be represented without precision loss.',
          value,
        );
      case RoundingMode.down:
        break;
      case RoundingMode.up:
        increment = extra.contains(RegExp('[1-9]'));
      case RoundingMode.halfUp:
        increment = int.parse(extra[0]) >= 5;
    }
    paddedFraction = paddedFraction.substring(0, 9);
  }

  paddedFraction = paddedFraction.padRight(9, '0');
  var raw =
      BigInt.parse(wholePart) * lamportsPerSol + BigInt.parse(paddedFraction);
  if (increment) raw += BigInt.one;

  return lamportsToSol(lamports(raw));
}

/// Converts [value] to its equivalent Lamports amount.
Lamports solToLamports(Sol value) => lamports(value.raw);

/// Converts [value] to its equivalent SOL fixed-point amount.
Sol lamportsToSol(Lamports value) => Sol(value.value);

/// Returns an encoder that writes a [Sol] or [Lamports] value as an unsigned
/// 64-bit Lamports count in little-endian order.
FixedSizeEncoder<Object> getSolEncoder() {
  final inner = getU64Encoder();
  return FixedSizeEncoder<Object>(
    fixedSize: inner.fixedSize,
    write: (value, bytes, offset) {
      final raw = value is BigInt
          ? value
          : throw ArgumentError.value(
              value,
              'value',
              'Expected Sol or Lamports',
            );
      return inner.write(raw, bytes, offset);
    },
  );
}

/// Returns a decoder that reads an unsigned 64-bit Lamports count as [Sol].
FixedSizeDecoder<Sol> getSolDecoder() {
  final inner = getU64Decoder();
  return FixedSizeDecoder<Sol>(
    fixedSize: inner.fixedSize,
    read: (bytes, offset) {
      final (value, newOffset) = inner.read(bytes, offset);
      return (lamportsToSol(lamports(value)), newOffset);
    },
  );
}

/// Returns a codec that encodes [Sol] or [Lamports] values and decodes [Sol].
FixedSizeCodec<Object, Sol> getSolCodec() {
  return combineCodec(getSolEncoder(), getSolDecoder())
      as FixedSizeCodec<Object, Sol>;
}
