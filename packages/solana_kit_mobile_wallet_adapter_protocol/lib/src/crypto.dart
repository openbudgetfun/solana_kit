import 'dart:math';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';

/// The P-256 (prime256v1/secp256r1) elliptic curve domain parameters.
final ECDomainParameters p256 = ECDomainParameters('prime256v1');

/// Creates a cryptographically secure random generator for pointycastle.
SecureRandom createSecureRandom() {
  final random = Random.secure();
  final seed = Uint8List(32);
  for (var i = 0; i < 32; i++) {
    seed[i] = random.nextInt(256);
  }
  return FortunaRandom()..seed(KeyParameter(seed));
}

/// Generates a new P-256 EC keypair.
AsymmetricKeyPair<ECPublicKey, ECPrivateKey> generateP256KeyPair() {
  final generator = ECKeyGenerator()
    ..init(
      ParametersWithRandom(
        ECKeyGeneratorParameters(p256),
        createSecureRandom(),
      ),
    );
  final pair = generator.generateKeyPair();
  return AsymmetricKeyPair(
    pair.publicKey as ECPublicKey,
    pair.privateKey as ECPrivateKey,
  );
}

/// Signs [data] using ECDSA with SHA-256 and returns the signature as
/// concatenated `r(32) || s(32)` bytes (P1363 format, 64 bytes).
Uint8List ecdsaSign(Uint8List data, ECPrivateKey privateKey) {
  final signer = ECDSASigner(SHA256Digest())
    ..init(
      true,
      ParametersWithRandom(
        PrivateKeyParameter<ECPrivateKey>(privateKey),
        createSecureRandom(),
      ),
    );
  final signature = signer.generateSignature(data) as ECSignature;

  // Convert r and s to fixed 32-byte big-endian representations.
  final r = _bigIntToBytes(signature.r, 32);
  final s = _bigIntToBytes(signature.s, 32);

  final result = Uint8List(64)
    ..setAll(0, r)
    ..setAll(32, s);
  return result;
}

/// Verifies an ECDSA SHA-256 signature in P1363 format (`r(32) || s(32)`).
bool ecdsaVerify(
  Uint8List data,
  Uint8List signatureBytes,
  ECPublicKey publicKey,
) {
  final r = _bytesToBigInt(signatureBytes.sublist(0, 32));
  final s = _bytesToBigInt(signatureBytes.sublist(32, 64));

  final verifier = ECDSASigner(SHA256Digest())
    ..init(false, PublicKeyParameter<ECPublicKey>(publicKey));
  return verifier.verifySignature(data, ECSignature(r, s));
}

/// Performs ECDH P-256 key agreement and returns the 32-byte shared secret
/// (the x-coordinate of the shared point).
Uint8List ecdhSharedSecret(ECPrivateKey privateKey, ECPublicKey publicKey) {
  final point = publicKey.Q! * privateKey.d;
  if (point == null || point.isInfinity) {
    throw StateError('ECDH agreement produced point at infinity');
  }
  return _bigIntToBytes(point.x!.toBigInteger()!, 32);
}

/// Exports an [ECPublicKey] as 65-byte X9.62 uncompressed format.
///
/// Format: `0x04 || x(32) || y(32)`
Uint8List ecPublicKeyToBytes(ECPublicKey publicKey) {
  return Uint8List.fromList(publicKey.Q!.getEncoded(false));
}

/// Imports a 65-byte X9.62 uncompressed public key as an [ECPublicKey].
ECPublicKey ecPublicKeyFromBytes(Uint8List bytes) {
  final point = p256.curve.decodePoint(bytes);
  return ECPublicKey(point, p256);
}

/// Derives a key using HKDF-SHA256.
///
/// [ikm] is the input keying material.
/// [salt] is the optional salt (can be empty).
/// [info] is the optional context info (can be empty).
/// [outputLength] is the desired key length in bytes.
Uint8List hkdfSha256({
  required Uint8List ikm,
  required Uint8List salt,
  required Uint8List info,
  required int outputLength,
}) {
  final hkdf = HKDFKeyDerivator(SHA256Digest())
    ..init(HkdfParameters(ikm, outputLength, salt, info));
  final output = Uint8List(outputLength);
  hkdf.deriveKey(null, 0, output, 0);
  return output;
}

/// Encrypts [plaintext] using AES-128-GCM.
///
/// Returns the ciphertext with the 16-byte authentication tag appended.
Uint8List aesGcmEncrypt({
  required Uint8List plaintext,
  required Uint8List key,
  required Uint8List nonce,
  required Uint8List aad,
}) {
  final cipher = GCMBlockCipher(AESEngine())
    ..init(true, AEADParameters(KeyParameter(key), 128, nonce, aad));
  final output = Uint8List(plaintext.length + 16); // +16 for GCM tag
  var offset = cipher.processBytes(plaintext, 0, plaintext.length, output, 0);
  offset += cipher.doFinal(output, offset);
  return output.sublist(0, offset);
}

/// Decrypts [ciphertextWithTag] using AES-128-GCM.
///
/// The [ciphertextWithTag] must include the 16-byte authentication tag
/// appended to the ciphertext.
///
/// Throws [InvalidCipherTextException] if authentication fails.
Uint8List aesGcmDecrypt({
  required Uint8List ciphertextWithTag,
  required Uint8List key,
  required Uint8List nonce,
  required Uint8List aad,
}) {
  final cipher = GCMBlockCipher(AESEngine())
    ..init(false, AEADParameters(KeyParameter(key), 128, nonce, aad));
  final output = Uint8List(ciphertextWithTag.length);
  var offset = cipher.processBytes(
    ciphertextWithTag,
    0,
    ciphertextWithTag.length,
    output,
    0,
  );
  offset += cipher.doFinal(output, offset);
  return output.sublist(0, offset);
}

/// Generates [length] cryptographically secure random bytes.
Uint8List randomBytes(int length) {
  final random = Random.secure();
  return Uint8List.fromList(List.generate(length, (_) => random.nextInt(256)));
}

/// Converts a [BigInt] to a fixed-length unsigned big-endian byte array.
Uint8List _bigIntToBytes(BigInt value, int length) {
  final result = Uint8List(length);
  var v = value;
  for (var i = length - 1; i >= 0; i--) {
    result[i] = (v & BigInt.from(0xFF)).toInt();
    v >>= 8;
  }
  return result;
}

/// Converts unsigned big-endian bytes to a [BigInt].
BigInt _bytesToBigInt(Uint8List bytes) {
  var result = BigInt.zero;
  for (var i = 0; i < bytes.length; i++) {
    result = (result << 8) | BigInt.from(bytes[i]);
  }
  return result;
}
