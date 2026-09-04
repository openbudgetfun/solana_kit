import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:solana_kit_dapp_publisher_cli/src/errors.dart';

/// The default content type for APK uploads.
const apkContentType = 'application/vnd.android.package-archive';

/// Computes the lowercase hexadecimal SHA-256 digest of [bytes].
///
/// The implementation follows FIPS 180-4 and is verified against the standard
/// test vectors in this package's test suite.
String sha256Hex(Uint8List bytes) {
  final message = _padMessage(bytes);
  final words = _parseMessage(message);
  var h0 = 0x6a09e667;
  var h1 = 0xbb67ae85;
  var h2 = 0x3c6ef372;
  var h3 = 0xa54ff53a;
  var h4 = 0x510e527f;
  var h5 = 0x9b05688c;
  var h6 = 0x1f83d9ab;
  var h7 = 0x5be0cd19;

  const k = <int>[
    0x428a2f98,
    0x71374491,
    0xb5c0fbcf,
    0xe9b5dba5,
    0x3956c25b,
    0x59f111f1,
    0x923f82a4,
    0xab1c5ed5,
    0xd807aa98,
    0x12835b01,
    0x243185be,
    0x550c7dc3,
    0x72be5d74,
    0x80deb1fe,
    0x9bdc06a7,
    0xc19bf174,
    0xe49b69c1,
    0xefbe4786,
    0x0fc19dc6,
    0x240ca1cc,
    0x2de92c6f,
    0x4a7484aa,
    0x5cb0a9dc,
    0x76f988da,
    0x983e5152,
    0xa831c66d,
    0xb00327c8,
    0xbf597fc7,
    0xc6e00bf3,
    0xd5a79147,
    0x06ca6351,
    0x14292967,
    0x27b70a85,
    0x2e1b2138,
    0x4d2c6dfc,
    0x53380d13,
    0x650a7354,
    0x766a0abb,
    0x81c2c92e,
    0x92722c85,
    0xa2bfe8a1,
    0xa81a664b,
    0xc24b8b70,
    0xc76c51a3,
    0xd192e819,
    0xd6990624,
    0xf40e3585,
    0x106aa070,
    0x19a4c116,
    0x1e376c08,
    0x2748774c,
    0x34b0bcb5,
    0x391c0cb3,
    0x4ed8aa4a,
    0x5b9cca4f,
    0x682e6ff3,
    0x748f82ee,
    0x78a5636f,
    0x84c87814,
    0x8cc70208,
    0x90befffa,
    0xa4506ceb,
    0xbef9a3f7,
    0xc67178f2,
  ];

  for (var block = 0; block < words.length; block += 16) {
    final w = Uint32List(64);
    for (var t = 0; t < 16; t++) {
      w[t] = words[block + t];
    }
    for (var t = 16; t < 64; t++) {
      final s0 =
          _rotateRight(w[t - 15], 7) ^
          _rotateRight(w[t - 15], 18) ^
          (w[t - 15] >>> 3);
      final s1 =
          _rotateRight(w[t - 2], 17) ^
          _rotateRight(w[t - 2], 19) ^
          (w[t - 2] >>> 10);
      w[t] = (w[t - 16] + s0 + w[t - 7] + s1) & 0xffffffff;
    }

    var a = h0;
    var b = h1;
    var c = h2;
    var d = h3;
    var e = h4;
    var f = h5;
    var g = h6;
    var hh = h7;

    for (var t = 0; t < 64; t++) {
      final s1 = _rotateRight(e, 6) ^ _rotateRight(e, 11) ^ _rotateRight(e, 25);
      final ch = (e & f) ^ ((~e & 0xffffffff) & g);
      final temp1 = (hh + s1 + ch + k[t] + w[t]) & 0xffffffff;
      final s0 = _rotateRight(a, 2) ^ _rotateRight(a, 13) ^ _rotateRight(a, 22);
      final maj = (a & b) ^ (a & c) ^ (b & c);
      final temp2 = (s0 + maj) & 0xffffffff;

      hh = g;
      g = f;
      f = e;
      e = (d + temp1) & 0xffffffff;
      d = c;
      c = b;
      b = a;
      a = (temp1 + temp2) & 0xffffffff;
    }

    h0 = (h0 + a) & 0xffffffff;
    h1 = (h1 + b) & 0xffffffff;
    h2 = (h2 + c) & 0xffffffff;
    h3 = (h3 + d) & 0xffffffff;
    h4 = (h4 + e) & 0xffffffff;
    h5 = (h5 + f) & 0xffffffff;
    h6 = (h6 + g) & 0xffffffff;
    h7 = (h7 + hh) & 0xffffffff;
  }

  final digest = BytesBuilder()
    ..add(_u32be(h0))
    ..add(_u32be(h1))
    ..add(_u32be(h2))
    ..add(_u32be(h3))
    ..add(_u32be(h4))
    ..add(_u32be(h5))
    ..add(_u32be(h6))
    ..add(_u32be(h7));
  return base16Encode(digest.toBytes());
}

/// Returns the SHA-256 digest of the contents of [path] as lowercase hex.
String hashFileSha256(String path) => sha256Hex(File(path).readAsBytesSync());

/// Pads the message per FIPS 180-4: append 0x80, zero fill to 56 mod 64, and
/// append the 64-bit big-endian bit length.
Uint8List _padMessage(Uint8List bytes) {
  final bitLength = bytes.length * 8;
  final paddedLength = ((bytes.length + 8) ~/ 64 + 1) * 64;
  final padded = Uint8List(paddedLength)
    ..setRange(0, bytes.length, bytes)
    ..[bytes.length] = 0x80;
  final lengthBytes = ByteData(8)..setUint64(0, bitLength);
  padded.setRange(
    paddedLength - 8,
    paddedLength,
    lengthBytes.buffer.asUint8List(),
  );
  return padded;
}

Uint32List _parseMessage(Uint8List message) {
  final words = Uint32List(message.length ~/ 4);
  final view = ByteData.sublistView(message);
  for (var i = 0; i < words.length; i++) {
    words[i] = view.getUint32(i * 4);
  }
  return words;
}

int _rotateRight(int value, int bits) =>
    ((value >>> bits) | (value << (32 - bits))) & 0xffffffff;

Uint8List _u32be(int value) {
  final data = ByteData(4)..setUint32(0, value);
  return data.buffer.asUint8List();
}

/// Lowercase hexadecimal encoding of [bytes].
String base16Encode(Uint8List bytes) {
  const digits = '0123456789abcdef';
  final out = StringBuffer();
  for (final byte in bytes) {
    out
      ..write(digits[(byte >> 4) & 0xf])
      ..write(digits[byte & 0xf]);
  }
  return out.toString();
}

/// Substring helpers that tolerate short strings.
extension SafeSubstring on String {
  /// Returns a substring of at most [end - start] characters without throwing
  /// when the string is shorter than [end].
  String substringSafe(int start, int end) {
    if (length <= start) {
      return '';
    }
    return substring(start, length < end ? length : end);
  }
}

/// Decodes a base64 string into bytes.
Uint8List base64DecodeBytes(String value) {
  try {
    return base64.decode(value);
  } on FormatException {
    throw const PublisherCliException('Failed to decode a base64 payload.');
  }
}

/// Infers a file name from the final path segment of [url], mirroring the
/// upstream CLI. Returns `null` when no segment can be inferred.
String? inferFileNameFromUrl(String url) {
  final parsed = Uri.tryParse(url);
  if (parsed == null) {
    return null;
  }
  final segments = parsed.pathSegments
      .where((segment) => segment.isNotEmpty)
      .toList();
  if (segments.isEmpty) {
    return null;
  }
  return segments.last;
}

/// Ensures that [fileName] ends with the `.apk` extension, appending it when
/// missing.
String ensureApkFileName(String fileName) {
  final normalized = fileName.trim();
  if (normalized.toLowerCase().endsWith('.apk')) {
    return normalized;
  }
  return '$normalized.apk';
}

/// Infers a MIME type from a [fileName]'s extension, falling back to
/// `application/octet-stream`.
String inferMimeType(String? fileName) {
  if (fileName == null || fileName.isEmpty) {
    return 'application/octet-stream';
  }
  final extension = fileName.contains('.')
      ? fileName.substring(fileName.lastIndexOf('.') + 1).toLowerCase()
      : '';
  return switch (extension) {
    'apk' => apkContentType,
    'png' => 'image/png',
    'jpg' || 'jpeg' => 'image/jpeg',
    'webp' => 'image/webp',
    'gif' => 'image/gif',
    'svg' => 'image/svg+xml',
    'mp4' => 'video/mp4',
    'webm' => 'video/webm',
    'mov' => 'video/quicktime',
    'json' => 'application/json',
    '' => 'application/octet-stream',
    _ => 'application/octet-stream',
  };
}

/// Normalizes a URL string, stripping a trailing slash.
String normalizeUrl(String value) => _stripTrailingSlash(Uri.parse(value));

/// Ensures that [value] is an absolute HTTPS URL, prefixing `https://` when
/// the scheme is missing.
String ensureHttpsUrl(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    return trimmed;
  }
  if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
    return _stripTrailingSlash(Uri.parse(trimmed));
  }
  return _stripTrailingSlash(Uri.parse('https://$trimmed'));
}

String _stripTrailingSlash(Uri uri) {
  final normalized = uri.normalizePath().toString();
  return normalized.endsWith('/')
      ? normalized.substring(0, normalized.length - 1)
      : normalized;
}
