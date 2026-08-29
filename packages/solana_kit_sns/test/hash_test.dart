import 'dart:convert';
import 'dart:typed_data';

import 'package:solana_kit_sns/solana_kit_sns.dart';
import 'package:test/test.dart';

String _hex(Uint8List bytes) =>
    bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

void main() {
  group('sha256', () {
    test('NIST vector: empty input', () {
      expect(
        _hex(sha256(Uint8List(0))),
        'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
      );
    });

    test('NIST vector: "abc"', () {
      expect(
        _hex(sha256(Uint8List.fromList(utf8.encode('abc')))),
        'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad',
      );
    });

    test('"hello world"', () {
      expect(
        _hex(sha256(Uint8List.fromList(utf8.encode('hello world')))),
        'b94d27b9934d3e08a52e52d7da7dabfac484efe37a5380ee9088f7ace2efcde9',
      );
    });

    test('multi-block input (200 bytes)', () {
      // Cross-checked against `node -e "console.log(require('crypto')
      // .createHash('sha256').update(Buffer.alloc(200, 7)).digest('hex'))"`.
      final input = Uint8List(200)..fillRange(0, 200, 7);
      expect(
        _hex(sha256(input)),
        '83ed56670125a357640623904bc0c1a17fdc835d75eef70363750f1a9c8ba724',
      );
    });
  });

  group('getHashedName', () {
    // Vectors computed with the TypeScript SDK's getHashedNameSync:
    // sha256(utf8('SPL Name Service' + name)).
    const vectors = <String, String>{
      '': '6b5013319a5674f34ff3c57bf7c92cfe14d70427d750cb773b5a5ef35ad5de83',
      'example':
          '7790ab8658a73c4f1b56fee722e5446b33c8407ba710ebd0f64f05e357d6e799',
      'bonfida':
          '8ee2d25c3d2b2a83a1fc209b90377aed03dc2539e8e238355edda8d1b2edab98',
      '.sol':
          'e8b8273f30ca2ebed726c06393b446a2f613700bcca7ab51aa86b75ea6496b84',
      'solver':
          'd67c363e2db8f185bfbe93cef4aa2cfb7b9539da6fba53053727d70f76087810',
      // Multi-byte UTF-8 input.
      'Ø': '4953761847398aedf790ff02f857b7af43c0fb2fe2bac1769ed4045186abda9e',
      // Subdomain (NUL), record V1 (0x01) and record V2 (0x02) label prefixes.
      '\u0000sub':
          '4283e89c83ac6b464b0bcd51cf1391ed43cbff55c51a47c4c759596e2a5edc39',
      '\u0001url':
          '10edbb8fea0a71c36dffa9b24b2158f399107f336552f48d44dd42bf715568f1',
      '\u0002url':
          'e77214d976cb19019b46315c066d230374473ba561c1f3d7197fd1e644ac3585',
      '\u0002SOL':
          '30ecde95b64ef547d89fde3987039f70b53937a8ffbcc10a285b826fdfa076bd',
      '\u0002twitter':
          'b0da031a049fb9ad694a1d028e4f8726d0d886f5f5f5b1fccbbfd6074487c768',
      '0': 'edb81c691c767307cedba259d80df17ff55ee82e4981421d74005433f77b3c24',
    };

    for (final MapEntry(:key, :value) in vectors.entries) {
      test('hashes "$key"', () {
        expect(_hex(getHashedName(key)), value);
      });
    }

    test('hash prefix is the SPL Name Service string', () {
      expect(snsHashPrefix, 'SPL Name Service');
    });

    test('similar names hash differently', () {
      expect(getHashedName('sol'), isNot(equals(getHashedName('.sol'))));
    });
  });
}
