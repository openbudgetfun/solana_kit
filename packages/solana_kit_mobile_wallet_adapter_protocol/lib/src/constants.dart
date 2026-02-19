/// Retry delay schedule for WebSocket connection attempts, in milliseconds.
///
/// Uses Nyquist-frequency logic: 300ms UI threshold / 2 = 150ms initial delay,
/// with progressive backoff to 1000ms. The schedule repeats from the last
/// value once exhausted.
const List<int> mwaRetryDelayScheduleMs = [
  150,
  150,
  200,
  500,
  500,
  750,
  750,
  1000,
];

/// Total connection timeout in milliseconds.
const int mwaConnectionTimeoutMs = 30000;

/// WebSocket subprotocol for binary-encoded messages.
const String mwaWebSocketProtocolBinary = 'com.solana.mobilewalletadapter.v1';

/// WebSocket subprotocol for base64-encoded messages (used for remote
/// reflector connections).
const String mwaWebSocketProtocolBase64 =
    'com.solana.mobilewalletadapter.v1.base64';

/// Android Intent scheme for launching wallet apps.
const String mwaIntentScheme = 'solana-wallet';

/// Length of an X9.62 uncompressed P-256 public key in bytes.
///
/// Format: `0x04 || x(32) || y(32)` = 65 bytes.
const int mwaPublicKeyLengthBytes = 65;

/// Number of bytes used for the sequence number in encrypted messages.
const int mwaSequenceNumberBytes = 4;

/// Maximum sequence number value (2^32).
const int mwaMaxSequenceNumber = 4294967296;

/// Number of bytes for the AES-GCM initialization vector.
const int mwaIvBytes = 12;

/// AES-GCM authentication tag length in bits.
const int mwaGcmTagBits = 128;

/// Minimum valid association port (dynamic/private port range per RFC 6335).
const int mwaMinAssociationPort = 49152;

/// Maximum valid association port.
const int mwaMaxAssociationPort = 65535;

/// Maximum valid reflector ID (2^53 - 1, JavaScript safe integer limit).
const int mwaMaxReflectorId = 9007199254740991;

/// MWA feature identifier for signing transactions.
const String mwaFeatureSignTransactions = 'solana:signTransactions';

/// MWA feature identifier for signing and sending transactions.
const String mwaFeatureSignAndSendTransaction = 'solana:signAndSendTransaction';

/// MWA feature identifier for Sign In With Solana.
const String mwaFeatureSignInWithSolana = 'solana:signInWithSolana';

/// MWA feature identifier for cloning authorization tokens.
const String mwaFeatureCloneAuthorization = 'solana:cloneAuthorization';

/// WebSocket path for local association connections.
const String mwaLocalWebSocketPath = '/solana-wallet';

/// Association URI path for local connections.
const String mwaLocalAssociationPath = '/v1/associate/local';

/// Association URI path for remote connections.
const String mwaRemoteAssociationPath = '/v1/associate/remote';
