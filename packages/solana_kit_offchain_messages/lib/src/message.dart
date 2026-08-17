import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_offchain_messages/src/application_domain.dart';
import 'package:solana_kit_offchain_messages/src/content.dart';
import 'package:solana_kit_offchain_messages/src/signatory.dart';
import 'package:solana_kit_offchain_messages/src/version.dart';

/// A sealed union type for offchain messages.
///
/// An offchain message is either a [OffchainMessageV0] or
/// [OffchainMessageV1].
@immutable
sealed class OffchainMessage {
  /// The version of the offchain message.
  OffchainMessageVersion get version;

  /// The required signatories for this message.
  List<OffchainMessageSignatory> get requiredSignatories;
}

/// A version 0 offchain message.
///
/// Version 0 messages include an application domain, content with a specific
/// format, and a list of required signatories.
@immutable
class OffchainMessageV0 implements OffchainMessage {
  /// Creates a v0 offchain message.
  const OffchainMessageV0({
    required this.applicationDomain,
    required this.content,
    required this.requiredSignatories,
  });

  @override
  OffchainMessageVersion get version => 0;

  /// The application domain (32 bytes encoded as base58).
  final OffchainMessageApplicationDomain applicationDomain;

  /// The content of the message with format metadata.
  final OffchainMessageContent content;

  @override
  final List<OffchainMessageSignatory> requiredSignatories;

  @override
  bool operator ==(Object other) {
    if (other is! OffchainMessageV0) return false;
    if (other.applicationDomain.value != applicationDomain.value) return false;
    if (other.content != content) return false;
    if (other.requiredSignatories.length != requiredSignatories.length) {
      return false;
    }
    for (var i = 0; i < requiredSignatories.length; i++) {
      if (other.requiredSignatories[i] != requiredSignatories[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
    version,
    applicationDomain.value,
    content,
    Object.hashAll(requiredSignatories),
  );
}

/// A version 1 offchain message.
///
/// Version 1 messages have UTF-8 content of arbitrary length and a list of
/// required signatories that are sorted lexicographically when encoded.
@immutable
class OffchainMessageV1 implements OffchainMessage {
  /// Creates a v1 offchain message.
  const OffchainMessageV1({
    required this.content,
    required this.requiredSignatories,
  });

  @override
  OffchainMessageVersion get version => 1;

  /// The UTF-8 text content of the message.
  final String content;

  @override
  final List<OffchainMessageSignatory> requiredSignatories;

  @override
  bool operator ==(Object other) {
    if (other is! OffchainMessageV1) return false;
    if (other.content != content) return false;
    if (other.requiredSignatories.length != requiredSignatories.length) {
      return false;
    }
    for (var i = 0; i < requiredSignatories.length; i++) {
      if (other.requiredSignatories[i] != requiredSignatories[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode =>
      Object.hash(version, content, Object.hashAll(requiredSignatories));
}

/// Asserts that a version 1 offchain message received from an untrusted
/// source is the message that you expected it to be.
///
/// A signer (eg. a wallet) returns the message bytes it signed alongside its
/// signature. Verifying that signature proves only that the signer produced it
/// over *those* bytes; it says nothing about whether those bytes represent the
/// message you asked for. Use this function to establish that they do, then
/// verify the signature separately with `verifyOffchainMessageEnvelope`.
///
/// Required signatories are compared without regard to order. The offchain
/// message specification mandates that they be serialized in lexicographic
/// order, so a decoded message always lists them in that order while
/// [expectedMessage] may list them in whatever order you built it with. Both
/// lists are sorted before they are compared, and they are reported in sorted
/// order in the error context so that they can be compared by eye.
///
/// Message content is not included in the error context, because it can carry
/// data you would rather not have written to logs or forwarded to an error
/// reporting service. Its length in UTF-8 bytes — the encoding in which
/// version 1 content is serialized — is reported instead.
void assertOffchainMessageV1Equal(
  OffchainMessageV1 receivedMessage,
  OffchainMessageV1 expectedMessage,
) {
  if (receivedMessage.content != expectedMessage.content) {
    throw SolanaError(
      SolanaErrorCode.offchainMessageContentDoesNotMatchExpected,
      {
        'actualBytes': utf8.encode(receivedMessage.content).length,
        'expectedBytes': utf8.encode(expectedMessage.content).length,
      },
    );
  }
  final actualAddresses = _getSortedSignatoryAddresses(receivedMessage);
  final expectedAddresses = _getSortedSignatoryAddresses(expectedMessage);
  if (actualAddresses.length != expectedAddresses.length ||
      !_sameAddresses(actualAddresses, expectedAddresses)) {
    throw SolanaError(
      SolanaErrorCode.offchainMessageRequiredSignatoriesDoNotMatchExpected,
      {
        'actualAddresses': actualAddresses,
        'expectedAddresses': expectedAddresses,
      },
    );
  }
}

List<String> _getSortedSignatoryAddresses(OffchainMessageV1 message) {
  final addresses =
      message.requiredSignatories
          .map((signatory) => signatory.address.value)
          .toList()
        ..sort();
  return addresses;
}

bool _sameAddresses(List<String> a, List<String> b) {
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
