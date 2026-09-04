import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:solana_kit_wallet_adapter/solana_kit_wallet_adapter.dart';
import 'package:solana_kit_wallet_standard/solana_kit_wallet_standard.dart';

void main() {
  group('Mobile wallet signing request boundaries', () {
    late _RecordingBackend backend;
    late MobileWallet wallet;
    late SolanaSignTransactionFeature transactions;
    late SolanaSignAndSendTransactionFeature send;
    late SolanaSignMessageFeature messages;

    setUp(() async {
      backend = _RecordingBackend();
      wallet = MobileWallet(
        backend: backend,
        identity: const WalletAppIdentity(name: 'Security test'),
        chain: SolanaChainId.mainnet,
      );
      await wallet
          .feature<StandardConnectFeature>(StandardFeatureId.connect)!
          .connect();
      transactions = wallet.feature<SolanaSignTransactionFeature>(
        SolanaFeatureId.signTransaction,
      )!;
      send = wallet.feature<SolanaSignAndSendTransactionFeature>(
        SolanaFeatureId.signAndSendTransaction,
      )!;
      messages = wallet.feature<SolanaSignMessageFeature>(
        SolanaFeatureId.signMessage,
      )!;
    });

    test(
      'rejects mixed message signers before requesting signatures',
      () async {
        await expectLater(
          messages.signMessage([
            for (final account in backend.accounts)
              SolanaSignMessageInput(account: account, message: Uint8List(1)),
          ]),
          _invalidRequest,
        );
        expect(backend.calls, isEmpty);
      },
    );

    test('rejects mixed transaction signers before signing', () async {
      await expectLater(
        transactions.signTransaction([
          for (final account in backend.accounts)
            SolanaSignTransactionInput(
              account: account,
              transaction: Uint8List(1),
            ),
        ]),
        _invalidRequest,
      );
      expect(backend.calls, isEmpty);
    });

    test('rejects mixed submission signers before sending', () async {
      await expectLater(
        send.signAndSendTransaction([
          for (final account in backend.accounts)
            SolanaSignAndSendTransactionInput(
              account: account,
              transaction: Uint8List(1),
              chain: SolanaChainId.mainnet,
            ),
        ]),
        _invalidRequest,
      );
      expect(backend.calls, isEmpty);
    });

    test(
      'rejects a later transaction for a different chain before signing',
      () async {
        await expectLater(
          transactions.signTransaction([
            for (final chain in [SolanaChainId.mainnet, SolanaChainId.devnet])
              SolanaSignTransactionInput(
                account: backend.accounts.first,
                transaction: Uint8List(1),
                chain: chain,
              ),
          ]),
          _invalidRequest,
        );
        expect(backend.calls, isEmpty);
      },
    );

    test(
      'does not submit devnet requests through a mainnet authorization',
      () async {
        await expectLater(
          send.signAndSendTransaction([
            for (final chain in [SolanaChainId.mainnet, SolanaChainId.devnet])
              SolanaSignAndSendTransactionInput(
                account: backend.accounts.first,
                transaction: Uint8List(1),
                chain: chain,
              ),
          ]),
          _invalidRequest,
        );
        expect(backend.calls, isEmpty);
      },
    );

    const differentOptions = {
      'preflight commitment': SolanaSignAndSendTransactionOptions(
        preflightCommitment: SolanaTransactionCommitment.finalized,
      ),
      'minimum context slot': SolanaSignAndSendTransactionOptions(
        minContextSlot: 100,
      ),
      'commitment': SolanaSignAndSendTransactionOptions(
        commitment: SolanaTransactionCommitment.finalized,
      ),
      'skip preflight': SolanaSignAndSendTransactionOptions(
        skipPreflight: true,
      ),
      'maximum retries': SolanaSignAndSendTransactionOptions(maxRetries: 3),
    };
    for (final entry in differentOptions.entries) {
      test('rejects mixed ${entry.key} policies before sending', () async {
        await expectLater(
          send.signAndSendTransaction([
            for (final options in [null, entry.value])
              SolanaSignAndSendTransactionInput(
                account: backend.accounts.first,
                transaction: Uint8List(1),
                chain: SolanaChainId.mainnet,
                options: options,
              ),
          ]),
          _invalidRequest,
        );
        expect(backend.calls, isEmpty);
      });
    }

    test('preserves homogeneous batches and equivalent send options', () async {
      final account = backend.accounts.first;
      final signed = await transactions.signTransaction([
        SolanaSignTransactionInput(
          account: account,
          transaction: Uint8List.fromList([1]),
        ),
        SolanaSignTransactionInput(
          account: account,
          transaction: Uint8List.fromList([2]),
          chain: SolanaChainId.mainnet,
        ),
      ]);
      expect(signed.map((output) => output.signedTransaction), [
        [1],
        [2],
      ]);

      final signedMessages = await messages.signMessage([
        for (final byte in [3, 4])
          SolanaSignMessageInput(
            account: account,
            message: Uint8List.fromList([byte]),
          ),
      ]);
      expect(signedMessages.map((output) => output.signedMessage), [
        [3],
        [4],
      ]);

      final sent = await send.signAndSendTransaction([
        for (final byte in [5, 6])
          SolanaSignAndSendTransactionInput(
            account: account,
            transaction: Uint8List.fromList([byte]),
            chain: SolanaChainId.mainnet,
            // Separate instances with equal values are the same policy.
            options: SolanaSignAndSendTransactionOptions(
              preflightCommitment: SolanaTransactionCommitment.confirmed,
              minContextSlot: backend.accounts.length + 10,
              commitment: SolanaTransactionCommitment.finalized,
              skipPreflight: false,
              maxRetries: 3,
            ),
          ),
      ]);
      expect(sent, hasLength(2));
      expect(backend.calls.map((call) => call.account), [
        account,
        account,
        account,
      ]);
      expect(backend.calls.map((call) => call.payloads), [
        [
          [1],
          [2],
        ],
        [
          [3],
          [4],
        ],
        [
          [5],
          [6],
        ],
      ]);
      final options = backend.calls.last.options!;
      expect(
        options.preflightCommitment,
        SolanaTransactionCommitment.confirmed,
      );
      expect(options.minContextSlot, 12);
      expect(options.commitment, SolanaTransactionCommitment.finalized);
      expect(options.skipPreflight, isFalse);
      expect(options.maxRetries, 3);
    });

    test('treats omitted and empty send options as equivalent', () async {
      await send.signAndSendTransaction([
        for (final options in [
          null,
          const SolanaSignAndSendTransactionOptions(),
        ])
          SolanaSignAndSendTransactionInput(
            account: backend.accounts.first,
            transaction: Uint8List(1),
            chain: SolanaChainId.mainnet,
            options: options,
          ),
      ]);
      expect(backend.calls, hasLength(1));
      expect(backend.calls.single.payloads, hasLength(2));
    });

    test(
      'disconnect immediately removes authority while backend cleanup waits',
      () async {
        final completion = Completer<void>();
        backend.disconnectCompletion = completion;
        final disconnected = wallet
            .feature<StandardDisconnectFeature>(StandardFeatureId.disconnect)!
            .disconnect();
        try {
          await expectLater(
            messages.signMessage([
              SolanaSignMessageInput(
                account: backend.accounts.first,
                message: Uint8List(1),
              ),
            ]),
            _invalidRequest,
          );
          expect(backend.calls, isEmpty);
          expect(wallet.accounts, isEmpty);
        } finally {
          completion.complete();
          await disconnected;
        }
      },
    );

    test('failed backend cleanup cannot leave accounts authorized', () async {
      backend.disconnectError = StateError('Backend cleanup failed');
      await expectLater(
        wallet
            .feature<StandardDisconnectFeature>(StandardFeatureId.disconnect)!
            .disconnect(),
        throwsStateError,
      );
      expect(wallet.accounts, isEmpty);
      await expectLater(
        transactions.signTransaction([
          SolanaSignTransactionInput(
            account: backend.accounts.first,
            transaction: Uint8List(1),
          ),
        ]),
        _invalidRequest,
      );
      expect(backend.calls, isEmpty);
    });

    test(
      'a pending connect cannot restore authority after disconnect',
      () async {
        final authorization = Completer<MobileWalletAuthorization>();
        backend.authorization = authorization;
        final connecting = wallet
            .feature<StandardConnectFeature>(StandardFeatureId.connect)!
            .connect();
        final rejected = expectLater(connecting, _disconnected);
        await wallet
            .feature<StandardDisconnectFeature>(StandardFeatureId.disconnect)!
            .disconnect();
        authorization.complete(
          MobileWalletAuthorization(accounts: backend.accounts),
        );
        await rejected;
        expect(wallet.accounts, isEmpty);
      },
    );

    test(
      'a pending sign-in cannot restore authority after disconnect',
      () async {
        final authorization = Completer<MobileWalletAuthorization>();
        backend.authorization = authorization;
        final signingIn = wallet
            .feature<SolanaSignInFeature>(SolanaFeatureId.signIn)!
            .signIn(const [SolanaSignInInput()]);
        final rejected = expectLater(signingIn, _disconnected);
        await wallet
            .feature<StandardDisconnectFeature>(StandardFeatureId.disconnect)!
            .disconnect();
        authorization.complete(
          MobileWalletAuthorization(
            accounts: backend.accounts,
            signInOutput: SolanaSignInOutput(
              account: backend.accounts.first,
              signedMessage: Uint8List(1),
              signature: Uint8List(64),
            ),
          ),
        );
        await rejected;
        expect(wallet.accounts, isEmpty);
      },
    );

    test('the most recent connect owns the authorization state', () async {
      final firstAuthorization = Completer<MobileWalletAuthorization>();
      backend.authorization = firstAuthorization;
      final connect = wallet.feature<StandardConnectFeature>(
        StandardFeatureId.connect,
      )!;
      final first = connect.connect();
      final rejected = expectLater(first, _disconnected);
      final secondAuthorization = Completer<MobileWalletAuthorization>();
      backend.authorization = secondAuthorization;
      final second = connect.connect();
      secondAuthorization.complete(
        MobileWalletAuthorization(accounts: [backend.accounts.last]),
      );
      await second;
      firstAuthorization.complete(
        MobileWalletAuthorization(accounts: [backend.accounts.first]),
      );
      await rejected;
      expect(wallet.accounts, [backend.accounts.last]);
    });
  });
}

final Matcher _invalidRequest = throwsA(
  isA<WalletStandardException>().having(
    (error) => error.code,
    'code',
    WalletStandardErrorCode.invalidRequest,
  ),
);

final Matcher _disconnected = throwsA(
  isA<WalletStandardException>().having(
    (error) => error.code,
    'code',
    WalletStandardErrorCode.disconnected,
  ),
);

class _RecordingBackend implements MobileWalletBackend {
  Completer<MobileWalletAuthorization>? authorization;
  Completer<void>? disconnectCompletion;
  StateError? disconnectError;
  final List<WalletAccount> accounts = [
    for (final value in [1, 2])
      WalletAccount(
        address: 'account-$value',
        publicKey: Uint8List.fromList(List.filled(32, value)),
        chains: const [SolanaChainId.mainnet],
        features: const [
          SolanaFeatureId.signMessage,
          SolanaFeatureId.signTransaction,
          SolanaFeatureId.signAndSendTransaction,
        ],
      ),
  ];
  final calls =
      <
        ({
          WalletAccount account,
          List<Uint8List> payloads,
          SolanaSignAndSendTransactionOptions? options,
        })
      >[];

  @override
  bool get isSupported => true;

  @override
  Future<MobileWalletAuthorization> authorize({
    required WalletAppIdentity identity,
    required String chain,
    bool silent = false,
    SolanaSignInInput? signIn,
  }) async => authorization != null
      ? authorization!.future
      : MobileWalletAuthorization(accounts: accounts);

  @override
  Future<void> disconnect() async {
    final error = disconnectError;
    if (error != null) throw error;
    await disconnectCompletion?.future;
  }

  @override
  Future<List<Uint8List>> signTransactions(
    List<Uint8List> transactions,
    WalletAccount account,
  ) async {
    calls.add((account: account, payloads: transactions, options: null));
    return transactions;
  }

  @override
  Future<List<Uint8List>> signMessages(
    List<Uint8List> messages,
    WalletAccount account,
  ) async {
    calls.add((account: account, payloads: messages, options: null));
    return messages.map((_) => Uint8List(64)).toList();
  }

  @override
  Future<List<Uint8List>> signAndSendTransactions(
    List<Uint8List> transactions,
    WalletAccount account,
    SolanaSignAndSendTransactionOptions? options,
  ) async {
    calls.add((account: account, payloads: transactions, options: options));
    return transactions.map((_) => Uint8List(64)).toList();
  }
}
