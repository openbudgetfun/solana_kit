// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'package:solana_kit_addresses/solana_kit_addresses.dart';

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
}
