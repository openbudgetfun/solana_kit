import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_sns/solana_kit_sns.dart';
import 'package:test/test.dart';

String _hex(Uint8List bytes) =>
    bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

void main() {
  group('findDomainKey', () {
    // Expected values from the TypeScript SDK's own test suite
    // (js/tests/sns/derivation.test.ts and js-kit/tests/sns/domain.test.ts)
    // plus vectors cross-computed with @solana/web3.js mirroring
    // getSnsDomainKeySync.
    test('derives the well-known bonfida.sol account', () async {
      final key = await findDomainKey('bonfida');
      expect(
        key.address,
        const Address('Crf8hzfthWGbGbLTVCiqRqV5MVnbpHB1L9KQMd6gsinb'),
      );
      expect(key.isSub, isFalse);
      expect(key.isSubRecord, isFalse);
      expect(key.parentAddress, isNull);
      expect(
        _hex(key.hash),
        '8ee2d25c3d2b2a83a1fc209b90377aed03dc2539e8e238355edda8d1b2edab98',
      );
    });

    test('derives the dex.bonfida.sol subdomain', () async {
      final key = await findDomainKey('dex.bonfida');
      expect(
        key.address,
        const Address('HoFfFXqFHAC8RP3duuQNzag1ieUwJRBv1HtRNiWFq4Qu'),
      );
      expect(key.isSub, isTrue);
      expect(key.isSubRecord, isFalse);
      expect(
        key.parentAddress,
        const Address('Crf8hzfthWGbGbLTVCiqRqV5MVnbpHB1L9KQMd6gsinb'),
      );
    });

    test('derives the sns-ip-5-wallet-1 account', () async {
      final key = await findDomainKey('sns-ip-5-wallet-1');
      expect(
        key.address,
        const Address('6qJtQdAJvAiSfGXWAuHDteAes6vnFcxtHmLzw1TStCrd'),
      );
      expect(key.isSub, isFalse);
    });

    test('derives the test.sns-ip-5-wallet-1 subdomain', () async {
      final key = await findDomainKey('test.sns-ip-5-wallet-1');
      expect(
        key.address,
        const Address('EzQAeEBXpZWpsZXcZRwV63RRr2RkwBVqdYN53tcbTDEm'),
      );
      expect(key.isSub, isTrue);
      expect(
        key.parentAddress,
        const Address('6qJtQdAJvAiSfGXWAuHDteAes6vnFcxtHmLzw1TStCrd'),
      );
    });

    test('derives a subdomain with multi-byte UTF-8 label', () async {
      final key = await findDomainKey('Ø.bonfida');
      expect(
        key.address,
        const Address('9Cw7FSkJ1rNm4zZ7VBKA51daxj5QRpTempjmoZU19yk'),
      );
    });

    test('derives a.bonfida with the domain as parent', () async {
      final key = await findDomainKey('a.bonfida');
      expect(
        key.address,
        const Address('HiFDXbqhRcgUzbzHftzvrGvDwNW9BWZZjtXu1gJAhUpr'),
      );
      expect(key.isSub, isTrue);
    });

    test('derives the V2 url record of bonfida', () async {
      final key = await findDomainKey(
        'url.bonfida',
        record: SnsRecordVersion.v2,
      );
      expect(
        key.address,
        const Address('EyXTEBK3xFkzkweB5PNR1zNjYchpyYyizunbdpcCEHVy'),
      );
      expect(key.isSub, isTrue);
      expect(key.isSubRecord, isFalse);
      expect(
        key.parentAddress,
        const Address('Crf8hzfthWGbGbLTVCiqRqV5MVnbpHB1L9KQMd6gsinb'),
      );
    });

    test('derives the V1 url record of bonfida', () async {
      final key = await findDomainKey(
        'url.bonfida',
        record: SnsRecordVersion.v1,
      );
      expect(
        key.address,
        const Address('CvhvqcxBbA4UdWuJFDMuuC4XbpCrAd9gidpW5wxEsjg5'),
      );
    });

    test('derives the V2 SOL record of bonfida', () async {
      final key = await findDomainKey(
        'SOL.bonfida',
        record: SnsRecordVersion.v2,
      );
      expect(
        key.address,
        const Address('ETARvCjLwjyM6Jux1ndxuXuYEYy56Nf5uvU3abL1WyW6'),
      );
    });

    test('derives the V1 SOL record of bonfida', () async {
      final key = await findDomainKey(
        'SOL.bonfida',
        record: SnsRecordVersion.v1,
      );
      expect(
        key.address,
        const Address('5WCZ6uhXPXJ7UrzBvXBnE9biZykq1ezJ6JhYe6CHgA7d'),
      );
    });

    test('derives the V2 twitter record of bonfida', () async {
      final key = await findDomainKey(
        'twitter.bonfida',
        record: SnsRecordVersion.v2,
      );
      expect(
        key.address,
        const Address('5tmb9sJ8pcRSAEu8mWQgLf2BAQ8eYmYh3W6sy2iqkfen'),
      );
    });

    test('derives the V2 url sub-record of a.bonfida', () async {
      final key = await findDomainKey(
        'url.a.bonfida',
        record: SnsRecordVersion.v2,
      );
      expect(
        key.address,
        const Address('Fwj5CpNUMqhfLe7tNM8NVz7MUDx3NoudxiSLqfxfAyjE'),
      );
      expect(key.isSubRecord, isTrue);
      expect(key.isSub, isTrue);
    });

    test('derives the V1 url sub-record of a.bonfida', () async {
      final key = await findDomainKey(
        'url.a.bonfida',
        record: SnsRecordVersion.v1,
      );
      expect(
        key.address,
        const Address('6Ck3zGPYfWuGv3CisTRW7AHm7ALQdWYSdK2pVSQTi96Q'),
      );
      expect(key.isSubRecord, isTrue);
    });

    test('findRecordV2Address agrees with the sub-record derivation', () async {
      final viaRecord = await findRecordV2Address(
        domain: 'a.bonfida',
        record: SnsRecord.url,
      );
      final viaDomainKey = await findDomainKey(
        'url.a.bonfida',
        record: SnsRecordVersion.v2,
      );
      expect(viaRecord, viaDomainKey.address);
    });

    test('record version prefixes are the protocol bytes', () {
      expect(SnsRecordVersion.v1.prefixByte, 1);
      expect(SnsRecordVersion.v2.prefixByte, 2);
    });

    test('rejects three labels without a record version', () {
      expect(
        () => findDomainKey('a.b.c'),
        throwsArgumentError,
      );
    });

    test('rejects more than three labels', () {
      expect(() => findDomainKey('a.b.c.d'), throwsArgumentError);
      expect(
        () => findDomainKey('a.b.c.d', record: SnsRecordVersion.v2),
        throwsArgumentError,
      );
    });
  });

  group('deriveNameAddress and findNameAccountKey', () {
    test('agree with each other', () async {
      final derived = await deriveNameAddress(
        'bonfida',
        parentAddress: snsRootDomainAddressObject,
      );
      final key = await findNameAccountKey(
        getHashedName('bonfida'),
        parentAddress: snsRootDomainAddressObject,
      );
      expect(derived.$1, key);
    });

    test('absent class and parent seeds equal 32 zero-byte seeds', () async {
      // Cross-computed with @solana/web3.js using 32 zero bytes for the
      // class and parent seeds.
      final key = await findNameAccountKey(getHashedName('bonfida'));
      expect(
        key,
        const Address('85v6oF1VnGNeT4oV2fH8HpVBj3k3U4m6uNnWYT8AcA5H'),
      );
    });
  });
}
