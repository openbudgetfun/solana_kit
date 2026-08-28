// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

import './authorization_data.dart';
import './collection_details_toggle.dart';
import './collection_toggle.dart';
import './data.dart';
import './rule_set_toggle.dart';
import './token_standard.dart';
import './uses_toggle.dart';

sealed class UpdateArgs {
  const UpdateArgs();
}

final class UpdateArgsV1 extends UpdateArgs {
  const UpdateArgsV1({
    required this.newUpdateAuthority,
    required this.data,
    required this.primarySaleHappened,
    required this.isMutable,
    required this.collection,
    required this.collectionDetails,
    required this.uses,
    required this.ruleSet,
    required this.authorizationData,
  });

  final Address? newUpdateAuthority;
  final Data? data;
  final bool? primarySaleHappened;
  final bool? isMutable;
  final CollectionToggle collection;
  final CollectionDetailsToggle collectionDetails;
  final UsesToggle uses;
  final RuleSetToggle ruleSet;
  final AuthorizationData? authorizationData;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateArgsV1 &&
          newUpdateAuthority == other.newUpdateAuthority &&
          data == other.data &&
          primarySaleHappened == other.primarySaleHappened &&
          isMutable == other.isMutable &&
          collection == other.collection &&
          collectionDetails == other.collectionDetails &&
          uses == other.uses &&
          ruleSet == other.ruleSet &&
          authorizationData == other.authorizationData;

  @override
  int get hashCode => Object.hash(
    newUpdateAuthority,
    data,
    primarySaleHappened,
    isMutable,
    collection,
    collectionDetails,
    uses,
    ruleSet,
    authorizationData,
  );

  @override
  String toString() =>
      'UpdateArgs.V1(newUpdateAuthority: $newUpdateAuthority, data: $data, primarySaleHappened: $primarySaleHappened, isMutable: $isMutable, collection: $collection, collectionDetails: $collectionDetails, uses: $uses, ruleSet: $ruleSet, authorizationData: $authorizationData)';
}

final class UpdateArgsAsUpdateAuthorityV2 extends UpdateArgs {
  const UpdateArgsAsUpdateAuthorityV2({
    required this.newUpdateAuthority,
    required this.data,
    required this.primarySaleHappened,
    required this.isMutable,
    required this.collection,
    required this.collectionDetails,
    required this.uses,
    required this.ruleSet,
    required this.tokenStandard,
    required this.authorizationData,
  });

  final Address? newUpdateAuthority;
  final Data? data;
  final bool? primarySaleHappened;
  final bool? isMutable;
  final CollectionToggle collection;
  final CollectionDetailsToggle collectionDetails;
  final UsesToggle uses;
  final RuleSetToggle ruleSet;
  final TokenStandard? tokenStandard;
  final AuthorizationData? authorizationData;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateArgsAsUpdateAuthorityV2 &&
          newUpdateAuthority == other.newUpdateAuthority &&
          data == other.data &&
          primarySaleHappened == other.primarySaleHappened &&
          isMutable == other.isMutable &&
          collection == other.collection &&
          collectionDetails == other.collectionDetails &&
          uses == other.uses &&
          ruleSet == other.ruleSet &&
          tokenStandard == other.tokenStandard &&
          authorizationData == other.authorizationData;

  @override
  int get hashCode => Object.hash(
    newUpdateAuthority,
    data,
    primarySaleHappened,
    isMutable,
    collection,
    collectionDetails,
    uses,
    ruleSet,
    tokenStandard,
    authorizationData,
  );

  @override
  String toString() =>
      'UpdateArgs.AsUpdateAuthorityV2(newUpdateAuthority: $newUpdateAuthority, data: $data, primarySaleHappened: $primarySaleHappened, isMutable: $isMutable, collection: $collection, collectionDetails: $collectionDetails, uses: $uses, ruleSet: $ruleSet, tokenStandard: $tokenStandard, authorizationData: $authorizationData)';
}

final class UpdateArgsAsAuthorityItemDelegateV2 extends UpdateArgs {
  const UpdateArgsAsAuthorityItemDelegateV2({
    required this.newUpdateAuthority,
    required this.primarySaleHappened,
    required this.isMutable,
    required this.tokenStandard,
    required this.authorizationData,
  });

  final Address? newUpdateAuthority;
  final bool? primarySaleHappened;
  final bool? isMutable;
  final TokenStandard? tokenStandard;
  final AuthorizationData? authorizationData;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateArgsAsAuthorityItemDelegateV2 &&
          newUpdateAuthority == other.newUpdateAuthority &&
          primarySaleHappened == other.primarySaleHappened &&
          isMutable == other.isMutable &&
          tokenStandard == other.tokenStandard &&
          authorizationData == other.authorizationData;

  @override
  int get hashCode => Object.hash(
    newUpdateAuthority,
    primarySaleHappened,
    isMutable,
    tokenStandard,
    authorizationData,
  );

  @override
  String toString() =>
      'UpdateArgs.AsAuthorityItemDelegateV2(newUpdateAuthority: $newUpdateAuthority, primarySaleHappened: $primarySaleHappened, isMutable: $isMutable, tokenStandard: $tokenStandard, authorizationData: $authorizationData)';
}

final class UpdateArgsAsCollectionDelegateV2 extends UpdateArgs {
  const UpdateArgsAsCollectionDelegateV2({
    required this.collection,
    required this.authorizationData,
  });

  final CollectionToggle collection;
  final AuthorizationData? authorizationData;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateArgsAsCollectionDelegateV2 &&
          collection == other.collection &&
          authorizationData == other.authorizationData;

  @override
  int get hashCode => Object.hash(collection, authorizationData);

  @override
  String toString() =>
      'UpdateArgs.AsCollectionDelegateV2(collection: $collection, authorizationData: $authorizationData)';
}

final class UpdateArgsAsDataDelegateV2 extends UpdateArgs {
  const UpdateArgsAsDataDelegateV2({
    required this.data,
    required this.authorizationData,
  });

  final Data? data;
  final AuthorizationData? authorizationData;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateArgsAsDataDelegateV2 &&
          data == other.data &&
          authorizationData == other.authorizationData;

  @override
  int get hashCode => Object.hash(data, authorizationData);

  @override
  String toString() =>
      'UpdateArgs.AsDataDelegateV2(data: $data, authorizationData: $authorizationData)';
}

final class UpdateArgsAsProgrammableConfigDelegateV2 extends UpdateArgs {
  const UpdateArgsAsProgrammableConfigDelegateV2({
    required this.ruleSet,
    required this.authorizationData,
  });

  final RuleSetToggle ruleSet;
  final AuthorizationData? authorizationData;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateArgsAsProgrammableConfigDelegateV2 &&
          ruleSet == other.ruleSet &&
          authorizationData == other.authorizationData;

  @override
  int get hashCode => Object.hash(ruleSet, authorizationData);

  @override
  String toString() =>
      'UpdateArgs.AsProgrammableConfigDelegateV2(ruleSet: $ruleSet, authorizationData: $authorizationData)';
}

final class UpdateArgsAsDataItemDelegateV2 extends UpdateArgs {
  const UpdateArgsAsDataItemDelegateV2({
    required this.data,
    required this.authorizationData,
  });

  final Data? data;
  final AuthorizationData? authorizationData;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateArgsAsDataItemDelegateV2 &&
          data == other.data &&
          authorizationData == other.authorizationData;

  @override
  int get hashCode => Object.hash(data, authorizationData);

  @override
  String toString() =>
      'UpdateArgs.AsDataItemDelegateV2(data: $data, authorizationData: $authorizationData)';
}

final class UpdateArgsAsCollectionItemDelegateV2 extends UpdateArgs {
  const UpdateArgsAsCollectionItemDelegateV2({
    required this.collection,
    required this.authorizationData,
  });

  final CollectionToggle collection;
  final AuthorizationData? authorizationData;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateArgsAsCollectionItemDelegateV2 &&
          collection == other.collection &&
          authorizationData == other.authorizationData;

  @override
  int get hashCode => Object.hash(collection, authorizationData);

  @override
  String toString() =>
      'UpdateArgs.AsCollectionItemDelegateV2(collection: $collection, authorizationData: $authorizationData)';
}

final class UpdateArgsAsProgrammableConfigItemDelegateV2 extends UpdateArgs {
  const UpdateArgsAsProgrammableConfigItemDelegateV2({
    required this.ruleSet,
    required this.authorizationData,
  });

  final RuleSetToggle ruleSet;
  final AuthorizationData? authorizationData;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateArgsAsProgrammableConfigItemDelegateV2 &&
          ruleSet == other.ruleSet &&
          authorizationData == other.authorizationData;

  @override
  int get hashCode => Object.hash(ruleSet, authorizationData);

  @override
  String toString() =>
      'UpdateArgs.AsProgrammableConfigItemDelegateV2(ruleSet: $ruleSet, authorizationData: $authorizationData)';
}

Encoder<UpdateArgs> getUpdateArgsEncoder() {
  return transformEncoder<Map<String, Object?>, UpdateArgs>(
    getDiscriminatedUnionEncoder([
      (
        0,
        getStructEncoder([
          (
            'newUpdateAuthority',
            getNullableEncoder<Address>(getAddressEncoder()),
          ),
          ('data', getNullableEncoder<Data>(getDataEncoder())),
          (
            'primarySaleHappened',
            getNullableEncoder<bool>(getBooleanEncoder()),
          ),
          ('isMutable', getNullableEncoder<bool>(getBooleanEncoder())),
          ('collection', getCollectionToggleEncoder()),
          ('collectionDetails', getCollectionDetailsToggleEncoder()),
          ('uses', getUsesToggleEncoder()),
          ('ruleSet', getRuleSetToggleEncoder()),
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
          (
            'newUpdateAuthority',
            getNullableEncoder<Address>(getAddressEncoder()),
          ),
          ('data', getNullableEncoder<Data>(getDataEncoder())),
          (
            'primarySaleHappened',
            getNullableEncoder<bool>(getBooleanEncoder()),
          ),
          ('isMutable', getNullableEncoder<bool>(getBooleanEncoder())),
          ('collection', getCollectionToggleEncoder()),
          ('collectionDetails', getCollectionDetailsToggleEncoder()),
          ('uses', getUsesToggleEncoder()),
          ('ruleSet', getRuleSetToggleEncoder()),
          (
            'tokenStandard',
            getNullableEncoder<TokenStandard>(getTokenStandardEncoder()),
          ),
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
          (
            'newUpdateAuthority',
            getNullableEncoder<Address>(getAddressEncoder()),
          ),
          (
            'primarySaleHappened',
            getNullableEncoder<bool>(getBooleanEncoder()),
          ),
          ('isMutable', getNullableEncoder<bool>(getBooleanEncoder())),
          (
            'tokenStandard',
            getNullableEncoder<TokenStandard>(getTokenStandardEncoder()),
          ),
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
          ('collection', getCollectionToggleEncoder()),
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
          ('data', getNullableEncoder<Data>(getDataEncoder())),
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
          ('ruleSet', getRuleSetToggleEncoder()),
          (
            'authorizationData',
            getNullableEncoder<AuthorizationData>(
              getAuthorizationDataEncoder(),
            ),
          ),
        ]),
      ),
      (
        6,
        getStructEncoder([
          ('data', getNullableEncoder<Data>(getDataEncoder())),
          (
            'authorizationData',
            getNullableEncoder<AuthorizationData>(
              getAuthorizationDataEncoder(),
            ),
          ),
        ]),
      ),
      (
        7,
        getStructEncoder([
          ('collection', getCollectionToggleEncoder()),
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
          ('ruleSet', getRuleSetToggleEncoder()),
          (
            'authorizationData',
            getNullableEncoder<AuthorizationData>(
              getAuthorizationDataEncoder(),
            ),
          ),
        ]),
      ),
    ], size: getU8Encoder()),
    (UpdateArgs value) => switch (value) {
      UpdateArgsV1(
        newUpdateAuthority: final newUpdateAuthority,
        data: final data,
        primarySaleHappened: final primarySaleHappened,
        isMutable: final isMutable,
        collection: final collection,
        collectionDetails: final collectionDetails,
        uses: final uses,
        ruleSet: final ruleSet,
        authorizationData: final authorizationData,
      ) =>
        <String, Object?>{
          '__kind': 0,
          'newUpdateAuthority': newUpdateAuthority,
          'data': data,
          'primarySaleHappened': primarySaleHappened,
          'isMutable': isMutable,
          'collection': collection,
          'collectionDetails': collectionDetails,
          'uses': uses,
          'ruleSet': ruleSet,
          'authorizationData': authorizationData,
        },
      UpdateArgsAsUpdateAuthorityV2(
        newUpdateAuthority: final newUpdateAuthority,
        data: final data,
        primarySaleHappened: final primarySaleHappened,
        isMutable: final isMutable,
        collection: final collection,
        collectionDetails: final collectionDetails,
        uses: final uses,
        ruleSet: final ruleSet,
        tokenStandard: final tokenStandard,
        authorizationData: final authorizationData,
      ) =>
        <String, Object?>{
          '__kind': 1,
          'newUpdateAuthority': newUpdateAuthority,
          'data': data,
          'primarySaleHappened': primarySaleHappened,
          'isMutable': isMutable,
          'collection': collection,
          'collectionDetails': collectionDetails,
          'uses': uses,
          'ruleSet': ruleSet,
          'tokenStandard': tokenStandard,
          'authorizationData': authorizationData,
        },
      UpdateArgsAsAuthorityItemDelegateV2(
        newUpdateAuthority: final newUpdateAuthority,
        primarySaleHappened: final primarySaleHappened,
        isMutable: final isMutable,
        tokenStandard: final tokenStandard,
        authorizationData: final authorizationData,
      ) =>
        <String, Object?>{
          '__kind': 2,
          'newUpdateAuthority': newUpdateAuthority,
          'primarySaleHappened': primarySaleHappened,
          'isMutable': isMutable,
          'tokenStandard': tokenStandard,
          'authorizationData': authorizationData,
        },
      UpdateArgsAsCollectionDelegateV2(
        collection: final collection,
        authorizationData: final authorizationData,
      ) =>
        <String, Object?>{
          '__kind': 3,
          'collection': collection,
          'authorizationData': authorizationData,
        },
      UpdateArgsAsDataDelegateV2(
        data: final data,
        authorizationData: final authorizationData,
      ) =>
        <String, Object?>{
          '__kind': 4,
          'data': data,
          'authorizationData': authorizationData,
        },
      UpdateArgsAsProgrammableConfigDelegateV2(
        ruleSet: final ruleSet,
        authorizationData: final authorizationData,
      ) =>
        <String, Object?>{
          '__kind': 5,
          'ruleSet': ruleSet,
          'authorizationData': authorizationData,
        },
      UpdateArgsAsDataItemDelegateV2(
        data: final data,
        authorizationData: final authorizationData,
      ) =>
        <String, Object?>{
          '__kind': 6,
          'data': data,
          'authorizationData': authorizationData,
        },
      UpdateArgsAsCollectionItemDelegateV2(
        collection: final collection,
        authorizationData: final authorizationData,
      ) =>
        <String, Object?>{
          '__kind': 7,
          'collection': collection,
          'authorizationData': authorizationData,
        },
      UpdateArgsAsProgrammableConfigItemDelegateV2(
        ruleSet: final ruleSet,
        authorizationData: final authorizationData,
      ) =>
        <String, Object?>{
          '__kind': 8,
          'ruleSet': ruleSet,
          'authorizationData': authorizationData,
        },
    },
  );
}

Decoder<UpdateArgs> getUpdateArgsDecoder() {
  return transformDecoder<Map<String, Object?>, UpdateArgs>(
    getDiscriminatedUnionDecoder([
      (
        0,
        transformDecoder<Map<String, Object?>, Map<String, Object?>>(
          getStructDecoder([
            (
              'newUpdateAuthority',
              getNullableDecoder<Address>(getAddressDecoder()),
            ),
            ('data', getNullableDecoder<Data>(getDataDecoder())),
            (
              'primarySaleHappened',
              getNullableDecoder<bool>(getBooleanDecoder()),
            ),
            ('isMutable', getNullableDecoder<bool>(getBooleanDecoder())),
            ('collection', getCollectionToggleDecoder()),
            ('collectionDetails', getCollectionDetailsToggleDecoder()),
            ('uses', getUsesToggleDecoder()),
            ('ruleSet', getRuleSetToggleDecoder()),
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
            (
              'newUpdateAuthority',
              getNullableDecoder<Address>(getAddressDecoder()),
            ),
            ('data', getNullableDecoder<Data>(getDataDecoder())),
            (
              'primarySaleHappened',
              getNullableDecoder<bool>(getBooleanDecoder()),
            ),
            ('isMutable', getNullableDecoder<bool>(getBooleanDecoder())),
            ('collection', getCollectionToggleDecoder()),
            ('collectionDetails', getCollectionDetailsToggleDecoder()),
            ('uses', getUsesToggleDecoder()),
            ('ruleSet', getRuleSetToggleDecoder()),
            (
              'tokenStandard',
              getNullableDecoder<TokenStandard>(getTokenStandardDecoder()),
            ),
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
            (
              'newUpdateAuthority',
              getNullableDecoder<Address>(getAddressDecoder()),
            ),
            (
              'primarySaleHappened',
              getNullableDecoder<bool>(getBooleanDecoder()),
            ),
            ('isMutable', getNullableDecoder<bool>(getBooleanDecoder())),
            (
              'tokenStandard',
              getNullableDecoder<TokenStandard>(getTokenStandardDecoder()),
            ),
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
            ('collection', getCollectionToggleDecoder()),
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
            ('data', getNullableDecoder<Data>(getDataDecoder())),
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
            ('ruleSet', getRuleSetToggleDecoder()),
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
          getStructDecoder([
            ('data', getNullableDecoder<Data>(getDataDecoder())),
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
        7,
        transformDecoder<Map<String, Object?>, Map<String, Object?>>(
          getStructDecoder([
            ('collection', getCollectionToggleDecoder()),
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
            ('ruleSet', getRuleSetToggleDecoder()),
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
          return UpdateArgsV1(
            newUpdateAuthority: map['newUpdateAuthority'] as Address?,
            data: map['data'] as Data?,
            primarySaleHappened: map['primarySaleHappened'] as bool?,
            isMutable: map['isMutable'] as bool?,
            collection: map['collection']! as CollectionToggle,
            collectionDetails:
                map['collectionDetails']! as CollectionDetailsToggle,
            uses: map['uses']! as UsesToggle,
            ruleSet: map['ruleSet']! as RuleSetToggle,
            authorizationData: map['authorizationData'] as AuthorizationData?,
          );
        case 1:
          return UpdateArgsAsUpdateAuthorityV2(
            newUpdateAuthority: map['newUpdateAuthority'] as Address?,
            data: map['data'] as Data?,
            primarySaleHappened: map['primarySaleHappened'] as bool?,
            isMutable: map['isMutable'] as bool?,
            collection: map['collection']! as CollectionToggle,
            collectionDetails:
                map['collectionDetails']! as CollectionDetailsToggle,
            uses: map['uses']! as UsesToggle,
            ruleSet: map['ruleSet']! as RuleSetToggle,
            tokenStandard: map['tokenStandard'] as TokenStandard?,
            authorizationData: map['authorizationData'] as AuthorizationData?,
          );
        case 2:
          return UpdateArgsAsAuthorityItemDelegateV2(
            newUpdateAuthority: map['newUpdateAuthority'] as Address?,
            primarySaleHappened: map['primarySaleHappened'] as bool?,
            isMutable: map['isMutable'] as bool?,
            tokenStandard: map['tokenStandard'] as TokenStandard?,
            authorizationData: map['authorizationData'] as AuthorizationData?,
          );
        case 3:
          return UpdateArgsAsCollectionDelegateV2(
            collection: map['collection']! as CollectionToggle,
            authorizationData: map['authorizationData'] as AuthorizationData?,
          );
        case 4:
          return UpdateArgsAsDataDelegateV2(
            data: map['data'] as Data?,
            authorizationData: map['authorizationData'] as AuthorizationData?,
          );
        case 5:
          return UpdateArgsAsProgrammableConfigDelegateV2(
            ruleSet: map['ruleSet']! as RuleSetToggle,
            authorizationData: map['authorizationData'] as AuthorizationData?,
          );
        case 6:
          return UpdateArgsAsDataItemDelegateV2(
            data: map['data'] as Data?,
            authorizationData: map['authorizationData'] as AuthorizationData?,
          );
        case 7:
          return UpdateArgsAsCollectionItemDelegateV2(
            collection: map['collection']! as CollectionToggle,
            authorizationData: map['authorizationData'] as AuthorizationData?,
          );
        case 8:
          return UpdateArgsAsProgrammableConfigItemDelegateV2(
            ruleSet: map['ruleSet']! as RuleSetToggle,
            authorizationData: map['authorizationData'] as AuthorizationData?,
          );
      }
      throw StateError(
        'Unsupported UpdateArgs discriminator: ${map['__kind']}',
      );
    },
  );
}

Codec<UpdateArgs, UpdateArgs> getUpdateArgsCodec() {
  return combineCodec(getUpdateArgsEncoder(), getUpdateArgsDecoder());
}
