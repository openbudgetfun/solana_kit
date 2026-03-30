/// Structured error types and error-code utilities for the Solana Kit Dart
/// SDK.
///
/// Exports `SolanaError`, numeric error codes, error domains, message
/// formatting helpers, and Solana runtime/RPC error conversion utilities.
///
/// <!-- {=errorDomainHelpersSection} -->
///
/// ### Typed Error Domains
///
/// `solana_kit_errors` includes domain helpers layered over numeric error codes.
/// Use them to route error handling without hardcoding code ranges throughout your
/// application.
///
/// ```dart
/// import 'package:solana_kit_errors/solana_kit_errors.dart';
///
/// void handleSolanaFailure(SolanaError error) {
///   if (error.isInDomain(SolanaErrorDomain.rpc)) {
///     print('RPC failure: $error');
///     return;
///   }
///
///   if (error.isInDomain(SolanaErrorDomain.transaction)) {
///     print('Transaction failure: $error');
///     return;
///   }
///
///   print('Unhandled Solana error: $error');
/// }
/// ```
///
/// This keeps your error-routing logic readable while still preserving the exact
/// numeric code and context payload when you need lower-level diagnostics.
///
/// <!-- {/errorDomainHelpersSection} -->
///
/// <!-- {=securityNoteCalloutSection|replace:"SECURITY_GUIDANCE_TOKEN":"Attach small, structured, non-sensitive context to `SolanaError` values so service boundaries can classify failures without parsing strings."|replace:"SECURITY_AVOIDANCE_TOKEN":"Avoid logging private keys, auth tokens, wallet session payloads, or full structured error contexts in production logs."} -->
///
/// > **Security note**
/// >
/// > Attach small, structured, non-sensitive context to `SolanaError` values so service boundaries can classify failures without parsing strings.
/// >
/// > Avoid logging private keys, auth tokens, wallet session payloads, or full structured error contexts in production logs.
///
/// <!-- {/securityNoteCalloutSection} -->
library;

export 'src/codes.dart';
export 'src/context.dart';
export 'src/error.dart';
export 'src/error_domain.dart';
export 'src/error_helpers.dart';
export 'src/instruction_error.dart';
export 'src/json_rpc_error.dart';
export 'src/message_formatter.dart';
export 'src/messages.dart';
export 'src/rpc_enum_errors.dart';
export 'src/simulation_errors.dart';
export 'src/transaction_error.dart';
