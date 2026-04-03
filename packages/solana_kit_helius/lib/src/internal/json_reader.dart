// ignore_for_file: public_member_api_docs
/// Internal JSON reading helpers for Helius type deserialization.
///
/// [JsonReader] wraps a raw `Map<String, Object?>` and provides typed
/// accessor methods that eliminate manual `! as T` casts in every
/// `fromJson` factory. This keeps deserialization code readable and
/// ensures consistent error surfaces when a field is missing or
/// unexpectedly null.
///
/// This file is intentionally **not** exported from
/// `lib/solana_kit_helius.dart` — it is an implementation detail.
class JsonReader {
  const JsonReader(this._json);

  final Map<String, Object?> _json;

  // -------------------------------------------------------------------------
  // Required (non-nullable) accessors — throw StateError when key is absent
  // or the value is null.
  // -------------------------------------------------------------------------

  /// Returns the [String] value for [key]. Throws if absent or null.
  String requireString(String key) => _require<String>(key);

  /// Returns the [int] value for [key]. Throws if absent or null.
  int requireInt(String key) => _require<int>(key);

  /// Returns the [bool] value for [key]. Throws if absent or null.
  bool requireBool(String key) => _require<bool>(key);

  /// Returns the [double] value for [key], coercing [num] via [num.toDouble].
  /// Throws if absent or null.
  double requireDouble(String key) {
    final value = _json[key];
    if (value == null) _missing(key);
    return (value as num).toDouble();
  }

  /// Returns the raw [Map<String, Object?>] for [key]. Throws if absent or
  /// null.
  Map<String, Object?> requireMap(String key) =>
      _require<Map<String, Object?>>(key);

  /// Returns a [List] for [key] and casts each element to [E].
  /// Throws if absent or null.
  List<E> requireList<E>(String key) =>
      _require<List<Object?>>(key).cast<E>();

  /// Returns a required [List] and maps each element to [T] via [mapper].
  ///
  /// The [mapper] receives the raw `Object?` — callers should cast as needed.
  List<T> requireMappedList<T>(String key, T Function(Object?) mapper) =>
      _require<List<Object?>>(key).map(mapper).toList();

  /// Returns a required [List] of maps, decoding each element via [decoder].
  ///
  /// Each list element is cast to `Map<String, Object?>` before being passed
  /// to [decoder], eliminating inline casts in `fromJson` factories.
  List<T> requireDecodedList<T>(
    String key,
    T Function(Map<String, Object?>) decoder,
  ) =>
      _require<List<Object?>>(key)
          .map((e) => decoder(e! as Map<String, Object?>))
          .toList();

  // -------------------------------------------------------------------------
  // Optional (nullable) accessors — return null when key is absent or null.
  // -------------------------------------------------------------------------

  /// Returns the [String] value for [key], or null if absent / null.
  String? optString(String key) => _json[key] as String?;

  /// Returns the [int] value for [key], or null if absent / null.
  int? optInt(String key) => _json[key] as int?;

  /// Returns the [bool] value for [key], or null if absent / null.
  bool? optBool(String key) => _json[key] as bool?;

  /// Returns the [double] value for [key], coercing [num] via [num.toDouble],
  /// or null if absent / null.
  double? optDouble(String key) => (_json[key] as num?)?.toDouble();

  /// Returns the raw [Map<String, Object?>] for [key], or null if absent /
  /// null.
  Map<String, Object?>? optMap(String key) =>
      _json[key] as Map<String, Object?>?;

  /// Returns a typed [List] for [key] casting each element to [E], or null if
  /// absent / null.
  List<E>? optList<E>(String key) =>
      (_json[key] as List<Object?>?)?.cast<E>();

  /// Returns a mapped [List] for [key] via [mapper], or null if absent / null.
  List<T>? optMappedList<T>(String key, T Function(Object?) mapper) =>
      (_json[key] as List<Object?>?)?.map(mapper).toList();

  /// Returns a mapped [List] of maps for [key] via [decoder], or null if
  /// absent / null.
  ///
  /// Each list element is cast to `Map<String, Object?>` before being passed
  /// to [decoder], eliminating inline casts in `fromJson` factories.
  List<T>? optDecodedList<T>(
    String key,
    T Function(Map<String, Object?>) decoder,
  ) =>
      (_json[key] as List<Object?>?)
          ?.map((e) => decoder(e! as Map<String, Object?>))
          .toList();

  /// Returns a typed value decoded by [decoder] when the key is present and
  /// non-null, otherwise null.
  ///
  /// Useful for nested objects: `r.optDecoded('content', AssetContent.fromJson)`
  T? optDecoded<T>(
    String key,
    T Function(Map<String, Object?>) decoder,
  ) {
    final raw = _json[key];
    if (raw == null) return null;
    return decoder(raw as Map<String, Object?>);
  }

  /// Returns an enum value decoded by [decoder] when the key is present and
  /// non-null, otherwise null.
  ///
  /// Useful for optional enums: `r.optEnum('sortBy', AssetSortBy.fromJson)`
  T? optEnum<T>(String key, T Function(String) decoder) {
    final raw = _json[key];
    if (raw == null) return null;
    return decoder(raw as String);
  }

  // -------------------------------------------------------------------------
  // Raw access
  // -------------------------------------------------------------------------

  /// Returns the raw value for [key] without any cast.
  Object? raw(String key) => _json[key];

  // -------------------------------------------------------------------------
  // Internal helpers
  // -------------------------------------------------------------------------

  T _require<T>(String key) {
    final value = _json[key];
    if (value == null) _missing(key);
    return value as T;
  }

  Never _missing(String key) {
    throw FormatException(
      'JsonReader: required key "$key" is absent or null',
    );
  }
}
