import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_helius/src/internal/json_rpc_client.dart';
import 'package:solana_kit_helius/src/types/smart_transaction_types.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

/// Simulates the transaction to estimate compute units consumed.
///
/// Calls the `simulateTransaction` RPC method with `replaceRecentBlockhash`
/// and `sigVerify` disabled to get a compute unit estimate without requiring
/// valid signatures.
///
/// The estimate is only meaningful when the node reports `unitsConsumed`. A
/// missing value is an error rather than a default: the Helius API rejects a
/// zero compute budget, so inventing a number would silently size the
/// transaction for work the simulation never confirmed.
Future<ComputeUnitsEstimate> txGetComputeUnits(
  JsonRpcClient rpcClient,
  CreateSmartTransactionInput input,
) async {
  final result = await rpcClient.call('simulateTransaction', [
    serializeSmartTransactionInput(input),
    {'replaceRecentBlockhash': true, 'sigVerify': false},
  ]);
  final response = result! as Map<String, Object?>;
  final value = response['value']! as Map<String, Object?>;

  // A transaction-level failure is reported in `err`; surface it rather than
  // reporting units from a simulation that did not succeed.
  final error = value['err'];
  if (error != null) {
    throw SolanaError(
      SolanaErrorCode.heliusTransactionSimulationFailed,
      {
        'message':
            'simulateTransaction failed while estimating compute units: '
            '$error',
      },
    );
  }

  final units = switch (value['unitsConsumed']) {
    final int units => units,
    final BigInt units => units.toInt(),
    _ => null,
  };
  if (units == null) {
    throw StateError(
      'simulateTransaction did not report unitsConsumed, so the compute unit '
      'limit cannot be estimated.',
    );
  }

  return ComputeUnitsEstimate(units: units);
}

/// Renders a [CreateSmartTransactionInput] as the JSON shape the node accepts.
///
/// Instructions may be either [Instruction] objects or pre-serialized maps, so
/// both are normalized here. Without this a real [Instruction] fails at
/// encoding time, because the JSON encoder has no way to render it.
Map<String, Object?> serializeSmartTransactionInput(
  CreateSmartTransactionInput input,
) {
  return {
    'instructions': [
      for (final instruction in input.instructions)
        serializeSmartTransactionInstruction(instruction),
    ],
    if (input.signers != null) 'signers': input.signers,
    if (input.feePayer != null) 'feePayer': input.feePayer,
    if (input.computeUnitLimit != null)
      'computeUnitLimit': input.computeUnitLimit,
    if (input.computeUnitPrice != null)
      'computeUnitPrice': input.computeUnitPrice,
    if (input.lookupTableAddresses != null)
      'lookupTableAddresses': input.lookupTableAddresses,
  };
}

/// Renders a single instruction as JSON.
///
/// An [Instruction] becomes `{programAddress, accounts, data}` with its account
/// roles flattened and its data base58-encoded. Anything else is returned
/// unchanged so pre-serialized maps pass through untouched.
Object? serializeSmartTransactionInstruction(Object? instruction) {
  if (instruction is! Instruction) return instruction;

  final accounts = instruction.accounts;
  final data = instruction.data;

  return <String, Object?>{
    'programAddress': instruction.programAddress.value,
    if (accounts != null)
      'accounts': [
        for (final account in accounts)
          <String, Object?>{
            'address': account.address.value,
            'role': _roleName(account.role),
            if (account is AccountLookupMeta)
              'lookupTableAddress': account.lookupTableAddress,
          },
      ],
    if (data != null) 'data': getBase58Decoder().decode(data),
  };
}

/// The wire name for an account role.
String _roleName(AccountRole role) => switch (role) {
  AccountRole.readonly => 'readonly',
  AccountRole.writable => 'writable',
  AccountRole.readonlySigner => 'readonlySigner',
  AccountRole.writableSigner => 'writableSigner',
};
