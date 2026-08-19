import 'package:http/http.dart' as http;
import 'package:solana_kit_helius/src/transactions/fetch_tip_floor.dart';
import 'package:solana_kit_helius/src/transactions/lamports.dart';

/// Minimum tip (in SOL) when routing through staked weighted QUIC only.
///
/// Upstream Sender Max lowered the SWQOS-only floor from 0.0005 SOL to
/// 0.000005 SOL (5,000 lamports) in v3.1.0.
const swqosMinimumTipSol = 0.000005;

/// Minimum tip (in SOL) when using the dual-route tip strategy.
const dualRouteMinimumTipSol = 0.001;

/// Determines the recommended tip, in lamports, for a transaction based on the
/// 75th percentile tip floor and the configured minimum.
Future<BigInt> determineTipSol({
  required bool swqosOnly,
  http.Client? client,
  Future<double?> Function()? fetchTipFloor,
  BigInt Function(double sol)? toLamports,
}) async {
  final floor =
      await (fetchTipFloor ?? (() => fetchTipFloor75th(client: client)))();
  final minimum = swqosOnly ? swqosMinimumTipSol : dualRouteMinimumTipSol;
  final tipSol = floor == null || floor < minimum ? minimum : floor;
  return (toLamports ?? solToLamports)(tipSol);
}
