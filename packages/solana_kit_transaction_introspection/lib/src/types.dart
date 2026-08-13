import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

/// The location of an instruction within a transaction.
sealed class InstructionTrace {
  const InstructionTrace();
}

/// The trace for a top-level instruction in the transaction message.
///
/// [index] is its position in the compiled message's instructions.
@immutable
class OuterInstructionTrace extends InstructionTrace {
  /// Creates an [OuterInstructionTrace] at the given [index].
  const OuterInstructionTrace({required this.index});

  /// The position of this instruction in the compiled message.
  final int index;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OuterInstructionTrace && index == other.index;

  @override
  int get hashCode => index;

  @override
  String toString() => 'OuterInstructionTrace(index: $index)';
}

/// The trace for an instruction emitted via cross-program invocation.
///
/// [outerIndex] is the index of the outer instruction that triggered the CPI
/// chain; [innerIndex] is the position within that outer instruction's
/// inner-instruction group.
@immutable
class InnerInstructionTrace extends InstructionTrace {
  /// Creates an [InnerInstructionTrace] for the instruction at
  /// [innerIndex] within the outer instruction at [outerIndex].
  const InnerInstructionTrace({
    required this.outerIndex,
    required this.innerIndex,
    this.stackHeight,
  });

  /// The index of the outer instruction that triggered this CPI.
  final int outerIndex;

  /// The position of this instruction within its outer instruction's group.
  final int innerIndex;

  /// The CPI depth at which this instruction was invoked, when reported by the
  /// RPC. `1` is the outer-instruction depth, `2` is the first nested CPI, and
  /// so on.
  final int? stackHeight;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InnerInstructionTrace &&
          outerIndex == other.outerIndex &&
          innerIndex == other.innerIndex &&
          stackHeight == other.stackHeight;

  @override
  int get hashCode => Object.hash(outerIndex, innerIndex, stackHeight);

  @override
  String toString() =>
      'InnerInstructionTrace(outerIndex: $outerIndex, innerIndex: $innerIndex, '
      'stackHeight: $stackHeight)';
}

/// An [Instruction] carrying its location in the transaction as a [trace].
///
/// Because a [TracedInstruction] is itself an [Instruction], it can be passed
/// directly to the auto-generated `@solana-program/*` `identifyXInstruction` /
/// `parseXInstruction` helpers and to [isInstructionForProgram] from
/// `solana_kit_instructions`.
class TracedInstruction extends Instruction {
  /// Creates a [TracedInstruction] with the given [programAddress], optional
  /// [accounts]/[data], and its [trace].
  const TracedInstruction({
    required super.programAddress,
    required this.trace,
    super.accounts,
    super.data,
  });

  /// The location of this instruction within its transaction.
  final InstructionTrace trace;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TracedInstruction &&
          programAddress == other.programAddress &&
          _accountMetasEquals(accounts, other.accounts) &&
          _uint8ListEquals(data, other.data) &&
          trace == other.trace;

  @override
  int get hashCode => Object.hash(
    programAddress,
    accounts == null ? null : Object.hashAll(accounts!),
    data == null ? null : Object.hashAll(data!),
    trace,
  );

  @override
  String toString() =>
      'TracedInstruction(programAddress: $programAddress, '
      'accounts: $accounts, data: $data, trace: $trace)';
}

bool _accountMetasEquals(List<AccountMeta>? a, List<AccountMeta>? b) {
  if (identical(a, b)) return true;
  if (a == null || b == null) return a == b;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

bool _uint8ListEquals(Uint8List? a, Uint8List? b) {
  if (identical(a, b)) return true;
  if (a == null || b == null) return a == b;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
