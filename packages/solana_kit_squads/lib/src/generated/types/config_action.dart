// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

import './member.dart';
import './period.dart';

sealed class ConfigAction {
  const ConfigAction();
}

final class ConfigActionAddMember extends ConfigAction {
  const ConfigActionAddMember({
    required this.newMember,
  });

  final Member newMember;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConfigActionAddMember && newMember == other.newMember;

  @override
  int get hashCode => newMember.hashCode;

  @override
  String toString() => 'ConfigAction.AddMember(newMember: $newMember)';
}

final class ConfigActionRemoveMember extends ConfigAction {
  const ConfigActionRemoveMember({
    required this.oldMember,
  });

  final Address oldMember;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConfigActionRemoveMember && oldMember == other.oldMember;

  @override
  int get hashCode => oldMember.hashCode;

  @override
  String toString() => 'ConfigAction.RemoveMember(oldMember: $oldMember)';
}

final class ConfigActionChangeThreshold extends ConfigAction {
  const ConfigActionChangeThreshold({
    required this.newThreshold,
  });

  final int newThreshold;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConfigActionChangeThreshold &&
          newThreshold == other.newThreshold;

  @override
  int get hashCode => newThreshold.hashCode;

  @override
  String toString() =>
      'ConfigAction.ChangeThreshold(newThreshold: $newThreshold)';
}

final class ConfigActionSetTimeLock extends ConfigAction {
  const ConfigActionSetTimeLock({
    required this.newTimeLock,
  });

  final int newTimeLock;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConfigActionSetTimeLock && newTimeLock == other.newTimeLock;

  @override
  int get hashCode => newTimeLock.hashCode;

  @override
  String toString() => 'ConfigAction.SetTimeLock(newTimeLock: $newTimeLock)';
}

final class ConfigActionAddSpendingLimit extends ConfigAction {
  const ConfigActionAddSpendingLimit({
    required this.createKey,
    required this.vaultIndex,
    required this.mint,
    required this.amount,
    required this.period,
    required this.members,
    required this.destinations,
  });

  final Address createKey;
  final int vaultIndex;
  final Address mint;
  final BigInt amount;
  final Period period;
  final List<Address> members;
  final List<Address> destinations;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConfigActionAddSpendingLimit &&
          createKey == other.createKey &&
          vaultIndex == other.vaultIndex &&
          mint == other.mint &&
          amount == other.amount &&
          period == other.period &&
          _listEquals(members, other.members) &&
          _listEquals(destinations, other.destinations);

  @override
  int get hashCode => Object.hash(
    createKey,
    vaultIndex,
    mint,
    amount,
    period,
    _listHashCode(members),
    _listHashCode(destinations),
  );

  @override
  String toString() =>
      'ConfigAction.AddSpendingLimit(createKey: $createKey, vaultIndex: $vaultIndex, mint: $mint, amount: $amount, period: $period, members: $members, destinations: $destinations)';
}

final class ConfigActionRemoveSpendingLimit extends ConfigAction {
  const ConfigActionRemoveSpendingLimit({
    required this.spendingLimit,
  });

  final Address spendingLimit;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConfigActionRemoveSpendingLimit &&
          spendingLimit == other.spendingLimit;

  @override
  int get hashCode => spendingLimit.hashCode;

  @override
  String toString() =>
      'ConfigAction.RemoveSpendingLimit(spendingLimit: $spendingLimit)';
}

final class ConfigActionSetRentCollector extends ConfigAction {
  const ConfigActionSetRentCollector({
    required this.newRentCollector,
  });

  final Address? newRentCollector;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConfigActionSetRentCollector &&
          newRentCollector == other.newRentCollector;

  @override
  int get hashCode => newRentCollector.hashCode;

  @override
  String toString() =>
      'ConfigAction.SetRentCollector(newRentCollector: $newRentCollector)';
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

Encoder<ConfigAction> getConfigActionEncoder() {
  return transformEncoder<Map<String, Object?>, ConfigAction>(
    getDiscriminatedUnionEncoder([
      (0, getStructEncoder([('newMember', getMemberEncoder())])),
      (1, getStructEncoder([('oldMember', getAddressEncoder())])),
      (2, getStructEncoder([('newThreshold', getU16Encoder())])),
      (3, getStructEncoder([('newTimeLock', getU32Encoder())])),
      (
        4,
        getStructEncoder([
          ('createKey', getAddressEncoder()),
          ('vaultIndex', getU8Encoder()),
          ('mint', getAddressEncoder()),
          ('amount', getU64Encoder()),
          ('period', getPeriodEncoder()),
          (
            'members',
            getArrayEncoder(
              transformEncoder(getAddressEncoder(), (Address value) => value),
            ),
          ),
          (
            'destinations',
            getArrayEncoder(
              transformEncoder(getAddressEncoder(), (Address value) => value),
            ),
          ),
        ]),
      ),
      (5, getStructEncoder([('spendingLimit', getAddressEncoder())])),
      (
        6,
        getStructEncoder([
          (
            'newRentCollector',
            getNullableEncoder<Address>(
              transformEncoder(getAddressEncoder(), (Address value) => value),
            ),
          ),
        ]),
      ),
    ], size: getU8Encoder()),
    (ConfigAction value) => switch (value) {
      ConfigActionAddMember(newMember: final newMember) => <String, Object?>{
        '__kind': 0,
        'newMember': newMember,
      },
      ConfigActionRemoveMember(oldMember: final oldMember) => <String, Object?>{
        '__kind': 1,
        'oldMember': oldMember,
      },
      ConfigActionChangeThreshold(newThreshold: final newThreshold) =>
        <String, Object?>{'__kind': 2, 'newThreshold': newThreshold},
      ConfigActionSetTimeLock(newTimeLock: final newTimeLock) =>
        <String, Object?>{'__kind': 3, 'newTimeLock': newTimeLock},
      ConfigActionAddSpendingLimit(
        createKey: final createKey,
        vaultIndex: final vaultIndex,
        mint: final mint,
        amount: final amount,
        period: final period,
        members: final members,
        destinations: final destinations,
      ) =>
        <String, Object?>{
          '__kind': 4,
          'createKey': createKey,
          'vaultIndex': vaultIndex,
          'mint': mint,
          'amount': amount,
          'period': period,
          'members': members,
          'destinations': destinations,
        },
      ConfigActionRemoveSpendingLimit(spendingLimit: final spendingLimit) =>
        <String, Object?>{'__kind': 5, 'spendingLimit': spendingLimit},
      ConfigActionSetRentCollector(newRentCollector: final newRentCollector) =>
        <String, Object?>{'__kind': 6, 'newRentCollector': newRentCollector},
    },
  );
}

Decoder<ConfigAction> getConfigActionDecoder() {
  return transformDecoder<Map<String, Object?>, ConfigAction>(
    getDiscriminatedUnionDecoder([
      (
        0,
        transformDecoder<Map<String, Object?>, Map<String, Object?>>(
          getStructDecoder([('newMember', getMemberDecoder())]),
          (Map<String, Object?> map, Uint8List bytes, int offset) => map,
        ),
      ),
      (
        1,
        transformDecoder<Map<String, Object?>, Map<String, Object?>>(
          getStructDecoder([('oldMember', getAddressDecoder())]),
          (Map<String, Object?> map, Uint8List bytes, int offset) => map,
        ),
      ),
      (
        2,
        transformDecoder<Map<String, Object?>, Map<String, Object?>>(
          getStructDecoder([('newThreshold', getU16Decoder())]),
          (Map<String, Object?> map, Uint8List bytes, int offset) => map,
        ),
      ),
      (
        3,
        transformDecoder<Map<String, Object?>, Map<String, Object?>>(
          getStructDecoder([('newTimeLock', getU32Decoder())]),
          (Map<String, Object?> map, Uint8List bytes, int offset) => map,
        ),
      ),
      (
        4,
        transformDecoder<Map<String, Object?>, Map<String, Object?>>(
          getStructDecoder([
            ('createKey', getAddressDecoder()),
            ('vaultIndex', getU8Decoder()),
            ('mint', getAddressDecoder()),
            ('amount', getU64Decoder()),
            ('period', getPeriodDecoder()),
            ('members', getArrayDecoder(getAddressDecoder())),
            ('destinations', getArrayDecoder(getAddressDecoder())),
          ]),
          (Map<String, Object?> map, Uint8List bytes, int offset) => map,
        ),
      ),
      (
        5,
        transformDecoder<Map<String, Object?>, Map<String, Object?>>(
          getStructDecoder([('spendingLimit', getAddressDecoder())]),
          (Map<String, Object?> map, Uint8List bytes, int offset) => map,
        ),
      ),
      (
        6,
        transformDecoder<Map<String, Object?>, Map<String, Object?>>(
          getStructDecoder([
            (
              'newRentCollector',
              getNullableDecoder<Address>(getAddressDecoder()),
            ),
          ]),
          (Map<String, Object?> map, Uint8List bytes, int offset) => map,
        ),
      ),
    ], size: getU8Decoder()),
    (Map<String, Object?> map, Uint8List bytes, int offset) {
      switch (map['__kind']) {
        case 0:
          return ConfigActionAddMember(newMember: map['newMember']! as Member);
        case 1:
          return ConfigActionRemoveMember(
            oldMember: map['oldMember']! as Address,
          );
        case 2:
          return ConfigActionChangeThreshold(
            newThreshold: map['newThreshold']! as int,
          );
        case 3:
          return ConfigActionSetTimeLock(
            newTimeLock: map['newTimeLock']! as int,
          );
        case 4:
          return ConfigActionAddSpendingLimit(
            createKey: map['createKey']! as Address,
            vaultIndex: map['vaultIndex']! as int,
            mint: map['mint']! as Address,
            amount: map['amount']! as BigInt,
            period: map['period']! as Period,
            members: map['members']! as List<Address>,
            destinations: map['destinations']! as List<Address>,
          );
        case 5:
          return ConfigActionRemoveSpendingLimit(
            spendingLimit: map['spendingLimit']! as Address,
          );
        case 6:
          return ConfigActionSetRentCollector(
            newRentCollector: map['newRentCollector'] as Address?,
          );
      }
      throw StateError(
        'Unsupported ConfigAction discriminator: ${map['__kind']}',
      );
    },
  );
}

Codec<ConfigAction, ConfigAction> getConfigActionCodec() {
  return combineCodec(getConfigActionEncoder(), getConfigActionDecoder());
}
