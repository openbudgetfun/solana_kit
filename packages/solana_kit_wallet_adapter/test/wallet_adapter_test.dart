import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:solana_kit_signers/solana_kit_signers.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';
import 'package:solana_kit_transactions/solana_kit_transactions.dart';
import 'package:solana_kit_wallet_adapter/solana_kit_wallet_adapter.dart';
import 'package:solana_kit_wallet_standard/solana_kit_wallet_standard.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WalletAdapterState', () {
    test('copies every field and supports explicit nulls', () {
      final wallet = _TestWallet();
      final account = _account();
      final initial = WalletAdapterState(
        connectionStatus: WalletConnectionStatus.connected,
        operationStatus: WalletOperationStatus.signingMessage,
        wallets: [wallet],
        selectedWallet: wallet,
        selectedAccount: account,
        error: 'error',
      );
      expect(initial.isConnected, isTrue);
      expect(initial.wallets.clear, throwsUnsupportedError);
      final copy = initial.copyWith(
        connectionStatus: WalletConnectionStatus.disconnecting,
        operationStatus: WalletOperationStatus.sendingTransaction,
        wallets: const [],
        selectedWallet: null,
        selectedAccount: null,
        error: null,
      );
      expect(copy.connectionStatus, WalletConnectionStatus.disconnecting);
      expect(copy.operationStatus, WalletOperationStatus.sendingTransaction);
      expect(copy.wallets, isEmpty);
      expect(copy.selectedWallet, isNull);
      expect(copy.selectedAccount, isNull);
      expect(copy.error, isNull);
      expect(copy.isConnected, isFalse);
      expect(initial.copyWith().selectedWallet, wallet);
      expect(WalletConnectionStatus.values, hasLength(6));
      expect(WalletOperationStatus.values, hasLength(5));
    });
  });

  group('WalletController', () {
    test(
      'discovers, connects, follows account changes, and disconnects',
      () async {
        final registry = WalletRegistryController();
        final wallet = _TestWallet();
        registry.register(wallet);
        final controller = WalletController(
          registry,
          chain: SolanaChainId.localnet,
        );
        var notifications = 0;
        controller.addListener(() => notifications++);
        await controller.initialize();
        await controller.initialize();
        expect(controller.state.wallets, [wallet]);
        await controller.connect(wallet, silent: true);
        expect(wallet.lastSilent, isTrue);
        expect(controller.state.isConnected, isTrue);
        expect(controller.createSigner().account.address, _account().address);
        final firstAccount = wallet.accounts.first;
        final lastAccount = wallet.accounts.last;
        controller.selectAccount(lastAccount);
        wallet.emitAccounts([lastAccount]);
        expect(controller.state.selectedAccount, lastAccount);
        wallet.emitAccounts([firstAccount]);
        expect(controller.state.selectedAccount, wallet.accounts.first);
        wallet.emitAccounts(const []);
        expect(
          controller.state.connectionStatus,
          WalletConnectionStatus.disconnected,
        );
        wallet.emitAccounts([firstAccount]);
        await controller.connect(wallet);
        await controller.disconnect();
        expect(wallet.disconnected, isTrue);
        expect(controller.state.selectedWallet, isNull);
        expect(notifications, greaterThan(4));
        controller
          ..dispose()
          ..dispose();
        expect(controller.initialize, throwsStateError);
      },
    );

    test('responds to registry registration and removal', () async {
      final registry = WalletRegistryController();
      final controller = WalletController(
        registry,
        chain: SolanaChainId.devnet,
      );
      await controller.initialize();
      final wallet = _TestWallet();
      registry.register(wallet);
      expect(controller.state.wallets, [wallet]);
      await controller.connect(wallet);
      registry
        ..changed(wallet)
        ..unregister(wallet);
      expect(controller.state.wallets, isEmpty);
      expect(controller.state.isConnected, isFalse);
      controller.dispose();
    });

    test('reports unsupported, invalid, and rejected connections', () async {
      final registry = WalletRegistryController();
      final controller = WalletController(
        registry,
        chain: SolanaChainId.localnet,
      );
      await controller.initialize();
      expect(
        () => controller.connect(_UnsupportedWallet()),
        throwsA(isA<WalletStandardException>()),
      );
      expect(controller.createSigner, throwsA(isA<WalletStandardException>()));
      expect(
        () => controller.selectAccount(_account()),
        throwsA(isA<WalletStandardException>()),
      );
      final empty = _TestWallet(connectAccounts: const []);
      await expectLater(
        controller.connect(empty),
        throwsA(isA<WalletStandardException>()),
      );
      expect(controller.state.error, isA<WalletStandardException>());
      controller.clearError();
      expect(controller.state.error, isNull);
      final rejected = _TestWallet(connectError: StateError('rejected'));
      await expectLater(controller.connect(rejected), throwsStateError);
      expect(controller.state.selectedWallet, isNull);
      controller.dispose();
    });

    test('performs sign in and resets operation state', () async {
      final registry = WalletRegistryController();
      final wallet = _TestWallet();
      registry.register(wallet);
      final controller = WalletController(
        registry,
        chain: SolanaChainId.localnet,
      );
      await controller.initialize();
      expect(
        () => controller.signIn(const SolanaSignInInput()),
        throwsA(isA<WalletStandardException>()),
      );
      await controller.connect(wallet);
      final result = await controller.signIn(
        const SolanaSignInInput(domain: 'x'),
      );
      expect(result.account.address, _account().address);
      expect(controller.state.operationStatus, WalletOperationStatus.idle);
      wallet.signInOutputCount = 0;
      await expectLater(
        controller.signIn(const SolanaSignInInput()),
        throwsA(isA<WalletStandardException>()),
      );
      expect(controller.state.error, isNotNull);
      wallet.signInError = StateError('failed');
      await expectLater(
        controller.signIn(const SolanaSignInInput()),
        throwsStateError,
      );
      final unsupported = _TestWallet(includeSignIn: false);
      await controller.disconnect();
      await controller.connect(unsupported);
      await expectLater(
        controller.signIn(const SolanaSignInInput()),
        throwsA(isA<WalletStandardException>()),
      );
      controller.dispose();
    });
  });

  group('MobileWallet', () {
    test('exposes backend metadata and all operations', () async {
      final backend = _Backend();
      final identity = WalletAppIdentity(
        name: 'App',
        uri: Uri.https('example.test'),
        icon: 'icon.png',
      );
      expect(identity.name, 'App');
      expect(identity.uri?.host, 'example.test');
      expect(identity.icon, 'icon.png');
      final registry = MobileWalletRegistry(
        backend: backend,
        identity: identity,
        chain: SolanaChainId.localnet,
      );
      expect(registry.backend, backend);
      expect(registry.identity, identity);
      expect(registry.chain, SolanaChainId.localnet);
      await registry.initialize();
      await registry.initialize();
      final wallet = registry.wallets.single as MobileWallet;
      expect(wallet.backend, backend);
      expect(wallet.identity, identity);
      expect(wallet.chain, SolanaChainId.localnet);
      expect(wallet.version, walletStandardVersion);
      expect(wallet.name, 'Mobile wallet');
      expect(wallet.icon.mimeSubtype, 'svg+xml');
      expect(wallet.chains, [SolanaChainId.localnet]);
      expect(wallet.accounts, isEmpty);
      expect(() => wallet.features.clear(), throwsUnsupportedError);
      final changes = <StandardWalletChange>[];
      final events = wallet.feature<StandardEventsFeature>(
        StandardFeatureId.events,
      )!;
      final off = events.onChange(changes.add);
      expect(events.version, '1.0.0');
      final connect = wallet.feature<StandardConnectFeature>(
        StandardFeatureId.connect,
      )!;
      expect(connect.version, '1.0.0');
      final connected = await connect.connect(
        const StandardConnectInput(silent: true),
      );
      expect(connected.accounts, hasLength(1));
      expect(backend.lastSilent, isTrue);
      final account = connected.accounts.single;

      final signTransactions = wallet.feature<SolanaSignTransactionFeature>(
        SolanaFeatureId.signTransaction,
      )!;
      expect(signTransactions.version, '1.0.0');
      expect(
        signTransactions.supportedTransactionVersions,
        SolanaTransactionVersion.values,
      );
      expect(
        (await signTransactions.signTransaction([
          SolanaSignTransactionInput(
            account: account,
            transaction: Uint8List.fromList([1]),
          ),
        ])).single.signedTransaction,
        [1],
      );
      final send = wallet.feature<SolanaSignAndSendTransactionFeature>(
        SolanaFeatureId.signAndSendTransaction,
      )!;
      expect(send.version, '1.0.0');
      expect(
        send.supportedTransactionVersions,
        SolanaTransactionVersion.values,
      );
      expect(
        (await send.signAndSendTransaction([
          SolanaSignAndSendTransactionInput(
            account: account,
            transaction: Uint8List.fromList([2]),
            chain: SolanaChainId.localnet,
          ),
        ])).single.signature,
        hasLength(64),
      );
      final messages = wallet.feature<SolanaSignMessageFeature>(
        SolanaFeatureId.signMessage,
      )!;
      expect(messages.version, '1.1.0');
      final messageOutput = await messages.signMessage([
        SolanaSignMessageInput(
          account: account,
          message: Uint8List.fromList([3]),
        ),
      ]);
      expect(messageOutput.single.signedMessage, [3]);
      expect(messageOutput.single.signatureType, 'ed25519');

      final signIn = wallet.feature<SolanaSignInFeature>(
        SolanaFeatureId.signIn,
      )!;
      expect(signIn.version, '1.0.0');
      expect(
        (await signIn.signIn(const [SolanaSignInInput()])).single.account,
        account,
      );
      final disconnect = wallet.feature<StandardDisconnectFeature>(
        StandardFeatureId.disconnect,
      )!;
      expect(disconnect.version, '1.0.0');
      await disconnect.disconnect();
      expect(backend.disconnected, isTrue);
      expect(changes, hasLength(3));
      off();
      await connect.connect();
      expect(changes, hasLength(3));
    });

    test('does not register an unsupported mobile backend', () async {
      final registry = MobileWalletRegistry(
        backend: _Backend(supported: false),
        identity: const WalletAppIdentity(name: 'App'),
        chain: SolanaChainId.localnet,
      );
      await registry.initialize();
      expect(registry.wallets, isEmpty);
    });

    test('validates accounts, output counts, and sign-in proof', () async {
      final backend = _Backend();
      final wallet = MobileWallet(
        backend: backend,
        identity: const WalletAppIdentity(name: 'App'),
        chain: SolanaChainId.localnet,
      );
      final transactions = wallet.feature<SolanaSignTransactionFeature>(
        SolanaFeatureId.signTransaction,
      )!;
      await expectLater(
        transactions.signTransaction(const []),
        throwsA(isA<WalletStandardException>()),
      );
      final connect = wallet.feature<StandardConnectFeature>(
        StandardFeatureId.connect,
      )!;
      final account = (await connect.connect()).accounts.single;
      backend.wrongCount = true;
      await expectLater(
        transactions.signTransaction([
          SolanaSignTransactionInput(
            account: account,
            transaction: Uint8List(1),
          ),
        ]),
        throwsA(isA<WalletStandardException>()),
      );
      final send = wallet.feature<SolanaSignAndSendTransactionFeature>(
        SolanaFeatureId.signAndSendTransaction,
      )!;
      await expectLater(
        send.signAndSendTransaction([
          SolanaSignAndSendTransactionInput(
            account: account,
            transaction: Uint8List(1),
            chain: SolanaChainId.localnet,
          ),
        ]),
        throwsA(isA<WalletStandardException>()),
      );
      final messages = wallet.feature<SolanaSignMessageFeature>(
        SolanaFeatureId.signMessage,
      )!;
      await expectLater(
        messages.signMessage([
          SolanaSignMessageInput(account: account, message: Uint8List(1)),
        ]),
        throwsA(isA<WalletStandardException>()),
      );
      backend.wrongCount = false;
      await expectLater(
        messages.signMessage([
          SolanaSignMessageInput(
            account: _account(address: 'other'),
            message: Uint8List(1),
          ),
        ]),
        throwsA(isA<WalletStandardException>()),
      );
      backend.includeSignIn = false;
      await expectLater(
        wallet.feature<SolanaSignInFeature>(SolanaFeatureId.signIn)!.signIn(
          const [SolanaSignInInput()],
        ),
        throwsA(isA<WalletStandardException>()),
      );
    });
  });

  group('WalletAccountSigner', () {
    test('signs messages, transactions, and sends transactions', () async {
      final wallet = _TestWallet();
      final account = wallet.accounts.first;
      final signer = WalletAccountSigner(
        wallet: wallet,
        account: account,
        chain: SolanaChainId.localnet,
      );
      expect(signer.address.value, account.address);
      final message = createSignableMessage('hello');
      final signedMessages = await signer.modifyAndSignMessages([message]);
      expect(
        signedMessages.single.signatures[signer.address]?.value,
        hasLength(64),
      );
      final transaction = compileTransaction(
        const TransactionMessage(version: TransactionVersion.v0).copyWith(
          feePayer: signer.address,
          lifetimeConstraint: BlockhashLifetimeConstraint(
            blockhash: '11111111111111111111111111111111',
            lastValidBlockHeight: BigInt.zero,
          ),
        ),
      );
      final signedTransactions = await signer.modifyAndSignTransactions(
        [transaction],
        TransactionSignerConfig(minContextSlot: BigInt.one),
      );
      expect(signedTransactions.single.messageBytes, transaction.messageBytes);
      final signatures = await signer.signAndSendTransactions(
        [transaction],
        TransactionSignerConfig(minContextSlot: BigInt.two),
      );
      expect(signatures.single.value, hasLength(64));
    });

    test('rejects unsupported features and output count mismatches', () async {
      final unsupported = WalletAccountSigner(
        wallet: _UnsupportedWallet(),
        account: _account(),
        chain: SolanaChainId.localnet,
      );
      await expectLater(
        unsupported.modifyAndSignMessages([createSignableMessage('x')]),
        throwsA(isA<WalletStandardException>()),
      );
      await expectLater(
        unsupported.modifyAndSignTransactions(const []),
        throwsA(isA<WalletStandardException>()),
      );
      await expectLater(
        unsupported.signAndSendTransactions(const []),
        throwsA(isA<WalletStandardException>()),
      );
      final wallet = _TestWallet(wrongOutputCount: true);
      final signer = WalletAccountSigner(
        wallet: wallet,
        account: wallet.accounts.first,
        chain: SolanaChainId.localnet,
      );
      await expectLater(
        signer.modifyAndSignMessages([createSignableMessage('x')]),
        throwsA(isA<WalletStandardException>()),
      );
      final transaction = compileTransaction(
        const TransactionMessage(version: TransactionVersion.v0).copyWith(
          feePayer: signer.address,
          lifetimeConstraint: BlockhashLifetimeConstraint(
            blockhash: '11111111111111111111111111111111',
            lastValidBlockHeight: BigInt.zero,
          ),
        ),
      );
      await expectLater(
        signer.modifyAndSignTransactions([transaction]),
        throwsA(isA<WalletStandardException>()),
      );
      await expectLater(
        signer.signAndSendTransactions([transaction]),
        throwsA(isA<WalletStandardException>()),
      );
    });
  });

  test('creates the current platform registry', () {
    final registry = createDefaultWalletRegistry(
      appIdentity: const WalletAppIdentity(name: 'App'),
      chain: SolanaChainId.localnet,
    );
    expect(registry, isA<WalletRegistry>());
    registry.dispose();
  });
}

WalletAccount _account({String address = '11111111111111111111111111111111'}) =>
    WalletAccount(
      address: address,
      publicKey: Uint8List(32),
      chains: const [SolanaChainId.localnet],
      features: const [SolanaFeatureId.signMessage],
    );

class _Backend implements MobileWalletBackend {
  _Backend({this.supported = true});
  final bool supported;
  bool disconnected = false;
  bool includeSignIn = true;
  bool lastSilent = false;
  bool wrongCount = false;
  final WalletAccount account = _account();
  @override
  bool get isSupported => supported;
  @override
  Future<MobileWalletAuthorization> authorize({
    required WalletAppIdentity identity,
    required String chain,
    bool silent = false,
    SolanaSignInInput? signIn,
  }) async {
    lastSilent = silent;
    return MobileWalletAuthorization(
      accounts: [account],
      signInOutput: signIn != null && includeSignIn
          ? SolanaSignInOutput(
              account: account,
              signedMessage: Uint8List(1),
              signature: Uint8List(64),
            )
          : null,
    );
  }

  @override
  Future<void> disconnect() async => disconnected = true;
  @override
  Future<List<Uint8List>> signAndSendTransactions(
    List<Uint8List> transactions,
    WalletAccount account,
    SolanaSignAndSendTransactionOptions? options,
  ) async => wrongCount ? [] : transactions.map((_) => Uint8List(64)).toList();
  @override
  Future<List<Uint8List>> signMessages(
    List<Uint8List> messages,
    WalletAccount account,
  ) async => wrongCount ? [] : messages.map((_) => Uint8List(64)).toList();
  @override
  Future<List<Uint8List>> signTransactions(
    List<Uint8List> transactions,
    WalletAccount account,
  ) async => wrongCount ? [] : transactions.map(Uint8List.fromList).toList();
}

class _TestWallet implements Wallet {
  _TestWallet({
    this.connectAccounts,
    this.connectError,
    this.includeSignIn = true,
    this.wrongOutputCount = false,
  }) {
    _accounts =
        connectAccounts ??
        [_account(), _account(address: '11111111111111111111111111111112')];
    features = {
      StandardFeatureId.connect: _TestConnect(this),
      StandardFeatureId.disconnect: _TestDisconnect(this),
      StandardFeatureId.events: _TestEvents(this),
      SolanaFeatureId.signMessage: _TestSignMessage(this),
      SolanaFeatureId.signTransaction: _TestSignTransaction(this),
      SolanaFeatureId.signAndSendTransaction: _TestSendTransaction(this),
      if (includeSignIn) SolanaFeatureId.signIn: _TestSignIn(this),
    };
  }
  final List<WalletAccount>? connectAccounts;
  final Error? connectError;
  final bool includeSignIn;
  final bool wrongOutputCount;
  late List<WalletAccount> _accounts;
  @override
  late final Map<String, WalletFeature> features;
  bool disconnected = false;
  bool lastSilent = false;
  int signInOutputCount = 1;
  Error? signInError;
  void Function(StandardWalletChange)? listener;
  void emitAccounts(List<WalletAccount> value) {
    _accounts = value;
    listener?.call(StandardWalletChange(accounts: value));
  }

  @override
  List<WalletAccount> get accounts => _accounts;
  @override
  List<String> get chains => const [SolanaChainId.localnet];
  @override
  WalletIcon get icon => WalletIcon(_icon);
  @override
  String get name => 'Test wallet';
  @override
  String get version => walletStandardVersion;
}

class _UnsupportedWallet implements Wallet {
  @override
  List<WalletAccount> get accounts => const [];
  @override
  List<String> get chains => const [];
  @override
  Map<String, WalletFeature> get features => const {};
  @override
  WalletIcon get icon => WalletIcon(_icon);
  @override
  String get name => 'Unsupported';
  @override
  String get version => walletStandardVersion;
}

class _TestConnect implements StandardConnectFeature {
  const _TestConnect(this.wallet);
  final _TestWallet wallet;
  @override
  Future<StandardConnectOutput> connect([
    StandardConnectInput input = const StandardConnectInput(),
  ]) async {
    wallet.lastSilent = input.silent;
    if (wallet.connectError case final error?) throw error;
    return StandardConnectOutput(wallet.accounts);
  }

  @override
  String get version => '1.0.0';
}

class _TestDisconnect implements StandardDisconnectFeature {
  const _TestDisconnect(this.wallet);
  final _TestWallet wallet;
  @override
  Future<void> disconnect() async => wallet.disconnected = true;
  @override
  String get version => '1.0.0';
}

class _TestEvents implements StandardEventsFeature {
  const _TestEvents(this.wallet);
  final _TestWallet wallet;
  @override
  void Function() onChange(
    void Function(StandardWalletChange change) listener,
  ) {
    wallet.listener = listener;
    return () => wallet.listener = null;
  }

  @override
  String get version => '1.0.0';
}

class _TestSignMessage implements SolanaSignMessageFeature {
  const _TestSignMessage(this.wallet);
  final _TestWallet wallet;
  @override
  Future<List<SolanaSignMessageOutput>> signMessage(
    List<SolanaSignMessageInput> inputs,
  ) async => wallet.wrongOutputCount
      ? []
      : inputs
            .map(
              (input) => SolanaSignMessageOutput(
                signedMessage: input.message,
                signature: Uint8List(64),
              ),
            )
            .toList();
  @override
  String get version => '1.0.0';
}

class _TestSignTransaction implements SolanaSignTransactionFeature {
  const _TestSignTransaction(this.wallet);
  final _TestWallet wallet;
  @override
  Future<List<SolanaSignTransactionOutput>> signTransaction(
    List<SolanaSignTransactionInput> inputs,
  ) async => wallet.wrongOutputCount
      ? []
      : inputs
            .map((input) => SolanaSignTransactionOutput(input.transaction))
            .toList();
  @override
  List<SolanaTransactionVersion> get supportedTransactionVersions =>
      SolanaTransactionVersion.values;
  @override
  String get version => '1.0.0';
}

class _TestSendTransaction implements SolanaSignAndSendTransactionFeature {
  const _TestSendTransaction(this.wallet);
  final _TestWallet wallet;
  @override
  Future<List<SolanaSignAndSendTransactionOutput>> signAndSendTransaction(
    List<SolanaSignAndSendTransactionInput> inputs,
  ) async => wallet.wrongOutputCount
      ? []
      : inputs
            .map((_) => SolanaSignAndSendTransactionOutput(Uint8List(64)))
            .toList();
  @override
  List<SolanaTransactionVersion> get supportedTransactionVersions =>
      SolanaTransactionVersion.values;
  @override
  String get version => '1.0.0';
}

class _TestSignIn implements SolanaSignInFeature {
  const _TestSignIn(this.wallet);
  final _TestWallet wallet;
  @override
  Future<List<SolanaSignInOutput>> signIn(
    List<SolanaSignInInput> inputs,
  ) async {
    if (wallet.signInError case final error?) throw error;
    return List.generate(
      wallet.signInOutputCount,
      (_) => SolanaSignInOutput(
        account: wallet.accounts.first,
        signedMessage: Uint8List(1),
        signature: Uint8List(64),
      ),
    );
  }

  @override
  String get version => '1.0.0';
}

const _icon = 'data:image/png;base64,AA==';
