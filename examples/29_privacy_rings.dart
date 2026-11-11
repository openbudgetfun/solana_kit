// ignore_for_file: avoid_print
/// Example 29: Build a Privacy Rings SOL deposit without a network call.
///
/// The deposit instruction does not ask the remote prover for a proof. The
/// owner signs the Solana transaction that carries it. `recipientOwnerHash`
/// is the Poseidon owner hash from the recipient's shielded address; this
/// example uses 32 zero bytes so it can run offline. A real deposit uses
/// the recipient's hash.
///
/// Run:
///   dart examples/29_privacy_rings.dart
library;

import 'dart:typed_data';

import 'package:solana_kit_privacy_rings/solana_kit_privacy_rings.dart';

Future<void> main() async {
  final endpoints = resolvePrivacyRingsEndpoints(
    solanaRpcUrl: Uri.parse(
      'https://devnet.helius-rpc.com/?api-key=YOUR_API_KEY',
    ),
  );
  print('Indexer: ${redactUri(endpoints.indexer)}');
  print('Prover:  ${redactUri(endpoints.prover)}');

  final deposit = await depositInstruction(
    tree: stateMerkleTree,
    depositor: userRegistryProgramId,
    deposits: [
      AssetDeposit(
        asset: const SolDepositAsset(),
        viewTag: Uint8List(32),
        recipientOwnerHash: Uint8List(32),
        amount: BigInt.from(1000000),
      ),
    ],
  );

  print('Program: ${deposit.programAddress}');
  print('Accounts: ${deposit.accounts!.length}');
  print('First byte (deposit tag): ${deposit.data!.first}');
}
