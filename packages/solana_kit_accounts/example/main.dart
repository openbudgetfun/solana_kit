// Examples intentionally print CLI output for demonstration purposes.
// ignore_for_file: avoid_print

import 'dart:typed_data';

import 'package:solana_kit_accounts/solana_kit_accounts.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

void main() {
  final baseAccount = BaseAccount(
    executable: false,
    lamports: Lamports(BigInt.from(1_000_000)),
    programAddress: const Address('11111111111111111111111111111111'),
    space: BigInt.from(16),
  );

  final account = Account<Uint8List>(
    address: const Address('11111111111111111111111111111111'),
    data: Uint8List.fromList([1, 2, 3, 4]),
    executable: baseAccount.executable,
    lamports: baseAccount.lamports,
    programAddress: baseAccount.programAddress,
    space: BigInt.from(4),
  );

  print('Base account space: ${baseAccount.space}');
  print('Decoded account byte length: ${account.data.length}');
}
