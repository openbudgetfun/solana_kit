// Examples intentionally print CLI output for demonstration purposes.
// ignore_for_file: avoid_print

import 'package:solana_kit_rpc_spec_types/solana_kit_rpc_spec_types.dart';
import 'package:solana_kit_rpc_transformers/solana_kit_rpc_transformers.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

void main() {
  final transformer = getDefaultRequestTransformerForSolanaRpc(
    const RequestTransformerConfig(defaultCommitment: Commitment.confirmed),
  );

  final transformed = transformer(
    RpcRequest<Object?>(
      methodName: 'getBalance',
      params: <Object?>[
        '11111111111111111111111111111111',
        <String, Object?>{'minContextSlot': BigInt.from(123)},
      ],
    ),
  );

  print('Transformed params: ${transformed.params}');
}
