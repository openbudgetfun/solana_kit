import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/src/utils.dart';

/// A factory that builds a [Decoder] for a struct field whose shape depends on
/// the values of previously decoded fields in the same struct.
///
/// The function receives a frozen snapshot of all fields that have been decoded
/// so far, in declaration order, and must return the [Decoder] that should be
/// used to read the current field from the byte stream.
///
/// See [createDependentStructDecoder].
typedef DependentStructDecoderFieldFactory =
    Decoder<Object?> Function(Map<String, Object?> fields);

class _InternalEntry {
  _InternalEntry({
    required this.name,
    required this.resolveDecoder,
    this.staticDecoder,
  });

  final String name;

  /// Resolves the decoder for this entry, given the fields decoded so far.
  final Decoder<Object?> Function(Map<String, Object?> fields) resolveDecoder;

  /// The static decoder for this entry, if the entry was added with one
  /// directly. Absent when the entry was added with a factory, in which case
  /// the entry is treated as variable size for the purposes of computing the
  /// struct's total fixed size.
  final Decoder<Object?>? staticDecoder;
}

/// A fluent builder that accumulates field decoders for a struct whose later
/// fields may depend on the values of earlier ones.
///
/// Each call to [field] returns a new builder whose accumulated field list is
/// extended by the newly added field. Call [build] to obtain the final
/// [Decoder] once every field has been declared.
///
/// The builder mirrors the fixed vs variable size behaviour of
/// `getStructDecoder`. The empty builder finishes to a [FixedSizeDecoder] of
/// size zero. Adding a [FixedSizeDecoder] preserves the fixed size property
/// and the sizes accumulate. Adding a [VariableSizeDecoder] or a
/// [DependentStructDecoderFieldFactory] drops the builder to variable size,
/// which is then preserved by every subsequent [field] call.
///
/// Instances of this class are immutable. Calling [field] does not mutate the
/// receiver; it returns a new builder.
///
/// Added in @solana/kit v7.0.0.
class DependentStructDecoderBuilder {
  DependentStructDecoderBuilder._(this._entries);

  final List<_InternalEntry> _entries;

  /// Finalizes the builder and returns a [Decoder] that decodes each declared
  /// field in turn, in the order they were added.
  ///
  /// Returns a [FixedSizeDecoder] when every field has been added with a
  /// fixed-size decoder, and a [VariableSizeDecoder] otherwise.
  Decoder<Map<String, Object?>> build() {
    final staticDecoders = _entries.map((e) => e.staticDecoder).toList();
    final everyStatic = staticDecoders.every((d) => d != null);
    final fixedSize = everyStatic
        ? sumCodecSizes(
            staticDecoders.cast<Decoder<Object?>>().map(getFixedSize).toList(),
          )
        : null;

    (Map<String, Object?>, int) readImpl(Uint8List bytes, int currentOffset) {
      var offset = currentOffset;
      // A fresh, mutable snapshot of the fields decoded so far. It is frozen
      // (via `Map.unmodifiable`) before being handed to each field factory so
      // that dependent factories cannot mutate earlier decoded values.
      final decoded = <String, Object?>{};
      for (final entry in _entries) {
        final decoder = entry.resolveDecoder(Map.unmodifiable(decoded));
        final (value, newOffset) = decoder.read(bytes, offset);
        offset = newOffset;
        decoded[entry.name] = value;
      }
      return (decoded, offset);
    }

    if (fixedSize != null) {
      return FixedSizeDecoder<Map<String, Object?>>(
        fixedSize: fixedSize,
        read: readImpl,
      );
    }
    return VariableSizeDecoder<Map<String, Object?>>(read: readImpl);
  }

  /// Adds a field decoded by [decoderOrFactory].
  ///
  /// Pass a [Decoder] for a field whose shape is independent of earlier
  /// fields. Pass a [DependentStructDecoderFieldFactory] for a field whose
  /// decoder must be built from a frozen snapshot of the fields that precede
  /// it.
  ///
  /// Adding a [VariableSizeDecoder] or a factory drops the builder to
  /// variable size; subsequent [field] calls cannot raise it back to fixed
  /// size.
  DependentStructDecoderBuilder field(
    String name,
    Object decoderOrFactory,
  ) {
    final isFactory = decoderOrFactory is! Decoder;
    late final Decoder<Object?> Function(Map<String, Object?> fields)
    resolveDecoder;
    late final Decoder<Object?>? staticDecoder;
    if (isFactory) {
      final factory = decoderOrFactory as DependentStructDecoderFieldFactory;
      resolveDecoder = (fields) =>
          factory(Map<String, Object?>.unmodifiable(fields));
      // A factory-added entry is treated as variable size for the purposes of
      // computing the struct's total fixed size, since its byte length cannot
      // be known until the earlier fields have been decoded.
      staticDecoder = null;
    } else {
      final decoder = decoderOrFactory as Decoder<Object?>;
      resolveDecoder = (_) => decoder;
      staticDecoder = decoder;
    }
    return DependentStructDecoderBuilder._([
      ..._entries,
      _InternalEntry(
        name: name,
        resolveDecoder: resolveDecoder,
        staticDecoder: staticDecoder,
      ),
    ]);
  }
}

/// Creates a fluent builder for a struct decoder whose later fields may depend
/// on the decoded values of earlier ones.
///
/// Unlike `getStructDecoder`, which accepts a fixed array of named decoders,
/// this builder lets each field provide a factory that receives the values
/// that have already been decoded. This is useful for binary formats where a
/// count, version, or discriminator decoded near the start of the struct
/// controls how a later field must be parsed.
///
/// The builder mirrors the fixed vs variable size behaviour of
/// `getStructDecoder`. The empty builder finishes to a [FixedSizeDecoder] of
/// size zero. Adding a [FixedSizeDecoder] preserves the fixed size property
/// and the sizes accumulate. Adding a [VariableSizeDecoder] or a
/// [DependentStructDecoderFieldFactory] drops the builder to variable size,
/// which is then preserved by every subsequent `field` call.
///
/// The returned builder is immutable; each `field` call returns a new builder
/// whose accumulated field list is extended by the newly added field. Call
/// `build` to produce the final decoder.
///
/// Prefer `getStructDecoder` when every field's decoder is independent of the
/// values that precede it. Reach for this builder only when at least one field
/// needs to be parameterised by another.
///
/// The encoder direction does not need a dependent variant. An encoder
/// already has access to the entire value when serialising, so the existing
/// `getStructEncoder` can be paired with the decoder returned by this builder
/// and combined with `combineCodec` to obtain a full codec.
///
/// Added in @solana/kit v7.0.0.
///
/// ```dart
/// import 'dart:typed_data';
///
/// import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
/// import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
///
/// void main() {
///   final decoder = createDependentStructDecoder()
///       .field('count', getU8Decoder())
///       .field(
///         'values',
///         (fields) => getArrayDecoder(
///           getU32Decoder(),
///           size: FixedArraySize(fields['count']! as int),
///         ),
///       )
///       .build();
///
///   final (value, _) =
///       decoder.read(Uint8List.fromList([2, 1, 0, 0, 0, 2, 0, 0, 0]), 0);
///   print(value); // {count: 2, values: [1, 2]}
/// }
/// ```
DependentStructDecoderBuilder createDependentStructDecoder() {
  return DependentStructDecoderBuilder._(const []);
}
