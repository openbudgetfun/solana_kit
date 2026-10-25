import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show listEquals;
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_keys/solana_kit_keys.dart';
import 'package:solana_kit_offchain_messages/solana_kit_offchain_messages.dart';
import 'package:solana_kit_transactions/solana_kit_transactions.dart';
import 'package:solana_kit_wallet_standard/solana_kit_wallet_standard.dart';

/// Rejects wallet result counts that differ from the request.
void assertWalletOutputCount(int expected, int actual) {
  if (expected != actual) {
    throw invalidWalletResponse(
      'Wallet output count does not match the request',
    );
  }
}

/// Creates a failure at the untrusted wallet response boundary.
WalletStandardException invalidWalletResponse(String message) =>
    WalletStandardException(WalletStandardErrorCode.invalidResponse, message);

/// Verifies both the account identity and its Ed25519 signature.
void assertWalletSignature({
  required WalletAccount account,
  required Uint8List message,
  required Uint8List signature,
  String? signatureType,
}) {
  if (signatureType != null && signatureType != 'ed25519') {
    throw invalidWalletResponse(
      'Wallet returned an unsupported signature type',
    );
  }

  if (getAddressFromPublicKey(account.publicKey).value != account.address ||
      !verifySignature(account.publicKey, SignatureBytes(signature), message)) {
    throw invalidWalletResponse(
      'Wallet signature does not verify against the account',
    );
  }
}

/// Binds the returned transaction and its authorized signature to the input.
void assertWalletSignedTransaction(
  SolanaSignTransactionInput input,
  Uint8List signedBytes,
) {
  final submitted = getTransactionDecoder().decode(input.transaction);
  final signed = getTransactionDecoder().decode(signedBytes);

  if (!listEquals(submitted.messageBytes, signed.messageBytes)) {
    throw invalidWalletResponse('Wallet signed a different transaction');
  }

  final signature = signed.signatures[address(input.account.address)];

  if (signature == null) {
    throw invalidWalletResponse(
      'Wallet transaction is missing the requested signer',
    );
  }

  assertWalletSignature(
    account: input.account,
    message: signed.messageBytes,
    signature: signature.value,
  );
}

/// Verifies the reported transaction ID against the submitted message.
///
/// The first required signature is the transaction ID. This proves that the
/// signature belongs to the request; confirmation still requires an RPC query.
void assertWalletSubmissionSignature(
  SolanaSignAndSendTransactionInput input,
  Uint8List signature,
) {
  final transaction = getTransactionDecoder().decode(input.transaction);

  if (transaction.signatures.isEmpty ||
      !verifySignature(
        getPublicKeyFromAddress(transaction.signatures.keys.first),
        SignatureBytes(signature),
        transaction.messageBytes,
      )) {
    throw invalidWalletResponse(
      'Wallet reported a signature for a different transaction',
    );
  }
}

/// Rejects signed messages that differ from the bytes the caller requested.
void assertWalletSignedMessage(
  SolanaSignMessageInput input,
  SolanaSignMessageOutput output,
) {
  if (!listEquals(input.message, output.signedMessage)) {
    throw invalidWalletResponse('Wallet signed a different message');
  }

  assertWalletSignature(
    account: input.account,
    message: output.signedMessage,
    signature: output.signature,
    signatureType: output.signatureType,
  );
}

/// Binds all supplied SIWS fields to a proof from a currently authorized account.
void assertWalletSignIn(
  SolanaSignInInput input,
  SolanaSignInOutput output,
  List<WalletAccount> authorizedAccounts,
) {
  if (!authorizedAccounts.any(
    (account) =>
        account.address == output.account.address &&
        listEquals(account.publicKey, output.account.publicKey),
  )) {
    throw invalidWalletResponse(
      'Wallet sign-in proof uses an unauthorized account',
    );
  }

  assertWalletSignature(
    account: output.account,
    message: output.signedMessage,
    signature: output.signature,
    signatureType: output.signatureType,
  );
  final String text;

  try {
    text = utf8.decode(output.signedMessage);
  } on FormatException {
    throw invalidWalletResponse('Wallet returned an invalid SIWS message');
  }

  const suffix = ' wants you to sign in with your Solana account:';
  final lines = text.split('\n');

  if (text.contains('\r') ||
      lines.length < 2 ||
      !lines.first.endsWith(suffix) ||
      lines.first.length == suffix.length) {
    throw invalidWalletResponse('Wallet returned an invalid SIWS header');
  }

  final fields = <String, String>{
    'domain': lines.first.substring(0, lines.first.length - suffix.length),
    'address': lines[1],
  };
  const labels = [
    'URI',
    'Version',
    'Chain ID',
    'Nonce',
    'Issued At',
    'Expiration Time',
    'Not Before',
    'Request ID',
  ];
  var cursor = 2;

  if (cursor < lines.length) {
    if (lines[cursor++] != '') {
      throw invalidWalletResponse('Wallet returned an invalid SIWS separator');
    }

    if (cursor < lines.length &&
        ((cursor + 1 < lines.length && lines[cursor + 1].isEmpty) ||
            lines[cursor] == input.statement ||
            (!labels.any((label) => lines[cursor].startsWith('$label: ')) &&
                lines[cursor] != 'Resources:'))) {
      fields['statement'] = lines[cursor++];

      if (cursor < lines.length && lines[cursor++] != '') {
        throw invalidWalletResponse(
          'Wallet returned an invalid SIWS statement',
        );
      }
    }
  }

  // Security: Parse fields in canonical order and consume every line so a
  // duplicate nonce or a label inside the statement cannot satisfy a challenge.
  for (final label in labels) {
    if (cursor < lines.length && lines[cursor].startsWith('$label: ')) {
      fields[label] = lines[cursor++].substring(label.length + 2);
    }
  }

  final resources = <String>[];

  if (cursor < lines.length && lines[cursor] == 'Resources:') {
    cursor++;

    while (cursor < lines.length && lines[cursor].startsWith('- ')) {
      resources.add(lines[cursor++].substring(2));
    }
  }

  if (cursor != lines.length || fields['address'] != output.account.address) {
    throw invalidWalletResponse('Wallet returned an invalid SIWS message');
  }

  final expected = <String, String?>{
    'domain': input.domain,
    'address': input.address,
    'statement': input.statement,
    'URI': input.uri,
    'Version': input.version,
    'Chain ID': input.chainId,
    'Nonce': input.nonce,
    'Issued At': input.issuedAt,
    'Expiration Time': input.expirationTime,
    'Not Before': input.notBefore,
    'Request ID': input.requestId,
  };

  if (expected.entries.any(
        (entry) => entry.value != null && fields[entry.key] != entry.value,
      ) ||
      (input.resources != null && !listEquals(input.resources, resources))) {
    throw invalidWalletResponse(
      'Wallet sign-in proof does not match the request',
    );
  }
}

/// Binds the canonical version-one offchain payload and verifies its signer.
void assertWalletOffchainMessage(
  SolanaSignOffchainMessageInput input,
  SolanaSignOffchainMessageOutput output,
) {
  final expected = OffchainMessageV1(
    content: input.message,
    requiredSignatories: [
      for (final key in input.requiredSigners)
        OffchainMessageSignatory(address: getAddressFromPublicKey(key)),
    ],
  );
  final expectedBytes = getOffchainMessageV1Encoder().encode(expected);

  if (!listEquals(output.signedOffchainMessage, expectedBytes) ||
      !input.requiredSigners.any(
        (key) => listEquals(key, input.account.publicKey),
      )) {
    throw invalidWalletResponse(
      'Wallet returned a different or invalid offchain message',
    );
  }

  assertWalletSignature(
    account: input.account,
    message: output.signedOffchainMessage,
    signature: output.signature,
    signatureType: output.signatureType,
  );
}
