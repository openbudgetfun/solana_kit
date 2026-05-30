// Auto-generated. Do not edit.
// ignore_for_file: type=lint, constant_identifier_names

/// Error codes for the SolanaStakeInterface program.

/// Message: "Not enough credits to redeem"
const int solanaStakeInterfaceErrorNoCreditsToRedeem = 0x0; // 0

/// Message: "Lockup has not yet expired"
const int solanaStakeInterfaceErrorLockupInForce = 0x1; // 1

/// Message: "Stake already deactivated"
const int solanaStakeInterfaceErrorAlreadyDeactivated = 0x2; // 2

/// Message: "One re-delegation permitted per epoch"
const int solanaStakeInterfaceErrorTooSoonToRedelegate = 0x3; // 3

/// Message: "Split amount is more than is staked"
const int solanaStakeInterfaceErrorInsufficientStake = 0x4; // 4

/// Message: "Stake account with transient stake cannot be merged"
const int solanaStakeInterfaceErrorMergeTransientStake = 0x5; // 5

/// Message: "Stake account merge failed due to different authority, lockups or state"
const int solanaStakeInterfaceErrorMergeMismatch = 0x6; // 6

/// Message: "Custodian address not present"
const int solanaStakeInterfaceErrorCustodianMissing = 0x7; // 7

/// Message: "Custodian signature not present"
const int solanaStakeInterfaceErrorCustodianSignatureMissing = 0x8; // 8

/// Message: "Insufficient voting activity in the reference vote account"
const int solanaStakeInterfaceErrorInsufficientReferenceVotes = 0x9; // 9

/// Message: "Stake account is not delegated to the provided vote account"
const int solanaStakeInterfaceErrorVoteAddressMismatch = 0xa; // 10

/// Message: "Stake account has not been delinquent for the minimum epochs required for deactivation"
const int
solanaStakeInterfaceErrorMinimumDelinquentEpochsForDeactivationNotMet =
    0xb; // 11

/// Message: "Delegation amount is less than the minimum"
const int solanaStakeInterfaceErrorInsufficientDelegation = 0xc; // 12

/// Message: "Stake account with transient or inactive stake cannot be redelegated"
const int solanaStakeInterfaceErrorRedelegateTransientOrInactiveStake =
    0xd; // 13

/// Message: "Stake redelegation to the same vote account is not permitted"
const int solanaStakeInterfaceErrorRedelegateToSameVoteAccount = 0xe; // 14

/// Message: "Redelegated stake must be fully activated before deactivation"
const int
solanaStakeInterfaceErrorRedelegatedStakeMustFullyActivateBeforeDeactivationIsPermitted =
    0xf; // 15

/// Message: "Stake action is not permitted while the epoch rewards period is active"
const int solanaStakeInterfaceErrorEpochRewardsActive = 0x10; // 16

/// Map of error codes to human-readable messages.
const Map<int, String> _solanaStakeInterfaceErrorMessages = {
  solanaStakeInterfaceErrorNoCreditsToRedeem: 'Not enough credits to redeem',
  solanaStakeInterfaceErrorLockupInForce: 'Lockup has not yet expired',
  solanaStakeInterfaceErrorAlreadyDeactivated: 'Stake already deactivated',
  solanaStakeInterfaceErrorTooSoonToRedelegate:
      'One re-delegation permitted per epoch',
  solanaStakeInterfaceErrorInsufficientStake:
      'Split amount is more than is staked',
  solanaStakeInterfaceErrorMergeTransientStake:
      'Stake account with transient stake cannot be merged',
  solanaStakeInterfaceErrorMergeMismatch:
      'Stake account merge failed due to different authority, lockups or state',
  solanaStakeInterfaceErrorCustodianMissing: 'Custodian address not present',
  solanaStakeInterfaceErrorCustodianSignatureMissing:
      'Custodian signature not present',
  solanaStakeInterfaceErrorInsufficientReferenceVotes:
      'Insufficient voting activity in the reference vote account',
  solanaStakeInterfaceErrorVoteAddressMismatch:
      'Stake account is not delegated to the provided vote account',
  solanaStakeInterfaceErrorMinimumDelinquentEpochsForDeactivationNotMet:
      'Stake account has not been delinquent for the minimum epochs required for deactivation',
  solanaStakeInterfaceErrorInsufficientDelegation:
      'Delegation amount is less than the minimum',
  solanaStakeInterfaceErrorRedelegateTransientOrInactiveStake:
      'Stake account with transient or inactive stake cannot be redelegated',
  solanaStakeInterfaceErrorRedelegateToSameVoteAccount:
      'Stake redelegation to the same vote account is not permitted',
  solanaStakeInterfaceErrorRedelegatedStakeMustFullyActivateBeforeDeactivationIsPermitted:
      'Redelegated stake must be fully activated before deactivation',
  solanaStakeInterfaceErrorEpochRewardsActive:
      'Stake action is not permitted while the epoch rewards period is active',
};

/// Get the error message for a SolanaStakeInterface program error code.
String? getSolanaStakeInterfaceErrorMessage(int code) {
  return _solanaStakeInterfaceErrorMessages[code];
}

/// Check if an error code belongs to the SolanaStakeInterface program.
bool isSolanaStakeInterfaceError(int code) {
  return _solanaStakeInterfaceErrorMessages.containsKey(code);
}
