// Auto-generated. Do not edit.
// ignore_for_file: type=lint, constant_identifier_names

/// Error codes for the TokenVault program.

/// InvalidAuthority: The provided authority does not match the vault authority.
/// Message: "The provided authority does not match the vault authority."
const int tokenVaultErrorInvalidAuthority = 0x1770; // 6000

/// VaultFull: The vault has reached its maximum capacity.
/// Message: "The vault has reached its maximum capacity."
const int tokenVaultErrorVaultFull = 0x1771; // 6001

/// InsufficientFunds: Insufficient funds for this withdrawal.
/// Message: "Insufficient funds for this withdrawal."
const int tokenVaultErrorInsufficientFunds = 0x1772; // 6002

/// VaultNotActive: The vault is not in active status.
/// Message: "The vault is not in active status."
const int tokenVaultErrorVaultNotActive = 0x1773; // 6003

/// InvalidAmount: The specified amount is invalid.
/// Message: "The specified amount is invalid."
const int tokenVaultErrorInvalidAmount = 0x1774; // 6004

/// Map of error codes to human-readable messages.
const Map<int, String> _tokenVaultErrorMessages = {
    tokenVaultErrorInvalidAuthority: 'The provided authority does not match the vault authority.',
    tokenVaultErrorVaultFull: 'The vault has reached its maximum capacity.',
    tokenVaultErrorInsufficientFunds: 'Insufficient funds for this withdrawal.',
    tokenVaultErrorVaultNotActive: 'The vault is not in active status.',
    tokenVaultErrorInvalidAmount: 'The specified amount is invalid.',
};

/// Get the error message for a TokenVault program error code.
String? getTokenVaultErrorMessage(int code) {
  return _tokenVaultErrorMessages[code];
}

/// Check if an error code belongs to the TokenVault program.
bool isTokenVaultError(int code) {
  return _tokenVaultErrorMessages.containsKey(code);
}
