import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import 'package:solana_kit_privacy_rings/src/bytes.dart';
import 'package:solana_kit_privacy_rings/src/exception.dart';

const _hpkePrefix = 'TSPP/hpke/';
const _transferInfo = 'TSPP/tx';
const _ringDepositInfo = 'TSPP/ring_deposit';

/// X25519 viewing key for confidential notes.
///
/// The key is clamped the way `clampViewingSecret` clamps it in
/// `sdk-libs/ts/src/keypair/derivation.ts`. Encryption is AES-256-CTR with
/// the HKDF info string `TSPP/hpke/TSPP/tx`, matching `applyTransferCipher`
/// in `sdk-libs/ts/src/keypair/encryption.ts`.
class ViewingKey {
  ViewingKey._(this._secret);

  /// Builds a viewing key from 32 secret bytes.
  ///
  /// The bytes are clamped: the low three bits of the first byte are
  /// cleared, and the high bit of the last byte is cleared and the next
  /// bit set.
  factory ViewingKey.fromBytes(List<int> bytes) {
    final secret = copyBytes(bytes, 32, 'viewing secret');
    secret[0] &= 248;
    secret[31] = (secret[31] & 127) | 64;
    return ViewingKey._(secret);
  }

  final Uint8List _secret;

  /// Tagged public key: `0x04 || u-coordinate`.
  Future<Uint8List> publicKey() async {
    final raw = await _publicCoordinate(_secret);
    return Uint8List.fromList([4, ...raw]);
  }

  /// Decrypts one confidential slot.
  ///
  /// [txViewingPublicKey] is the transaction's tagged ephemeral key.
  /// [salt] is the 16-byte transaction salt. [slotIndex] is the output's
  /// index in that transaction, not the Merkle leaf index.
  Future<Uint8List> decryptSlot({
    required List<int> txViewingPublicKey,
    required List<int> ciphertext,
    required List<int> salt,
    required int slotIndex,
    String infoLabel = _transferInfo,
  }) async {
    final txKey = _taggedKey(txViewingPublicKey, 'txViewingPublicKey');
    final recipient = await publicKey();
    return _applyCipher(
      secret: _secret,
      counterparty: txKey,
      ephemeralPublicKey: txKey,
      recipientPublicKey: recipient,
      input: ciphertext,
      salt: copyBytes(salt, 16, 'salt'),
      slotIndex: slotIndex,
      infoLabel: infoLabel,
    );
  }

  /// Encrypts one confidential slot to [recipientPublicKey].
  Future<Uint8List> encryptSlot({
    required List<int> recipientPublicKey,
    required List<int> plaintext,
    required List<int> salt,
    required int slotIndex,
  }) async {
    final recipient = _taggedKey(recipientPublicKey, 'recipientPublicKey');
    final ephemeral = await publicKey();
    return _applyCipher(
      secret: _secret,
      counterparty: recipient,
      ephemeralPublicKey: ephemeral,
      recipientPublicKey: recipient,
      input: plaintext,
      salt: copyBytes(salt, 16, 'salt'),
      slotIndex: slotIndex,
      infoLabel: _transferInfo,
    );
  }

  /// Decrypts a ring-deposit ciphertext. The slot index is fixed at 0 and
  /// the info label is `TSPP/ring_deposit`.
  Future<Uint8List> decryptRingDeposit({
    required List<int> txViewingPublicKey,
    required List<int> ciphertext,
    required List<int> salt,
  }) {
    return decryptSlot(
      txViewingPublicKey: txViewingPublicKey,
      ciphertext: ciphertext,
      salt: salt,
      slotIndex: 0,
      infoLabel: _ringDepositInfo,
    );
  }
}

Uint8List _taggedKey(List<int> bytes, String name) {
  final key = copyBytes(bytes, 33, name);
  if (key[0] != 4) {
    throw PrivacyRingsException(
      '$name is missing the 0x04 coordinate tag',
      code: 'invalid_public_key',
    );
  }
  var u = BigInt.zero;
  for (var i = 32; i >= 1; i--) {
    u = (u << 8) | BigInt.from(key[i]);
  }
  final field = (BigInt.one << 255) - BigInt.from(19);
  if (u >= field) {
    throw PrivacyRingsException(
      '$name coordinate is not canonical',
      code: 'invalid_public_key',
    );
  }
  return key;
}

Future<Uint8List> _publicCoordinate(Uint8List secret) async {
  final pair = await X25519().newKeyPairFromSeed(secret);
  final publicKey = await pair.extractPublicKey();
  if (publicKey.bytes.length != 32) {
    throw PrivacyRingsException(
      'X25519 public key was ${publicKey.bytes.length} bytes',
      code: 'invalid_public_key',
    );
  }
  return Uint8List.fromList(publicKey.bytes);
}

Future<Uint8List> _applyCipher({
  required Uint8List secret,
  required Uint8List counterparty,
  required Uint8List ephemeralPublicKey,
  required Uint8List recipientPublicKey,
  required List<int> input,
  required Uint8List salt,
  required int slotIndex,
  required String infoLabel,
}) async {
  if (slotIndex < 0 || slotIndex > 0xffffffff) {
    throw PrivacyRingsException(
      'slotIndex is outside 0..2^32-1',
      code: 'integer_range',
    );
  }
  final shared = await _sharedSecret(secret, counterparty);
  if (shared.every((byte) => byte == 0)) {
    throw PrivacyRingsException(
      'X25519 shared secret is zero',
      code: 'non_contributory_key',
    );
  }
  final ikm = Uint8List.fromList([
    ...shared,
    ...ephemeralPublicKey,
    ...recipientPublicKey,
  ]);
  final info = Uint8List.fromList([
    ...utf8.encode(_hpkePrefix),
    ...utf8.encode(infoLabel),
    ...salt,
    ...u32be(slotIndex),
  ]);
  final hkdf = Hkdf(hmac: Hmac.sha256(), outputLength: 44);
  final expanded = await hkdf.deriveKey(
    secretKey: SecretKey(ikm),
    nonce: Uint8List(32),
    info: info,
  );
  final okm = Uint8List.fromList(await expanded.extractBytes());
  if (okm.length != 44) {
    throw PrivacyRingsException(
      'HKDF returned ${okm.length} bytes',
      code: 'hkdf',
    );
  }
  final key = Uint8List.sublistView(okm, 0, 32);
  final counter = Uint8List(16)..setRange(0, 12, okm.sublist(32));
  counter[15] = 2;
  final box = await AesCtr.with256bits(macAlgorithm: MacAlgorithm.empty)
      .encrypt(
        input,
        secretKey: SecretKey(key),
        nonce: counter,
      );
  return Uint8List.fromList(box.cipherText);
}

Future<Uint8List> _sharedSecret(Uint8List secret, Uint8List taggedPeer) async {
  final pair = await X25519().newKeyPairFromSeed(secret);
  final shared = await X25519().sharedSecretKey(
    keyPair: pair,
    remotePublicKey: SimplePublicKey(
      Uint8List.sublistView(taggedPeer, 1),
      type: KeyPairType.x25519,
    ),
  );
  return Uint8List.fromList(await shared.extractBytes());
}
