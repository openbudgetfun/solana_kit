---
"solana_kit_helius": major
---

# Helius SDK v3.0.0 auth/payment port

Port Helius SDK v3.0.0 auth/payment API surface

- **Added** `signup()` — unified Phase 1 signup replacing the legacy `agenticSignup`. Supports both secret-key-authenticated and pre-authenticated flows. Returns discriminated `SignupResult` (`already_subscribed`, `upgrade_required`, or `payment_required`).
- **Added** `SignupRequest` type with `secretKey()` and `preauthenticated()` constructors, replacing `AgenticSignupRequest`/`AgenticSignupResponse`.
- **Added** `SignupResult` sealed class with `AlreadySubscribedResult`, `UpgradeRequiredResult`, and `PaymentRequiredResult` variants.
- **Added** `SignupEndpoints` type for mainnet/devnet RPC URLs.
- **Added** `constants.dart` — v3.0.0 constants: `paymentHost`, `treasury`, `usdcMint`, `memoProgramId`, polling timeouts, `agentPlanId`, etc.
- **Added** `signup_helpers.dart` — `buildEndpoints()` helper.
- **Verified** existing checkout functions (`createPayment`, `getPaymentStatus`, `pollCheckoutCompletion`) match upstream v3.0.0 semantics.
- **Verified** `getAddress`, `loadKeypair`, `getHttpStatus` match upstream v3.0.0.
- **Removed** legacy `agenticSignup` method and `agentic_signup.dart` (upstream v3.0.0 removed it; `signup` is the replacement).

```dart
// Before
final result = await auth.agenticSignup(secretKey: keypair);

// After
final result = await auth.signup(
  SignupRequest.secretKey(secretKey: keypair, plan: 'agent'),
);
```
