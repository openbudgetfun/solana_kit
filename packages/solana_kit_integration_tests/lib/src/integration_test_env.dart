import 'dart:convert';
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

/// Default lamports funded to the integration test payer (10 SOL).
const defaultPayerLamports = 10_000_000_000;

/// The `disable_sbpf_v0_v1_v2_deployment` feature gate.
///
/// The committed program artifacts are SBPF v0 ELFs; agave 4.2+ rejects
/// v0-v2 loader deploys unless this gate is disabled at SurfPool startup.
const disableSbpfV0V1V2DeploymentFeatureGate = Address(
  'B8JJXCy5amZyWG9r7EnUYLwzXSXTxG7GZ1qZ1qggo83g',
);

/// A shared environment for on-chain integration tests against SurfPool.
///
/// Use [IntegrationTestEnv.create] to start a fresh Surfpool instance for
/// the test file. Each instance binds auto-allocated ports, so parallel test
/// files each get an isolated chain. Tests fail loudly when Surfpool cannot
/// be started; they never silently skip.
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

  /// Starts a fresh Surfnet for this test file and returns an environment
  /// bound to it.
  ///
  /// Each call starts its own Surfpool instance on auto-allocated ports, so
  /// parallel test files each get an isolated chain with no port conflicts.
  /// The [payer] is funded with [payerLamports] lamports.
  static Future<IntegrationTestEnv> create({
    int payerLamports = defaultPayerLamports,
  }) async {
    final surfnet = await Surfnet.start(
      config: SurfnetConfig(
        // Clock-mode block production with 10ms slots: fast enough for the
        // address-lookup-table close test to age the SlotHashes sysvar (512
        // entries) in ~6s, while keeping the blockhash validity window (150
        // blocks = 1.5s) wide enough for parallel test execution.
        blockProductionMode: BlockProductionMode.clock,
        slotTimeMs: 10,
        // Allow loader-based deploys of the committed SBPF v0 artifacts.
        disableFeatures: const [disableSbpfV0V1V2DeploymentFeatureGate],
      ),
    );
    final rpc = createSolanaRpc(
      url: surfnet.rpcUrl,
      allowInsecureHttp: true,
    );
    final payer = generateKeyPairSigner();
    await surfnet.fundSol(payer.address, payerLamports);
    return IntegrationTestEnv._(
      rpc: rpc,
      surfnet: surfnet,
      payer: payer,
      startedSurfnet: true,
    );
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

  /// Builds, signs, sends, and confirms a version 1 transaction.
  ///
  /// Version 1 transactions (SIMD-0296 / SIMD-0385) allow up to 4096 bytes
  /// instead of the legacy 1232-byte ceiling. Unlike legacy and version 0
  /// transactions, v1 defaults both the compute unit limit and the loaded
  /// accounts data size limit to **zero**, so both must be set explicitly or
  /// the transaction fails at execution. [computeUnitLimit] and
  /// [loadedAccountsDataSizeLimit] default to values that are generous enough
  /// for the small instruction sets these tests use.
  Future<Signature> sendV1Instructions(
    List<Instruction> instructions, {
    List<Object> extraSigners = const [],
    int computeUnitLimit = 200000,
    int loadedAccountsDataSizeLimit = 262144,
    int? heapSize,
    BigInt? priorityFeeLamports,
  }) async {
    final allSigners = <Object>[payer, ...extraSigners];
    final instructionsWithSigners = instructions
        .map((instruction) => addSignersToInstruction(allSigners, instruction))
        .toList();
    final message = TransactionMessageWithFeePayerSigner(
      feePayerSigner: payer,
      version: TransactionVersion.v1,
      instructions: instructionsWithSigners,
      lifetimeConstraint: await recentBlockhashLifetime(),
      config: V1TransactionConfig(
        computeUnitLimit: computeUnitLimit,
        loadedAccountsDataSizeLimit: loadedAccountsDataSizeLimit,
        heapSize: heapSize,
        priorityFeeLamports: priorityFeeLamports,
      ),
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

  /// Signs and compiles a v1 transaction without sending it, returning the
  /// base64 wire form and its byte length.
  ///
  /// Useful for asserting on transaction size before submission.
  Future<({String wire, int byteLength})> buildV1WireTransaction(
    List<Instruction> instructions, {
    List<Object> extraSigners = const [],
    int computeUnitLimit = 200000,
    int loadedAccountsDataSizeLimit = 262144,
  }) async {
    final allSigners = <Object>[payer, ...extraSigners];
    final message = TransactionMessageWithFeePayerSigner(
      feePayerSigner: payer,
      version: TransactionVersion.v1,
      instructions: instructions
          .map(
            (instruction) => addSignersToInstruction(allSigners, instruction),
          )
          .toList(),
      lifetimeConstraint: await recentBlockhashLifetime(),
      config: V1TransactionConfig(
        computeUnitLimit: computeUnitLimit,
        loadedAccountsDataSizeLimit: loadedAccountsDataSizeLimit,
      ),
    );
    final signed = await signTransactionMessageWithSigners(message);
    final wire = getBase64EncodedWireTransaction(signed);
    return (wire: wire, byteLength: base64Decode(wire).length);
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
  ///
  /// Requests up to transaction version 1 so both v0 and v1 transactions can be
  /// read back. Reading a v1 transaction without `maxSupportedTransactionVersion:
  /// 1` fails with RPC error `-32015`.
  Future<Map<String, Object?>?> fetchTransaction(Signature signature) async {
    return rpc
        .getTransaction(
          signature,
          const GetTransactionConfig(
            commitment: Commitment.confirmed,
            maxSupportedTransactionVersion: 1,
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
