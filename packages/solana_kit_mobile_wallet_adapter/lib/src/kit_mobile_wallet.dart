import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show listEquals;
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_keys/solana_kit_keys.dart';
import 'package:solana_kit_mobile_wallet_adapter_protocol/solana_kit_mobile_wallet_adapter_protocol.dart';
import 'package:solana_kit_transactions/solana_kit_transactions.dart';

import 'package:solana_kit_mobile_wallet_adapter/src/verify_sign_in.dart';

/// Mobile wallet API that verifies wallet-controlled signing results.
///
/// Payloads, addresses, and signatures use the MWA base64 encoding. Authorize
/// or reauthorize this wrapper before signing. Invalid proofs, changed messages,
/// and incorrect result counts throw [FormatException].
abstract interface class KitMobileWallet {
  /// Requests authorization from the wallet.
  ///
  /// When [signInPayload] is supplied, requires a valid Ed25519 proof from an
  /// authorized account whose SIWS message matches every requested field.
  Future<AuthorizationResult> authorize({
    AppIdentity? identity,
    String? chain,
    List<String>? features,
    List<String>? addresses,
    SignInPayload? signInPayload,
  });

  /// Reauthorizes with an existing auth token.
  Future<AuthorizationResult> reauthorize({
    required String authToken,
    AppIdentity? identity,
  });

  /// Revokes the current authorization.
  Future<void> deauthorize({required String authToken});

  /// Queries the wallet's capabilities.
  Future<WalletCapabilities> getCapabilities();

  /// Signs one or more transactions and returns them with signatures.
  ///
  /// Each transaction is provided as a base64-encoded wire-format
  /// transaction, and returned the same way. Message bytes and existing
  /// signatures are preserved, and authorized signers' signatures are verified.
  Future<List<String>> signTransactions({required List<String> payloads});

  /// Signs one or more arbitrary messages.
  ///
  /// Each output is the original message followed by a verified 64-byte
  /// signature for each authorized address in [addresses], in the same order.
  Future<List<String>> signMessages({
    required List<String> addresses,
    required List<String> payloads,
  });

  /// Signs and sends one or more transactions, returning their signatures.
  ///
  /// Verifies each signature against the submitted message and its fee payer.
  /// Callers must independently confirm network submission and commitment.
  Future<List<String>> signAndSendTransactions({
    required List<String> payloads,
    SignAndSendOptions? options,
  });

  /// Clones an existing authorization token.
  Future<AuthorizationResult> cloneAuthorization();
}

/// Wraps a raw [MobileWallet] with verification of MWA signing responses.
///
/// The wrapper tracks its own authorization. Even when [wallet] has already
/// been authorized, call authorize or reauthorize on the returned wrapper.
KitMobileWallet wrapWithKitApi(MobileWallet wallet) {
  return _KitMobileWalletImpl(wallet);
}

class _KitMobileWalletImpl implements KitMobileWallet {
  _KitMobileWalletImpl(this._wallet);

  final MobileWallet _wallet;
  Set<Address> _accounts = const {};
  int _authorizationGeneration = 0;

  @override
  Future<AuthorizationResult> authorize({
    AppIdentity? identity,
    String? chain,
    List<String>? features,
    List<String>? addresses,
    SignInPayload? signInPayload,
  }) async {
    final generation = _beginAuthorization();
    final signInRequest = signInPayload?.toJson();

    if (signInRequest?['resources'] case final List<String> resources) {
      signInRequest!['resources'] = List<String>.unmodifiable(resources);
    }

    final params = <String, Object?>{
      if (identity != null) 'identity': identity.toJson(),
      'chain': ?chain,
      'features': ?features,
      'addresses': ?addresses,
      'sign_in_payload': ?signInRequest,
    };

    final result = await _wallet.authorize(params);

    return _acceptAuthorization(result, generation, signInRequest);
  }

  @override
  Future<AuthorizationResult> reauthorize({
    required String authToken,
    AppIdentity? identity,
  }) async {
    final generation = _beginAuthorization();
    final params = <String, Object?>{
      'auth_token': authToken,
      if (identity != null) 'identity': identity.toJson(),
    };

    final result = await _wallet.reauthorize(params);

    return _acceptAuthorization(result, generation, null);
  }

  @override
  Future<void> deauthorize({required String authToken}) async {
    _beginAuthorization();
    await _wallet.deauthorize({'auth_token': authToken});
  }

  @override
  Future<WalletCapabilities> getCapabilities() async {
    final result = await _wallet.getCapabilities();

    return WalletCapabilities.fromJson(result);
  }

  @override
  Future<List<String>> signTransactions({
    required List<String> payloads,
  }) async {
    final generation = _authorizationGeneration;
    final accounts = _authorizedAccounts();
    final submittedPayloads = List<String>.unmodifiable(payloads);
    final submitted = _transactions(submittedPayloads, accounts);
    final result = await _wallet.signTransactions({
      'payloads': submittedPayloads,
    });
    _assertCurrentAuthorization(generation);
    final signedPayloads = _outputs(
      result,
      'signed_payloads',
      submitted.length,
    );

    for (var index = 0; index < submitted.length; index++) {
      final original = submitted[index];
      final signed = getTransactionDecoder().decode(
        base64.decode(signedPayloads[index]),
      );

      if (!listEquals(original.messageBytes, signed.messageBytes)) {
        throw const FormatException('Wallet signed a different transaction');
      }

      for (final entry in original.signatures.entries) {
        final signature = signed.signatures[entry.key];

        if (accounts.contains(entry.key) && signature == null) {
          throw const FormatException('Wallet omitted an authorized signature');
        }

        if (signature != null) {
          _verifySignature(
            getPublicKeyFromAddress(entry.key),
            signature.value,
            original.messageBytes,
          );
        }

        if (entry.value != null &&
            !listEquals(entry.value!.value, signature?.value)) {
          throw const FormatException('Wallet changed an existing signature');
        }
      }
    }

    return signedPayloads;
  }

  @override
  Future<List<String>> signMessages({
    required List<String> addresses,
    required List<String> payloads,
  }) async {
    final generation = _authorizationGeneration;
    final accounts = _authorizedAccounts();
    final requestedAddresses = List<String>.unmodifiable(addresses);
    final submittedPayloads = List<String>.unmodifiable(payloads);
    final messages = submittedPayloads.map(base64.decode).toList();
    final publicKeys = requestedAddresses.map(_publicKey).toList();

    if (publicKeys.isEmpty ||
        publicKeys.any(
          (key) => !accounts.contains(getAddressFromPublicKey(key)),
        )) {
      throw ArgumentError('Messages must use authorized addresses');
    }

    final result = await _wallet.signMessages({
      'addresses': requestedAddresses,
      'payloads': submittedPayloads,
    });
    _assertCurrentAuthorization(generation);
    final signedPayloads = _outputs(result, 'signed_payloads', messages.length);

    for (var index = 0; index < messages.length; index++) {
      final message = messages[index];
      final signed = base64.decode(signedPayloads[index]);

      if (signed.length != message.length + publicKeys.length * 64 ||
          !listEquals(message, signed.sublist(0, message.length))) {
        throw const FormatException('Wallet signed a different message');
      }

      for (var signer = 0; signer < publicKeys.length; signer++) {
        final offset = message.length + signer * 64;
        _verifySignature(
          publicKeys[signer],
          Uint8List.sublistView(signed, offset, offset + 64),
          message,
        );
      }
    }

    return signedPayloads;
  }

  @override
  Future<List<String>> signAndSendTransactions({
    required List<String> payloads,
    SignAndSendOptions? options,
  }) async {
    final generation = _authorizationGeneration;
    final accounts = _authorizedAccounts();
    final submittedPayloads = List<String>.unmodifiable(payloads);
    final submitted = _transactions(submittedPayloads, accounts);
    final params = <String, Object?>{
      'payloads': submittedPayloads,
      if (options != null) 'options': options.toJson(),
    };

    final result = await _wallet.signAndSendTransactions(params);
    _assertCurrentAuthorization(generation);
    final signatures = _outputs(result, 'signatures', submitted.length);

    for (var index = 0; index < submitted.length; index++) {
      final transaction = submitted[index];
      // A transaction ID is the first signer's signature (the fee payer).
      // Another signer's valid signature is not the submitted transaction ID.
      _verifySignature(
        getPublicKeyFromAddress(transaction.signatures.keys.first),
        base64.decode(signatures[index]),
        transaction.messageBytes,
      );
    }

    return signatures;
  }

  @override
  Future<AuthorizationResult> cloneAuthorization() async {
    final result = await _wallet.cloneAuthorization({});
    final authorization = AuthorizationResult.fromJson(result);
    _accountAddresses(authorization);
    verifyMobileWalletSignIn(authorization, null);

    return authorization;
  }

  int _beginAuthorization() {
    _accounts = const {};

    return ++_authorizationGeneration;
  }

  AuthorizationResult _acceptAuthorization(
    Map<String, Object?> result,
    int generation,
    Map<String, Object?>? signInRequest,
  ) {
    _assertCurrentAuthorization(generation);
    final authorization = AuthorizationResult.fromJson(result);
    final accounts = _accountAddresses(authorization);
    verifyMobileWalletSignIn(authorization, signInRequest);
    _accounts = accounts;

    return authorization;
  }

  Set<Address> _authorizedAccounts() {
    if (_accounts.isEmpty) {
      throw StateError('Authorize this wallet before requesting signatures');
    }

    return _accounts;
  }

  void _assertCurrentAuthorization(int generation) {
    if (generation != _authorizationGeneration) {
      throw StateError('Wallet authorization changed during the request');
    }
  }
}

Set<Address> _accountAddresses(AuthorizationResult authorization) {
  if (authorization.accounts.isEmpty) {
    throw const FormatException('Wallet returned no authorized accounts');
  }

  return {
    for (final account in authorization.accounts)
      getAddressFromPublicKey(_publicKey(account.address)),
  };
}

Uint8List _publicKey(String encoded) {
  final bytes = base64.decode(encoded);

  if (bytes.length != 32) {
    throw const FormatException('Wallet address must contain 32 bytes');
  }

  return bytes;
}

List<Transaction> _transactions(List<String> payloads, Set<Address> accounts) {
  final transactions = [
    for (final payload in payloads)
      getTransactionDecoder().decode(base64.decode(payload)),
  ];

  if (transactions.any(
    (transaction) => !transaction.signatures.keys.any(accounts.contains),
  )) {
    throw ArgumentError('Transactions must include an authorized signer');
  }

  return transactions;
}

List<String> _outputs(Map<String, Object?> result, String field, int count) {
  final values = result[field];

  if (values is! List<Object?> ||
      values.length != count ||
      values.any((value) => value is! String)) {
    throw const FormatException('Wallet output count or type is invalid');
  }

  return List<String>.unmodifiable(values.cast<String>());
}

void _verifySignature(
  Uint8List publicKey,
  Uint8List signature,
  Uint8List message,
) {
  if (!verifySignature(publicKey, SignatureBytes(signature), message)) {
    throw const FormatException('Wallet signature does not verify');
  }
}
