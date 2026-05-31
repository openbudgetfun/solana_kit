import 'dart:convert';
import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_keys/solana_kit_keys.dart';

/// Defines a message that needs signing and its current set of signatures
/// if any.
///
/// This class allows message modifying signers to decide on whether or not
/// they should modify the provided message depending on whether or not
/// signatures already exist for such message.
class SignableMessage {
  /// Creates a [SignableMessage] with the given [content] and [signatures].
  const SignableMessage({required this.content, required this.signatures});

  /// The content of the message as bytes.
  final Uint8List content;

  /// The current set of signatures for this message.
  final Map<Address, SignatureBytes> signatures;
}

/// Creates a [SignableMessage] from a [Uint8List] or a UTF-8 string.
///
/// It optionally accepts a signature dictionary if the message already
/// contains signatures.
///
/// ```dart
/// final message = createSignableMessage(Uint8List.fromList([1, 2, 3]));
/// final messageFromText = createSignableMessage('Hello world!');
/// final messageWithSignatures = createSignableMessage(
///   'Hello world!',
///   {Address('1234..5678'): SignatureBytes(Uint8List(64))},
/// );
/// ```
SignableMessage createSignableMessage(
  Object content, [
  Map<Address, SignatureBytes>? signatures,
]) {
  final Uint8List contentBytes;
  if (content is String) {
    contentBytes = Uint8List.fromList(utf8.encode(content));
  } else if (content is Uint8List) {
    contentBytes = content;
  } else {
    throw ArgumentError('content must be a String or Uint8List');
  }

  return SignableMessage(
    content: contentBytes,
    signatures: Map<Address, SignatureBytes>.unmodifiable(
      signatures != null
          ? Map<Address, SignatureBytes>.of(signatures)
          : <Address, SignatureBytes>{},
    ),
  );
}
