import 'package:solana_kit_errors/src/error.dart';

/// Configuration for mapping RPC enum errors to [SolanaError] instances.
class RpcEnumErrorConfig {
  const RpcEnumErrorConfig({
    required this.errorCodeBaseOffset,
    required this.orderedErrorNames,
    required this.getErrorContext,
  });

  /// The base error code offset. The position of the error name in
  /// [orderedErrorNames] is added to this to compute the error code.
  final int errorCodeBaseOffset;

  /// Ordered list of RPC error name strings.
  final List<String> orderedErrorNames;

  /// Callback to compute context for a given error code.
  final Map<String, Object?>? Function(
    int errorCode,
    String rpcErrorName,
    Object? rpcErrorContext,
  )
  getErrorContext;
}

/// Converts an RPC enum-style error into a [SolanaError].
///
/// RPC errors from Solana come as either a plain string (e.g. `"AccountInUse"`)
/// or as a map with a single key (e.g. `{"Custom": 42}`). This function maps
/// those to the appropriate [SolanaError] using an ordered list of error names.
SolanaError getSolanaErrorFromRpcError(
  RpcEnumErrorConfig config,
  Object rpcEnumError,
) {
  String rpcErrorName;
  Object? rpcErrorContext;

  if (rpcEnumError is String) {
    rpcErrorName = rpcEnumError;
  } else if (rpcEnumError is Map<String, Object?>) {
    rpcErrorName = rpcEnumError.keys.first;
    rpcErrorContext = rpcEnumError[rpcErrorName];
  } else {
    rpcErrorName = rpcEnumError.toString();
  }

  final codeOffset = config.orderedErrorNames.indexOf(rpcErrorName);
  final errorCode = config.errorCodeBaseOffset + codeOffset;
  final errorContext = config.getErrorContext(
    errorCode,
    rpcErrorName,
    rpcErrorContext,
  );
  return SolanaError(errorCode, errorContext);
}
