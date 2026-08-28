// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

import './seed.dart';

sealed class ExtraAccount {
  const ExtraAccount();
}

final class ExtraAccountPreconfiguredProgram extends ExtraAccount {
  const ExtraAccountPreconfiguredProgram({
    required this.isSigner,
    required this.isWritable,
  });

  final bool isSigner;
  final bool isWritable;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExtraAccountPreconfiguredProgram &&
          isSigner == other.isSigner &&
          isWritable == other.isWritable;

  @override
  int get hashCode => Object.hash(isSigner, isWritable);

  @override
  String toString() =>
      'ExtraAccount.PreconfiguredProgram(isSigner: $isSigner, isWritable: $isWritable)';
}

final class ExtraAccountPreconfiguredCollection extends ExtraAccount {
  const ExtraAccountPreconfiguredCollection({
    required this.isSigner,
    required this.isWritable,
  });

  final bool isSigner;
  final bool isWritable;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExtraAccountPreconfiguredCollection &&
          isSigner == other.isSigner &&
          isWritable == other.isWritable;

  @override
  int get hashCode => Object.hash(isSigner, isWritable);

  @override
  String toString() =>
      'ExtraAccount.PreconfiguredCollection(isSigner: $isSigner, isWritable: $isWritable)';
}

final class ExtraAccountPreconfiguredOwner extends ExtraAccount {
  const ExtraAccountPreconfiguredOwner({
    required this.isSigner,
    required this.isWritable,
  });

  final bool isSigner;
  final bool isWritable;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExtraAccountPreconfiguredOwner &&
          isSigner == other.isSigner &&
          isWritable == other.isWritable;

  @override
  int get hashCode => Object.hash(isSigner, isWritable);

  @override
  String toString() =>
      'ExtraAccount.PreconfiguredOwner(isSigner: $isSigner, isWritable: $isWritable)';
}

final class ExtraAccountPreconfiguredRecipient extends ExtraAccount {
  const ExtraAccountPreconfiguredRecipient({
    required this.isSigner,
    required this.isWritable,
  });

  final bool isSigner;
  final bool isWritable;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExtraAccountPreconfiguredRecipient &&
          isSigner == other.isSigner &&
          isWritable == other.isWritable;

  @override
  int get hashCode => Object.hash(isSigner, isWritable);

  @override
  String toString() =>
      'ExtraAccount.PreconfiguredRecipient(isSigner: $isSigner, isWritable: $isWritable)';
}

final class ExtraAccountPreconfiguredAsset extends ExtraAccount {
  const ExtraAccountPreconfiguredAsset({
    required this.isSigner,
    required this.isWritable,
  });

  final bool isSigner;
  final bool isWritable;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExtraAccountPreconfiguredAsset &&
          isSigner == other.isSigner &&
          isWritable == other.isWritable;

  @override
  int get hashCode => Object.hash(isSigner, isWritable);

  @override
  String toString() =>
      'ExtraAccount.PreconfiguredAsset(isSigner: $isSigner, isWritable: $isWritable)';
}

final class ExtraAccountCustomPda extends ExtraAccount {
  const ExtraAccountCustomPda({
    required this.seeds,
    required this.customProgramId,
    required this.isSigner,
    required this.isWritable,
  });

  final List<Seed> seeds;
  final Address? customProgramId;
  final bool isSigner;
  final bool isWritable;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExtraAccountCustomPda &&
          seeds == other.seeds &&
          customProgramId == other.customProgramId &&
          isSigner == other.isSigner &&
          isWritable == other.isWritable;

  @override
  int get hashCode => Object.hash(seeds, customProgramId, isSigner, isWritable);

  @override
  String toString() =>
      'ExtraAccount.CustomPda(seeds: $seeds, customProgramId: $customProgramId, isSigner: $isSigner, isWritable: $isWritable)';
}

final class ExtraAccountAddress extends ExtraAccount {
  const ExtraAccountAddress({
    required this.address,
    required this.isSigner,
    required this.isWritable,
  });

  final Address address;
  final bool isSigner;
  final bool isWritable;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExtraAccountAddress &&
          address == other.address &&
          isSigner == other.isSigner &&
          isWritable == other.isWritable;

  @override
  int get hashCode => Object.hash(address, isSigner, isWritable);

  @override
  String toString() =>
      'ExtraAccount.Address(address: $address, isSigner: $isSigner, isWritable: $isWritable)';
}

Encoder<ExtraAccount> getExtraAccountEncoder() {
  return transformEncoder<Map<String, Object?>, ExtraAccount>(
    getDiscriminatedUnionEncoder([
      (
        0,
        getStructEncoder([
          ('isSigner', getBooleanEncoder()),
          ('isWritable', getBooleanEncoder()),
        ]),
      ),
      (
        1,
        getStructEncoder([
          ('isSigner', getBooleanEncoder()),
          ('isWritable', getBooleanEncoder()),
        ]),
      ),
      (
        2,
        getStructEncoder([
          ('isSigner', getBooleanEncoder()),
          ('isWritable', getBooleanEncoder()),
        ]),
      ),
      (
        3,
        getStructEncoder([
          ('isSigner', getBooleanEncoder()),
          ('isWritable', getBooleanEncoder()),
        ]),
      ),
      (
        4,
        getStructEncoder([
          ('isSigner', getBooleanEncoder()),
          ('isWritable', getBooleanEncoder()),
        ]),
      ),
      (
        5,
        getStructEncoder([
          (
            'seeds',
            getArrayEncoder<Seed>(
              transformEncoder(getSeedEncoder(), (Seed value) => value),
            ),
          ),
          ('customProgramId', getNullableEncoder<Address>(getAddressEncoder())),
          ('isSigner', getBooleanEncoder()),
          ('isWritable', getBooleanEncoder()),
        ]),
      ),
      (
        6,
        getStructEncoder([
          ('address', getAddressEncoder()),
          ('isSigner', getBooleanEncoder()),
          ('isWritable', getBooleanEncoder()),
        ]),
      ),
    ], size: getU8Encoder()),
    (ExtraAccount value) => switch (value) {
      ExtraAccountPreconfiguredProgram(
        isSigner: final isSigner,
        isWritable: final isWritable,
      ) =>
        <String, Object?>{
          '__kind': 0,
          'isSigner': isSigner,
          'isWritable': isWritable,
        },
      ExtraAccountPreconfiguredCollection(
        isSigner: final isSigner,
        isWritable: final isWritable,
      ) =>
        <String, Object?>{
          '__kind': 1,
          'isSigner': isSigner,
          'isWritable': isWritable,
        },
      ExtraAccountPreconfiguredOwner(
        isSigner: final isSigner,
        isWritable: final isWritable,
      ) =>
        <String, Object?>{
          '__kind': 2,
          'isSigner': isSigner,
          'isWritable': isWritable,
        },
      ExtraAccountPreconfiguredRecipient(
        isSigner: final isSigner,
        isWritable: final isWritable,
      ) =>
        <String, Object?>{
          '__kind': 3,
          'isSigner': isSigner,
          'isWritable': isWritable,
        },
      ExtraAccountPreconfiguredAsset(
        isSigner: final isSigner,
        isWritable: final isWritable,
      ) =>
        <String, Object?>{
          '__kind': 4,
          'isSigner': isSigner,
          'isWritable': isWritable,
        },
      ExtraAccountCustomPda(
        seeds: final seeds,
        customProgramId: final customProgramId,
        isSigner: final isSigner,
        isWritable: final isWritable,
      ) =>
        <String, Object?>{
          '__kind': 5,
          'seeds': seeds,
          'customProgramId': customProgramId,
          'isSigner': isSigner,
          'isWritable': isWritable,
        },
      ExtraAccountAddress(
        address: final address,
        isSigner: final isSigner,
        isWritable: final isWritable,
      ) =>
        <String, Object?>{
          '__kind': 6,
          'address': address,
          'isSigner': isSigner,
          'isWritable': isWritable,
        },
    },
  );
}

Decoder<ExtraAccount> getExtraAccountDecoder() {
  return transformDecoder<Map<String, Object?>, ExtraAccount>(
    getDiscriminatedUnionDecoder([
      (
        0,
        transformDecoder<Map<String, Object?>, Map<String, Object?>>(
          getStructDecoder([
            ('isSigner', getBooleanDecoder()),
            ('isWritable', getBooleanDecoder()),
          ]),
          (Map<String, Object?> map, Uint8List bytes, int offset) => map,
        ),
      ),
      (
        1,
        transformDecoder<Map<String, Object?>, Map<String, Object?>>(
          getStructDecoder([
            ('isSigner', getBooleanDecoder()),
            ('isWritable', getBooleanDecoder()),
          ]),
          (Map<String, Object?> map, Uint8List bytes, int offset) => map,
        ),
      ),
      (
        2,
        transformDecoder<Map<String, Object?>, Map<String, Object?>>(
          getStructDecoder([
            ('isSigner', getBooleanDecoder()),
            ('isWritable', getBooleanDecoder()),
          ]),
          (Map<String, Object?> map, Uint8List bytes, int offset) => map,
        ),
      ),
      (
        3,
        transformDecoder<Map<String, Object?>, Map<String, Object?>>(
          getStructDecoder([
            ('isSigner', getBooleanDecoder()),
            ('isWritable', getBooleanDecoder()),
          ]),
          (Map<String, Object?> map, Uint8List bytes, int offset) => map,
        ),
      ),
      (
        4,
        transformDecoder<Map<String, Object?>, Map<String, Object?>>(
          getStructDecoder([
            ('isSigner', getBooleanDecoder()),
            ('isWritable', getBooleanDecoder()),
          ]),
          (Map<String, Object?> map, Uint8List bytes, int offset) => map,
        ),
      ),
      (
        5,
        transformDecoder<Map<String, Object?>, Map<String, Object?>>(
          getStructDecoder([
            ('seeds', getArrayDecoder(getSeedDecoder())),
            (
              'customProgramId',
              getNullableDecoder<Address>(getAddressDecoder()),
            ),
            ('isSigner', getBooleanDecoder()),
            ('isWritable', getBooleanDecoder()),
          ]),
          (Map<String, Object?> map, Uint8List bytes, int offset) => map,
        ),
      ),
      (
        6,
        transformDecoder<Map<String, Object?>, Map<String, Object?>>(
          getStructDecoder([
            ('address', getAddressDecoder()),
            ('isSigner', getBooleanDecoder()),
            ('isWritable', getBooleanDecoder()),
          ]),
          (Map<String, Object?> map, Uint8List bytes, int offset) => map,
        ),
      ),
    ], size: getU8Decoder()),
    (Map<String, Object?> map, Uint8List bytes, int offset) {
      switch (map['__kind']) {
        case 0:
          return ExtraAccountPreconfiguredProgram(
            isSigner: map['isSigner']! as bool,
            isWritable: map['isWritable']! as bool,
          );
        case 1:
          return ExtraAccountPreconfiguredCollection(
            isSigner: map['isSigner']! as bool,
            isWritable: map['isWritable']! as bool,
          );
        case 2:
          return ExtraAccountPreconfiguredOwner(
            isSigner: map['isSigner']! as bool,
            isWritable: map['isWritable']! as bool,
          );
        case 3:
          return ExtraAccountPreconfiguredRecipient(
            isSigner: map['isSigner']! as bool,
            isWritable: map['isWritable']! as bool,
          );
        case 4:
          return ExtraAccountPreconfiguredAsset(
            isSigner: map['isSigner']! as bool,
            isWritable: map['isWritable']! as bool,
          );
        case 5:
          return ExtraAccountCustomPda(
            seeds: map['seeds']! as List<Seed>,
            customProgramId: map['customProgramId'] as Address?,
            isSigner: map['isSigner']! as bool,
            isWritable: map['isWritable']! as bool,
          );
        case 6:
          return ExtraAccountAddress(
            address: map['address']! as Address,
            isSigner: map['isSigner']! as bool,
            isWritable: map['isWritable']! as bool,
          );
      }
      throw StateError(
        'Unsupported ExtraAccount discriminator: ${map['__kind']}',
      );
    },
  );
}

Codec<ExtraAccount, ExtraAccount> getExtraAccountCodec() {
  return combineCodec(getExtraAccountEncoder(), getExtraAccountDecoder());
}
