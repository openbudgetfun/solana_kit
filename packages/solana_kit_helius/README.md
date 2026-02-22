# solana_kit_helius

[![pub package](https://img.shields.io/pub/v/solana_kit_helius.svg)](https://pub.dev/packages/solana_kit_helius)
[![docs](https://img.shields.io/badge/docs-pub.dev-0175C2.svg)](https://pub.dev/documentation/solana_kit_helius/latest/)
[![CI](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml)
[![coverage](https://codecov.io/gh/openbudgetfun/solana_kit/branch/main/graph/badge.svg)](https://codecov.io/gh/openbudgetfun/solana_kit)

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

## Installation

```bash
dart pub add solana_kit_helius
```

If you're working inside the `solana_kit` monorepo, workspace resolution uses local packages automatically.

## Documentation

- Package page: https://pub.dev/packages/solana_kit_helius
- API reference: https://pub.dev/documentation/solana_kit_helius/latest/

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
