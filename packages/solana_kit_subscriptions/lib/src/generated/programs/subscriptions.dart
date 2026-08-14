// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

import '../instructions/instructions.dart';

/// The address of the Subscriptions program.
const subscriptionsProgramAddress = Address(
  'De1egAFMkMWZSN5rYXRj9CAdheBamobVNubTsi9avR44',
);

/// Known accounts for the Subscriptions program.
enum SubscriptionsAccount {
  fixedDelegation,
  plan,
  recurringDelegation,
  subscriptionAuthority,
  subscriptionDelegation,
  eventAuthority,
}

/// Known instructions for the Subscriptions program.
enum SubscriptionsInstruction {
  initSubscriptionAuthority,
  createFixedDelegation,
  createRecurringDelegation,
  revokeDelegation,
  transferFixed,
  transferRecurring,
  closeSubscriptionAuthority,
  createPlan,
  updatePlan,
  deletePlan,
  transferSubscription,
  subscribe,
  cancelSubscription,
  resumeSubscription,
  revokeSubscriptionAuthority,
  revokeAbandonedDelegation,
  revokeAbandonedSubscription,
  cancelSubscriptionNow,
}

/// Identifies the type of a Subscriptions instruction.
SubscriptionsInstruction identifySubscriptionsInstruction(
  Uint8List data,
) {
  if (containsBytes(data, getU8Encoder().encode(0), 0)) {
    return SubscriptionsInstruction.initSubscriptionAuthority;
  }
  if (containsBytes(data, getU8Encoder().encode(1), 0)) {
    return SubscriptionsInstruction.createFixedDelegation;
  }
  if (containsBytes(data, getU8Encoder().encode(2), 0)) {
    return SubscriptionsInstruction.createRecurringDelegation;
  }
  if (containsBytes(data, getU8Encoder().encode(3), 0)) {
    return SubscriptionsInstruction.revokeDelegation;
  }
  if (containsBytes(data, getU8Encoder().encode(4), 0)) {
    return SubscriptionsInstruction.transferFixed;
  }
  if (containsBytes(data, getU8Encoder().encode(5), 0)) {
    return SubscriptionsInstruction.transferRecurring;
  }
  if (containsBytes(data, getU8Encoder().encode(6), 0)) {
    return SubscriptionsInstruction.closeSubscriptionAuthority;
  }
  if (containsBytes(data, getU8Encoder().encode(7), 0)) {
    return SubscriptionsInstruction.createPlan;
  }
  if (containsBytes(data, getU8Encoder().encode(8), 0)) {
    return SubscriptionsInstruction.updatePlan;
  }
  if (containsBytes(data, getU8Encoder().encode(9), 0)) {
    return SubscriptionsInstruction.deletePlan;
  }
  if (containsBytes(data, getU8Encoder().encode(10), 0)) {
    return SubscriptionsInstruction.transferSubscription;
  }
  if (containsBytes(data, getU8Encoder().encode(11), 0)) {
    return SubscriptionsInstruction.subscribe;
  }
  if (containsBytes(data, getU8Encoder().encode(12), 0)) {
    return SubscriptionsInstruction.cancelSubscription;
  }
  if (containsBytes(data, getU8Encoder().encode(13), 0)) {
    return SubscriptionsInstruction.resumeSubscription;
  }
  if (containsBytes(data, getU8Encoder().encode(14), 0)) {
    return SubscriptionsInstruction.revokeSubscriptionAuthority;
  }
  if (containsBytes(data, getU8Encoder().encode(15), 0)) {
    return SubscriptionsInstruction.revokeAbandonedDelegation;
  }
  if (containsBytes(data, getU8Encoder().encode(16), 0)) {
    return SubscriptionsInstruction.revokeAbandonedSubscription;
  }
  if (containsBytes(data, getU8Encoder().encode(17), 0)) {
    return SubscriptionsInstruction.cancelSubscriptionNow;
  }

  throw SolanaError(
    SolanaErrorCode.programClientsFailedToIdentifyInstruction,
    {
      'instructionData': data,
      'programName': 'subscriptions',
    },
  );
}

/// A parsed instruction from the Subscriptions program.
sealed class ParsedSubscriptionsInstruction {
  const ParsedSubscriptionsInstruction(this.instructionType);

  final SubscriptionsInstruction instructionType;
}

/// A parsed InitSubscriptionAuthority instruction.
final class ParsedInitSubscriptionAuthority
    extends ParsedSubscriptionsInstruction {
  const ParsedInitSubscriptionAuthority({required this.data})
    : super(SubscriptionsInstruction.initSubscriptionAuthority);

  final InitSubscriptionAuthorityInstructionData data;
}

/// A parsed CreateFixedDelegation instruction.
final class ParsedCreateFixedDelegation extends ParsedSubscriptionsInstruction {
  const ParsedCreateFixedDelegation({required this.data})
    : super(SubscriptionsInstruction.createFixedDelegation);

  final CreateFixedDelegationInstructionData data;
}

/// A parsed CreateRecurringDelegation instruction.
final class ParsedCreateRecurringDelegation
    extends ParsedSubscriptionsInstruction {
  const ParsedCreateRecurringDelegation({required this.data})
    : super(SubscriptionsInstruction.createRecurringDelegation);

  final CreateRecurringDelegationInstructionData data;
}

/// A parsed RevokeDelegation instruction.
final class ParsedRevokeDelegation extends ParsedSubscriptionsInstruction {
  const ParsedRevokeDelegation({required this.data})
    : super(SubscriptionsInstruction.revokeDelegation);

  final RevokeDelegationInstructionData data;
}

/// A parsed TransferFixed instruction.
final class ParsedTransferFixed extends ParsedSubscriptionsInstruction {
  const ParsedTransferFixed({required this.data})
    : super(SubscriptionsInstruction.transferFixed);

  final TransferFixedInstructionData data;
}

/// A parsed TransferRecurring instruction.
final class ParsedTransferRecurring extends ParsedSubscriptionsInstruction {
  const ParsedTransferRecurring({required this.data})
    : super(SubscriptionsInstruction.transferRecurring);

  final TransferRecurringInstructionData data;
}

/// A parsed CloseSubscriptionAuthority instruction.
final class ParsedCloseSubscriptionAuthority
    extends ParsedSubscriptionsInstruction {
  const ParsedCloseSubscriptionAuthority({required this.data})
    : super(SubscriptionsInstruction.closeSubscriptionAuthority);

  final CloseSubscriptionAuthorityInstructionData data;
}

/// A parsed CreatePlan instruction.
final class ParsedCreatePlan extends ParsedSubscriptionsInstruction {
  const ParsedCreatePlan({required this.data})
    : super(SubscriptionsInstruction.createPlan);

  final CreatePlanInstructionData data;
}

/// A parsed UpdatePlan instruction.
final class ParsedUpdatePlan extends ParsedSubscriptionsInstruction {
  const ParsedUpdatePlan({required this.data})
    : super(SubscriptionsInstruction.updatePlan);

  final UpdatePlanInstructionData data;
}

/// A parsed DeletePlan instruction.
final class ParsedDeletePlan extends ParsedSubscriptionsInstruction {
  const ParsedDeletePlan({required this.data})
    : super(SubscriptionsInstruction.deletePlan);

  final DeletePlanInstructionData data;
}

/// A parsed TransferSubscription instruction.
final class ParsedTransferSubscription extends ParsedSubscriptionsInstruction {
  const ParsedTransferSubscription({required this.data})
    : super(SubscriptionsInstruction.transferSubscription);

  final TransferSubscriptionInstructionData data;
}

/// A parsed Subscribe instruction.
final class ParsedSubscribe extends ParsedSubscriptionsInstruction {
  const ParsedSubscribe({required this.data})
    : super(SubscriptionsInstruction.subscribe);

  final SubscribeInstructionData data;
}

/// A parsed CancelSubscription instruction.
final class ParsedCancelSubscription extends ParsedSubscriptionsInstruction {
  const ParsedCancelSubscription({required this.data})
    : super(SubscriptionsInstruction.cancelSubscription);

  final CancelSubscriptionInstructionData data;
}

/// A parsed ResumeSubscription instruction.
final class ParsedResumeSubscription extends ParsedSubscriptionsInstruction {
  const ParsedResumeSubscription({required this.data})
    : super(SubscriptionsInstruction.resumeSubscription);

  final ResumeSubscriptionInstructionData data;
}

/// A parsed RevokeSubscriptionAuthority instruction.
final class ParsedRevokeSubscriptionAuthority
    extends ParsedSubscriptionsInstruction {
  const ParsedRevokeSubscriptionAuthority({required this.data})
    : super(SubscriptionsInstruction.revokeSubscriptionAuthority);

  final RevokeSubscriptionAuthorityInstructionData data;
}

/// A parsed RevokeAbandonedDelegation instruction.
final class ParsedRevokeAbandonedDelegation
    extends ParsedSubscriptionsInstruction {
  const ParsedRevokeAbandonedDelegation({required this.data})
    : super(SubscriptionsInstruction.revokeAbandonedDelegation);

  final RevokeAbandonedDelegationInstructionData data;
}

/// A parsed RevokeAbandonedSubscription instruction.
final class ParsedRevokeAbandonedSubscription
    extends ParsedSubscriptionsInstruction {
  const ParsedRevokeAbandonedSubscription({required this.data})
    : super(SubscriptionsInstruction.revokeAbandonedSubscription);

  final RevokeAbandonedSubscriptionInstructionData data;
}

/// A parsed CancelSubscriptionNow instruction.
final class ParsedCancelSubscriptionNow extends ParsedSubscriptionsInstruction {
  const ParsedCancelSubscriptionNow({required this.data})
    : super(SubscriptionsInstruction.cancelSubscriptionNow);

  final CancelSubscriptionNowInstructionData data;
}

/// Parses a Subscriptions instruction.
ParsedSubscriptionsInstruction parseSubscriptionsInstruction(
  Instruction instruction,
) {
  return switch (identifySubscriptionsInstruction(
    instruction.data ?? Uint8List(0),
  )) {
    SubscriptionsInstruction.initSubscriptionAuthority =>
      ParsedInitSubscriptionAuthority(
        data: parseInitSubscriptionAuthorityInstruction(instruction),
      ),
    SubscriptionsInstruction.createFixedDelegation =>
      ParsedCreateFixedDelegation(
        data: parseCreateFixedDelegationInstruction(instruction),
      ),
    SubscriptionsInstruction.createRecurringDelegation =>
      ParsedCreateRecurringDelegation(
        data: parseCreateRecurringDelegationInstruction(instruction),
      ),
    SubscriptionsInstruction.revokeDelegation => ParsedRevokeDelegation(
      data: parseRevokeDelegationInstruction(instruction),
    ),
    SubscriptionsInstruction.transferFixed => ParsedTransferFixed(
      data: parseTransferFixedInstruction(instruction),
    ),
    SubscriptionsInstruction.transferRecurring => ParsedTransferRecurring(
      data: parseTransferRecurringInstruction(instruction),
    ),
    SubscriptionsInstruction.closeSubscriptionAuthority =>
      ParsedCloseSubscriptionAuthority(
        data: parseCloseSubscriptionAuthorityInstruction(instruction),
      ),
    SubscriptionsInstruction.createPlan => ParsedCreatePlan(
      data: parseCreatePlanInstruction(instruction),
    ),
    SubscriptionsInstruction.updatePlan => ParsedUpdatePlan(
      data: parseUpdatePlanInstruction(instruction),
    ),
    SubscriptionsInstruction.deletePlan => ParsedDeletePlan(
      data: parseDeletePlanInstruction(instruction),
    ),
    SubscriptionsInstruction.transferSubscription => ParsedTransferSubscription(
      data: parseTransferSubscriptionInstruction(instruction),
    ),
    SubscriptionsInstruction.subscribe => ParsedSubscribe(
      data: parseSubscribeInstruction(instruction),
    ),
    SubscriptionsInstruction.cancelSubscription => ParsedCancelSubscription(
      data: parseCancelSubscriptionInstruction(instruction),
    ),
    SubscriptionsInstruction.resumeSubscription => ParsedResumeSubscription(
      data: parseResumeSubscriptionInstruction(instruction),
    ),
    SubscriptionsInstruction.revokeSubscriptionAuthority =>
      ParsedRevokeSubscriptionAuthority(
        data: parseRevokeSubscriptionAuthorityInstruction(instruction),
      ),
    SubscriptionsInstruction.revokeAbandonedDelegation =>
      ParsedRevokeAbandonedDelegation(
        data: parseRevokeAbandonedDelegationInstruction(instruction),
      ),
    SubscriptionsInstruction.revokeAbandonedSubscription =>
      ParsedRevokeAbandonedSubscription(
        data: parseRevokeAbandonedSubscriptionInstruction(instruction),
      ),
    SubscriptionsInstruction.cancelSubscriptionNow =>
      ParsedCancelSubscriptionNow(
        data: parseCancelSubscriptionNowInstruction(instruction),
      ),
  };
}
