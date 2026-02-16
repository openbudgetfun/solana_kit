import 'dart:typed_data';

import 'package:solana_kit_accounts/solana_kit_accounts.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:test/test.dart';

void main() {
  group('parseBase64RpcAccount', () {
    test('parses an encoded account with base64 data', () {
      const addr = Address('GQE2yjns7SKKuMc89tveBDpzYHwXfeuB2PGAbGaPWc6G');
      final rpcAccount = <String, dynamic>{
        'data': ['somedata', 'base64'],
        'executable': false,
        'lamports': 1000000000,
        'owner': '11111111111111111111111111111111',
        'space': 6,
      };

      final account = parseBase64RpcAccount(addr, rpcAccount);

      expect(account.exists, isTrue);
      expect(account, isA<ExistingAccount<Uint8List>>());

      final existing = account as ExistingAccount<Uint8List>;
      expect(
        existing.data,
        equals(Uint8List.fromList([178, 137, 158, 117, 171, 90])),
      );
      expect(existing.executable, isFalse);
      expect(existing.lamports, Lamports(BigInt.from(1000000000)));
      expect(
        existing.programAddress,
        const Address('11111111111111111111111111111111'),
      );
      expect(existing.space, BigInt.from(6));
    });

    test('parses an empty account (null)', () {
      const addr = Address('GQE2yjns7SKKuMc89tveBDpzYHwXfeuB2PGAbGaPWc6G');

      final account = parseBase64RpcAccount(addr, null);

      expect(account.exists, isFalse);
      expect(account, isA<NonExistingAccount<Uint8List>>());
      expect(account.address, addr);
    });
  });

  group('parseBase58RpcAccount', () {
    test('parses an encoded account with base58 tuple data', () {
      const addr = Address('GQE2yjns7SKKuMc89tveBDpzYHwXfeuB2PGAbGaPWc6G');
      final rpcAccount = <String, dynamic>{
        'data': ['somedata', 'base58'],
        'executable': false,
        'lamports': 1000000000,
        'owner': '11111111111111111111111111111111',
        'space': 6,
      };

      final account = parseBase58RpcAccount(addr, rpcAccount);

      expect(account.exists, isTrue);
      expect(account, isA<ExistingAccount<Uint8List>>());

      final existing = account as ExistingAccount<Uint8List>;
      expect(
        existing.data,
        equals(Uint8List.fromList([102, 6, 221, 155, 82, 67])),
      );
    });

    test('parses an encoded account with implicit base58 string data', () {
      const addr = Address('GQE2yjns7SKKuMc89tveBDpzYHwXfeuB2PGAbGaPWc6G');
      final rpcAccount = <String, dynamic>{
        'data': 'somedata',
        'executable': false,
        'lamports': 1000000000,
        'owner': '11111111111111111111111111111111',
        'space': 6,
      };

      final account = parseBase58RpcAccount(addr, rpcAccount);

      expect(account.exists, isTrue);
      final existing = account as ExistingAccount<Uint8List>;
      expect(
        existing.data,
        equals(Uint8List.fromList([102, 6, 221, 155, 82, 67])),
      );
    });

    test('parses an empty account (null)', () {
      const addr = Address('GQE2yjns7SKKuMc89tveBDpzYHwXfeuB2PGAbGaPWc6G');

      final account = parseBase58RpcAccount(addr, null);

      expect(account.exists, isFalse);
      expect(account, isA<NonExistingAccount<Uint8List>>());
      expect(account.address, addr);
    });
  });

  group('parseJsonRpcAccount', () {
    test('parses a jsonParsed account with custom data', () {
      const addr = Address('GQE2yjns7SKKuMc89tveBDpzYHwXfeuB2PGAbGaPWc6G');
      final rpcAccount = <String, dynamic>{
        'data': <String, dynamic>{
          'parsed': <String, dynamic>{
            'info': <String, dynamic>{'mint': '2222', 'owner': '3333'},
            'type': 'token',
          },
          'program': 'splToken',
          'space': 165,
        },
        'executable': false,
        'lamports': 1000000000,
        'owner': '11111111111111111111111111111111',
        'space': 165,
      };

      final account = parseJsonRpcAccount(addr, rpcAccount);

      expect(account.exists, isTrue);
      expect(
        account,
        isA<ExistingAccount<JsonParsedAccountData<Map<String, dynamic>>>>(),
      );

      final existing =
          account
              as ExistingAccount<JsonParsedAccountData<Map<String, dynamic>>>;
      expect(existing.data.data, {'mint': '2222', 'owner': '3333'});
      expect(existing.data.parsedAccountMeta, isNotNull);
      expect(existing.data.parsedAccountMeta!.program, 'splToken');
      expect(existing.data.parsedAccountMeta!.type, 'token');
      expect(existing.executable, isFalse);
      expect(existing.lamports, Lamports(BigInt.from(1000000000)));
      expect(
        existing.programAddress,
        const Address('11111111111111111111111111111111'),
      );
      expect(existing.space, BigInt.from(165));
    });

    test('parses without info field', () {
      const addr = Address('GQE2yjns7SKKuMc89tveBDpzYHwXfeuB2PGAbGaPWc6G');
      final rpcAccount = <String, dynamic>{
        'data': <String, dynamic>{
          'parsed': <String, dynamic>{'type': 'token'},
          'program': 'splToken',
          'space': 165,
        },
        'executable': false,
        'lamports': 1000000000,
        'owner': '11111111111111111111111111111111',
        'space': 165,
      };

      final account = parseJsonRpcAccount(addr, rpcAccount);

      expect(account.exists, isTrue);
      final existing =
          account
              as ExistingAccount<JsonParsedAccountData<Map<String, dynamic>>>;
      expect(existing.data.data, isEmpty);
      expect(existing.data.parsedAccountMeta!.program, 'splToken');
      expect(existing.data.parsedAccountMeta!.type, 'token');
    });

    test('parses without metadata when program and type are missing', () {
      const addr = Address('GQE2yjns7SKKuMc89tveBDpzYHwXfeuB2PGAbGaPWc6G');
      final rpcAccount = <String, dynamic>{
        'data': <String, dynamic>{
          'parsed': <String, dynamic>{
            'info': <String, dynamic>{'mint': '2222'},
          },
          'space': 165,
        },
        'executable': false,
        'lamports': 1000000000,
        'owner': '11111111111111111111111111111111',
        'space': 165,
      };

      final account = parseJsonRpcAccount(addr, rpcAccount);

      expect(account.exists, isTrue);
      final existing =
          account
              as ExistingAccount<JsonParsedAccountData<Map<String, dynamic>>>;
      expect(existing.data.data, {'mint': '2222'});
      expect(existing.data.parsedAccountMeta, isNull);
    });

    test('parses an empty account (null)', () {
      const addr = Address('GQE2yjns7SKKuMc89tveBDpzYHwXfeuB2PGAbGaPWc6G');

      final account = parseJsonRpcAccount(addr, null);

      expect(account.exists, isFalse);
      expect(
        account,
        isA<NonExistingAccount<JsonParsedAccountData<Map<String, dynamic>>>>(),
      );
      expect(account.address, addr);
    });
  });

  group('parseBaseAccount', () {
    test('parses base account fields from a map with int values', () {
      final rpcAccount = <String, dynamic>{
        'executable': true,
        'lamports': 500000000,
        'owner': '11111111111111111111111111111111',
        'space': 200,
      };

      final baseAccount = parseBaseAccount(rpcAccount);

      expect(baseAccount.executable, isTrue);
      expect(baseAccount.lamports, Lamports(BigInt.from(500000000)));
      expect(
        baseAccount.programAddress,
        const Address('11111111111111111111111111111111'),
      );
      expect(baseAccount.space, BigInt.from(200));
    });

    test('parses base account fields from a map with BigInt values', () {
      final rpcAccount = <String, dynamic>{
        'executable': false,
        'lamports': BigInt.from(1000000000),
        'owner': '11111111111111111111111111111111',
        'space': BigInt.from(42),
      };

      final baseAccount = parseBaseAccount(rpcAccount);

      expect(baseAccount.executable, isFalse);
      expect(baseAccount.lamports, Lamports(BigInt.from(1000000000)));
      expect(baseAccount.space, BigInt.from(42));
    });
  });
}
