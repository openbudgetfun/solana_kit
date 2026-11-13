import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:solana_kit_privacy_rings/solana_kit_privacy_rings.dart';
import 'package:solana_kit_privacy_rings/src/prover/p384.dart'
    show p384PublicKey, p384Sign;
import 'package:test/test.dart';

import 'nitro_quote.dart';

File _fixture(String name) {
  final relative = 'test/fixtures/$name';
  final local = File(relative);
  if (local.existsSync()) return local;
  return File('packages/solana_kit_privacy_rings/$relative');
}

Uint8List _hex(String text) {
  final bytes = Uint8List(text.length ~/ 2);
  for (var i = 0; i < bytes.length; i++) {
    bytes[i] = int.parse(text.substring(i * 2, i * 2 + 2), radix: 16);
  }
  return bytes;
}

Matcher _code(String code) => throwsA(
  isA<PrivacyRingsException>().having((error) => error.code, 'code', code),
);

void main() {
  test(
    'the embedded AWS Nitro root is the published generation-1 certificate',
    () {
      expect(
        sha256.convert(awsNitroRoot).toString(),
        '641a0321a3e244efe456463195d606317ed7cdcc3c1756e09893f3c68f79bb5b',
      );
    },
  );

  test('shared Nitro CBOR cases match the upstream verdict', () {
    final shared = jsonDecode(
      _fixture('nitro_cbor_cases.json').readAsStringSync(),
    ) as Map<String, Object?>;
    final leaf = _hex(shared['leaf_key']! as String);
    final nonce = _hex(shared['nonce']! as String);
    final hpke = _hex(shared['hpke_public_key']! as String);
    final root = _hex(shared['root']! as String);
    final policy = shared['policy']! as Map<String, Object?>;
    final measurements = [
      for (final raw in policy['measurements']! as List)
        NitroMeasurement(
          pcr0: _hex((raw as Map)['pcr0'] as String),
          pcr1: _hex(raw['pcr1'] as String),
          pcr2: _hex(raw['pcr2'] as String),
        ),
    ];
    for (final entry in shared['cases']! as List) {
      final item = entry as Map<String, Object?>;
      final name = item['name']! as String;
      final document = item['cose'] == null
          ? encodeCoseSign1(
              _hex(item['payload']! as String),
              p384Sign(
                coseSign1Input(_hex(item['payload']! as String)),
                leaf,
              ),
            )
          : _hex(item['cose']! as String);
      final expected = item['expect']! as String;
      if (expected == 'accept') {
        final verdict = verifyNitroAttestation(
          document: document,
          measurements: measurements,
          nonce: nonce,
          hpkePublicKey: hpke,
          nowSecs: shared['now']! as int,
          anchors: [root],
        );
        expect(
          _hexOf(verdict.imageId),
          _hexOf(measurements.single.pcr0),
          reason: name,
        );
      } else {
        expect(
          () => verifyNitroAttestation(
            document: document,
            measurements: measurements,
            nonce: nonce,
            hpkePublicKey: hpke,
            nowSecs: shared['now']! as int,
            anchors: [root],
          ),
          _code('malformed_attestation'),
          reason: name,
        );
      }
    }
  });

  test('a live AWS Nitro attestation passes the published chain', () {
    final live = jsonDecode(
      _fixture('nitro_live_attestation.json').readAsStringSync(),
    ) as Map<String, Object?>;
    final policy = jsonDecode(
      _fixture('nitro_live_policy.json').readAsStringSync(),
    ) as Map<String, Object?>;
    final deployment = policy['deployment']! as Map<String, Object?>;
    final attestation = live['attestation']! as Map<String, Object?>;
    final evidence = attestation['evidence']! as Map<String, Object?>;
    final measurements = [
      for (final raw in deployment['measurements']! as List)
        NitroMeasurement(
          pcr0: _hex((raw as Map)['pcr0'] as String),
          pcr1: _hex(raw['pcr1'] as String),
          pcr2: _hex(raw['pcr2'] as String),
        ),
    ];
    final hpke = _hex(attestation['hpke_public_key']! as String);
    final verdict = verifyNitroAttestation(
      document: _hex(evidence['document']! as String),
      measurements: measurements,
      nonce: _hex(live['nonce']! as String),
      hpkePublicKey: hpke,
      nowSecs: live['captured_at']! as int,
    );
    expect(_hexOf(verdict.imageId), _hexOf(measurements.single.pcr0));
    expect(
      () => verifyNitroAttestation(
        document: _hex(evidence['document']! as String),
        measurements: measurements,
        nonce: Uint8List(32),
        hpkePublicKey: hpke,
        nowSecs: live['captured_at']! as int,
      ),
      _code('nonce'),
    );
    expect(
      () => verifyNitroAttestation(
        document: _hex(evidence['document']! as String),
        measurements: measurements,
        nonce: _hex(live['nonce']! as String),
        hpkePublicKey: hpke,
        nowSecs: live['captured_at']! as int,
        pinnedHpkePublicKey: Uint8List(32),
      ),
      _code('hpke_key'),
    );
    expect(
      () => p384Sign(Uint8List(1), Uint8List(16)),
      _code('invalid_length'),
    );
    expect(
      () => p384Sign(Uint8List(1), Uint8List(48)),
      _code('integer_range'),
    );
    final secret = Uint8List(48)..[47] = 3;
    final key = p384PublicKey(secret);
    final signed = p384Sign(
      const [1, 2, 3],
      secret,
      nonce: Uint8List(48)..[47] = 9,
    );
    expect(p384Verify(signed, const [1, 2, 3], key, der: false), isTrue);
    expect(() => p384PublicKey(Uint8List(48)), _code('integer_range'));
    expect(() => p384PublicKey(Uint8List(3)), _code('invalid_length'));
    expect(
      () => p384Sign(
        const [1],
        secret,
        nonce: Uint8List(48),
      ),
      _code('tee_encryption'),
    );
    expect(
      p384Verify(Uint8List(10), const [1], key, der: true),
      isFalse,
    );
    expect(
      p384Verify(
        Uint8List.fromList([
          0x30,
          0x81,
          0x06,
          0x02,
          0x01,
          0x01,
          0x02,
          0x01,
          0x01,
        ]),
        const [1],
        key,
        der: true,
      ),
      isFalse,
    );
    expect(
      p384Verify(
        Uint8List.fromList([
          0x30,
          0x06,
          0x02,
          0x02,
          0x00,
          0x01,
          0x02,
          0x01,
          0x01,
        ]),
        const [1],
        key,
        der: true,
      ),
      isFalse,
    );
    final digest = sha384.convert(const [9]).bytes;
    var scalar = BigInt.zero;
    for (final byte in digest) {
      scalar = (scalar << 8) | BigInt.from(byte);
    }
    final order = BigInt.parse(
      'ffffffffffffffffffffffffffffffffffffffffffffffffc7634d81f4372ddf581a0db248b0a77aecec196accc52973',
      radix: 16,
    );
    scalar %= order;
    var opposite = order - scalar;
    final signature = Uint8List(96);
    for (var i = 47; i >= 0; i--) {
      signature[i] = (opposite & BigInt.from(0xff)).toInt();
      opposite >>= 8;
    }
    signature[95] = 1;
    final generator = _hex(
      '04aa87ca22be8b05378eb1c71ef320ad746e1d3b628ba79b9859f741e082542a38'
      '5502f25dbf55296c3a545e3872760ab73617de4a96262c6f5d9e98bf9292dc29'
      'f8f41dbd289a147ce9da3113b5f0b8c00a60b1ce1d7e819d7a431d7c90ea0e5f',
    );
    expect(p384Verify(signature, const [9], generator, der: false), isFalse);
  });

  test('a caller-built document verifies through the test chain', () {
    final nonce = Uint8List(32)..[0] = 4;
    final hpke = Uint8List(32)..[0] = 5;
    final body = nitroAttestation(nonce: nonce, hpke: hpke);
    final document = _hex(
      (body['evidence']! as Map)['document']! as String,
    );
    final verdict = verifyNitroAttestation(
      document: document,
      measurements: [nitroMeasurement()],
      nonce: nonce,
      hpkePublicKey: hpke,
      nowSecs: 1700000000,
      anchors: [nitroTestRoot],
    );
    expect(_hexOf(verdict.imageId), _hexOf(nitroPcr0));
    final flipped = Uint8List.fromList(document);
    flipped[flipped.length - 1] ^= 1;
    expect(
      () => verifyNitroAttestation(
        document: flipped,
        measurements: [nitroMeasurement()],
        nonce: nonce,
        hpkePublicKey: hpke,
        nowSecs: 1700000000,
        anchors: [nitroTestRoot],
      ),
      _code('signature'),
    );
    expect(
      () => verifyNitroAttestation(
        document: _hex(
          (nitroAttestation(
                    nonce: nonce,
                    hpke: hpke,
                    digest: 'SHA256',
                  )['evidence']!
                  as Map)['document']!
              as String,
        ),
        measurements: [nitroMeasurement()],
        nonce: nonce,
        hpkePublicKey: hpke,
        nowSecs: 1700000000,
        anchors: [nitroTestRoot],
      ),
      _code('digest'),
    );
    expect(
      () => verifyNitroAttestation(
        document: _hex(
          (nitroAttestation(
                    nonce: nonce,
                    hpke: hpke,
                    pcr0: Uint8List(48),
                  )['evidence']!
                  as Map)['document']!
              as String,
        ),
        measurements: [nitroMeasurement(pcr0: Uint8List(48))],
        nonce: nonce,
        hpkePublicKey: hpke,
        nowSecs: 1700000000,
        anchors: [nitroTestRoot],
      ),
      _code('debug_enclave'),
    );
    expect(
      () => verifyNitroAttestation(
        document: _hex(
          (nitroAttestation(nonce: nonce, hpke: hpke, alg: -7)['evidence']!
                  as Map)['document']!
              as String,
        ),
        measurements: [nitroMeasurement()],
        nonce: nonce,
        hpkePublicKey: hpke,
        nowSecs: 1700000000,
        anchors: [nitroTestRoot],
      ),
      _code('alg'),
    );
    expect(
      () => verifyNitroAttestation(
        document: document,
        measurements: [nitroMeasurement()],
        nonce: nonce,
        hpkePublicKey: hpke,
        nowSecs: 100,
        anchors: [nitroTestRoot],
      ),
      _code('certificate_validity'),
    );
    expect(
      () => verifyNitroAttestation(
        document: document,
        measurements: [nitroMeasurement()],
        nonce: nonce,
        hpkePublicKey: hpke,
        nowSecs: 2500000000,
        anchors: [nitroTestRoot],
      ),
      _code('certificate_validity'),
    );
  });
}

String _hexOf(List<int> bytes) =>
    bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
