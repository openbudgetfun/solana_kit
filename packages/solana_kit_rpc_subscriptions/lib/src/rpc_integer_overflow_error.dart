import 'package:solana_kit_errors/solana_kit_errors.dart';

/// Creates a [SolanaError] for an integer overflow in a JSON RPC response.
///
/// The error includes the method name, the key path to the overflowing value,
/// and the value itself.
///
/// The [keyPath] list describes the path to the value within the RPC response.
/// The first element is either:
/// - An [int] representing the argument position (0-indexed), or
/// - A [String] representing a named argument.
///
/// Remaining elements describe the path within that argument.
SolanaError createSolanaJsonRpcIntegerOverflowError(
  String methodName,
  List<Object> keyPath,
  BigInt value,
) {
  String argumentLabel;

  if (keyPath[0] is int) {
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
  } else {
    argumentLabel = '`${keyPath[0]}`';
  }

  final String? path;
  if (keyPath.length > 1) {
    path = keyPath
        .skip(1)
        .map(
          (pathPart) => pathPart is int ? '[$pathPart]' : pathPart.toString(),
        )
        .join('.');
  } else {
    path = null;
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
