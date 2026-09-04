import 'dart:convert';
import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_anchor/src/idl.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';

/// The JSON-shaped value model used by the dynamic Anchor coder.
///
/// Structs and instruction arguments map to `Map<String, Object?>`. Rust
/// enums map to a map with a `'__kind'` entry holding the variant name and
/// the variant's fields beside it, mirroring the runtime codecs in
/// `solana_kit_codecs_data_structures`.
typedef AnchorValue = Object?;

/// A decoded event found in a transaction log sequence.
class AnchorDecodedEvent {
  /// Creates a decoded event.
  const AnchorDecodedEvent({required this.name, required this.data});

  /// The event name.
  final String name;

  /// The decoded event fields.
  final Map<String, AnchorValue> data;
}

/// Thrown when account or event bytes do not start with the expected
/// Anchor discriminator.
class AnchorDiscriminatorMismatch implements Exception {
  /// Creates a discriminator mismatch error.
  const AnchorDiscriminatorMismatch({
    required this.expected,
    required this.found,
  });

  /// The expected discriminator bytes.
  final List<int> expected;

  /// The discriminator bytes found in the data.
  final List<int> found;

  @override
  String toString() =>
      'AnchorDiscriminatorMismatch(expected: $expected, found: $found)';
}

/// Builds dynamic codecs from a parsed Anchor IDL.
///
/// The coder exposes three capabilities:
///
/// - [encodeInstructionData] / [decodeInstructionData]: round-trip
///   instruction arguments
/// - [encodeAccount] / [decodeAccount]: round-trip account data
/// - [decodeEventLogs]: pull typed events out of program logs
class AnchorCoder {
  /// Builds a coder for the given IDL.
  AnchorCoder(this.idl);

  /// The parsed IDL backing this coder.
  final AnchorIdlProgram idl;

  final Map<String, (Encoder<Object?>, Decoder<Object?>)> _typeCache = {};

  /// Encodes instruction arguments for the instruction named [name].
  ///
  /// The IDL instruction's explicit discriminator is used verbatim.
  Uint8List encodeInstructionData(String name, Map<String, AnchorValue> args) {
    final instruction = _instruction(name);
    final buffer = BytesBuilder()
      ..add(_discriminatorBytes(instruction.discriminator));
    for (final field in instruction.args) {
      final (encoder, _) = codecFor(field.type);
      _appendEncoded(
        buffer,
        encoder,
        _fieldValue(field, name, args),
        field.name,
      );
    }
    return buffer.toBytes();
  }

  /// Decodes Anchor instruction data for the instruction named [name].
  ///
  /// The discriminator is validated against the IDL entry; the decoded
  /// arguments are returned keyed by argument name.
  Map<String, AnchorValue> decodeInstructionData(
    String name,
    List<int> data,
  ) {
    final instruction = _instruction(name);
    final stripped = _stripDiscriminator(instruction.discriminator, data);
    final (_, decoder) = _structCodec(instruction.args);
    final (decoded, _) = decoder.read(stripped, 0);
    return Map<String, AnchorValue>.from(decoded! as Map);
  }

  /// Decodes account data for the account named [name].
  ///
  /// The account's discriminator is validated and stripped; the decoded
  /// fields are returned in the result's `data` entry alongside the raw
  /// discriminator bytes.
  ({List<int> discriminator, Map<String, AnchorValue> data}) decodeAccount(
    String name,
    List<int> data,
  ) {
    final account = _account(name);
    final stripped = _stripDiscriminator(account.discriminator, data);
    final definition = _definitionFor(name);
    final (_, decoder) = _codecForDefinition(definition);
    final (decoded, _) = decoder.read(stripped, 0);
    return (
      discriminator: account.discriminator,
      data: Map<String, AnchorValue>.from(decoded! as Map),
    );
  }

  /// Encodes account data for the account named [name], prefixing the
  /// account discriminator.
  Uint8List encodeAccount(String name, Map<String, AnchorValue> values) {
    final account = _account(name);
    final buffer = BytesBuilder()
      ..add(_discriminatorBytes(account.discriminator));
    final (encoder, _) = _codecForDefinition(_definitionFor(name));
    _appendEncoded(
      buffer,
      encoder,
      Map<String, AnchorValue>.from(values),
      name,
    );
    return buffer.toBytes();
  }

  /// Extracts typed events from a program log sequence.
  ///
  /// Anchor `emit!` logs arrive as `Program data: <base64>` lines whose
  /// payload is `eventDiscriminator + fields`. Lines are matched against the
  /// IDL events; unrecognized data lines are skipped. Only events emitted
  /// while the IDL program is executing are returned, including calls to it
  /// through CPI. Pass the complete transaction logs so invocation provenance
  /// can be checked, and check the transaction result before acting on events.
  List<AnchorDecodedEvent> decodeEventLogs(List<String> logs) {
    final events = <AnchorDecodedEvent>[];
    final programs = <String>[];
    final invocationPattern = RegExp(
      r'^Program ([1-9A-HJ-NP-Za-km-z]+) invoke \[(\d+)\]$',
    );
    final completionPattern = RegExp(
      r'^Program ([1-9A-HJ-NP-Za-km-z]+) (?:success|failed: .*)$',
    );

    for (final log in logs) {
      final invocation = invocationPattern.firstMatch(log);

      if (invocation != null) {
        final depth = int.tryParse(invocation.group(2)!);

        if (depth == 1) programs.clear();

        // Incomplete or inconsistent logs cannot establish event provenance.
        if (depth != programs.length + 1) {
          programs.clear();
          continue;
        }

        programs.add(invocation.group(1)!);
        continue;
      }

      final completion = completionPattern.firstMatch(log);

      if (completion != null) {
        if (programs.isNotEmpty && programs.last == completion.group(1)) {
          programs.removeLast();
        } else {
          programs.clear();
        }
        continue;
      }

      if (programs.isEmpty ||
          programs.last != idl.address ||
          !log.startsWith('Program data: ')) {
        continue;
      }

      final payload = base64Decode(log.substring('Program data: '.length));
      for (final entry in idl.events.entries) {
        final discriminator = entry.value.discriminator;
        if (!startsWithDiscriminator(payload, discriminator)) {
          continue;
        }
        final stripped = _stripDiscriminator(discriminator, payload);
        final definition = _definitionFor(entry.key);
        final (_, decoder) = _codecForDefinition(definition);
        final (decoded, _) = decoder.read(stripped, 0);
        events.add(
          AnchorDecodedEvent(
            name: entry.key,
            data: Map<String, AnchorValue>.from(decoded! as Map)
              ..removeWhere((key, _) => key == '__kind'),
          ),
        );
        break;
      }
    }
    return events;
  }

  AnchorIdlInstruction _instruction(String name) {
    final instruction = idl.instructions[name];
    if (instruction == null) {
      throw ArgumentError.value(name, 'name', 'Unknown Anchor IDL instruction');
    }
    return instruction;
  }

  AnchorIdlAccount _account(String name) {
    final account = idl.accounts[name];
    if (account == null) {
      throw ArgumentError.value(name, 'name', 'Unknown Anchor IDL account');
    }
    return account;
  }

  AnchorIdlTypeDef _definitionFor(String name) {
    final definition = idl.types[name];
    if (definition == null) {
      throw ArgumentError.value(
        name,
        'name',
        'Defined type not found in the IDL',
      );
    }
    return definition;
  }

  AnchorValue _fieldValue(
    AnchorIdlField field,
    String instructionName,
    Map<String, AnchorValue> args,
  ) {
    if (args.containsKey(field.name)) {
      return args[field.name];
    }
    throw ArgumentError.value(
      args.keys,
      instructionName,
      'Missing argument "${field.name}" for instruction "$instructionName"',
    );
  }

  void _appendEncoded(
    BytesBuilder buffer,
    Encoder<Object?> encoder,
    AnchorValue value,
    String context,
  ) {
    buffer.add(encoder.encode(value));
  }

  (Encoder<Object?>, Decoder<Object?>) _codecForDefinition(
    AnchorIdlTypeDef definition,
  ) => switch (definition) {
    final AnchorIdlStruct struct => _structCodec(struct.fields),
    final AnchorIdlEnum enumDef => _enumCodec(enumDef),
  };

  /// Builds the runtime codec pair for an [AnchorIdlType].
  ///
  /// Exposed for advanced use cases that compose Anchor codecs outside the
  /// fixed account/instruction/event flows.
  (Encoder<Object?>, Decoder<Object?>) codecFor(AnchorIdlType type) {
    final cacheKey = _typeCacheKey(type);
    final cached = _typeCache[cacheKey];
    if (cached != null) return cached;

    final (encoder, decoder) = switch (type) {
      final AnchorIdlPrimitive primitive => _primitiveCodec(primitive.name),
      AnchorIdlBytes() => (
        // Anchor `bytes` arguments are u32-length-prefixed byte strings.
        addEncoderSizePrefix(
          transformEncoder<Uint8List, List<int>>(
            getBytesEncoder(),
            Uint8List.fromList,
          ),
          getU32Encoder(),
        ),
        addDecoderSizePrefix(
          transformDecoder<Uint8List, List<int>>(
            getBytesDecoder(),
            (bytes, _, _) => bytes,
          ),
          getU32Decoder(),
        ),
      ),
      final AnchorIdlDefined defined => _codecForDefinition(
        _definitionFor(defined.name),
      ),
      final AnchorIdlVec vec => (
        getArrayEncoder<Object?>(codecFor(vec.element).$1),
        getArrayDecoder<Object?>(codecFor(vec.element).$2),
      ),
      final AnchorIdlOption option => (
        getNullableEncoder<Object?>(codecFor(option.inner).$1),
        getNullableDecoder<Object?>(codecFor(option.inner).$2),
      ),
      final AnchorIdlArray array => (
        getArrayEncoder<Object?>(
          codecFor(array.element).$1,
          size: FixedArraySize(array.length),
        ),
        getArrayDecoder<Object?>(
          codecFor(array.element).$2,
          size: FixedArraySize(array.length),
        ),
      ),
    };
    final pair = (encoder, decoder);
    _typeCache[cacheKey] = pair;
    return pair;
  }

  String _typeCacheKey(AnchorIdlType type) => switch (type) {
    final AnchorIdlPrimitive primitive => 'primitive:${primitive.name}',
    AnchorIdlBytes() => 'bytes',
    final AnchorIdlDefined defined => 'defined:${defined.name}',
    final AnchorIdlVec vec => 'vec:${_typeCacheKey(vec.element)}',
    final AnchorIdlOption option => 'option:${_typeCacheKey(option.inner)}',
    final AnchorIdlArray array =>
      'array:${_typeCacheKey(array.element)}:${array.length}',
  };

  (Encoder<Object?>, Decoder<Object?>) _primitiveCodec(String name) =>
      switch (name) {
        'u8' => (getU8Encoder(), getU8Decoder()),
        'u16' => (getU16Encoder(), getU16Decoder()),
        'u32' => (getU32Encoder(), getU32Decoder()),
        'u64' => (getU64Encoder(), getU64Decoder()),
        'u128' => (getU128Encoder(), getU128Decoder()),
        'i8' => (getI8Encoder(), getI8Decoder()),
        'i16' => (getI16Encoder(), getI16Decoder()),
        'i32' => (getI32Encoder(), getI32Decoder()),
        'i64' => (getI64Encoder(), getI64Decoder()),
        'i128' => (getI128Encoder(), getI128Decoder()),
        'f32' => (getF32Encoder(), getF32Decoder()),
        'f64' => (getF64Encoder(), getF64Decoder()),
        'bool' => (getBooleanEncoder(), getBooleanDecoder()),
        'string' => (
          addEncoderSizePrefix(getUtf8Encoder(), getU32Encoder()),
          addDecoderSizePrefix(getUtf8Decoder(), getU32Decoder()),
        ),
        'pubkey' => (getAddressEncoder(), getAddressDecoder()),
        final other => throw ArgumentError.value(
          other,
          'type',
          'Unsupported Anchor IDL scalar type',
        ),
      };

  (Encoder<Object?>, Decoder<Object?>) _structCodec(
    List<AnchorIdlField> fields,
  ) {
    final entries = fields
        .map(
          (field) => (field.name, codecFor(field.type).$1),
        )
        .toList(growable: false);
    final decoderEntries = fields
        .map(
          (field) => (field.name, codecFor(field.type).$2),
        )
        .toList(growable: false);
    return (
      getStructEncoder(entries),
      getStructDecoder(decoderEntries),
    );
  }

  (Encoder<Object?>, Decoder<Object?>) _enumCodec(AnchorIdlEnum enumDef) {
    final encoderVariants = enumDef.variants
        .map(
          (variant) => (
            variant.name as Object?,
            _structCodec(variant.fields).$1,
          ),
        )
        .toList(growable: false);
    final decoderVariants = enumDef.variants
        .map(
          (variant) => (
            variant.name as Object?,
            _structCodec(variant.fields).$2,
          ),
        )
        .toList(growable: false);
    return (
      getDiscriminatedUnionEncoder(encoderVariants),
      getDiscriminatedUnionDecoder(decoderVariants),
    );
  }
}

Uint8List _discriminatorBytes(List<int> discriminator) =>
    Uint8List.fromList(discriminator);

/// Validates [data] against [discriminator] and returns the bytes after it.
Uint8List _stripDiscriminator(List<int> discriminator, List<int> data) {
  final bytes = Uint8List.fromList(data);
  for (var i = 0; i < discriminator.length; i++) {
    if (bytes.length <= i || bytes[i] != discriminator[i]) {
      throw AnchorDiscriminatorMismatch(
        expected: List.of(discriminator),
        found: List.of(bytes.take(discriminator.length)),
      );
    }
  }
  return Uint8List.sublistView(bytes, discriminator.length);
}

/// Returns true when [data] starts with [discriminator].
bool startsWithDiscriminator(List<int> data, List<int> discriminator) {
  if (data.length < discriminator.length) return false;
  for (var i = 0; i < discriminator.length; i++) {
    if (data[i] != discriminator[i]) return false;
  }
  return true;
}
