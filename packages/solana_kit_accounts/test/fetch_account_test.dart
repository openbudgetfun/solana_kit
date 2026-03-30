import 'dart:typed_data';

import 'package:solana_kit_accounts/solana_kit_accounts.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:solana_kit_test_matchers/solana_kit_test_matchers.dart';
import 'package:test/test.dart';

void main() {
  group('fetchEncodedAccount', () {
    test('fetches and parses an existing base64-encoded account', () async {
      const addr = testAccountAddressA;
      final rpc = createAccountsFixtureRpc({addr: base64RpcAccountFixture()});

      final account = await fetchEncodedAccount(rpc, addr);

      expect(account.exists, isTrue);
      final existing = account as ExistingAccount<Uint8List>;
      expect(
        existing.data,
        equals(Uint8List.fromList([178, 137, 158, 117, 171, 90])),
      );
      expect(existing.executable, isFalse);
      expect(existing.lamports, Lamports(BigInt.from(1000000000)));
      expect(existing.programAddress, testOwnerAddress);
      expect(existing.space, BigInt.from(6));
    });

    test('fetches and parses a missing account', () async {
      const addr = testAccountAddressA;
      final rpc = createAccountsFixtureRpc({});

      final account = await fetchEncodedAccount(rpc, addr);

      expect(account.exists, isFalse);
      expect(account, isA<NonExistingAccount<Uint8List>>());
      expect(account.address, addr);
    });
  });

  group('SolanaAccountClient', () {
    test('fetches encoded accounts through the higher-level client', () async {
      const addr = testAccountAddressA;
      final rpc = createAccountsFixtureRpc({addr: base64RpcAccountFixture()});
      final client = createSolanaAccountClient(rpc);

      final account = await client.fetchEncodedAccount(addr);

      expect(account.exists, isTrue);
      expect(account.address, addr);
    });

    test(
      'fetches jsonParsed accounts through the higher-level client',
      () async {
        const addr = testAccountAddressA;
        final rpc = createAccountsFixtureRpc({
          addr: jsonParsedRpcAccountFixture(),
        });
        final client = createSolanaAccountClient(rpc);

        final account = await client.fetchJsonParsedAccount(addr);

        expect(account.exists, isTrue);
        expect(account.address, addr);
      },
    );
  });

  group('fetchEncodedAccounts', () {
    test('fetches and parses multiple accounts', () async {
      const addrA = testAccountAddressA;
      const addrB = testAccountAddressB;

      final rpc = createAccountsFixtureRpc({addrA: base64RpcAccountFixture()});

      final accounts = await fetchEncodedAccounts(rpc, [addrA, addrB]);

      expect(accounts, hasLength(2));

      expect(accounts[0].exists, isTrue);
      final existingA = accounts[0] as ExistingAccount<Uint8List>;
      expect(
        existingA.data,
        equals(Uint8List.fromList([178, 137, 158, 117, 171, 90])),
      );

      expect(accounts[1].exists, isFalse);
      expect(accounts[1].address, addrB);
    });
  });

  group('fetchJsonParsedAccount', () {
    test('fetches and parses an existing jsonParsed account', () async {
      const addr = testAccountAddressA;
      final rpc = createAccountsFixtureRpc({
        addr: jsonParsedRpcAccountFixture(),
      });

      final account = await fetchJsonParsedAccount(rpc, addr);

      expect(account.exists, isTrue);
    });

    test('fetches and parses a missing jsonParsed account', () async {
      const addr = testAccountAddressA;
      final rpc = createAccountsFixtureRpc({});

      final account = await fetchJsonParsedAccount(rpc, addr);

      expect(account.exists, isFalse);
      expect(account.address, addr);
    });
  });

  group('fetchJsonParsedAccounts', () {
    test('fetches and parses multiple jsonParsed accounts', () async {
      const addrA = testAccountAddressA;
      const addrB = testAccountAddressB;

      final rpc = createAccountsFixtureRpc({
        addrA: jsonParsedRpcAccountFixture(),
      });

      final accounts = await fetchJsonParsedAccounts(rpc, [addrA, addrB]);

      expect(accounts, hasLength(2));
      expect(accounts[0].exists, isTrue);
      expect(accounts[1].exists, isFalse);
      expect(accounts[1].address, addrB);
    });
  });
}
