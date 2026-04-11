
import 'package:solana_kit_compute_budget/solana_kit_compute_budget.dart';
import 'package:test/test.dart';

void main() {
  group('SetComputeUnitLimit', () {
    test('encode/decode round-trips', () {
      const original = SetComputeUnitLimitInstructionData(units: 400000);
      final codec = getSetComputeUnitLimitInstructionDataCodec();
      final encoded = codec.encode(original);
      final decoded = codec.decode(encoded);
      expect(decoded, equals(original));
      expect(decoded.discriminator, equals(setComputeUnitLimitDiscriminator));
      expect(decoded.units, equals(400000));
    });

    test('encodes discriminator 2 at offset 0', () {
      final encoder = getSetComputeUnitLimitInstructionDataEncoder();
      final bytes = encoder.encode(
        const SetComputeUnitLimitInstructionData(units: 1),
      );
      expect(bytes[0], equals(2));
    });

    test('encodes units as little-endian u32', () {
      final encoder = getSetComputeUnitLimitInstructionDataEncoder();
      final bytes = encoder.encode(
        const SetComputeUnitLimitInstructionData(units: 0x01020304),
      );
      // discriminator(1) + u32 LE
      expect(bytes.length, equals(5));
      expect(bytes[1], equals(0x04));
      expect(bytes[2], equals(0x03));
      expect(bytes[3], equals(0x02));
      expect(bytes[4], equals(0x01));
    });

    test('instruction builder produces correct data', () {
      final ix = getSetComputeUnitLimitInstruction(units: 200000);
      expect(ix.programAddress, equals(computeBudgetProgramAddress));
      expect(ix.accounts, isEmpty);

      final parsed = parseSetComputeUnitLimitInstruction(ix);
      expect(parsed.units, equals(200000));
      expect(parsed.discriminator, equals(2));
    });

    test('value equality', () {
      const a = SetComputeUnitLimitInstructionData(units: 100);
      const b = SetComputeUnitLimitInstructionData(units: 100);
      const c = SetComputeUnitLimitInstructionData(units: 200);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
    });

    test('toString includes field values', () {
      const data = SetComputeUnitLimitInstructionData(units: 42);
      final str = data.toString();
      expect(str, contains('units: 42'));
      expect(str, contains('discriminator: 2'));
    });
  });

  group('SetComputeUnitPrice', () {
    test('encode/decode round-trips', () {
      final original = SetComputeUnitPriceInstructionData(
        microLamports: BigInt.from(50000),
      );
      final codec = getSetComputeUnitPriceInstructionDataCodec();
      final encoded = codec.encode(original);
      final decoded = codec.decode(encoded);
      expect(decoded, equals(original));
      expect(decoded.discriminator, equals(setComputeUnitPriceDiscriminator));
      expect(decoded.microLamports, equals(BigInt.from(50000)));
    });

    test('encodes discriminator 3 at offset 0', () {
      final encoder = getSetComputeUnitPriceInstructionDataEncoder();
      final bytes = encoder.encode(
        SetComputeUnitPriceInstructionData(microLamports: BigInt.zero),
      );
      expect(bytes[0], equals(3));
    });

    test('encodes microLamports as little-endian u64', () {
      final encoder = getSetComputeUnitPriceInstructionDataEncoder();
      final bytes = encoder.encode(
        SetComputeUnitPriceInstructionData(microLamports: BigInt.one),
      );
      // discriminator(1) + u64 LE(8) = 9
      expect(bytes.length, equals(9));
      expect(bytes[1], equals(1));
      for (var i = 2; i < 9; i++) {
        expect(bytes[i], equals(0));
      }
    });

    test('handles large u64 values', () {
      // max u64
      final maxU64 = BigInt.parse('18446744073709551615');
      final codec = getSetComputeUnitPriceInstructionDataCodec();
      final data = SetComputeUnitPriceInstructionData(
        microLamports: maxU64,
      );
      final decoded = codec.decode(codec.encode(data));
      expect(decoded.microLamports, equals(maxU64));
    });

    test('instruction builder produces correct data', () {
      final ix = getSetComputeUnitPriceInstruction(
        microLamports: BigInt.from(1000),
      );
      expect(ix.programAddress, equals(computeBudgetProgramAddress));
      expect(ix.accounts, isEmpty);

      final parsed = parseSetComputeUnitPriceInstruction(ix);
      expect(parsed.microLamports, equals(BigInt.from(1000)));
      expect(parsed.discriminator, equals(3));
    });

    test('value equality', () {
      final a = SetComputeUnitPriceInstructionData(
        microLamports: BigInt.from(100),
      );
      final b = SetComputeUnitPriceInstructionData(
        microLamports: BigInt.from(100),
      );
      final c = SetComputeUnitPriceInstructionData(
        microLamports: BigInt.from(200),
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
    });
  });

  group('RequestHeapFrame', () {
    test('encode/decode round-trips', () {
      const original = RequestHeapFrameInstructionData(bytes: 262144);
      final codec = getRequestHeapFrameInstructionDataCodec();
      final encoded = codec.encode(original);
      final decoded = codec.decode(encoded);
      expect(decoded, equals(original));
      expect(decoded.discriminator, equals(requestHeapFrameDiscriminator));
      expect(decoded.bytes, equals(262144));
    });

    test('encodes discriminator 1 at offset 0', () {
      final encoder = getRequestHeapFrameInstructionDataEncoder();
      final bytes = encoder.encode(
        const RequestHeapFrameInstructionData(bytes: 1024),
      );
      expect(bytes[0], equals(1));
    });

    test('instruction builder produces correct data', () {
      final ix = getRequestHeapFrameInstruction(bytes: 32768);
      expect(ix.programAddress, equals(computeBudgetProgramAddress));
      expect(ix.accounts, isEmpty);

      final parsed = parseRequestHeapFrameInstruction(ix);
      expect(parsed.bytes, equals(32768));
    });

    test('value equality', () {
      const a = RequestHeapFrameInstructionData(bytes: 1024);
      const b = RequestHeapFrameInstructionData(bytes: 1024);
      const c = RequestHeapFrameInstructionData(bytes: 2048);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
    });
  });

  group('RequestUnits (deprecated)', () {
    test('encode/decode round-trips', () {
      const original = RequestUnitsInstructionData(
        units: 1400000,
        additionalFee: 5000,
      );
      final codec = getRequestUnitsInstructionDataCodec();
      final encoded = codec.encode(original);
      final decoded = codec.decode(encoded);
      expect(decoded, equals(original));
      expect(decoded.discriminator, equals(requestUnitsDiscriminator));
      expect(decoded.units, equals(1400000));
      expect(decoded.additionalFee, equals(5000));
    });

    test('encodes discriminator 0 at offset 0', () {
      final encoder = getRequestUnitsInstructionDataEncoder();
      final bytes = encoder.encode(
        const RequestUnitsInstructionData(units: 100, additionalFee: 0),
      );
      expect(bytes[0], equals(0));
    });

    test('encodes units and additionalFee as u32', () {
      final encoder = getRequestUnitsInstructionDataEncoder();
      final bytes = encoder.encode(
        const RequestUnitsInstructionData(units: 100, additionalFee: 200),
      );
      // discriminator(1) + units(4) + additionalFee(4) = 9
      expect(bytes.length, equals(9));
    });

    test('value equality', () {
      const a = RequestUnitsInstructionData(units: 100, additionalFee: 50);
      const b = RequestUnitsInstructionData(units: 100, additionalFee: 50);
      const c = RequestUnitsInstructionData(units: 100, additionalFee: 99);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
    });
  });

  group('SetLoadedAccountsDataSizeLimit', () {
    test('encode/decode round-trips', () {
      const original = SetLoadedAccountsDataSizeLimitInstructionData(
        accountDataSizeLimit: 65536,
      );
      final codec = getSetLoadedAccountsDataSizeLimitInstructionDataCodec();
      final encoded = codec.encode(original);
      final decoded = codec.decode(encoded);
      expect(decoded, equals(original));
      expect(
        decoded.discriminator,
        equals(setLoadedAccountsDataSizeLimitDiscriminator),
      );
      expect(decoded.accountDataSizeLimit, equals(65536));
    });

    test('encodes discriminator 4 at offset 0', () {
      final encoder =
          getSetLoadedAccountsDataSizeLimitInstructionDataEncoder();
      final bytes = encoder.encode(
        const SetLoadedAccountsDataSizeLimitInstructionData(
          accountDataSizeLimit: 100,
        ),
      );
      expect(bytes[0], equals(4));
    });

    test('instruction builder produces correct data', () {
      final ix = getSetLoadedAccountsDataSizeLimitInstruction(
        accountDataSizeLimit: 128000,
      );
      expect(ix.programAddress, equals(computeBudgetProgramAddress));
      expect(ix.accounts, isEmpty);

      final parsed = parseSetLoadedAccountsDataSizeLimitInstruction(ix);
      expect(parsed.accountDataSizeLimit, equals(128000));
    });

    test('value equality', () {
      const a = SetLoadedAccountsDataSizeLimitInstructionData(
        accountDataSizeLimit: 100,
      );
      const b = SetLoadedAccountsDataSizeLimitInstructionData(
        accountDataSizeLimit: 100,
      );
      const c = SetLoadedAccountsDataSizeLimitInstructionData(
        accountDataSizeLimit: 200,
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
    });
  });
}
