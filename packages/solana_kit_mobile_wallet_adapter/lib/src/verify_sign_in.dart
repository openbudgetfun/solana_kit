import 'dart:convert';

import 'package:flutter/foundation.dart' show listEquals;
import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_keys/solana_kit_keys.dart';
import 'package:solana_kit_mobile_wallet_adapter_protocol/solana_kit_mobile_wallet_adapter_protocol.dart';

/// Verifies a wallet proof and binds its SIWS fields to the original request.
@internal
void verifyMobileWalletSignIn(
  AuthorizationResult authorization,
  Map<String, Object?>? request,
) {
  final proof = authorization.signInResult;

  if (request == null && proof == null) return;

  if (request == null || proof == null) {
    throw const FormatException('Wallet sign-in proof does not match request');
  }

  final publicKey = base64.decode(proof.address);
  final message = base64.decode(proof.signedMessage);
  final signature = base64.decode(proof.signature);

  if (publicKey.length != 32 ||
      !authorization.accounts.any(
        (account) => listEquals(base64.decode(account.address), publicKey),
      ) ||
      (proof.signatureType != null && proof.signatureType != 'ed25519') ||
      !verifySignature(publicKey, SignatureBytes(signature), message)) {
    throw const FormatException('Wallet sign-in signature does not verify');
  }

  final fields = _signInFields(utf8.decode(message));

  if (fields['address'] != getAddressFromPublicKey(publicKey).value) {
    throw const FormatException('SIWS message names a different account');
  }

  // A valid signature over an unrelated challenge is not a sign-in proof for
  // this request. Wallets may fill omitted fields, but cannot change supplied
  // fields (including the replay-resistant nonce).
  for (final entry in request.entries) {
    final matches = entry.key == 'resources'
        ? listEquals(
            entry.value! as List<String>,
            fields['resources'] as List<String>? ?? const [],
          )
        : fields[entry.key] == entry.value;

    if (!matches) {
      throw FormatException('SIWS message changed requested ${entry.key}');
    }
  }
}

const _headerSuffix = ' wants you to sign in with your Solana account:';
const _fieldNames = {
  'URI: ': 'uri',
  'Version: ': 'version',
  'Chain ID: ': 'chain_id',
  'Nonce: ': 'nonce',
  'Issued At: ': 'issued_at',
  'Expiration Time: ': 'expiration_time',
  'Not Before: ': 'not_before',
  'Request ID: ': 'request_id',
};

/// Reads only the unambiguous SIWS grammar; duplicated and unknown fields fail.
Map<String, Object?> _signInFields(String message) {
  final lines = message.split('\n');

  if (message.contains('\r') ||
      lines.length < 2 ||
      !lines.first.endsWith(_headerSuffix)) {
    throw const FormatException('Wallet returned a malformed SIWS message');
  }

  final fields = <String, Object?>{
    'domain': lines.first.substring(
      0,
      lines.first.length - _headerSuffix.length,
    ),
    'address': lines[1],
  };
  var position = 2;

  if (position < lines.length) {
    if (lines[position++] != '') {
      throw const FormatException('SIWS message is missing a blank separator');
    }

    if (position < lines.length &&
        lines[position] != 'Resources:' &&
        !_fieldNames.keys.any(lines[position].startsWith)) {
      fields['statement'] = lines[position++];

      if (position < lines.length && lines[position++] != '') {
        throw const FormatException('SIWS statement is missing a separator');
      }
    }
  }

  while (position < lines.length) {
    final line = lines[position++];

    if (line == 'Resources:') {
      final resources = <String>[];

      while (position < lines.length) {
        final resource = lines[position++];

        if (!resource.startsWith('- ')) {
          throw const FormatException('Malformed SIWS resource');
        }

        resources.add(resource.substring(2));
      }

      fields['resources'] = resources;
      break;
    }

    final prefixes = _fieldNames.keys.where(line.startsWith);

    if (prefixes.isEmpty || fields.containsKey(_fieldNames[prefixes.first])) {
      throw const FormatException('Unknown or duplicated SIWS field');
    }

    final prefix = prefixes.first;
    fields[_fieldNames[prefix]!] = line.substring(prefix.length);
  }

  return fields;
}
