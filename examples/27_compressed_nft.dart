// ignore_for_file: avoid_print
/// Example 27: Compressed NFTs with mpl-bubblegum.
///
/// Demonstrates the compressed NFT instruction builders and helpers.
///
/// ⚠️  Requires a running SurfPool instance at localhost:8899
///     for on-chain operations (not needed for instruction building demos).
///
/// Run:
///   dart examples/27_compressed_nft.dart
library;

import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_mpl_bubblegum/solana_kit_mpl_bubblegum.dart';
import 'package:solana_kit_rpc/solana_kit_rpc.dart';
import 'package:solana_kit_signers/solana_kit_signers.dart';

Future<void> main() async {
  // ── 1. Setup ─────────────────────────────────────────────────────────────
  final rpc = createSolanaRpc(
    url: 'http://localhost:8899',
    allowInsecureHttp: true,
  );

  final payer = generateKeyPairSigner();
  print('Payer: ${payer.address.value}');

  // Request airdrop (requires SurfPool)
  print('Requesting 10 SOL airdrop …');
  await rpc
      .requestAirdrop(
        payer.address,
        Lamports(BigInt.from(10000000000)),
      )
      .send();

  await Future<void>.delayed(const Duration(seconds: 5));

  final balance = await rpc.getBalanceValue(payer.address).send();
  print('Balance: ${balance.value} lamports');

  // ── 2. Program Addresses ─────────────────────────────────────────────────
  const bubblegumProgram = Address('BGUMAp9Gph7G9Jn2tU58R5L2qPG1Mj9HP7G3G7VYV2Ma');
  const compressionProgram = Address('cmtDvXzGgh4bcrDY2gZqFaGQqat4RNQPhKJ4jAc7uLi');
  const noopProgram = Address('noopb9bkMVz3tFhZ5L7bJGby9DreGG5J2P4V4Wxe8tK');
  const systemProgram = Address('11111111111111111111111111111111');

  // ── 3. Instruction Builders Demo ─────────────────────────────────────────
  print('\n=== Compressed NFT Instruction Builders ===\n');

  // Create Tree instruction
  final createTreeIx = getCreateTreeInstruction(
    programAddress: bubblegumProgram,
    treeAuthority: payer.address,
    merkleTree: payer.address,
    payer: payer.address,
    treeCreator: payer.address,
    logWrapper: noopProgram,
    compressionProgram: compressionProgram,
    systemProgram: systemProgram,
    maxDepth: 14,
    maxBufferSize: 64,
    public: true,
  );
  print('✅ createTree instruction built (${createTreeIx.data!.length} bytes)');

  // Burn instruction
  final burnIx = getBurnInstruction(
    programAddress: bubblegumProgram,
    treeAuthority: payer.address,
    leafOwner: payer.address,
    leafDelegate: payer.address,
    merkleTree: payer.address,
    logWrapper: noopProgram,
    compressionProgram: compressionProgram,
    systemProgram: systemProgram,
    root: List.filled(32, 0),
    dataHash: List.filled(32, 0),
    creatorHash: List.filled(32, 0),
    nonce: BigInt.zero,
    index: 0,
  );
  print('✅ burn instruction built (${burnIx.data!.length} bytes)');

  // Transfer instruction
  final transferIx = getTransferInstruction(
    programAddress: bubblegumProgram,
    treeAuthority: payer.address,
    leafOwner: payer.address,
    leafDelegate: payer.address,
    newLeafOwner: payer.address,
    merkleTree: payer.address,
    logWrapper: noopProgram,
    compressionProgram: compressionProgram,
    systemProgram: systemProgram,
    root: List.filled(32, 0),
    dataHash: List.filled(32, 0),
    creatorHash: List.filled(32, 0),
    nonce: BigInt.zero,
    index: 0,
  );
  print('✅ transfer instruction built (${transferIx.data!.length} bytes)');

  // Delegate instruction
  final delegateIx = getDelegateInstruction(
    programAddress: bubblegumProgram,
    treeAuthority: payer.address,
    leafOwner: payer.address,
    previousLeafDelegate: payer.address,
    newLeafDelegate: payer.address,
    merkleTree: payer.address,
    logWrapper: noopProgram,
    compressionProgram: compressionProgram,
    systemProgram: systemProgram,
    root: List.filled(32, 0),
    dataHash: List.filled(32, 0),
    creatorHash: List.filled(32, 0),
    nonce: BigInt.zero,
    index: 0,
  );
  print('✅ delegate instruction built (${delegateIx.data!.length} bytes)');

  // MintV1 instruction
  final mintIx = getMintV1Instruction(
    programAddress: bubblegumProgram,
    treeAuthority: payer.address,
    leafOwner: payer.address,
    leafDelegate: payer.address,
    merkleTree: payer.address,
    payer: payer.address,
    treeDelegate: payer.address,
    logWrapper: noopProgram,
    compressionProgram: compressionProgram,
    systemProgram: systemProgram,
    message: const MetadataArgs(
      name: 'My Compressed NFT',
      uri: 'https://example.com/metadata.json',
      sellerFeeBasisPoints: 500,
      creators: [
        Creator(
          address: Address('11111111111111111111111111111112'),
          verified: true,
          share: 100,
        ),
      ],
    ),
  );
  print('✅ mintV1 instruction built (${mintIx.data!.length} bytes)');

  // ── 4. Hashing Demo ─────────────────────────────────────────────────────
  print('\n=== Keccak-256 Hashing ===\n');

  final hash = bubblegumHash([
    Uint8List.fromList('Hello, compressed NFTs!'.codeUnits),
  ]);
  print('Hash: ${hash.map((b) => b.toRadixString(16).padLeft(2, '0')).join()}');
  print('Hash length: ${hash.length} bytes');

  // ── 5. Composite Helpers Demo ────────────────────────────────────────────
  print('\n=== Composite Helpers ===\n');

  // Create Tree plan
  getCreateTreeInstructionPlan(
    CreateTreeInput(
      merkleTree: payer.address,
      payer: payer.address,
      treeCreator: payer.address,
      maxDepth: 14,
      maxBufferSize: 64,
    ),
  );
  print('✅ createTree plan created');

  // Mint V1 plan
  getMintV1InstructionPlan(
    MintV1Input(
      merkleTree: payer.address,
      leafOwner: payer.address,
      leafDelegate: payer.address,
      payer: payer.address,
      treeDelegate: payer.address,
      name: 'My Compressed NFT',
      uri: 'https://example.com/metadata.json',
    ),
  );
  print('✅ mintV1 plan created');

  // Burn plan
  getBurnInstructionPlan(
    BurnInput(
      root: List.filled(32, 0),
      dataHash: List.filled(32, 0),
      creatorHash: List.filled(32, 0),
      nonce: BigInt.zero,
      index: 0,
      leafOwner: payer.address,
      leafDelegate: payer.address,
      merkleTree: payer.address,
    ),
  );
  print('✅ burn plan created');

  // Transfer plan
  getTransferInstructionPlan(
    TransferInput(
      root: List.filled(32, 0),
      dataHash: List.filled(32, 0),
      creatorHash: List.filled(32, 0),
      nonce: BigInt.zero,
      index: 0,
      leafOwner: payer.address,
      leafDelegate: payer.address,
      merkleTree: payer.address,
      newLeafOwner: payer.address,
    ),
  );
  print('✅ transfer plan created');

  // Delegate plan
  getDelegateInstructionPlan(
    DelegateInput(
      root: List.filled(32, 0),
      dataHash: List.filled(32, 0),
      creatorHash: List.filled(32, 0),
      nonce: BigInt.zero,
      index: 0,
      leafOwner: payer.address,
      previousDelegate: payer.address,
      newDelegate: payer.address,
      merkleTree: payer.address,
    ),
  );
  print('✅ delegate plan created');

  // ── 6. canTransfer Demo ──────────────────────────────────────────────────
  print('\n=== Transfer Eligibility ===\n');

  final canTransferResult = canTransfer(
    frozen: false,
    nonTransferable: false,
  );
  print('Can transfer (not frozen, transferable): $canTransferResult');

  final cannotTransfer = canTransfer(
    frozen: true,
    nonTransferable: false,
  );
  print('Can transfer (frozen): $cannotTransfer');

  // ── 7. PDA Derivation Demo ───────────────────────────────────────────────
  print('\n=== PDA Derivation ===\n');

  // Note: PDA derivation is async and requires the full Ed25519 curve check
  print('Tree Authority PDA: findTreeAuthorityPda(merkleTree: ...) → Future<PDA>');
  print('Leaf Asset ID PDA: findLeafAssetIdPda(merkleTree:, nonce:, index:) → Future<PDA>');
  print('Bubblegum Signer PDA: findBubblegumSignerPda() → Future<PDA>');

  print('\n✅ All examples completed successfully!');
  print('To run on-chain tests, start SurfPool and run:');
  print('  dart test test/integration/ --tags integration');
}
