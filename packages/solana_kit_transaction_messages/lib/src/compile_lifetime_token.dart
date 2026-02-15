import 'package:solana_kit_transaction_messages/src/lifetime.dart';

/// Extracts the lifetime token (blockhash or nonce value) from the lifetime
/// constraint.
String getCompiledLifetimeToken(LifetimeConstraint lifetimeConstraint) {
  return switch (lifetimeConstraint) {
    BlockhashLifetimeConstraint(:final blockhash) => blockhash,
    DurableNonceLifetimeConstraint(:final nonce) => nonce,
  };
}
