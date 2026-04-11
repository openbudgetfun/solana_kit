import 'package:solana_kit_address_lookup_table/solana_kit_address_lookup_table.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:test/test.dart';

void main() {
  group('CreateLookupTable', () {
    test('encode/decode round-trips', () {
      final original = CreateLookupTableInstructionData(
        recentSlot: BigInt.from(123456789),
        bump: 255,
      );
      final codec = getCreateLookupTableInstructionDataCodec();
      final encoded = codec.encode(original);
      final decoded = codec.decode(encoded);
      expect(decoded, equals(original));
      expect(decoded.discriminator, equals(createLookupTableDiscriminator));
      expect(decoded.recentSlot, equals(BigInt.from(123456789)));
      expect(decoded.bump, equals(255));
    });

    test('encodes discriminator 0 as u32 LE at offset 0', () {
      final encoder = getCreateLookupTableInstructionDataEncoder();
      final bytes = encoder.encode(
        CreateLookupTableInstructionData(
          recentSlot: BigInt.zero,
          bump: 0,
        ),
      );
      // u32 LE discriminator: 0x00 0x00 0x00 0x00
      expect(bytes[0], equals(0));
      expect(bytes[1], equals(0));
      expect(bytes[2], equals(0));
      expect(bytes[3], equals(0));
    });

    test('encodes recentSlot as little-endian u64', () {
      final encoder = getCreateLookupTableInstructionDataEncoder();
      final bytes = encoder.encode(
        CreateLookupTableInstructionData(
          recentSlot: BigInt.one,
          bump: 0,
        ),
      );
      // discriminator(4) + u64 LE(8) + bump(1) = 13
      expect(bytes.length, equals(13));
      expect(bytes[4], equals(1));
      for (var i = 5; i < 12; i++) {
        expect(bytes[i], equals(0));
      }
    });

    test('instruction builder produces correct data and accounts', () {
      const tableAddr = Address('Tab1eLookupTab1e111111111111111111111111111');
      const authority = Address('Auth111111111111111111111111111111111111111');
      const payer = Address('Payer11111111111111111111111111111111111111');

      final ix = getCreateLookupTableInstruction(
        address: tableAddr,
        authority: authority,
        payer: payer,
        recentSlot: BigInt.from(42),
        bump: 254,
      );
      expect(ix.programAddress, equals(addressLookupTableProgramAddress));
      expect(ix.accounts, hasLength(4));
      expect(ix.accounts![0].address, equals(tableAddr));
      expect(ix.accounts![1].address, equals(authority));
      expect(ix.accounts![2].address, equals(payer));

      final parsed = parseCreateLookupTableInstruction(ix);
      expect(parsed.recentSlot, equals(BigInt.from(42)));
      expect(parsed.bump, equals(254));
      expect(parsed.discriminator, equals(0));
    });

    test('value equality', () {
      final a = CreateLookupTableInstructionData(
        recentSlot: BigInt.from(100),
        bump: 1,
      );
      final b = CreateLookupTableInstructionData(
        recentSlot: BigInt.from(100),
        bump: 1,
      );
      final c = CreateLookupTableInstructionData(
        recentSlot: BigInt.from(200),
        bump: 1,
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
    });

    test('toString includes field values', () {
      final data = CreateLookupTableInstructionData(
        recentSlot: BigInt.from(42),
        bump: 7,
      );
      final str = data.toString();
      expect(str, contains('recentSlot: 42'));
      expect(str, contains('bump: 7'));
      expect(str, contains('discriminator: 0'));
    });
  });

  group('FreezeLookupTable', () {
    test('encode/decode round-trips', () {
      const original = FreezeLookupTableInstructionData();
      final codec = getFreezeLookupTableInstructionDataCodec();
      final encoded = codec.encode(original);
      final decoded = codec.decode(encoded);
      expect(decoded, equals(original));
      expect(decoded.discriminator, equals(freezeLookupTableDiscriminator));
    });

    test('encodes discriminator 1 as u32 LE', () {
      final encoder = getFreezeLookupTableInstructionDataEncoder();
      final bytes = encoder.encode(const FreezeLookupTableInstructionData());
      expect(bytes.length, equals(4));
      expect(bytes[0], equals(1));
      expect(bytes[1], equals(0));
      expect(bytes[2], equals(0));
      expect(bytes[3], equals(0));
    });

    test('instruction builder produces correct data and accounts', () {
      const tableAddr = Address('Tab1eLookupTab1e111111111111111111111111111');
      const authority = Address('Auth111111111111111111111111111111111111111');

      final ix = getFreezeLookupTableInstruction(
        address: tableAddr,
        authority: authority,
      );
      expect(ix.programAddress, equals(addressLookupTableProgramAddress));
      expect(ix.accounts, hasLength(2));
      expect(ix.accounts![0].address, equals(tableAddr));
      expect(ix.accounts![1].address, equals(authority));

      final parsed = parseFreezeLookupTableInstruction(ix);
      expect(parsed.discriminator, equals(1));
    });

    test('value equality', () {
      const a = FreezeLookupTableInstructionData();
      const b = FreezeLookupTableInstructionData();
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });

  group('ExtendLookupTable', () {
    test('encode/decode round-trips', () {
      const addr1 = Address('11111111111111111111111111111111');
      const addr2 = Address('TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA');
      const original = ExtendLookupTableInstructionData(
        addresses: [addr1, addr2],
      );
      final codec = getExtendLookupTableInstructionDataCodec();
      final encoded = codec.encode(original);
      final decoded = codec.decode(encoded);
      expect(decoded, equals(original));
      expect(decoded.discriminator, equals(extendLookupTableDiscriminator));
      expect(decoded.addresses, hasLength(2));
      expect(decoded.addresses[0], equals(addr1));
      expect(decoded.addresses[1], equals(addr2));
    });

    test('encodes discriminator 2 as u32 LE', () {
      final encoder = getExtendLookupTableInstructionDataEncoder();
      final bytes = encoder.encode(
        const ExtendLookupTableInstructionData(addresses: []),
      );
      expect(bytes[0], equals(2));
      expect(bytes[1], equals(0));
      expect(bytes[2], equals(0));
      expect(bytes[3], equals(0));
    });

    test('encodes address count as u64 LE prefix', () {
      const addr = Address('11111111111111111111111111111111');
      final encoder = getExtendLookupTableInstructionDataEncoder();
      final bytes = encoder.encode(
        const ExtendLookupTableInstructionData(addresses: [addr, addr]),
      );
      // discriminator(4) + count u64(8) + 2 * address(32) = 76
      expect(bytes.length, equals(76));
      // count = 2 as u64 LE
      expect(bytes[4], equals(2));
      for (var i = 5; i < 12; i++) {
        expect(bytes[i], equals(0));
      }
    });

    test('instruction builder produces correct data and accounts', () {
      const tableAddr = Address('Tab1eLookupTab1e111111111111111111111111111');
      const authority = Address('Auth111111111111111111111111111111111111111');
      const payer = Address('Payer11111111111111111111111111111111111111');
      const addr1 = Address('11111111111111111111111111111111');

      final ix = getExtendLookupTableInstruction(
        address: tableAddr,
        authority: authority,
        payer: payer,
        addresses: [addr1],
      );
      expect(ix.programAddress, equals(addressLookupTableProgramAddress));
      expect(ix.accounts, hasLength(4));
      expect(ix.accounts![0].address, equals(tableAddr));
      expect(ix.accounts![1].address, equals(authority));
      expect(ix.accounts![2].address, equals(payer));

      final parsed = parseExtendLookupTableInstruction(ix);
      expect(parsed.addresses, hasLength(1));
      expect(parsed.addresses[0], equals(addr1));
    });

    test('handles empty addresses list', () {
      final codec = getExtendLookupTableInstructionDataCodec();
      const data = ExtendLookupTableInstructionData(addresses: []);
      final decoded = codec.decode(codec.encode(data));
      expect(decoded.addresses, isEmpty);
    });

    test('value equality', () {
      const addr = Address('11111111111111111111111111111111');
      const a = ExtendLookupTableInstructionData(addresses: [addr]);
      const b = ExtendLookupTableInstructionData(addresses: [addr]);
      const c = ExtendLookupTableInstructionData(addresses: []);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
    });
  });

  group('DeactivateLookupTable', () {
    test('encode/decode round-trips', () {
      const original = DeactivateLookupTableInstructionData();
      final codec = getDeactivateLookupTableInstructionDataCodec();
      final encoded = codec.encode(original);
      final decoded = codec.decode(encoded);
      expect(decoded, equals(original));
      expect(
        decoded.discriminator,
        equals(deactivateLookupTableDiscriminator),
      );
    });

    test('encodes discriminator 3 as u32 LE', () {
      final encoder = getDeactivateLookupTableInstructionDataEncoder();
      final bytes = encoder.encode(
        const DeactivateLookupTableInstructionData(),
      );
      expect(bytes.length, equals(4));
      expect(bytes[0], equals(3));
      expect(bytes[1], equals(0));
      expect(bytes[2], equals(0));
      expect(bytes[3], equals(0));
    });

    test('instruction builder produces correct data and accounts', () {
      const tableAddr = Address('Tab1eLookupTab1e111111111111111111111111111');
      const authority = Address('Auth111111111111111111111111111111111111111');

      final ix = getDeactivateLookupTableInstruction(
        address: tableAddr,
        authority: authority,
      );
      expect(ix.programAddress, equals(addressLookupTableProgramAddress));
      expect(ix.accounts, hasLength(2));
      expect(ix.accounts![0].address, equals(tableAddr));
      expect(ix.accounts![1].address, equals(authority));

      final parsed = parseDeactivateLookupTableInstruction(ix);
      expect(parsed.discriminator, equals(3));
    });

    test('value equality', () {
      const a = DeactivateLookupTableInstructionData();
      const b = DeactivateLookupTableInstructionData();
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });

  group('CloseLookupTable', () {
    test('encode/decode round-trips', () {
      const original = CloseLookupTableInstructionData();
      final codec = getCloseLookupTableInstructionDataCodec();
      final encoded = codec.encode(original);
      final decoded = codec.decode(encoded);
      expect(decoded, equals(original));
      expect(decoded.discriminator, equals(closeLookupTableDiscriminator));
    });

    test('encodes discriminator 4 as u32 LE', () {
      final encoder = getCloseLookupTableInstructionDataEncoder();
      final bytes = encoder.encode(
        const CloseLookupTableInstructionData(),
      );
      expect(bytes.length, equals(4));
      expect(bytes[0], equals(4));
      expect(bytes[1], equals(0));
      expect(bytes[2], equals(0));
      expect(bytes[3], equals(0));
    });

    test('instruction builder produces correct data and accounts', () {
      const tableAddr = Address('Tab1eLookupTab1e111111111111111111111111111');
      const authority = Address('Auth111111111111111111111111111111111111111');
      const recipient = Address('Recip11111111111111111111111111111111111111');

      final ix = getCloseLookupTableInstruction(
        address: tableAddr,
        authority: authority,
        recipient: recipient,
      );
      expect(ix.programAddress, equals(addressLookupTableProgramAddress));
      expect(ix.accounts, hasLength(3));
      expect(ix.accounts![0].address, equals(tableAddr));
      expect(ix.accounts![1].address, equals(authority));
      expect(ix.accounts![2].address, equals(recipient));

      final parsed = parseCloseLookupTableInstruction(ix);
      expect(parsed.discriminator, equals(4));
    });

    test('value equality', () {
      const a = CloseLookupTableInstructionData();
      const b = CloseLookupTableInstructionData();
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });
}
