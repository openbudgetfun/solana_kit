import 'package:solana_kit_rpc_api/solana_kit_rpc_api.dart';
import 'package:test/test.dart';

/// Tests for RPC method param builders that take no arguments and always
/// return an empty params list.
void main() {
  group('zero-parameter RPC param builders', () {
    test('getClusterNodesParams returns empty list', () {
      expect(getClusterNodesParams(), isEmpty);
    });

    test('getEpochScheduleParams returns empty list', () {
      expect(getEpochScheduleParams(), isEmpty);
    });

    test('getFirstAvailableBlockParams returns empty list', () {
      expect(getFirstAvailableBlockParams(), isEmpty);
    });

    test('getGenesisHashParams returns empty list', () {
      expect(getGenesisHashParams(), isEmpty);
    });

    test('getHealthParams returns empty list', () {
      expect(getHealthParams(), isEmpty);
    });

    test('getHighestSnapshotSlotParams returns empty list', () {
      expect(getHighestSnapshotSlotParams(), isEmpty);
    });

    test('getIdentityParams returns empty list', () {
      expect(getIdentityParams(), isEmpty);
    });

    test('getInflationRateParams returns empty list', () {
      expect(getInflationRateParams(), isEmpty);
    });

    test('getMaxRetransmitSlotParams returns empty list', () {
      expect(getMaxRetransmitSlotParams(), isEmpty);
    });

    test('getMaxShredInsertSlotParams returns empty list', () {
      expect(getMaxShredInsertSlotParams(), isEmpty);
    });

    test('getVersionParams returns empty list', () {
      expect(getVersionParams(), isEmpty);
    });

    test('minimumLedgerSlotParams returns empty list', () {
      expect(minimumLedgerSlotParams(), isEmpty);
    });
  });
}
