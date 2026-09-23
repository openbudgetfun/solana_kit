/// An internal character-to-digit index for a base-X alphabet.
///
/// Alphabets are looked up by UTF-16 code unit, which is exactly what
/// `String.indexOf` reports for the per-character scans this replaces. Every
/// alphabet the SDK ships is ASCII (base-16, base-10, base-58), so lookups hit
/// a dense list instead of scanning the alphabet once per character.
///
/// Buffer sizing uses integer bit arithmetic rather than floating point, so
/// the bounds are exact upper limits that can never truncate a conversion.
class BaseXLookup {
  /// Builds the digit index for [alphabet].
  BaseXLookup(this.alphabet) {
    final codeUnits = alphabet.codeUnits;
    // A base-X alphabet needs at least two symbols. A shorter one cannot
    // represent any value and previously produced silent zero output.
    if (codeUnits.length < 2) {
      throw ArgumentError.value(
        alphabet,
        'alphabet',
        'a base-X alphabet must contain at least two characters',
      );
    }
    base = codeUnits.length;
    zeroCharacter = String.fromCharCode(codeUnits.first);

    if (codeUnits.every((unit) => unit < _denseLimit)) {
      final dense = List<int>.filled(_denseLimit, -1);

      for (var i = 0; i < codeUnits.length; i++) {
        // First occurrence wins, matching `alphabet.indexOf`.
        if (dense[codeUnits[i]] == -1) dense[codeUnits[i]] = i;
      }
      _dense = dense;
    } else {
      final sparse = <int, int>{};

      for (var i = 0; i < codeUnits.length; i++) {
        sparse.putIfAbsent(codeUnits[i], () => i);
      }
      _sparse = sparse;
    }
  }

  static const _denseLimit = 128;

  /// The alphabet this lookup indexes.
  final String alphabet;

  /// The character that encodes a zero byte, i.e. the first alphabet entry.
  late final String zeroCharacter;

  /// The number of characters in the alphabet.
  late final int base;

  /// Bits contributed by one significant character: `(base - 1).bitLength`.
  ///
  /// Since `base <= 2^bits`, a `characters`-long base-X value is below
  /// `2^(characters * bits)` and therefore always fits in
  /// [bytesForCharacters] bytes.
  late final int bitsPerCharacter = (base - 1).bitLength;

  /// `floor(log2(base))`, at least 1 because [base] is at least 2.
  late final int _floorLog2Base = base.bitLength - 1;

  /// Cached digit indexes for alphabets whose code units fit in
  /// `_denseLimit`, or null when this lookup uses [_sparse] instead.
  List<int>? _dense;

  /// Cached digit indexes for alphabets with wide code units, or null when
  /// this lookup uses [_dense] instead.
  Map<int, int>? _sparse;

  /// Bytes that can hold any [characters]-long significant base-X value.
  int bytesForCharacters(int characters) =>
      (characters * bitsPerCharacter + 7) >> 3;

  /// Digit slots that can hold any [bytes]-long value in this base.
  ///
  /// Uses `floor(log2(base))` in place of the true log, which only makes the
  /// result larger, so it never under-allocates.
  int digitsForBytes(int bytes) =>
      (bytes * 8 + _floorLog2Base - 1) ~/ _floorLog2Base;

  /// The digit index for [codeUnit], or `-1` when it is not in the alphabet.
  int indexOf(int codeUnit) {
    if (_dense case final dense?) {
      return codeUnit < _denseLimit ? dense[codeUnit] : -1;
    }
    return _sparse![codeUnit] ?? -1;
  }
}

/// The shared lookup for [alphabet], built on first use.
///
/// Encoders, decoders, and the standalone validator all resolve through here so
/// a hot path indexes each alphabet once instead of once per call. The cache is
/// capped so an application that manufactures unbounded distinct alphabets
/// cannot grow it without limit; crossing the cap clears it rather than
/// retaining everything.
BaseXLookup baseXLookupFor(String alphabet) {
  final cached = _lookups[alphabet];

  if (cached != null) return cached;
  final lookup = BaseXLookup(alphabet);

  if (_lookups.length >= _lookupCacheLimit) {
    _lookups.clear();
  }
  _lookups[alphabet] = lookup;
  return lookup;
}

final Map<String, BaseXLookup> _lookups = {};

const int _lookupCacheLimit = 64;
