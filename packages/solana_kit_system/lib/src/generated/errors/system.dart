// Auto-generated. Do not edit.
// ignore_for_file: type=lint, constant_identifier_names

/// Error codes for the System program.

/// AccountAlreadyInUse: an account with the same address already exists
/// Message: "an account with the same address already exists"
const int systemErrorAccountAlreadyInUse = 0x0; // 0

/// ResultWithNegativeLamports: account does not have enough SOL to perform the operation
/// Message: "account does not have enough SOL to perform the operation"
const int systemErrorResultWithNegativeLamports = 0x1; // 1

/// InvalidProgramId: cannot assign account to this program id
/// Message: "cannot assign account to this program id"
const int systemErrorInvalidProgramId = 0x2; // 2

/// InvalidAccountDataLength: cannot allocate account data of this length
/// Message: "cannot allocate account data of this length"
const int systemErrorInvalidAccountDataLength = 0x3; // 3

/// MaxSeedLengthExceeded: length of requested seed is too long
/// Message: "length of requested seed is too long"
const int systemErrorMaxSeedLengthExceeded = 0x4; // 4

/// AddressWithSeedMismatch: provided address does not match addressed derived from seed
/// Message: "provided address does not match addressed derived from seed"
const int systemErrorAddressWithSeedMismatch = 0x5; // 5

/// NonceNoRecentBlockhashes: advancing stored nonce requires a populated RecentBlockhashes sysvar
/// Message: "advancing stored nonce requires a populated RecentBlockhashes sysvar"
const int systemErrorNonceNoRecentBlockhashes = 0x6; // 6

/// NonceBlockhashNotExpired: stored nonce is still in recent_blockhashes
/// Message: "stored nonce is still in recent_blockhashes"
const int systemErrorNonceBlockhashNotExpired = 0x7; // 7

/// NonceUnexpectedBlockhashValue: specified nonce does not match stored nonce
/// Message: "specified nonce does not match stored nonce"
const int systemErrorNonceUnexpectedBlockhashValue = 0x8; // 8

/// Map of error codes to human-readable messages.
const Map<int, String> _systemErrorMessages = {
    systemErrorAccountAlreadyInUse: 'an account with the same address already exists',
    systemErrorResultWithNegativeLamports: 'account does not have enough SOL to perform the operation',
    systemErrorInvalidProgramId: 'cannot assign account to this program id',
    systemErrorInvalidAccountDataLength: 'cannot allocate account data of this length',
    systemErrorMaxSeedLengthExceeded: 'length of requested seed is too long',
    systemErrorAddressWithSeedMismatch: 'provided address does not match addressed derived from seed',
    systemErrorNonceNoRecentBlockhashes: 'advancing stored nonce requires a populated RecentBlockhashes sysvar',
    systemErrorNonceBlockhashNotExpired: 'stored nonce is still in recent_blockhashes',
    systemErrorNonceUnexpectedBlockhashValue: 'specified nonce does not match stored nonce',
};

/// Get the error message for a System program error code.
String? getSystemErrorMessage(int code) {
  return _systemErrorMessages[code];
}

/// Check if an error code belongs to the System program.
bool isSystemError(int code) {
  return _systemErrorMessages.containsKey(code);
}
