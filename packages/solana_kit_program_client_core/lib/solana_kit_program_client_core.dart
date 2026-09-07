/// Shared plumbing for generated program clients in the Solana Kit Dart SDK.
///
/// Provides the self-fetch account wrappers, the self plan-and-send function
/// bundles, and the instruction input resolution contract that generated
/// program clients compose their fetch, plan, and send APIs from.
library;

export 'src/instruction_input_resolution.dart';
export 'src/instructions.dart';
export 'src/self_fetch_functions.dart';
export 'src/self_plan_and_send_functions.dart';
