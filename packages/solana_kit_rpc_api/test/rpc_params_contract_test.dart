import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_keys/solana_kit_keys.dart';
import 'package:solana_kit_rpc_api/solana_kit_rpc_api.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:test/test.dart';

const _addressA = Address('11111111111111111111111111111111');
const _addressB = Address('TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA');
const _signatureA = Signature(
  '1111111111111111111111111111111111111111111111111111111111111111',
);
const _signatureB = Signature(
  '2222222222222222222222222222222222222222222222222222222222222222',
);
const _blockhash = Blockhash('11111111111111111111111111111111');

void main() {
  group('RPC param builder contracts', () {
    test('zero-parameter methods emit an empty params list', () {
      final testCases = <({String method, List<Object?> params})>[
        (method: 'getClusterNodes', params: getClusterNodesParams()),
        (method: 'getEpochSchedule', params: getEpochScheduleParams()),
        (
          method: 'getFirstAvailableBlock',
          params: getFirstAvailableBlockParams(),
        ),
        (method: 'getGenesisHash', params: getGenesisHashParams()),
        (method: 'getHealth', params: getHealthParams()),
        (
          method: 'getHighestSnapshotSlot',
          params: getHighestSnapshotSlotParams(),
        ),
        (method: 'getIdentity', params: getIdentityParams()),
        (method: 'getInflationRate', params: getInflationRateParams()),
        (method: 'getMaxRetransmitSlot', params: getMaxRetransmitSlotParams()),
        (
          method: 'getMaxShredInsertSlot',
          params: getMaxShredInsertSlotParams(),
        ),
        (method: 'getVersion', params: getVersionParams()),
        (method: 'minimumLedgerSlot', params: minimumLedgerSlotParams()),
      ];

      for (final testCase in testCases) {
        expect(testCase.params, isEmpty, reason: testCase.method);
      }
    });

    test('required positional arguments are preserved in-order', () {
      final testCases =
          <({String method, List<Object?> actual, List<Object?> expected})>[
            (
              method: 'getBlockCommitment',
              actual: getBlockCommitmentParams(BigInt.from(10)),
              expected: <Object?>[BigInt.from(10)],
            ),
            (
              method: 'getBlockTime',
              actual: getBlockTimeParams(BigInt.from(20)),
              expected: <Object?>[BigInt.from(20)],
            ),
            (
              method: 'getBlocksWithLimit',
              actual: getBlocksWithLimitParams(BigInt.from(1), 25),
              expected: <Object?>[BigInt.from(1), 25],
            ),
            (
              method: 'getFeeForMessage',
              actual: getFeeForMessageParams('AQID'),
              expected: <Object?>['AQID'],
            ),
            (
              method: 'getMinimumBalanceForRentExemption',
              actual: getMinimumBalanceForRentExemptionParams(BigInt.from(165)),
              expected: <Object?>[BigInt.from(165)],
            ),
            (
              method: 'getProgramAccounts',
              actual: getProgramAccountsParams(_addressB),
              expected: <Object?>[_addressB.value],
            ),
            (
              method: 'getSignaturesForAddress',
              actual: getSignaturesForAddressParams(_addressA),
              expected: <Object?>[_addressA.value],
            ),
            (
              method: 'getSignatureStatuses',
              actual: getSignatureStatusesParams([_signatureA, _signatureB]),
              expected: <Object?>[
                [_signatureA.value, _signatureB.value],
              ],
            ),
            (
              method: 'getSlotLeaders',
              actual: getSlotLeadersParams(BigInt.from(100), 4),
              expected: <Object?>[BigInt.from(100), 4],
            ),
            (
              method: 'getTokenAccountBalance',
              actual: getTokenAccountBalanceParams(_addressA),
              expected: <Object?>[_addressA.value],
            ),
            (
              method: 'getTokenLargestAccounts',
              actual: getTokenLargestAccountsParams(_addressB),
              expected: <Object?>[_addressB.value],
            ),
            (
              method: 'getTokenSupply',
              actual: getTokenSupplyParams(_addressB),
              expected: <Object?>[_addressB.value],
            ),
            (
              method: 'getTransaction',
              actual: getTransactionParams(_signatureA),
              expected: <Object?>[_signatureA.value],
            ),
            (
              method: 'isBlockhashValid',
              actual: isBlockhashValidParams(_blockhash),
              expected: <Object?>[_blockhash.value],
            ),
            (
              method: 'requestAirdrop',
              actual: requestAirdropParams(
                _addressA,
                Lamports(BigInt.from(1_000_000_000)),
              ),
              expected: <Object?>[_addressA.value, BigInt.from(1_000_000_000)],
            ),
            (
              method: 'getInflationReward',
              actual: getInflationRewardParams([_addressA, _addressB]),
              expected: <Object?>[
                [_addressA.value, _addressB.value],
              ],
            ),
            (
              method: 'getMultipleAccounts',
              actual: getMultipleAccountsParams([_addressA, _addressB]),
              expected: <Object?>[
                [_addressA.value, _addressB.value],
              ],
            ),
          ];

      for (final testCase in testCases) {
        expect(testCase.actual, testCase.expected, reason: testCase.method);
      }
    });

    test('optional positional arguments are omitted when null', () {
      expect(getRecentPerformanceSamplesParams(), isEmpty);
      expect(getRecentPerformanceSamplesParams(32), [32]);

      expect(getRecentPrioritizationFeesParams(), isEmpty);
      expect(
        getRecentPrioritizationFeesParams([_addressA, _addressB]),
        [
          [_addressA.value, _addressB.value],
        ],
      );

      expect(getBlocksParams(BigInt.from(1)), [BigInt.from(1)]);
      expect(
        getBlocksParams(BigInt.from(1), BigInt.from(2)),
        [BigInt.from(1), BigInt.from(2)],
      );

      expect(getLeaderScheduleParams(), [null]);
      expect(
        getLeaderScheduleParams(BigInt.from(9)),
        [BigInt.from(9)],
      );
    });

    test('filter helpers serialize to RPC payload shape', () {
      expect(
        const TokenAccountMintFilter(mint: _addressB).toJson(),
        {'mint': _addressB.value},
      );
      expect(
        const TokenAccountProgramIdFilter(programId: _addressB).toJson(),
        {'programId': _addressB.value},
      );
      expect(
        getTokenAccountsByOwnerParams(
          _addressA,
          const TokenAccountMintFilter(mint: _addressB).toJson(),
        ),
        [
          _addressA.value,
          {'mint': _addressB.value},
        ],
      );
      expect(
        getTokenAccountsByDelegateParams(
          _addressA,
          const TokenAccountProgramIdFilter(programId: _addressB).toJson(),
        ),
        [
          _addressA.value,
          {'programId': _addressB.value},
        ],
      );
    });
  });

  group('RPC config serializer contracts', () {
    test(
      'serializers include every non-null field with expected key names',
      () {
        final testCases =
            <
              ({
                String type,
                Map<String, Object?> actual,
                Map<String, Object?> expected,
              })
            >[
              (
                type: 'GetBlockHeightConfig',
                actual: GetBlockHeightConfig(
                  commitment: Commitment.confirmed,
                  minContextSlot: BigInt.from(7),
                ).toJson(),
                expected: {
                  'commitment': 'confirmed',
                  'minContextSlot': BigInt.from(7),
                },
              ),
              (
                type: 'GetBlocksConfig',
                actual: const GetBlocksConfig(
                  commitment: Commitment.finalized,
                ).toJson(),
                expected: {'commitment': 'finalized'},
              ),
              (
                type: 'GetBlocksWithLimitConfig',
                actual: const GetBlocksWithLimitConfig(
                  commitment: Commitment.confirmed,
                ).toJson(),
                expected: {'commitment': 'confirmed'},
              ),
              (
                type: 'GetEpochInfoConfig',
                actual: GetEpochInfoConfig(
                  commitment: Commitment.finalized,
                  minContextSlot: BigInt.from(99),
                ).toJson(),
                expected: {
                  'commitment': 'finalized',
                  'minContextSlot': BigInt.from(99),
                },
              ),
              (
                type: 'GetInflationRewardConfig',
                actual: GetInflationRewardConfig(
                  commitment: Commitment.confirmed,
                  epoch: BigInt.from(3),
                  minContextSlot: BigInt.from(4),
                ).toJson(),
                expected: {
                  'commitment': 'confirmed',
                  'epoch': BigInt.from(3),
                  'minContextSlot': BigInt.from(4),
                },
              ),
              (
                type: 'GetLatestBlockhashConfig',
                actual: GetLatestBlockhashConfig(
                  commitment: Commitment.processed,
                  minContextSlot: BigInt.from(33),
                ).toJson(),
                expected: {
                  'commitment': 'processed',
                  'minContextSlot': BigInt.from(33),
                },
              ),
              (
                type: 'GetLeaderScheduleConfig',
                actual: const GetLeaderScheduleConfig(
                  commitment: Commitment.confirmed,
                  identity: _addressA,
                ).toJson(),
                expected: {
                  'commitment': 'confirmed',
                  'identity': _addressA.value,
                },
              ),
              (
                type: 'GetInflationGovernorConfig',
                actual: const GetInflationGovernorConfig(
                  commitment: Commitment.finalized,
                ).toJson(),
                expected: {'commitment': 'finalized'},
              ),
              (
                type: 'SlotRange',
                actual: SlotRange(
                  firstSlot: BigInt.from(1),
                  lastSlot: BigInt.from(2),
                ).toJson(),
                expected: {
                  'firstSlot': BigInt.from(1),
                  'lastSlot': BigInt.from(2),
                },
              ),
              (
                type: 'GetBlockProductionConfig',
                actual: GetBlockProductionConfig(
                  commitment: Commitment.confirmed,
                  identity: _addressB,
                  range: SlotRange(firstSlot: BigInt.from(11)),
                ).toJson(),
                expected: {
                  'commitment': 'confirmed',
                  'identity': _addressB.value,
                  'range': {'firstSlot': BigInt.from(11)},
                },
              ),
              (
                type: 'GetFeeForMessageConfig',
                actual: GetFeeForMessageConfig(
                  commitment: Commitment.finalized,
                  minContextSlot: BigInt.from(5),
                ).toJson(),
                expected: {
                  'commitment': 'finalized',
                  'minContextSlot': BigInt.from(5),
                },
              ),
              (
                type: 'GetSignatureStatusesConfig',
                actual: const GetSignatureStatusesConfig(
                  searchTransactionHistory: true,
                ).toJson(),
                expected: {'searchTransactionHistory': true},
              ),
              (
                type: 'GetLargestAccountsConfig',
                actual: const GetLargestAccountsConfig(
                  commitment: Commitment.confirmed,
                  filter: 'circulating',
                ).toJson(),
                expected: {'commitment': 'confirmed', 'filter': 'circulating'},
              ),
              (
                type: 'GetSignaturesForAddressConfig',
                actual: GetSignaturesForAddressConfig(
                  before: _signatureA,
                  commitment: Commitment.finalized,
                  limit: 10,
                  minContextSlot: BigInt.from(55),
                  until: _signatureB,
                ).toJson(),
                expected: {
                  'before': _signatureA.value,
                  'commitment': 'finalized',
                  'limit': 10,
                  'minContextSlot': BigInt.from(55),
                  'until': _signatureB.value,
                },
              ),
              (
                type: 'GetSlotLeaderConfig',
                actual: GetSlotLeaderConfig(
                  commitment: Commitment.confirmed,
                  minContextSlot: BigInt.from(22),
                ).toJson(),
                expected: {
                  'commitment': 'confirmed',
                  'minContextSlot': BigInt.from(22),
                },
              ),
              (
                type: 'GetMinimumBalanceForRentExemptionConfig',
                actual: const GetMinimumBalanceForRentExemptionConfig(
                  commitment: Commitment.finalized,
                ).toJson(),
                expected: {'commitment': 'finalized'},
              ),
              (
                type: 'GetSlotConfig',
                actual: GetSlotConfig(
                  commitment: Commitment.processed,
                  minContextSlot: BigInt.from(8),
                ).toJson(),
                expected: {
                  'commitment': 'processed',
                  'minContextSlot': BigInt.from(8),
                },
              ),
              (
                type: 'IsBlockhashValidConfig',
                actual: IsBlockhashValidConfig(
                  commitment: Commitment.confirmed,
                  minContextSlot: BigInt.from(9),
                ).toJson(),
                expected: {
                  'commitment': 'confirmed',
                  'minContextSlot': BigInt.from(9),
                },
              ),
              (
                type: 'GetTokenSupplyConfig',
                actual: const GetTokenSupplyConfig(
                  commitment: Commitment.finalized,
                ).toJson(),
                expected: {'commitment': 'finalized'},
              ),
              (
                type: 'GetVoteAccountsConfig',
                actual: GetVoteAccountsConfig(
                  commitment: Commitment.confirmed,
                  delinquentSlotDistance: BigInt.from(3),
                  keepUnstakedDelinquents: false,
                  votePubkey: _addressA,
                ).toJson(),
                expected: {
                  'commitment': 'confirmed',
                  'delinquentSlotDistance': BigInt.from(3),
                  'keepUnstakedDelinquents': false,
                  'votePubkey': _addressA.value,
                },
              ),
              (
                type: 'GetTransactionConfig',
                actual: const GetTransactionConfig(
                  commitment: Commitment.finalized,
                  encoding: TransactionEncoding.json,
                  maxSupportedTransactionVersion: 0,
                ).toJson(),
                expected: {
                  'commitment': 'finalized',
                  'encoding': 'json',
                  'maxSupportedTransactionVersion': 0,
                },
              ),
              (
                type: 'GetStakeMinimumDelegationConfig',
                actual: const GetStakeMinimumDelegationConfig(
                  commitment: Commitment.processed,
                ).toJson(),
                expected: {'commitment': 'processed'},
              ),
              (
                type: 'GetProgramAccountsConfig',
                actual: GetProgramAccountsConfig(
                  commitment: Commitment.confirmed,
                  encoding: AccountEncoding.base64,
                  dataSlice: const DataSlice(offset: 10, length: 20),
                  filters: const [
                    {'dataSize': 165},
                  ],
                  minContextSlot: BigInt.from(123),
                  withContext: true,
                ).toJson(),
                expected: {
                  'commitment': 'confirmed',
                  'encoding': 'base64',
                  'dataSlice': {'offset': 10, 'length': 20},
                  'filters': const [
                    {'dataSize': 165},
                  ],
                  'minContextSlot': BigInt.from(123),
                  'withContext': true,
                },
              ),
              (
                type: 'GetTransactionCountConfig',
                actual: GetTransactionCountConfig(
                  commitment: Commitment.finalized,
                  minContextSlot: BigInt.from(20),
                ).toJson(),
                expected: {
                  'commitment': 'finalized',
                  'minContextSlot': BigInt.from(20),
                },
              ),
              (
                type: 'GetTokenAccountsByDelegateConfig',
                actual: GetTokenAccountsByDelegateConfig(
                  commitment: Commitment.confirmed,
                  encoding: AccountEncoding.base64,
                  dataSlice: const DataSlice(offset: 4, length: 8),
                  minContextSlot: BigInt.from(2),
                ).toJson(),
                expected: {
                  'commitment': 'confirmed',
                  'encoding': 'base64',
                  'dataSlice': {'offset': 4, 'length': 8},
                  'minContextSlot': BigInt.from(2),
                },
              ),
              (
                type: 'GetMultipleAccountsConfig',
                actual: GetMultipleAccountsConfig(
                  commitment: Commitment.processed,
                  encoding: AccountEncoding.base64,
                  dataSlice: const DataSlice(offset: 0, length: 32),
                  minContextSlot: BigInt.from(77),
                ).toJson(),
                expected: {
                  'commitment': 'processed',
                  'encoding': 'base64',
                  'dataSlice': {'offset': 0, 'length': 32},
                  'minContextSlot': BigInt.from(77),
                },
              ),
              (
                type: 'GetTokenAccountBalanceConfig',
                actual: const GetTokenAccountBalanceConfig(
                  commitment: Commitment.confirmed,
                ).toJson(),
                expected: {'commitment': 'confirmed'},
              ),
              (
                type: 'GetTokenAccountsByOwnerConfig',
                actual: GetTokenAccountsByOwnerConfig(
                  commitment: Commitment.finalized,
                  encoding: AccountEncoding.base64,
                  dataSlice: const DataSlice(offset: 6, length: 12),
                  minContextSlot: BigInt.from(44),
                ).toJson(),
                expected: {
                  'commitment': 'finalized',
                  'encoding': 'base64',
                  'dataSlice': {'offset': 6, 'length': 12},
                  'minContextSlot': BigInt.from(44),
                },
              ),
              (
                type: 'GetSupplyConfig',
                actual: const GetSupplyConfig(
                  commitment: Commitment.confirmed,
                  excludeNonCirculatingAccountsList: true,
                ).toJson(),
                expected: {
                  'commitment': 'confirmed',
                  'excludeNonCirculatingAccountsList': true,
                },
              ),
              (
                type: 'GetTokenLargestAccountsConfig',
                actual: const GetTokenLargestAccountsConfig(
                  commitment: Commitment.finalized,
                ).toJson(),
                expected: {'commitment': 'finalized'},
              ),
            ];

        for (final testCase in testCases) {
          expect(testCase.actual, testCase.expected, reason: testCase.type);
        }
      },
    );
  });
}
