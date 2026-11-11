import 'dart:typed_data';

import 'package:solana_kit_privacy_rings/src/exception.dart';
import 'package:solana_kit_privacy_rings/src/poseidon/poseidon.dart';

/// Poseidon nullifier key.
///
/// `NullifierKey` in `sdk-libs/ts/src/keypair/nullifier-key.ts`. The secret
/// is 31 bytes. Its public key is `Poseidon(rightAlign(secret))`, and a
/// note nullifier is `Poseidon(utxoHash, blinding, rightAlign(secret))`.
class NullifierKey {
  /// Creates a key from a 31-byte secret.
  NullifierKey.fromSecret(List<int> secret)
    : _secret = Uint8List.fromList(secret) {
    if (_secret.length != 31) {
      throw PrivacyRingsException(
        'nullifier secret is ${_secret.length} bytes, it takes 31',
        code: 'invalid_length',
      );
    }
  }

  final Uint8List _secret;
  var _destroyed = false;

  /// `Poseidon` of the right-aligned secret.
  Uint8List publicKey() {
    _usable();
    return poseidonHash([rightAlign(_secret)]);
  }

  /// Nullifier of a note with [utxoHash] and [blinding].
  Uint8List nullifier(Uint8List utxoHash, Uint8List blinding) {
    _usable();
    return poseidonHash([utxoHash, blinding, rightAlign(_secret)]);
  }

  /// Nullifier of an unused proof slot under an all-zero secret.
  static Uint8List zeroKeyNullifier(Uint8List utxoHash, Uint8List blinding) {
    return poseidonHash([utxoHash, blinding, Uint8List(32)]);
  }

  /// Wipes the secret. Later calls throw.
  void destroy() {
    _secret.fillRange(0, _secret.length, 0);
    _destroyed = true;
  }

  void _usable() {
    if (_destroyed) {
      throw PrivacyRingsException(
        'nullifier key was destroyed',
        code: 'destroyed_key',
      );
    }
  }
}
