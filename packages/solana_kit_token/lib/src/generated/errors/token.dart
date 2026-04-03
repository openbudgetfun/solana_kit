// Auto-generated. Do not edit.
// ignore_for_file: type=lint, constant_identifier_names

/// Error codes for the Token program.

/// NotRentExempt: Lamport balance below rent-exempt threshold
/// Message: "Lamport balance below rent-exempt threshold"
const int tokenErrorNotRentExempt = 0x0; // 0

/// InsufficientFunds: Insufficient funds
/// Message: "Insufficient funds"
const int tokenErrorInsufficientFunds = 0x1; // 1

/// InvalidMint: Invalid Mint
/// Message: "Invalid Mint"
const int tokenErrorInvalidMint = 0x2; // 2

/// MintMismatch: Account not associated with this Mint
/// Message: "Account not associated with this Mint"
const int tokenErrorMintMismatch = 0x3; // 3

/// OwnerMismatch: Owner does not match
/// Message: "Owner does not match"
const int tokenErrorOwnerMismatch = 0x4; // 4

/// FixedSupply: Fixed supply
/// Message: "Fixed supply"
const int tokenErrorFixedSupply = 0x5; // 5

/// AlreadyInUse: Already in use
/// Message: "Already in use"
const int tokenErrorAlreadyInUse = 0x6; // 6

/// InvalidNumberOfProvidedSigners: Invalid number of provided signers
/// Message: "Invalid number of provided signers"
const int tokenErrorInvalidNumberOfProvidedSigners = 0x7; // 7

/// InvalidNumberOfRequiredSigners: Invalid number of required signers
/// Message: "Invalid number of required signers"
const int tokenErrorInvalidNumberOfRequiredSigners = 0x8; // 8

/// UninitializedState: State is unititialized
/// Message: "State is unititialized"
const int tokenErrorUninitializedState = 0x9; // 9

/// NativeNotSupported: Instruction does not support native tokens
/// Message: "Instruction does not support native tokens"
const int tokenErrorNativeNotSupported = 0xa; // 10

/// NonNativeHasBalance: Non-native account can only be closed if its balance is zero
/// Message: "Non-native account can only be closed if its balance is zero"
const int tokenErrorNonNativeHasBalance = 0xb; // 11

/// InvalidInstruction: Invalid instruction
/// Message: "Invalid instruction"
const int tokenErrorInvalidInstruction = 0xc; // 12

/// InvalidState: State is invalid for requested operation
/// Message: "State is invalid for requested operation"
const int tokenErrorInvalidState = 0xd; // 13

/// Overflow: Operation overflowed
/// Message: "Operation overflowed"
const int tokenErrorOverflow = 0xe; // 14

/// AuthorityTypeNotSupported: Account does not support specified authority type
/// Message: "Account does not support specified authority type"
const int tokenErrorAuthorityTypeNotSupported = 0xf; // 15

/// MintCannotFreeze: This token mint cannot freeze accounts
/// Message: "This token mint cannot freeze accounts"
const int tokenErrorMintCannotFreeze = 0x10; // 16

/// AccountFrozen: Account is frozen
/// Message: "Account is frozen"
const int tokenErrorAccountFrozen = 0x11; // 17

/// MintDecimalsMismatch: The provided decimals value different from the Mint decimals
/// Message: "The provided decimals value different from the Mint decimals"
const int tokenErrorMintDecimalsMismatch = 0x12; // 18

/// NonNativeNotSupported: Instruction does not support non-native tokens
/// Message: "Instruction does not support non-native tokens"
const int tokenErrorNonNativeNotSupported = 0x13; // 19

/// Map of error codes to human-readable messages.
const Map<int, String> _tokenErrorMessages = {
    tokenErrorNotRentExempt: 'Lamport balance below rent-exempt threshold',
    tokenErrorInsufficientFunds: 'Insufficient funds',
    tokenErrorInvalidMint: 'Invalid Mint',
    tokenErrorMintMismatch: 'Account not associated with this Mint',
    tokenErrorOwnerMismatch: 'Owner does not match',
    tokenErrorFixedSupply: 'Fixed supply',
    tokenErrorAlreadyInUse: 'Already in use',
    tokenErrorInvalidNumberOfProvidedSigners: 'Invalid number of provided signers',
    tokenErrorInvalidNumberOfRequiredSigners: 'Invalid number of required signers',
    tokenErrorUninitializedState: 'State is unititialized',
    tokenErrorNativeNotSupported: 'Instruction does not support native tokens',
    tokenErrorNonNativeHasBalance: 'Non-native account can only be closed if its balance is zero',
    tokenErrorInvalidInstruction: 'Invalid instruction',
    tokenErrorInvalidState: 'State is invalid for requested operation',
    tokenErrorOverflow: 'Operation overflowed',
    tokenErrorAuthorityTypeNotSupported: 'Account does not support specified authority type',
    tokenErrorMintCannotFreeze: 'This token mint cannot freeze accounts',
    tokenErrorAccountFrozen: 'Account is frozen',
    tokenErrorMintDecimalsMismatch: 'The provided decimals value different from the Mint decimals',
    tokenErrorNonNativeNotSupported: 'Instruction does not support non-native tokens',
};

/// Get the error message for a Token program error code.
String? getTokenErrorMessage(int code) {
  return _tokenErrorMessages[code];
}

/// Check if an error code belongs to the Token program.
bool isTokenError(int code) {
  return _tokenErrorMessages.containsKey(code);
}
