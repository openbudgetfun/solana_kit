/// Test assertion helpers for the Solana Kit Dart SDK.
///
/// Provides custom matchers for:
/// - Solana error matching by code and context
/// - Byte array comparison
/// - Address validation
/// - Transaction signature verification
library;

export 'src/address_matchers.dart';
export 'src/bytes_matchers.dart';
export 'src/canned_rpc_responses.dart';
export 'src/fake_accounts.dart';
export 'src/fake_rpc.dart';
export 'src/fake_signers.dart';
export 'src/solana_error_matchers.dart';
export 'src/test_addresses.dart';
export 'src/test_fixtures.dart';
export 'src/transaction_matchers.dart';
