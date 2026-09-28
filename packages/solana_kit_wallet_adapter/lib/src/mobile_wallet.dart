import 'dart:convert';
import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart' as addresses;
import 'package:solana_kit_keys/solana_kit_keys.dart';
import 'package:solana_kit_transactions/solana_kit_transactions.dart';
import 'package:solana_kit_wallet_standard/solana_kit_wallet_standard.dart';

/// A signature algorithm name whose signatures this package can verify.
const _supportedSignatureType = 'ed25519';

/// Metadata supplied to wallet authorization prompts.
class WalletAppIdentity {
  /// Creates application identity metadata.
  const WalletAppIdentity({required this.name, this.uri, this.icon});

  /// Application display name.
  final String name;

  /// Verified application URI.
  final Uri? uri;

  /// Icon path relative to [uri].
  final String? icon;
}

/// Mobile authorization state returned by a backend.
class MobileWalletAuthorization {
  /// Creates mobile authorization state.
  MobileWalletAuthorization({
    required List<WalletAccount> accounts,
    this.signInOutput,
  }) : accounts = List.unmodifiable(accounts);

  /// Accounts authorized by the user.
  final List<WalletAccount> accounts;

  /// Sign-in proof when authorization included SIWS.
  final SolanaSignInOutput? signInOutput;
}

/// Platform boundary used by the synthetic mobile Wallet Standard wallet.
abstract interface class MobileWalletBackend {
  /// Whether this backend can launch a wallet on the current platform.
  bool get isSupported;

  /// Authorizes accounts, optionally requesting Sign In With Solana.
  Future<MobileWalletAuthorization> authorize({
    required WalletAppIdentity identity,
    required String chain,
    bool silent = false,
    SolanaSignInInput? signIn,
  });

  /// Revokes or cleans up the active authorization.
  Future<void> disconnect();

  /// Signs serialized transactions.
  Future<List<Uint8List>> signTransactions(
    List<Uint8List> transactions,
    WalletAccount account,
  );

  /// Signs arbitrary messages.
  Future<List<Uint8List>> signMessages(
    List<Uint8List> messages,
    WalletAccount account,
  );

  /// Signs and submits serialized transactions.
  Future<List<Uint8List>> signAndSendTransactions(
    List<Uint8List> transactions,
    WalletAccount account,
    SolanaSignAndSendTransactionOptions? options,
  );
}

/// Registry exposing Mobile Wallet Adapter as one Wallet Standard wallet.
class MobileWalletRegistry extends WalletRegistryController {
  /// Creates a mobile registry that also keeps [additionalWallets] available.
  MobileWalletRegistry({
    required this.backend,
    required this.identity,
    required this.chain,
    this.additionalWallets = const [],
  });

  /// The transport used for wallet requests.
  final MobileWalletBackend backend;

  /// The application identity shown by wallet prompts.
  final WalletAppIdentity identity;

  /// The chain used by wallet requests.
  final String chain;

  /// Wallets that are always available, regardless of detection.
  final List<Wallet> additionalWallets;

  bool _initialized = false;

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    if (backend.isSupported) {
      register(
        MobileWallet(
          backend: backend,
          identity: identity,
          chain: chain,
        ),
      );
    }
    for (final wallet in additionalWallets) {
      register(wallet);
    }
  }
}

/// A synthetic Wallet Standard wallet backed by Mobile Wallet Adapter.
class MobileWallet implements Wallet {
  /// Creates a synthetic mobile wallet.
  MobileWallet({
    required this.backend,
    required this.identity,
    required this.chain,
  }) : icon = WalletIcon(_mobileWalletIcon) {
    _events = _MobileEventsFeature();
    _features = {
      StandardFeatureId.connect: _MobileConnectFeature(this),
      StandardFeatureId.disconnect: _MobileDisconnectFeature(this),
      StandardFeatureId.events: _events,
      SolanaFeatureId.signTransaction: _MobileSignTransactionFeature(this),
      SolanaFeatureId.signAndSendTransaction:
          _MobileSignAndSendTransactionFeature(this),
      SolanaFeatureId.signMessage: _MobileSignMessageFeature(this),
      SolanaFeatureId.signIn: _MobileSignInFeature(this),
    };
  }

  /// The transport used for wallet requests.
  final MobileWalletBackend backend;

  /// The application identity shown by wallet prompts.
  final WalletAppIdentity identity;

  /// The chain used by wallet requests.
  final String chain;
  late final _MobileEventsFeature _events;
  late final Map<String, WalletFeature> _features;
  List<WalletAccount> _accounts = const [];
  int _authorizationGeneration = 0;

  @override
  String get version => walletStandardVersion;

  @override
  String get name => 'Mobile wallet';

  @override
  final WalletIcon icon;

  @override
  List<String> get chains => [chain];

  @override
  Map<String, WalletFeature> get features => Map.unmodifiable(_features);

  @override
  List<WalletAccount> get accounts => List.unmodifiable(_accounts);

  Future<StandardConnectOutput> _connect(StandardConnectInput input) async {
    final generation = ++_authorizationGeneration;
    final authorization = await backend.authorize(
      identity: identity,
      chain: chain,
      silent: input.silent,
    );
    _assertCurrentAuthorization(generation);
    _setAccounts(authorization.accounts);
    return StandardConnectOutput(_accounts);
  }

  Future<void> _disconnect() async {
    _authorizationGeneration++;
    _setAccounts(const []);
    await backend.disconnect();
  }

  Future<List<SolanaSignTransactionOutput>> _signTransactions(
    List<SolanaSignTransactionInput> inputs,
  ) async {
    _assertAccounts(inputs.map((input) => input.account));
    _assertTransactionChains(inputs);
    final signed = await backend.signTransactions(
      inputs.map((input) => input.transaction).toList(),
      inputs.first.account,
    );
    _assertOutputLength(inputs.length, signed.length);
    return [
      for (var index = 0; index < inputs.length; index++)
        _assertVerifiedSignedTransaction(inputs[index], signed[index]),
    ];
  }

  Future<List<SolanaSignAndSendTransactionOutput>> _signAndSendTransactions(
    List<SolanaSignAndSendTransactionInput> inputs,
  ) async {
    _assertAccounts(inputs.map((input) => input.account));
    _assertTransactionChains(inputs);
    final policies = inputs.map((input) {
      final options = input.options;
      return (
        options?.preflightCommitment,
        options?.minContextSlot,
        options?.commitment,
        options?.skipPreflight,
        options?.maxRetries,
      );
    }).toSet();
    if (policies.length > 1) {
      throw const WalletStandardException(
        WalletStandardErrorCode.invalidRequest,
        'Mobile wallet batches must use the same submission options',
      );
    }
    final signatures = await backend.signAndSendTransactions(
      inputs.map((input) => input.transaction).toList(),
      inputs.first.account,
      inputs.first.options,
    );
    _assertOutputLength(inputs.length, signatures.length);
    return [
      for (var index = 0; index < inputs.length; index++)
        SolanaSignAndSendTransactionOutput(
          _assertVerifiedTransactionSignature(inputs[index], signatures[index]),
        ),
    ];
  }

  Future<List<SolanaSignMessageOutput>> _signMessages(
    List<SolanaSignMessageInput> inputs,
  ) async {
    _assertAccounts(inputs.map((input) => input.account));
    final signatures = await backend.signMessages(
      inputs.map((input) => input.message).toList(),
      inputs.first.account,
    );
    _assertOutputLength(inputs.length, signatures.length);
    return [
      for (var index = 0; index < inputs.length; index++)
        SolanaSignMessageOutput(
          signedMessage: inputs[index].message,
          signature: _assertVerifiedSignature(
            account: inputs[index].account,
            signature: signatures[index],
            signedBytes: inputs[index].message,
          ),
          signatureType: _supportedSignatureType,
        ),
    ];
  }

  void _assertOutputLength(int inputs, int outputs) {
    if (inputs != outputs) {
      throw const WalletStandardException(
        WalletStandardErrorCode.invalidResponse,
        'Mobile wallet output count does not match the input count',
      );
    }
  }

  Future<List<SolanaSignInOutput>> _signIn(
    List<SolanaSignInInput> inputs,
  ) async {
    final generation = ++_authorizationGeneration;
    final results = <SolanaSignInOutput>[];
    for (final input in inputs) {
      final authorization = await backend.authorize(
        identity: identity,
        chain: chain,
        signIn: input,
      );
      _assertCurrentAuthorization(generation);
      _setAccounts(authorization.accounts);
      final output = authorization.signInOutput;
      if (output == null) {
        throw const WalletStandardException(
          WalletStandardErrorCode.invalidResponse,
          'Mobile wallet did not return a sign-in proof',
        );
      }
      // The backend may present the proof against any of the accounts it
      // authorized alongside it, but the proof must verify against the
      // account it is attached to.
      if (!authorization.accounts.contains(output.account)) {
        throw const WalletStandardException(
          WalletStandardErrorCode.invalidResponse,
          'Mobile wallet attached the sign-in proof to an unauthorized '
          'account',
        );
      }
      _assertVerifiedSignature(
        account: output.account,
        signature: output.signature,
        signedBytes: output.signedMessage,
      );
      if (output.signatureType != null &&
          output.signatureType != _supportedSignatureType) {
        throw const WalletStandardException(
          WalletStandardErrorCode.invalidResponse,
          'Mobile wallet returned an unsupported signature type',
        );
      }
      results.add(output);
    }
    return results;
  }

  /// Verifies a wallet-returned [signature] over [signedBytes] against
  /// [account]'s public key before it can be treated as authentic.
  ///
  /// A compromised wallet can return any bytes it likes; without this check a
  /// well-formed but forged signature flows into `SignableMessage` and
  /// `Transaction` objects as if the account had actually signed.
  Uint8List _assertVerifiedSignature({
    required WalletAccount account,
    required Uint8List signature,
    required Uint8List signedBytes,
  }) {
    final isValid =
        signature.length == 64 &&
        verifySignature(
          account.publicKey,
          SignatureBytes(Uint8List.fromList(signature)),
          signedBytes,
        );
    if (!isValid) {
      throw const WalletStandardException(
        WalletStandardErrorCode.invalidResponse,
        'Wallet signature does not verify against the authorized account',
      );
    }
    return signature;
  }

  /// Verifies the account's signature inside a wallet-returned signed
  /// transaction and returns the signed transaction output.
  ///
  /// A wallet that returns a different transaction than the one it was
  /// given — or one whose signature does not verify — is rejected. The
  /// signed message bytes must match the submission byte-for-byte, so a
  /// wallet cannot slip a modified transaction past a caller that reviewed
  /// it.
  SolanaSignTransactionOutput _assertVerifiedSignedTransaction(
    SolanaSignTransactionInput input,
    Uint8List signedTransaction,
  ) {
    final signed = getTransactionDecoder().decode(signedTransaction);
    final submitted = getTransactionDecoder().decode(input.transaction);
    if (!_bytesEqual(signed.messageBytes, submitted.messageBytes)) {
      throw const WalletStandardException(
        WalletStandardErrorCode.invalidResponse,
        'Wallet signed a different transaction',
      );
    }
    final signature = signed.signatures[_address(input.account)];
    if (signature == null) {
      throw const WalletStandardException(
        WalletStandardErrorCode.invalidResponse,
        'Wallet signed transaction does not include the authorized account',
      );
    }
    _assertVerifiedSignature(
      account: input.account,
      signature: signature.value,
      signedBytes: signed.messageBytes,
    );
    return SolanaSignTransactionOutput(signedTransaction);
  }

  /// Verifies that a wallet-reported submission signature is a genuine
  /// signature of the submitted transaction's message bytes.
  ///
  /// The MWA `sign_and_send_transactions` result is the submitted
  /// transaction's own signature — a required signer's Ed25519 signature
  /// over its message bytes. The submission is verified against the
  /// authorized account first and every declared signer public key second,
  /// so a wallet that reports a signature for a different transaction — or
  /// an arbitrary byte string — is rejected before the caller records it.
  Uint8List _assertVerifiedTransactionSignature(
    SolanaSignAndSendTransactionInput input,
    Uint8List reportedSignature,
  ) {
    if (reportedSignature.length != 64) {
      throw const WalletStandardException(
        WalletStandardErrorCode.invalidResponse,
        'Wallet reported a malformed transaction signature',
      );
    }
    final transaction = getTransactionDecoder().decode(input.transaction);
    final isValid =
        verifySignature(
          input.account.publicKey,
          SignatureBytes(Uint8List.fromList(reportedSignature)),
          transaction.messageBytes,
        ) ||
        transaction.signatures.keys.any(
          (signerAddress) => verifySignature(
            addresses.getPublicKeyFromAddress(signerAddress),
            SignatureBytes(Uint8List.fromList(reportedSignature)),
            transaction.messageBytes,
          ),
        );
    if (!isValid) {
      throw const WalletStandardException(
        WalletStandardErrorCode.invalidResponse,
        'Wallet reported a signature for a different transaction',
      );
    }
    return reportedSignature;
  }

  addresses.Address _address(WalletAccount account) =>
      addresses.address(account.address);

  static bool _bytesEqual(Uint8List a, Uint8List b) {
    if (a.length != b.length) return false;
    for (var index = 0; index < a.length; index++) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }

  void _setAccounts(List<WalletAccount> accounts) {
    _accounts = List.unmodifiable(accounts);
    _events.emit(StandardWalletChange(accounts: _accounts));
  }

  void _assertCurrentAuthorization(int generation) {
    if (generation != _authorizationGeneration) {
      throw const WalletStandardException(
        WalletStandardErrorCode.disconnected,
        'Mobile wallet authorization was superseded or disconnected',
      );
    }
  }

  void _assertAccounts(Iterable<WalletAccount> accounts) {
    final values = accounts.toList();
    if (values.isEmpty ||
        values.any(
          (account) => account != values.first || !_accounts.contains(account),
        )) {
      throw const WalletStandardException(
        WalletStandardErrorCode.invalidRequest,
        'Mobile wallet requests must use a single authorized account',
      );
    }
  }

  void _assertTransactionChains(List<SolanaSignTransactionInput> inputs) {
    if (inputs.any((input) => input.chain != null && input.chain != chain)) {
      throw const WalletStandardException(
        WalletStandardErrorCode.invalidRequest,
        'Mobile wallet transaction chain does not match the authorized chain',
      );
    }
  }
}

class _MobileConnectFeature implements StandardConnectFeature {
  const _MobileConnectFeature(this.wallet);
  final MobileWallet wallet;
  @override
  String get version => '1.0.0';
  @override
  Future<StandardConnectOutput> connect([
    StandardConnectInput input = const StandardConnectInput(),
  ]) => wallet._connect(input);
}

class _MobileDisconnectFeature implements StandardDisconnectFeature {
  const _MobileDisconnectFeature(this.wallet);
  final MobileWallet wallet;
  @override
  String get version => '1.0.0';
  @override
  Future<void> disconnect() => wallet._disconnect();
}

class _MobileEventsFeature implements StandardEventsFeature {
  final List<void Function(StandardWalletChange)> _listeners = [];
  @override
  String get version => '1.0.0';
  @override
  void Function() onChange(void Function(StandardWalletChange) listener) {
    _listeners.add(listener);
    return () => _listeners.remove(listener);
  }

  void emit(StandardWalletChange change) {
    for (final listener in List.of(_listeners)) {
      listener(change);
    }
  }
}

class _MobileSignTransactionFeature implements SolanaSignTransactionFeature {
  const _MobileSignTransactionFeature(this.wallet);
  final MobileWallet wallet;
  @override
  String get version => '1.0.0';
  @override
  List<SolanaTransactionVersion> get supportedTransactionVersions => const [
    SolanaTransactionVersion.legacy,
    SolanaTransactionVersion.version0,
  ];
  @override
  Future<List<SolanaSignTransactionOutput>> signTransaction(
    List<SolanaSignTransactionInput> inputs,
  ) => wallet._signTransactions(inputs);
}

class _MobileSignAndSendTransactionFeature
    implements SolanaSignAndSendTransactionFeature {
  const _MobileSignAndSendTransactionFeature(this.wallet);
  final MobileWallet wallet;
  @override
  String get version => '1.0.0';
  @override
  List<SolanaTransactionVersion> get supportedTransactionVersions => const [
    SolanaTransactionVersion.legacy,
    SolanaTransactionVersion.version0,
  ];
  @override
  Future<List<SolanaSignAndSendTransactionOutput>> signAndSendTransaction(
    List<SolanaSignAndSendTransactionInput> inputs,
  ) => wallet._signAndSendTransactions(inputs);
}

class _MobileSignMessageFeature implements SolanaSignMessageFeature {
  const _MobileSignMessageFeature(this.wallet);
  final MobileWallet wallet;
  @override
  String get version => '1.1.0';
  @override
  Future<List<SolanaSignMessageOutput>> signMessage(
    List<SolanaSignMessageInput> inputs,
  ) => wallet._signMessages(inputs);
}

class _MobileSignInFeature implements SolanaSignInFeature {
  const _MobileSignInFeature(this.wallet);
  final MobileWallet wallet;
  @override
  String get version => '1.0.0';
  @override
  Future<List<SolanaSignInOutput>> signIn(List<SolanaSignInInput> inputs) =>
      wallet._signIn(inputs);
}

final _mobileWalletIcon =
    'data:image/svg+xml;base64,${base64.encode(utf8.encode(_mobileWalletSvg))}';

const _mobileWalletSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 96 96">
  <rect width="96" height="96" rx="24" fill="#11131a"/>
  <path d="M25 29h48l-8 9H17zM31 44h48l-8 9H23zM25 59h48l-8 9H17z" fill="#58f5b4"/>
</svg>
''';
