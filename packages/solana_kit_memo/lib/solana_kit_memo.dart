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

export 'src/add_memo.dart';
export 'src/generated/memo.dart';
