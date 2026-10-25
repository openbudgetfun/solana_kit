@TestOn('browser')
library;

import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_keys/solana_kit_keys.dart';
import 'package:solana_kit_offchain_messages/solana_kit_offchain_messages.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';
import 'package:solana_kit_transactions/solana_kit_transactions.dart';
import 'package:solana_kit_wallet_adapter/solana_kit_wallet_adapter.dart';
import 'package:solana_kit_wallet_standard/solana_kit_wallet_standard.dart';
import 'package:web/web.dart' as web;

void main() {
  late _SigningWallet fixture;
  late WalletRegistry registry;
  late Wallet wallet;

  setUp(() async {
    fixture = _SigningWallet();
    registry = createDefaultWalletRegistry(
      appIdentity: const WalletAppIdentity(name: 'Signing test'),
      chain: SolanaChainId.localnet,
    );
    await registry.initialize();
    web.window.dispatchEvent(
      web.CustomEvent(
        'wallet-standard:register-wallet',
        web.CustomEventInit(detail: fixture.register.toJS),
      ),
    );
    wallet = registry.wallets.single;
  });

  tearDown(() async {
    await registry.dispose();
    fixture.keyPair.dispose();
  });

  Future<List<SolanaSignMessageOutput>> signMessage() => wallet
      .feature<SolanaSignMessageFeature>(SolanaFeatureId.signMessage)!
      .signMessage([
        SolanaSignMessageInput(
          account: wallet.accounts.single,
          message: Uint8List.fromList([1, 2, 3]),
        ),
      ]);

  Future<List<SolanaSignTransactionOutput>> signTransaction() => wallet
      .feature<SolanaSignTransactionFeature>(SolanaFeatureId.signTransaction)!
      .signTransaction([
        SolanaSignTransactionInput(
          account: wallet.accounts.single,
          transaction: fixture.transaction(),
        ),
      ]);

  Future<List<SolanaSignAndSendTransactionOutput>> send() => wallet
      .feature<SolanaSignAndSendTransactionFeature>(
        SolanaFeatureId.signAndSendTransaction,
      )!
      .signAndSendTransaction([
        SolanaSignAndSendTransactionInput(
          account: wallet.accounts.single,
          transaction: fixture.transaction(),
          chain: SolanaChainId.localnet,
        ),
      ]);

  Future<List<SolanaSignAndSendAllResult>> sendAll() => wallet
      .feature<SolanaSignAndSendAllTransactionsFeature>(
        SolanaFeatureId.signAndSendAllTransactions,
      )!
      .signAndSendAllTransactions([
        SolanaSignAndSendTransactionInput(
          account: wallet.accounts.single,
          transaction: fixture.transaction(),
          chain: SolanaChainId.localnet,
        ),
      ]);

  Future<List<SolanaSignInOutput>> signIn() =>
      wallet.feature<SolanaSignInFeature>(SolanaFeatureId.signIn)!.signIn(
        const [SolanaSignInInput(domain: 'example.test', nonce: 'fresh')],
      );

  Future<List<SolanaSignOffchainMessageOutput>> offchain() => wallet
      .feature<SolanaSignOffchainMessageFeature>(
        SolanaFeatureId.signOffchainMessage,
      )!
      .signOffchainMessage([
        SolanaSignOffchainMessageInput(
          account: wallet.accounts.single,
          message: 'Expected message',
          requiredSigners: [fixture.keyPair.publicKey],
        ),
      ]);

  for (final count in [0, 2]) {
    for (final feature in [
      'message',
      'transaction',
      'send',
      'batch',
      'signIn',
      'offchain',
    ]) {
      test('$feature rejects $count outputs for one request', () async {
        fixture.outputs = List.generate(count, (_) => JSObject());
        final operation = switch (feature) {
          'message' => signMessage(),
          'transaction' => signTransaction(),
          'send' => send(),
          'batch' => sendAll(),
          'signIn' => signIn(),
          _ => offchain(),
        };
        await expectLater(operation, _invalidResponse);
      });
    }
  }

  test('rejects a forged message signature', () async {
    fixture.outputs = [
      fixture.messageOutput(Uint8List.fromList([1, 2, 3]))
        ..['signature'] = Uint8List(64).toJS,
    ];
    await expectLater(signMessage(), _invalidResponse);
  });

  test('rejects a valid signature over a substituted message', () async {
    fixture.outputs = [
      fixture.messageOutput(Uint8List.fromList([4, 5, 6])),
    ];
    await expectLater(signMessage(), _invalidResponse);
  });

  test('accepts a genuine message signature', () async {
    fixture.outputs = [
      fixture.messageOutput(Uint8List.fromList([1, 2, 3])),
    ];
    expect((await signMessage()).single.signedMessage, [1, 2, 3]);
  });

  test(
    'rejects reordered message results even when both signatures verify',
    () async {
      fixture.outputs = [
        fixture.messageOutput(Uint8List.fromList([2])),
        fixture.messageOutput(Uint8List.fromList([1])),
      ];
      await expectLater(
        wallet
            .feature<SolanaSignMessageFeature>(SolanaFeatureId.signMessage)!
            .signMessage([
              for (final byte in [1, 2])
                SolanaSignMessageInput(
                  account: wallet.accounts.single,
                  message: Uint8List.fromList([byte]),
                ),
            ]),
        _invalidResponse,
      );
    },
  );

  test(
    'the provider cannot mutate the requested message through interop',
    () async {
      fixture.onRequest = (request) {
        final bytes = (request['message']! as JSUint8Array).toDart;
        bytes[0] = 4;
        fixture.outputs = [fixture.messageOutput(bytes)];
      };
      await expectLater(signMessage(), _invalidResponse);
    },
  );

  test(
    'provider getters cannot shorten an already checked result batch',
    () async {
      final bytes = Uint8List.fromList([1]);
      final first = fixture.messageOutput(bytes);
      _defineProperty(
        first,
        'signedMessage'.toJS,
        JSObject()
          ..['get'] = (() {
            fixture.response!.length = 0;
            return bytes.toJS;
          }).toJS,
      );
      fixture.outputs = [
        first,
        fixture.messageOutput(Uint8List.fromList([2])),
      ];
      final results = await wallet
          .feature<SolanaSignMessageFeature>(SolanaFeatureId.signMessage)!
          .signMessage([
            for (final byte in [1, 2])
              SolanaSignMessageInput(
                account: wallet.accounts.single,
                message: Uint8List.fromList([byte]),
              ),
          ]);
      expect(results, hasLength(2));
    },
  );

  test('rejects unsupported signature algorithms', () async {
    fixture.outputs = [
      fixture.messageOutput(Uint8List.fromList([1, 2, 3]))
        ..['signatureType'] = 'unknown'.toJS,
    ];
    await expectLater(signMessage(), _invalidResponse);
  });

  test('rejects a signed transaction with a substituted message', () async {
    fixture.outputs = [
      JSObject()
        ..['signedTransaction'] = fixture
            .transaction(signed: true, changed: true)
            .toJS,
    ];
    await expectLater(signTransaction(), _invalidResponse);
  });

  test('rejects an unchanged transaction with a forged signature', () async {
    fixture.outputs = [
      JSObject()..['signedTransaction'] = fixture.transaction().toJS,
    ];
    await expectLater(signTransaction(), _invalidResponse);
  });

  test('accepts a genuine signed transaction', () async {
    final bytes = fixture.transaction(signed: true);
    fixture.outputs = [JSObject()..['signedTransaction'] = bytes.toJS];
    expect((await signTransaction()).single.signedTransaction, bytes);
  });

  test('rejects a submission signature for another transaction', () async {
    final other = getTransactionDecoder().decode(
      fixture.transaction(changed: true),
    );
    fixture.outputs = [
      JSObject()..['signature'] = fixture.sign(other.messageBytes).toJS,
    ];
    await expectLater(send(), _invalidResponse);
  });

  test('accepts a genuine submission signature', () async {
    final transaction = getTransactionDecoder().decode(fixture.transaction());
    final signature = fixture.sign(transaction.messageBytes);
    fixture.outputs = [JSObject()..['signature'] = signature.toJS];
    expect((await send()).single.signature, signature);
  });

  test('verifies fulfilled batch signatures', () async {
    fixture.outputs = [
      JSObject()
        ..['status'] = 'fulfilled'.toJS
        ..['value'] = (JSObject()..['signature'] = Uint8List(64).toJS),
    ];
    await expectLater(sendAll(), _invalidResponse);
  });

  test('preserves rejected batch items', () async {
    fixture.outputs = [
      JSObject()
        ..['status'] = 'rejected'.toJS
        ..['reason'] = 'Rejected'.toJS,
    ];
    expect((await sendAll()).single, isA<SolanaSignAndSendAllFailure>());
  });

  test('accepts a verified fulfilled batch item', () async {
    final message = getTransactionDecoder()
        .decode(fixture.transaction())
        .messageBytes;
    fixture.outputs = [
      JSObject()
        ..['status'] = 'fulfilled'.toJS
        ..['value'] = (JSObject()..['signature'] = fixture.sign(message).toJS),
    ];
    expect((await sendAll()).single, isA<SolanaSignAndSendAllSuccess>());
  });

  test('rejects unknown batch statuses', () async {
    fixture.outputs = [JSObject()..['status'] = 'unknown'.toJS];
    await expectLater(sendAll(), _invalidResponse);
  });

  test('rejects a correctly signed stale sign-in challenge', () async {
    fixture.outputs = [fixture.signInOutput(nonce: 'stale')];
    await expectLater(signIn(), _invalidResponse);
  });

  test('rejects a forged sign-in signature', () async {
    fixture.outputs = [
      fixture.signInOutput()..['signature'] = Uint8List(64).toJS,
    ];
    await expectLater(signIn(), _invalidResponse);
  });

  test('accepts a sign-in proof for the requested challenge', () async {
    fixture.outputs = [fixture.signInOutput()];
    expect((await signIn()).single.account.address, fixture.address.value);
  });

  test('rejects a sign-in account absent from wallet authorization', () async {
    fixture.outputs = [fixture.signInOutput()];
    fixture.raw['accounts'] = <JSObject>[].toJS;
    await expectLater(signIn(), _invalidResponse);
  });

  const fullSignIn = SolanaSignInInput(
    domain: 'example.test',
    statement: 'Sign in here',
    uri: 'https://example.test/login',
    version: '1',
    chainId: 'solana:localnet',
    nonce: 'fresh',
    issuedAt: '2026-10-25T12:00:00Z',
    expirationTime: '2026-10-25T13:00:00Z',
    notBefore: '2026-10-25T11:00:00Z',
    requestId: 'request123',
    resources: ['https://example.test/resource'],
  );

  String fullProof() =>
      'example.test wants you to sign in with your Solana account:\n${fixture.address.value}\n\nSign in here\n\n'
      'URI: https://example.test/login\nVersion: 1\nChain ID: solana:localnet\nNonce: fresh\n'
      'Issued At: 2026-10-25T12:00:00Z\nExpiration Time: 2026-10-25T13:00:00Z\nNot Before: 2026-10-25T11:00:00Z\nRequest ID: request123\n'
      'Resources:\n- https://example.test/resource';

  for (final field in [
    'example.test wants',
    'Sign in here',
    'https://example.test/login',
    'Version: 1',
    'solana:localnet',
    'Nonce: fresh',
    '2026-10-25T12:00:00Z',
    '2026-10-25T13:00:00Z',
    '2026-10-25T11:00:00Z',
    'request123',
    'https://example.test/resource',
  ]) {
    test('binds the requested SIWS field $field', () async {
      final bytes = Uint8List.fromList(
        utf8.encode(fullProof().replaceFirst(field, '${field}changed')),
      );
      fixture.outputs = [
        fixture.messageOutput(bytes)..['account'] = fixture.account,
      ];
      await expectLater(
        wallet.feature<SolanaSignInFeature>(SolanaFeatureId.signIn)!.signIn(
          const [fullSignIn],
        ),
        _invalidResponse,
      );
    });
  }

  test('accepts a SIWS proof with every requested field', () async {
    fixture.outputs = [
      fixture.messageOutput(Uint8List.fromList(utf8.encode(fullProof())))
        ..['account'] = fixture.account,
    ];
    expect(
      await wallet.feature<SolanaSignInFeature>(SolanaFeatureId.signIn)!.signIn(
        const [fullSignIn],
      ),
      hasLength(1),
    );
  });

  test('rejects duplicate SIWS nonce fields', () async {
    final proof = fullProof().replaceFirst(
      'Nonce: fresh',
      'Nonce: fresh\nNonce: stale',
    );
    fixture.outputs = [
      fixture.messageOutput(Uint8List.fromList(utf8.encode(proof)))
        ..['account'] = fixture.account,
    ];
    await expectLater(signIn(), _invalidResponse);
  });

  test(
    'accepts a canonical offchain message with a genuine signature',
    () async {
      fixture.outputs = [fixture.offchainOutput()];
      expect(await offchain(), hasLength(1));
    },
  );

  test('rejects a valid signature over substituted offchain content', () async {
    fixture.outputs = [fixture.offchainOutput(content: 'Different message')];
    await expectLater(offchain(), _invalidResponse);
  });

  test('rejects a valid signature over substituted offchain signers', () async {
    fixture.outputs = [
      fixture.offchainOutput(
        signer: address('11111111111111111111111111111111'),
      ),
    ];
    await expectLater(offchain(), _invalidResponse);
  });

  test('rejects forged offchain signatures', () async {
    fixture.outputs = [
      fixture.offchainOutput()..['signature'] = Uint8List(64).toJS,
    ];
    await expectLater(offchain(), _invalidResponse);
  });
}

final Matcher _invalidResponse = throwsA(
  isA<WalletStandardException>().having(
    (error) => error.code,
    'code',
    WalletStandardErrorCode.invalidResponse,
  ),
);

/// A real Ed25519 signer behind the browser's untrusted JavaScript boundary.
class _SigningWallet {
  _SigningWallet() {
    account
      ..['address'] = address.value.toJS
      ..['publicKey'] = keyPair.publicKey.toJS
      ..['chains'] = [SolanaChainId.localnet.toJS].toJS
      ..['features'] = _methods.keys.map((key) => key.toJS).toList().toJS;
    final features = JSObject();
    for (final entry in _methods.entries) {
      features[entry.key] = JSObject()
        ..['version'] = '1.0.0'.toJS
        ..['supportedTransactionVersions'] = ['legacy'.toJS, 0.toJS].toJS
        ..['supportedMessageVersions'] = [1.toJS].toJS
        ..[entry.value] = ((JSObject input) {
          onRequest?.call(input);
          response = outputs.toJS;
          return Future<JSArray<JSObject>>.value(response).toJS;
        }).toJS;
    }
    raw
      ..['version'] = walletStandardVersion.toJS
      ..['name'] = 'Signing test wallet'.toJS
      ..['chains'] = [SolanaChainId.localnet.toJS].toJS
      ..['features'] = features
      ..['accounts'] = [account].toJS;
  }

  final KeyPair keyPair = createKeyPairFromPrivateKeyBytes(
    Uint8List.fromList(List.filled(32, 7)),
  );
  late final Address address = getAddressFromPublicKey(keyPair.publicKey);
  final JSObject account = JSObject();
  final JSObject raw = JSObject();
  List<JSObject> outputs = [];
  JSArray<JSObject>? response;
  void Function(JSObject)? onRequest;

  static const Map<String, String> _methods = {
    SolanaFeatureId.signMessage: 'signMessage',
    SolanaFeatureId.signTransaction: 'signTransaction',
    SolanaFeatureId.signAndSendTransaction: 'signAndSendTransaction',
    SolanaFeatureId.signAndSendAllTransactions: 'signAndSendAllTransactions',
    SolanaFeatureId.signIn: 'signIn',
    SolanaFeatureId.signOffchainMessage: 'signOffchainMessage',
  };

  void register(JSObject api) =>
      api.callMethod<JSFunction>('register'.toJS, raw);

  Uint8List sign(Uint8List bytes) => signBytes(keyPair.privateKey, bytes).value;

  JSObject messageOutput(Uint8List bytes) => JSObject()
    ..['signedMessage'] = bytes.toJS
    ..['signature'] = sign(bytes).toJS
    ..['signatureType'] = 'ed25519'.toJS;

  JSObject offchainOutput({
    String content = 'Expected message',
    Address? signer,
  }) {
    final bytes = getOffchainMessageV1Encoder().encode(
      OffchainMessageV1(
        content: content,
        requiredSignatories: [
          OffchainMessageSignatory(address: signer ?? address),
        ],
      ),
    );
    return JSObject()
      ..['signedOffchainMessage'] = bytes.toJS
      ..['signature'] = sign(bytes).toJS;
  }

  JSObject signInOutput({String nonce = 'fresh'}) => messageOutput(
    Uint8List.fromList(
      utf8.encode(
        'example.test wants you to sign in with your Solana account:\n${address.value}\n\nNonce: $nonce',
      ),
    ),
  )..['account'] = account;

  Uint8List transaction({bool signed = false, bool changed = false}) {
    final transaction = compileTransaction(
      const TransactionMessage(version: TransactionVersion.v0).copyWith(
        feePayer: address,
        lifetimeConstraint: BlockhashLifetimeConstraint(
          blockhash: changed
              ? '4vJ9JU1bJJE96FWSJKvHsmmFADCg4gpZQff4P3bkLKi'
              : '11111111111111111111111111111111',
          lastValidBlockHeight: BigInt.zero,
        ),
      ),
    );
    return getTransactionEncoder().encode(
      signed
          ? Transaction(
              messageBytes: transaction.messageBytes,
              signatures: {
                address: SignatureBytes(sign(transaction.messageBytes)),
              },
            )
          : transaction,
    );
  }
}

@JS('Object.defineProperty')
external JSObject _defineProperty(
  JSObject target,
  JSString property,
  JSObject descriptor,
);
