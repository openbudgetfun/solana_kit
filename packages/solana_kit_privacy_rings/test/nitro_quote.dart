import 'dart:typed_data';

import 'package:solana_kit_privacy_rings/solana_kit_privacy_rings.dart';

/// Root the session tests trust instead of the AWS Nitro root.
final Uint8List nitroTestRoot = _hex(
  '3082017f30820105a003020102020101300a06082a8648ce3d04030330183116301406'
  '035504030c0d7370722d746573742d726f6f74301e170d323030313031303030303030'
  '5a170d3438303130313030303030305a30183116301406035504030c0d7370722d7465'
  '73742d726f6f743076301006072a8648ce3d020106052b81040022036200049bcab776'
  'f30a1a3a586d4d2079f6493314e16e7c2b6f5a19525316355a28d0ff024edbf3770b76'
  'd17e14d719969804d009a27fe694d31483ac0852b15a8627936b33da644cf7a31153e6'
  'cf228db1880d293ff7a42ff71e9518bbb662707bd6eea3233021300f0603551d130101'
  'ff040530030101ff300e0603551d0f0101ff040403020204300a06082a8648ce3d0403'
  '0303680030650230554ef884c34fc60b0a1b34828c46f974335950a5171ec189511ebf'
  'e072dbb09db3c7a7771c5e32bc09562ada6c52b965023100fca51e2a1375ad8dc8398d'
  'd16c73b66513bf62ae4695ab37a634270baaf49616ddf361b0038f3979fb4349ffc5df'
  '7d5d',
);

/// Leaf certificate signed by [nitroTestRoot].
final Uint8List nitroLeafCertificate = _hex(
  '3082017b30820102a003020102020102300a06082a8648ce3d04030330183116301406'
  '035504030c0d7370722d746573742d726f6f74301e170d323030313031303030303030'
  '5a170d3438303130313030303030305a30183116301406035504030c0d7370722d7465'
  '73742d6c6561663076301006072a8648ce3d020106052b8104002203620004e598c89a'
  '74d1688bacd3b830ee95f60d6775ce2a24741f8b2e45951c566e7ada8c3d44ed1b439c'
  '623bcc3fd45915b25fc7e24627820b05532c6d0351d69eb8213b75c43a0c0e2e914386'
  '07882f1261a1a3270e8910095b49fbdeee1b5d2dbe76a320301e300c0603551d130101'
  'ff04023000300e0603551d0f0101ff040403020780300a06082a8648ce3d0403030367'
  '00306402305767d8f4efe72a86c3240589fcd0c8068d21282f555d0c29717c752d9cfe'
  '4edf8ecb3289658788978141e47e60520f47023059a26a6e5ed2b974ad8d3422168ea5'
  '8298a28df35f3b3cd6f22ac99f1e5e7a0228556f990c7dffcfe9230e240e482dfe',
);

final Uint8List _leafSecret = _hex(
  '0bf7898c31897e250cbe9cca25e65f1f05323c26e625b0719e1c5cdb88d86511'
  '0354d847903c1f0f87d060e40a043221',
);

/// PCR0 of the quote [nitroAttestation] builds unless a caller overrides it.
final Uint8List nitroPcr0 = Uint8List(48)..[0] = 1;

/// PCR1 paired with [nitroPcr0].
final Uint8List nitroPcr1 = Uint8List(48)..[0] = 2;

/// PCR2 paired with [nitroPcr0].
final Uint8List nitroPcr2 = Uint8List(48)..[0] = 3;

/// The measurement [nitroPolicy] pins.
NitroMeasurement nitroMeasurement({Uint8List? pcr0}) {
  return NitroMeasurement(
    pcr0: pcr0 ?? nitroPcr0,
    pcr1: nitroPcr1,
    pcr2: nitroPcr2,
  );
}

/// A Nitro policy whose anchors are the test root.
TeePolicy nitroPolicy({
  List<Uint8List>? imageIds,
  List<NitroMeasurement>? measurements,
  String gpu = 'optional',
  Duration maxAge = const Duration(minutes: 10),
}) {
  return TeePolicy(
    platform: 'aws-nitro',
    imageIds: imageIds ?? [nitroPcr0],
    measurements: measurements ?? [nitroMeasurement()],
    anchors: [nitroTestRoot],
    gpu: gpu,
    maxAge: maxAge,
  );
}

/// Attestation JSON whose COSE document is signed by the test leaf.
Map<String, Object?> nitroAttestation({
  required Uint8List nonce,
  required Uint8List hpke,
  Uint8List? pcr0,
  Uint8List? userData,
  String digest = 'SHA384',
  int alg = -35,
  bool includeGpu = true,
  Object? gpu,
  Uint8List? payload,
  Uint8List? certificate,
  List<Uint8List>? cabundle,
  bool includeUserData = true,
  bool includePublicKey = true,
}) {
  final image = pcr0 ?? nitroPcr0;
  final report = userData ?? proverReportData(nonce, hpke);
  final body =
      payload ??
      _document(
        pcr0: image,
        nonce: nonce,
        hpke: hpke,
        userData: report,
        digest: digest,
        certificate: certificate,
        cabundle: cabundle,
        includeUserData: includeUserData,
        includePublicKey: includePublicKey,
      );
  final signature = p384Sign(coseSign1Input(body, alg: alg), _leafSecret);
  final document = encodeCoseSign1(body, signature, alg: alg);
  return {
    'platform': 'aws-nitro',
    'hpke_public_key': _hexOf(hpke),
    if (includeGpu) 'gpu': gpu,
    'evidence': {'document': _hexOf(document)},
  };
}

Uint8List _document({
  required Uint8List pcr0,
  required Uint8List nonce,
  required Uint8List hpke,
  required Uint8List userData,
  required String digest,
  Uint8List? certificate,
  List<Uint8List>? cabundle,
  bool includeUserData = true,
  bool includePublicKey = true,
}) {
  final pairs = <(Uint8List, Uint8List)>[
    (_text('module_id'), _text('i-spr-test')),
    (_text('digest'), _text(digest)),
    (_text('timestamp'), _uint(1700000000000)),
    (
      _text('pcrs'),
      _map([
        (_uint(0), _bytes(pcr0)),
        (_uint(1), _bytes(nitroPcr1)),
        (_uint(2), _bytes(nitroPcr2)),
      ]),
    ),
    (_text('certificate'), _bytes(certificate ?? nitroLeafCertificate)),
    (
      _text('cabundle'),
      _array([
        for (final der in cabundle ?? [nitroTestRoot]) _bytes(der),
      ]),
    ),
    if (includePublicKey) (_text('public_key'), _bytes(hpke)),
    if (includeUserData) (_text('user_data'), _bytes(userData)),
    (_text('nonce'), _bytes(nonce)),
  ];
  return _map(pairs);
}

Uint8List _map(List<(Uint8List, Uint8List)> pairs) {
  final body = BytesBuilder(copy: false);
  for (final pair in pairs) {
    body
      ..add(pair.$1)
      ..add(pair.$2);
  }
  return Uint8List.fromList([..._header(5, pairs.length), ...body.toBytes()]);
}

Uint8List _array(List<Uint8List> items) {
  final body = BytesBuilder(copy: false);
  for (final item in items) {
    body.add(item);
  }
  return Uint8List.fromList([..._header(4, items.length), ...body.toBytes()]);
}

Uint8List _text(String text) {
  return Uint8List.fromList([..._header(3, text.length), ...text.codeUnits]);
}

Uint8List _bytes(List<int> bytes) {
  return Uint8List.fromList([..._header(2, bytes.length), ...bytes]);
}

Uint8List _uint(int value) => _header(0, value);

Uint8List _header(int major, int value) {
  if (value < 24) return Uint8List.fromList([(major << 5) | value]);
  if (value < 0x100) {
    return Uint8List.fromList([(major << 5) | 24, value]);
  }
  if (value < 0x10000) {
    return Uint8List.fromList([
      (major << 5) | 25,
      value >> 8,
      value & 0xff,
    ]);
  }
  if (value <= 0xffffffff) {
    return Uint8List.fromList([
      (major << 5) | 26,
      value >> 24,
      (value >> 16) & 0xff,
      (value >> 8) & 0xff,
      value & 0xff,
    ]);
  }
  final out = Uint8List(9);
  out[0] = (major << 5) | 27;
  var rest = value;
  for (var i = 8; i >= 1; i--) {
    out[i] = rest & 0xff;
    rest >>= 8;
  }
  return out;
}

Uint8List _hex(String text) {
  final bytes = Uint8List(text.length ~/ 2);
  for (var i = 0; i < bytes.length; i++) {
    bytes[i] = int.parse(text.substring(i * 2, i * 2 + 2), radix: 16);
  }
  return bytes;
}

String _hexOf(List<int> bytes) =>
    bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
