// ignore_for_file: avoid_print
/// Example 21: Helius DAS – fetch assets by owner (API-key required).
///
/// The Digital Asset Standard (DAS) API provides rich metadata for NFTs,
/// fungible tokens, and compressed assets.
///
/// ⚠️  Replace `YOUR_API_KEY` with a real key from https://helius.dev before
///     running.  The example uses mainnet; switch to devnet for testing.
///
/// Run:
///   dart examples/21_helius_das.dart
library;

import 'package:solana_kit_helius/solana_kit_helius.dart';

Future<void> main() async {
  const apiKey = 'YOUR_API_KEY'; // ← fill in

  // Guard: skip network calls when using the placeholder key.
  if (apiKey == 'YOUR_API_KEY') {
    print('Set a real Helius API key to run this example.');
    print('Get one free at https://helius.dev');
    _printStructureDoc();
    return;
  }

  final helius = createHelius(HeliusConfig(apiKey: apiKey));

  // ── 1. Fetch assets owned by a wallet ─────────────────────────────────────
  // Replace with any mainnet wallet address to see real data.
  const ownerAddress = '9B5XszUGdMaxCZ7uSQhPzdks5ZQSmWxrmzCSvtJ6Ns6g';

  print('Fetching assets for $ownerAddress …');
  final assetList = await helius.das.getAssetsByOwner(
    GetAssetsByOwnerRequest(ownerAddress: ownerAddress, page: 1, limit: 5),
  );

  print('Total assets: ${assetList.total}');
  for (final asset in assetList.items) {
    print('  id: ${asset.id}, '
        'name: ${asset.content?.metadata?.name ?? '<no name>'}');
  }

  // ── 2. Fetch a single asset by ID ─────────────────────────────────────────
  if (assetList.items.isNotEmpty) {
    final firstId = assetList.items.first.id;
    final detail = await helius.das.getAsset(GetAssetRequest(id: firstId));
    print('\nFirst asset interface: ${detail.interface_}');
  }
}

void _printStructureDoc() {
  print('''
GetAssetsByOwnerRequest fields:
  ownerAddress  String  – the wallet to query
  page          int     – 1-based page number
  limit         int     – items per page (max 1000)

AssetList fields:
  total         int            – total matching assets
  items         List<HeliusAsset>

HeliusAsset fields:
  id            String         – mint address
  interface     String?        – "V1_NFT", "FungibleToken", etc.
  content       AssetContent?  – metadata, files, links
''');
}
