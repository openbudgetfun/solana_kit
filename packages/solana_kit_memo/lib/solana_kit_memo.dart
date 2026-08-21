/// Memo program client for the Solana Kit Dart SDK.
///
/// Provides codecs and an ergonomic instruction builder for the Memo program,
/// which attaches arbitrary UTF-8 memo text to transactions.
///
/// ## Quick start
///
/// ```dart
/// import 'package:solana_kit_memo/solana_kit_memo.dart';
///
/// final instruction = getAddMemoInstruction(memo: 'Hello from Solana Kit');
/// ```
library;

// Hide memoProgramAddress; it's already provided by
// solana_kit_address_constants to avoid duplication across the SDK.
export 'src/generated/memo.dart' hide memoProgramAddress;
