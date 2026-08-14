import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_keys/solana_kit_keys.dart';
import 'package:solana_kit_rpc/solana_kit_rpc.dart';
import 'package:solana_kit_rpc_spec/solana_kit_rpc_spec.dart';
import 'package:solana_kit_signers/solana_kit_signers.dart';
import 'package:solana_kit_surfpool/solana_kit_surfpool.dart';
import 'package:solana_kit_transaction_confirmation/solana_kit_transaction_confirmation.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';
import 'package:solana_kit_transactions/solana_kit_transactions.dart';

/// Default SurfPool RPC URL used by the `test:integration` workspace script.
const defaultSurfPoolRpcUrl = 'http://localhost:8899';

/// Default lamports funded to the integration test payer (10 SOL).
const defaultPayerLamports = 10_000_000_000;

/// A shared environment for on-chain integration tests against SurfPool.
///
/// Connects to an already-running SurfPool instance (the `test:integration`
/// script starts one), mints a funded [payer], and provides helpers to send
/// transactions built from any program-client instruction.
class IntegrationTestEnv {
  IntegrationTestEnv._({
    required this.rpc,
    required this.surfnet,
    required this.payer,
  });

  /// The Solana RPC client bound to the local SurfPool instance.
  final Rpc rpc;

  /// The Surfnet wrapper used for cheatcode calls (funding, time travel, …).
  final Surfnet surfnet;

  /// A funded [KeyPairSigner] used as the default fee payer for tests.
  final KeyPairSigner payer;

  /// Connects to a running SurfPool instance at [rpcUrl] and funds [payer]
  /// with [payerLamports] lamports.
  ///
  /// SurfPool must already be running (the `test:integration` script starts
  /// it). Use `isSurfPoolRunning()` to detect whether it is reachable.
  static Future<IntegrationTestEnv> connect({
    String rpcUrl = defaultSurfPoolRpcUrl,
    int payerLamports = defaultPayerLamports,
  }) async {
    final rpc = createSolanaRpc(url: rpcUrl, allowInsecureHttp: true);
    final surfnet = Surfnet.connect(rpcUrl: Uri.parse(rpcUrl));
    final payer = generateKeyPairSigner();
    await surfnet.fundSol(payer.address, payerLamports);
    return IntegrationTestEnv._(rpc: rpc, surfnet: surfnet, payer: payer);
  }

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
