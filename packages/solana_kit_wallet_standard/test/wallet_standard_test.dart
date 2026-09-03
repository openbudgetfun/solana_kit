import 'dart:typed_data';

import 'package:solana_kit_wallet_standard/solana_kit_wallet_standard.dart';
import 'package:test/test.dart';

void main() {
  group('identifiers and errors', () {
    test('exposes canonical identifiers', () {
      expect(walletStandardVersion, '1.0.0');
      expect(StandardFeatureId.connect, 'standard:connect');
      expect(StandardFeatureId.disconnect, 'standard:disconnect');
      expect(StandardFeatureId.events, 'standard:events');
      expect(SolanaChainId.values, hasLength(4));
      expect(SolanaFeatureId.signAndSendAllTransactions, contains(':'));
      expect(SolanaFeatureId.signAndSendTransaction, contains(':'));
      expect(SolanaFeatureId.signIn, contains(':'));
      expect(SolanaFeatureId.signMessage, contains(':'));
      expect(SolanaFeatureId.signOffchainMessage, contains(':'));
      expect(SolanaFeatureId.signTransaction, contains(':'));
      expect(isWalletStandardIdentifier('standard:connect'), isTrue);
      expect(isWalletStandardIdentifier(':connect'), isFalse);
      expect(isWalletStandardIdentifier('standard:'), isFalse);
      expect(isWalletStandardIdentifier('connect'), isFalse);
    });

    test('preserves typed error details', () {
      const error = WalletStandardException(
        WalletStandardErrorCode.transport,
        'failed',
        cause: 'network',
      );
      expect(error.code, WalletStandardErrorCode.transport);
      expect(error.message, 'failed');
      expect(error.cause, 'network');
      expect(error.toString(), contains('failed'));
      expect(WalletStandardErrorCode.values, hasLength(8));
    });
  });

  group('wallet data', () {
    test('validates and decodes icons', () {
      final icon = WalletIcon(_icon);
      expect(icon.dataUri, _icon);
      expect(icon.mimeSubtype, 'png');
      expect(icon.mimeType, 'image/png');
      expect(icon.bytes, [0]);
      expect(icon.toString(), _icon);
      expect(
        () => WalletIcon('https://wallet.test/icon.png'),
        throwsFormatException,
      );
      expect(
        () => WalletIcon('data:image/png;base64,!'),
        throwsFormatException,
      );
    });

    test('copies and validates account metadata', () {
      final publicKey = Uint8List(32);
      final chains = [SolanaChainId.localnet];
      final features = [SolanaFeatureId.signMessage];
      final account = WalletAccount(
        address: 'address',
        publicKey: publicKey,
        chains: chains,
        features: features,
        label: 'Primary',
        icon: WalletIcon(_icon),
      );
      publicKey[0] = 2;
      chains.add(SolanaChainId.devnet);
      features.add(SolanaFeatureId.signIn);
      expect(account.publicKey.first, 0);
      expect(account.chains, [SolanaChainId.localnet]);
      expect(account.features, [SolanaFeatureId.signMessage]);
      expect(account.label, 'Primary');
      expect(account.icon, isNotNull);
      expect(() => account.chains.add('x:y'), throwsUnsupportedError);
      expect(
        () => WalletAccount(
          address: '',
          publicKey: Uint8List(32),
          chains: const [],
          features: const [],
        ),
        throwsArgumentError,
      );
      expect(
        () => WalletAccount(
          address: 'a',
          publicKey: Uint8List(31),
          chains: const [],
          features: const [],
        ),
        throwsArgumentError,
      );
      expect(
        () => WalletAccount(
          address: 'a',
          publicKey: Uint8List(32),
          chains: const ['invalid'],
          features: const [],
        ),
        throwsArgumentError,
      );
      expect(
        () => WalletAccount(
          address: 'a',
          publicKey: Uint8List(32),
          chains: const [],
          features: const ['invalid'],
        ),
        throwsArgumentError,
      );
    });

    test('looks up typed wallet features', () {
      final wallet = _Wallet();
      expect(
        wallet.feature<StandardConnectFeature>(StandardFeatureId.connect),
        isA<_Connect>(),
      );
      expect(
        wallet.feature<SolanaSignMessageFeature>(StandardFeatureId.connect),
        isNull,
      );
      expect(wallet.supports(StandardFeatureId.connect), isTrue);
      expect(wallet.supports(StandardFeatureId.events), isFalse);
      expect(wallet.version, walletStandardVersion);
      expect(wallet.name, 'Test wallet');
      expect(wallet.icon.mimeType, 'image/png');
      expect(wallet.chains, [SolanaChainId.localnet]);
      expect(wallet.accounts, hasLength(1));
    });
  });

  group('standard features', () {
    test('models connect and change payloads', () async {
      const input = StandardConnectInput(silent: true);
      expect(input.silent, isTrue);
      final account = _account();
      final output = StandardConnectOutput([account]);
      expect(output.accounts, [account]);
      expect(output.accounts.clear, throwsUnsupportedError);
      final change = StandardWalletChange(
        chains: const [SolanaChainId.devnet],
        features: {_Feature.id: const _Feature()},
        accounts: [account],
      );
      expect(change.chains, [SolanaChainId.devnet]);
      expect(change.features, hasLength(1));
      expect(change.accounts, [account]);
      expect((await const _Connect().connect()).accounts, hasLength(1));
      await const _Disconnect().disconnect();
      var changed = false;
      final off = _Events().onChange(
        (value) => changed = value.accounts != null,
      );
      expect(changed, isTrue);
      off();
    });
  });

  group('Solana features', () {
    test('models transaction inputs and outputs', () {
      final account = _account();
      const options = SolanaSignTransactionOptions(
        preflightCommitment: SolanaTransactionCommitment.confirmed,
        minContextSlot: 4,
      );
      final input = SolanaSignTransactionInput(
        account: account,
        transaction: Uint8List.fromList([1, 2]),
        chain: SolanaChainId.localnet,
        options: options,
      );
      expect(input.account, account);
      expect(input.transaction, [1, 2]);
      expect(input.chain, SolanaChainId.localnet);
      expect(input.options, options);
      expect(
        options.preflightCommitment,
        SolanaTransactionCommitment.confirmed,
      );
      expect(options.minContextSlot, 4);
      final output = SolanaSignTransactionOutput(Uint8List.fromList([3]));
      expect(output.signedTransaction, [3]);

      const sendOptions = SolanaSignAndSendTransactionOptions(
        preflightCommitment: SolanaTransactionCommitment.processed,
        minContextSlot: 5,
        commitment: SolanaTransactionCommitment.finalized,
        skipPreflight: true,
        maxRetries: 2,
      );
      final sendInput = SolanaSignAndSendTransactionInput(
        account: account,
        transaction: Uint8List.fromList([4]),
        chain: SolanaChainId.devnet,
        options: sendOptions,
      );
      expect(sendInput.options, sendOptions);
      expect(sendOptions.commitment, SolanaTransactionCommitment.finalized);
      expect(sendOptions.skipPreflight, isTrue);
      expect(sendOptions.maxRetries, 2);
      expect(
        SolanaSignAndSendTransactionOutput(Uint8List.fromList([5])).signature,
        [5],
      );
      expect(SolanaTransactionVersion.values, hasLength(2));
      expect(SolanaTransactionCommitment.values, hasLength(3));
    });

    test('models batch results', () {
      final output = SolanaSignAndSendTransactionOutput(
        Uint8List.fromList([1]),
      );
      final success = SolanaSignAndSendAllSuccess(output);
      const failure = SolanaSignAndSendAllFailure('rejected');
      expect(success.output, output);
      expect(failure.error, 'rejected');
      expect(SolanaSignAndSendAllMode.values, hasLength(2));
    });

    test('models messages and sign in', () {
      final account = _account();
      final input = SolanaSignMessageInput(
        account: account,
        message: Uint8List.fromList([1, 2]),
      );
      expect(input.account, account);
      expect(input.message, [1, 2]);
      final output = SolanaSignMessageOutput(
        signedMessage: Uint8List.fromList([1, 2]),
        signature: Uint8List.fromList([3]),
        signatureType: 'ed25519',
      );
      expect(output.signedMessage, [1, 2]);
      expect(output.signature, [3]);
      expect(output.signatureType, 'ed25519');
      const signIn = SolanaSignInInput(
        domain: 'example.test',
        address: 'address',
        statement: 'Sign in',
        uri: 'https://example.test',
        version: '1',
        chainId: '1',
        nonce: 'nonce',
        issuedAt: 'now',
        expirationTime: 'later',
        notBefore: 'now',
        requestId: 'request',
        resources: ['https://example.test/resource'],
      );
      expect(signIn.domain, 'example.test');
      expect(signIn.address, 'address');
      expect(signIn.statement, 'Sign in');
      expect(signIn.uri, 'https://example.test');
      expect(signIn.version, '1');
      expect(signIn.chainId, '1');
      expect(signIn.nonce, 'nonce');
      expect(signIn.issuedAt, 'now');
      expect(signIn.expirationTime, 'later');
      expect(signIn.notBefore, 'now');
      expect(signIn.requestId, 'request');
      expect(signIn.resources, hasLength(1));
      final signInOutput = SolanaSignInOutput(
        account: account,
        signedMessage: Uint8List.fromList([1]),
        signature: Uint8List.fromList([2]),
      );
      expect(signInOutput.account, account);
    });

    test('models offchain messages', () {
      final account = _account();
      final input = SolanaSignOffchainMessageInput(
        account: account,
        message: 'hello',
        requiredSigners: [Uint8List(32)],
      );
      expect(input.account, account);
      expect(input.message, 'hello');
      expect(input.requiredSigners.single, hasLength(32));
      final output = SolanaSignOffchainMessageOutput(
        signedOffchainMessage: Uint8List.fromList([1]),
        signature: Uint8List.fromList([2]),
        signatureType: 'ed25519',
      );
      expect(output.signedOffchainMessage, [1]);
      expect(output.signature, [2]);
      expect(output.signatureType, 'ed25519');
    });
  });

  test('registry deduplicates wallets that share a name', () async {
    final registry = WalletRegistryController();
    final events = <WalletRegistryEvent>[];
    registry.events.listen(events.add);
    await registry.initialize();
    final off = registry.register(_Wallet());
    final duplicateOff = registry.register(_Wallet());
    final otherOff = registry.register(_Wallet('Other wallet'));
    expect(
      registry.wallets.map((wallet) => wallet.name),
      ['Test wallet', 'Other wallet'],
    );
    expect(
      events.whereType<WalletRegistered>().map((event) => event.wallet.name),
      ['Test wallet', 'Other wallet'],
    );
    // Unregistering a skipped duplicate must not remove the original.
    duplicateOff();
    expect(
      registry.wallets.map((wallet) => wallet.name),
      ['Test wallet', 'Other wallet'],
    );
    otherOff();
    off();
    expect(registry.wallets, isEmpty);
    await registry.dispose();
  });

  test('registry emits deterministic mutations and disposes safely', () async {
    final registry = WalletRegistryController();
    final wallet = _Wallet();
    final events = <WalletRegistryEvent>[];
    registry.events.listen(events.add);
    await registry.initialize();
    final off = registry.register(wallet);
    final duplicateOff = registry.register(wallet);
    registry
      ..changed(wallet)
      ..changed(_Wallet());
    duplicateOff();
    expect(registry.wallets, [wallet]);
    expect(() => registry.wallets.clear(), throwsUnsupportedError);
    off();
    off();
    registry.unregister(wallet);
    expect(events[0], isA<WalletRegistered>());
    expect(events[0].wallet, wallet);
    expect(events[1], isA<WalletChanged>());
    expect(events[2], isA<WalletUnregistered>());
    await registry.dispose();
    await registry.dispose();
    registry
      ..unregister(wallet)
      ..changed(wallet);
    expect(() => registry.register(wallet), throwsStateError);
  });
}

WalletAccount _account() => WalletAccount(
  address: '11111111111111111111111111111111',
  publicKey: Uint8List(32),
  chains: const [SolanaChainId.localnet],
  features: const [SolanaFeatureId.signMessage],
);

class _Wallet implements Wallet {
  _Wallet([this.name = 'Test wallet']);

  @override
  final String name;

  final WalletAccount _value = _account();
  @override
  List<WalletAccount> get accounts => [_value];
  @override
  List<String> get chains => const [SolanaChainId.localnet];
  @override
  Map<String, WalletFeature> get features => const {
    StandardFeatureId.connect: _Connect(),
  };
  @override
  WalletIcon get icon => WalletIcon(_icon);
  @override
  String get version => walletStandardVersion;
}

class _Feature implements WalletFeature {
  const _Feature();
  static const id = 'test:feature';
  @override
  String get version => '1.0.0';
}

class _Connect implements StandardConnectFeature {
  const _Connect();
  @override
  Future<StandardConnectOutput> connect([
    StandardConnectInput input = const StandardConnectInput(),
  ]) async => StandardConnectOutput([_account()]);
  @override
  String get version => '1.0.0';
}

class _Disconnect implements StandardDisconnectFeature {
  const _Disconnect();
  @override
  Future<void> disconnect() async {}
  @override
  String get version => '1.0.0';
}

class _Events implements StandardEventsFeature {
  @override
  void Function() onChange(
    void Function(StandardWalletChange change) listener,
  ) {
    listener(StandardWalletChange(accounts: [_account()]));
    return () {};
  }

  @override
  String get version => '1.0.0';
}

const _icon = 'data:image/png;base64,AA==';
