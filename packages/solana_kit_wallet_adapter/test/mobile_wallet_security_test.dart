import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_keys/solana_kit_keys.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';
import 'package:solana_kit_transactions/solana_kit_transactions.dart';
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

    tearDown(() {
      backend.keyPair.dispose();
      backend.otherKeyPair.dispose();
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
      final first = _unsignedTransaction(
        backend.accountAddress,
        '11111111111111111111111111111111',
      );
      final second = _unsignedTransaction(
        backend.accountAddress,
        '4vJ9JU1bJJE96FWSJKvHsmmFADCg4gpZQff4P3bkLKi',
      );
      final signed = await transactions.signTransaction([
        SolanaSignTransactionInput(account: account, transaction: first),
        SolanaSignTransactionInput(
          account: account,
          transaction: second,
          chain: SolanaChainId.mainnet,
        ),
      ]);
      expect(
        signed.map((output) => output.signedTransaction),
        hasLength(2),
      );
      // The signed transaction keeps the submitted message bytes and now
      // carries a verifying signature for the authorized account.
      for (var index = 0; index < signed.length; index++) {
        final decoded = getTransactionDecoder().decode(
          signed[index].signedTransaction,
        );
        final input = getTransactionDecoder().decode(
          index == 0 ? first : second,
        );
        expect(decoded.messageBytes, input.messageBytes);
        expect(
          verifySignature(
            backend.keyPair.publicKey,
            decoded.signatures[backend.accountAddress]!,
            decoded.messageBytes,
          ),
          isTrue,
        );
      }

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
      expect(
        signedMessages.every(
          (output) =>
              output.signature.length == 64 &&
              verifySignature(
                backend.keyPair.publicKey,
                SignatureBytes(output.signature),
                output.signedMessage,
              ),
        ),
        isTrue,
      );

      final sent = await send.signAndSendTransaction([
        for (final byte in [5, 6])
          SolanaSignAndSendTransactionInput(
            account: account,
            transaction: _unsignedTransaction(
              backend.accountAddress,
              blockhashFor(byte),
            ),
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
      expect(
        sent.every((output) => output.signature.length == 64),
        isTrue,
      );
      expect(backend.calls.map((call) => call.account), [
        account,
        account,
        account,
      ]);
      expect(backend.calls.map((call) => call.payloads), [
        [first, second],
        [
          [3],
          [4],
        ],
        hasLength(2),
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
            transaction: _unsignedTransaction(
              backend.accountAddress,
              '11111111111111111111111111111111',
            ),
            chain: SolanaChainId.mainnet,
            options: options,
          ),
      ]);
      expect(backend.calls, hasLength(1));
      expect(backend.calls.single.payloads, hasLength(2));
    });

    test(
      'rejects a forged message signature from a compromised wallet',
      () async {
        backend.forgeMessageSignatures = true;
        await expectLater(
          messages.signMessage([
            SolanaSignMessageInput(
              account: backend.accounts.first,
              message: Uint8List.fromList([7]),
            ),
          ]),
          _invalidResponse,
        );
      },
    );

    test(
      'rejects a substituted signed transaction from a compromised wallet',
      () async {
        final submitted = _unsignedTransaction(
          backend.accountAddress,
          '11111111111111111111111111111111',
        );
        final substituted = _unsignedTransaction(
          backend.accountAddress,
          'cGfHiC6Kgg3FpFZvgwGcswsCRtp4aBP2fzuXRQPizuN',
        );
        backend.substitutedTransaction = backend.signTransactionBytes(
          substituted,
        );
        await expectLater(
          transactions.signTransaction([
            SolanaSignTransactionInput(
              account: backend.accounts.first,
              transaction: submitted,
            ),
          ]),
          _invalidResponse,
        );
      },
    );

    test(
      'rejects a signed transaction whose signature does not verify',
      () async {
        final submitted = _unsignedTransaction(
          backend.accountAddress,
          '11111111111111111111111111111111',
        );
        final submittedMessage = getTransactionDecoder()
            .decode(submitted)
            .messageBytes;
        final foreignKeyPair = generateKeyPair();
        addTearDown(foreignKeyPair.dispose);
        backend.substitutedTransaction = getTransactionEncoder().encode(
          Transaction(
            messageBytes: submittedMessage,
            signatures: {
              // Same message, same signer slot, but signed by a foreign key:
              // the signature is structurally valid but does not verify.
              backend.accountAddress: signBytes(
                foreignKeyPair.privateKey,
                submittedMessage,
              ),
            },
          ),
        );
        await expectLater(
          transactions.signTransaction([
            SolanaSignTransactionInput(
              account: backend.accounts.first,
              transaction: submitted,
            ),
          ]),
          _invalidResponse,
        );
      },
    );

    test(
      'rejects a submission signature for a different transaction',
      () async {
        final submitted = _unsignedTransaction(
          backend.accountAddress,
          '11111111111111111111111111111111',
        );
        final other = _unsignedTransaction(
          backend.accountAddress,
          '4vJ9JU1bJJE96FWSJKvHsmmFADCg4gpZQff4P3bkLKi',
        );
        final otherSignature = signBytes(backend.keyPair.privateKey, other);
        backend.reportedSignatures = [otherSignature.value];
        await expectLater(
          send.signAndSendTransaction([
            SolanaSignAndSendTransactionInput(
              account: backend.accounts.first,
              transaction: submitted,
              chain: SolanaChainId.mainnet,
            ),
          ]),
          _invalidResponse,
        );
      },
    );

    test(
      'rejects a sign-in proof attached to an unauthorized account',
      () async {
        final message = Uint8List.fromList([1, 2, 3]);
        final signature = signBytes(backend.keyPair.privateKey, message);
        final stranger = generateKeyPair();
        addTearDown(stranger.dispose);
        final strangerAddress = getAddressFromPublicKey(stranger.publicKey);
        final strangerAccount = WalletAccount(
          address: strangerAddress.value,
          publicKey: stranger.publicKey,
          chains: const [SolanaChainId.mainnet],
          features: const [SolanaFeatureId.signIn],
        );
        final authorization = Completer<MobileWalletAuthorization>();
        backend.authorization = authorization;
        final signingIn = wallet
            .feature<SolanaSignInFeature>(SolanaFeatureId.signIn)!
            .signIn(const [SolanaSignInInput()]);
        authorization.complete(
          MobileWalletAuthorization(
            accounts: backend.accounts,
            signInOutput: SolanaSignInOutput(
              account: strangerAccount,
              signedMessage: message,
              signature: signature.value,
            ),
          ),
        );
        await expectLater(signingIn, _invalidResponse);
      },
    );

    test(
      'rejects a sign-in proof whose signature does not verify',
      () async {
        final message = Uint8List.fromList([1, 2, 3]);
        final signature = signBytes(backend.keyPair.privateKey, message);
        // Corrupt one byte so the proof is well-formed but invalid.
        signature.value[0] ^= 1;
        final authorization = Completer<MobileWalletAuthorization>();
        backend.authorization = authorization;
        final signingIn = wallet
            .feature<SolanaSignInFeature>(SolanaFeatureId.signIn)!
            .signIn(const [SolanaSignInInput()]);
        authorization.complete(
          MobileWalletAuthorization(
            accounts: backend.accounts,
            signInOutput: SolanaSignInOutput(
              account: backend.accounts.first,
              signedMessage: message,
              signature: signature.value,
            ),
          ),
        );
        await expectLater(signingIn, _invalidResponse);
      },
    );

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

/// Compiles an unsigned wire transaction whose only signer is [address].
///
/// [blockhash] makes each transaction's message bytes (and therefore its
/// signature) unique. The result is the full wire envelope — zero-valued
/// signatures followed by the message — exactly what a dApp submits to the
/// wallet for signing.
Uint8List _unsignedTransaction(Address address, String blockhash) {
  final transaction = compileTransaction(
    const TransactionMessage(version: TransactionVersion.v0).copyWith(
      feePayer: address,
      lifetimeConstraint: BlockhashLifetimeConstraint(
        blockhash: blockhash,
        lastValidBlockHeight: BigInt.zero,
      ),
    ),
  );
  return getTransactionEncoder().encode(transaction);
}

/// A distinct valid base58 blockhash for each fixture salt byte.
String blockhashFor(int byte) {
  const blockhashes = [
    '11111111111111111111111111111111',
    '4vJ9JU1bJJE96FWSJKvHsmmFADCg4gpZQff4P3bkLKi',
    'cGfHiC6Kgg3FpFZvgwGcswsCRtp4aBP2fzuXRQPizuN',
    '1thX6LZfHDZZKUs92febYZhYRcXddmzfzF2NvTkPNE',
    '3ARMH9zfVCnU2TKiphU4xcEyWdA45fc1sjKEtYMdf3gr',
  ];
  return blockhashes[byte % blockhashes.length];
}

final Matcher _invalidRequest = throwsA(
  isA<WalletStandardException>().having(
    (error) => error.code,
    'code',
    WalletStandardErrorCode.invalidRequest,
  ),
);

final Matcher _invalidResponse = throwsA(
  isA<WalletStandardException>().having(
    (error) => error.code,
    'code',
    WalletStandardErrorCode.invalidResponse,
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
  _RecordingBackend() {
    _keyPair = generateKeyPair();
    _otherKeyPair = generateKeyPair();
    accountAddress = getAddressFromPublicKey(_keyPair.publicKey);
    final otherAddress = getAddressFromPublicKey(_otherKeyPair.publicKey);
    accounts = [
      WalletAccount(
        address: accountAddress.value,
        publicKey: _keyPair.publicKey,
        chains: const [SolanaChainId.mainnet],
        features: const [
          SolanaFeatureId.signMessage,
          SolanaFeatureId.signTransaction,
          SolanaFeatureId.signAndSendTransaction,
        ],
      ),
      WalletAccount(
        address: otherAddress.value,
        publicKey: _otherKeyPair.publicKey,
        chains: const [SolanaChainId.mainnet],
        features: const [
          SolanaFeatureId.signMessage,
          SolanaFeatureId.signTransaction,
          SolanaFeatureId.signAndSendTransaction,
        ],
      ),
    ];
  }

  late final KeyPair _keyPair;
  late final KeyPair _otherKeyPair;

  Completer<MobileWalletAuthorization>? authorization;
  Completer<void>? disconnectCompletion;
  StateError? disconnectError;

  /// The wallet's real Ed25519 key pair; positive tests sign with it so the
  /// returned signatures verify against the authorized account.
  KeyPair get keyPair => _keyPair;

  /// A second real key pair backing the second authorized account.
  KeyPair get otherKeyPair => _otherKeyPair;

  /// The authorized account's [Address].
  late Address accountAddress;

  late final List<WalletAccount> accounts;

  /// When set, message signing returns all-zero signatures that do not
  /// verify — simulating a compromised wallet returning forgeries.
  bool forgeMessageSignatures = false;

  /// When set, transaction signing returns these bytes instead of signing
  /// the submitted transactions.
  Uint8List? substitutedTransaction;

  /// When set, sign-and-send reports these signatures instead of the
  /// submitted transactions' own signatures.
  List<Uint8List>? reportedSignatures;

  final calls =
      <
        ({
          WalletAccount account,
          List<Uint8List> payloads,
          SolanaSignAndSendTransactionOptions? options,
        })
      >[];

  /// Signs a submitted wire transaction envelope with the wallet key.
  Uint8List signTransactionBytes(Uint8List wireTransaction) {
    final decoded = getTransactionDecoder().decode(wireTransaction);
    return getTransactionEncoder().encode(
      Transaction(
        messageBytes: decoded.messageBytes,
        signatures: {
          accountAddress: signBytes(keyPair.privateKey, decoded.messageBytes),
        },
      ),
    );
  }

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
    final substituted = substitutedTransaction;
    if (substituted != null) {
      return List.filled(transactions.length, substituted);
    }
    return transactions.map(signTransactionBytes).toList();
  }

  @override
  Future<List<Uint8List>> signMessages(
    List<Uint8List> messages,
    WalletAccount account,
  ) async {
    calls.add((account: account, payloads: messages, options: null));
    if (forgeMessageSignatures) {
      return messages.map((_) => Uint8List(64)).toList();
    }
    return [
      for (final message in messages)
        signBytes(keyPair.privateKey, message).value,
    ];
  }

  @override
  Future<List<Uint8List>> signAndSendTransactions(
    List<Uint8List> transactions,
    WalletAccount account,
    SolanaSignAndSendTransactionOptions? options,
  ) async {
    calls.add((account: account, payloads: transactions, options: options));
    final reported = reportedSignatures;
    if (reported != null) return reported;
    return [
      for (final transaction in transactions)
        signBytes(
          keyPair.privateKey,
          getTransactionDecoder().decode(transaction).messageBytes,
        ).value,
    ];
  }
}
