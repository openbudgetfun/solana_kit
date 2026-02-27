// Examples intentionally print CLI output for demonstration purposes.
// ignore_for_file: avoid_print

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_program_client_core/solana_kit_program_client_core.dart';

void main() {
  const account = Address('11111111111111111111111111111111');

  final requiredValue = getNonNullResolvedInstructionInput('authority', account);
  final resolvedAddress = getAddressFromResolvedInstructionAccount(
    'authority',
    requiredValue,
  );

  print('Resolved instruction account: ${resolvedAddress.value}');
}
