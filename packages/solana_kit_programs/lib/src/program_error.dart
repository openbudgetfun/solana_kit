import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';

/// A minimal representation of a transaction message containing instructions
/// indexed by their position.
///
/// This is used by [isProgramError] to look up the instruction at a given index
/// and determine its program address.
class TransactionMessageInput {
  /// Creates a [TransactionMessageInput] with the given [instructions] map.
  const TransactionMessageInput({required this.instructions});

  /// A map of instruction indices to their corresponding [InstructionInput].
  final Map<int, InstructionInput> instructions;
}

/// A minimal representation of an instruction containing only its program
/// address.
///
/// This is used by [isProgramError] to check whether an instruction belongs to
/// a specific program.
class InstructionInput {
  /// Creates an [InstructionInput] with the given [programAddress].
  const InstructionInput({required this.programAddress});

  /// The address of the program that this instruction targets.
  final Address programAddress;
}

/// Identifies whether an [error] -- typically caused by a transaction failure
/// -- is a custom program error from the provided [programAddress].
///
/// Since the RPC response only provides the index of the failed instruction,
/// the [transactionMessage] is required to determine its program address.
///
/// When [code] is provided, the function also checks that the custom program
/// error code matches the given value.
///
/// Returns `true` if:
/// 1. The [error] is a [SolanaError] with code
///    [SolanaErrorCode.instructionErrorCustom].
/// 2. The instruction at the error's index in [transactionMessage] matches
///    [programAddress].
/// 3. If [code] is provided, the custom error code matches.
///
/// ```dart
/// try {
///   // Send and confirm your transaction.
/// } catch (error) {
///   if (isProgramError(error, transactionMessage, myProgramAddress, 42)) {
///     // Handle custom program error 42 from this program.
///   } else if (isProgramError(error, transactionMessage, myProgramAddress)) {
///     // Handle all other custom program errors from this program.
///   } else {
///     throw error;
///   }
/// }
/// ```
bool isProgramError(
  Object? error,
  TransactionMessageInput transactionMessage,
  Address programAddress, [
  int? code,
]) {
  if (!isSolanaError(error, SolanaErrorCode.instructionErrorCustom)) {
    return false;
  }

  final context = (error! as SolanaError).context;
  final index = context['index'];

  if (index is! int) {
    return false;
  }

  final instruction = transactionMessage.instructions[index];

  if (instruction == null || instruction.programAddress != programAddress) {
    return false;
  }

  return code == null || context['code'] == code;
}
