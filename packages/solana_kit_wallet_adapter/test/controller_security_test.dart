import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:solana_kit_wallet_adapter/solana_kit_wallet_adapter.dart';
import 'package:solana_kit_wallet_standard/solana_kit_wallet_standard.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('wallet authorization lifecycle security', () {
    late WalletRegistryController registry;
    late WalletController controller;

    setUp(() async {
      registry = WalletRegistryController();
      controller = WalletController(registry, chain: SolanaChainId.devnet);
      await controller.initialize();
    });

    tearDown(() => controller.dispose());

    for (final invalidation in ['disconnect', 'unregister', 'dispose']) {
      test(
        'late authorization cannot restore an account after $invalidation',
        () async {
          final wallet = _DelayedWallet()
            ..connection = Completer<StandardConnectOutput>();
          registry.register(wallet);
          final connection = controller.connect(wallet);
          final rejected = expectLater(connection, throwsA(_disconnected));
          switch (invalidation) {
            case 'disconnect':
              await controller.disconnect();
            case 'unregister':
              registry.unregister(wallet);
            case 'dispose':
              controller.dispose();
          }
          wallet.connection!.complete(StandardConnectOutput(wallet.accounts));
          await rejected;
          expect(controller.state.selectedAccount, isNull);
          expect(wallet.listeners, isEmpty);
        },
      );
    }

    for (final fails in [false, true]) {
      test('older ${fails ? 'failed' : 'successful'} connect cannot replace '
          'a newer connection', () async {
        final oldWallet = _DelayedWallet()
          ..connection = Completer<StandardConnectOutput>();
        final newWallet = _DelayedWallet();
        final oldConnection = controller.connect(oldWallet);
        final rejected = expectLater(
          oldConnection,
          throwsA(fails ? isStateError : _disconnected),
        );
        await controller.connect(newWallet);
        if (fails) {
          oldWallet.connection!.completeError(StateError('old rejection'));
        } else {
          oldWallet.connection!.complete(
            StandardConnectOutput(oldWallet.accounts),
          );
        }
        await rejected;
        expect(controller.state.selectedWallet, same(newWallet));
        expect(
          controller.state.selectedAccount,
          same(newWallet.accounts.first),
        );
        expect(controller.state.error, isNull);
        expect(oldWallet.listeners, isEmpty);
      });
    }

    test(
      'old disconnect cannot clear a new connection or its listener',
      () async {
        final oldWallet = _DelayedWallet()..disconnection = Completer<void>();
        final newWallet = _DelayedWallet();
        await controller.connect(oldWallet);
        final disconnection = controller.disconnect();
        await controller.connect(newWallet);
        oldWallet.disconnection!.complete();
        await disconnection;
        expect(controller.state.selectedWallet, same(newWallet));
        expect(controller.state.isConnected, isTrue);
        expect(oldWallet.listeners, isEmpty);
        expect(newWallet.listeners, hasLength(1));
        newWallet.emitAccounts(const []);
        expect(controller.state.isConnected, isFalse);
      },
    );

    test(
      'disconnect immediately prevents signer creation and sign in',
      () async {
        final wallet = _DelayedWallet()..disconnection = Completer<void>();
        await controller.connect(wallet);
        final disconnection = controller.disconnect();
        expect(controller.state.selectedAccount, isNull);
        expect(controller.createSigner, throwsA(_disconnected));
        await expectLater(
          controller.signIn(const SolanaSignInInput()),
          throwsA(_disconnected),
        );
        expect(
          () => controller.selectAccount(wallet.accounts.first),
          throwsA(isA<WalletStandardException>()),
        );
        expect(wallet.signInCalls, 0);
        wallet.emitAccounts(wallet.accounts);
        expect(controller.state.selectedAccount, isNull);
        wallet.disconnection!.complete();
        await disconnection;
      },
    );

    test('unregister removes the active wallet event subscription', () async {
      final wallet = _DelayedWallet();
      registry.register(wallet);
      await controller.connect(wallet);
      registry.unregister(wallet);
      expect(wallet.listeners, isEmpty);
      wallet.emitAccounts(wallet.accounts);
      expect(controller.state.selectedAccount, isNull);
    });

    test(
      'stale sign-in error does not overwrite the new connection state',
      () async {
        final oldWallet = _DelayedWallet()
          ..signInResponse = Completer<List<SolanaSignInOutput>>();
        await controller.connect(oldWallet);
        final result = controller.signIn(const SolanaSignInInput());
        final rejected = expectLater(result, throwsStateError);
        await controller.connect(_DelayedWallet());
        oldWallet.signInResponse!.completeError(StateError('old sign in'));
        await rejected;
        expect(controller.state.error, isNull);
        expect(controller.state.operationStatus, WalletOperationStatus.idle);
      },
    );

    test(
      'disconnect completion after disposal does not notify listeners',
      () async {
        final wallet = _DelayedWallet()..disconnection = Completer<void>();
        await controller.connect(wallet);
        final disconnection = controller.disconnect();
        controller.dispose();
        wallet.disconnection!.complete();
        await disconnection;
      },
    );
  });

  test(
    'initialization completion after disposal does not subscribe or notify',
    () async {
      final registry = _DelayedRegistry();
      final controller = WalletController(
        registry,
        chain: SolanaChainId.devnet,
      );
      final initialization = controller.initialize();
      controller.dispose();
      registry.ready.complete();
      await initialization;
      expect(registry.subscriptionCount, 0);
    },
  );

  test(
    'initialization cannot reset a connection established while discovering',
    () async {
      final registry = _DelayedRegistry();
      final controller = WalletController(
        registry,
        chain: SolanaChainId.devnet,
      );
      final initialization = controller.initialize();
      await controller.connect(_DelayedWallet());
      registry.ready.complete();
      await initialization;
      expect(controller.state.isConnected, isTrue);
      controller.dispose();
    },
  );
}

final Matcher _disconnected = isA<WalletStandardException>().having(
  (error) => error.code,
  'code',
  WalletStandardErrorCode.disconnected,
);

class _DelayedRegistry extends WalletRegistryController {
  final ready = Completer<void>();
  int subscriptionCount = 0;

  @override
  Stream<WalletRegistryEvent> get events {
    subscriptionCount++;
    return super.events;
  }

  @override
  Future<void> initialize() => ready.future;
}

class _DelayedWallet
    implements
        Wallet,
        StandardConnectFeature,
        StandardDisconnectFeature,
        StandardEventsFeature,
        SolanaSignInFeature {
  Completer<StandardConnectOutput>? connection;
  Completer<void>? disconnection;
  Completer<List<SolanaSignInOutput>>? signInResponse;
  int signInCalls = 0;
  final listeners = <void Function(StandardWalletChange)>[];

  @override
  final accounts = [
    WalletAccount(
      address: '11111111111111111111111111111111',
      publicKey: Uint8List(32),
      chains: const [SolanaChainId.devnet],
      features: const [SolanaFeatureId.signIn],
    ),
  ];

  @override
  List<String> get chains => const [SolanaChainId.devnet];

  @override
  Map<String, WalletFeature> get features => {
    StandardFeatureId.connect: this,
    StandardFeatureId.disconnect: this,
    StandardFeatureId.events: this,
    SolanaFeatureId.signIn: this,
  };

  @override
  WalletIcon get icon => WalletIcon('data:image/png;base64,AA==');

  @override
  String get name => 'Delayed wallet';

  @override
  String get version => '1.0.0';

  @override
  Future<StandardConnectOutput> connect([
    StandardConnectInput input = const StandardConnectInput(),
  ]) => connection?.future ?? Future.value(StandardConnectOutput(accounts));

  @override
  Future<void> disconnect() => disconnection?.future ?? Future.value();

  @override
  void Function() onChange(void Function(StandardWalletChange) listener) {
    listeners.add(listener);
    return () => listeners.remove(listener);
  }

  void emitAccounts(List<WalletAccount> accounts) {
    for (final listener in List.of(listeners)) {
      listener(StandardWalletChange(accounts: accounts));
    }
  }

  @override
  Future<List<SolanaSignInOutput>> signIn(List<SolanaSignInInput> inputs) {
    signInCalls++;
    return signInResponse?.future ?? Future.value([]);
  }
}
