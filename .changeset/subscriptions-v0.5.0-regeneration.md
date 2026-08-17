---
"solana_kit_subscriptions": minor
---

# Regenerate solana_kit_subscriptions from the v0.5.0 IDL

Regenerated `solana_kit_subscriptions` from the `solana-foundation/subscriptions` `ts-client-v0.5.0` Codama IDL, bringing the generated Dart surface in sync with the pinned reference (`ts-client-v0.4.0-rc.2` → `ts-client-v0.5.0`).

Notable additions and changes:

- New `cancelSubscriptionNow` instruction (discriminator 17) with `CancelSubscriptionNowData` (`expectedCurrentPeriodStartTs`).
- `resumeSubscription` now takes a required `resumeData: ResumeData` struct (`expectedExpiresAtTs`).
- `UpdatePlanData` gained four required fields: `expectedCreatedAt`, `expectedEndTs`, `expectedPullers`, and `expectedMetadataUri`.
- `getCreatePlanInstruction` accepts an optional `payer` account.
- Generated program-level instruction identification and parsing helpers (`SubscriptionsInstruction` enum, `identifySubscriptionsInstruction`, `parseSubscriptionsInstruction`) and new error codes.
