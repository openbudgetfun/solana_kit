import 'dart:typed_data';

import 'package:solana_kit_privacy_rings/solana_kit_privacy_rings.dart';
import 'package:test/test.dart';

import 'nitro_quote.dart';

final _nonce = Uint8List(32)..[0] = 4;
final _hpke = Uint8List(32)..[0] = 5;

final Uint8List _pathRoot = _hex(
  '308201853082010aa003020102020101300a06082a8648ce3d04030330183116301406'
  '035504030c0d7370722d706174682d726f6f743020170d323030313031303030303030'
  '5a180f32303630303130313030303030305a30183116301406035504030c0d7370722d'
  '706174682d726f6f743076301006072a8648ce3d020106052b8104002203620004a168'
  'a862f2a6b4b80376fd52c850ff89de99ac511a78e98a42608c499e71656aefead53ad7'
  'a6e9256c0b60f14a6cb103b430f73762141f693623f4f5e136b99c15ee79ab70f90c99'
  'ab23b06800a326ee03268babec90195bcc621e115df382cba326302430120603551d13'
  '0101ff040830060101ff020100300e0603551d0f0101ff040403020204300a06082a86'
  '48ce3d0403030369003066023100e55b3858dd213a82384e635660b1aa28df6747532a'
  '202c1d5f2f35c68f112edca7861960d658cce82753a4f7c781ae6b023100fd40f18d18'
  '10254e056c48529e87208d79eca9e1f49bfbfb814717f90299fbf6a51c677a552c60d8'
  '03074af27d63dd59',
);
final Uint8List _pathMid = _hex(
  '3082018230820109a003020102020102300a06082a8648ce3d04030330183116301406'
  '035504030c0d7370722d706174682d726f6f743020170d323030313031303030303030'
  '5a180f32303630303130313030303030305a30173115301306035504030c0c7370722d'
  '706174682d6d69643076301006072a8648ce3d020106052b810400220362000407a2a7'
  '2d307a6c885818b67ad97491d2c0a0560c570931aa02b52315b53c7c8b21150f89ef2f'
  'd99b7ad5a768b0f59bd6ae92954ddbfe43bdbc7027b25b357c99a5d7fce85541dff07e'
  'de03f282d948200db71a017a8d55dd9ddfa2b5f0fc8cf9a326302430120603551d1301'
  '01ff040830060101ff020100300e0603551d0f0101ff040403020204300a06082a8648'
  'ce3d040303036700306402306d989442cfd1cd41cfa72dada2ed97ee03cc1965137423'
  'e8ef7a71df3d1975d0783d6c7ad16f7c0264c386bd5917d670023047b7c653d3b1f7b5'
  'df6fbc32999a245af0f1882bab15291c086461869e263e5dfedec97f46617f316bb42d'
  '9ad1d9210c',
);
final Uint8List _pathLeaf = _hex(
  '3082017e30820103a003020102020103300a06082a8648ce3d04030330173115301306'
  '035504030c0c7370722d706174682d6d69643020170d3230303130313030303030305a'
  '180f32303630303130313030303030305a30183116301406035504030c0d7370722d70'
  '6174682d6c6561663076301006072a8648ce3d020106052b810400220362000412b9b2'
  'c8a7f5409967bee85874643e292920c4b4478302b07cabd4cff186d843c96e58c2cbf5'
  '738072913908a860480e6ec4a121ab5f26dcb3b0b1be919e99dc831a048a73beb97022'
  '061651c07d28256af0a6aed36a5c46cbaa4359562d03eaa320301e300c0603551d1301'
  '01ff04023000300e0603551d0f0101ff040403020780300a06082a8648ce3d04030303'
  '69003066023100e8b32084ce3e24156dac8f0117cc21dc3845b9db5e94087f39fbf671'
  '1575f8ca1bb5299509da5a19c06970678c40a96c023100c990ee7f05a32504b3165dc7'
  '97ae5a4bfdaf48257cab121db0c1f89836907451eb190ea26f4ffaf86fb40b4f9e18e6'
  'a2',
);

Matcher _code(String code) => throwsA(
  isA<PrivacyRingsException>().having((error) => error.code, 'code', code),
);

void main() {
  test('Nitro documents refuse each broken field', () {
    void refuse(
      String code,
      Map<String, Object?> body, {
      List<Uint8List>? anchors,
      Uint8List? hpke,
    }) {
      final evidence = body['evidence']! as Map<String, Object?>;
      expect(
        () => verifyNitroAttestation(
          document: _hex(evidence['document']! as String),
          measurements: [nitroMeasurement()],
          nonce: _nonce,
          hpkePublicKey: hpke ?? _hpke,
          nowSecs: 1700000000,
          anchors: anchors ?? [nitroTestRoot],
        ),
        _code(code),
      );
    }

    Map<String, Object?> quote({
      Uint8List? payload,
      Uint8List? certificate,
      List<Uint8List>? cabundle,
      bool includeUserData = true,
      bool includePublicKey = true,
      Uint8List? pcr0,
    }) {
      return nitroAttestation(
        nonce: _nonce,
        hpke: _hpke,
        payload: payload,
        certificate: certificate,
        cabundle: cabundle,
        includeUserData: includeUserData,
        includePublicKey: includePublicKey,
        pcr0: pcr0,
      );
    }

    refuse('public_key', quote(), hpke: Uint8List(32)..[0] = 9);
    refuse('malformed_attestation', quote(payload: Uint8List.fromList([0x80])));
    refuse(
      'malformed_attestation',
      quote(payload: _map([(_text('module_id'), _text(''))])),
    );
    refuse('malformed_attestation', quote(payload: _pcrKey()));
    refuse('malformed_attestation', quote(pcr0: Uint8List(16)));
    refuse(
      'malformed_attestation',
      quote(payload: _map([(_text('cabundle'), _text('no'))])),
    );
    refuse('root', quote(cabundle: const []));
    refuse('root', quote(), anchors: [Uint8List(4)]);
    refuse(
      'certificate_chain',
      quote(certificate: _pathLeaf, cabundle: [_pathRoot, _pathMid]),
      anchors: [_pathRoot],
    );
    refuse(
      'certificate_chain',
      quote(certificate: nitroTestRoot, cabundle: [nitroTestRoot]),
    );
    refuse('report_data', quote(includeUserData: false));
    refuse('public_key', quote(includePublicKey: false));
    refuse(
      'malformed_attestation',
      quote(payload: Uint8List.fromList([0xf7])),
    );
    refuse(
      'malformed_attestation',
      quote(payload: Uint8List.fromList([0x1c])),
    );
    refuse('certificate_chain', quote(certificate: _flipOid(nitroTestRoot, 0)));
    refuse('certificate_chain', quote(certificate: _flipOid(nitroTestRoot, 1)));
    refuse(
      'certificate_chain',
      quote(certificate: _breakLength(nitroTestRoot)),
    );
    final noCertSign = _replace(nitroTestRoot, '040403020204', '040403020280');
    refuse(
      'certificate_chain',
      quote(cabundle: [noCertSign]),
      anchors: [noCertSign],
    );
    refuse(
      'certificate_chain',
      quote(certificate: _flipLast(nitroLeafCertificate)),
    );
    refuse(
      'certificate_chain',
      quote(
        certificate: _replace(
          nitroLeafCertificate,
          '06052b81040022',
          '06052b81040023',
        ),
      ),
    );
    refuse(
      'certificate_chain',
      quote(
        certificate: _replace(
          nitroLeafCertificate,
          '300e0603551d0f0101ff040403020780',
          '300e0603551d0f0101ff040100020100',
        ),
      ),
    );
    refuse(
      'certificate_chain',
      quote(
        certificate: _replace(
          nitroLeafCertificate,
          '300e0603551d0f0101ff040403020780',
          '300e0603551d0f020100040403020780',
        ),
      ),
    );
    refuse(
      'certificate_chain',
      quote(
        certificate: _replace(
          nitroLeafCertificate,
          '0603551d0f',
          '0603551d0e',
        ),
      ),
    );
    refuse(
      'certificate_chain',
      quote(
        certificate: _replace(
          nitroLeafCertificate,
          '0367003064',
          '0367013064',
        ),
      ),
    );
    refuse(
      'certificate_chain',
      quote(
        certificate: _replace(
          nitroLeafCertificate,
          '170d3230303130313030303030305a',
          '160d3230303130313030303030305a',
        ),
      ),
    );
    refuse(
      'certificate_chain',
      quote(certificate: _replace(_pathRoot, '020100', '020180')),
    );
    refuse('malformed_attestation', quote(payload: _badBundle()));
    expect(
      () => verifyNitroAttestation(
        document: _intPayload,
        measurements: [nitroMeasurement()],
        nonce: _nonce,
        hpkePublicKey: _hpke,
        nowSecs: 1700000000,
        anchors: [nitroTestRoot],
      ),
      _code('malformed_attestation'),
    );
    encodeCoseSign1(Uint8List(70000), Uint8List(96));
    expect(
      () => NitroMeasurement(
        pcr0: Uint8List(1),
        pcr1: nitroPcr1,
        pcr2: nitroPcr2,
      ),
      _code('invalid_length'),
    );
  });
}

Uint8List _pcrKey() {
  return _map([
    (_text('module_id'), _text('i-spr-test')),
    (_text('digest'), _text('SHA384')),
    (_text('timestamp'), _uint(1)),
    (_text('pcrs'), _map([(_text('0'), _bytes(nitroPcr0))])),
    (_text('certificate'), _bytes(nitroTestRoot)),
    (_text('cabundle'), _array([_bytes(nitroTestRoot)])),
  ]);
}

Uint8List _flipOid(Uint8List source, int which) {
  final bytes = Uint8List.fromList(source);
  final oid = [0x06, 0x08, 0x2a, 0x86, 0x48, 0xce, 0x3d, 0x04, 0x03, 0x03];
  var seen = 0;
  for (var i = 0; i + oid.length <= bytes.length; i++) {
    var match = true;
    for (var j = 0; j < oid.length; j++) {
      if (bytes[i + j] != oid[j]) match = false;
    }
    if (!match) continue;
    if (seen == which) {
      bytes[i + oid.length - 1] ^= 1;
      return bytes;
    }
    seen++;
  }
  throw StateError('oid $which missing');
}

Uint8List _breakLength(Uint8List source) {
  final bytes = Uint8List.fromList(source);
  bytes[1] = 0x80;
  return bytes;
}

Uint8List _map(List<(Uint8List, Uint8List)> pairs) {
  final body = <int>[];
  for (final pair in pairs) {
    body
      ..addAll(pair.$1)
      ..addAll(pair.$2);
  }
  return Uint8List.fromList([..._header(5, pairs.length), ...body]);
}

Uint8List _array(List<Uint8List> items) {
  final body = <int>[];
  for (final item in items) {
    body.addAll(item);
  }
  return Uint8List.fromList([..._header(4, items.length), ...body]);
}

Uint8List _text(String text) =>
    Uint8List.fromList([..._header(3, text.length), ...text.codeUnits]);

Uint8List _bytes(List<int> bytes) =>
    Uint8List.fromList([..._header(2, bytes.length), ...bytes]);

Uint8List _uint(int value) => _header(0, value);

Uint8List _badBundle() {
  return _map([
    (_text('module_id'), _text('i-spr-test')),
    (_text('digest'), _text('SHA384')),
    (_text('timestamp'), _uint(1)),
    (
      _text('pcrs'),
      _map([
        (_uint(0), _bytes(const [1])),
        (_uint(1), _bytes(const [2])),
        (_uint(2), _bytes(const [3])),
      ]),
    ),
    (_text('cabundle'), _text('no')),
  ]);
}

Uint8List _replace(Uint8List source, String from, String to) {
  final needle = _hex(from);
  final replacement = _hex(to);
  var found = -1;
  for (var i = 0; i + needle.length <= source.length; i++) {
    var match = true;
    for (var j = 0; j < needle.length; j++) {
      if (source[i + j] != needle[j]) match = false;
    }
    if (!match) continue;
    if (found >= 0) throw StateError('ambiguous $from');
    found = i;
  }
  if (found < 0) throw StateError('missing $from');
  return Uint8List.fromList(source)
    ..setRange(found, found + replacement.length, replacement);
}

Uint8List _flipLast(Uint8List source) {
  final bytes = Uint8List.fromList(source);
  bytes[bytes.length - 1] ^= 1;
  return bytes;
}

/// COSE_Sign1 whose payload is an integer, so the payload is not a byte string.
final Uint8List _intPayload = Uint8List.fromList([
  0xd2, 0x84, // tag 18, array of 4
  0x44, 0xa1, 0x01, 0x38, 0x22, // protected {1: -35}
  0xa0, // unprotected map
  0x01, // payload
  0x40, // signature
]);

Uint8List _header(int major, int value) {
  if (value < 24) return Uint8List.fromList([(major << 5) | value]);
  if (value < 256) return Uint8List.fromList([(major << 5) | 24, value]);
  if (value < 65536) {
    return Uint8List.fromList([
      (major << 5) | 25,
      value >> 8,
      value & 0xff,
    ]);
  }
  return Uint8List.fromList([
    (major << 5) | 26,
    value >> 24,
    (value >> 16) & 0xff,
    (value >> 8) & 0xff,
    value & 0xff,
  ]);
}

Uint8List _hex(String text) {
  final bytes = Uint8List(text.length ~/ 2);
  for (var i = 0; i < bytes.length; i++) {
    bytes[i] = int.parse(text.substring(i * 2, i * 2 + 2), radix: 16);
  }
  return bytes;
}
