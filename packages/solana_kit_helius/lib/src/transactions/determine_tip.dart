import 'package:http/http.dart' as http;
import 'package:solana_kit_helius/src/transactions/fetch_tip_floor.dart';
import 'package:solana_kit_helius/src/transactions/lamports.dart';

const swqosMinimumTipSol = 0.0005;
const dualRouteMinimumTipSol = 0.001;

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
