import 'package:meta/meta.dart';
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
