import 'dart:convert';
import 'dart:typed_data';

import 'package:solana_kit_privacy_rings/src/exception.dart';
import 'package:solana_kit_privacy_rings/src/prover/p384.dart';

/// AWS Nitro Enclaves root certificate, generation 1.
///
/// The SHA-256 of these bytes is
/// `641a0321a3e244efe456463195d606317ed7cdcc3c1756e09893f3c68f79bb5b`.
final Uint8List awsNitroRoot = Uint8List.fromList([
  0x30, 0x82, 0x02, 0x11, 0x30, 0x82, 0x01, 0x96, 0xa0, 0x03, 0x02, 0x01, //
  0x02, 0x02, 0x11, 0x00, 0xf9, 0x31, 0x75, 0x68, 0x1b, 0x90, 0xaf, 0xe1,
  0x1d, 0x46, 0xcc, 0xb4, 0xe4, 0xe7, 0xf8, 0x56, 0x30, 0x0a, 0x06, 0x08,
  0x2a, 0x86, 0x48, 0xce, 0x3d, 0x04, 0x03, 0x03, 0x30, 0x49, 0x31, 0x0b,
  0x30, 0x09, 0x06, 0x03, 0x55, 0x04, 0x06, 0x13, 0x02, 0x55, 0x53, 0x31,
  0x0f, 0x30, 0x0d, 0x06, 0x03, 0x55, 0x04, 0x0a, 0x0c, 0x06, 0x41, 0x6d,
  0x61, 0x7a, 0x6f, 0x6e, 0x31, 0x0c, 0x30, 0x0a, 0x06, 0x03, 0x55, 0x04,
  0x0b, 0x0c, 0x03, 0x41, 0x57, 0x53, 0x31, 0x1b, 0x30, 0x19, 0x06, 0x03,
  0x55, 0x04, 0x03, 0x0c, 0x12, 0x61, 0x77, 0x73, 0x2e, 0x6e, 0x69, 0x74,
  0x72, 0x6f, 0x2d, 0x65, 0x6e, 0x63, 0x6c, 0x61, 0x76, 0x65, 0x73, 0x30,
  0x1e, 0x17, 0x0d, 0x31, 0x39, 0x31, 0x30, 0x32, 0x38, 0x31, 0x33, 0x32,
  0x38, 0x30, 0x35, 0x5a, 0x17, 0x0d, 0x34, 0x39, 0x31, 0x30, 0x32, 0x38,
  0x31, 0x34, 0x32, 0x38, 0x30, 0x35, 0x5a, 0x30, 0x49, 0x31, 0x0b, 0x30,
  0x09, 0x06, 0x03, 0x55, 0x04, 0x06, 0x13, 0x02, 0x55, 0x53, 0x31, 0x0f,
  0x30, 0x0d, 0x06, 0x03, 0x55, 0x04, 0x0a, 0x0c, 0x06, 0x41, 0x6d, 0x61,
  0x7a, 0x6f, 0x6e, 0x31, 0x0c, 0x30, 0x0a, 0x06, 0x03, 0x55, 0x04, 0x0b,
  0x0c, 0x03, 0x41, 0x57, 0x53, 0x31, 0x1b, 0x30, 0x19, 0x06, 0x03, 0x55,
  0x04, 0x03, 0x0c, 0x12, 0x61, 0x77, 0x73, 0x2e, 0x6e, 0x69, 0x74, 0x72,
  0x6f, 0x2d, 0x65, 0x6e, 0x63, 0x6c, 0x61, 0x76, 0x65, 0x73, 0x30, 0x76,
  0x30, 0x10, 0x06, 0x07, 0x2a, 0x86, 0x48, 0xce, 0x3d, 0x02, 0x01, 0x06,
  0x05, 0x2b, 0x81, 0x04, 0x00, 0x22, 0x03, 0x62, 0x00, 0x04, 0xfc, 0x02,
  0x54, 0xeb, 0xa6, 0x08, 0xc1, 0xf3, 0x68, 0x70, 0xe2, 0x9a, 0xda, 0x90,
  0xbe, 0x46, 0x38, 0x32, 0x92, 0x73, 0x6e, 0x89, 0x4b, 0xff, 0xf6, 0x72,
  0xd9, 0x89, 0x44, 0x4b, 0x50, 0x51, 0xe5, 0x34, 0xa4, 0xb1, 0xf6, 0xdb,
  0xe3, 0xc0, 0xbc, 0x58, 0x1a, 0x32, 0xb7, 0xb1, 0x76, 0x07, 0x0e, 0xde,
  0x12, 0xd6, 0x9a, 0x3f, 0xea, 0x21, 0x1b, 0x66, 0xe7, 0x52, 0xcf, 0x7d,
  0xd1, 0xdd, 0x09, 0x5f, 0x6f, 0x13, 0x70, 0xf4, 0x17, 0x08, 0x43, 0xd9,
  0xdc, 0x10, 0x01, 0x21, 0xe4, 0xcf, 0x63, 0x01, 0x28, 0x09, 0x66, 0x44,
  0x87, 0xc9, 0x79, 0x62, 0x84, 0x30, 0x4d, 0xc5, 0x3f, 0xf4, 0xa3, 0x42,
  0x30, 0x40, 0x30, 0x0f, 0x06, 0x03, 0x55, 0x1d, 0x13, 0x01, 0x01, 0xff,
  0x04, 0x05, 0x30, 0x03, 0x01, 0x01, 0xff, 0x30, 0x1d, 0x06, 0x03, 0x55,
  0x1d, 0x0e, 0x04, 0x16, 0x04, 0x14, 0x90, 0x25, 0xb5, 0x0d, 0xd9, 0x05,
  0x47, 0xe7, 0x96, 0xc3, 0x96, 0xfa, 0x72, 0x9d, 0xcf, 0x99, 0xa9, 0xdf,
  0x4b, 0x96, 0x30, 0x0e, 0x06, 0x03, 0x55, 0x1d, 0x0f, 0x01, 0x01, 0xff,
  0x04, 0x04, 0x03, 0x02, 0x01, 0x86, 0x30, 0x0a, 0x06, 0x08, 0x2a, 0x86,
  0x48, 0xce, 0x3d, 0x04, 0x03, 0x03, 0x03, 0x69, 0x00, 0x30, 0x66, 0x02,
  0x31, 0x00, 0xa3, 0x7f, 0x2f, 0x91, 0xa1, 0xc9, 0xbd, 0x5e, 0xe7, 0xb8,
  0x62, 0x7c, 0x16, 0x98, 0xd2, 0x55, 0x03, 0x8e, 0x1f, 0x03, 0x43, 0xf9,
  0x5b, 0x63, 0xa9, 0x62, 0x8c, 0x3d, 0x39, 0x80, 0x95, 0x45, 0xa1, 0x1e,
  0xbc, 0xbf, 0x2e, 0x3b, 0x55, 0xd8, 0xae, 0xee, 0x71, 0xb4, 0xc3, 0xd6,
  0xad, 0xf3, 0x02, 0x31, 0x00, 0xa2, 0xf3, 0x9b, 0x16, 0x05, 0xb2, 0x70,
  0x28, 0xa5, 0xdd, 0x4b, 0xa0, 0x69, 0xb5, 0x01, 0x6e, 0x65, 0xb4, 0xfb,
  0xde, 0x8f, 0xe0, 0x06, 0x1d, 0x6a, 0x53, 0x19, 0x7f, 0x9c, 0xda, 0xf5,
  0xd9, 0x43, 0xbc, 0x61, 0xfc, 0x2b, 0xeb, 0x03, 0xcb, 0x6f, 0xee, 0x8d,
  0x23, 0x02, 0xf3, 0xdf, 0xf6,
]);

const _coseSign1 = 18;
const _es384 = -35;
const _pcrSize = 48;
const _maxDocumentEntries = 16;
const _maxPcrs = 32;
const _maxCabundle = 8;
const _maxDepth = 16;
const _notBeforeSkew = 300;
const _safe = 0x1fffffffffffff;

const _digitalSignature = 1;
const _keyCertSign = 32;

final Uint8List _ecdsaSha384 = Uint8List.fromList([
  0x06,
  0x08,
  0x2a,
  0x86,
  0x48,
  0xce,
  0x3d,
  0x04,
  0x03,
  0x03,
]);
final Uint8List _ecPublicKey = Uint8List.fromList([
  0x06,
  0x07,
  0x2a,
  0x86,
  0x48,
  0xce,
  0x3d,
  0x02,
  0x01,
]);
final Uint8List _secp384r1 = Uint8List.fromList([
  0x06,
  0x05,
  0x2b,
  0x81,
  0x04,
  0x00,
  0x22,
]);
final Uint8List _basicConstraintsOid = Uint8List.fromList([
  0x06,
  0x03,
  0x55,
  0x1d,
  0x13,
]);
final Uint8List _keyUsageOid = Uint8List.fromList([
  0x06,
  0x03,
  0x55,
  0x1d,
  0x0f,
]);

/// PCR0, PCR1, and PCR2 of one image the policy accepts.
class NitroMeasurement {
  /// Creates a measurement. Each PCR is 48 bytes.
  NitroMeasurement({
    required List<int> pcr0,
    required List<int> pcr1,
    required List<int> pcr2,
  }) : pcr0 = _pcr(pcr0, 'pcr0'),
       pcr1 = _pcr(pcr1, 'pcr1'),
       pcr2 = _pcr(pcr2, 'pcr2');

  /// PCR0, the image digest.
  final Uint8List pcr0;

  /// PCR1.
  final Uint8List pcr1;

  /// PCR2.
  final Uint8List pcr2;
}

/// What a verified Nitro document bound.
class NitroAttestation {
  /// Creates a verdict.
  const NitroAttestation({
    required this.imageId,
    required this.reportData,
    required this.publicKey,
    required this.nonce,
  });

  /// PCR0.
  final Uint8List imageId;

  /// `user_data`, the SHA-512 report binding.
  final Uint8List reportData;

  /// `public_key` from the document.
  final Uint8List publicKey;

  /// Nonce the document committed to.
  final Uint8List nonce;
}

/// Verifies a COSE_Sign1 Nitro document against [measurements].
///
/// The certificate chain must end at [anchors], which defaults to
/// [awsNitroRoot]. [nowSecs] is the unix time the document is checked at.
/// A document whose PCR0 is all zeros is a debug enclave and is refused.
NitroAttestation verifyNitroAttestation({
  required List<int> document,
  required List<NitroMeasurement> measurements,
  required List<int> nonce,
  required List<int> hpkePublicKey,
  required int nowSecs,
  List<int>? pinnedHpkePublicKey,
  List<Uint8List>? anchors,
}) {
  final cose = _cose(Uint8List.fromList(document));
  final payload = _document(cose.payload);
  final leafKey = _chain(
    payload,
    anchors ?? [awsNitroRoot],
    nowSecs,
  );
  final signed = _cborList([
    _cborText('Signature1'),
    _cborBytes(cose.protectedHeader),
    _cborBytes(Uint8List(0)),
    _cborBytes(cose.payload),
  ]);
  if (!p384Verify(cose.signature, signed, leafKey, der: false)) {
    _refuse('signature');
  }
  if (payload.digest != 'SHA384') _refuse('digest');
  if (payload.pcr0.every((byte) => byte == 0)) _refuse('debug_enclave');
  final matched = measurements.any(
    (item) =>
        _equal(item.pcr0, payload.pcr0) &&
        _equal(item.pcr1, payload.pcr1) &&
        _equal(item.pcr2, payload.pcr2),
  );
  if (!matched) _refuse('measurement');
  if (payload.nonce == null || !_equal(payload.nonce!, nonce)) {
    _refuse('nonce');
  }
  if (payload.publicKey == null || !_equal(payload.publicKey!, hpkePublicKey)) {
    _refuse('public_key');
  }
  if (pinnedHpkePublicKey != null &&
      !_equal(pinnedHpkePublicKey, hpkePublicKey)) {
    _refuse('hpke_key');
  }
  if (payload.userData == null) _refuse('report_data');
  return NitroAttestation(
    imageId: payload.pcr0,
    reportData: payload.userData!,
    publicKey: payload.publicKey!,
    nonce: payload.nonce!,
  );
}

/// Bytes a COSE_Sign1 ES384 signature covers for [payload].
///
/// The protected header is the map `{1: -35}`. [encodeCoseSign1] wraps a
/// signature over these bytes.
Uint8List coseSign1Input(List<int> payload, {int alg = _es384}) {
  final protected = _cborMap([
    (key: _cborInt(1), value: _cborInt(alg)),
  ]);
  return _cborList([
    _cborText('Signature1'),
    _cborBytes(protected),
    _cborBytes(Uint8List(0)),
    _cborBytes(Uint8List.fromList(payload)),
  ]);
}

/// COSE_Sign1 bytes around [payload] and a compact P-384 [signature].
///
/// [tagged] wraps the array in CBOR tag 18. The verifier accepts both.
Uint8List encodeCoseSign1(
  List<int> payload,
  List<int> signature, {
  bool tagged = true,
  int alg = _es384,
}) {
  final protected = _cborMap([
    (key: _cborInt(1), value: _cborInt(alg)),
  ]);
  final message = _cborList([
    _cborBytes(protected),
    _cborMap(const []),
    _cborBytes(Uint8List.fromList(payload)),
    _cborBytes(Uint8List.fromList(signature)),
  ]);
  if (!tagged) return message;
  return Uint8List.fromList([0xd2, ...message]);
}

class _Cose {
  _Cose(this.protectedHeader, this.payload, this.signature);
  final Uint8List protectedHeader;
  final Uint8List payload;
  final Uint8List signature;
}

class _Document {
  _Document({
    required this.digest,
    required this.pcr0,
    required this.pcr1,
    required this.pcr2,
    required this.certificate,
    required this.cabundle,
    required this.publicKey,
    required this.userData,
    required this.nonce,
  });
  final String digest;
  final Uint8List pcr0;
  final Uint8List pcr1;
  final Uint8List pcr2;
  final Uint8List certificate;
  final List<Uint8List> cabundle;
  final Uint8List? publicKey;
  final Uint8List? userData;
  final Uint8List? nonce;
}

class _Certificate {
  _Certificate({
    required this.tbs,
    required this.signature,
    required this.publicKey,
    required this.subject,
    required this.issuer,
    required this.notBefore,
    required this.notAfter,
    required this.ca,
    required this.pathLen,
    required this.keyUsage,
  });
  final Uint8List tbs;
  final Uint8List signature;
  final Uint8List publicKey;
  final Uint8List subject;
  final Uint8List issuer;
  final int notBefore;
  final int notAfter;
  final bool ca;
  final int? pathLen;
  final int? keyUsage;
}

_Cose _cose(Uint8List bytes) {
  final decoded = _Cbor(bytes).read(outerTag: _coseSign1);
  if (decoded is! List || decoded.length != 4) _refuse('malformed_attestation');
  final headerBytes = _bytes(decoded[0]);
  final header = _Cbor(headerBytes).read();
  if (header is! Map || header[1] != _es384) _refuse('alg');
  if (decoded[1] is! Map) _refuse('malformed_attestation');
  return _Cose(headerBytes, _bytes(decoded[2]), _bytes(decoded[3]));
}

_Document _document(Uint8List payload) {
  final decoded = _Cbor(payload).read();
  if (decoded is! Map || decoded.length > _maxDocumentEntries) {
    _refuse('malformed_attestation');
  }
  final module = decoded['module_id'];
  if (module is! String || module.isEmpty) _refuse('malformed_attestation');
  final timestamp = decoded['timestamp'];
  if (timestamp is! int || timestamp < 0) _refuse('malformed_attestation');
  final digest = decoded['digest'];
  if (digest is! String) _refuse('malformed_attestation');
  final pcrs = decoded['pcrs'];
  if (pcrs is! Map || pcrs.length > _maxPcrs) _refuse('malformed_attestation');
  final parsed = <int, Uint8List>{};
  for (final entry in pcrs.entries) {
    final index = entry.key;
    if (index is! int || index < 0 || index > 31) {
      _refuse('malformed_attestation');
    }
    parsed[index] = _bytes(entry.value);
  }
  Uint8List pcr(int index) {
    final value = parsed[index];
    if (value == null || value.length != _pcrSize) {
      _refuse('malformed_attestation');
    }
    return value;
  }

  final bundle = decoded['cabundle'];
  if (bundle is! List || bundle.length > _maxCabundle) {
    _refuse('malformed_attestation');
  }
  return _Document(
    digest: digest,
    pcr0: pcr(0),
    pcr1: pcr(1),
    pcr2: pcr(2),
    certificate: _bytes(decoded['certificate']),
    cabundle: [for (final item in bundle) _bytes(item)],
    publicKey: _optionalBytes(decoded['public_key']),
    userData: _optionalBytes(decoded['user_data']),
    nonce: _optionalBytes(decoded['nonce']),
  );
}

Uint8List _chain(_Document document, List<Uint8List> anchors, int nowSecs) {
  if (document.cabundle.isEmpty ||
      !anchors.any((anchor) => _equal(anchor, document.cabundle.first))) {
    _refuse('root');
  }
  final ders = [document.certificate, ...document.cabundle.reversed];
  final chain = [for (final der in ders) _certificate(der)];
  for (var index = 0; index < chain.length; index++) {
    final certificate = chain[index];
    if (nowSecs + _notBeforeSkew < certificate.notBefore ||
        nowSecs > certificate.notAfter) {
      _refuse('certificate_validity');
    }
    if (index + 1 == chain.length) continue;
    final issuer = chain[index + 1];
    if (!issuer.ca) _refuse('certificate_chain');
    final path = issuer.pathLen;
    if (path != null && path < index) _refuse('certificate_chain');
    if (!_permits(issuer.keyUsage, _keyCertSign)) {
      _refuse('certificate_chain');
    }
    if (!_equal(certificate.issuer, issuer.subject) ||
        !p384Verify(
          certificate.signature,
          certificate.tbs,
          issuer.publicKey,
          der: true,
        )) {
      _refuse('certificate_chain');
    }
  }
  final leaf = chain.first;
  if (!_permits(leaf.keyUsage, _digitalSignature)) {
    _refuse('certificate_chain');
  }
  return leaf.publicKey;
}

bool _permits(int? usage, int flag) => usage == null || usage & flag != 0;

_Certificate _certificate(Uint8List der) {
  final cert = _tlv(der);
  if (cert.tag != 0x30 || cert.end != der.length) _refuse('certificate_chain');
  final body = _children(cert);
  if (body.length != 3) _refuse('certificate_chain');
  final tbs = body[0];
  final algorithm = body[1];
  final signature = _bitString(body[2]);
  _algorithm(algorithm);
  final fields = _children(tbs);
  var index = 0;
  if (fields.isNotEmpty && fields.first.tag == 0xa0) index++;
  if (fields.length < index + 7) _refuse('certificate_chain');
  final signatureAlgorithm = fields[index + 1];
  final issuer = fields[index + 2];
  final validity = fields[index + 3];
  final subject = fields[index + 4];
  final keyInfo = fields[index + 5];
  if (!_oidOnly(signatureAlgorithm, _ecdsaSha384)) {
    _refuse('certificate_chain');
  }
  final times = _children(validity);
  if (times.length != 2) _refuse('certificate_chain');
  final keyParts = _children(keyInfo);
  if (keyParts.length != 2) _refuse('certificate_chain');
  final keyAlgorithm = _children(keyParts[0]);
  if (keyAlgorithm.length != 2 ||
      !_equal(keyAlgorithm[0].bytes, _ecPublicKey) ||
      !_equal(keyAlgorithm[1].bytes, _secp384r1)) {
    _refuse('certificate_chain');
  }
  var ca = false;
  int? pathLen;
  int? keyUsage;
  for (final field in fields.skip(index + 6)) {
    if (field.tag == 0xa1 || field.tag == 0xa2) continue;
    if (field.tag != 0xa3) _refuse('certificate_chain');
    final extensions = _children(_only(_children(field)));
    for (final extension in extensions) {
      final parts = _children(extension);
      if (parts.length < 2 || parts.length > 3) {
        _refuse('certificate_chain');
      }
      final oid = parts[0].bytes;
      var critical = false;
      var value = parts[1];
      if (parts.length == 3) {
        if (parts[1].tag != 0x01 || parts[1].value.isEmpty) {
          _refuse('certificate_chain');
        }
        critical = parts[1].value[0] != 0;
        value = parts[2];
      }
      if (_equal(oid, _basicConstraintsOid)) {
        final constraints = _children(_tlv(value.value));
        if (constraints.isNotEmpty && constraints.first.tag == 0x01) {
          ca =
              constraints.first.value.isNotEmpty &&
              constraints.first.value[0] != 0;
        }
        if (constraints.length > 1 && constraints[1].tag == 0x02) {
          pathLen = _integer(constraints[1]).toInt();
        }
      } else if (_equal(oid, _keyUsageOid)) {
        keyUsage = _usage(_bitString(_tlv(value.value), allowUnused: true));
      } else if (critical) {
        _refuse('certificate_chain');
      }
    }
  }
  return _Certificate(
    tbs: tbs.bytes,
    signature: signature,
    publicKey: _bitString(keyParts[1]),
    subject: subject.bytes,
    issuer: issuer.bytes,
    notBefore: _time(times[0]),
    notAfter: _time(times[1]),
    ca: ca,
    pathLen: pathLen,
    keyUsage: keyUsage,
  );
}

Uint8List _algorithm(_Tlv algorithm) {
  final parts = _children(algorithm);
  if (parts.length != 1 || !_equal(parts.single.bytes, _ecdsaSha384)) {
    _refuse('certificate_chain');
  }
  return algorithm.bytes;
}

bool _oidOnly(_Tlv algorithm, Uint8List oid) {
  final parts = _children(algorithm);
  return parts.length == 1 && _equal(parts.single.bytes, oid);
}

Uint8List _bitString(_Tlv node, {bool allowUnused = false}) {
  if (node.tag != 0x03 ||
      node.value.isEmpty ||
      node.value[0] > 7 ||
      (!allowUnused && node.value[0] != 0)) {
    _refuse('certificate_chain');
  }
  return Uint8List.sublistView(node.value, 1);
}

int _usage(Uint8List payload) {
  var value = 0;
  for (var bit = 0; bit < payload.length * 8 && bit < 16; bit++) {
    if (payload[bit >> 3] & (0x80 >> (bit & 7)) != 0) value |= 1 << bit;
  }
  return value;
}

int _time(_Tlv node) {
  final text = ascii.decode(node.value);
  if (node.tag == 0x17 && text.length == 13 && text.endsWith('Z')) {
    final year = int.parse(text.substring(0, 2));
    return _unix(
      year >= 50 ? 1900 + year : 2000 + year,
      text.substring(2),
    );
  }
  if (node.tag == 0x18 && text.length == 15 && text.endsWith('Z')) {
    return _unix(int.parse(text.substring(0, 4)), text.substring(4));
  }
  _refuse('certificate_chain');
}

int _unix(int year, String rest) {
  final month = int.parse(rest.substring(0, 2));
  final day = int.parse(rest.substring(2, 4));
  final hour = int.parse(rest.substring(4, 6));
  final minute = int.parse(rest.substring(6, 8));
  final second = int.parse(rest.substring(8, 10));
  return DateTime.utc(
        year,
        month,
        day,
        hour,
        minute,
        second,
      ).millisecondsSinceEpoch ~/
      1000;
}

BigInt _integer(_Tlv node) {
  if (node.tag != 0x02 || node.value.isEmpty || node.value[0] & 0x80 != 0) {
    _refuse('certificate_chain');
  }
  var value = BigInt.zero;
  for (final byte in node.value) {
    value = (value << 8) | BigInt.from(byte);
  }
  return value;
}

class _Tlv {
  _Tlv(this.tag, this.bytes, this.value, this.end);
  final int tag;
  final Uint8List bytes;
  final Uint8List value;
  final int end;
}

_Tlv _tlv(Uint8List bytes) {
  final read = _readTlv(bytes, 0);
  if (read.end != bytes.length) _refuse('certificate_chain');
  return read;
}

_Tlv _only(List<_Tlv> nodes) {
  if (nodes.length != 1) _refuse('certificate_chain');
  return nodes.single;
}

List<_Tlv> _children(_Tlv node) {
  if (node.tag & 0x20 == 0) _refuse('certificate_chain');
  final nodes = <_Tlv>[];
  var offset = 0;
  while (offset < node.value.length) {
    final child = _readTlv(node.value, offset);
    nodes.add(child);
    offset = child.end;
  }
  return nodes;
}

_Tlv _readTlv(Uint8List bytes, int offset) {
  if (offset >= bytes.length) _refuse('certificate_chain');
  final tag = bytes[offset];
  if (tag & 0x1f == 0x1f) _refuse('certificate_chain');
  if (offset + 1 >= bytes.length) _refuse('certificate_chain');
  final first = bytes[offset + 1];
  var length = first;
  var start = offset + 2;
  if (first & 0x80 != 0) {
    final count = first & 0x7f;
    if (count == 0 || count > 3 || start + count > bytes.length) {
      _refuse('certificate_chain');
    }
    length = 0;
    for (var i = 0; i < count; i++) {
      length = (length << 8) | bytes[start + i];
    }
    start += count;
  }
  if (start + length > bytes.length) _refuse('certificate_chain');
  return _Tlv(
    tag,
    Uint8List.sublistView(bytes, offset, start + length),
    Uint8List.sublistView(bytes, start, start + length),
    start + length,
  );
}

class _Cbor {
  _Cbor(this.bytes);
  final Uint8List bytes;
  var _offset = 0;
  var _depth = 0;

  Object? read({int? outerTag}) {
    final value = _item(outerTag: outerTag, leading: true);
    if (_offset != bytes.length) _refuse('malformed_attestation');
    return value;
  }

  Object? _item({int? outerTag, bool leading = false}) {
    if (_offset >= bytes.length) _refuse('malformed_attestation');
    final initial = bytes[_offset++];
    final major = initial >> 5;
    final info = initial & 0x1f;
    if (major == 6) {
      final tag = _argument(info);
      if (leading && outerTag != null && tag == outerTag) {
        return _item();
      }
      _refuse('malformed_attestation');
    }
    if (major == 0 || major == 1) {
      final argument = _argument(info);
      if (argument > _safe || (major == 1 && argument == _safe)) {
        _refuse('malformed_attestation');
      }
      return major == 0 ? argument : -1 - argument;
    }
    if (major == 2 || major == 3) {
      if (info == 31) _refuse('malformed_attestation');
      final length = _argument(info);
      if (_offset + length > bytes.length) _refuse('malformed_attestation');
      final slice = Uint8List.sublistView(bytes, _offset, _offset + length);
      _offset += length;
      if (major == 2) return Uint8List.fromList(slice);
      try {
        return utf8.decode(slice);
      } on FormatException {
        _refuse('malformed_attestation');
      }
    }
    if (major == 4 || major == 5) {
      if (_depth >= _maxDepth) _refuse('malformed_attestation');
      _depth++;
      final indefinite = info == 31;
      final count = indefinite ? null : _argument(info);
      final values = <Object?>[];
      if (indefinite) {
        while (!_break()) {
          values.add(_item());
        }
      } else {
        final items = major == 5 ? count! * 2 : count!;
        for (var i = 0; i < items; i++) {
          values.add(_item());
        }
      }
      _depth--;
      if (major == 4) return values;
      if (values.length.isOdd) _refuse('malformed_attestation');
      final map = <Object?, Object?>{};
      for (var i = 0; i < values.length; i += 2) {
        final key = values[i];
        if (key is! String && key is! int) _refuse('malformed_attestation');
        if (map.containsKey(key)) _refuse('malformed_attestation');
        map[key] = values[i + 1];
      }
      return map;
    }
    if (major == 7) {
      if (info == 20) return false;
      if (info == 21) return true;
      if (info == 22) return null;
    }
    // Major types are three bits, so this also refuses a simple value
    // other than false, true, or null.
    _refuse('malformed_attestation');
  }

  bool _break() {
    if (_offset >= bytes.length) _refuse('malformed_attestation');
    if (bytes[_offset] != 0xff) return false;
    _offset++;
    return true;
  }

  int _argument(int info) {
    if (info < 24) return info;
    final width = switch (info) {
      24 => 1,
      25 => 2,
      26 => 4,
      27 => 8,
      _ => _badArgument(),
    };
    if (_offset + width > bytes.length) _refuse('malformed_attestation');
    var value = 0;
    for (var i = 0; i < width; i++) {
      value = (value << 8) | bytes[_offset++];
    }
    return value;
  }

  int _badArgument() {
    _refuse('malformed_attestation');
  }
}

Uint8List _cborText(String text) => _headed(3, utf8.encode(text));

Uint8List _cborBytes(List<int> bytes) => _headed(2, bytes);

Uint8List _cborInt(int value) {
  if (value >= 0) return _argumentHeader(0, value);
  return _argumentHeader(1, -1 - value);
}

Uint8List _cborList(List<Uint8List> items) {
  final body = BytesBuilder(copy: false);
  for (final item in items) {
    body.add(item);
  }
  return Uint8List.fromList([
    ..._argumentHeader(4, items.length),
    ...body.toBytes(),
  ]);
}

Uint8List _cborMap(List<({Uint8List key, Uint8List value})> entries) {
  final body = BytesBuilder(copy: false);
  for (final entry in entries) {
    body
      ..add(entry.key)
      ..add(entry.value);
  }
  return Uint8List.fromList([
    ..._argumentHeader(5, entries.length),
    ...body.toBytes(),
  ]);
}

Uint8List _headed(int major, List<int> bytes) {
  return Uint8List.fromList([
    ..._argumentHeader(major, bytes.length),
    ...bytes,
  ]);
}

Uint8List _argumentHeader(int major, int value) {
  if (value < 24) return Uint8List.fromList([(major << 5) | value]);
  if (value < 256) {
    return Uint8List.fromList([(major << 5) | 24, value]);
  }
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

Uint8List _bytes(Object? value) {
  if (value is Uint8List) return value;
  _refuse('malformed_attestation');
}

Uint8List? _optionalBytes(Object? value) {
  if (value == null) return null;
  return _bytes(value);
}

Uint8List _pcr(List<int> bytes, String name) {
  if (bytes.length != _pcrSize) {
    throw PrivacyRingsException(
      '$name is ${bytes.length} bytes, it takes $_pcrSize',
      code: 'invalid_length',
    );
  }
  return Uint8List.fromList(bytes);
}

bool _equal(List<int> left, List<int> right) {
  if (left.length != right.length) return false;
  for (var i = 0; i < left.length; i++) {
    if (left[i] != right[i]) return false;
  }
  return true;
}

Never _refuse(String code) {
  throw PrivacyRingsException('nitro attestation refused: $code', code: code);
}
