import 'package:solana_kit_accounts/solana_kit_accounts.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_program_client_core/solana_kit_program_client_core.dart';
import 'package:solana_kit_rpc_spec/solana_kit_rpc_spec.dart';
import 'package:test/test.dart';

const _mockAddressA = Address('GQE2yjns7SKKuMc89tveBDpzYHwXfeuB2PGAbGaPWc6G');
const _mockAddressB = Address('11111111111111111111111111111111');
const _mockAddressMissing = Address(
  'BPFLoaderUpgradeab1e11111111111111111111111',
);
const _ownerAddress = Address('11111111111111111111111111111111');

/// Creates a mock decoder that decodes a single byte into a map.
Decoder<Map<String, int>> _getMockDecoder() {
  return VariableSizeDecoder<Map<String, int>>(
    read: (bytes, offset) {
      final value = bytes[offset];
      return ({'value': value}, offset + 1);
    },
  );
}

/// Creates a mock RPC that responds to getAccountInfo and getMultipleAccounts.
Rpc _createMockRpc() {
  return Rpc(
    api: MapRpcApi({
      'getAccountInfo': (params) => RpcPlan<Object?>(
        execute: (_) async {
          final addressStr = params[0]! as String;
          return _getAccountResponse(Address(addressStr));
        },
      ),
      'getMultipleAccounts': (params) => RpcPlan<Object?>(
        execute: (_) async {
          final addresses = (params[0]! as List).cast<String>();
          return {
            'value': addresses
                .map((a) => _getRawAccountData(Address(a)))
                .toList(),
          };
        },
      ),
    }),
    transport: (_) async => null,
  );
}

Map<String, dynamic>? _getAccountResponse(Address address) {
  final rawData = _getRawAccountData(address);
  if (rawData == null) return null;
  return {'value': rawData};
}

Map<String, dynamic>? _getRawAccountData(Address address) {
  if (address == _mockAddressA) {
    return {
      'data': ['AQ==', 'base64'], // [1] in base64
      'executable': false,
      'lamports': 1000000000,
      'owner': _ownerAddress.value,
      'space': 1,
    };
  }
  if (address == _mockAddressB) {
    return {
      'data': ['Ag==', 'base64'], // [2] in base64
      'executable': false,
      'lamports': 2000000000,
      'owner': _ownerAddress.value,
      'space': 1,
    };
  }
  // Missing account.
  return null;
}

void main() {
  late Rpc mockRpc;
  late Decoder<Map<String, int>> decoder;
  late SelfFetchFunctions<Map<String, int>> fetchable;

  setUp(() {
    mockRpc = _createMockRpc();
    decoder = _getMockDecoder();
    fetchable = addSelfFetchFunctions(mockRpc, decoder);
  });

  group('SelfFetchFunctions', () {
    group('fetch', () {
      test('fetches and decodes a single account', () async {
        final result = await fetchable.fetch(_mockAddressA);

        expect(result.address, _mockAddressA);
        expect(result.data, {'value': 1});
      });

      test('throws when account does not exist', () async {
        expect(
          () => fetchable.fetch(_mockAddressMissing),
          throwsA(
            isA<SolanaError>().having(
              (e) => e.code,
              'code',
              SolanaErrorCode.accountsAccountNotFound,
            ),
          ),
        );
      });
    });

    group('fetchMaybe', () {
      test(
        'fetches and decodes a single account without asserting existence',
        () async {
          final result = await fetchable.fetchMaybe(_mockAddressA);

          expect(result.exists, isTrue);
          expect(result, isA<ExistingAccount<Map<String, int>>>());
          final existing = result as ExistingAccount<Map<String, int>>;
          expect(existing.data, {'value': 1});
          expect(existing.address, _mockAddressA);
        },
      );

      test(
        'returns a MaybeAccount for missing accounts without throwing',
        () async {
          final result = await fetchable.fetchMaybe(_mockAddressMissing);

          expect(result.exists, isFalse);
          expect(result, isA<NonExistingAccount<Map<String, int>>>());
          expect(result.address, _mockAddressMissing);
        },
      );
    });

    group('fetchAll', () {
      test('fetches and decodes multiple accounts', () async {
        final addresses = [_mockAddressA, _mockAddressB];
        final result = await fetchable.fetchAll(addresses);

        expect(result, hasLength(2));
        expect(result[0].address, _mockAddressA);
        expect(result[0].data, {'value': 1});
        expect(result[1].address, _mockAddressB);
        expect(result[1].data, {'value': 2});
      });

      test('throws when any account does not exist', () async {
        expect(
          () => fetchable.fetchAll([_mockAddressA, _mockAddressMissing]),
          throwsA(
            isA<SolanaError>().having(
              (e) => e.code,
              'code',
              SolanaErrorCode.accountsOneOrMoreAccountsNotFound,
            ),
          ),
        );
      });
    });

    group('fetchAllMaybe', () {
      test(
        'fetches and decodes multiple accounts without asserting existence',
        () async {
          final addresses = [_mockAddressA, _mockAddressB];
          final result = await fetchable.fetchAllMaybe(addresses);

          expect(result, hasLength(2));
          expect(result[0].exists, isTrue);
          expect((result[0] as ExistingAccount<Map<String, int>>).data, {
            'value': 1,
          });
          expect(result[1].exists, isTrue);
          expect((result[1] as ExistingAccount<Map<String, int>>).data, {
            'value': 2,
          });
        },
      );

      test(
        'returns MaybeAccounts including missing accounts without throwing',
        () async {
          final result = await fetchable.fetchAllMaybe([
            _mockAddressA,
            _mockAddressMissing,
          ]);

          expect(result, hasLength(2));
          expect(result[0].exists, isTrue);
          expect((result[0] as ExistingAccount<Map<String, int>>).data, {
            'value': 1,
          });
          expect(result[1].exists, isFalse);
          expect(result[1].address, _mockAddressMissing);
        },
      );
    });
  });

  group('addSelfFetchFunctions', () {
    test('returns a SelfFetchFunctions instance', () {
      final result = addSelfFetchFunctions(mockRpc, decoder);
      expect(result, isA<SelfFetchFunctions<Map<String, int>>>());
    });
  });
}
