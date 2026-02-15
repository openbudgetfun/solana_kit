/// A union of all possible commitment statuses -- each a measure of the
/// network confirmation and stake levels on a particular block.
///
/// Read more about the statuses themselves at
/// https://docs.solana.com/cluster/commitments.
enum Commitment {
  /// The node will query the most recent block confirmed by supermajority of
  /// the cluster as having reached maximum lockout, meaning the cluster has
  /// recognized this block as finalized.
  finalized,

  /// The node will query the most recent block that has been voted on by
  /// supermajority of the cluster.
  confirmed,

  /// The node will query its most recent block. Note that the block may still
  /// be skipped by the cluster.
  processed,
}

/// Returns a [Comparator] that sorts [Commitment] values according to their
/// level of finality in ascending order (processed < confirmed < finalized).
Comparator<Commitment> getCommitmentComparator() {
  return commitmentComparator;
}

/// Compares two [Commitment] values according to their level of finality.
///
/// Returns:
/// - `-1` if [a] has a lower finality level than [b]
/// - `0` if [a] and [b] have the same finality level
/// - `1` if [a] has a higher finality level than [b]
int commitmentComparator(Commitment a, Commitment b) {
  if (a == b) return 0;
  return _getCommitmentScore(a) < _getCommitmentScore(b) ? -1 : 1;
}

int _getCommitmentScore(Commitment commitment) {
  return switch (commitment) {
    Commitment.finalized => 2,
    Commitment.confirmed => 1,
    Commitment.processed => 0,
  };
}
