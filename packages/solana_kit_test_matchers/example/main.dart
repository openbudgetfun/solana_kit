// Examples intentionally print CLI output for demonstration purposes.
// ignore_for_file: avoid_print

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_test_matchers/solana_kit_test_matchers.dart';

void main() {
  const a = Address('11111111111111111111111111111111');
  const b = Address('11111111111111111111111111111111');

  final validState = <Object?, Object?>{};
  final equalsState = <Object?, Object?>{};

  final isValid = isValidSolanaAddress.matches(a, validState);
  final isEqual = equalsAddress(b).matches(a, equalsState);

  print('isValidSolanaAddress: $isValid');
  print('equalsAddress: $isEqual');
}
