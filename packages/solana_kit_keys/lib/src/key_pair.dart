import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:ed25519_edwards/ed25519_edwards.dart' as ed;
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';

import 'package:solana_kit_keys/src/private_key.dart';
import 'package:solana_kit_keys/src/public_key.dart';
import 'package:solana_kit_keys/src/signatures.dart';

/// Finalizer that zeros out byte arrays when KeyPair instances are GC'd.
///
/// This is a best-effort mitigation against private key material persisting
/// in memory. Dart's GC does not guarantee deterministic finalization, so
/// the zeroing may happen later than desired or not at all if the process
/// terminates abruptly.
final Finalizer<(Uint8List, Uint8List)> _keyPairFinalizer = Finalizer((keys) {
  _zeroBytes(keys.$1);
  _zeroBytes(keys.$2);
});

/// Zeros out all bytes in a [Uint8List].
///
/// Note: The Dart VM may theoretically optimize this away if it determines
/// the buffer is no longer read. In practice, this provides reasonable
/// protection against casual memory inspection.
void _zeroBytes(Uint8List bytes) {
  for (var i = 0; i < bytes.length; i++) {
    bytes[i] = 0;
  }
}

/// An Ed25519 key pair consisting of a 32-byte private key and a 32-byte
/// public key.
///
/// Key bytes are stored internally and defensive copies are returned from
/// getters to prevent external mutation of key material.
///
/// When the [KeyPair] is garbage collected, the internal key bytes are
/// zeroed out as a best-effort security measure. For explicit control,
/// call [dispose] to zero the bytes immediately.
class KeyPair {
  /// Creates a [KeyPair] from the given [privateKey] and [publicKey] bytes.
  KeyPair({required Uint8List privateKey, required Uint8List publicKey})
    : _privateKey = Uint8List.fromList(privateKey),
      _publicKey = Uint8List.fromList(publicKey) {
    _keyPairFinalizer.attach(this, (_privateKey, _publicKey), detach: this);
  }

  final Uint8List _privateKey;
  final Uint8List _publicKey;

  bool _isDisposed = false;

  /// Whether [dispose] has been called.
  bool get isDisposed => _isDisposed;

  /// The 32-byte Ed25519 private key (seed).
  ///
  /// Returns a defensive copy to prevent external mutation.
  /// Throws [StateError] if [dispose] has been called.
  Uint8List get privateKey {
    if (_isDisposed) {
      throw StateError('KeyPair has been disposed');
    }
    return Uint8List.fromList(_privateKey);
  }

  /// The 32-byte Ed25519 public key.
  ///
  /// Returns a defensive copy to prevent external mutation.
  /// Throws [StateError] if [dispose] has been called.
  Uint8List get publicKey {
    if (_isDisposed) {
      throw StateError('KeyPair has been disposed');
    }
    return Uint8List.fromList(_publicKey);
  }

  /// Explicitly zeros out the internal key bytes.
  ///
  /// After calling this method, [privateKey] and [publicKey] getters will
  /// throw [StateError]. This is idempotent - calling dispose multiple times
  /// is safe.
  ///
  /// This is recommended when you're done with a key pair to minimize the
  /// window where sensitive material exists in memory.
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    _zeroBytes(_privateKey);
    _zeroBytes(_publicKey);
    _keyPairFinalizer.detach(this);
  }
}

/// Generates a new random Ed25519 key pair.
///
/// Returns a [KeyPair] with a randomly generated 32-byte private key and its
/// corresponding 32-byte public key.
KeyPair generateKeyPair() {
  final keyPair = ed.generateKey();
  final seed = keyPair.privateKey.bytes.sublist(0, 32);
  final publicKeyBytes = keyPair.publicKey.bytes;
  return KeyPair(
    privateKey: Uint8List.fromList(seed),
    publicKey: Uint8List.fromList(publicKeyBytes),
  );
}

/// A predicate used to test whether a generated address satisfies a key grind.
typedef GrindKeyPairPredicate = bool Function(String address);

const _base58Alphabet =
    '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';

/// Generates [amount] key pairs whose base58-encoded public key satisfies
/// [matches].
///
/// [matches] may be a [RegExp] or a [GrindKeyPairPredicate]. A regular
/// expression's literal characters are validated against the base58 alphabet to
/// catch impossible grinds like `RegExp(r'^ab0')` before key generation starts.
Future<List<KeyPair>> grindKeyPairs({
  required Object matches,
  int amount = 1,
  int concurrency = 32,
}) async {
  final matcher = _createGrindMatcher(matches);
  if (amount <= 0) return <KeyPair>[];

  final found = <KeyPair>[];
  final batchSize = concurrency <= 0 ? 1 : concurrency;
  while (found.length < amount) {
    for (var i = 0; i < batchSize && found.length < amount; i++) {
      final keyPair = generateKeyPair();
      final addr = getAddressFromPublicKey(keyPair.publicKey).value;
      if (matcher(addr)) found.add(keyPair);
    }
    await Future<void>.delayed(Duration.zero);
  }

  return found;
}

/// Generates one key pair whose base58-encoded public key satisfies [matches].
Future<KeyPair> grindKeyPair({
  required Object matches,
  int concurrency = 32,
}) async {
  final keyPairs = await grindKeyPairs(
    matches: matches,
    concurrency: concurrency,
  );
  return keyPairs.single;
}

GrindKeyPairPredicate _createGrindMatcher(Object matches) {
  if (matches is GrindKeyPairPredicate) return matches;
  if (matches is RegExp) {
    _assertGrindRegexIsValid(matches);
    return matches.hasMatch;
  }

  throw ArgumentError.value(matches, 'matches', 'Expected RegExp or predicate');
}

void _assertGrindRegexIsValid(RegExp regex) {
  final stripped = regex.pattern
      .replaceAll(RegExp(r'\\.|\[[^\]]*\]|\{[^}]*\}|\([^)]*\)'), '')
      .replaceAll(RegExp(r'[$()*+./?\[\]^{|}]'), '');

  for (final rune in stripped.runes) {
    final character = String.fromCharCode(rune);
    if (!_isBase58Character(character, caseSensitive: regex.isCaseSensitive)) {
      throw SolanaError(SolanaErrorCode.keysInvalidBase58InGrindRegex, {
        'character': character,
        'source': regex.pattern,
      });
    }
  }
}

bool _isBase58Character(String character, {required bool caseSensitive}) {
  if (_base58Alphabet.contains(character)) return true;
  return !caseSensitive &&
      (_base58Alphabet.contains(character.toLowerCase()) ||
          _base58Alphabet.contains(character.toUpperCase()));
}

/// Creates a [KeyPair] from a 64-byte array where the first 32 bytes
/// represent the private key and the last 32 bytes represent the public key.
///
/// Throws a [SolanaError] with code
/// [SolanaErrorCode.keysInvalidKeyPairByteLength] if [bytes] is not exactly
/// 64 bytes.
///
/// Throws a [SolanaError] with code
/// [SolanaErrorCode.keysPublicKeyMustMatchPrivateKey] if the public key bytes
/// do not match the public key derived from the private key bytes.
KeyPair createKeyPairFromBytes(Uint8List bytes) {
  if (bytes.length != 64) {
    throw SolanaError(SolanaErrorCode.keysInvalidKeyPairByteLength, {
      'byteLength': bytes.length,
    });
  }

  final privateKeyBytes = Uint8List.sublistView(bytes, 0, 32);
  final publicKeyBytes = Uint8List.sublistView(bytes, 32, 64);

  // Verify the public key matches the private key by signing and verifying
  // random data.
  final derivedPublicKey = getPublicKeyFromPrivateKey(privateKeyBytes);
  final testData = Uint8List.fromList([0, 1, 2, 3]);
  final sig = signBytes(privateKeyBytes, testData);
  final isValid = verifySignature(derivedPublicKey, sig, testData);
  if (!isValid) {
    throw SolanaError(SolanaErrorCode.keysPublicKeyMustMatchPrivateKey);
  }

  // Also verify the provided public key matches the derived one using
  // constant-time comparison to prevent timing attacks.
  if (!constantTimeEqual(publicKeyBytes, derivedPublicKey)) {
    throw SolanaError(SolanaErrorCode.keysPublicKeyMustMatchPrivateKey);
  }

  return KeyPair(
    privateKey: Uint8List.fromList(privateKeyBytes),
    publicKey: Uint8List.fromList(publicKeyBytes),
  );
}

/// Creates a [KeyPair] from a 32-byte private key, deriving the corresponding
/// public key.
///
/// Throws a [SolanaError] with code
/// [SolanaErrorCode.keysInvalidPrivateKeyByteLength] if [bytes] is not
/// exactly 32 bytes.
KeyPair createKeyPairFromPrivateKeyBytes(Uint8List bytes) {
  assertIsPrivateKey(bytes);
  final publicKeyBytes = getPublicKeyFromPrivateKey(bytes);
  return KeyPair(
    privateKey: Uint8List.fromList(bytes),
    publicKey: publicKeyBytes,
  );
}

/// Writes a [KeyPair] to disk using the JSON byte-array format produced by
/// `solana-keygen`.
///
/// The first 32 bytes are the private key and the last 32 bytes are the public
/// key. Parent directories are created automatically. Existing files are not
/// overwritten unless [unsafelyOverwriteExistingKeyPair] is `true`.
Future<void> writeKeyPair(
  KeyPair keyPair,
  String path, {
  bool unsafelyOverwriteExistingKeyPair = false,
}) async {
  final privateKey = keyPair.privateKey;
  final publicKey = keyPair.publicKey;
  assertIsPrivateKey(privateKey);

  final bytes = Uint8List(64)
    ..setRange(0, 32, privateKey)
    ..setRange(32, 64, publicKey);
  final file = File(path);
  final parent = file.parent;
  if (parent.path.isNotEmpty) {
    await parent.create(recursive: true);
  }

  if (!unsafelyOverwriteExistingKeyPair && file.existsSync()) {
    throw FileSystemException('Key pair file already exists', path);
  }

  final sink = await file.open(mode: FileMode.writeOnly);
  try {
    await sink.writeString(jsonEncode(bytes.toList()));
  } finally {
    await sink.close();
  }

  if (!Platform.isWindows) {
    await Process.run('chmod', ['600', path]);
  }
}

/// Compares two byte arrays in constant time to prevent timing attacks.
///
/// Returns `true` if both arrays have the same length and identical contents.
/// The comparison always examines all bytes regardless of where mismatches
/// occur, preventing an attacker from learning partial key information through
/// timing side-channels.
bool constantTimeEqual(Uint8List a, Uint8List b) {
  if (a.length != b.length) return false;
  var result = 0;
  for (var i = 0; i < a.length; i++) {
    result |= a[i] ^ b[i];
  }
  return result == 0;
}
