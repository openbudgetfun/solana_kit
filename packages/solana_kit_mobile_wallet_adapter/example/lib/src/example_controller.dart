import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:solana_kit_mobile_wallet_adapter_example/src/example_services.dart';
import 'package:solana_kit_mobile_wallet_adapter_protocol/solana_kit_mobile_wallet_adapter_protocol.dart';

class MwaExampleController extends ChangeNotifier {
  MwaExampleController({
    required MwaPlatformSupportService platformService,
    required MwaSessionService sessionService,
    String initialMessageDraft =
        'Hello from the Solana Kit Android-first Flutter example',
    String initialTransactionDraft = '',
  }) : _platformService = platformService,
       _sessionService = sessionService,
       _messageDraft = initialMessageDraft,
       _transactionDraft = initialTransactionDraft;

  factory MwaExampleController.live() {
    return MwaExampleController(
      platformService: DefaultMwaPlatformSupportService(),
      sessionService: const DefaultMwaSessionService(),
    );
  }

  final MwaPlatformSupportService _platformService;
  final MwaSessionService _sessionService;

  final List<String> _logs = <String>[];

  bool _isBusy = false;
  bool? _walletEndpointAvailable;
  AuthorizationResult? _authorization;
  WalletCapabilities? _capabilities;
  String? _lastSignedPayload;
  List<String> _lastSubmittedSignatures = const <String>[];
  String _messageDraft;
  String _transactionDraft;

  bool get isSupported => _platformService.isSupported;
  bool get isBusy => _isBusy;
  bool? get walletEndpointAvailable => _walletEndpointAvailable;
  AuthorizationResult? get authorization => _authorization;
  WalletCapabilities? get capabilities => _capabilities;
  String? get lastSignedPayload => _lastSignedPayload;
  List<String> get lastSubmittedSignatures =>
      List<String>.unmodifiable(_lastSubmittedSignatures);
  String get messageDraft => _messageDraft;
  String get transactionDraft => _transactionDraft;
  UnmodifiableListView<String> get logs => UnmodifiableListView(_logs);

  bool get hasAuthorization =>
      _authorization != null && _authorization!.accounts.isNotEmpty;

  String get activeAccountLabel {
    final authorization = _authorization;
    if (authorization == null || authorization.accounts.isEmpty) {
      return 'Not authorized';
    }

    final account = authorization.accounts.first;
    return account.displayAddress ?? account.address;
  }

  Future<void> initialize() => refreshWalletEndpointStatus();

  void setMessageDraft(String value) {
    if (_messageDraft == value) {
      return;
    }

    _messageDraft = value;
    notifyListeners();
  }

  void setTransactionDraft(String value) {
    if (_transactionDraft == value) {
      return;
    }

    _transactionDraft = value;
    notifyListeners();
  }

  Future<void> refreshWalletEndpointStatus() async {
    if (!isSupported) {
      _walletEndpointAvailable = false;
      _appendLog('Mobile Wallet Adapter is unavailable on this platform.');
      notifyListeners();
      return;
    }

    await _runOperation('Refresh wallet endpoint', () async {
      final isAvailable = await _platformService.isWalletEndpointAvailable();
      _walletEndpointAvailable = isAvailable;
      _appendLog(
        isAvailable
            ? 'Wallet endpoint detected on device.'
            : 'No wallet endpoint detected. Install a mock or compatible wallet.',
      );
      notifyListeners();
    });
  }

  Future<void> authorize() {
    return _runOperation('Authorize', () async {
      final authorization = await _sessionService.authorize();
      _authorization = authorization;
      _capabilities = null;
      _lastSignedPayload = null;
      _lastSubmittedSignatures = const <String>[];

      final accountCount = authorization.accounts.length;
      final preview = accountCount > 0
          ? (authorization.accounts.first.displayAddress ??
                authorization.accounts.first.address)
          : 'No accounts returned';
      _appendLog('Authorized $accountCount account(s). First account: $preview');
      notifyListeners();
    });
  }

  Future<void> loadCapabilities() {
    final authorization = _authorization;
    if (authorization == null) {
      throw StateError('Authorize first.');
    }

    return _runOperation('Get capabilities', () async {
      final result = await _sessionService.loadCapabilities(
        authorization.authToken,
      );
      final (refreshedAuth, fetchedCapabilities) = result;
      _authorization = refreshedAuth;
      _capabilities = fetchedCapabilities;
      _appendLog(
        'Capabilities loaded. Features: '
        '${fetchedCapabilities.features?.join(', ') ?? 'none'}',
      );
      notifyListeners();
    });
  }

  Future<void> signMessage() {
    final authorization = _authorization;
    if (authorization == null || authorization.accounts.isEmpty) {
      throw StateError('Authorize first.');
    }

    final message = _messageDraft.trim();
    if (message.isEmpty) {
      throw StateError('Enter a message to sign.');
    }

    return _runOperation('Sign message', () async {
      final result = await _sessionService.signMessage(
        authToken: authorization.authToken,
        message: message,
      );
      final (refreshedAuth, signedPayloads) = result;
      if (signedPayloads.isEmpty) {
        throw StateError('Wallet returned no signed payloads.');
      }

      _authorization = refreshedAuth;
      _lastSignedPayload = signedPayloads.first;
      _appendLog(
        'Message signed. Returned ${signedPayloads.length} signed payload(s).',
      );
      notifyListeners();
    });
  }

  Future<void> signAndSendTransaction() {
    final authorization = _authorization;
    if (authorization == null || authorization.accounts.isEmpty) {
      throw StateError('Authorize first.');
    }

    final payload = _transactionDraft.trim();
    if (payload.isEmpty) {
      throw StateError('Paste a base64 transaction payload first.');
    }

    return _runOperation('Sign & send transaction', () async {
      final result = await _sessionService.signAndSendTransactions(
        authToken: authorization.authToken,
        payloads: <String>[payload],
      );
      final (refreshedAuth, signatures) = result;
      _authorization = refreshedAuth;
      _lastSubmittedSignatures = signatures;
      _appendLog(
        'Transaction submitted. Returned ${signatures.length} signature(s).',
      );
      notifyListeners();
    });
  }

  Future<void> deauthorize() {
    final authorization = _authorization;
    if (authorization == null) {
      throw StateError('No active authorization.');
    }

    return _runOperation('Deauthorize', () async {
      await _sessionService.deauthorize(authorization.authToken);
      _authorization = null;
      _capabilities = null;
      _lastSignedPayload = null;
      _lastSubmittedSignatures = const <String>[];
      _appendLog('Authorization revoked.');
      notifyListeners();
    });
  }

  Future<void> _runOperation(
    String label,
    Future<void> Function() operation,
  ) async {
    if (_isBusy) {
      return;
    }

    _isBusy = true;
    notifyListeners();
    _appendLog('$label started.');

    try {
      await operation();
      _appendLog('$label succeeded.');
    } on Object catch (error) {
      _appendLog('$label failed: $error');
      rethrow;
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  void _appendLog(String message) {
    final now = DateTime.now();
    final timestamp =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
    _logs.insert(0, '[$timestamp] $message');
  }
}
