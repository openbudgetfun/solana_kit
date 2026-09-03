// coverage:ignore-file

import 'dart:convert';
import 'dart:typed_data';

import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';
import 'package:solana_kit_mobile_wallet_adapter/solana_kit_mobile_wallet_adapter.dart'
    as mwa;
import 'package:solana_kit_mobile_wallet_adapter_protocol/solana_kit_mobile_wallet_adapter_protocol.dart'
    as protocol;
import 'package:solana_kit_wallet_adapter/src/mobile_wallet.dart';
import 'package:solana_kit_wallet_standard/solana_kit_wallet_standard.dart';

/// Creates the native Mobile Wallet Adapter registry.
WalletRegistry createPlatformWalletRegistry({
  required WalletAppIdentity appIdentity,
  required String chain,
  List<Wallet> additionalWallets = const [],
}) => MobileWalletRegistry(
  backend: NativeMobileWalletBackend(),
  identity: appIdentity,
  chain: chain,
  additionalWallets: additionalWallets,
);

/// Android Mobile Wallet Adapter backend.
class NativeMobileWalletBackend implements MobileWalletBackend {
  String? _authToken;
  String? _walletUriBase;
  final Map<String, String> _rawAddresses = {};

  @override
  bool get isSupported => mwa.isMwaSupported();

  @override
  Future<MobileWalletAuthorization> authorize({
    required WalletAppIdentity identity,
    required String chain,
    bool silent = false,
    SolanaSignInInput? signIn,
  }) async {
    final result = await mwa.transact(
      (wallet) => wallet.authorize(
        identity: protocol.AppIdentity(
          name: identity.name,
          uri: identity.uri,
          icon: identity.icon,
        ),
        chain: chain,
        signInPayload: signIn == null ? null : _toMwaSignIn(signIn),
      ),
      config: protocol.WalletAssociationConfig(baseUri: _walletUriBase),
    );
    _authToken = result.authToken;
    _walletUriBase = result.walletUriBase ?? _walletUriBase;
    final accounts = result.accounts.map(_toWalletAccount).toList();
    final signInResult = result.signInResult;
    return MobileWalletAuthorization(
      accounts: accounts,
      signInOutput: signInResult == null
          ? null
          : SolanaSignInOutput(
              account: accounts.firstWhere(
                (account) =>
                    _rawAddresses[account.address] == signInResult.address,
                orElse: () => accounts.first,
              ),
              signedMessage: base64.decode(signInResult.signedMessage),
              signature: base64.decode(signInResult.signature),
              signatureType: signInResult.signatureType,
            ),
    );
  }

  @override
  Future<void> disconnect() async {
    final authToken = _authToken;
    if (authToken != null) {
      await mwa.transact(
        (wallet) => wallet.deauthorize(authToken: authToken),
        config: protocol.WalletAssociationConfig(baseUri: _walletUriBase),
      );
    }
    _authToken = null;
    _rawAddresses.clear();
  }

  @override
  Future<List<Uint8List>> signTransactions(
    List<Uint8List> transactions,
    WalletAccount account,
  ) => _authorized(
    (wallet) async => (await wallet.signTransactions(
      payloads: transactions.map(base64.encode).toList(),
    )).map((value) => Uint8List.fromList(base64.decode(value))).toList(),
  );

  @override
  Future<List<Uint8List>> signMessages(
    List<Uint8List> messages,
    WalletAccount account,
  ) => _authorized(
    (wallet) async => (await wallet.signMessages(
      addresses: List.filled(messages.length, _rawAddress(account)),
      payloads: messages.map(base64.encode).toList(),
    )).map((value) => Uint8List.fromList(base64.decode(value))).toList(),
  );

  @override
  Future<List<Uint8List>> signAndSendTransactions(
    List<Uint8List> transactions,
    WalletAccount account,
    SolanaSignAndSendTransactionOptions? options,
  ) => _authorized(
    (wallet) async => (await wallet.signAndSendTransactions(
      payloads: transactions.map(base64.encode).toList(),
      options: options == null
          ? null
          : protocol.SignAndSendOptions(
              minContextSlot: options.minContextSlot,
              commitment: options.commitment?.name,
              skipPreflight: options.skipPreflight,
              maxRetries: options.maxRetries,
            ),
    )).map((value) => Uint8List.fromList(base64.decode(value))).toList(),
  );

  Future<T> _authorized<T>(
    Future<T> Function(mwa.KitMobileWallet wallet) callback,
  ) async {
    final authToken = _authToken;
    if (authToken == null) {
      throw const WalletStandardException(
        WalletStandardErrorCode.disconnected,
        'Mobile wallet authorization is unavailable',
      );
    }
    return mwa.transact(
      (wallet) async {
        final refreshed = await wallet.reauthorize(authToken: authToken);
        _authToken = refreshed.authToken;
        return callback(wallet);
      },
      config: protocol.WalletAssociationConfig(baseUri: _walletUriBase),
    );
  }

  WalletAccount _toWalletAccount(protocol.MwaAccount account) {
    final publicKey = Uint8List.fromList(base64.decode(account.address));
    final displayAddress =
        account.displayAddress ?? getBase58Decoder().decode(publicKey);
    _rawAddresses[displayAddress] = account.address;
    return WalletAccount(
      address: displayAddress,
      publicKey: publicKey,
      chains: account.chains ?? SolanaChainId.values,
      features: const [
        SolanaFeatureId.signTransaction,
        SolanaFeatureId.signAndSendTransaction,
        SolanaFeatureId.signMessage,
        SolanaFeatureId.signIn,
      ],
      label: account.label,
      icon: _walletIcon(account.icon),
    );
  }

  String _rawAddress(WalletAccount account) {
    final value = _rawAddresses[account.address];
    if (value == null) {
      throw const WalletStandardException(
        WalletStandardErrorCode.invalidRequest,
        'Mobile wallet account is not authorized',
      );
    }
    return value;
  }
}

WalletIcon? _walletIcon(String? value) {
  if (value == null) return null;
  try {
    return WalletIcon(value);
  } on FormatException {
    return null;
  }
}

protocol.SignInPayload _toMwaSignIn(SolanaSignInInput input) {
  return protocol.SignInPayload(
    domain: input.domain,
    address: input.address,
    statement: input.statement,
    uri: input.uri,
    version: input.version,
    chainId: input.chainId,
    nonce: input.nonce,
    issuedAt: input.issuedAt,
    expirationTime: input.expirationTime,
    notBefore: input.notBefore,
    requestId: input.requestId,
    resources: input.resources,
  );
}
