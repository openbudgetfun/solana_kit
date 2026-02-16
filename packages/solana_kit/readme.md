# solana_kit

The Solana Kit Dart SDK -- a comprehensive, modular Dart port of the [Solana TypeScript SDK (`@solana/kit`)](https://github.com/anza-xyz/kit).

This is the umbrella package that re-exports all 35 public packages in the SDK, giving you a single import for the entire Solana development toolkit.

## Installation

Add `solana_kit` to your `pubspec.yaml`:

```yaml
dependencies:
  solana_kit:
```

Then import everything with a single line:

```dart
import 'package:solana_kit/solana_kit.dart';
```

## Quick start

```dart
import 'package:solana_kit/solana_kit.dart';

Future<void> main() async {
  // 1. Create an RPC client.
  final rpc = createSolanaRpc('https://api.devnet.solana.com');

  // 2. Generate a new Ed25519 key pair.
  final keyPair = await generateKeyPair();
  final signer = await createKeyPairSignerFromKeyPair(keyPair);
  print('Address: ${signer.address}');

  // 3. Check the balance.
  final balanceResponse = await rpc.request('getBalance', [
    signer.address.value,
    {'commitment': 'confirmed'},
  ]).send();
  print('Balance: $balanceResponse');

  // 4. Fetch an account.
  final account = await fetchEncodedAccount(
    rpc,
    const Address('11111111111111111111111111111111'),
  );
  if (account.exists) {
    print('System program account exists');
  }
}
```

## Usage

### Addresses

Create, validate, and derive Solana addresses.

```dart
import 'package:solana_kit/solana_kit.dart';

Future<void> main() async {
  // Validate an address.
  final addr = address('11111111111111111111111111111112');
  print(isAddress('11111111111111111111111111111112')); // true

  // Derive a program-derived address (PDA).
  const tokenProgram = Address('TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA');
  final (pda, bump) = await getProgramDerivedAddress(
    programAddress: tokenProgram,
    seeds: ['metadata'],
  );
  print('PDA: ${pda.value}, bump: $bump');
}
```

### Keys and signers

Generate key pairs and create transaction signers.

```dart
import 'package:solana_kit/solana_kit.dart';

Future<void> main() async {
  // Generate a new key pair.
  final keyPair = await generateKeyPair();

  // Create a signer from the key pair.
  final signer = await createKeyPairSignerFromKeyPair(keyPair);
  print('Signer address: ${signer.address}');

  // Sign a message.
  final signature = await signer.signMessages([
    Uint8List.fromList('Hello Solana'.codeUnits),
  ]);
  print('Signed: ${signature.length} signature(s)');
}
```

### RPC client

Make JSON-RPC calls to a Solana node.

```dart
import 'package:solana_kit/solana_kit.dart';

Future<void> main() async {
  final rpc = createSolanaRpc('https://api.devnet.solana.com');

  // Get the latest blockhash.
  final blockhashResponse = await rpc.request('getLatestBlockhash', [
    {'commitment': 'confirmed'},
  ]).send();
  print('Blockhash: $blockhashResponse');

  // Get the minimum balance for rent exemption.
  final rentExemption = getMinimumBalanceForRentExemption(165);
  print('Rent exemption for 165 bytes: ${rentExemption.value} lamports');
}
```

### Accounts

Fetch and decode on-chain accounts.

```dart
import 'package:solana_kit/solana_kit.dart';

Future<void> main() async {
  final rpc = createSolanaRpc('https://api.devnet.solana.com');

  // Fetch a single account.
  final maybeAccount = await fetchEncodedAccount(
    rpc,
    const Address('11111111111111111111111111111111'),
  );

  switch (maybeAccount) {
    case ExistingAccount(:final account):
      print('Lamports: ${account.lamports}');
      print('Data: ${account.data.length} bytes');
      print('Owner: ${account.programAddress}');
    case NonExistingAccount(:final address):
      print('Account not found at $address');
  }

  // Fetch multiple accounts at once.
  final accounts = await fetchEncodedAccounts(rpc, [
    const Address('11111111111111111111111111111111'),
    const Address('TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA'),
  ]);
  print('Fetched ${accounts.length} accounts');
}
```

### Codecs

Encode and decode binary data for on-chain structures.

```dart
import 'package:solana_kit/solana_kit.dart';

void main() {
  // Encode and decode addresses.
  final addr = address('11111111111111111111111111111111');
  final encoder = getAddressEncoder();
  final bytes = encoder.encode(addr);
  print('Address encoded to ${bytes.length} bytes'); // 32

  // Encode and decode numbers.
  final u64Encoder = getU64Encoder();
  final numBytes = u64Encoder.encode(BigInt.from(1000000));
  print('U64 encoded to ${numBytes.length} bytes'); // 8
}
```

### Sysvars

Access Solana system variables.

```dart
import 'package:solana_kit/solana_kit.dart';

Future<void> main() async {
  final rpc = createSolanaRpc('https://api.devnet.solana.com');

  // Fetch the Clock sysvar.
  final clock = await fetchSysvarClock(rpc);
  print('Current slot: ${clock.slot}');
  print('Current epoch: ${clock.epoch}');
  print('Unix timestamp: ${clock.unixTimestamp}');

  // Fetch the Rent sysvar.
  final rent = await fetchSysvarRent(rpc);
  print('Lamports per byte-year: ${rent.lamportsPerByteYear}');

  // All sysvar addresses are available as constants.
  print('Clock: ${sysvarClockAddress.value}');
  print('Rent: ${sysvarRentAddress.value}');
}
```

### RPC subscriptions

Subscribe to real-time notifications over WebSocket.

```dart
import 'package:solana_kit/solana_kit.dart';

Future<void> main() async {
  final subscriptions = createSolanaRpcSubscriptions(
    'wss://api.devnet.solana.com',
  );

  final controller = AbortController();

  // Subscribe to slot notifications.
  final pending = subscriptions.request('slotNotifications');
  final stream = await pending.subscribe(
    RpcSubscribeOptions(abortSignal: controller.signal),
  );

  var count = 0;
  await for (final notification in stream) {
    print('Slot: $notification');
    count++;
    if (count >= 3) {
      controller.abort();
    }
  }
}
```

### Transaction confirmation

Confirm transactions using multiple strategies.

```dart
import 'package:solana_kit/solana_kit.dart';

void main() {
  // Compare commitment levels.
  print(commitmentComparator(Commitment.finalized, Commitment.confirmed) > 0);
  // true -- finalized is higher than confirmed

  // Calculate rent exemption without an RPC call.
  final balance = getMinimumBalanceForRentExemption(165);
  print('Minimum balance: ${balance.value} lamports');
}
```

### Error handling

All errors in the SDK are structured `SolanaError` instances.

```dart
import 'package:solana_kit/solana_kit.dart';

void main() {
  try {
    // This will throw because the string is not a valid address.
    address('not-valid');
  } on SolanaError catch (e) {
    print('Error code: ${e.code}');
    print('Message: $e');
    if (isSolanaError(e, SolanaErrorCode.addressesInvalidBase58EncodedAddress)) {
      print('Invalid address format');
    }
  }
}
```

## Re-exported packages

This umbrella package re-exports the following packages:

| Package | Description |
|---------|-------------|
| `solana_kit_accounts` | Account fetching and decoding |
| `solana_kit_addresses` | Base58 address utilities and PDA derivation |
| `solana_kit_codecs` | Codec umbrella (core, numbers, strings, data structures) |
| `solana_kit_errors` | Error codes, error class, and error conversion |
| `solana_kit_fast_stable_stringify` | Deterministic JSON serialization |
| `solana_kit_functional` | Functional programming utilities (pipe, compose) |
| `solana_kit_instruction_plans` | Instruction plan composition |
| `solana_kit_instructions` | Instruction types and account meta |
| `solana_kit_keys` | Key pair generation and signature types |
| `solana_kit_offchain_messages` | Off-chain message signing |
| `solana_kit_options` | Borsh-compatible Option codec |
| `solana_kit_program_client_core` | Program client building blocks |
| `solana_kit_programs` | Program error identification |
| `solana_kit_rpc` | RPC client factory |
| `solana_kit_rpc_parsed_types` | Parsed RPC response types |
| `solana_kit_rpc_spec_types` | RPC specification types |
| `solana_kit_rpc_subscriptions` | WebSocket subscription client |
| `solana_kit_rpc_transport_http` | HTTP transport for RPC |
| `solana_kit_rpc_types` | RPC type definitions (Commitment, Lamports, etc.) |
| `solana_kit_signers` | Transaction signer abstractions |
| `solana_kit_subscribable` | Pub/sub event patterns |
| `solana_kit_sysvars` | System variable account access |
| `solana_kit_transaction_confirmation` | Transaction confirmation strategies |
| `solana_kit_transaction_messages` | Transaction message building |
| `solana_kit_transactions` | Transaction types and serialization |

### Umbrella-specific helpers

| Function | Description |
|----------|-------------|
| `getMinimumBalanceForRentExemption(int space)` | Calculates the minimum lamports for rent exemption without an RPC call. Uses on-chain rent parameters from the Solana runtime. |

## API Reference

Since this is an umbrella package, the complete API is the union of all re-exported packages. Refer to each package's readme for detailed API documentation:

- [solana_kit_errors](../solana_kit_errors/readme.md)
- [solana_kit_addresses](../solana_kit_addresses/readme.md)
- [solana_kit_accounts](../solana_kit_accounts/readme.md)
- [solana_kit_sysvars](../solana_kit_sysvars/readme.md)
- [solana_kit_rpc_subscriptions](../solana_kit_rpc_subscriptions/readme.md)
- [solana_kit_subscribable](../solana_kit_subscribable/readme.md)
- [solana_kit_programs](../solana_kit_programs/readme.md)
- [solana_kit_program_client_core](../solana_kit_program_client_core/readme.md)
- [solana_kit_transaction_confirmation](../solana_kit_transaction_confirmation/readme.md)
