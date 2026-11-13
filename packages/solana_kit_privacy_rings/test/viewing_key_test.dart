import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:solana_kit_privacy_rings/solana_kit_privacy_rings.dart';
import 'package:test/test.dart';

File _fixture() {
  const relative = 'test/fixtures/viewing_key_vector.json';
  final local = File(relative);
  if (local.existsSync()) return local;
  return File('packages/solana_kit_privacy_rings/$relative');
}

Uint8List _hex(String value) {
  final bytes = Uint8List(value.length ~/ 2);
  for (var i = 0; i < bytes.length; i++) {
    bytes[i] = int.parse(value.substring(i * 2, i * 2 + 2), radix: 16);
  }
  return bytes;
}

void main() {
  final vector =
      jsonDecode(_fixture().readAsStringSync()) as Map<String, Object?>;

  test(
    'viewing-key encryption matches @noble, which the TypeScript SDK uses',
    () async {
      final sender = ViewingKey.fromBytes(_hex(vector['secret']! as String));
      final recipient = ViewingKey.fromBytes(
        _hex(vector['recipientSecret']! as String),
      );
      expect(await sender.publicKey(), _hex(vector['publicKey']! as String));
      expect(
        await recipient.publicKey(),
        _hex(vector['recipientPublicKey']! as String),
      );
      final salt = _hex(vector['salt']! as String);
      final plaintext = _hex(vector['plaintext']! as String);
      final ciphertext = await sender.encryptSlot(
        recipientPublicKey: await recipient.publicKey(),
        plaintext: plaintext,
        salt: salt,
        slotIndex: vector['slotIndex']! as int,
      );
      expect(ciphertext, _hex(vector['ciphertext']! as String));
      expect(
        await recipient.decryptSlot(
          txViewingPublicKey: await sender.publicKey(),
          ciphertext: ciphertext,
          salt: salt,
          slotIndex: vector['slotIndex']! as int,
        ),
        plaintext,
      );
    },
  );
}
