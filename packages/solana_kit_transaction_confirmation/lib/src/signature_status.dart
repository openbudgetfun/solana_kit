import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

/// The status of a transaction signature.
class SignatureStatus {
  /// Creates a [SignatureStatus].
  const SignatureStatus({this.confirmationStatus, this.err});

  /// The commitment level the signature has reached.
  ///
  /// Will be `null` if the signature is not found in the status cache.
  final Commitment? confirmationStatus;

  /// The error associated with this transaction, if any.
  ///
  /// A non-null value indicates the transaction failed.
  final Object? err;
}
