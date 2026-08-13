// Examples intentionally print CLI output for demonstration purposes.
// ignore_for_file: avoid_print

import 'package:solana_kit/solana_kit.dart';

void main() {
  // The local `getMinimumBalanceForRentExemption` helper was removed in
  // @solana/kit v7.0.0 because rent exemption is becoming dynamic (see
  // SIMD-0437/0194/0389). Fetch the value from an RPC node instead:
  //
  //   final rpc = createSolanaRpc('https://api.mainnet-beta.solana.com');
  //   final rent = await rpc.getMinimumBalanceForRentExemption(165).send();
  //   print('Rent exemption for 165 bytes: ${rent.value} lamports');

  final transformed = 2.pipe((value) => value + 3).pipe((value) => value * 10);

  print('Pipe result: $transformed');
}
