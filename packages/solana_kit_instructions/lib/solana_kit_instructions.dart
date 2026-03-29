/// Instruction primitives for the Solana Kit Dart SDK.
///
/// Use this library to model program invocations with explicit account
/// metadata roles and binary instruction payloads.
///
/// <!-- {=docsInstructionPrimitivesSection} -->
///
/// ## Model an instruction
///
/// Use `Instruction` plus `AccountMeta` when you need to describe a program call
/// before building a full transaction message around it.
///
/// ```dart
/// import 'dart:typed_data';
///
/// import 'package:solana_kit_addresses/solana_kit_addresses.dart';
/// import 'package:solana_kit_instructions/solana_kit_instructions.dart';
///
/// void main() {
///   const programAddress = Address('11111111111111111111111111111111');
///   const signerAddress = Address('11111111111111111111111111111111');
///
///   final instruction = Instruction(
///     programAddress: programAddress,
///     accounts: const [
///       AccountMeta(
///         address: signerAddress,
///         role: AccountRole.writableSigner,
///       ),
///     ],
///     data: Uint8List(0),
///   );
///
///   print(isInstructionForProgram(instruction, programAddress));
/// }
/// ```
///
/// Keeping instruction construction explicit makes it easier to reason about
/// required signer privileges, writable accounts, and serialized program data.
///
/// <!-- {/docsInstructionPrimitivesSection} -->
library;

export 'src/accounts.dart';
export 'src/instruction.dart';
export 'src/roles.dart';
