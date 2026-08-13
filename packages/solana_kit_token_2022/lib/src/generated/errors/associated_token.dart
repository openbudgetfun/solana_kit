// Auto-generated. Do not edit.
// ignore_for_file: type=lint, constant_identifier_names

/// Error codes for the AssociatedToken program.

/// InvalidOwner: Associated token account owner does not match address derivation
/// Message: "Associated token account owner does not match address derivation"
const int associatedTokenErrorInvalidOwner = 0x0; // 0

/// Map of error codes to human-readable messages.
const Map<int, String> _associatedTokenErrorMessages = {
    associatedTokenErrorInvalidOwner: 'Associated token account owner does not match address derivation',
};

/// Get the error message for a AssociatedToken program error code.
String? getAssociatedTokenErrorMessage(int code) {
  return _associatedTokenErrorMessages[code];
}

/// Check if an error code belongs to the AssociatedToken program.
bool isAssociatedTokenError(int code) {
  return _associatedTokenErrorMessages.containsKey(code);
}
