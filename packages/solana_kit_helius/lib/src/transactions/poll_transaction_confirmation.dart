import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_helius/src/internal/json_rpc_client.dart';
import 'package:solana_kit_helius/src/types/smart_transaction_types.dart';

/// Polls `getSignatureStatuses` in a loop until the transaction reaches
/// the desired commitment level or the timeout is exceeded.
///
/// Defaults to a 60-second timeout with a 5-second polling interval and
/// `confirmed` commitment level.
///
/// Throws a [SolanaError] with
/// [SolanaErrorCode.heliusTransactionConfirmationTimeout] if the timeout
/// is reached before confirmation.
Future<SmartTransactionResult> txPollTransactionConfirmation(
  JsonRpcClient rpcClient,
  PollTransactionConfirmationRequest request,
) async {
  final timeoutMs = request.timeoutMs ?? 60000;
  final intervalMs = request.intervalMs ?? 5000;
  final commitment = request.commitment?.toJson() ?? 'confirmed';
  final stopwatch = Stopwatch()..start();

  while (stopwatch.elapsedMilliseconds < timeoutMs) {
    final result = await rpcClient.call('getSignatureStatuses', [
      [request.signature],
      {'searchTransactionHistory': true},
    ]);
    final response = result as Map<String, Object?>?;
    if (response != null) {
      final value = response['value'] as List<Object?>?;
      if (value != null && value.isNotEmpty && value[0] != null) {
        final status = value[0]! as Map<String, Object?>;
        final confirmationStatus = status['confirmationStatus'] as String?;
        if (confirmationStatus != null) {
          if (confirmationStatus == commitment ||
              confirmationStatus == 'finalized' ||
              (commitment == 'confirmed' &&
                  confirmationStatus == 'finalized')) {
            return SmartTransactionResult(
              signature: request.signature,
              confirmationStatus: confirmationStatus,
            );
          }
        }
      }
    }
    await Future<void>.delayed(Duration(milliseconds: intervalMs));
  }

  throw SolanaError(SolanaErrorCode.heliusTransactionConfirmationTimeout, {
    'timeoutMs': timeoutMs,
    'signature': request.signature,
  });
}
