import 'package:solana_kit_keys/solana_kit_keys.dart' show SignatureBytes;
import 'package:solana_kit_mobile_wallet_adapter_protocol/solana_kit_mobile_wallet_adapter_protocol.dart';
import 'package:solana_kit_transactions/solana_kit_transactions.dart'
    show Transaction;

/// Kit-integrated mobile wallet API that works with Solana Kit types
/// ([Transaction], [SignatureBytes]) instead of raw base64 strings.
///
/// This mirrors the JS `@solana/mobile-wallet-adapter-protocol-kit` package.
abstract interface class KitMobileWallet {
  /// Requests authorization from the wallet.
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
  /// transaction, and returned the same way.
  Future<List<String>> signTransactions({required List<String> payloads});

  /// Signs one or more arbitrary messages.
  Future<List<String>> signMessages({
    required List<String> addresses,
    required List<String> payloads,
  });

  /// Signs and sends one or more transactions, returning their signatures.
  Future<List<String>> signAndSendTransactions({
    required List<String> payloads,
    SignAndSendOptions? options,
  });

  /// Clones an existing authorization token.
  Future<AuthorizationResult> cloneAuthorization();
}

/// Wraps a raw [MobileWallet] with a Kit-level API that handles type
/// conversions between Solana Kit types and the MWA JSON-RPC format.
KitMobileWallet wrapWithKitApi(MobileWallet wallet) {
  return _KitMobileWalletImpl(wallet);
}

class _KitMobileWalletImpl implements KitMobileWallet {
  _KitMobileWalletImpl(this._wallet);

  final MobileWallet _wallet;

  @override
  Future<AuthorizationResult> authorize({
    AppIdentity? identity,
    String? chain,
    List<String>? features,
    List<String>? addresses,
    SignInPayload? signInPayload,
  }) async {
    final params = <String, Object?>{
      if (identity != null) 'identity': identity.toJson(),
      if (chain != null) 'chain': chain,
      if (features != null) 'features': features,
      if (addresses != null) 'addresses': addresses,
      if (signInPayload != null) 'sign_in_payload': signInPayload.toJson(),
    };

    final result = await _wallet.authorize(params);
    return AuthorizationResult.fromJson(result);
  }

  @override
  Future<AuthorizationResult> reauthorize({
    required String authToken,
    AppIdentity? identity,
  }) async {
    final params = <String, Object?>{
      'auth_token': authToken,
      if (identity != null) 'identity': identity.toJson(),
    };

    final result = await _wallet.reauthorize(params);
    return AuthorizationResult.fromJson(result);
  }

  @override
  Future<void> deauthorize({required String authToken}) async {
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
    final result = await _wallet.signTransactions({'payloads': payloads});
    return (result['signed_payloads']! as List<Object?>).cast<String>();
  }

  @override
  Future<List<String>> signMessages({
    required List<String> addresses,
    required List<String> payloads,
  }) async {
    final result = await _wallet.signMessages({
      'addresses': addresses,
      'payloads': payloads,
    });
    return (result['signed_payloads']! as List<Object?>).cast<String>();
  }

  @override
  Future<List<String>> signAndSendTransactions({
    required List<String> payloads,
    SignAndSendOptions? options,
  }) async {
    final params = <String, Object?>{
      'payloads': payloads,
      if (options != null) 'options': options.toJson(),
    };

    final result = await _wallet.signAndSendTransactions(params);
    return (result['signatures']! as List<Object?>).cast<String>();
  }

  @override
  Future<AuthorizationResult> cloneAuthorization() async {
    final result = await _wallet.cloneAuthorization({});
    return AuthorizationResult.fromJson(result);
  }
}
