import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

import 'package:solana_kit_mobile_wallet_adapter/src/pigeon/wallet_api.dart';
import 'package:solana_kit_mobile_wallet_adapter/src/wallet/wallet_config.dart';
import 'package:solana_kit_mobile_wallet_adapter/src/wallet/wallet_request_types.dart';

/// Callbacks for handling wallet-side MWA requests and lifecycle events.
///
/// Implement this interface to provide wallet functionality. Each method
/// receives a request object that must be completed by calling one of its
/// `completeWith*` methods.
abstract interface class WalletScenarioCallbacks {
  /// Called when the scenario is ready to accept connections.
  void onScenarioReady();

  /// Called when the scenario is actively serving dApp clients.
  void onScenarioServingClients();

  /// Called when the scenario has finished serving clients.
  void onScenarioServingComplete();

  /// Called when the scenario has completed normally.
  void onScenarioComplete();

  /// Called when the scenario encounters an error.
  void onScenarioError(Object? error);

  /// Called when scenario teardown is complete.
  void onScenarioTeardownComplete();

  /// Called when a dApp requests authorization.
  void onAuthorizeRequest(AuthorizeDappRequest request);

  /// Called when a dApp requests reauthorization.
  void onReauthorizeRequest(ReauthorizeDappRequest request);

  /// Called when a dApp requests transaction signing.
  void onSignTransactionsRequest(SignTransactionsRequest request);

  /// Called when a dApp requests message signing.
  void onSignMessagesRequest(SignMessagesRequest request);

  /// Called when a dApp requests transaction signing and sending.
  void onSignAndSendTransactionsRequest(SignAndSendTransactionsRequest request);

  /// Called when a dApp deauthorizes (revokes its token).
  void onDeauthorizedEvent(DeauthorizedEvent event);
}

/// Manages a wallet-side MWA scenario.
///
/// This wraps the native Android walletlib via [MwaWalletHostApi] to
/// handle incoming dApp requests. The wallet implements
/// [WalletScenarioCallbacks] to receive requests and lifecycle events.
///
/// Example:
/// ```dart
/// final scenario = WalletScenario(
///   walletName: 'My Wallet',
///   config: const MobileWalletAdapterConfig(
///     maxTransactionsPerSigningRequest: 10,
///     maxMessagesPerSigningRequest: 5,
///     optionalFeatures: ['solana:signTransactions'],
///   ),
///   callbacks: myCallbacksImpl,
/// );
///
/// await scenario.start();
/// // ... wallet is now handling requests via callbacks ...
/// await scenario.close();
/// ```
class WalletScenario {
  WalletScenario({
    required this.walletName,
    required this.config,
    required this.callbacks,
    MwaWalletHostApi? walletApi,
  }) : _walletApi = walletApi ?? MwaWalletHostApi();

  /// Human-readable name of the wallet.
  final String walletName;

  /// Wallet capabilities configuration.
  final MobileWalletAdapterConfig config;

  /// Callbacks for handling requests and lifecycle events.
  final WalletScenarioCallbacks callbacks;

  final MwaWalletHostApi _walletApi;

  String? _sessionId;
  bool _closed = false;

  /// The active session identifier, or `null` if not started.
  String? get sessionId => _sessionId;

  /// Whether this scenario has been closed.
  bool get isClosed => _closed;

  /// Starts the wallet scenario and begins accepting connections.
  ///
  /// This creates the native scenario, sets up the event bridge, and
  /// starts the WebSocket server.
  Future<void> start() async {
    // Set up the native -> Dart callback bridge.
    _walletApi.setMethodCallHandler(_handleNativeCall);

    // Create the scenario on the native side.
    _sessionId = await _walletApi.createScenario(
      walletName: walletName,
      configJson: jsonEncode(config.toCapabilitiesJson()),
    );

    // Start accepting connections.
    await _walletApi.startScenario(sessionId: _sessionId!);
  }

  /// Closes the scenario and stops accepting connections.
  Future<void> close() async {
    if (_closed) return;
    _closed = true;

    if (_sessionId != null) {
      await _walletApi.closeScenario(sessionId: _sessionId!);
    }

    _walletApi.setMethodCallHandler(null);
  }

  /// Handles method calls from the native side (Kotlin -> Dart).
  Future<Object?> _handleNativeCall(MethodCall call) async {
    switch (call.method) {
      case 'onScenarioReady':
        callbacks.onScenarioReady();
      case 'onScenarioServingClients':
        callbacks.onScenarioServingClients();
      case 'onScenarioServingComplete':
        callbacks.onScenarioServingComplete();
      case 'onScenarioComplete':
        callbacks.onScenarioComplete();
      case 'onScenarioError':
        final args = call.arguments as Map<Object?, Object?>?;
        callbacks.onScenarioError(args?['error']);
      case 'onScenarioTeardownComplete':
        callbacks.onScenarioTeardownComplete();
      case 'onAuthorizeRequest':
        await _handleAuthorizeRequest(call);
      case 'onReauthorizeRequest':
        await _handleReauthorizeRequest(call);
      case 'onSignTransactionsRequest':
        await _handleSignTransactionsRequest(call);
      case 'onSignMessagesRequest':
        await _handleSignMessagesRequest(call);
      case 'onSignAndSendTransactionsRequest':
        await _handleSignAndSendTransactionsRequest(call);
      case 'onDeauthorizedEvent':
        await _handleDeauthorizedEvent(call);
      default:
        throw MissingPluginException('No handler for method ${call.method}');
    }
    return null;
  }

  Future<void> _handleAuthorizeRequest(MethodCall call) async {
    final args = _decodeArgs(call);
    final requestId = args['requestId']! as String;
    final params = _decodeJsonMap(args['paramsJson'] as String?);

    final request = AuthorizeDappRequest.fromParams(
      requestId: requestId,
      sessionId: _sessionId!,
      params: params,
    );

    callbacks.onAuthorizeRequest(request);

    // Wait for the wallet to complete the request, then resolve it natively.
    try {
      final result = await request.future;
      await _walletApi.resolveRequest(
        sessionId: _sessionId!,
        requestId: requestId,
        resultJson: jsonEncode(result),
      );
    } on Object catch (error) {
      await _walletApi.resolveRequest(
        sessionId: _sessionId!,
        requestId: requestId,
        resultJson: jsonEncode(_errorToJson(error)),
      );
    }
  }

  Future<void> _handleReauthorizeRequest(MethodCall call) async {
    final args = _decodeArgs(call);
    final requestId = args['requestId']! as String;
    final params = _decodeJsonMap(args['paramsJson'] as String?);

    final request = ReauthorizeDappRequest(
      requestId: requestId,
      sessionId: _sessionId!,
      identityName: params['identity_name'] as String?,
      identityUri: params['identity_uri'] as String?,
      chain: params['chain'] as String?,
      authorizationScope: params['auth_token'] as String? ?? '',
    );

    callbacks.onReauthorizeRequest(request);

    try {
      final result = await request.future;
      await _walletApi.resolveRequest(
        sessionId: _sessionId!,
        requestId: requestId,
        resultJson: jsonEncode(result),
      );
    } on Object catch (error) {
      await _walletApi.resolveRequest(
        sessionId: _sessionId!,
        requestId: requestId,
        resultJson: jsonEncode(_errorToJson(error)),
      );
    }
  }

  Future<void> _handleSignTransactionsRequest(MethodCall call) async {
    final args = _decodeArgs(call);
    final requestId = args['requestId']! as String;
    final params = _decodeJsonMap(args['paramsJson'] as String?);

    final request = SignTransactionsRequest.fromParams(
      requestId: requestId,
      sessionId: _sessionId!,
      params: params,
    );

    callbacks.onSignTransactionsRequest(request);

    try {
      final result = await request.future;
      await _walletApi.resolveRequest(
        sessionId: _sessionId!,
        requestId: requestId,
        resultJson: jsonEncode(result),
      );
    } on Object catch (error) {
      await _walletApi.resolveRequest(
        sessionId: _sessionId!,
        requestId: requestId,
        resultJson: jsonEncode(_errorToJson(error)),
      );
    }
  }

  Future<void> _handleSignMessagesRequest(MethodCall call) async {
    final args = _decodeArgs(call);
    final requestId = args['requestId']! as String;
    final params = _decodeJsonMap(args['paramsJson'] as String?);

    final request = SignMessagesRequest.fromParams(
      requestId: requestId,
      sessionId: _sessionId!,
      params: params,
    );

    callbacks.onSignMessagesRequest(request);

    try {
      final result = await request.future;
      await _walletApi.resolveRequest(
        sessionId: _sessionId!,
        requestId: requestId,
        resultJson: jsonEncode(result),
      );
    } on Object catch (error) {
      await _walletApi.resolveRequest(
        sessionId: _sessionId!,
        requestId: requestId,
        resultJson: jsonEncode(_errorToJson(error)),
      );
    }
  }

  Future<void> _handleSignAndSendTransactionsRequest(MethodCall call) async {
    final args = _decodeArgs(call);
    final requestId = args['requestId']! as String;
    final params = _decodeJsonMap(args['paramsJson'] as String?);

    final request = SignAndSendTransactionsRequest.fromParams(
      requestId: requestId,
      sessionId: _sessionId!,
      params: params,
    );

    callbacks.onSignAndSendTransactionsRequest(request);

    try {
      final result = await request.future;
      await _walletApi.resolveRequest(
        sessionId: _sessionId!,
        requestId: requestId,
        resultJson: jsonEncode(result),
      );
    } on Object catch (error) {
      await _walletApi.resolveRequest(
        sessionId: _sessionId!,
        requestId: requestId,
        resultJson: jsonEncode(_errorToJson(error)),
      );
    }
  }

  Future<void> _handleDeauthorizedEvent(MethodCall call) async {
    final args = _decodeArgs(call);
    final requestId = args['requestId']! as String;
    final params = _decodeJsonMap(args['paramsJson'] as String?);

    final event = DeauthorizedEvent(
      requestId: requestId,
      sessionId: _sessionId!,
      identityName: params['identity_name'] as String?,
      identityUri: params['identity_uri'] as String?,
      chain: params['chain'] as String?,
      authorizationScope: params['auth_token'] as String? ?? '',
    );

    callbacks.onDeauthorizedEvent(event);

    try {
      final result = await event.future;
      await _walletApi.resolveRequest(
        sessionId: _sessionId!,
        requestId: requestId,
        resultJson: jsonEncode(result),
      );
    } on Object catch (error) {
      await _walletApi.resolveRequest(
        sessionId: _sessionId!,
        requestId: requestId,
        resultJson: jsonEncode(_errorToJson(error)),
      );
    }
  }

  Map<String, Object?> _decodeArgs(MethodCall call) {
    final args = call.arguments;
    if (args is Map<Object?, Object?>) {
      return args.cast<String, Object?>();
    }
    return <String, Object?>{};
  }

  Map<String, Object?> _decodeJsonMap(String? json) {
    if (json == null || json.isEmpty) return {};
    final decoded = jsonDecode(json);
    if (decoded is Map<String, Object?>) return decoded;
    if (decoded is Map) return decoded.cast<String, Object?>();
    return {};
  }

  Map<String, Object?> _errorToJson(Object error) {
    if (error is WalletRequestError) {
      return {
        'error': {
          'code': error.code,
          'message': error.message,
          if (error.data != null) 'data': error.data,
        },
      };
    }
    return {
      'error': {'code': -32603, 'message': error.toString()},
    };
  }
}
