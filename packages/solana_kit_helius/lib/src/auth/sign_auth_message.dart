import 'package:solana_kit_helius/src/types/auth_types.dart';

/// Signs an authentication message with the given secret key.
///
/// This helper intentionally throws until a real Ed25519 implementation is
/// wired in. Returning placeholder bytes would be forgeable and unsafe for
/// downstream authentication flows.
Future<SignAuthMessageResponse> authSignAuthMessage(
  SignAuthMessageRequest _,
) async {
  throw UnsupportedError(
    'authSignAuthMessage is not implemented; use wallet-based signing or '
    'provide a verified Ed25519 implementation before using Helius auth.',
  );
}
