import 'package:http/http.dart' as http;
import 'package:solana_kit_rpc/src/rpc_default_config.dart';
import 'package:solana_kit_rpc/src/rpc_transport.dart';
import 'package:solana_kit_rpc_api/solana_kit_rpc_api.dart';
import 'package:solana_kit_rpc_spec/solana_kit_rpc_spec.dart';

/// Creates an [Rpc] instance that exposes the Solana JSON RPC API given a
/// cluster URL and some optional transport config.
///
/// See [createDefaultRpcTransport] for the shape of the transport config.
///
/// ```dart
/// final rpc = createSolanaRpc(url: 'https://api.mainnet-beta.solana.com');
/// final slot = await rpc.request('getSlot').send();
/// ```
Rpc createSolanaRpc({
  required String url,
  Map<String, String>? headers,
  http.Client? client,
}) {
  return createSolanaRpcFromTransport(
    createDefaultRpcTransport(url: url, headers: headers, client: client),
  );
}

/// Creates an [Rpc] instance that exposes the Solana JSON RPC API given the
/// supplied [RpcTransport].
///
/// Use this when you want to provide a custom transport (e.g. for testing or
/// special networking requirements) but still want the standard Solana RPC API
/// with default transformers applied.
Rpc createSolanaRpcFromTransport(RpcTransport transport) {
  return createRpc(
    RpcConfig(
      api: createSolanaRpcApiAdapter(defaultRpcConfig),
      transport: transport,
    ),
  );
}
