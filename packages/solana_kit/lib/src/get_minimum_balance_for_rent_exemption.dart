import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

/// On-chain rent parameters sourced from the Solana runtime.
///
/// See: https://github.com/anza-xyz/solana-sdk/blob/c07f692/rent/src/lib.rs#L93-L97
const _accountStorageOverhead = 128;
const _defaultExemptionThreshold = 2;
const _defaultLamportsPerByteYear = 3480;

/// Calculates the minimum lamports required to make an account rent exempt
/// for a given data size, without performing an RPC call.
///
/// Values are sourced from the on-chain rent parameters in the Solana runtime.
///
/// Note that this logic may change, or be incorrect depending on the cluster
/// you are connected to. You can always use the RPC method
/// `getMinimumBalanceForRentExemption` to get the current value.
///
/// [space] is the number of bytes of account data.
Lamports getMinimumBalanceForRentExemption(int space) {
  final requiredLamports =
      (_accountStorageOverhead + space) *
      _defaultLamportsPerByteYear *
      _defaultExemptionThreshold;
  return Lamports(BigInt.from(requiredLamports));
}
