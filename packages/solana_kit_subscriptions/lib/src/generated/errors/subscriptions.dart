// Auto-generated. Do not edit.
// ignore_for_file: type=lint, constant_identifier_names

/// Error codes for the Subscriptions program.

/// Message: "Account must be a signer"
const int subscriptionsErrorNotSigner = 0x64; // 100

/// Message: "Invalid account address"
const int subscriptionsErrorInvalidAddress = 0x65; // 101

/// Message: "Invalid escrow PDA derivation"
const int subscriptionsErrorInvalidEscrowPda = 0x66; // 102

/// Message: "Invalid subscription-authority PDA derivation"
const int subscriptionsErrorInvalidSubscriptionAuthorityPda = 0x67; // 103

/// Message: "Expected system program"
const int subscriptionsErrorNotSystemProgram = 0x68; // 104

/// Message: "Token Program does not match other accounts"
const int subscriptionsErrorInvalidTokenProgram = 0x69; // 105

/// Message: "Invalid Token-2022 mint account data"
const int subscriptionsErrorInvalidToken2022MintAccountData = 0x6a; // 106

/// Message: "Invalid Token-2022 token account data"
const int subscriptionsErrorInvalidToken2022TokenAccountData = 0x6b; // 107

/// Message: "Invalid associated token account address"
const int subscriptionsErrorInvalidAssociatedTokenAccountDerivedAddress =
    0x6c; // 108

/// Message: "Invalid SPL Token mint account data"
const int subscriptionsErrorInvalidTokenSplMintAccountData = 0x6d; // 109

/// Message: "Invalid SPL Token account data"
const int subscriptionsErrorInvalidTokenSplTokenAccountData = 0x6e; // 110

/// Message: "Invalid account data"
const int subscriptionsErrorInvalidAccountData = 0x6f; // 111

/// Message: "Invalid instruction data"
const int subscriptionsErrorInvalidInstructionData = 0x70; // 112

/// Message: "Not enough account keys provided"
const int subscriptionsErrorNotEnoughAccountKeys = 0x71; // 113

/// Message: "Invalid instruction"
const int subscriptionsErrorInvalidInstruction = 0x72; // 114

/// Message: "Arithmetic Overflow"
const int subscriptionsErrorArithmeticOverflow = 0x73; // 115

/// Message: "Arithmetic Underflow"
const int subscriptionsErrorArithmeticUnderflow = 0x74; // 116

/// Message: "Invalid account discriminator"
const int subscriptionsErrorInvalidAccountDiscriminator = 0x75; // 117

/// Message: "Mint has ConfidentialTransfer extension"
const int subscriptionsErrorMintHasConfidentialTransfer = 0x76; // 118

/// Message: "Mint has NonTransferable extension"
const int subscriptionsErrorMintHasNonTransferable = 0x77; // 119

/// Message: "Mint has PermanentDelegate extension"
const int subscriptionsErrorMintHasPermanentDelegate = 0x78; // 120

/// Message: "Mint has TransferHook extension"
const int subscriptionsErrorMintHasTransferHook = 0x79; // 121

/// Message: "Mint has TransferFee extension"
const int subscriptionsErrorMintHasTransferFee = 0x7a; // 122

/// Message: "Mint has MintCloseAuthority extension"
const int subscriptionsErrorMintHasMintCloseAuthority = 0x7b; // 123

/// Message: "Mint has Pausable extension"
const int subscriptionsErrorMintHasPausable = 0x7c; // 124

/// Message: "Token mint mismatch"
const int subscriptionsErrorMintMismatch = 0x7d; // 125

/// Message: "Invalid delegation PDA derivation"
const int subscriptionsErrorInvalidDelegatePda = 0x7e; // 126

/// Message: "Invalid header data"
const int subscriptionsErrorInvalidHeaderData = 0x7f; // 127

/// Message: "Delegation has expired"
const int subscriptionsErrorDelegationExpired = 0x80; // 128

/// Message: "Invalid amount specified"
const int subscriptionsErrorInvalidAmount = 0x81; // 129

/// Message: "Caller not authorized for this action"
const int subscriptionsErrorUnauthorized = 0x82; // 130

/// Message: "Account must be writable"
const int subscriptionsErrorAccountNotWritable = 0x83; // 131

/// Message: "Token account owner does not match expected"
const int subscriptionsErrorAtaOwnerMismatch = 0x84; // 132

/// Message: "Delegation header version is not compatible"
const int subscriptionsErrorDelegationVersionMismatch = 0x85; // 133

/// Message: "Account requires explicit migration"
const int subscriptionsErrorMigrationRequired = 0x86; // 134

/// Message: "Delegation account already exists"
const int subscriptionsErrorDelegationAlreadyExists = 0x87; // 135

/// Message: "Delegation init_id does not match current SubscriptionAuthority"
const int subscriptionsErrorStaleSubscriptionAuthority = 0x88; // 136

/// Message: "Transfer amount exceeds delegation limit"
const int subscriptionsErrorAmountExceedsLimit = 0x12c; // 300

/// Message: "Expiry time specified is less than current time"
const int subscriptionsErrorFixedDelegationExpiryInPast = 0x12d; // 301

/// Message: "zero amount specified"
const int subscriptionsErrorFixedDelegationAmountZero = 0x12e; // 302

/// Message: "Transfer amount exceeds period limit"
const int subscriptionsErrorAmountExceedsPeriodLimit = 0x190; // 400

/// Message: "Period has not elapsed yet"
const int subscriptionsErrorPeriodNotElapsed = 0x191; // 401

/// Message: "Invalid Period length"
const int subscriptionsErrorInvalidPeriodLength = 0x192; // 402

/// Message: "Payer provided does not match delegation"
const int subscriptionsErrorInvalidPayerData = 0x193; // 403

/// Message: "Past start time specified"
const int subscriptionsErrorRecurringDelegationStartTimeInPast = 0x194; // 404

/// Message: "start time specified is greater than expiry"
const int subscriptionsErrorRecurringDelegationStartTimeGreaterThanExpiry =
    0x195; // 405

/// Message: "zero amount specified"
const int subscriptionsErrorRecurringDelegationAmountZero = 0x196; // 406

/// Message: "Delegation period has not started yet"
const int subscriptionsErrorDelegationNotStarted = 0x197; // 407

/// Message: "Plan is in sunset status"
const int subscriptionsErrorPlanSunset = 0x1f4; // 500

/// Message: "Plan has expired"
const int subscriptionsErrorPlanExpired = 0x1f5; // 501

/// Message: "Invalid Plan PDA derivation"
const int subscriptionsErrorInvalidPlanPda = 0x1f6; // 502

/// Message: "Invalid subscription PDA derivation"
const int subscriptionsErrorInvalidSubscriptionPda = 0x1f7; // 503

/// Message: "Caller is not the plan owner"
const int subscriptionsErrorNotPlanOwner = 0x1f8; // 504

/// Message: "Subscription does not belong to this plan"
const int subscriptionsErrorSubscriptionPlanMismatch = 0x1f9; // 505

/// Message: "Destination not in plan whitelist"
const int subscriptionsErrorUnauthorizedDestination = 0x1fa; // 506

/// Message: "No valid destinations provided"
const int subscriptionsErrorInvalidNumDestinations = 0x1fb; // 507

/// Message: "Subscription cancelled and past valid period"
const int subscriptionsErrorSubscriptionCancelled = 0x1fc; // 508

/// Message: "Subscription already cancelled"
const int subscriptionsErrorSubscriptionAlreadyCancelled = 0x1fd; // 509

/// Message: "Subscription is not cancelled"
const int subscriptionsErrorSubscriptionNotCancelled = 0x1fe; // 510

/// Message: "End timestamp must be zero or in the future"
const int subscriptionsErrorInvalidEndTs = 0x1ff; // 511

/// Message: "Invalid plan status value"
const int subscriptionsErrorInvalidPlanStatus = 0x200; // 512

/// Message: "Plan cannot be updated after sunset"
const int subscriptionsErrorPlanImmutableAfterSunset = 0x201; // 513

/// Message: "Sunset requires a non-zero end timestamp"
const int subscriptionsErrorSunsetRequiresEndTs = 0x202; // 514

/// Message: "Plan must be expired to delete"
const int subscriptionsErrorPlanNotExpired = 0x203; // 515

/// Message: "Plan account has been closed"
const int subscriptionsErrorPlanClosed = 0x204; // 516

/// Message: "Already subscribed to this plan"
const int subscriptionsErrorAlreadySubscribed = 0x205; // 517

/// Message: "Plan account already exists"
const int subscriptionsErrorPlanAlreadyExists = 0x206; // 518

/// Message: "Subscription plan terms do not match the current plan"
const int subscriptionsErrorPlanTermsMismatch = 0x207; // 519

/// Message: "Invalid event authority PDA"
const int subscriptionsErrorInvalidEventAuthority = 0x258; // 600

/// Message: "Invalid event data"
const int subscriptionsErrorInvalidEventData = 0x259; // 601

/// Message: "Invalid event tag prefix"
const int subscriptionsErrorInvalidEventTag = 0x25a; // 602

/// Message: "Unknown event discriminator"
const int subscriptionsErrorInvalidEventDiscriminator = 0x25b; // 603

/// Map of error codes to human-readable messages.
const Map<int, String> _subscriptionsErrorMessages = {
  subscriptionsErrorNotSigner: 'Account must be a signer',
  subscriptionsErrorInvalidAddress: 'Invalid account address',
  subscriptionsErrorInvalidEscrowPda: 'Invalid escrow PDA derivation',
  subscriptionsErrorInvalidSubscriptionAuthorityPda:
      'Invalid subscription-authority PDA derivation',
  subscriptionsErrorNotSystemProgram: 'Expected system program',
  subscriptionsErrorInvalidTokenProgram:
      'Token Program does not match other accounts',
  subscriptionsErrorInvalidToken2022MintAccountData:
      'Invalid Token-2022 mint account data',
  subscriptionsErrorInvalidToken2022TokenAccountData:
      'Invalid Token-2022 token account data',
  subscriptionsErrorInvalidAssociatedTokenAccountDerivedAddress:
      'Invalid associated token account address',
  subscriptionsErrorInvalidTokenSplMintAccountData:
      'Invalid SPL Token mint account data',
  subscriptionsErrorInvalidTokenSplTokenAccountData:
      'Invalid SPL Token account data',
  subscriptionsErrorInvalidAccountData: 'Invalid account data',
  subscriptionsErrorInvalidInstructionData: 'Invalid instruction data',
  subscriptionsErrorNotEnoughAccountKeys: 'Not enough account keys provided',
  subscriptionsErrorInvalidInstruction: 'Invalid instruction',
  subscriptionsErrorArithmeticOverflow: 'Arithmetic Overflow',
  subscriptionsErrorArithmeticUnderflow: 'Arithmetic Underflow',
  subscriptionsErrorInvalidAccountDiscriminator:
      'Invalid account discriminator',
  subscriptionsErrorMintHasConfidentialTransfer:
      'Mint has ConfidentialTransfer extension',
  subscriptionsErrorMintHasNonTransferable:
      'Mint has NonTransferable extension',
  subscriptionsErrorMintHasPermanentDelegate:
      'Mint has PermanentDelegate extension',
  subscriptionsErrorMintHasTransferHook: 'Mint has TransferHook extension',
  subscriptionsErrorMintHasTransferFee: 'Mint has TransferFee extension',
  subscriptionsErrorMintHasMintCloseAuthority:
      'Mint has MintCloseAuthority extension',
  subscriptionsErrorMintHasPausable: 'Mint has Pausable extension',
  subscriptionsErrorMintMismatch: 'Token mint mismatch',
  subscriptionsErrorInvalidDelegatePda: 'Invalid delegation PDA derivation',
  subscriptionsErrorInvalidHeaderData: 'Invalid header data',
  subscriptionsErrorDelegationExpired: 'Delegation has expired',
  subscriptionsErrorInvalidAmount: 'Invalid amount specified',
  subscriptionsErrorUnauthorized: 'Caller not authorized for this action',
  subscriptionsErrorAccountNotWritable: 'Account must be writable',
  subscriptionsErrorAtaOwnerMismatch:
      'Token account owner does not match expected',
  subscriptionsErrorDelegationVersionMismatch:
      'Delegation header version is not compatible',
  subscriptionsErrorMigrationRequired: 'Account requires explicit migration',
  subscriptionsErrorDelegationAlreadyExists:
      'Delegation account already exists',
  subscriptionsErrorStaleSubscriptionAuthority:
      'Delegation init_id does not match current SubscriptionAuthority',
  subscriptionsErrorAmountExceedsLimit:
      'Transfer amount exceeds delegation limit',
  subscriptionsErrorFixedDelegationExpiryInPast:
      'Expiry time specified is less than current time',
  subscriptionsErrorFixedDelegationAmountZero: 'zero amount specified',
  subscriptionsErrorAmountExceedsPeriodLimit:
      'Transfer amount exceeds period limit',
  subscriptionsErrorPeriodNotElapsed: 'Period has not elapsed yet',
  subscriptionsErrorInvalidPeriodLength: 'Invalid Period length',
  subscriptionsErrorInvalidPayerData:
      'Payer provided does not match delegation',
  subscriptionsErrorRecurringDelegationStartTimeInPast:
      'Past start time specified',
  subscriptionsErrorRecurringDelegationStartTimeGreaterThanExpiry:
      'start time specified is greater than expiry',
  subscriptionsErrorRecurringDelegationAmountZero: 'zero amount specified',
  subscriptionsErrorDelegationNotStarted:
      'Delegation period has not started yet',
  subscriptionsErrorPlanSunset: 'Plan is in sunset status',
  subscriptionsErrorPlanExpired: 'Plan has expired',
  subscriptionsErrorInvalidPlanPda: 'Invalid Plan PDA derivation',
  subscriptionsErrorInvalidSubscriptionPda:
      'Invalid subscription PDA derivation',
  subscriptionsErrorNotPlanOwner: 'Caller is not the plan owner',
  subscriptionsErrorSubscriptionPlanMismatch:
      'Subscription does not belong to this plan',
  subscriptionsErrorUnauthorizedDestination:
      'Destination not in plan whitelist',
  subscriptionsErrorInvalidNumDestinations: 'No valid destinations provided',
  subscriptionsErrorSubscriptionCancelled:
      'Subscription cancelled and past valid period',
  subscriptionsErrorSubscriptionAlreadyCancelled:
      'Subscription already cancelled',
  subscriptionsErrorSubscriptionNotCancelled: 'Subscription is not cancelled',
  subscriptionsErrorInvalidEndTs: 'End timestamp must be zero or in the future',
  subscriptionsErrorInvalidPlanStatus: 'Invalid plan status value',
  subscriptionsErrorPlanImmutableAfterSunset:
      'Plan cannot be updated after sunset',
  subscriptionsErrorSunsetRequiresEndTs:
      'Sunset requires a non-zero end timestamp',
  subscriptionsErrorPlanNotExpired: 'Plan must be expired to delete',
  subscriptionsErrorPlanClosed: 'Plan account has been closed',
  subscriptionsErrorAlreadySubscribed: 'Already subscribed to this plan',
  subscriptionsErrorPlanAlreadyExists: 'Plan account already exists',
  subscriptionsErrorPlanTermsMismatch:
      'Subscription plan terms do not match the current plan',
  subscriptionsErrorInvalidEventAuthority: 'Invalid event authority PDA',
  subscriptionsErrorInvalidEventData: 'Invalid event data',
  subscriptionsErrorInvalidEventTag: 'Invalid event tag prefix',
  subscriptionsErrorInvalidEventDiscriminator: 'Unknown event discriminator',
};

/// Get the error message for a Subscriptions program error code.
String? getSubscriptionsErrorMessage(int code) {
  return _subscriptionsErrorMessages[code];
}

/// Check if an error code belongs to the Subscriptions program.
bool isSubscriptionsError(int code) {
  return _subscriptionsErrorMessages.containsKey(code);
}
