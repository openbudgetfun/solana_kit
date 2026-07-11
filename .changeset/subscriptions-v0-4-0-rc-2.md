---
"solana_kit_subscriptions": minor
"codama-renderers-dart": patch
---

# Subscriptions: regenerate from ts-client-v0.4.0-rc.2

Regenerates the Subscriptions generated code from upstream IDL
`ts-client-v0.4.0-rc.2` (was `ts-client-v0.3.0`). Adds 3 new instructions:

- `revokeSubscriptionAuthority`
- `revokeAbandonedDelegation`
- `revokeAbandonedSubscription`

Adds 4 new errors: `transferHookTooManyAccounts`, `invalidSelfProgram`,
`planEndTsCannotExtend`,
`recurringDelegationStartOnLandingRequiresExpiry`.

Updates existing instructions with new required/optional accounts
(`payer`, `receiver`, `subscriptionAuthority`, `eventAuthority`,
`selfProgram`) and PDA-based `eventAuthority` defaults.

Also fixes three latent renderer bugs in `codama-renderers-dart`:
empty struct constructors, PDA seed import merging, and BigInt import
attribution.
