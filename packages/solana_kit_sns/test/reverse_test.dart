import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_sns/solana_kit_sns.dart';
import 'package:test/test.dart';

void main() {
  group('reverse derivations', () {
    // Cross-computed with @solana/web3.js mirroring
    // getReverseAddressFromDomainAddress from the TypeScript SDK.
    test('derives the reverse account of bonfida', () async {
      final domainKey = await findDomainKey('bonfida');
      final address = await findReverseAddress(
        domainAddress: domainKey.address,
      );
      expect(
        address,
        const Address('DqgmWxe2PPrfy45Ja3UPyFGwcbRzkRuwXt3NyxjX8krg'),
      );
    });

    test('derives the reverse account of a subdomain with parent', () async {
      final domainKey = await findDomainKey('a.bonfida');
      final address = await findReverseAddress(
        domainAddress: domainKey.address,
        parentAddress: domainKey.parentAddress,
      );
      expect(
        address,
        const Address('rixHffj1oxKRGCB1MULj2BPEGL9Ac2VRhZdrjL91Evw'),
      );
    });

    test('findReverseAddressForDomain matches the domain-key path', () async {
      final fromDomain = await findReverseAddressForDomain('a.bonfida');
      final domainKey = await findDomainKey('a.bonfida');
      final fromKey = await findReverseAddress(
        domainAddress: domainKey.address,
        parentAddress: domainKey.parentAddress,
      );
      expect(fromDomain, fromKey);
      expect(
        fromDomain,
        const Address('rixHffj1oxKRGCB1MULj2BPEGL9Ac2VRhZdrjL91Evw'),
      );
    });
  });

  group('reverse values', () {
    test('encodes a NUL marker for subdomain values', () {
      final encoded = encodeReverseValue('dex', isSubdomain: true);
      // u32 length prefix (4) + NUL marker (1) + 'dex' (3).
      expect(encoded, Uint8List.fromList([4, 0, 0, 0, 0, 100, 101, 120]));
    });

    test('preserves the NUL marker unless trimming is requested', () {
      final encoded = encodeReverseValue('dex', isSubdomain: true);
      expect(decodeReverseValue(encoded), '\u0000dex');
      expect(decodeReverseValue(encoded, trimLeadingNullByte: true), 'dex');
    });

    test('roundtrips a plain value', () {
      final encoded = encodeReverseValue('bonfida');
      expect(decodeReverseValue(encoded), 'bonfida');
    });

    test('decode tolerates an empty value', () {
      expect(decodeReverseValue(encodeNameValue('')), '');
    });
  });
}
