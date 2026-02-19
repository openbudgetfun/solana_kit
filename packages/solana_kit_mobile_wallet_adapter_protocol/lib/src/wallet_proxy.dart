import 'dart:async';

import 'package:solana_kit_mobile_wallet_adapter_protocol/src/constants.dart';
import 'package:solana_kit_mobile_wallet_adapter_protocol/src/types.dart';

/// Callback type for sending JSON-RPC requests to the wallet.
typedef SendRequest = Future<Map<String, Object?>> Function(
  String method,
  Map<String, Object?> params,
);

/// Abstract interface for interacting with a mobile wallet via MWA.
///
/// This mirrors the wallet methods defined in the MWA specification. Methods
/// accept and return raw JSON-compatible types. Use the kit-level wrapper
/// (`KitMobileWallet` in the Flutter plugin) for type-safe transaction APIs.
abstract interface class MobileWallet {
  /// Requests authorization from the wallet.
  Future<Map<String, Object?>> authorize(Map<String, Object?> params);

  /// Reauthorizes with an existing auth token.
  Future<Map<String, Object?>> reauthorize(Map<String, Object?> params);

  /// Revokes the current authorization.
  Future<Map<String, Object?>> deauthorize(Map<String, Object?> params);

  /// Queries the wallet's capabilities.
  Future<Map<String, Object?>> getCapabilities();

  /// Signs one or more transactions.
  Future<Map<String, Object?>> signTransactions(Map<String, Object?> params);

  /// Signs one or more arbitrary messages.
  Future<Map<String, Object?>> signMessages(Map<String, Object?> params);

  /// Signs and sends one or more transactions.
  Future<Map<String, Object?>> signAndSendTransactions(
    Map<String, Object?> params,
  );

  /// Clones an existing authorization token.
  Future<Map<String, Object?>> cloneAuthorization(Map<String, Object?> params);
}

/// Chain identifier mapping between v1 and legacy formats.
const _v1ToLegacyChain = {
  'solana:testnet': 'testnet',
  'solana:devnet': 'devnet',
  'solana:mainnet': 'mainnet-beta',
};

const _legacyToV1Chain = {
  'testnet': 'solana:testnet',
  'devnet': 'solana:devnet',
  'mainnet-beta': 'solana:mainnet',
};

/// Creates a [MobileWallet] proxy that handles backwards compatibility
/// between v1 and legacy protocol versions.
///
/// The proxy intercepts method calls to:
/// - Map chain identifiers between v1 format (`solana:mainnet`) and legacy
///   format (`mainnet-beta`)
/// - Handle reauthorize: v1 sends `authorize` with `auth_token`, legacy
///   sends `reauthorize`
/// - Convert capabilities: v1 uses `features` array, legacy uses boolean
///   `supports_*` fields
MobileWallet createMobileWalletProxy(
  SendRequest sendRequest,
  SessionProperties sessionProps,
) {
  return _MobileWalletProxy(sendRequest, sessionProps);
}

class _MobileWalletProxy implements MobileWallet {
  _MobileWalletProxy(this._sendRequest, this._sessionProps);

  final SendRequest _sendRequest;
  final SessionProperties _sessionProps;

  ProtocolVersion get _version => _sessionProps.protocolVersion;

  @override
  Future<Map<String, Object?>> authorize(Map<String, Object?> params) async {
    final mappedParams = _mapAuthorizeParams(Map<String, Object?>.of(params));
    final method = _resolveAuthorizeMethod(mappedParams);
    final result = await _sendRequest(method, mappedParams);
    return result;
  }

  @override
  Future<Map<String, Object?>> reauthorize(Map<String, Object?> params) async {
    final mappedParams = Map<String, Object?>.of(params);
    final method = _resolveAuthorizeMethod(mappedParams);
    return _sendRequest(method, mappedParams);
  }

  @override
  Future<Map<String, Object?>> deauthorize(Map<String, Object?> params) {
    return _sendRequest('deauthorize', params);
  }

  @override
  Future<Map<String, Object?>> getCapabilities() async {
    final result = await _sendRequest('get_capabilities', {});
    return _mapCapabilitiesResponse(result);
  }

  @override
  Future<Map<String, Object?>> signTransactions(Map<String, Object?> params) {
    return _sendRequest('sign_transactions', params);
  }

  @override
  Future<Map<String, Object?>> signMessages(Map<String, Object?> params) {
    return _sendRequest('sign_messages', params);
  }

  @override
  Future<Map<String, Object?>> signAndSendTransactions(
    Map<String, Object?> params,
  ) {
    return _sendRequest('sign_and_send_transactions', params);
  }

  @override
  Future<Map<String, Object?>> cloneAuthorization(
    Map<String, Object?> params,
  ) {
    return _sendRequest('clone_authorization', params);
  }

  /// Maps chain identifiers based on protocol version.
  Map<String, Object?> _mapAuthorizeParams(Map<String, Object?> params) {
    final chain = params['chain'] as String?;
    if (chain == null) return params;

    if (_version == ProtocolVersion.legacy) {
      // Convert v1 chain ID to legacy cluster name.
      final legacyChain = _v1ToLegacyChain[chain] ?? chain;
      params['cluster'] = legacyChain;
    } else {
      // Ensure v1 chain ID format.
      final v1Chain = _legacyToV1Chain[chain] ?? chain;
      params['chain'] = v1Chain;
    }
    return params;
  }

  /// Resolves the correct method name for authorize/reauthorize.
  String _resolveAuthorizeMethod(Map<String, Object?> params) {
    final hasAuthToken = params.containsKey('auth_token') &&
        params['auth_token'] != null;

    if (hasAuthToken && _version == ProtocolVersion.legacy) {
      return 'reauthorize';
    }
    return 'authorize';
  }

  /// Maps capabilities response for backwards compatibility.
  Map<String, Object?> _mapCapabilitiesResponse(Map<String, Object?> result) {
    if (_version == ProtocolVersion.legacy) {
      // Convert legacy boolean flags to v1 features array.
      final features = <String>[mwaFeatureSignTransactions];
      if (result['supports_clone_authorization'] == true) {
        features.add(mwaFeatureCloneAuthorization);
      }
      return {...result, 'features': features};
    } else {
      // Convert v1 features to legacy boolean flags.
      final features = (result['features'] as List<Object?>?)?.cast<String>();
      return {
        ...result,
        'supports_sign_and_send_transactions': true,
        'supports_clone_authorization':
            features?.contains(mwaFeatureCloneAuthorization) ?? false,
      };
    }
  }
}
