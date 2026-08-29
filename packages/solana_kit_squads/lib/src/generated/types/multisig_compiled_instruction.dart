// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

@immutable
class MultisigCompiledInstruction {
  const MultisigCompiledInstruction({
    required this.programIdIndex,
    required this.accountIndexes,
    required this.data,
  });

  final int programIdIndex;
  final Uint8List accountIndexes;
  final Uint8List data;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MultisigCompiledInstruction &&
          runtimeType == other.runtimeType &&
          programIdIndex == other.programIdIndex &&
          _listEquals(accountIndexes, other.accountIndexes) &&
          _listEquals(data, other.data);

  @override
  int get hashCode => Object.hash(
    programIdIndex,
    _listHashCode(accountIndexes),
    _listHashCode(data),
  );

  @override
  String toString() =>
      'MultisigCompiledInstruction(programIdIndex: $programIdIndex, accountIndexes: $accountIndexes, data: $data)';
}

bool _listEquals<T>(List<T>? a, List<T>? b) {
  if (identical(a, b)) return true;
  if (a == null || b == null) return a == b;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    final left = a[i];
    final right = b[i];
    if (left is List<Object?> && right is List<Object?>) {
      if (!_listEquals(left, right)) return false;
    } else if (left != right) {
      return false;
    }
  }
  return true;
}

Object? _deepHash(Object? value) {
  if (value is List<Object?>) {
    return Object.hashAll(value.map(_deepHash));
  }
  return value;
}

int _listHashCode<T>(List<T>? a) {
  if (a == null) return 0;
  return Object.hashAll(a.map(_deepHash));
}

Encoder<MultisigCompiledInstruction> getMultisigCompiledInstructionEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('programIdIndex', getU8Encoder()),
    (
      'accountIndexes',
      addEncoderSizePrefix(getBytesEncoder(), getU32Encoder()),
    ),
    ('data', addEncoderSizePrefix(getBytesEncoder(), getU32Encoder())),
  ]);

  return transformEncoder(
    structEncoder,
    (MultisigCompiledInstruction value) => <String, Object?>{
      'programIdIndex': value.programIdIndex,
      'accountIndexes': value.accountIndexes,
      'data': value.data,
    },
  );
}

Decoder<MultisigCompiledInstruction> getMultisigCompiledInstructionDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('programIdIndex', getU8Decoder()),
    (
      'accountIndexes',
      addDecoderSizePrefix(getBytesDecoder(), getU32Decoder()),
    ),
    ('data', addDecoderSizePrefix(getBytesDecoder(), getU32Decoder())),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        MultisigCompiledInstruction(
          programIdIndex: map['programIdIndex']! as int,
          accountIndexes: map['accountIndexes']! as Uint8List,
          data: map['data']! as Uint8List,
        ),
  );
}

Codec<MultisigCompiledInstruction, MultisigCompiledInstruction>
getMultisigCompiledInstructionCodec() {
  return combineCodec(
    getMultisigCompiledInstructionEncoder(),
    getMultisigCompiledInstructionDecoder(),
  );
}
