import 'dart:typed_data';

import 'package:solana_kit_accounts/solana_kit_accounts.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_rpc_spec/solana_kit_rpc_spec.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:test/test.dart';

/// Creates a mock Rpc that returns accounts for a given set of addresses.
///
/// The [accounts] map is keyed by address string and values are the RPC
/// account data maps.
Rpc _getMockRpc(Map<String, Map<String, dynamic>> accounts) {
  final api = MapRpcApi({
    'getAccountInfo': (params) => RpcPlan<Object?>(
      execute: (config) async {
        final addr = (params[0]! as String?)!;
        final value = accounts[addr];
        return <String, dynamic>{
          'context': <String, dynamic>{'slot': BigInt.zero},
          'value': value,
        };
      },
    ),
    'getMultipleAccounts': (params) => RpcPlan<Object?>(
      execute: (config) async {
        final addrs = (params[0]! as List?)!;
        final values = addrs.map((a) => accounts[a! as String]).toList();
        return <String, dynamic>{
          'context': <String, dynamic>{'slot': BigInt.zero},
          'value': values,
        };
      },
    ),
  });

  return Rpc(api: api, transport: (config) async => null);
}

void main() {
  group('fetchEncodedAccount', () {
    test('fetches and parses an existing base64-encoded account', () async {
      const addr = Address('GQE2yjns7SKKuMc89tveBDpzYHwXfeuB2PGAbGaPWc6G');
      final rpc = _getMockRpc({
        addr.value: <String, dynamic>{
          'data': ['somedata', 'base64'],
          'executable': false,
          'lamports': 1000000000,
          'owner': '11111111111111111111111111111111',
          'space': 6,
        },
      });

      final account = await fetchEncodedAccount(rpc, addr);

      expect(account.exists, isTrue);
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

    test('fetches and parses a missing account', () async {
      const addr = Address('GQE2yjns7SKKuMc89tveBDpzYHwXfeuB2PGAbGaPWc6G');
      final rpc = _getMockRpc({});

      final account = await fetchEncodedAccount(rpc, addr);

      expect(account.exists, isFalse);
      expect(account, isA<NonExistingAccount<Uint8List>>());
      expect(account.address, addr);
    });
  });

  group('fetchEncodedAccounts', () {
    test('fetches and parses multiple accounts', () async {
      const addrA = Address('GQE2yjns7SKKuMc89tveBDpzYHwXfeuB2PGAbGaPWc6G');
      const addrB = Address('11111111111111111111111111111111');

      final rpc = _getMockRpc({
        addrA.value: <String, dynamic>{
          'data': ['somedata', 'base64'],
          'executable': false,
          'lamports': 1000000000,
          'owner': '11111111111111111111111111111111',
          'space': 6,
        },
      });

      final accounts = await fetchEncodedAccounts(rpc, [addrA, addrB]);

      expect(accounts, hasLength(2));

      // Account A exists
      expect(accounts[0].exists, isTrue);
      final existingA = accounts[0] as ExistingAccount<Uint8List>;
      expect(
        existingA.data,
        equals(Uint8List.fromList([178, 137, 158, 117, 171, 90])),
      );

      // Account B does not exist
      expect(accounts[1].exists, isFalse);
      expect(accounts[1].address, addrB);
    });
  });

  group('fetchJsonParsedAccount', () {
    test('fetches and parses an existing jsonParsed account', () async {
      const addr = Address('GQE2yjns7SKKuMc89tveBDpzYHwXfeuB2PGAbGaPWc6G');
      final rpc = _getMockRpc({
        addr.value: <String, dynamic>{
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
        },
      });

      final account = await fetchJsonParsedAccount(rpc, addr);

      expect(account.exists, isTrue);
    });

    test('fetches and parses a missing jsonParsed account', () async {
      const addr = Address('GQE2yjns7SKKuMc89tveBDpzYHwXfeuB2PGAbGaPWc6G');
      final rpc = _getMockRpc({});

      final account = await fetchJsonParsedAccount(rpc, addr);

      expect(account.exists, isFalse);
      expect(account.address, addr);
    });
  });

  group('fetchJsonParsedAccounts', () {
    test('fetches and parses multiple jsonParsed accounts', () async {
      const addrA = Address('GQE2yjns7SKKuMc89tveBDpzYHwXfeuB2PGAbGaPWc6G');
      const addrB = Address('11111111111111111111111111111111');

      final rpc = _getMockRpc({
        addrA.value: <String, dynamic>{
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
        },
      });

      final accounts = await fetchJsonParsedAccounts(rpc, [addrA, addrB]);

      expect(accounts, hasLength(2));

      // Account A exists
      expect(accounts[0].exists, isTrue);

      // Account B does not exist
      expect(accounts[1].exists, isFalse);
      expect(accounts[1].address, addrB);
    });
  });
}
