# solana_kit_mobile_wallet_adapter_protocol

Pure Dart implementation of the [Solana Mobile Wallet Adapter](https://github.com/solana-mobile/mobile-wallet-adapter) v2.0 protocol. Handles P-256 cryptography, session handshakes, encrypted message framing, JSON-RPC request/response encoding, association URI building/parsing, and protocol version negotiation.

This package has **zero Flutter dependency** and can be used in server-side Dart, CLI tools, or any Dart environment.

## Features

- **P-256 ECDSA/ECDH cryptography** via `pointycastle` (pure Dart, cross-platform)
- **AES-128-GCM encryption** with sequence number AAD for replay attack prevention
- **HKDF-SHA256** key derivation with association public key as salt
- **HELLO_REQ / HELLO_RSP** handshake for session establishment
- **JSON-RPC 2.0** message encryption/decryption
- **Association URI** building and parsing (local + remote)
- **Wallet proxy** with v1/legacy backwards compatibility
- **Sign In With Solana (SIWS)** message builder following EIP-4361
- **JWS ES256** compact serialization for attestation
- **Central error codes** integrated with `solana_kit_errors`

## Usage

### Association keypair generation

```dart
import 'package:solana_kit_mobile_wallet_adapter_protocol/solana_kit_mobile_wallet_adapter_protocol.dart';

// Generate keypairs for a new session.
final associationKeypair = generateAssociationKeypair();
final ecdhKeypair = generateEcdhKeypair();

// Get the association token (base64url-encoded public key).
final token = getAssociationToken(associationKeypair);
```

### Building association URIs

```dart
// Local association (same-device).
final uri = buildLocalAssociationUri(
  associationKeypair.publicKey,
  55123,
);
// -> solana-wallet:/v1/associate/local?association=...&port=55123

// Remote association (via reflector).
final remoteUri = buildRemoteAssociationUri(
  associationKeypair.publicKey,
  'reflect.example.com',
  reflectorId,
);
```

### HELLO handshake

```dart
// Create HELLO_REQ (129 bytes: 65B ECDH pubkey + 64B ECDSA signature).
final helloReq = createHelloReq(ecdhKeypair, associationKeypair);

// Parse HELLO_RSP from the wallet.
final result = parseHelloRsp(helloRspBytes, associationKeypair, ecdhKeypair);
final sharedSecret = result.sharedSecret; // 16-byte AES key
```

### Encrypted messaging

```dart
// Encrypt a JSON-RPC request.
final encrypted = encryptJsonRpcRequest(
  1, // sequence number
  'authorize',
  {'chain': 'solana:mainnet'},
  sharedSecret,
);

// Decrypt a JSON-RPC response.
final response = decryptJsonRpcResponse(encryptedBytes, sharedSecret);
```

### Wallet proxy

```dart
// Create a wallet proxy that handles v1/legacy compatibility.
final wallet = createMobileWalletProxy(sendRequest, sessionProps);

final authResult = await wallet.authorize({
  'identity': {'name': 'My dApp'},
  'chain': 'solana:mainnet',
});
```

## Protocol details

### Wire format

Each encrypted message follows this binary format:

```
[4B sequence number (big-endian)] [12B random IV] [ciphertext + 16B GCM tag]
```

The 4-byte sequence number is also used as AAD (Additional Authenticated Data) for AES-GCM, preventing replay attacks.

### Handshake flow

1. dApp generates association keypair (P-256 ECDSA) and ECDH keypair (P-256)
2. dApp sends HELLO_REQ: `[65B ECDH pubkey][64B ECDSA signature]`
3. Wallet sends HELLO_RSP: `[65B wallet ECDH pubkey][optional encrypted session props]`
4. Both sides derive shared secret via ECDH + HKDF-SHA256 -> 16-byte AES key
5. All subsequent messages use AES-128-GCM with incrementing sequence numbers

### Protocol versions

- **v1**: Uses chain identifiers (`solana:mainnet`, `solana:devnet`, `solana:testnet`), feature arrays, and separate `reauthorize` method
- **legacy**: Uses cluster names (`mainnet-beta`, `devnet`, `testnet`), boolean feature flags (`supports_sign_and_send_transactions`), and `authorize` with `auth_token` for reauthorization
