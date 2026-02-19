import 'package:solana_kit_mobile_wallet_adapter_protocol/src/types.dart';

/// Creates a Sign In With Solana (SIWS) message string following the
/// EIP-4361/SIWS specification format.
///
/// The message format follows the template:
/// ```text
/// ${domain} wants you to sign in with your Solana account:
/// ${address}
///
/// ${statement}
///
/// URI: ${uri}
/// Version: ${version}
/// Chain ID: ${chainId}
/// Nonce: ${nonce}
/// Issued At: ${issuedAt}
/// Expiration Time: ${expirationTime}
/// Not Before: ${notBefore}
/// Request ID: ${requestId}
/// Resources:
/// - ${resources[0]}
/// - ${resources[1]}
/// ...
/// ```
String createSiwsMessage(SignInPayload payload) {
  final buffer = StringBuffer()

    // Header
    ..writeln(
      '${payload.domain ?? ''} wants you to sign in with your Solana account:',
    )
    ..writeln(payload.address ?? '');

  // Statement (optional, separated by blank line)
  if (payload.statement != null) {
    buffer
      ..writeln()
      ..writeln(payload.statement);
  }

  // Fields (each separated by blank line from header+statement)
  buffer.writeln();

  if (payload.uri != null) {
    buffer.writeln('URI: ${payload.uri}');
  }
  if (payload.version != null) {
    buffer.writeln('Version: ${payload.version}');
  }
  if (payload.chainId != null) {
    buffer.writeln('Chain ID: ${payload.chainId}');
  }
  if (payload.nonce != null) {
    buffer.writeln('Nonce: ${payload.nonce}');
  }
  if (payload.issuedAt != null) {
    buffer.writeln('Issued At: ${payload.issuedAt}');
  }
  if (payload.expirationTime != null) {
    buffer.writeln('Expiration Time: ${payload.expirationTime}');
  }
  if (payload.notBefore != null) {
    buffer.writeln('Not Before: ${payload.notBefore}');
  }
  if (payload.requestId != null) {
    buffer.writeln('Request ID: ${payload.requestId}');
  }
  if (payload.resources != null && payload.resources!.isNotEmpty) {
    buffer.writeln('Resources:');
    for (final resource in payload.resources!) {
      buffer.writeln('- $resource');
    }
  }

  // Trim trailing newline.
  return buffer.toString().trimRight();
}
