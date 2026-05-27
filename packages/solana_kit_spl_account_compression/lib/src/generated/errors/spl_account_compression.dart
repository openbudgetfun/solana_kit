// Auto-generated. Do not edit.
// ignore_for_file: type=lint, constant_identifier_names

/// Error codes for the SPL Account Compression program.

/// IncorrectOwner: Account does not have correct owner
/// Message: "Account does not have correct owner"
const int splAccountCompressionErrorIncorrectOwner = 0x1770; // 6000

/// NotInitialized: Account is not initialized
/// Message: "Account is not initialized"
const int splAccountCompressionErrorNotInitialized = 0x1771; // 6001

/// ConcurrentLimitReached: Concurrent limit reached for this tree
/// Message: "Concurrent limit reached for this tree"
const int splAccountCompressionErrorConcurrentLimitReached = 0x1772; // 6002

/// IndexOutOfBounds: Index out of bounds
/// Message: "Index out of bounds"
const int splAccountCompressionErrorIndexOutOfBounds = 0x1773; // 6003

/// LeafAlreadyModified: Leaf already modified at this index
/// Message: "Leaf already modified at this index"
const int splAccountCompressionErrorLeafAlreadyModified = 0x1774; // 6004

/// LeafIndexAlreadyModifiedConcurrently: Leaf index already modified concurrently
/// Message: "Leaf index already modified concurrently"
const int splAccountCompressionErrorLeafIndexAlreadyModifiedConcurrently =
    0x1775; // 6005

/// ChangelogBufferFull: Changelog buffer is full
/// Message: "Changelog buffer is full"
const int splAccountCompressionErrorChangelogBufferFull = 0x1776; // 6006

/// IncorrectLeafHash: Incorrect leaf hash
/// Message: "Incorrect leaf hash"
const int splAccountCompressionErrorIncorrectLeafHash = 0x1777; // 6007

/// IncorrectRootHash: Incorrect root hash
/// Message: "Incorrect root hash"
const int splAccountCompressionErrorIncorrectRootHash = 0x1778; // 6008

/// AuthorityDoesNotMatch: Authority does not match
/// Message: "Authority does not match"
const int splAccountCompressionErrorAuthorityDoesNotMatch = 0x1779; // 6009

/// Map of error codes to human-readable messages.
const Map<int, String> _splAccountCompressionErrorMessages = {
  splAccountCompressionErrorIncorrectOwner:
      'Account does not have correct owner',
  splAccountCompressionErrorNotInitialized: 'Account is not initialized',
  splAccountCompressionErrorConcurrentLimitReached:
      'Concurrent limit reached for this tree',
  splAccountCompressionErrorIndexOutOfBounds: 'Index out of bounds',
  splAccountCompressionErrorLeafAlreadyModified:
      'Leaf already modified at this index',
  splAccountCompressionErrorLeafIndexAlreadyModifiedConcurrently:
      'Leaf index already modified concurrently',
  splAccountCompressionErrorChangelogBufferFull: 'Changelog buffer is full',
  splAccountCompressionErrorIncorrectLeafHash: 'Incorrect leaf hash',
  splAccountCompressionErrorIncorrectRootHash: 'Incorrect root hash',
  splAccountCompressionErrorAuthorityDoesNotMatch: 'Authority does not match',
};

/// Get the error message for an SPL Account Compression program error code.
String? getSplAccountCompressionErrorMessage(int code) {
  return _splAccountCompressionErrorMessages[code];
}

/// Check if an error code belongs to the SPL Account Compression program.
bool isSplAccountCompressionError(int code) {
  return _splAccountCompressionErrorMessages.containsKey(code);
}
