import 'dart:convert';
import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_sns/solana_kit_sns.dart';
import 'package:test/test.dart';

void main() {
  group('SnsRecord', () {
    test('covers all 28 TS SDK record keys', () {
      expect(SnsRecord.values.length, 28);
    });

    test('label values match the TypeScript enum', () {
      expect(SnsRecord.sol.label, 'SOL');
      expect(SnsRecord.url.label, 'url');
      expect(SnsRecord.twitter.label, 'twitter');
      expect(SnsRecord.ipfs.label, 'IPFS');
      expect(SnsRecord.aaaa.label, 'AAAA');
      expect(SnsRecord.bio.label, 'bio');
    });
  });

  group('record address derivation', () {
    // Cross-computed with @solana/web3.js mirroring getRecordV1Key /
    // getRecordV2Key from the TypeScript SDK.
    test('derives the V2 url record of bonfida', () async {
      final address = await findRecordV2Address(
        domain: 'bonfida',
        record: SnsRecord.url,
      );
      expect(
        address,
        const Address('EyXTEBK3xFkzkweB5PNR1zNjYchpyYyizunbdpcCEHVy'),
      );
    });

    test('derives the V1 url record of bonfida', () async {
      final address = await findRecordV1Address(
        domain: 'bonfida',
        record: SnsRecord.url,
      );
      expect(
        address,
        const Address('CvhvqcxBbA4UdWuJFDMuuC4XbpCrAd9gidpW5wxEsjg5'),
      );
    });

    test('derives the V2 SOL record of bonfida', () async {
      final address = await findRecordV2Address(
        domain: 'bonfida',
        record: SnsRecord.sol,
      );
      expect(
        address,
        const Address('ETARvCjLwjyM6Jux1ndxuXuYEYy56Nf5uvU3abL1WyW6'),
      );
    });

    test('derives the V2 url record of a subdomain', () async {
      final address = await findRecordV2Address(
        domain: 'a.bonfida',
        record: SnsRecord.url,
      );
      expect(
        address,
        const Address('Fwj5CpNUMqhfLe7tNM8NVz7MUDx3NoudxiSLqfxfAyjE'),
      );
    });
  });

  group('SnsValidation', () {
    test('identifier lengths follow SNS-IP 1', () {
      expect(SnsValidation.none.identifierLength, 0);
      expect(SnsValidation.ethereum.identifierLength, 20);
      expect(SnsValidation.solana.identifierLength, 32);
      expect(SnsValidation.unverifiedSolana.identifierLength, 32);
    });

    test('fromValue roundtrips the wire values', () {
      expect(SnsValidation.fromValue(0), SnsValidation.none);
      expect(SnsValidation.fromValue(1), SnsValidation.solana);
      expect(SnsValidation.fromValue(2), SnsValidation.ethereum);
      expect(SnsValidation.fromValue(3), SnsValidation.unverifiedSolana);
      expect(() => SnsValidation.fromValue(4), throwsArgumentError);
    });
  });

  group('SnsRecordHeader codec', () {
    test('roundtrips u16/u16/u32 little-endian fields', () {
      const header = SnsRecordHeader(
        stalenessValidation: SnsValidation.solana,
        rightOfAssociationValidation: SnsValidation.ethereum,
        contentLength: 5,
      );

      final encoded = getSnsRecordHeaderCodec().encode(header);
      expect(encoded.length, recordHeaderLength);
      expect(encoded, Uint8List.fromList([1, 0, 2, 0, 5, 0, 0, 0]));

      final decoded = getSnsRecordHeaderDecoder().decode(encoded);
      expect(decoded.stalenessValidation, SnsValidation.solana);
      expect(
        decoded.rightOfAssociationValidation,
        SnsValidation.ethereum,
      );
      expect(decoded.contentLength, 5);
    });
  });

  group('SnsRecordV2.deserialize', () {
    Uint8List buildRecordBytes(
      SnsRecordHeader header,
      Uint8List payload,
    ) {
      final bytes = Uint8List(
        recordDataOffset + recordHeaderLength + payload.length,
      );
      getSnsRecordHeaderEncoder().write(header, bytes, recordDataOffset);
      bytes.setAll(recordDataOffset + recordHeaderLength, payload);
      return bytes;
    }

    test('splits staleness id, RoA id and content', () {
      const header = SnsRecordHeader(
        stalenessValidation: SnsValidation.solana,
        rightOfAssociationValidation: SnsValidation.none,
        contentLength: 11,
      );
      final stalenessId = getAddressEncoder().encode(
        nameProgramAddressObject,
      );
      final content = utf8.encode('hello world');
      final bytes = buildRecordBytes(
        header,
        Uint8List.fromList([...stalenessId, ...content]),
      );

      final record = SnsRecordV2.deserialize(bytes);
      expect(record.header.stalenessValidation, SnsValidation.solana);
      expect(record.header.rightOfAssociationValidation, SnsValidation.none);
      expect(record.header.contentLength, 11);
      expect(record.stalenessId, stalenessId);
      expect(record.roaId, isEmpty);
      expect(record.content, content);
      expect(
        decodeRecordContent(content: record.content, record: SnsRecord.url),
        'hello world',
      );
    });

    test('rejects account data that is too short', () {
      expect(
        () => SnsRecordV2.deserialize(Uint8List(20)),
        throwsArgumentError,
      );
    });

    test('rejects a content length that exceeds the account data', () {
      const header = SnsRecordHeader(
        stalenessValidation: SnsValidation.none,
        rightOfAssociationValidation: SnsValidation.none,
        contentLength: 99,
      );
      // The TS SDK validates the length lazily on getContent(); the Dart
      // decoder mirrors that and only throws when the content is read.
      final record = SnsRecordV2.deserialize(
        buildRecordBytes(header, Uint8List(4)),
      );
      expect(record.header.contentLength, 99);
      expect(() => record.content, throwsArgumentError);
    });
  });

  group('record content (de)serialization', () {
    // Items taken from the TypeScript SDK's own record.test.ts.
    test('UTF-8 records roundtrip', () {
      for (final record in [
        SnsRecord.txt,
        SnsRecord.cname,
        SnsRecord.discord,
        SnsRecord.github,
      ]) {
        expect(
          encodeRecordContent(content: 'this is a test', record: record),
          Uint8List.fromList(utf8.encode('this is a test')),
        );
      }
    });

    test('SOL records roundtrip a base58 wallet address', () {
      const wallet = 'GtEGr7hhAqt53JbGrQNgWY2rrHHtNSj4aNquNqaDPaUH';
      final encoded = encodeRecordContent(
        content: wallet,
        record: SnsRecord.sol,
      );
      expect(encoded.length, 32);
      expect(
        decodeRecordContent(content: encoded, record: SnsRecord.sol),
        wallet,
      );
    });

    test('EVM records render as 0x-prefixed hex', () {
      const hex = '0xc0ffee254729296a45a3885639ac7e10f9d54979';
      final encoded = encodeRecordContent(
        content: hex,
        record: SnsRecord.eth,
      );
      expect(encoded.length, 20);
      expect(
        decodeRecordContent(content: encoded, record: SnsRecord.eth),
        hex,
      );
    });

    test('rejects EVM content that is not a 20-byte address', () {
      expect(
        () => encodeRecordContent(
          content: '0x1234',
          record: SnsRecord.eth,
        ),
        throwsArgumentError,
      );
      expect(
        () => decodeRecordContent(
          content: Uint8List(19),
          record: SnsRecord.eth,
        ),
        throwsArgumentError,
      );
    });

    test('rejects unsupported record types', () {
      expect(
        () => decodeRecordContent(
          content: Uint8List(20),
          record: SnsRecord.injective,
        ),
        throwsArgumentError,
      );
      expect(
        () => encodeRecordContent(
          content: '1.1.1.4',
          record: SnsRecord.a,
        ),
        throwsArgumentError,
      );
    });
  });
}
