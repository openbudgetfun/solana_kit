// Auto-generated. Do not edit.
// ignore_for_file: type=lint, constant_identifier_names

/// Error codes for the Staking program.

/// PoolNotActive: The staking pool is not active.
/// Message: "The staking pool is not active."
const int stakingErrorPoolNotActive = 0x1770; // 6000

/// MaxStakersReached: Maximum number of stakers has been reached.
/// Message: "Maximum number of stakers has been reached."
const int stakingErrorMaxStakersReached = 0x1771; // 6001

/// StakeDurationNotMet: Minimum stake duration has not been met.
/// Message: "Minimum stake duration has not been met."
const int stakingErrorStakeDurationNotMet = 0x1772; // 6002

/// NoRewardsAvailable: There are no rewards available to claim.
/// Message: "There are no rewards available to claim."
const int stakingErrorNoRewardsAvailable = 0x1773; // 6003

/// InvalidStakeAmount: The stake amount must be greater than zero.
/// Message: "The stake amount must be greater than zero."
const int stakingErrorInvalidStakeAmount = 0x1774; // 6004

/// Unauthorized: You are not authorized to perform this action.
/// Message: "You are not authorized to perform this action."
const int stakingErrorUnauthorized = 0x1775; // 6005

/// Map of error codes to human-readable messages.
const Map<int, String> _stakingErrorMessages = {
  stakingErrorPoolNotActive: 'The staking pool is not active.',
  stakingErrorMaxStakersReached: 'Maximum number of stakers has been reached.',
  stakingErrorStakeDurationNotMet: 'Minimum stake duration has not been met.',
  stakingErrorNoRewardsAvailable: 'There are no rewards available to claim.',
  stakingErrorInvalidStakeAmount: 'The stake amount must be greater than zero.',
  stakingErrorUnauthorized: 'You are not authorized to perform this action.',
};

/// Get the error message for a Staking program error code.
String? getStakingErrorMessage(int code) {
  return _stakingErrorMessages[code];
}

/// Check if an error code belongs to the Staking program.
bool isStakingError(int code) {
  return _stakingErrorMessages.containsKey(code);
}
