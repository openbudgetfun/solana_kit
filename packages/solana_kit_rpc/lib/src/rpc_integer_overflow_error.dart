import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_rpc_transformers/solana_kit_rpc_transformers.dart';

/// Creates a [SolanaError] describing an integer overflow in an RPC request.
///
/// The error includes human-readable context about which argument overflowed
/// and where in the parameter tree the value was found.
///
/// - [methodName] is the name of the RPC method being called.
/// - [keyPath] is the path to the overflowing value in the parameter tree.
/// - [value] is the [BigInt] value that exceeded the safe integer range.
SolanaError createSolanaJsonRpcIntegerOverflowError(
  String methodName,
  KeyPath keyPath,
  BigInt value,
) {
  var argumentLabel = '';
  if (keyPath.isNotEmpty && keyPath[0] is int) {
    final argPosition = (keyPath[0] as int) + 1;
    final lastDigit = argPosition % 10;
    final lastTwoDigits = argPosition % 100;
    if (lastDigit == 1 && lastTwoDigits != 11) {
      argumentLabel = '${argPosition}st';
    } else if (lastDigit == 2 && lastTwoDigits != 12) {
      argumentLabel = '${argPosition}nd';
    } else if (lastDigit == 3 && lastTwoDigits != 13) {
      argumentLabel = '${argPosition}rd';
    } else {
      argumentLabel = '${argPosition}th';
    }
  } else if (keyPath.isNotEmpty) {
    argumentLabel = '`${keyPath[0]}`';
  }

  String? path;
  if (keyPath.length > 1) {
    path = keyPath
        .skip(1)
        .map(
          (pathPart) => pathPart is int ? '[$pathPart]' : pathPart.toString(),
        )
        .join('.');
  }

  final optionalPathLabel = path != null ? ' at path `$path`' : '';

  return SolanaError(SolanaErrorCode.rpcIntegerOverflow, {
    'argumentLabel': argumentLabel,
    'keyPath': keyPath,
    'methodName': methodName,
    'optionalPathLabel': optionalPathLabel,
    'value': value,
    if (path != null) 'path': path,
  });
}
