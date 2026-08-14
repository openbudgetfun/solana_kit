import 'dart:io';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_keys/solana_kit_keys.dart';
import 'package:solana_kit_rpc/solana_kit_rpc.dart';
import 'package:solana_kit_rpc_api/solana_kit_rpc_api.dart';
import 'package:solana_kit_rpc_spec/solana_kit_rpc_spec.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart'
    hide TransactionVersion;
import 'package:solana_kit_signers/solana_kit_signers.dart';
import 'package:solana_kit_surfpool/solana_kit_surfpool.dart';
import 'package:solana_kit_transaction_confirmation/solana_kit_transaction_confirmation.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';
import 'package:solana_kit_transactions/solana_kit_transactions.dart';

/// Default SurfPool RPC URL used by the `test:integration` workspace script.
const defaultSurfPoolRpcUrl = 'http://localhost:8899';

/// Default WebSocket URL for a local SurfPool instance.
const defaultSurfPoolWsUrl = 'ws://localhost:8900';

/// Default lamports funded to the integration test payer (10 SOL).
const defaultPayerLamports = 10_000_000_000;

/// A shared environment for on-chain integration tests against SurfPool.
///
/// Use [IntegrationTestEnv.create] to attach to an already-running SurfPool
/// instance (e.g. the one started by the `test:integration` workspace script)
/// or to start a fresh one when none is reachable. Tests fail loudly when
/// SurfPool cannot be reached or started — they never silently skip.
class IntegrationTestEnv {
  IntegrationTestEnv._({
    required this.rpc,
    required this.surfnet,
    required this.payer,
    required this.startedSurfnet,
  });

  /// The Solana RPC client bound to the local SurfPool instance.
  final Rpc rpc;

  /// The Surfnet wrapper used for cheatcode calls (funding, time travel, …).
  final Surfnet surfnet;

  /// A funded [KeyPairSigner] used as the default fee payer for tests.
  final KeyPairSigner payer;

  /// Whether this environment started the SurfPool process itself (and is
  /// therefore responsible for stopping it in [dispose]).
  final bool startedSurfnet;

  /// Attaches to a running SurfPool instance at [rpcUrl], or starts a fresh
  /// one on that URL when none is reachable.
  ///
  /// Throws when SurfPool is neither reachable nor startable, so integration
  /// tests fail loudly instead of silently skipping. The [payer] is funded
  /// with [payerLamports] lamports.
  static Future<IntegrationTestEnv> create({
    String rpcUrl = defaultSurfPoolRpcUrl,
    String wsUrl = defaultSurfPoolWsUrl,
    int payerLamports = defaultPayerLamports,
  }) async {
    final (surfnet, started) = await _connectOrStart(
      rpcUrl: rpcUrl,
      wsUrl: wsUrl,
    );
    final rpc = createSolanaRpc(url: rpcUrl, allowInsecureHttp: true);
    final payer = generateKeyPairSigner();
    await surfnet.fundSol(payer.address, payerLamports);
    return IntegrationTestEnv._(
      rpc: rpc,
      surfnet: surfnet,
      payer: payer,
      startedSurfnet: started,
    );
  }

  static Future<(Surfnet, bool)> _connectOrStart({
    required String rpcUrl,
    required String wsUrl,
  }) async {
    if (await isSurfPoolRunning(rpcUrl: rpcUrl)) {
      return (Surfnet.connect(rpcUrl: Uri.parse(rpcUrl)), false);
    }
    // No existing instance — start one on the requested ports so the RPC
    // client (which targets `rpcUrl`) can reach it.
    final rpcPort = Uri.parse(rpcUrl).port;
    final wsPort = Uri.parse(wsUrl).port;
    final surfnet = await Surfnet.start(
      config: SurfnetConfig(rpcPort: rpcPort, wsPort: wsPort),
    );
    return (surfnet, true);
  }

  /// Releases the resources held by this environment, stopping the SurfPool
  /// process when this environment started it.
  Future<void> dispose() => surfnet.stop();

  /// Returns a blockhash-based lifetime constraint using the latest blockhash.
  Future<BlockhashLifetimeConstraint> recentBlockhashLifetime() async {
    final result = await rpc.getLatestBlockhashValue().send();
    return BlockhashLifetimeConstraint(
      blockhash: result.value.blockhash.value,
      lastValidBlockHeight: result.value.lastValidBlockHeight,
    );
  }

  /// Builds, signs, sends, and confirms a transaction containing
  /// [instructions].
  ///
  /// The [payer] is the fee payer and signs the transaction. Any additional
  /// signers required by the instructions (e.g. mints, account owners) are
  /// attached to the relevant account metas via [extraSigners] and also sign.
  Future<Signature> sendInstructions(
    List<Instruction> instructions, {
    List<Object> extraSigners = const [],
  }) async {
    final allSigners = <Object>[payer, ...extraSigners];
    final instructionsWithSigners = instructions
        .map((instruction) => addSignersToInstruction(allSigners, instruction))
        .toList();
    final message = TransactionMessageWithFeePayerSigner(
      feePayerSigner: payer,
      version: TransactionVersion.v0,
      instructions: instructionsWithSigners,
      lifetimeConstraint: await recentBlockhashLifetime(),
    );
    final compiled = compileTransaction(message);
    final signed = await signTransactionMessageWithSigners(message);
    final signedWithLifetime = TransactionWithLifetime(
      messageBytes: signed.messageBytes,
      signatures: signed.signatures,
      lifetimeConstraint: compiled.lifetimeConstraint,
    );
    return sendAndConfirmTransaction(rpc: rpc, transaction: signedWithLifetime);
  }

  /// Deploys the compiled program at [soPath] to [programId] and waits for
  /// it to be executable.
  ///
  /// Programs bake their canonical program ID into the binary (`crate::ID`),
  /// so they must be deployed at that same address for PDA derivation and
  /// program-id checks to work. [soPath] is resolved relative to the workspace
  /// root (see [resolveWorkspaceArtifactPath]).
  Future<void> deployProgram(Address programId, String soPath) async {
    await surfnet.deploy(
      DeployOptions(
        programId: programId,
        soPath: resolveWorkspaceArtifactPath(soPath),
      ),
    );
  }

  /// Fetches the confirmed transaction for [signature] as raw JSON, or `null`
  /// when it cannot be found.
  Future<Map<String, Object?>?> fetchTransaction(Signature signature) async {
    return rpc
        .getTransaction(
          signature,
          const GetTransactionConfig(
            commitment: Commitment.confirmed,
            // Integration transactions are version 0; request up to that.
            maxSupportedTransactionVersion: 0,
          ),
        )
        .send();
  }

  /// Returns the log messages emitted by the confirmed transaction at
  /// [signature], or an empty list when unavailable.
  Future<List<String>> transactionLogMessages(Signature signature) async {
    final transaction = await fetchTransaction(signature);
    if (transaction == null) return const [];
    final meta = transaction['meta'];
    if (meta is! Map<String, Object?>) return const [];
    final logs = meta['logMessages'];
    if (logs is! List) return const [];
    return logs.whereType<String>().toList();
  }
}

/// Returns `true` when a SurfPool instance is reachable at [rpcUrl].
Future<bool> isSurfPoolRunning({
  String rpcUrl = defaultSurfPoolRpcUrl,
}) async {
  final rpc = createSolanaRpc(url: rpcUrl, allowInsecureHttp: true);
  try {
    await rpc.getSlot().send();
    return true;
  } on Object {
    return false;
  }
}

/// Resolves a workspace-relative artifact path (e.g. `config/programs/x.so`)
/// from wherever the test process is running.
///
/// The `test:integration` script runs from the workspace root, but running a
/// suite directly from the package directory needs two levels of `..`.
String resolveWorkspaceArtifactPath(String relativePath) {
  if (File(relativePath).existsSync()) return relativePath;
  final fromPackage = '../../$relativePath';
  if (File(fromPackage).existsSync()) return fromPackage;
  return relativePath;
}
