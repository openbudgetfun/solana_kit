import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';

/// Maximum body bytes for any v0 message (largest 16-bit unsigned integer).
const int maxBodyBytes = 0xffff;

/// Maximum body bytes for hardware-wallet-signable messages.
///
/// This is the space remaining in the minimum IPv6 MTU after network header
/// overhead.
const int maxBodyBytesHardwareWalletSignable = 1232;

/// A restriction on what characters the message text can contain and how long
/// it can be.
///
/// This only applies to v0 messages.
enum OffchainMessageContentFormat {
  /// Restricted ASCII characters (0x20-0x7E), max 1232 bytes.
  restrictedAscii1232BytesMax(0),

  /// UTF-8, max 1232 bytes.
  utf81232BytesMax(1),

  /// UTF-8, max 65535 bytes.
  utf865535BytesMax(2);

  const OffchainMessageContentFormat(this.value);

  /// The numeric value of this format.
  final int value;

  /// Returns the format for the given numeric [value].
  ///
  /// Throws [ArgumentError] if the value is not a valid format.
  static OffchainMessageContentFormat fromValue(int value) {
    return switch (value) {
      0 => OffchainMessageContentFormat.restrictedAscii1232BytesMax,
      1 => OffchainMessageContentFormat.utf81232BytesMax,
      2 => OffchainMessageContentFormat.utf865535BytesMax,
      _ => throw ArgumentError('Invalid OffchainMessageContentFormat: $value'),
    };
  }
}

/// Content of a v0 offchain message.
@immutable
class OffchainMessageContent {
  /// Creates an [OffchainMessageContent] with the given [format] and [text].
  const OffchainMessageContent({required this.format, required this.text});

  /// The format restriction applied to the content.
  final OffchainMessageContentFormat format;

  /// The text content of the message.
  final String text;

  @override
  bool operator ==(Object other) {
    return other is OffchainMessageContent &&
        other.format == format &&
        other.text == text;
  }

  @override
  int get hashCode => Object.hash(format, text);
}

/// Returns the byte length of [text] encoded as UTF-8.
int _getUtf8ByteLength(String text) => utf8.encode(text).length;

/// Returns `true` if [text] contains only characters in the restricted ASCII
/// range [0x20, 0x7E].
bool _isTextRestrictedAscii(String text) {
  return RegExp(r'^[\x20-\x7e]+$').hasMatch(text);
}

/// Asserts that [content] conforms to restricted ASCII of 1232 bytes max.
///
/// Throws a [SolanaError] if:
/// - The format is not [OffchainMessageContentFormat.restrictedAscii1232BytesMax]
/// - The text is empty
/// - The text contains non-ASCII characters
/// - The text exceeds 1232 bytes
void assertIsOffchainMessageContentRestrictedAsciiOf1232BytesMax(
  OffchainMessageContent content,
) {
  if (content.format !=
      OffchainMessageContentFormat.restrictedAscii1232BytesMax) {
    throw SolanaError(SolanaErrorCode.offchainMessageMessageFormatMismatch, {
      'actualMessageFormat': content.format.value,
      'expectedMessageFormat':
          OffchainMessageContentFormat.restrictedAscii1232BytesMax.value,
    });
  }
  if (content.text.isEmpty) {
    throw SolanaError(SolanaErrorCode.offchainMessageMessageMustBeNonEmpty);
  }
  if (!_isTextRestrictedAscii(content.text)) {
    throw SolanaError(
      SolanaErrorCode.offchainMessageRestrictedAsciiBodyCharacterOutOfRange,
    );
  }
  final length = _getUtf8ByteLength(content.text);
  if (length > maxBodyBytesHardwareWalletSignable) {
    throw SolanaError(SolanaErrorCode.offchainMessageMaximumLengthExceeded, {
      'actualBytes': length,
      'maxBytes': maxBodyBytesHardwareWalletSignable,
    });
  }
}

/// Returns `true` if [content] conforms to restricted ASCII of 1232 bytes max.
bool isOffchainMessageContentRestrictedAsciiOf1232BytesMax(
  OffchainMessageContent content,
) {
  if (content.format !=
          OffchainMessageContentFormat.restrictedAscii1232BytesMax ||
      content.text.isEmpty ||
      !_isTextRestrictedAscii(content.text)) {
    return false;
  }
  final length = _getUtf8ByteLength(content.text);
  return length <= maxBodyBytesHardwareWalletSignable;
}

/// Asserts that [content] conforms to UTF-8 of 1232 bytes max.
///
/// Throws a [SolanaError] if:
/// - The text is empty
/// - The format is not [OffchainMessageContentFormat.utf81232BytesMax]
/// - The text exceeds 1232 bytes
void assertIsOffchainMessageContentUtf8Of1232BytesMax(
  OffchainMessageContent content,
) {
  if (content.text.isEmpty) {
    throw SolanaError(SolanaErrorCode.offchainMessageMessageMustBeNonEmpty);
  }
  if (content.format != OffchainMessageContentFormat.utf81232BytesMax) {
    throw SolanaError(SolanaErrorCode.offchainMessageMessageFormatMismatch, {
      'actualMessageFormat': content.format.value,
      'expectedMessageFormat':
          OffchainMessageContentFormat.utf81232BytesMax.value,
    });
  }
  final length = _getUtf8ByteLength(content.text);
  if (length > maxBodyBytesHardwareWalletSignable) {
    throw SolanaError(SolanaErrorCode.offchainMessageMaximumLengthExceeded, {
      'actualBytes': length,
      'maxBytes': maxBodyBytesHardwareWalletSignable,
    });
  }
}

/// Returns `true` if [content] conforms to UTF-8 of 1232 bytes max.
bool isOffchainMessageContentUtf8Of1232BytesMax(
  OffchainMessageContent content,
) {
  if (content.format != OffchainMessageContentFormat.utf81232BytesMax ||
      content.text.isEmpty) {
    return false;
  }
  final length = _getUtf8ByteLength(content.text);
  return length <= maxBodyBytesHardwareWalletSignable;
}

/// Asserts that [content] conforms to UTF-8 of 65535 bytes max.
///
/// Throws a [SolanaError] if:
/// - The format is not [OffchainMessageContentFormat.utf865535BytesMax]
/// - The text is empty
/// - The text exceeds 65535 bytes
void assertIsOffchainMessageContentUtf8Of65535BytesMax(
  OffchainMessageContent content,
) {
  if (content.format != OffchainMessageContentFormat.utf865535BytesMax) {
    throw SolanaError(SolanaErrorCode.offchainMessageMessageFormatMismatch, {
      'actualMessageFormat': content.format.value,
      'expectedMessageFormat':
          OffchainMessageContentFormat.utf865535BytesMax.value,
    });
  }
  if (content.text.isEmpty) {
    throw SolanaError(SolanaErrorCode.offchainMessageMessageMustBeNonEmpty);
  }
  final length = _getUtf8ByteLength(content.text);
  if (length > maxBodyBytes) {
    throw SolanaError(SolanaErrorCode.offchainMessageMaximumLengthExceeded, {
      'actualBytes': length,
      'maxBytes': maxBodyBytes,
    });
  }
}

/// Returns `true` if [content] conforms to UTF-8 of 65535 bytes max.
bool isOffchainMessageContentUtf8Of65535BytesMax(
  OffchainMessageContent content,
) {
  if (content.format != OffchainMessageContentFormat.utf865535BytesMax ||
      content.text.isEmpty) {
    return false;
  }
  final length = _getUtf8ByteLength(content.text);
  return length <= maxBodyBytes;
}
