import 'dart:convert';

import 'package:solana_kit_mobile_wallet_adapter/solana_kit_mobile_wallet_adapter.dart';
import 'package:solana_kit_mobile_wallet_adapter_protocol/solana_kit_mobile_wallet_adapter_protocol.dart';

abstract interface class MwaPlatformSupportService {
  bool get isSupported;

  Future<bool> isWalletEndpointAvailable();
}

class DefaultMwaPlatformSupportService implements MwaPlatformSupportService {
  DefaultMwaPlatformSupportService({MwaClientHostApi? hostApi})
    : _hostApi = hostApi ?? MwaClientHostApi();

  final MwaClientHostApi _hostApi;

  @override
  bool get isSupported => isMwaSupported();

  @override
  Future<bool> isWalletEndpointAvailable() async {
    if (!isSupported) {
      return false;
    }

    return _hostApi.isWalletEndpointAvailable();
  }
}

abstract interface class MwaSessionService {
  Future<AuthorizationResult> authorize();

  Future<(AuthorizationResult, WalletCapabilities)> loadCapabilities(
    String authToken,
  );

  Future<(AuthorizationResult, List<String>)> signMessage({
    required String authToken,
    required String message,
  });

  Future<(AuthorizationResult, List<String>)> signAndSendTransactions({
    required String authToken,
    required List<String> payloads,
  });

  Future<void> deauthorize(String authToken);
}

class DefaultMwaSessionService implements MwaSessionService {
  const DefaultMwaSessionService();

  @override
  Future<AuthorizationResult> authorize() {
    return transact(
      (wallet) => wallet.authorize(
        chain: 'solana:devnet',
        features: const [
          'solana:signMessages',
          'solana:signAndSendTransactions',
        ],
      ),
    );
  }

  @override
  Future<(AuthorizationResult, WalletCapabilities)> loadCapabilities(
    String authToken,
  ) {
    return transact((wallet) async {
      final refreshedAuth = await wallet.reauthorize(authToken: authToken);
      final capabilities = await wallet.getCapabilities();
      return (refreshedAuth, capabilities);
    });
  }

  @override
  Future<(AuthorizationResult, List<String>)> signMessage({
    required String authToken,
    required String message,
  }) {
    return transact((wallet) async {
      final refreshedAuth = await wallet.reauthorize(authToken: authToken);
      if (refreshedAuth.accounts.isEmpty) {
        throw StateError('Wallet returned no accounts after reauthorize.');
      }

      final signedPayloads = await wallet.signMessages(
        addresses: <String>[refreshedAuth.accounts.first.address],
        payloads: <String>[base64Encode(utf8.encode(message))],
      );
      return (refreshedAuth, signedPayloads);
    });
  }

  @override
  Future<(AuthorizationResult, List<String>)> signAndSendTransactions({
    required String authToken,
    required List<String> payloads,
  }) {
    return transact((wallet) async {
      final refreshedAuth = await wallet.reauthorize(authToken: authToken);
      final signatures = await wallet.signAndSendTransactions(
        payloads: payloads,
      );
      return (refreshedAuth, signatures);
    });
  }

  @override
  Future<void> deauthorize(String authToken) {
    return transact((wallet) => wallet.deauthorize(authToken: authToken));
  }
}
