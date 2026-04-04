// Auto-generated. Do not edit.
// ignore_for_file: type=lint, constant_identifier_names

/// Error codes for the Token2022 program.

/// NotRentExempt: Lamport balance below rent-exempt threshold
/// Message: "Lamport balance below rent-exempt threshold"
const int token2022ErrorNotRentExempt = 0x0; // 0

/// InsufficientFunds: Insufficient funds
/// Message: "Insufficient funds"
const int token2022ErrorInsufficientFunds = 0x1; // 1

/// InvalidMint: Invalid Mint
/// Message: "Invalid Mint"
const int token2022ErrorInvalidMint = 0x2; // 2

/// MintMismatch: Account not associated with this Mint
/// Message: "Account not associated with this Mint"
const int token2022ErrorMintMismatch = 0x3; // 3

/// OwnerMismatch: Owner does not match
/// Message: "Owner does not match"
const int token2022ErrorOwnerMismatch = 0x4; // 4

/// FixedSupply: Fixed supply
/// Message: "Fixed supply"
const int token2022ErrorFixedSupply = 0x5; // 5

/// AlreadyInUse: Already in use
/// Message: "Already in use"
const int token2022ErrorAlreadyInUse = 0x6; // 6

/// InvalidNumberOfProvidedSigners: Invalid number of provided signers
/// Message: "Invalid number of provided signers"
const int token2022ErrorInvalidNumberOfProvidedSigners = 0x7; // 7

/// InvalidNumberOfRequiredSigners: Invalid number of required signers
/// Message: "Invalid number of required signers"
const int token2022ErrorInvalidNumberOfRequiredSigners = 0x8; // 8

/// UninitializedState: State is unititialized
/// Message: "State is unititialized"
const int token2022ErrorUninitializedState = 0x9; // 9

/// NativeNotSupported: Instruction does not support native tokens
/// Message: "Instruction does not support native tokens"
const int token2022ErrorNativeNotSupported = 0xa; // 10

/// NonNativeHasBalance: Non-native account can only be closed if its balance is zero
/// Message: "Non-native account can only be closed if its balance is zero"
const int token2022ErrorNonNativeHasBalance = 0xb; // 11

/// InvalidInstruction: Invalid instruction
/// Message: "Invalid instruction"
const int token2022ErrorInvalidInstruction = 0xc; // 12

/// InvalidState: State is invalid for requested operation
/// Message: "State is invalid for requested operation"
const int token2022ErrorInvalidState = 0xd; // 13

/// Overflow: Operation overflowed
/// Message: "Operation overflowed"
const int token2022ErrorOverflow = 0xe; // 14

/// AuthorityTypeNotSupported: Account does not support specified authority type
/// Message: "Account does not support specified authority type"
const int token2022ErrorAuthorityTypeNotSupported = 0xf; // 15

/// MintCannotFreeze: This token mint cannot freeze accounts
/// Message: "This token mint cannot freeze accounts"
const int token2022ErrorMintCannotFreeze = 0x10; // 16

/// AccountFrozen: Account is frozen
/// Message: "Account is frozen"
const int token2022ErrorAccountFrozen = 0x11; // 17

/// MintDecimalsMismatch: The provided decimals value different from the Mint decimals
/// Message: "The provided decimals value different from the Mint decimals"
const int token2022ErrorMintDecimalsMismatch = 0x12; // 18

/// NonNativeNotSupported: Instruction does not support non-native tokens
/// Message: "Instruction does not support non-native tokens"
const int token2022ErrorNonNativeNotSupported = 0x13; // 19

/// Map of error codes to human-readable messages.
const Map<int, String> _token2022ErrorMessages = {
    token2022ErrorNotRentExempt: 'Lamport balance below rent-exempt threshold',
    token2022ErrorInsufficientFunds: 'Insufficient funds',
    token2022ErrorInvalidMint: 'Invalid Mint',
    token2022ErrorMintMismatch: 'Account not associated with this Mint',
    token2022ErrorOwnerMismatch: 'Owner does not match',
    token2022ErrorFixedSupply: 'Fixed supply',
    token2022ErrorAlreadyInUse: 'Already in use',
    token2022ErrorInvalidNumberOfProvidedSigners: 'Invalid number of provided signers',
    token2022ErrorInvalidNumberOfRequiredSigners: 'Invalid number of required signers',
    token2022ErrorUninitializedState: 'State is unititialized',
    token2022ErrorNativeNotSupported: 'Instruction does not support native tokens',
    token2022ErrorNonNativeHasBalance: 'Non-native account can only be closed if its balance is zero',
    token2022ErrorInvalidInstruction: 'Invalid instruction',
    token2022ErrorInvalidState: 'State is invalid for requested operation',
    token2022ErrorOverflow: 'Operation overflowed',
    token2022ErrorAuthorityTypeNotSupported: 'Account does not support specified authority type',
    token2022ErrorMintCannotFreeze: 'This token mint cannot freeze accounts',
    token2022ErrorAccountFrozen: 'Account is frozen',
    token2022ErrorMintDecimalsMismatch: 'The provided decimals value different from the Mint decimals',
    token2022ErrorNonNativeNotSupported: 'Instruction does not support non-native tokens',
};

/// Get the error message for a Token2022 program error code.
String? getToken2022ErrorMessage(int code) {
  return _token2022ErrorMessages[code];
}

/// Check if an error code belongs to the Token2022 program.
bool isToken2022Error(int code) {
  return _token2022ErrorMessages.containsKey(code);
}
