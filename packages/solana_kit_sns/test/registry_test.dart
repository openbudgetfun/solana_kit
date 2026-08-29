import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_sns/solana_kit_sns.dart';
import 'package:test/test.dart';

void main() {
  const parentAddress = snsRootDomainAddressObject;
  const ownerAddress = nameProgramAddressObject;
  const classAddress = reverseLookupClassAddressObject;

  final parentBytes = getAddressEncoder().encode(parentAddress);
  final ownerBytes = getAddressEncoder().encode(ownerAddress);
  final classBytes = getAddressEncoder().encode(classAddress);
  final data = Uint8List.fromList('hello'.codeUnits);

  Uint8List buildRegistryBytes(Uint8List payload) {
    final bytes = Uint8List(nameRegistryHeaderLength + payload.length)
      ..setAll(0, parentBytes)
      ..setAll(32, ownerBytes)
      ..setAll(64, classBytes)
      ..setAll(nameRegistryHeaderLength, payload);
    return bytes;
  }

  group('getNameRegistryStateDecoder', () {
    test('header length is 96 bytes', () {
      expect(nameRegistryHeaderLength, 96);
    });

    test('decodes parent, owner, class and data from raw bytes', () {
      final bytes = buildRegistryBytes(data);
      expect(bytes.length, 101);

      final state = getNameRegistryStateDecoder().decode(bytes);
      expect(state.parentName, parentAddress);
      expect(state.owner, ownerAddress);
      expect(state.registryClass, classAddress);
      expect(state.data, data);
      expect(state.hasData, isTrue);
    });

    test('decodes an account without data', () {
      final state = getNameRegistryStateDecoder().decode(
        buildRegistryBytes(
          Uint8List(0),
        ),
      );
      expect(state.parentName, parentAddress);
      expect(state.owner, ownerAddress);
      expect(state.registryClass, classAddress);
      expect(state.data, isEmpty);
      expect(state.hasData, isFalse);
    });

    test('decodes a zero-class top-level-domain registry', () {
      final bytes = Uint8List(96)
        ..setAll(0, parentBytes)
        ..setAll(32, ownerBytes);
      final state = getNameRegistryStateDecoder().decode(bytes);
      expect(
        state.registryClass,
        const Address('11111111111111111111111111111111'),
      );
      expect(state.data, isEmpty);
    });
  });

  group('getNameRegistryStateCodec roundtrip', () {
    test('encode → decode preserves the state', () {
      final codec = getNameRegistryStateCodec();
      final state = NameRegistryState(
        parentName: parentAddress,
        owner: ownerAddress,
        registryClass: classAddress,
        data: data,
      );

      final encoded = codec.encode(state);
      expect(encoded.length, nameRegistryHeaderLength + data.length);
      expect(codec.decode(encoded).parentName, parentAddress);
      expect(codec.decode(encoded).owner, ownerAddress);
      expect(codec.decode(encoded).registryClass, classAddress);
      expect(codec.decode(encoded).data, data);
    });

    test('encoded header matches the raw on-wire layout', () {
      final state = NameRegistryState(
        parentName: parentAddress,
        owner: ownerAddress,
        registryClass: classAddress,
        data: data,
      );

      final encoded = getNameRegistryStateEncoder().encode(state);
      expect(encoded.sublist(0, 32), parentBytes);
      expect(encoded.sublist(32, 64), ownerBytes);
      expect(encoded.sublist(64, 96), classBytes);
      expect(encoded.sublist(96), data);
    });
  });

  group('NameRegistryState', () {
    test('defaults data to an empty list when omitted', () {
      final state = NameRegistryState(
        parentName: parentAddress,
        owner: ownerAddress,
        registryClass: classAddress,
      );

      expect(state.data, isEmpty);
      expect(state.hasData, isFalse);
    });
  });

  group('getNameValueCodec', () {
    test('u32 little-endian length prefix followed by UTF-8 bytes', () {
      expect(
        encodeNameValue('abc'),
        Uint8List.fromList([3, 0, 0, 0, 97, 98, 99]),
      );
    });

    test('roundtrips plain, NUL-prefixed and multi-byte names', () {
      for (final value in ['bonfida', '\u0000dex', 'Ø', '']) {
        expect(decodeNameValue(encodeNameValue(value)), value);
      }
    });

    test('encodes an empty value as just the length prefix', () {
      expect(encodeNameValue(''), Uint8List.fromList([0, 0, 0, 0]));
    });

    test('rejects a length that exceeds the available bytes', () {
      expect(
        () => decodeNameValue(Uint8List.fromList([9, 0, 0, 0, 97])),
        throwsArgumentError,
      );
    });
  });
}
