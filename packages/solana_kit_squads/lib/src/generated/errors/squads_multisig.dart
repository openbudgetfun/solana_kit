// Auto-generated. Do not edit.
// ignore_for_file: type=lint, constant_identifier_names

/// Error codes for the SquadsMultisig program.

/// DuplicateMember: Found multiple members with the same pubkey
/// Message: "Found multiple members with the same pubkey"
const int squadsMultisigErrorDuplicateMember = 0x1770; // 6000

/// EmptyMembers: Members array is empty
/// Message: "Members array is empty"
const int squadsMultisigErrorEmptyMembers = 0x1771; // 6001

/// TooManyMembers: Too many members, can be up to 65535
/// Message: "Too many members, can be up to 65535"
const int squadsMultisigErrorTooManyMembers = 0x1772; // 6002

/// InvalidThreshold: Invalid threshold, must be between 1 and number of members with Vote permission
/// Message: "Invalid threshold, must be between 1 and number of members with Vote permission"
const int squadsMultisigErrorInvalidThreshold = 0x1773; // 6003

/// Unauthorized: Attempted to perform an unauthorized action
/// Message: "Attempted to perform an unauthorized action"
const int squadsMultisigErrorUnauthorized = 0x1774; // 6004

/// NotAMember: Provided pubkey is not a member of multisig
/// Message: "Provided pubkey is not a member of multisig"
const int squadsMultisigErrorNotAMember = 0x1775; // 6005

/// InvalidTransactionMessage: TransactionMessage is malformed.
/// Message: "TransactionMessage is malformed."
const int squadsMultisigErrorInvalidTransactionMessage = 0x1776; // 6006

/// StaleProposal: Proposal is stale
/// Message: "Proposal is stale"
const int squadsMultisigErrorStaleProposal = 0x1777; // 6007

/// InvalidProposalStatus: Invalid proposal status
/// Message: "Invalid proposal status"
const int squadsMultisigErrorInvalidProposalStatus = 0x1778; // 6008

/// InvalidTransactionIndex: Invalid transaction index
/// Message: "Invalid transaction index"
const int squadsMultisigErrorInvalidTransactionIndex = 0x1779; // 6009

/// AlreadyApproved: Member already approved the transaction
/// Message: "Member already approved the transaction"
const int squadsMultisigErrorAlreadyApproved = 0x177a; // 6010

/// AlreadyRejected: Member already rejected the transaction
/// Message: "Member already rejected the transaction"
const int squadsMultisigErrorAlreadyRejected = 0x177b; // 6011

/// AlreadyCancelled: Member already cancelled the transaction
/// Message: "Member already cancelled the transaction"
const int squadsMultisigErrorAlreadyCancelled = 0x177c; // 6012

/// InvalidNumberOfAccounts: Wrong number of accounts provided
/// Message: "Wrong number of accounts provided"
const int squadsMultisigErrorInvalidNumberOfAccounts = 0x177d; // 6013

/// InvalidAccount: Invalid account provided
/// Message: "Invalid account provided"
const int squadsMultisigErrorInvalidAccount = 0x177e; // 6014

/// RemoveLastMember: Cannot remove last member
/// Message: "Cannot remove last member"
const int squadsMultisigErrorRemoveLastMember = 0x177f; // 6015

/// NoVoters: Members don't include any voters
/// Message: "Members don't include any voters"
const int squadsMultisigErrorNoVoters = 0x1780; // 6016

/// NoProposers: Members don't include any proposers
/// Message: "Members don't include any proposers"
const int squadsMultisigErrorNoProposers = 0x1781; // 6017

/// NoExecutors: Members don't include any executors
/// Message: "Members don't include any executors"
const int squadsMultisigErrorNoExecutors = 0x1782; // 6018

/// InvalidStaleTransactionIndex: `stale_transaction_index` must be <= `transaction_index`
/// Message: "`stale_transaction_index` must be <= `transaction_index`"
const int squadsMultisigErrorInvalidStaleTransactionIndex = 0x1783; // 6019

/// NotSupportedForControlled: Instruction not supported for controlled multisig
/// Message: "Instruction not supported for controlled multisig"
const int squadsMultisigErrorNotSupportedForControlled = 0x1784; // 6020

/// TimeLockNotReleased: Proposal time lock has not been released
/// Message: "Proposal time lock has not been released"
const int squadsMultisigErrorTimeLockNotReleased = 0x1785; // 6021

/// NoActions: Config transaction must have at least one action
/// Message: "Config transaction must have at least one action"
const int squadsMultisigErrorNoActions = 0x1786; // 6022

/// MissingAccount: Missing account
/// Message: "Missing account"
const int squadsMultisigErrorMissingAccount = 0x1787; // 6023

/// InvalidMint: Invalid mint
/// Message: "Invalid mint"
const int squadsMultisigErrorInvalidMint = 0x1788; // 6024

/// InvalidDestination: Invalid destination
/// Message: "Invalid destination"
const int squadsMultisigErrorInvalidDestination = 0x1789; // 6025

/// SpendingLimitExceeded: Spending limit exceeded
/// Message: "Spending limit exceeded"
const int squadsMultisigErrorSpendingLimitExceeded = 0x178a; // 6026

/// DecimalsMismatch: Decimals don't match the mint
/// Message: "Decimals don't match the mint"
const int squadsMultisigErrorDecimalsMismatch = 0x178b; // 6027

/// UnknownPermission: Member has unknown permission
/// Message: "Member has unknown permission"
const int squadsMultisigErrorUnknownPermission = 0x178c; // 6028

/// ProtectedAccount: Account is protected, it cannot be passed into a CPI as writable
/// Message: "Account is protected, it cannot be passed into a CPI as writable"
const int squadsMultisigErrorProtectedAccount = 0x178d; // 6029

/// TimeLockExceedsMaxAllowed: Time lock exceeds the maximum allowed (90 days)
/// Message: "Time lock exceeds the maximum allowed (90 days)"
const int squadsMultisigErrorTimeLockExceedsMaxAllowed = 0x178e; // 6030

/// IllegalAccountOwner: Account is not owned by Multisig program
/// Message: "Account is not owned by Multisig program"
const int squadsMultisigErrorIllegalAccountOwner = 0x178f; // 6031

/// RentReclamationDisabled: Rent reclamation is disabled for this multisig
/// Message: "Rent reclamation is disabled for this multisig"
const int squadsMultisigErrorRentReclamationDisabled = 0x1790; // 6032

/// InvalidRentCollector: Invalid rent collector address
/// Message: "Invalid rent collector address"
const int squadsMultisigErrorInvalidRentCollector = 0x1791; // 6033

/// ProposalForAnotherMultisig: Proposal is for another multisig
/// Message: "Proposal is for another multisig"
const int squadsMultisigErrorProposalForAnotherMultisig = 0x1792; // 6034

/// TransactionForAnotherMultisig: Transaction is for another multisig
/// Message: "Transaction is for another multisig"
const int squadsMultisigErrorTransactionForAnotherMultisig = 0x1793; // 6035

/// TransactionNotMatchingProposal: Transaction doesn't match proposal
/// Message: "Transaction doesn't match proposal"
const int squadsMultisigErrorTransactionNotMatchingProposal = 0x1794; // 6036

/// TransactionNotLastInBatch: Transaction is not last in batch
/// Message: "Transaction is not last in batch"
const int squadsMultisigErrorTransactionNotLastInBatch = 0x1795; // 6037

/// BatchNotEmpty: Batch is not empty
/// Message: "Batch is not empty"
const int squadsMultisigErrorBatchNotEmpty = 0x1796; // 6038

/// SpendingLimitInvalidAmount: Invalid SpendingLimit amount
/// Message: "Invalid SpendingLimit amount"
const int squadsMultisigErrorSpendingLimitInvalidAmount = 0x1797; // 6039

/// InvalidInstructionArgs: Invalid Instruction Arguments
/// Message: "Invalid Instruction Arguments"
const int squadsMultisigErrorInvalidInstructionArgs = 0x1798; // 6040

/// FinalBufferHashMismatch: Final message buffer hash doesnt match the expected hash
/// Message: "Final message buffer hash doesnt match the expected hash"
const int squadsMultisigErrorFinalBufferHashMismatch = 0x1799; // 6041

/// FinalBufferSizeExceeded: Final buffer size cannot exceed 4000 bytes
/// Message: "Final buffer size cannot exceed 4000 bytes"
const int squadsMultisigErrorFinalBufferSizeExceeded = 0x179a; // 6042

/// FinalBufferSizeMismatch: Final buffer size mismatch
/// Message: "Final buffer size mismatch"
const int squadsMultisigErrorFinalBufferSizeMismatch = 0x179b; // 6043

/// MultisigCreateDeprecated: multisig_create has been deprecated. Use multisig_create_v2 instead.
/// Message: "multisig_create has been deprecated. Use multisig_create_v2 instead."
const int squadsMultisigErrorMultisigCreateDeprecated = 0x179c; // 6044

/// Map of error codes to human-readable messages.
const Map<int, String> _squadsMultisigErrorMessages = {
  squadsMultisigErrorDuplicateMember:
      'Found multiple members with the same pubkey',
  squadsMultisigErrorEmptyMembers: 'Members array is empty',
  squadsMultisigErrorTooManyMembers: 'Too many members, can be up to 65535',
  squadsMultisigErrorInvalidThreshold:
      'Invalid threshold, must be between 1 and number of members with Vote permission',
  squadsMultisigErrorUnauthorized:
      'Attempted to perform an unauthorized action',
  squadsMultisigErrorNotAMember: 'Provided pubkey is not a member of multisig',
  squadsMultisigErrorInvalidTransactionMessage:
      'TransactionMessage is malformed.',
  squadsMultisigErrorStaleProposal: 'Proposal is stale',
  squadsMultisigErrorInvalidProposalStatus: 'Invalid proposal status',
  squadsMultisigErrorInvalidTransactionIndex: 'Invalid transaction index',
  squadsMultisigErrorAlreadyApproved: 'Member already approved the transaction',
  squadsMultisigErrorAlreadyRejected: 'Member already rejected the transaction',
  squadsMultisigErrorAlreadyCancelled:
      'Member already cancelled the transaction',
  squadsMultisigErrorInvalidNumberOfAccounts:
      'Wrong number of accounts provided',
  squadsMultisigErrorInvalidAccount: 'Invalid account provided',
  squadsMultisigErrorRemoveLastMember: 'Cannot remove last member',
  squadsMultisigErrorNoVoters: 'Members don\'t include any voters',
  squadsMultisigErrorNoProposers: 'Members don\'t include any proposers',
  squadsMultisigErrorNoExecutors: 'Members don\'t include any executors',
  squadsMultisigErrorInvalidStaleTransactionIndex:
      '`stale_transaction_index` must be <= `transaction_index`',
  squadsMultisigErrorNotSupportedForControlled:
      'Instruction not supported for controlled multisig',
  squadsMultisigErrorTimeLockNotReleased:
      'Proposal time lock has not been released',
  squadsMultisigErrorNoActions:
      'Config transaction must have at least one action',
  squadsMultisigErrorMissingAccount: 'Missing account',
  squadsMultisigErrorInvalidMint: 'Invalid mint',
  squadsMultisigErrorInvalidDestination: 'Invalid destination',
  squadsMultisigErrorSpendingLimitExceeded: 'Spending limit exceeded',
  squadsMultisigErrorDecimalsMismatch: 'Decimals don\'t match the mint',
  squadsMultisigErrorUnknownPermission: 'Member has unknown permission',
  squadsMultisigErrorProtectedAccount:
      'Account is protected, it cannot be passed into a CPI as writable',
  squadsMultisigErrorTimeLockExceedsMaxAllowed:
      'Time lock exceeds the maximum allowed (90 days)',
  squadsMultisigErrorIllegalAccountOwner:
      'Account is not owned by Multisig program',
  squadsMultisigErrorRentReclamationDisabled:
      'Rent reclamation is disabled for this multisig',
  squadsMultisigErrorInvalidRentCollector: 'Invalid rent collector address',
  squadsMultisigErrorProposalForAnotherMultisig:
      'Proposal is for another multisig',
  squadsMultisigErrorTransactionForAnotherMultisig:
      'Transaction is for another multisig',
  squadsMultisigErrorTransactionNotMatchingProposal:
      'Transaction doesn\'t match proposal',
  squadsMultisigErrorTransactionNotLastInBatch:
      'Transaction is not last in batch',
  squadsMultisigErrorBatchNotEmpty: 'Batch is not empty',
  squadsMultisigErrorSpendingLimitInvalidAmount: 'Invalid SpendingLimit amount',
  squadsMultisigErrorInvalidInstructionArgs: 'Invalid Instruction Arguments',
  squadsMultisigErrorFinalBufferHashMismatch:
      'Final message buffer hash doesnt match the expected hash',
  squadsMultisigErrorFinalBufferSizeExceeded:
      'Final buffer size cannot exceed 4000 bytes',
  squadsMultisigErrorFinalBufferSizeMismatch: 'Final buffer size mismatch',
  squadsMultisigErrorMultisigCreateDeprecated:
      'multisig_create has been deprecated. Use multisig_create_v2 instead.',
};

/// Get the error message for a SquadsMultisig program error code.
String? getSquadsMultisigErrorMessage(int code) {
  return _squadsMultisigErrorMessages[code];
}

/// Check if an error code belongs to the SquadsMultisig program.
bool isSquadsMultisigError(int code) {
  return _squadsMultisigErrorMessages.containsKey(code);
}
