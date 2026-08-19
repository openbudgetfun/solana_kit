import 'dart:math' as math;

/// One million — the number of microLamports in a lamport.
final microLamportsPerLamport = BigInt.from(1000000);

/// A resolved priority fee, expressed in both units the network uses.
class ResolvedPriorityFee {
  /// Creates a resolved priority fee.
  const ResolvedPriorityFee({required this.rate, required this.lamports});

  /// MicroLamports per compute unit — what legacy and v0 transactions request.
  final int rate;

  /// Total lamports — what version 1 transactions carry in their header config.
  final BigInt lamports;
}

/// Input for [resolvePriorityFee].
class ResolvePriorityFeeInput {
  /// Creates resolve-priority-fee input.
  const ResolvePriorityFeeInput({
    required this.estimate,
    required this.units,
    this.rateCap,
    this.lamportsCap,
  });

  /// Helius' recommended rate, in microLamports per CU.
  final double estimate;

  /// Compute-unit limit the transaction will request.
  final int units;

  /// Optional ceiling on the per-CU rate.
  final double? rateCap;

  /// Optional ceiling on total lamports spent on priority. Accepts a [num]
  /// or a [BigInt].
  final Object? lamportsCap;
}

/// Normalises a caller-supplied lamport cap into a non-negative whole number
/// of lamports, or `null` for "no ceiling".
///
/// `BigInt()` throws on a fraction, and a cap is easy to compute into one
/// (`budget / 3`), so the value is floored first.
///
/// Non-finite input resolves the way the same input resolves for `rateCap`,
/// where `min` decides it: `Infinity` is no ceiling at all, while `NaN` —
/// which can only be a caller bug — collapses to zero rather than silently
/// lifting the ceiling the caller asked for.
BigInt? _toWholeLamports(Object cap) => switch (cap) {
  final BigInt b => b.isNegative ? BigInt.zero : b,
  final num n when n == double.infinity => null,
  final num n when n.isNaN => BigInt.zero,
  final num n => BigInt.from(n >= 0 ? n.floorToDouble() : 0),
  _ => throw ArgumentError.value(cap, 'cap', 'must be a num or BigInt'),
};

/// Converts an integer microLamports-per-CU rate into a total lamport fee,
/// rounding up so the transaction never underpays relative to that rate.
BigInt _toLamports(int rate, int units) {
  final totalMicroLamports =
      BigInt.from(rate) * BigInt.from(math.max(0, units));
  return (totalMicroLamports + microLamportsPerLamport - BigInt.one) ~/
      microLamportsPerLamport;
}

/// Resolves the priority fee a transaction should pay, in both the per-CU rate
/// that legacy/v0 transactions request and the total lamport amount that
/// version 1 transactions carry in their header config (SIMD-0385).
///
/// Both caps are applied by clamping the rate, so the returned `rate` and
/// `lamports` always describe the same fee regardless of transaction version.
///
/// The rate is floored to a whole microLamport. Helius can return a fractional
/// estimate, and the compute-budget instruction encodes the rate as a `u64` —
/// passing a fraction there throws. Rounding down rather than to nearest also
/// keeps the `rateCap` and `lamportsCap` inputs true ceilings.
ResolvedPriorityFee resolvePriorityFee(ResolvePriorityFeeInput input) {
  var rate = input.rateCap != null
      ? math.min(input.estimate, input.rateCap!)
      : input.estimate;

  if (input.lamportsCap != null && input.units > 0) {
    final cap = _toWholeLamports(input.lamportsCap!);
    if (cap != null) {
      final clampedRate =
          (cap * microLamportsPerLamport) ~/ BigInt.from(input.units);
      rate = math.min(rate, clampedRate.toDouble());
    }
  }

  rate = rate.isFinite ? math.max(0, rate.floorToDouble()) : 0;
  final wholeRate = rate.toInt();
  return ResolvedPriorityFee(
    rate: wholeRate,
    lamports: _toLamports(wholeRate, input.units),
  );
}
