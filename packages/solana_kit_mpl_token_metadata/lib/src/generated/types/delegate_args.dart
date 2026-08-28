// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

import './authorization_data.dart';

sealed class DelegateArgs {
  const DelegateArgs();
}

final class DelegateArgsCollectionV1 extends DelegateArgs {
  const DelegateArgsCollectionV1({
    required this.authorizationData,
  });

  final AuthorizationData? authorizationData;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DelegateArgsCollectionV1 &&
          authorizationData == other.authorizationData;

  @override
  int get hashCode => authorizationData.hashCode;

  @override
  String toString() =>
      'DelegateArgs.CollectionV1(authorizationData: $authorizationData)';
}

final class DelegateArgsSaleV1 extends DelegateArgs {
  const DelegateArgsSaleV1({
    required this.amount,
    required this.authorizationData,
  });

  final BigInt amount;
  final AuthorizationData? authorizationData;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DelegateArgsSaleV1 &&
          amount == other.amount &&
          authorizationData == other.authorizationData;

  @override
  int get hashCode => Object.hash(amount, authorizationData);

  @override
  String toString() =>
      'DelegateArgs.SaleV1(amount: $amount, authorizationData: $authorizationData)';
}

final class DelegateArgsTransferV1 extends DelegateArgs {
  const DelegateArgsTransferV1({
    required this.amount,
    required this.authorizationData,
  });

  final BigInt amount;
  final AuthorizationData? authorizationData;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DelegateArgsTransferV1 &&
          amount == other.amount &&
          authorizationData == other.authorizationData;

  @override
  int get hashCode => Object.hash(amount, authorizationData);

  @override
  String toString() =>
      'DelegateArgs.TransferV1(amount: $amount, authorizationData: $authorizationData)';
}

final class DelegateArgsDataV1 extends DelegateArgs {
  const DelegateArgsDataV1({
    required this.authorizationData,
  });

  final AuthorizationData? authorizationData;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DelegateArgsDataV1 &&
          authorizationData == other.authorizationData;

  @override
  int get hashCode => authorizationData.hashCode;

  @override
  String toString() =>
      'DelegateArgs.DataV1(authorizationData: $authorizationData)';
}

final class DelegateArgsUtilityV1 extends DelegateArgs {
  const DelegateArgsUtilityV1({
    required this.amount,
    required this.authorizationData,
  });

  final BigInt amount;
  final AuthorizationData? authorizationData;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DelegateArgsUtilityV1 &&
          amount == other.amount &&
          authorizationData == other.authorizationData;

  @override
  int get hashCode => Object.hash(amount, authorizationData);

  @override
  String toString() =>
      'DelegateArgs.UtilityV1(amount: $amount, authorizationData: $authorizationData)';
}

final class DelegateArgsStakingV1 extends DelegateArgs {
  const DelegateArgsStakingV1({
    required this.amount,
    required this.authorizationData,
  });

  final BigInt amount;
  final AuthorizationData? authorizationData;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DelegateArgsStakingV1 &&
          amount == other.amount &&
          authorizationData == other.authorizationData;

  @override
  int get hashCode => Object.hash(amount, authorizationData);

  @override
  String toString() =>
      'DelegateArgs.StakingV1(amount: $amount, authorizationData: $authorizationData)';
}

final class DelegateArgsStandardV1 extends DelegateArgs {
  const DelegateArgsStandardV1({
    required this.amount,
  });

  final BigInt amount;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DelegateArgsStandardV1 && amount == other.amount;

  @override
  int get hashCode => amount.hashCode;

  @override
  String toString() => 'DelegateArgs.StandardV1(amount: $amount)';
}

final class DelegateArgsLockedTransferV1 extends DelegateArgs {
  const DelegateArgsLockedTransferV1({
    required this.amount,
    required this.lockedAddress,
    required this.authorizationData,
  });

  final BigInt amount;
  final Address lockedAddress;
  final AuthorizationData? authorizationData;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DelegateArgsLockedTransferV1 &&
          amount == other.amount &&
          lockedAddress == other.lockedAddress &&
          authorizationData == other.authorizationData;

  @override
  int get hashCode => Object.hash(amount, lockedAddress, authorizationData);

  @override
  String toString() =>
      'DelegateArgs.LockedTransferV1(amount: $amount, lockedAddress: $lockedAddress, authorizationData: $authorizationData)';
}

final class DelegateArgsProgrammableConfigV1 extends DelegateArgs {
  const DelegateArgsProgrammableConfigV1({
    required this.authorizationData,
  });

  final AuthorizationData? authorizationData;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DelegateArgsProgrammableConfigV1 &&
          authorizationData == other.authorizationData;

  @override
  int get hashCode => authorizationData.hashCode;

  @override
  String toString() =>
      'DelegateArgs.ProgrammableConfigV1(authorizationData: $authorizationData)';
}

final class DelegateArgsAuthorityItemV1 extends DelegateArgs {
  const DelegateArgsAuthorityItemV1({
    required this.authorizationData,
  });

  final AuthorizationData? authorizationData;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DelegateArgsAuthorityItemV1 &&
          authorizationData == other.authorizationData;

  @override
  int get hashCode => authorizationData.hashCode;

  @override
  String toString() =>
      'DelegateArgs.AuthorityItemV1(authorizationData: $authorizationData)';
}

final class DelegateArgsDataItemV1 extends DelegateArgs {
  const DelegateArgsDataItemV1({
    required this.authorizationData,
  });

  final AuthorizationData? authorizationData;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DelegateArgsDataItemV1 &&
          authorizationData == other.authorizationData;

  @override
  int get hashCode => authorizationData.hashCode;

  @override
  String toString() =>
      'DelegateArgs.DataItemV1(authorizationData: $authorizationData)';
}

final class DelegateArgsCollectionItemV1 extends DelegateArgs {
  const DelegateArgsCollectionItemV1({
    required this.authorizationData,
  });

  final AuthorizationData? authorizationData;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DelegateArgsCollectionItemV1 &&
          authorizationData == other.authorizationData;

  @override
  int get hashCode => authorizationData.hashCode;

  @override
  String toString() =>
      'DelegateArgs.CollectionItemV1(authorizationData: $authorizationData)';
}

final class DelegateArgsProgrammableConfigItemV1 extends DelegateArgs {
  const DelegateArgsProgrammableConfigItemV1({
    required this.authorizationData,
  });

  final AuthorizationData? authorizationData;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DelegateArgsProgrammableConfigItemV1 &&
          authorizationData == other.authorizationData;

  @override
  int get hashCode => authorizationData.hashCode;

  @override
  String toString() =>
      'DelegateArgs.ProgrammableConfigItemV1(authorizationData: $authorizationData)';
}

final class DelegateArgsPrintDelegateV1 extends DelegateArgs {
  const DelegateArgsPrintDelegateV1({
    required this.authorizationData,
  });

  final AuthorizationData? authorizationData;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DelegateArgsPrintDelegateV1 &&
          authorizationData == other.authorizationData;

  @override
  int get hashCode => authorizationData.hashCode;

  @override
  String toString() =>
      'DelegateArgs.PrintDelegateV1(authorizationData: $authorizationData)';
}

Encoder<DelegateArgs> getDelegateArgsEncoder() {
  return transformEncoder<Map<String, Object?>, DelegateArgs>(
    getDiscriminatedUnionEncoder([
      (
        0,
        getStructEncoder([
          (
            'authorizationData',
            getNullableEncoder<AuthorizationData>(
              getAuthorizationDataEncoder(),
            ),
          ),
        ]),
      ),
      (
        1,
        getStructEncoder([
          ('amount', getU64Encoder()),
          (
            'authorizationData',
            getNullableEncoder<AuthorizationData>(
              getAuthorizationDataEncoder(),
            ),
          ),
        ]),
      ),
      (
        2,
        getStructEncoder([
          ('amount', getU64Encoder()),
          (
            'authorizationData',
            getNullableEncoder<AuthorizationData>(
              getAuthorizationDataEncoder(),
            ),
          ),
        ]),
      ),
      (
        3,
        getStructEncoder([
          (
            'authorizationData',
            getNullableEncoder<AuthorizationData>(
              getAuthorizationDataEncoder(),
            ),
          ),
        ]),
      ),
      (
        4,
        getStructEncoder([
          ('amount', getU64Encoder()),
          (
            'authorizationData',
            getNullableEncoder<AuthorizationData>(
              getAuthorizationDataEncoder(),
            ),
          ),
        ]),
      ),
      (
        5,
        getStructEncoder([
          ('amount', getU64Encoder()),
          (
            'authorizationData',
            getNullableEncoder<AuthorizationData>(
              getAuthorizationDataEncoder(),
            ),
          ),
        ]),
      ),
      (6, getStructEncoder([('amount', getU64Encoder())])),
      (
        7,
        getStructEncoder([
          ('amount', getU64Encoder()),
          ('lockedAddress', getAddressEncoder()),
          (
            'authorizationData',
            getNullableEncoder<AuthorizationData>(
              getAuthorizationDataEncoder(),
            ),
          ),
        ]),
      ),
      (
        8,
        getStructEncoder([
          (
            'authorizationData',
            getNullableEncoder<AuthorizationData>(
              getAuthorizationDataEncoder(),
            ),
          ),
        ]),
      ),
      (
        9,
        getStructEncoder([
          (
            'authorizationData',
            getNullableEncoder<AuthorizationData>(
              getAuthorizationDataEncoder(),
            ),
          ),
        ]),
      ),
      (
        10,
        getStructEncoder([
          (
            'authorizationData',
            getNullableEncoder<AuthorizationData>(
              getAuthorizationDataEncoder(),
            ),
          ),
        ]),
      ),
      (
        11,
        getStructEncoder([
          (
            'authorizationData',
            getNullableEncoder<AuthorizationData>(
              getAuthorizationDataEncoder(),
            ),
          ),
        ]),
      ),
      (
        12,
        getStructEncoder([
          (
            'authorizationData',
            getNullableEncoder<AuthorizationData>(
              getAuthorizationDataEncoder(),
            ),
          ),
        ]),
      ),
      (
        13,
        getStructEncoder([
          (
            'authorizationData',
            getNullableEncoder<AuthorizationData>(
              getAuthorizationDataEncoder(),
            ),
          ),
        ]),
      ),
    ], size: getU8Encoder()),
    (DelegateArgs value) => switch (value) {
      DelegateArgsCollectionV1(authorizationData: final authorizationData) =>
        <String, Object?>{'__kind': 0, 'authorizationData': authorizationData},
      DelegateArgsSaleV1(
        amount: final amount,
        authorizationData: final authorizationData,
      ) =>
        <String, Object?>{
          '__kind': 1,
          'amount': amount,
          'authorizationData': authorizationData,
        },
      DelegateArgsTransferV1(
        amount: final amount,
        authorizationData: final authorizationData,
      ) =>
        <String, Object?>{
          '__kind': 2,
          'amount': amount,
          'authorizationData': authorizationData,
        },
      DelegateArgsDataV1(authorizationData: final authorizationData) =>
        <String, Object?>{'__kind': 3, 'authorizationData': authorizationData},
      DelegateArgsUtilityV1(
        amount: final amount,
        authorizationData: final authorizationData,
      ) =>
        <String, Object?>{
          '__kind': 4,
          'amount': amount,
          'authorizationData': authorizationData,
        },
      DelegateArgsStakingV1(
        amount: final amount,
        authorizationData: final authorizationData,
      ) =>
        <String, Object?>{
          '__kind': 5,
          'amount': amount,
          'authorizationData': authorizationData,
        },
      DelegateArgsStandardV1(amount: final amount) => <String, Object?>{
        '__kind': 6,
        'amount': amount,
      },
      DelegateArgsLockedTransferV1(
        amount: final amount,
        lockedAddress: final lockedAddress,
        authorizationData: final authorizationData,
      ) =>
        <String, Object?>{
          '__kind': 7,
          'amount': amount,
          'lockedAddress': lockedAddress,
          'authorizationData': authorizationData,
        },
      DelegateArgsProgrammableConfigV1(
        authorizationData: final authorizationData,
      ) =>
        <String, Object?>{'__kind': 8, 'authorizationData': authorizationData},
      DelegateArgsAuthorityItemV1(authorizationData: final authorizationData) =>
        <String, Object?>{'__kind': 9, 'authorizationData': authorizationData},
      DelegateArgsDataItemV1(authorizationData: final authorizationData) =>
        <String, Object?>{'__kind': 10, 'authorizationData': authorizationData},
      DelegateArgsCollectionItemV1(
        authorizationData: final authorizationData,
      ) =>
        <String, Object?>{'__kind': 11, 'authorizationData': authorizationData},
      DelegateArgsProgrammableConfigItemV1(
        authorizationData: final authorizationData,
      ) =>
        <String, Object?>{'__kind': 12, 'authorizationData': authorizationData},
      DelegateArgsPrintDelegateV1(authorizationData: final authorizationData) =>
        <String, Object?>{'__kind': 13, 'authorizationData': authorizationData},
    },
  );
}

Decoder<DelegateArgs> getDelegateArgsDecoder() {
  return transformDecoder<Map<String, Object?>, DelegateArgs>(
    getDiscriminatedUnionDecoder([
      (
        0,
        transformDecoder<Map<String, Object?>, Map<String, Object?>>(
          getStructDecoder([
            (
              'authorizationData',
              getNullableDecoder<AuthorizationData>(
                getAuthorizationDataDecoder(),
              ),
            ),
          ]),
          (Map<String, Object?> map, Uint8List bytes, int offset) => map,
        ),
      ),
      (
        1,
        transformDecoder<Map<String, Object?>, Map<String, Object?>>(
          getStructDecoder([
            ('amount', getU64Decoder()),
            (
              'authorizationData',
              getNullableDecoder<AuthorizationData>(
                getAuthorizationDataDecoder(),
              ),
            ),
          ]),
          (Map<String, Object?> map, Uint8List bytes, int offset) => map,
        ),
      ),
      (
        2,
        transformDecoder<Map<String, Object?>, Map<String, Object?>>(
          getStructDecoder([
            ('amount', getU64Decoder()),
            (
              'authorizationData',
              getNullableDecoder<AuthorizationData>(
                getAuthorizationDataDecoder(),
              ),
            ),
          ]),
          (Map<String, Object?> map, Uint8List bytes, int offset) => map,
        ),
      ),
      (
        3,
        transformDecoder<Map<String, Object?>, Map<String, Object?>>(
          getStructDecoder([
            (
              'authorizationData',
              getNullableDecoder<AuthorizationData>(
                getAuthorizationDataDecoder(),
              ),
            ),
          ]),
          (Map<String, Object?> map, Uint8List bytes, int offset) => map,
        ),
      ),
      (
        4,
        transformDecoder<Map<String, Object?>, Map<String, Object?>>(
          getStructDecoder([
            ('amount', getU64Decoder()),
            (
              'authorizationData',
              getNullableDecoder<AuthorizationData>(
                getAuthorizationDataDecoder(),
              ),
            ),
          ]),
          (Map<String, Object?> map, Uint8List bytes, int offset) => map,
        ),
      ),
      (
        5,
        transformDecoder<Map<String, Object?>, Map<String, Object?>>(
          getStructDecoder([
            ('amount', getU64Decoder()),
            (
              'authorizationData',
              getNullableDecoder<AuthorizationData>(
                getAuthorizationDataDecoder(),
              ),
            ),
          ]),
          (Map<String, Object?> map, Uint8List bytes, int offset) => map,
        ),
      ),
      (
        6,
        transformDecoder<Map<String, Object?>, Map<String, Object?>>(
          getStructDecoder([('amount', getU64Decoder())]),
          (Map<String, Object?> map, Uint8List bytes, int offset) => map,
        ),
      ),
      (
        7,
        transformDecoder<Map<String, Object?>, Map<String, Object?>>(
          getStructDecoder([
            ('amount', getU64Decoder()),
            ('lockedAddress', getAddressDecoder()),
            (
              'authorizationData',
              getNullableDecoder<AuthorizationData>(
                getAuthorizationDataDecoder(),
              ),
            ),
          ]),
          (Map<String, Object?> map, Uint8List bytes, int offset) => map,
        ),
      ),
      (
        8,
        transformDecoder<Map<String, Object?>, Map<String, Object?>>(
          getStructDecoder([
            (
              'authorizationData',
              getNullableDecoder<AuthorizationData>(
                getAuthorizationDataDecoder(),
              ),
            ),
          ]),
          (Map<String, Object?> map, Uint8List bytes, int offset) => map,
        ),
      ),
      (
        9,
        transformDecoder<Map<String, Object?>, Map<String, Object?>>(
          getStructDecoder([
            (
              'authorizationData',
              getNullableDecoder<AuthorizationData>(
                getAuthorizationDataDecoder(),
              ),
            ),
          ]),
          (Map<String, Object?> map, Uint8List bytes, int offset) => map,
        ),
      ),
      (
        10,
        transformDecoder<Map<String, Object?>, Map<String, Object?>>(
          getStructDecoder([
            (
              'authorizationData',
              getNullableDecoder<AuthorizationData>(
                getAuthorizationDataDecoder(),
              ),
            ),
          ]),
          (Map<String, Object?> map, Uint8List bytes, int offset) => map,
        ),
      ),
      (
        11,
        transformDecoder<Map<String, Object?>, Map<String, Object?>>(
          getStructDecoder([
            (
              'authorizationData',
              getNullableDecoder<AuthorizationData>(
                getAuthorizationDataDecoder(),
              ),
            ),
          ]),
          (Map<String, Object?> map, Uint8List bytes, int offset) => map,
        ),
      ),
      (
        12,
        transformDecoder<Map<String, Object?>, Map<String, Object?>>(
          getStructDecoder([
            (
              'authorizationData',
              getNullableDecoder<AuthorizationData>(
                getAuthorizationDataDecoder(),
              ),
            ),
          ]),
          (Map<String, Object?> map, Uint8List bytes, int offset) => map,
        ),
      ),
      (
        13,
        transformDecoder<Map<String, Object?>, Map<String, Object?>>(
          getStructDecoder([
            (
              'authorizationData',
              getNullableDecoder<AuthorizationData>(
                getAuthorizationDataDecoder(),
              ),
            ),
          ]),
          (Map<String, Object?> map, Uint8List bytes, int offset) => map,
        ),
      ),
    ], size: getU8Decoder()),
    (Map<String, Object?> map, Uint8List bytes, int offset) {
      switch (map['__kind']) {
        case 0:
          return DelegateArgsCollectionV1(
            authorizationData: map['authorizationData'] as AuthorizationData?,
          );
        case 1:
          return DelegateArgsSaleV1(
            amount: map['amount']! as BigInt,
            authorizationData: map['authorizationData'] as AuthorizationData?,
          );
        case 2:
          return DelegateArgsTransferV1(
            amount: map['amount']! as BigInt,
            authorizationData: map['authorizationData'] as AuthorizationData?,
          );
        case 3:
          return DelegateArgsDataV1(
            authorizationData: map['authorizationData'] as AuthorizationData?,
          );
        case 4:
          return DelegateArgsUtilityV1(
            amount: map['amount']! as BigInt,
            authorizationData: map['authorizationData'] as AuthorizationData?,
          );
        case 5:
          return DelegateArgsStakingV1(
            amount: map['amount']! as BigInt,
            authorizationData: map['authorizationData'] as AuthorizationData?,
          );
        case 6:
          return DelegateArgsStandardV1(amount: map['amount']! as BigInt);
        case 7:
          return DelegateArgsLockedTransferV1(
            amount: map['amount']! as BigInt,
            lockedAddress: map['lockedAddress']! as Address,
            authorizationData: map['authorizationData'] as AuthorizationData?,
          );
        case 8:
          return DelegateArgsProgrammableConfigV1(
            authorizationData: map['authorizationData'] as AuthorizationData?,
          );
        case 9:
          return DelegateArgsAuthorityItemV1(
            authorizationData: map['authorizationData'] as AuthorizationData?,
          );
        case 10:
          return DelegateArgsDataItemV1(
            authorizationData: map['authorizationData'] as AuthorizationData?,
          );
        case 11:
          return DelegateArgsCollectionItemV1(
            authorizationData: map['authorizationData'] as AuthorizationData?,
          );
        case 12:
          return DelegateArgsProgrammableConfigItemV1(
            authorizationData: map['authorizationData'] as AuthorizationData?,
          );
        case 13:
          return DelegateArgsPrintDelegateV1(
            authorizationData: map['authorizationData'] as AuthorizationData?,
          );
      }
      throw StateError(
        'Unsupported DelegateArgs discriminator: ${map['__kind']}',
      );
    },
  );
}

Codec<DelegateArgs, DelegateArgs> getDelegateArgsCodec() {
  return combineCodec(getDelegateArgsEncoder(), getDelegateArgsDecoder());
}
