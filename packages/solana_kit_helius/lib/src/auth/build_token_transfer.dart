import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';
import 'package:solana_kit_helius/src/internal/json_rpc_client.dart';
import 'package:solana_kit_helius/src/transactions/send_via_sender.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_keys/solana_kit_keys.dart';
import 'package:solana_kit_token/solana_kit_token.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';
import 'package:solana_kit_transactions/solana_kit_transactions.dart';

/// Parameters for building and sending a USDC token transfer.
class TokenTransferParams {
  /// Creates token transfer parameters.
  const TokenTransferParams({
    required this.secretKey,
    required this.recipientAddress,
    required this.mintAddress,
    required this.amount,
    this.additionalInstructions = const [],
  });

  /// The 64-byte secret key of the sender.
  final Uint8List secretKey;

  /// The recipient wallet address.
  final String recipientAddress;

  /// The USDC mint address.
  final String mintAddress;

  /// The raw transfer amount.
  final BigInt amount;

  /// Additional instructions to append (e.g. a memo).
  final List<Instruction> additionalInstructions;
}

/// Builds and sends a USDC token transfer, returning the transaction
/// signature.
///
/// Mirrors upstream helius-sdk v3.0.0 `buildAndSendTokenTransfer`: derives
/// the sender and recipient associated token accounts, builds a transfer
/// instruction (plus any [TokenTransferParams.additionalInstructions]),
/// fetches a recent blockhash, signs with the sender keypair, and submits
/// the transaction via the Helius Sender endpoint.
Future<String> buildAndSendTokenTransfer(
  TokenTransferParams params, {
  JsonRpcClient? rpcClient,
  http.Client? client,
}) async {
  final keyPair = createKeyPairFromBytes(params.secretKey);
  final signerAddress = Address(
    getBase58Decoder().decode(keyPair.publicKey),
  );
  final recipient = Address(params.recipientAddress);
  final mint = Address(params.mintAddress);

  final (senderAta, _) = await findAssociatedTokenPda(
    seeds: AssociatedTokenSeeds(
      owner: signerAddress,
      tokenProgram: tokenProgramAddress,
      mint: mint,
    ),
  );
  final (receiverAta, _) = await findAssociatedTokenPda(
    seeds: AssociatedTokenSeeds(
      owner: recipient,
      tokenProgram: tokenProgramAddress,
      mint: mint,
    ),
  );

  final transferInstruction = getTransferInstruction(
    programAddress: tokenProgramAddress,
    source: senderAta,
    destination: receiverAta,
    authority: signerAddress,
    amount: params.amount,
  );

  // Fetch a recent blockhash for the transaction lifetime.
  final effectiveRpc = rpcClient;
  if (effectiveRpc == null) {
    throw StateError('An RPC client is required to fetch a recent blockhash.');
  }
  final blockhashResult = await effectiveRpc.call('getLatestBlockhash');
  final blockhashValue =
      (blockhashResult! as Map<String, Object?>)['value']! as Map<String, Object?>;
  final blockhash = blockhashValue['blockhash']! as String;

  var message = createTransactionMessage(version: TransactionVersion.v0);
  message = setTransactionMessageFeePayer(signerAddress, message);
  message = setTransactionMessageLifetimeUsingBlockhash(
    BlockhashLifetimeConstraint(
      blockhash: blockhash,
      lastValidBlockHeight: BigInt.from(
        blockhashValue['lastValidBlockHeight']! as int,
      ),
    ),
    message,
  );
  message = appendTransactionMessageInstructions(
    [transferInstruction, ...params.additionalInstructions],
    message,
  );

  final transaction = compileTransaction(message);
  final signed = await signTransaction([keyPair], transaction);
  final encoded = getTransactionEncoder().encode(signed);
  final base64Tx = base64Encode(encoded);

  return sendViaSender(base64Tx, client: client);
}
