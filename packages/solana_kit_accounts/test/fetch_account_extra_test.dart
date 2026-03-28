import 'dart:typed_data';

import 'package:solana_kit_accounts/solana_kit_accounts.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_rpc_spec/solana_kit_rpc_spec.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
// Slot is a typedef for BigInt in solana_kit_rpc_types
import 'package:test/test.dart';

const _addr = Address('GQE2yjns7SKKuMc89tveBDpzYHwXfeuB2PGAbGaPWc6G');
const _addrB = Address('11111111111111111111111111111111');
const _owner = '11111111111111111111111111111111';

// ---------------------------------------------------------------------------
// Mock RPC helpers
// ---------------------------------------------------------------------------

Rpc _makeRpc(
  Map<String, Map<String, dynamic>?> accountInfo, {
  bool nullTopLevelResponse = false,
  bool nullValueInMultiple = false,
}) {
  final api = MapRpcApi({
    'getAccountInfo': (params) => RpcPlan<Object?>(
      execute: (config) async {
        if (nullTopLevelResponse) return null;
        final addr = params[0]! as String;
        return <String, dynamic>{'value': accountInfo[addr]};
      },
    ),
    'getMultipleAccounts': (params) => RpcPlan<Object?>(
      execute: (config) async {
        if (nullTopLevelResponse) return null;
        final addrs = params[0]! as List;
        final values = addrs.map((a) {
          if (nullValueInMultiple) return null;
          return accountInfo[a as String];
        }).toList();
        return <String, dynamic>{'value': values};
      },
    ),
  });

  return Rpc(api: api, transport: (config) async => null);
}

Map<String, dynamic> _accountData({bool executable = false}) => <String, dynamic>{
  'data': ['AAEC', 'base64'],
  'executable': executable,
  'lamports': 1000,
  'owner': _owner,
  'space': 3,
};

void main() {
  // ---------------------------------------------------------------------------
  // FetchAccountConfig
  // ---------------------------------------------------------------------------
  group('FetchAccountConfig', () {
    test('can be created with no arguments', () {
      const config = FetchAccountConfig();
      expect(config.commitment, isNull);
      expect(config.minContextSlot, isNull);
    });

    test('can be created with commitment', () {
      const config = FetchAccountConfig(commitment: Commitment.confirmed);
      expect(config.commitment, Commitment.confirmed);
      expect(config.minContextSlot, isNull);
    });

    test('can be created with minContextSlot', () {
      final config = FetchAccountConfig(minContextSlot: BigInt.from(42));
      expect(config.minContextSlot, BigInt.from(42));
      expect(config.commitment, isNull);
    });

    test('can be created with both commitment and minContextSlot', () {
      final config = FetchAccountConfig(
        commitment: Commitment.finalized,
        minContextSlot: BigInt.from(100),
      );
      expect(config.commitment, Commitment.finalized);
      expect(config.minContextSlot, BigInt.from(100));
    });
  });

  // ---------------------------------------------------------------------------
  // fetchEncodedAccount – with config options
  // ---------------------------------------------------------------------------
  group('fetchEncodedAccount with config', () {
    test('fetches with commitment config', () async {
      final rpc = _makeRpc({_addr.value: _accountData()});

      final account = await fetchEncodedAccount(
        rpc,
        _addr,
        config: const FetchAccountConfig(commitment: Commitment.confirmed),
      );

      expect(account.exists, isTrue);
    });

    test('fetches with minContextSlot config', () async {
      final rpc = _makeRpc({_addr.value: _accountData()});

      final account = await fetchEncodedAccount(
        rpc,
        _addr,
        config: FetchAccountConfig(minContextSlot: BigInt.from(1)),
      );

      expect(account.exists, isTrue);
    });

    test('returns NonExistingAccount when response has null value', () async {
      final rpc = _makeRpc({_addr.value: null});

      final account = await fetchEncodedAccount(rpc, _addr);

      expect(account.exists, isFalse);
      expect(account.address, _addr);
    });
  });

  // ---------------------------------------------------------------------------
  // fetchEncodedAccounts – with null response
  // ---------------------------------------------------------------------------
  group('fetchEncodedAccounts edge cases', () {
    test('returns non-existing accounts when top-level response is null',
        () async {
      final rpc = _makeRpc({}, nullTopLevelResponse: true);

      final accounts = await fetchEncodedAccounts(rpc, [_addr, _addrB]);

      expect(accounts, hasLength(2));
      expect(accounts[0].exists, isFalse);
      expect(accounts[1].exists, isFalse);
    });

    test('fetches with commitment config', () async {
      final rpc = _makeRpc({
        _addr.value: _accountData(),
        _addrB.value: null,
      });

      final accounts = await fetchEncodedAccounts(
        rpc,
        [_addr, _addrB],
        config: const FetchAccountConfig(commitment: Commitment.processed),
      );

      expect(accounts, hasLength(2));
      expect(accounts[0].exists, isTrue);
      expect(accounts[1].exists, isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  // fetchJsonParsedAccount – edge cases
  // ---------------------------------------------------------------------------
  group('fetchJsonParsedAccount edge cases', () {
    test('returns NonExistingAccount when top-level response is null',
        () async {
      final rpc = _makeRpc({}, nullTopLevelResponse: true);

      final account = await fetchJsonParsedAccount(rpc, _addr);

      expect(account.exists, isFalse);
      expect(account.address, _addr);
    });

    test('returns NonExistingAccount when value is null', () async {
      final rpc = _makeRpc({_addr.value: null});

      final account = await fetchJsonParsedAccount(rpc, _addr);

      expect(account.exists, isFalse);
    });

    test('falls back to base64 parsing when data is not jsonParsed', () async {
      // Data is a base64-encoded list, not a jsonParsed map.
      final rpc = _makeRpc({
        _addr.value: <String, dynamic>{
          'data': ['AAEC', 'base64'],
          'executable': false,
          'lamports': 1000,
          'owner': _owner,
          'space': 3,
        },
      });

      final account = await fetchJsonParsedAccount(rpc, _addr);

      expect(account.exists, isTrue);
      // Falls back to ExistingAccount<Uint8List>.
      expect(account, isA<ExistingAccount<Uint8List>>());
    });

    test('fetches with commitment config', () async {
      final rpc = _makeRpc({_addr.value: null});

      final account = await fetchJsonParsedAccount(
        rpc,
        _addr,
        config: const FetchAccountConfig(commitment: Commitment.confirmed),
      );

      expect(account.exists, isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  // fetchJsonParsedAccounts – edge cases
  // ---------------------------------------------------------------------------
  group('fetchJsonParsedAccounts edge cases', () {
    test('returns non-existing accounts when top-level response is null',
        () async {
      final rpc = _makeRpc({}, nullTopLevelResponse: true);

      final accounts = await fetchJsonParsedAccounts(rpc, [_addr, _addrB]);

      expect(accounts, hasLength(2));
      expect(accounts[0].exists, isFalse);
      expect(accounts[1].exists, isFalse);
    });

    test('handles null account data in the value list', () async {
      final rpc = _makeRpc({_addr.value: null, _addrB.value: null});

      final accounts = await fetchJsonParsedAccounts(rpc, [_addr, _addrB]);

      expect(accounts, hasLength(2));
      expect(accounts[0].exists, isFalse);
      expect(accounts[1].exists, isFalse);
    });

    test('falls back to base64 for non-jsonParsed entries', () async {
      final rpc = _makeRpc({
        _addr.value: <String, dynamic>{
          'data': ['AAEC', 'base64'],
          'executable': false,
          'lamports': 1000,
          'owner': _owner,
          'space': 3,
        },
        _addrB.value: null,
      });

      final accounts = await fetchJsonParsedAccounts(rpc, [_addr, _addrB]);

      expect(accounts, hasLength(2));
      expect(accounts[0].exists, isTrue);
      expect(accounts[0], isA<ExistingAccount<Uint8List>>());
      expect(accounts[1].exists, isFalse);
    });

    test('fetches with minContextSlot config', () async {
      final rpc = _makeRpc({_addr.value: _accountData()});

      final accounts = await fetchJsonParsedAccounts(
        rpc,
        [_addr],
        config: FetchAccountConfig(minContextSlot: BigInt.from(5)),
      );

      expect(accounts, hasLength(1));
      expect(accounts[0].exists, isTrue);
    });
  });
}
