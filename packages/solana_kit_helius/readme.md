# solana_kit_helius

Helius SDK for the Solana Kit Dart SDK. A Dart port of the [Helius TypeScript SDK](https://github.com/helius-labs/helius-sdk), providing DAS API, enhanced transactions, webhooks, smart transactions, ZK compression, staking, wallet API, WebSocket subscriptions, and auth.

## Features

- **DAS API** - Digital Asset Standard methods for querying assets, proofs, and metadata
- **Enhanced Transactions** - Parsed transaction history with human-readable types
- **Webhooks** - Create, manage, and delete webhook subscriptions
- **Smart Transactions** - Optimized transaction building with compute unit estimation and priority fees
- **ZK Compression** - Compressed account and token operations via Light Protocol
- **Staking** - Create stake, unstake, and withdraw transactions via Helius validators
- **Wallet API** - Identity resolution, balances, history, and transfers
- **WebSockets** - Real-time subscription support
- **Auth** - Project and API key management
- **Priority Fees** - Estimate priority fees for transactions
- **RPC V2** - Enhanced RPC methods with pagination

## Usage

```dart
import 'package:solana_kit_helius/solana_kit_helius.dart';

final helius = createHelius(
  HeliusConfig(apiKey: 'your-api-key'),
);

// DAS API
final asset = await helius.das.getAsset(
  GetAssetRequest(id: 'asset-id'),
);

// Priority fees
final fees = await helius.priorityFee.getPriorityFeeEstimate(
  GetPriorityFeeEstimateRequest(
    accountKeys: ['account-key'],
  ),
);

// Enhanced transactions
final txns = await helius.enhanced.getTransactions(
  GetTransactionsRequest(transactions: ['tx-sig']),
);
```

## Configuration

```dart
// Mainnet (default)
final helius = createHelius(
  HeliusConfig(apiKey: 'your-api-key'),
);

// Devnet
final helius = createHelius(
  HeliusConfig(
    apiKey: 'your-api-key',
    cluster: HeliusCluster.devnet,
  ),
);

// Custom HTTP client (useful for testing)
import 'package:http/http.dart' as http;

final helius = createHelius(
  HeliusConfig(apiKey: 'your-api-key'),
  client: http.Client(),
);
```
