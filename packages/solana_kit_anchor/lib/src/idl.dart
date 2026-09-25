import 'dart:convert';

/// A parsed Anchor IDL type node describing how values are byte-encoded.
sealed class AnchorIdlType {
  const AnchorIdlType();

  /// Parses an IDL 0.30 type node.
  ///
  /// Scalars arrive as plain strings (`"u8"`, `"pubkey"`, …); compound
  /// nodes are maps keyed by `bytes`, `defined`, `vec`, `option`, or
  /// `array`.
  ///
  /// Throws [ArgumentError] on unknown shapes — including generic
  /// instantiations, which this runtime does not monomorphize — so callers
  /// never silently build a wrong codec.
  static AnchorIdlType parse(Object? node) {
    if (node is String) {
      return _parseScalar(node);
    }
    if (node is Map) {
      if (node.containsKey('bytes')) {
        return const AnchorIdlBytes();
      }
      final defined = node['defined'];
      if (defined is Map) {
        if (defined['generics'] != null) {
          throw ArgumentError.value(
            defined['generics'],
            'type.defined.generics',
            'Generic type instantiation is not supported by the runtime coder',
          );
        }
        if (defined['name'] is String) {
          final name = defined['name'] as String;
          return AnchorIdlDefined(typeNameOf(name));
        }
      }
      if (node['vec'] != null) {
        return AnchorIdlVec(parse(node['vec']));
      }
      if (node['option'] != null) {
        final prefixNode = node['prefix'];
        return AnchorIdlOption(
          parse(node['option']),
          prefixNode == null ? 1 : _parsePrefix(prefixNode),
        );
      }
      final array = node['array'];
      if (array is List && array.length == 2) {
        return AnchorIdlArray(parse(array[0]), _parseArrayLength(array[1]));
      }
    }
    throw ArgumentError.value(
      node,
      'type',
      'Unsupported Anchor IDL type node',
    );
  }

  static AnchorIdlType _parseScalar(String scalar) => switch (scalar) {
    'u8' => AnchorIdlPrimitive.u8,
    'u16' => AnchorIdlPrimitive.u16,
    'u32' => AnchorIdlPrimitive.u32,
    'u64' => AnchorIdlPrimitive.u64,
    'u128' => AnchorIdlPrimitive.u128,
    'i8' => AnchorIdlPrimitive.i8,
    'i16' => AnchorIdlPrimitive.i16,
    'i32' => AnchorIdlPrimitive.i32,
    'i64' => AnchorIdlPrimitive.i64,
    'i128' => AnchorIdlPrimitive.i128,
    'f32' => AnchorIdlPrimitive.f32,
    'f64' => AnchorIdlPrimitive.f64,
    'bool' => AnchorIdlPrimitive.bool,
    'string' => AnchorIdlPrimitive.string,
    'pubkey' => AnchorIdlPrimitive.publicKey,
    'bytes' => const AnchorIdlBytes(),
    final _ => throw ArgumentError.value(
      scalar,
      'type',
      'Unknown Anchor IDL scalar type',
    ),
  };

  static int _parsePrefix(Object? prefix) {
    if (prefix is int && (prefix == 1 || prefix == 8)) {
      if (prefix == 8) {
        throw ArgumentError.value(
          prefix,
          'type.option.prefix',
          '8-byte option prefixes are not supported by the runtime coder',
        );
      }
      return prefix;
    }
    throw ArgumentError.value(
      prefix,
      'type.option.prefix',
      'Option prefixes must be 1 or 8 bytes',
    );
  }

  static int _parseArrayLength(Object? length) {
    if (length is int) return length;
    if (length is num) return length.toInt();
    if (length is String) {
      final parsed = int.tryParse(length);
      if (parsed != null) return parsed;
    }
    throw ArgumentError.value(
      length,
      'type.array.length',
      'Array lengths must be integers',
    );
  }
}

/// Strips module path segments from an IDL type name, e.g.
/// `idl::some_module::NamedStruct` becomes `NamedStruct`.
String typeNameOf(String name) {
  final parts = name.split('::');
  return parts.isEmpty ? name : parts.last;
}

/// A scalar type such as `u8` or `pubkey`.
class AnchorIdlPrimitive extends AnchorIdlType {
  /// Creates a primitive with the given scalar name.
  ///
  /// Parsing only ever produces the 15 supported scalars; building one with
  /// an unknown name throws when a codec is built for it.
  const AnchorIdlPrimitive(this.name);

  /// The unsigned 8-bit scalar.
  static const u8 = AnchorIdlPrimitive('u8');

  /// The unsigned 16-bit scalar.
  static const u16 = AnchorIdlPrimitive('u16');

  /// The unsigned 32-bit scalar.
  static const u32 = AnchorIdlPrimitive('u32');

  /// The unsigned 64-bit scalar.
  static const u64 = AnchorIdlPrimitive('u64');

  /// The unsigned 128-bit scalar.
  static const u128 = AnchorIdlPrimitive('u128');

  /// The signed 8-bit scalar.
  static const i8 = AnchorIdlPrimitive('i8');

  /// The signed 16-bit scalar.
  static const i16 = AnchorIdlPrimitive('i16');

  /// The signed 32-bit scalar.
  static const i32 = AnchorIdlPrimitive('i32');

  /// The signed 64-bit scalar.
  static const i64 = AnchorIdlPrimitive('i64');

  /// The signed 128-bit scalar.
  static const i128 = AnchorIdlPrimitive('i128');

  /// The single-precision float scalar.
  static const f32 = AnchorIdlPrimitive('f32');

  /// The double-precision float scalar.
  static const f64 = AnchorIdlPrimitive('f64');

  /// The boolean scalar.
  static const bool = AnchorIdlPrimitive('bool');

  /// The UTF-8 string scalar.
  static const string = AnchorIdlPrimitive('string');

  /// The 32-byte public key scalar.
  static const publicKey = AnchorIdlPrimitive('pubkey');

  /// The scalar name as written in the IDL.
  final String name;

  @override
  String toString() => name;
}

/// A variable-length, unprefixed byte sequence (`bytes`).
class AnchorIdlBytes extends AnchorIdlType {
  /// Creates the bytes type.
  const AnchorIdlBytes();

  @override
  String toString() => 'bytes';
}

/// A reference to a named type defined in the IDL, such as `MyStruct`.
class AnchorIdlDefined extends AnchorIdlType {
  /// Creates a reference to [name].
  const AnchorIdlDefined(this.name);

  /// The type name without module path segments.
  final String name;

  @override
  String toString() => name;
}

/// A `Vec<T>` with a `u32` length prefix.
/// A `Vec<T>` with a `u32` length prefix.
class AnchorIdlVec extends AnchorIdlType {
  /// Creates a vector of [element].
  const AnchorIdlVec(this.element);

  /// The element type.
  final AnchorIdlType element;
}

/// An `Option<T>` with a 1-byte discriminator prefix.
/// An `Option<T>` with a 1-byte discriminator prefix.
class AnchorIdlOption extends AnchorIdlType {
  /// Creates an option over [inner] with a [prefix]-byte tag.
  const AnchorIdlOption(this.inner, this.prefix);

  /// The wrapped type.
  final AnchorIdlType inner;

  /// The discriminator prefix byte length.
  final int prefix;
}

/// A fixed-length array `[T; N]`.
/// A fixed-length array.
class AnchorIdlArray extends AnchorIdlType {
  /// Creates a fixed array of [element] with [length] items.
  const AnchorIdlArray(this.element, this.length);

  /// The element type.
  final AnchorIdlType element;

  /// The fixed element count.
  final int length;
}

/// A named or tuple field within a struct, enum variant, or instruction.
/// A named or tuple field inside a struct, variant, or instruction.
class AnchorIdlField {
  AnchorIdlField._(this.name, this.rawType);

  /// Parses a field node: `{name, type}` for named fields, or a bare type
  /// node for tuple fields.
  factory AnchorIdlField.parse(Object? node, int tupleIndex) {
    if (node is Map && node.containsKey('type')) {
      final mapping = Map<String, Object?>.from(node);
      final rawType = mapping['type'];
      if (rawType == null) {
        throw ArgumentError.value(
          node,
          'field',
          'Anchor IDL named fields must carry a type',
        );
      }
      return AnchorIdlField._(
        (mapping['name'] as String?) ?? 'field$tupleIndex',
        rawType,
      );
    }
    return AnchorIdlField._('field$tupleIndex', node);
  }

  /// The field name, synthesized as `field<index>` for tuple fields.
  final String name;

  /// The raw IDL JSON for the field type.
  final Object? rawType;

  /// The parsed field type.
  ///
  /// Parsing is deferred until first access so documents containing
  /// unsupported shapes (such as generic instantiations) still parse; the
  /// error surfaces only when a codec is actually built for the field.
  late final AnchorIdlType type = AnchorIdlType.parse(rawType);
}

/// A Rust enum variant: unit, named, or tuple.
/// A Rust enum variant.
class AnchorIdlEnumVariant {
  /// Creates a variant.
  const AnchorIdlEnumVariant({required this.name, required this.fields});

  /// Parses a variant node.
  factory AnchorIdlEnumVariant.parse(Object? node) {
    if (node is! Map) {
      throw ArgumentError.value(
        node,
        'variant',
        'Anchor IDL enum variants must be objects',
      );
    }
    final fields = switch (node['fields']) {
      final List<Object?> list =>
        list.indexed
            .map((entry) => AnchorIdlField.parse(entry.$2, entry.$1))
            .toList(growable: false),
      null => const <AnchorIdlField>[],
      final other => <AnchorIdlField>[AnchorIdlField.parse(other, 0)],
    };
    return AnchorIdlEnumVariant(
      name: (node['name'] as String?) ?? 'variant',
      fields: fields,
    );
  }

  /// The variant name.
  final String name;

  /// The variant fields; empty for unit variants.
  final List<AnchorIdlField> fields;
}

/// The definition of a named type in the IDL.
sealed class AnchorIdlTypeDef {
  const AnchorIdlTypeDef();
}

/// A struct with named or tuple fields.
/// A struct definition.
class AnchorIdlStruct extends AnchorIdlTypeDef {
  /// Creates a struct.
  const AnchorIdlStruct({required this.fields});

  /// The fields, in declaration order.
  final List<AnchorIdlField> fields;
}

/// A Rust-style enum with a `u8` variant discriminator.
/// A Rust enum definition.
class AnchorIdlEnum extends AnchorIdlTypeDef {
  /// Creates an enum.
  const AnchorIdlEnum({required this.variants});

  /// The variants, in declaration order.
  final List<AnchorIdlEnumVariant> variants;
}

/// An instruction entry with its discriminator and argument types.
/// An instruction entry from the IDL.
class AnchorIdlInstruction {
  /// Creates an instruction entry.
  const AnchorIdlInstruction({
    required this.name,
    required this.discriminator,
    required this.args,
  });

  /// The instruction name.
  final String name;

  /// The 8-byte discriminator from the IDL, when present.
  final List<int> discriminator;

  /// The instruction arguments, in declaration order.
  final List<AnchorIdlField> args;
}

/// A named entry with an 8-byte discriminator (accounts and events).
/// A named entry with an 8-byte discriminator.
class AnchorIdlAccount {
  /// Creates a named, discriminated entry.
  const AnchorIdlAccount({required this.name, required this.discriminator});

  /// The account name.
  final String name;

  /// The 8-byte discriminator, `sha256("account:<name>")[0..8]`.
  final List<int> discriminator;
}

/// An event entry with an event discriminator
/// (`sha256("event:<name>")[0..8]`).
/// An event entry from the IDL.
class AnchorIdlEvent extends AnchorIdlAccount {
  /// Creates an event entry.
  const AnchorIdlEvent({required super.name, required super.discriminator});
}

/// A program-defined error with code, name, and message.
/// A program-defined error from the IDL.
class AnchorIdlCustomError {
  /// Creates a custom error.
  const AnchorIdlCustomError({
    required this.code,
    required this.name,
    this.msg,
  });

  /// The error code.
  final int code;

  /// The error name.
  final String name;

  /// The error message, if the IDL provides one.
  final String? msg;
}

/// A parsed Anchor IDL document (spec 0.30).
/// A parsed Anchor IDL document.
class AnchorIdlProgram {
  /// Creates an IDL program document.
  const AnchorIdlProgram({
    required this.address,
    required this.name,
    required this.instructions,
    required this.accounts,
    required this.events,
    required this.errors,
    required this.types,
  });

  /// Parses a raw IDL JSON string or a pre-decoded map.
  factory AnchorIdlProgram.parse(Object? raw) {
    final json = switch (raw) {
      final String text => jsonDecode(text) as Map<String, Object?>,
      final Map<String, Object?> rawMap => rawMap,
      final Map<dynamic, dynamic> rawMap => rawMap.cast<String, Object?>(),
      _ => throw ArgumentError.value(
        raw,
        'idl',
        'Expected an IDL JSON string or decoded map',
      ),
    };
    final metadata = json['metadata'];
    final programName = metadata is Map ? metadata['name'] : null;
    return AnchorIdlProgram(
      address: json['address'] as String? ?? '',
      name: programName is String ? programName : '',
      instructions: Map.fromEntries(
        (json['instructions'] as List<Object?>? ?? []).map((node) {
          final map = switch (node) {
            final Map<String, Object?> typed => typed,
            final Map<dynamic, dynamic> typedMap => Map<String, Object?>.from(
              typedMap,
            ),
            _ => throw ArgumentError.value(
              node,
              'instruction',
              'Expected an instruction object',
            ),
          };
          final name = map['name'];
          if (name is! String) {
            throw ArgumentError.value(
              node,
              'instruction.name',
              'Expected a string instruction name',
            );
          }
          return MapEntry(name, _parseInstruction(map));
        }),
      ),
      accounts: Map.fromEntries(
        (json['accounts'] as List<Object?>? ?? [])
            .cast<Map<String, Object?>>()
            .map(
              (node) => MapEntry(
                node['name'] as String? ?? '',
                AnchorIdlEvent(
                  name: node['name'] as String? ?? '',
                  discriminator: _discriminator(node),
                ),
              ),
            ),
      ),
      events: Map.fromEntries(
        (json['events'] as List<Object?>? ?? [])
            .cast<Map<String, Object?>>()
            .map(
              (node) => MapEntry(
                node['name'] as String? ?? '',
                AnchorIdlEvent(
                  name: node['name'] as String? ?? '',
                  discriminator: _discriminator(node),
                ),
              ),
            ),
      ),
      errors: Map.fromEntries(
        (json['errors'] as List<Object?>? ?? [])
            .map(_parseError)
            .map((error) => MapEntry(error.code, error)),
      ),
      types: Map.fromEntries(
        (json['types'] as List<Object?>? ?? []).map(_parseType),
      ),
    );
  }

  /// The program address as written in the IDL, or `''` when absent.
  final String address;

  /// The program name from the IDL metadata.
  final String name;

  /// The instructions keyed by name.
  final Map<String, AnchorIdlInstruction> instructions;

  /// The accounts keyed by name.
  final Map<String, AnchorIdlAccount> accounts;

  /// The events keyed by name.
  final Map<String, AnchorIdlEvent> events;

  /// The program-defined errors keyed by code.
  final Map<int, AnchorIdlCustomError> errors;

  /// The defined types keyed by name.
  final Map<String, AnchorIdlTypeDef> types;
}

List<int> _discriminator(Map<String, Object?> node) =>
    (node['discriminator'] as List<Object?>? ?? const [])
        .cast<num>()
        .map((byte) => byte.toInt())
        .toList(growable: false);

AnchorIdlInstruction _parseInstruction(Object? node) {
  final map = Map<String, Object?>.from(node! as Map);
  return AnchorIdlInstruction(
    name: (map['name'] as String?) ?? '',
    discriminator: _discriminator(map),
    args: _parseFields(map['args']),
  );
}

AnchorIdlCustomError _parseError(Object? node) {
  final map = Map<String, Object?>.from(node! as Map);
  return AnchorIdlCustomError(
    code: ((map['code'] as num?) ?? 0).toInt(),
    name: (map['name'] as String?) ?? '',
    msg: map['msg'] as String?,
  );
}

MapEntry<String, AnchorIdlTypeDef> _parseType(Object? node) {
  final map = Map<String, Object?>.from(node! as Map);
  final name = typeNameOf((map['name'] as String?) ?? '');
  final type = map['type'];
  final definition = switch (type) {
    {'kind': 'struct'} => AnchorIdlStruct(
      fields: _parseFields(type['fields']),
    ),
    {'kind': 'enum'} => AnchorIdlEnum(
      variants: (type['variants'] as List<Object?>? ?? [])
          .map(AnchorIdlEnumVariant.parse)
          .toList(growable: false),
    ),
    final Map<String, Object?> map when map.containsKey('kind') =>
      throw ArgumentError.value(
        map['kind'],
        'type.kind',
        'Unsupported Anchor IDL defined type kind',
      ),
    null => throw ArgumentError.value(node, 'type.type', 'Missing type body'),
    _ => throw ArgumentError.value(
      type,
      'type',
      'Unsupported Anchor IDL defined type',
    ),
  };
  return MapEntry(name, definition);
}

List<AnchorIdlField> _parseFields(Object? rawFields) {
  if (rawFields is! List) return const [];
  return rawFields.indexed
      .map((entry) => AnchorIdlField.parse(entry.$2, entry.$1))
      .toList(growable: false);
}
