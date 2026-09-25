import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:solana_kit_keys/solana_kit_keys.dart';
import 'package:solana_kit_mobile_wallet_adapter/solana_kit_mobile_wallet_adapter.dart'
    as mwa;
import 'package:solana_kit_mobile_wallet_adapter_protocol/solana_kit_mobile_wallet_adapter_protocol.dart'
    as protocol;
import 'package:solana_kit_wallet_adapter/src/mobile_wallet.dart';
import 'package:solana_kit_wallet_adapter/src/platform/default_registry_native.dart';
import 'package:solana_kit_wallet_standard/solana_kit_wallet_standard.dart';

void main() {
  group('Native mobile message signing', () {
    late _NativeWallet wallet;
    late NativeMobileWalletBackend backend;
    late WalletAccount account;
    final message = Uint8List.fromList([1, 2, 3]);

    setUp(() async {
      wallet = _NativeWallet();
      backend = NativeMobileWalletBackend(transact: wallet.transact);
      account = (await backend.authorize(
        identity: const WalletAppIdentity(name: 'Native signing test'),
        chain: SolanaChainId.mainnet,
      )).accounts.single;
    });

    tearDown(() => wallet.keyPair.dispose());

    test(
      'extracts a real Ed25519 signature over the requested message',
      () async {
        final signature = (await backend.signMessages([
          message,
        ], account)).single;
        expect(signature, hasLength(64));
        expect(
          verifySignature(
            wallet.keyPair.publicKey,
            SignatureBytes(signature),
            message,
          ),
          isTrue,
        );
        expect(wallet.lastPayloads, [base64.encode(message)]);
      },
    );

    test('requests one signer for every message in the batch', () async {
      final messages = [
        message,
        Uint8List.fromList([4, 5]),
        Uint8List(0),
      ];
      final signatures = await backend.signMessages(messages, account);
      expect(wallet.lastAddresses, [base64.encode(wallet.keyPair.publicKey)]);
      expect(signatures, hasLength(messages.length));
      for (var index = 0; index < messages.length; index++) {
        expect(signatures[index], hasLength(64));
        expect(
          verifySignature(
            wallet.keyPair.publicKey,
            SignatureBytes(signatures[index]),
            messages[index],
          ),
          isTrue,
        );
      }
    });

    test('rejects a valid signature for a substituted message', () async {
      final substituted = Uint8List.fromList([1, 9, 3]);
      wallet.outputs = [
        base64.encode([
          ...substituted,
          ...signBytes(wallet.keyPair.privateKey, substituted).value,
        ]),
      ];
      await expectLater(
        backend.signMessages([message], account),
        _invalidResponse,
      );
    });

    for (final signatureLength in [0, 63, 65, 128]) {
      test(
        'rejects an envelope with $signatureLength signature bytes',
        () async {
          wallet.outputs = [
            base64.encode([...message, ...Uint8List(signatureLength)]),
          ];
          await expectLater(
            backend.signMessages([message], account),
            _invalidResponse,
          );
        },
      );
    }

    for (final count in [0, 2]) {
      test('rejects $count outputs for one input', () async {
        wallet.outputs = List.filled(
          count,
          base64.encode([...message, ...Uint8List(64)]),
        );
        await expectLater(
          backend.signMessages([message], account),
          _invalidResponse,
        );
      });
    }

    test('rejects malformed base64 as an invalid wallet response', () async {
      wallet.outputs = ['not base64!'];
      await expectLater(
        backend.signMessages([message], account),
        _invalidResponse,
      );
    });

    test(
      'deauthorizes the latest token through the supplied session transport',
      () async {
        await backend.signMessages([message], account);
        await backend.disconnect();
        expect(wallet.deauthorizedToken, 'refreshed-token');
        await expectLater(
          backend.signMessages([message], account),
          throwsA(
            isA<WalletStandardException>().having(
              (error) => error.code,
              'code',
              WalletStandardErrorCode.disconnected,
            ),
          ),
        );
      },
    );
  });
}

final Matcher _invalidResponse = throwsA(
  isA<WalletStandardException>().having(
    (error) => error.code,
    'code',
    WalletStandardErrorCode.invalidResponse,
  ),
);

class _NativeWallet implements mwa.KitMobileWallet {
  final KeyPair keyPair = generateKeyPair();
  List<String>? outputs;
  List<String>? lastAddresses;
  List<String>? lastPayloads;
  String? deauthorizedToken;

  Future<T> transact<T>(
    Future<T> Function(mwa.KitMobileWallet wallet) callback, {
    protocol.WalletAssociationConfig? config,
  }) => callback(this);

  protocol.AuthorizationResult _authorization(String token) =>
      protocol.AuthorizationResult(
        accounts: [
          protocol.MwaAccount(address: base64.encode(keyPair.publicKey)),
        ],
        authToken: token,
      );

  @override
  Future<protocol.AuthorizationResult> authorize({
    protocol.AppIdentity? identity,
    String? chain,
    List<String>? features,
    List<String>? addresses,
    protocol.SignInPayload? signInPayload,
  }) async => _authorization('initial-token');

  @override
  Future<protocol.AuthorizationResult> reauthorize({
    required String authToken,
    protocol.AppIdentity? identity,
  }) async => _authorization('refreshed-token');

  @override
  Future<List<String>> signMessages({
    required List<String> addresses,
    required List<String> payloads,
  }) async {
    lastAddresses = addresses;
    lastPayloads = payloads;
    return outputs ??
        [
          for (final payload in payloads)
            base64.encode([
              ...base64.decode(payload),
              for (final _ in addresses)
                ...signBytes(keyPair.privateKey, base64.decode(payload)).value,
            ]),
        ];
  }

  @override
  Future<void> deauthorize({required String authToken}) async {
    deauthorizedToken = authToken;
  }

  @override
  Future<protocol.AuthorizationResult> cloneAuthorization() async =>
      throw UnimplementedError();

  @override
  Future<protocol.WalletCapabilities> getCapabilities() async =>
      throw UnimplementedError();

  @override
  Future<List<String>> signAndSendTransactions({
    required List<String> payloads,
    protocol.SignAndSendOptions? options,
  }) async => throw UnimplementedError();

  @override
  Future<List<String>> signTransactions({
    required List<String> payloads,
  }) async => throw UnimplementedError();
}
