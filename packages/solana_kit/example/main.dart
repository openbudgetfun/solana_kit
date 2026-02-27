// Examples intentionally print CLI output for demonstration purposes.
// ignore_for_file: avoid_print

import 'package:solana_kit/solana_kit.dart';

void main() {
  final rentExemption = getMinimumBalanceForRentExemption(165);

  final transformed = 2
      .pipe((value) => value + 3)
      .pipe((value) => value * 10);

  print('Rent exemption for 165 bytes: ${rentExemption.value} lamports');
  print('Pipe result: $transformed');
}
