/// ATA program error code for an owner that does not match PDA derivation.
const int associatedTokenErrorInvalidOwner = 0x0;

const Map<int, String> _associatedTokenErrorMessages = {
  associatedTokenErrorInvalidOwner:
      'Associated token account owner does not match address derivation',
};

/// Returns the message for an ATA program error [code], if known.
String? getAssociatedTokenErrorMessage(int code) {
  return _associatedTokenErrorMessages[code];
}

/// Returns `true` when [code] is a known ATA program error.
bool isAssociatedTokenError(int code) {
  return _associatedTokenErrorMessages.containsKey(code);
}
