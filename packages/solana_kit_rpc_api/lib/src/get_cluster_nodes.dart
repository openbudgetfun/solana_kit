import 'package:solana_kit_addresses/solana_kit_addresses.dart';

/// Information about a cluster node.
class ClusterNode {
  /// Creates a new [ClusterNode].
  const ClusterNode({
    required this.pubkey,
    this.featureSet,
    this.gossip,
    this.pubsub,
    this.rpc,
    this.serveRepair,
    this.shredVersion,
    this.tpu,
    this.tpuForwards,
    this.tpuForwardsQuic,
    this.tpuQuic,
    this.tpuVote,
    this.tvu,
    this.version,
  });

  /// The unique identifier of the node's feature set.
  final int? featureSet;

  /// Gossip network address for the node.
  final String? gossip;

  /// Node public key, as base-58 encoded string.
  final Address pubkey;

  /// WebSocket PubSub network address for the node.
  final String? pubsub;

  /// JSON RPC network address for the node.
  final String? rpc;

  /// Server repair UDP network address for the node.
  final String? serveRepair;

  /// The shred version the node has been configured to use.
  final int? shredVersion;

  /// TPU network address for the node.
  final String? tpu;

  /// TPU UDP forwards network address for the node.
  final String? tpuForwards;

  /// TPU QUIC forwards network address for the node.
  final String? tpuForwardsQuic;

  /// TPU QUIC network address for the node.
  final String? tpuQuic;

  /// TPU UDP vote network address for the node.
  final String? tpuVote;

  /// TVU UDP network address for the node.
  final String? tvu;

  /// The software version of the node.
  final String? version;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClusterNode &&
          runtimeType == other.runtimeType &&
          featureSet == other.featureSet &&
          gossip == other.gossip &&
          pubkey == other.pubkey &&
          pubsub == other.pubsub &&
          rpc == other.rpc &&
          serveRepair == other.serveRepair &&
          shredVersion == other.shredVersion &&
          tpu == other.tpu &&
          tpuForwards == other.tpuForwards &&
          tpuForwardsQuic == other.tpuForwardsQuic &&
          tpuQuic == other.tpuQuic &&
          tpuVote == other.tpuVote &&
          tvu == other.tvu &&
          version == other.version;

  @override
  int get hashCode => Object.hash(
    runtimeType,
    featureSet,
    gossip,
    pubkey,
    pubsub,
    rpc,
    serveRepair,
    shredVersion,
    tpu,
    tpuForwards,
    tpuForwardsQuic,
    tpuQuic,
    tpuVote,
    tvu,
    version,
  );

  @override
  String toString() =>
      'ClusterNode(pubkey: $pubkey, featureSet: $featureSet, gossip: $gossip, '
      'pubsub: $pubsub, rpc: $rpc, serveRepair: $serveRepair, '
      'shredVersion: $shredVersion, tpu: $tpu, tpuForwards: $tpuForwards, '
      'tpuForwardsQuic: $tpuForwardsQuic, tpuQuic: $tpuQuic, '
      'tpuVote: $tpuVote, tvu: $tvu, version: $version)';
}

/// Builds the JSON-RPC params list for `getClusterNodes`.
List<Object?> getClusterNodesParams() {
  return [];
}
