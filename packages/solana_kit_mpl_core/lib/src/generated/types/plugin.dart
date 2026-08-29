// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

import './add_blocker.dart';
import './attributes.dart';
import './autograph.dart';
import './bubblegum_v2.dart';
import './burn_delegate.dart';
import './edition.dart';
import './freeze_delegate.dart';
import './freeze_execute.dart';
import './groups.dart';
import './immutable_metadata.dart';
import './master_edition.dart';
import './permanent_burn_delegate.dart';
import './permanent_freeze_delegate.dart';
import './permanent_freeze_execute.dart';
import './permanent_transfer_delegate.dart';
import './royalties.dart';
import './transfer_delegate.dart';
import './update_delegate.dart';
import './verified_creators.dart';

sealed class Plugin {
  const Plugin();
}

final class PluginRoyalties extends Plugin {
  const PluginRoyalties(this.value);

  final Royalties value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PluginRoyalties && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Plugin.Royalties($value)';
}

final class PluginFreezeDelegate extends Plugin {
  const PluginFreezeDelegate(this.value);

  final FreezeDelegate value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PluginFreezeDelegate && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Plugin.FreezeDelegate($value)';
}

final class PluginBurnDelegate extends Plugin {
  const PluginBurnDelegate(this.value);

  final BurnDelegate value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PluginBurnDelegate && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Plugin.BurnDelegate($value)';
}

final class PluginTransferDelegate extends Plugin {
  const PluginTransferDelegate(this.value);

  final TransferDelegate value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PluginTransferDelegate && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Plugin.TransferDelegate($value)';
}

final class PluginUpdateDelegate extends Plugin {
  const PluginUpdateDelegate(this.value);

  final UpdateDelegate value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PluginUpdateDelegate && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Plugin.UpdateDelegate($value)';
}

final class PluginPermanentFreezeDelegate extends Plugin {
  const PluginPermanentFreezeDelegate(this.value);

  final PermanentFreezeDelegate value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PluginPermanentFreezeDelegate && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Plugin.PermanentFreezeDelegate($value)';
}

final class PluginAttributes extends Plugin {
  const PluginAttributes(this.value);

  final Attributes value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PluginAttributes && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Plugin.Attributes($value)';
}

final class PluginPermanentTransferDelegate extends Plugin {
  const PluginPermanentTransferDelegate(this.value);

  final PermanentTransferDelegate value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PluginPermanentTransferDelegate && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Plugin.PermanentTransferDelegate($value)';
}

final class PluginPermanentBurnDelegate extends Plugin {
  const PluginPermanentBurnDelegate(this.value);

  final PermanentBurnDelegate value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PluginPermanentBurnDelegate && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Plugin.PermanentBurnDelegate($value)';
}

final class PluginEdition extends Plugin {
  const PluginEdition(this.value);

  final Edition value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is PluginEdition && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Plugin.Edition($value)';
}

final class PluginMasterEdition extends Plugin {
  const PluginMasterEdition(this.value);

  final MasterEdition value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PluginMasterEdition && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Plugin.MasterEdition($value)';
}

final class PluginAddBlocker extends Plugin {
  const PluginAddBlocker(this.value);

  final AddBlocker value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PluginAddBlocker && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Plugin.AddBlocker($value)';
}

final class PluginImmutableMetadata extends Plugin {
  const PluginImmutableMetadata(this.value);

  final ImmutableMetadata value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PluginImmutableMetadata && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Plugin.ImmutableMetadata($value)';
}

final class PluginVerifiedCreators extends Plugin {
  const PluginVerifiedCreators(this.value);

  final VerifiedCreators value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PluginVerifiedCreators && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Plugin.VerifiedCreators($value)';
}

final class PluginAutograph extends Plugin {
  const PluginAutograph(this.value);

  final Autograph value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PluginAutograph && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Plugin.Autograph($value)';
}

final class PluginBubblegumV2 extends Plugin {
  const PluginBubblegumV2(this.value);

  final BubblegumV2 value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PluginBubblegumV2 && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Plugin.BubblegumV2($value)';
}

final class PluginFreezeExecute extends Plugin {
  const PluginFreezeExecute(this.value);

  final FreezeExecute value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PluginFreezeExecute && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Plugin.FreezeExecute($value)';
}

final class PluginPermanentFreezeExecute extends Plugin {
  const PluginPermanentFreezeExecute(this.value);

  final PermanentFreezeExecute value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PluginPermanentFreezeExecute && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Plugin.PermanentFreezeExecute($value)';
}

final class PluginGroups extends Plugin {
  const PluginGroups(this.value);

  final Groups value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is PluginGroups && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Plugin.Groups($value)';
}

Encoder<Plugin> getPluginEncoder() {
  return transformEncoder<Map<String, Object?>, Plugin>(
    getDiscriminatedUnionEncoder([
      (
        0,
        transformEncoder<Royalties, Map<String, Object?>>(
          getRoyaltiesEncoder(),
          (Map<String, Object?> map) => map['value']! as Royalties,
        ),
      ),
      (
        1,
        transformEncoder<FreezeDelegate, Map<String, Object?>>(
          getFreezeDelegateEncoder(),
          (Map<String, Object?> map) => map['value']! as FreezeDelegate,
        ),
      ),
      (
        2,
        transformEncoder<BurnDelegate, Map<String, Object?>>(
          getBurnDelegateEncoder(),
          (Map<String, Object?> map) => map['value']! as BurnDelegate,
        ),
      ),
      (
        3,
        transformEncoder<TransferDelegate, Map<String, Object?>>(
          getTransferDelegateEncoder(),
          (Map<String, Object?> map) => map['value']! as TransferDelegate,
        ),
      ),
      (
        4,
        transformEncoder<UpdateDelegate, Map<String, Object?>>(
          getUpdateDelegateEncoder(),
          (Map<String, Object?> map) => map['value']! as UpdateDelegate,
        ),
      ),
      (
        5,
        transformEncoder<PermanentFreezeDelegate, Map<String, Object?>>(
          getPermanentFreezeDelegateEncoder(),
          (Map<String, Object?> map) =>
              map['value']! as PermanentFreezeDelegate,
        ),
      ),
      (
        6,
        transformEncoder<Attributes, Map<String, Object?>>(
          getAttributesEncoder(),
          (Map<String, Object?> map) => map['value']! as Attributes,
        ),
      ),
      (
        7,
        transformEncoder<PermanentTransferDelegate, Map<String, Object?>>(
          getPermanentTransferDelegateEncoder(),
          (Map<String, Object?> map) =>
              map['value']! as PermanentTransferDelegate,
        ),
      ),
      (
        8,
        transformEncoder<PermanentBurnDelegate, Map<String, Object?>>(
          getPermanentBurnDelegateEncoder(),
          (Map<String, Object?> map) => map['value']! as PermanentBurnDelegate,
        ),
      ),
      (
        9,
        transformEncoder<Edition, Map<String, Object?>>(
          getEditionEncoder(),
          (Map<String, Object?> map) => map['value']! as Edition,
        ),
      ),
      (
        10,
        transformEncoder<MasterEdition, Map<String, Object?>>(
          getMasterEditionEncoder(),
          (Map<String, Object?> map) => map['value']! as MasterEdition,
        ),
      ),
      (
        11,
        transformEncoder<AddBlocker, Map<String, Object?>>(
          getAddBlockerEncoder(),
          (Map<String, Object?> map) => map['value']! as AddBlocker,
        ),
      ),
      (
        12,
        transformEncoder<ImmutableMetadata, Map<String, Object?>>(
          getImmutableMetadataEncoder(),
          (Map<String, Object?> map) => map['value']! as ImmutableMetadata,
        ),
      ),
      (
        13,
        transformEncoder<VerifiedCreators, Map<String, Object?>>(
          getVerifiedCreatorsEncoder(),
          (Map<String, Object?> map) => map['value']! as VerifiedCreators,
        ),
      ),
      (
        14,
        transformEncoder<Autograph, Map<String, Object?>>(
          getAutographEncoder(),
          (Map<String, Object?> map) => map['value']! as Autograph,
        ),
      ),
      (
        15,
        transformEncoder<BubblegumV2, Map<String, Object?>>(
          getBubblegumV2Encoder(),
          (Map<String, Object?> map) => map['value']! as BubblegumV2,
        ),
      ),
      (
        16,
        transformEncoder<FreezeExecute, Map<String, Object?>>(
          getFreezeExecuteEncoder(),
          (Map<String, Object?> map) => map['value']! as FreezeExecute,
        ),
      ),
      (
        17,
        transformEncoder<PermanentFreezeExecute, Map<String, Object?>>(
          getPermanentFreezeExecuteEncoder(),
          (Map<String, Object?> map) => map['value']! as PermanentFreezeExecute,
        ),
      ),
      (
        18,
        transformEncoder<Groups, Map<String, Object?>>(
          getGroupsEncoder(),
          (Map<String, Object?> map) => map['value']! as Groups,
        ),
      ),
    ], size: getU8Encoder()),
    (Plugin value) => switch (value) {
      PluginRoyalties(value: final value) => <String, Object?>{
        '__kind': 0,
        'value': value,
      },
      PluginFreezeDelegate(value: final value) => <String, Object?>{
        '__kind': 1,
        'value': value,
      },
      PluginBurnDelegate(value: final value) => <String, Object?>{
        '__kind': 2,
        'value': value,
      },
      PluginTransferDelegate(value: final value) => <String, Object?>{
        '__kind': 3,
        'value': value,
      },
      PluginUpdateDelegate(value: final value) => <String, Object?>{
        '__kind': 4,
        'value': value,
      },
      PluginPermanentFreezeDelegate(value: final value) => <String, Object?>{
        '__kind': 5,
        'value': value,
      },
      PluginAttributes(value: final value) => <String, Object?>{
        '__kind': 6,
        'value': value,
      },
      PluginPermanentTransferDelegate(value: final value) => <String, Object?>{
        '__kind': 7,
        'value': value,
      },
      PluginPermanentBurnDelegate(value: final value) => <String, Object?>{
        '__kind': 8,
        'value': value,
      },
      PluginEdition(value: final value) => <String, Object?>{
        '__kind': 9,
        'value': value,
      },
      PluginMasterEdition(value: final value) => <String, Object?>{
        '__kind': 10,
        'value': value,
      },
      PluginAddBlocker(value: final value) => <String, Object?>{
        '__kind': 11,
        'value': value,
      },
      PluginImmutableMetadata(value: final value) => <String, Object?>{
        '__kind': 12,
        'value': value,
      },
      PluginVerifiedCreators(value: final value) => <String, Object?>{
        '__kind': 13,
        'value': value,
      },
      PluginAutograph(value: final value) => <String, Object?>{
        '__kind': 14,
        'value': value,
      },
      PluginBubblegumV2(value: final value) => <String, Object?>{
        '__kind': 15,
        'value': value,
      },
      PluginFreezeExecute(value: final value) => <String, Object?>{
        '__kind': 16,
        'value': value,
      },
      PluginPermanentFreezeExecute(value: final value) => <String, Object?>{
        '__kind': 17,
        'value': value,
      },
      PluginGroups(value: final value) => <String, Object?>{
        '__kind': 18,
        'value': value,
      },
    },
  );
}

Decoder<Plugin> getPluginDecoder() {
  return transformDecoder<Map<String, Object?>, Plugin>(
    getDiscriminatedUnionDecoder([
      (
        0,
        transformDecoder<Royalties, Map<String, Object?>>(
          getRoyaltiesDecoder(),
          (Royalties value, Uint8List bytes, int offset) => <String, Object?>{
            'value': value,
          },
        ),
      ),
      (
        1,
        transformDecoder<FreezeDelegate, Map<String, Object?>>(
          getFreezeDelegateDecoder(),
          (FreezeDelegate value, Uint8List bytes, int offset) =>
              <String, Object?>{'value': value},
        ),
      ),
      (
        2,
        transformDecoder<BurnDelegate, Map<String, Object?>>(
          getBurnDelegateDecoder(),
          (BurnDelegate value, Uint8List bytes, int offset) =>
              <String, Object?>{'value': value},
        ),
      ),
      (
        3,
        transformDecoder<TransferDelegate, Map<String, Object?>>(
          getTransferDelegateDecoder(),
          (TransferDelegate value, Uint8List bytes, int offset) =>
              <String, Object?>{'value': value},
        ),
      ),
      (
        4,
        transformDecoder<UpdateDelegate, Map<String, Object?>>(
          getUpdateDelegateDecoder(),
          (UpdateDelegate value, Uint8List bytes, int offset) =>
              <String, Object?>{'value': value},
        ),
      ),
      (
        5,
        transformDecoder<PermanentFreezeDelegate, Map<String, Object?>>(
          getPermanentFreezeDelegateDecoder(),
          (PermanentFreezeDelegate value, Uint8List bytes, int offset) =>
              <String, Object?>{'value': value},
        ),
      ),
      (
        6,
        transformDecoder<Attributes, Map<String, Object?>>(
          getAttributesDecoder(),
          (Attributes value, Uint8List bytes, int offset) => <String, Object?>{
            'value': value,
          },
        ),
      ),
      (
        7,
        transformDecoder<PermanentTransferDelegate, Map<String, Object?>>(
          getPermanentTransferDelegateDecoder(),
          (PermanentTransferDelegate value, Uint8List bytes, int offset) =>
              <String, Object?>{'value': value},
        ),
      ),
      (
        8,
        transformDecoder<PermanentBurnDelegate, Map<String, Object?>>(
          getPermanentBurnDelegateDecoder(),
          (PermanentBurnDelegate value, Uint8List bytes, int offset) =>
              <String, Object?>{'value': value},
        ),
      ),
      (
        9,
        transformDecoder<Edition, Map<String, Object?>>(
          getEditionDecoder(),
          (Edition value, Uint8List bytes, int offset) => <String, Object?>{
            'value': value,
          },
        ),
      ),
      (
        10,
        transformDecoder<MasterEdition, Map<String, Object?>>(
          getMasterEditionDecoder(),
          (MasterEdition value, Uint8List bytes, int offset) =>
              <String, Object?>{'value': value},
        ),
      ),
      (
        11,
        transformDecoder<AddBlocker, Map<String, Object?>>(
          getAddBlockerDecoder(),
          (AddBlocker value, Uint8List bytes, int offset) => <String, Object?>{
            'value': value,
          },
        ),
      ),
      (
        12,
        transformDecoder<ImmutableMetadata, Map<String, Object?>>(
          getImmutableMetadataDecoder(),
          (ImmutableMetadata value, Uint8List bytes, int offset) =>
              <String, Object?>{'value': value},
        ),
      ),
      (
        13,
        transformDecoder<VerifiedCreators, Map<String, Object?>>(
          getVerifiedCreatorsDecoder(),
          (VerifiedCreators value, Uint8List bytes, int offset) =>
              <String, Object?>{'value': value},
        ),
      ),
      (
        14,
        transformDecoder<Autograph, Map<String, Object?>>(
          getAutographDecoder(),
          (Autograph value, Uint8List bytes, int offset) => <String, Object?>{
            'value': value,
          },
        ),
      ),
      (
        15,
        transformDecoder<BubblegumV2, Map<String, Object?>>(
          getBubblegumV2Decoder(),
          (BubblegumV2 value, Uint8List bytes, int offset) => <String, Object?>{
            'value': value,
          },
        ),
      ),
      (
        16,
        transformDecoder<FreezeExecute, Map<String, Object?>>(
          getFreezeExecuteDecoder(),
          (FreezeExecute value, Uint8List bytes, int offset) =>
              <String, Object?>{'value': value},
        ),
      ),
      (
        17,
        transformDecoder<PermanentFreezeExecute, Map<String, Object?>>(
          getPermanentFreezeExecuteDecoder(),
          (PermanentFreezeExecute value, Uint8List bytes, int offset) =>
              <String, Object?>{'value': value},
        ),
      ),
      (
        18,
        transformDecoder<Groups, Map<String, Object?>>(
          getGroupsDecoder(),
          (Groups value, Uint8List bytes, int offset) => <String, Object?>{
            'value': value,
          },
        ),
      ),
    ], size: getU8Decoder()),
    (Map<String, Object?> map, Uint8List bytes, int offset) {
      switch (map['__kind']) {
        case 0:
          return PluginRoyalties(map['value']! as Royalties);
        case 1:
          return PluginFreezeDelegate(map['value']! as FreezeDelegate);
        case 2:
          return PluginBurnDelegate(map['value']! as BurnDelegate);
        case 3:
          return PluginTransferDelegate(map['value']! as TransferDelegate);
        case 4:
          return PluginUpdateDelegate(map['value']! as UpdateDelegate);
        case 5:
          return PluginPermanentFreezeDelegate(
            map['value']! as PermanentFreezeDelegate,
          );
        case 6:
          return PluginAttributes(map['value']! as Attributes);
        case 7:
          return PluginPermanentTransferDelegate(
            map['value']! as PermanentTransferDelegate,
          );
        case 8:
          return PluginPermanentBurnDelegate(
            map['value']! as PermanentBurnDelegate,
          );
        case 9:
          return PluginEdition(map['value']! as Edition);
        case 10:
          return PluginMasterEdition(map['value']! as MasterEdition);
        case 11:
          return PluginAddBlocker(map['value']! as AddBlocker);
        case 12:
          return PluginImmutableMetadata(map['value']! as ImmutableMetadata);
        case 13:
          return PluginVerifiedCreators(map['value']! as VerifiedCreators);
        case 14:
          return PluginAutograph(map['value']! as Autograph);
        case 15:
          return PluginBubblegumV2(map['value']! as BubblegumV2);
        case 16:
          return PluginFreezeExecute(map['value']! as FreezeExecute);
        case 17:
          return PluginPermanentFreezeExecute(
            map['value']! as PermanentFreezeExecute,
          );
        case 18:
          return PluginGroups(map['value']! as Groups);
      }
      throw StateError('Unsupported Plugin discriminator: ${map['__kind']}');
    },
  );
}

Codec<Plugin, Plugin> getPluginCodec() {
  return combineCodec(getPluginEncoder(), getPluginDecoder());
}
