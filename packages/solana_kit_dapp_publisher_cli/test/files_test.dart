import 'dart:io';

import 'dart:typed_data';

import 'package:solana_kit_dapp_publisher_cli/src/errors.dart';
import 'package:solana_kit_dapp_publisher_cli/src/files.dart';
import 'package:test/test.dart';

void main() {
  group('sha256Hex', () {
    test('matches the standard test vector for the empty string', () {
      final digest = sha256Hex(Uint8List(0));
      expect(
        digest,
        'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
      );
    });

    test('matches the RFC 6234 vector for "abc"', () {
      final digest = sha256Hex(Uint8List.fromList('abc'.codeUnits));
      expect(
        digest,
        'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad',
      );
    });

    test('matches a verified two-block-length message', () {
      final message = Uint8List.fromList(
        List.generate(112, (index) => index & 0xff),
      );
      final digest = sha256Hex(message);
      expect(
        digest,
        '09373f127d34e61dbbaa8bc4499c87074f2ddb10e1b465f506d7d70a15011979',
      );
    });

    test('matches the known vector for a long message', () {
      final message = Uint8List.fromList(
        List.filled(1000000, 0x61),
      );
      final digest = sha256Hex(message);
      expect(
        digest,
        'cdc76e5c9914fb9281a1c7e284d73e67f1809a48a497200e046d39ccc7112cd0',
      );
    });

    test('hashes a file from disk', () {
      final directory = Directory.systemTemp.createTempSync();
      addTearDown(() => directory.deleteSync(recursive: true));
      final file = File('${directory.path}/sample.bin')
        ..writeAsBytesSync([1, 2, 3]);
      expect(
        hashFileSha256(file.path),
        '039058c6f2c0cb492c533b0a4d14ef77cc0f78abccced5287d84a1a2011cfb81',
      );
    });
  });

  group('inferFileNameFromUrl', () {
    test('returns the last path segment', () {
      expect(inferFileNameFromUrl('https://example.com/a/app.apk'), 'app.apk');
    });

    test('skips empty segments', () {
      expect(inferFileNameFromUrl('https://example.com//app.apk'), 'app.apk');
    });

    test('returns null without segments', () {
      expect(inferFileNameFromUrl('https://example.com'), isNull);
    });

    test('returns null for unparseable URLs', () {
      expect(inferFileNameFromUrl('::://'), isNull);
    });
  });

  group('ensureApkFileName', () {
    test('keeps the .apk extension', () {
      expect(ensureApkFileName('app.APK'), 'app.APK');
    });

    test('appends the .apk extension', () {
      expect(ensureApkFileName('app'), 'app.apk');
      expect(ensureApkFileName('  app  '), 'app.apk');
    });
  });

  group('inferMimeType', () {
    test('maps known extensions', () {
      expect(inferMimeType('app.apk'), apkContentType);
      expect(inferMimeType('icon.png'), 'image/png');
      expect(inferMimeType('icon.jpg'), 'image/jpeg');
      expect(inferMimeType('icon.jpeg'), 'image/jpeg');
      expect(inferMimeType('icon.webp'), 'image/webp');
      expect(inferMimeType('icon.gif'), 'image/gif');
      expect(inferMimeType('icon.svg'), 'image/svg+xml');
      expect(inferMimeType('demo.mp4'), 'video/mp4');
      expect(inferMimeType('demo.webm'), 'video/webm');
      expect(inferMimeType('demo.mov'), 'video/quicktime');
      expect(inferMimeType('meta.json'), 'application/json');
    });

    test('falls back to octet-stream', () {
      expect(inferMimeType('file.bin'), 'application/octet-stream');
      expect(inferMimeType('noextension'), 'application/octet-stream');
      expect(inferMimeType(''), 'application/octet-stream');
      expect(inferMimeType(null), 'application/octet-stream');
    });
  });

  group('base16Encode', () {
    test('encodes lowercase hex', () {
      expect(base16Encode(Uint8List.fromList([0x0f, 0xab])), '0fab');
    });
  });

  group('base64DecodeBytes', () {
    test('round-trips', () {
      final bytes = base64DecodeBytes('AQID');
      expect(bytes, [1, 2, 3]);
    });

    test('throws a friendly error for invalid input', () {
      expect(
        () => base64DecodeBytes('not base64!!'),
        throwsA(isA<PublisherCliException>()),
      );
    });
  });

  group('ensureHttpsUrl', () {
    test('passes through absolute https URLs', () {
      expect(
        ensureHttpsUrl('https://example.com/path/'),
        'https://example.com/path',
      );
    });

    test('keeps http URLs untouched', () {
      expect(ensureHttpsUrl('http://example.com'), 'http://example.com');
    });

    test('prefixes missing schemes', () {
      expect(ensureHttpsUrl('example.com'), 'https://example.com');
    });

    test('returns empty strings unchanged', () {
      expect(ensureHttpsUrl('   '), '');
    });
  });

  group('normalizeUrl', () {
    test('strips the trailing slash', () {
      expect(normalizeUrl('https://example.com/'), 'https://example.com');
    });
  });

  group('SafeSubstring', () {
    test('returns empty when start is beyond length', () {
      expect('abc'.substringSafe(10, 20), '');
    });

    test('clamps the end', () {
      expect('abc'.substringSafe(0, 50), 'abc');
      expect('abcdef'.substringSafe(1, 3), 'bc');
    });
  });
}
