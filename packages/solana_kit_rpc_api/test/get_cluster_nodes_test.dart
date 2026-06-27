import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_rpc_api/solana_kit_rpc_api.dart';
import 'package:test/test.dart';

const _pubkey = Address('11111111111111111111111111111111');

void main() {
  group('ClusterNode', () {
    test('can be constructed with clientId', () {
      const node = ClusterNode(pubkey: _pubkey, clientId: 'client-123');
      expect(node.pubkey, _pubkey);
      expect(node.clientId, 'client-123');
    });

    test('clientId defaults to null when not provided', () {
      const node = ClusterNode(pubkey: _pubkey);
      expect(node.clientId, isNull);
    });

    test('equality is true when all fields including clientId match', () {
      const a = ClusterNode(pubkey: _pubkey, clientId: 'client-1');
      const b = ClusterNode(pubkey: _pubkey, clientId: 'client-1');
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('equality is false when clientId differs', () {
      const a = ClusterNode(pubkey: _pubkey, clientId: 'client-1');
      const b = ClusterNode(pubkey: _pubkey, clientId: 'client-2');
      expect(a == b, isFalse);
    });

    test('equality is false when other fields differ', () {
      const a = ClusterNode(
        pubkey: _pubkey,
        clientId: 'client-1',
        rpc: 'rpc-a',
      );
      const b = ClusterNode(
        pubkey: _pubkey,
        clientId: 'client-1',
        rpc: 'rpc-b',
      );
      expect(a == b, isFalse);
    });

    test('toString includes clientId', () {
      const node = ClusterNode(pubkey: _pubkey, clientId: 'client-xyz');
      expect(node.toString(), contains('clientId: client-xyz'));
    });

    test('toString includes clientId: null when absent', () {
      const node = ClusterNode(pubkey: _pubkey);
      expect(node.toString(), contains('clientId: null'));
    });

    test('hashCode is consistent with equality', () {
      const a = ClusterNode(pubkey: _pubkey, clientId: 'client-1');
      const b = ClusterNode(pubkey: _pubkey, clientId: 'client-1');
      expect(a.hashCode, b.hashCode);
    });

    test('hashCode differs when clientId differs', () {
      const a = ClusterNode(pubkey: _pubkey, clientId: 'client-1');
      const b = ClusterNode(pubkey: _pubkey, clientId: 'client-2');
      expect(a.hashCode == b.hashCode, isFalse);
    });
  });

  group('getClusterNodesParams', () {
    test('returns an empty list', () {
      expect(getClusterNodesParams(), isEmpty);
    });
  });
}
