import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_keys/solana_kit_keys.dart';
import 'package:solana_kit_mobile_wallet_adapter/src/kit_mobile_wallet.dart';
import 'package:solana_kit_mobile_wallet_adapter_protocol/solana_kit_mobile_wallet_adapter_protocol.dart';
import 'package:solana_kit_transactions/solana_kit_transactions.dart';

import 'kit_mobile_wallet_test.dart' show MockMobileWallet;

void main() {
  late KeyPair key;
  late KeyPair other;
  late MockMobileWallet raw;
  late KitMobileWallet wallet;
  final message = Uint8List.fromList([1, 2, 3]);

  setUp(() async {
    key = generateKeyPair();
    other = generateKeyPair();
    raw = MockMobileWallet()..nextResult = _authorization([key]);
    wallet = wrapWithKitApi(raw);
    await wallet.authorize();
  });

  tearDown(() {
    key.dispose();
    other.dispose();
  });

  test(
    'rejects a forged message signature from an authorized wallet',
    () async {
      raw.nextResult = {
        'signed_payloads': [
          base64.encode([...message, ...Uint8List(64)]),
        ],
      };
      await expectLater(
        wallet.signMessages(addresses: [_address(key)], payloads: ['AQID']),
        throwsFormatException,
      );
    },
  );

  test('verifies every message signature in address order', () async {
    raw.nextResult = _authorization([key, other]);
    await wallet.reauthorize(authToken: 'token');
    final signed = _signedMessage(message, [key, other]);
    raw.nextResult = {
      'signed_payloads': [signed],
    };
    expect(
      await wallet.signMessages(
        addresses: [_address(key), _address(other)],
        payloads: ['AQID'],
      ),
      [signed],
    );
    expect(raw.lastParams!['addresses'], [_address(key), _address(other)]);
    expect(raw.lastParams!['payloads'], ['AQID']);

    for (final invalid in [
      _signedMessage(message, [other, key]),
      _signedMessage(message, [key]),
      _signedMessage(Uint8List.fromList([9, 8, 7]), [key, other]),
    ]) {
      raw.nextResult = {
        'signed_payloads': [invalid],
      };
      await expectLater(
        wallet.signMessages(
          addresses: [_address(key), _address(other)],
          payloads: ['AQID'],
        ),
        throwsFormatException,
      );
    }
  });

  test(
    'rejects unauthorized message addresses before invoking the wallet',
    () async {
      await expectLater(
        wallet.signMessages(addresses: [_address(other)], payloads: ['AQID']),
        throwsArgumentError,
      );
      expect(raw.lastMethod, 'authorize');
    },
  );

  for (final legacy in [false, true]) {
    test('accepts a valid ${legacy ? 'legacy' : 'v0'} transaction', () async {
      final original = _transaction([key], legacy: legacy);
      final signed = _encode(_sign(original, [key]));
      raw.nextResult = {
        'signed_payloads': [signed],
      };
      expect(await wallet.signTransactions(payloads: [_encode(original)]), [
        signed,
      ]);
      expect(raw.lastParams!['payloads'], [_encode(original)]);
    });
  }

  test(
    'rejects changed transactions and missing or forged signatures',
    () async {
      final original = _transaction([key]);
      final forged = Transaction(
        messageBytes: original.messageBytes,
        signatures: {
          getAddressFromPublicKey(key.publicKey): SignatureBytes(
            Uint8List(64)..[0] = 1,
          ),
        },
      );

      for (final invalid in [
        _sign(_transaction([key], salt: 2), [key]),
        original,
        forged,
      ]) {
        raw.nextResult = {
          'signed_payloads': [_encode(invalid)],
        };
        await expectLater(
          wallet.signTransactions(payloads: [_encode(original)]),
          throwsFormatException,
        );
      }
    },
  );

  test(
    'requires all authorized signers and preserves existing cosignatures',
    () async {
      final original = _transaction([other, key]);
      final partiallySigned = _sign(original, [other]);
      final fullySigned = _encode(_sign(partiallySigned, [key]));
      raw.nextResult = {
        'signed_payloads': [fullySigned],
      };
      expect(
        await wallet.signTransactions(payloads: [_encode(partiallySigned)]),
        [fullySigned],
      );
      raw.nextResult = {
        'signed_payloads': [
          _encode(_sign(original, [key])),
        ],
      };
      await expectLater(
        wallet.signTransactions(payloads: [_encode(partiallySigned)]),
        throwsFormatException,
      );
      raw.nextResult = _authorization([key, other]);
      await wallet.reauthorize(authToken: 'token');
      raw.nextResult = {
        'signed_payloads': [
          _encode(_sign(original, [key])),
        ],
      };
      await expectLater(
        wallet.signTransactions(payloads: [_encode(original)]),
        throwsFormatException,
      );
      raw.nextResult = {
        'signed_payloads': [fullySigned],
      };
      expect(await wallet.signTransactions(payloads: [_encode(original)]), [
        fullySigned,
      ]);
    },
  );

  test('rejects transactions without an authorized signer', () async {
    await expectLater(
      wallet.signTransactions(
        payloads: [
          _encode(_transaction([other])),
        ],
      ),
      throwsArgumentError,
    );
    expect(raw.lastMethod, 'authorize');
  });

  test(
    'verifies the fee payer transaction ID and forwards send options',
    () async {
      final original = _transaction([other, key]);
      final signature = base64.encode(
        signBytes(other.privateKey, original.messageBytes).value,
      );
      raw.nextResult = {
        'signatures': [signature],
      };
      expect(
        await wallet.signAndSendTransactions(
          payloads: [_encode(original)],
          options: const SignAndSendOptions(
            commitment: 'confirmed',
            skipPreflight: true,
          ),
        ),
        [signature],
      );
      expect(raw.lastParams!['options'], {
        'commitment': 'confirmed',
        'skip_preflight': true,
      });

      for (final invalid in [
        Uint8List(64),
        Uint8List(63),
        signBytes(
          other.privateKey,
          _transaction([other, key], salt: 2).messageBytes,
        ).value,
        signBytes(key.privateKey, original.messageBytes).value,
      ]) {
        raw.nextResult = {
          'signatures': [base64.encode(invalid)],
        };
        await expectLater(
          wallet.signAndSendTransactions(payloads: [_encode(original)]),
          throwsFormatException,
        );
      }
    },
  );

  for (final operation in ['transactions', 'messages', 'send']) {
    test(
      '$operation binds every batch result to its corresponding input',
      () async {
        final transactions = [
          _transaction([key]),
          _transaction([key], salt: 2),
        ];
        final messages = [
          message,
          Uint8List.fromList([4, 5, 6]),
        ];
        final outputs = operation == 'messages'
            ? [
                for (final bytes in messages) _signedMessage(bytes, [key]),
              ]
            : [
                for (final transaction in transactions)
                  operation == 'send'
                      ? base64.encode(
                          signBytes(
                            key.privateKey,
                            transaction.messageBytes,
                          ).value,
                        )
                      : _encode(_sign(transaction, [key])),
              ];
        final field = operation == 'send' ? 'signatures' : 'signed_payloads';
        Future<List<String>> sign() => switch (operation) {
          'messages' => wallet.signMessages(
            addresses: [_address(key)],
            payloads: messages.map(base64.encode).toList(),
          ),
          'send' => wallet.signAndSendTransactions(
            payloads: transactions.map(_encode).toList(),
          ),
          _ => wallet.signTransactions(
            payloads: transactions.map(_encode).toList(),
          ),
        };
        raw.nextResult = {field: outputs};
        expect(await sign(), outputs);
        raw.nextResult = {field: outputs.reversed.toList()};
        await expectLater(sign(), throwsFormatException);
      },
    );

    for (final outputs in <Object?>[
      [],
      ['AA==', 'AA=='],
      [null],
      [17],
      ['!base64!'],
      null,
    ]) {
      test('$operation rejects malformed outputs $outputs', () async {
        raw.nextResult = {
          operation == 'send' ? 'signatures' : 'signed_payloads': outputs,
        };
        final result = switch (operation) {
          'messages' => wallet.signMessages(
            addresses: [_address(key)],
            payloads: ['AQID'],
          ),
          'send' => wallet.signAndSendTransactions(
            payloads: [
              _encode(_transaction([key])),
            ],
          ),
          _ => wallet.signTransactions(
            payloads: [
              _encode(_transaction([key])),
            ],
          ),
        };
        await expectLater(result, throwsFormatException);
      });
    }
  }

  test(
    'accepts a verified SIWS proof with wallet-filled optional fields',
    () async {
      raw.nextResult = _signInAuthorization(key);
      final result = await wallet.authorize(
        signInPayload: const SignInPayload(
          domain: 'example.com',
          nonce: 'fresh123',
        ),
      );
      expect(result.signInResult, isNotNull);
    },
  );

  for (final mismatch in [
    'domain',
    'address',
    'statement',
    'uri',
    'version',
    'chain_id',
    'nonce',
    'issued_at',
    'expiration_time',
    'not_before',
    'request_id',
    'resources',
  ]) {
    test(
      'rejects a valid SIWS proof for a different requested $mismatch',
      () async {
        final params = _signInPayload(key).toJson();
        params[mismatch] = mismatch == 'resources' ? ['other'] : 'other';
        raw.nextResult = _signInAuthorization(key);
        await expectLater(
          wallet.authorize(signInPayload: _payloadFromJson(params)),
          throwsFormatException,
        );
      },
    );
  }

  for (final invalid in [
    'signature',
    'account',
    'algorithm',
    'missing',
    'unsolicited',
    'message account',
    'duplicate field',
    'unknown field',
  ]) {
    test('rejects SIWS $invalid', () async {
      final text = createSiwsMessage(_signInPayload(key));
      raw.nextResult = switch (invalid) {
        'account' => _signInAuthorization(
          other,
        )..['accounts'] = _authorization([key])['accounts'],
        'missing' => _authorization([key]),
        'message account' => _signInAuthorization(
          key,
          text: text.replaceFirst(
            getAddressFromPublicKey(key.publicKey).value,
            getAddressFromPublicKey(other.publicKey).value,
          ),
        ),
        'duplicate field' => _signInAuthorization(
          key,
          text: text.replaceFirst(
            'Nonce: fresh123',
            'Nonce: fresh123\nNonce: other',
          ),
        ),
        'unknown field' => _signInAuthorization(
          key,
          text: text.replaceFirst(
            'Nonce: fresh123',
            'Nonce: fresh123\nUnknown: value',
          ),
        ),
        _ => _signInAuthorization(key),
      };

      if (invalid == 'signature' || invalid == 'algorithm') {
        final proof = raw.nextResult['sign_in_result']! as Map<String, Object?>;
        proof[invalid == 'signature' ? 'signature' : 'signature_type'] =
            invalid == 'signature' ? base64.encode(Uint8List(64)) : 'unknown';
      }

      await expectLater(
        wallet.authorize(
          signInPayload: invalid == 'unsolicited' ? null : _signInPayload(key),
        ),
        throwsFormatException,
      );
    });
  }

  test('requires authorization and clears accounts on deauthorization or failed renewal', () async {
    await expectLater(
      wrapWithKitApi(raw)
          .signMessages(addresses: [_address(key)], payloads: ['AQID']),
      throwsStateError,
    );
    raw.nextResult = {};
    await wallet.deauthorize(authToken: 'token');
    await expectLater(
      wallet.signMessages(addresses: [_address(key)], payloads: ['AQID']),
      throwsStateError,
    );
    raw.nextResult = _authorization([key]);
    await wallet.authorize();
    raw.nextResult = {
      'accounts': [
        {'address': 'AQID'},
      ],
      'auth_token': 'token',
    };
    await expectLater(
      wallet.reauthorize(authToken: 'token'),
      throwsFormatException,
    );
    await expectLater(
      wallet.signMessages(addresses: [_address(key)], payloads: ['AQID']),
      throwsStateError,
    );
  });

  for (final revoke in [false, true]) {
    test(
      revoke
          ? 'rejects in-flight results after deauthorization'
          : 'binds results to original caller lists',
      () async {
        final deferred = _DeferredWallet()..nextResult = _authorization([key]);
        final wrapper = wrapWithKitApi(deferred);
        await wrapper.authorize();
        final payloads = ['AQID'];
        final pending = wrapper.signMessages(
          addresses: [_address(key)],
          payloads: payloads,
        );
        final changed = Uint8List.fromList([9, 8, 7]);
        payloads[0] = base64.encode(changed);

        if (revoke) await wrapper.deauthorize(authToken: 'token');

        deferred.response.complete({
          'signed_payloads': [
            _signedMessage(revoke ? message : changed, [key]),
          ],
        });
        await expectLater(
          pending,
          revoke ? throwsStateError : throwsFormatException,
        );
      },
    );
  }
}

String _address(KeyPair key) => base64.encode(key.publicKey);

Map<String, Object?> _authorization(List<KeyPair> keys) => {
  'accounts': [
    for (final key in keys) {'address': _address(key)},
  ],
  'auth_token': 'token',
};

String _signedMessage(Uint8List message, List<KeyPair> keys) => base64.encode([
  ...message,
  for (final key in keys) ...signBytes(key.privateKey, message).value,
]);

/// Minimal legacy/v0 wire message with signers and no instructions.
Transaction _transaction(
  List<KeyPair> keys, {
  int salt = 1,
  bool legacy = false,
}) => Transaction(
  messageBytes: Uint8List.fromList([
    if (!legacy) 0x80,
    keys.length,
    0,
    0,
    keys.length,
    for (final key in keys) ...key.publicKey,
    ...List<int>.filled(32, salt),
    0,
    if (!legacy) 0,
  ]),
  signatures: {
    for (final key in keys) getAddressFromPublicKey(key.publicKey): null,
  },
);

Transaction _sign(Transaction transaction, List<KeyPair> keys) => Transaction(
  messageBytes: transaction.messageBytes,
  signatures: {
    ...transaction.signatures,
    for (final key in keys)
      getAddressFromPublicKey(key.publicKey): signBytes(
        key.privateKey,
        transaction.messageBytes,
      ),
  },
);

String _encode(Transaction transaction) =>
    base64.encode(getTransactionEncoder().encode(transaction));

SignInPayload _signInPayload(KeyPair key) => SignInPayload(
  domain: 'example.com',
  address: getAddressFromPublicKey(key.publicKey).value,
  statement: 'Sign in',
  uri: 'https://example.com',
  version: '1',
  chainId: 'mainnet',
  nonce: 'fresh123',
  issuedAt: '2026-10-25T12:00:00Z',
  expirationTime: '2026-10-25T13:00:00Z',
  notBefore: '2026-10-25T11:00:00Z',
  requestId: 'request123',
  resources: ['https://example.com/resource'],
);

Map<String, Object?> _signInAuthorization(KeyPair key, {String? text}) {
  final message = Uint8List.fromList(
    utf8.encode(text ?? createSiwsMessage(_signInPayload(key))),
  );
  return _authorization([key])
    ..['sign_in_result'] = {
      'address': _address(key),
      'signed_message': base64.encode(message),
      'signature': base64.encode(signBytes(key.privateKey, message).value),
      'signature_type': 'ed25519',
    };
}

SignInPayload _payloadFromJson(Map<String, Object?> params) => SignInPayload(
  domain: params['domain']! as String,
  address: params['address']! as String,
  statement: params['statement']! as String,
  uri: params['uri']! as String,
  version: params['version']! as String,
  chainId: params['chain_id']! as String,
  nonce: params['nonce']! as String,
  issuedAt: params['issued_at']! as String,
  expirationTime: params['expiration_time']! as String,
  notBefore: params['not_before']! as String,
  requestId: params['request_id']! as String,
  resources: params['resources']! as List<String>,
);

class _DeferredWallet extends MockMobileWallet {
  final response = Completer<Map<String, Object?>>();

  @override
  Future<Map<String, Object?>> signMessages(Map<String, Object?> params) =>
      response.future;
}
