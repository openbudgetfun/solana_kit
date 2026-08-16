import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';
import 'package:solana_kit_helius/src/auth/build_token_transfer.dart';
import 'package:solana_kit_helius/src/auth/constants.dart';
import 'package:solana_kit_helius/src/internal/json_rpc_client.dart';
import 'package:solana_kit_helius/src/types/auth_types.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_keys/solana_kit_keys.dart';

/// Sends 1 USDC (6 decimals) to the Helius treasury, returning the
/// transaction signature.
Future<String> payUSDC(
  Uint8List secretKey, {
  JsonRpcClient? rpcClient,
  http.Client? client,
}) {
  return buildAndSendTokenTransfer(
    TokenTransferParams(
      secretKey: secretKey,
      recipientAddress: treasury,
      mintAddress: usdcMint,
      amount: paymentAmount,
    ),
    rpcClient: rpcClient,
    client: client,
  );
}

/// Sends [amount] USDC to [treasuryAddress] with an optional [memo],
/// returning the transaction signature.
Future<String> payWithMemo(
  Uint8List secretKey,
  String treasuryAddress,
  BigInt amount,
  String memo, {
  JsonRpcClient? rpcClient,
  http.Client? client,
}) {
  final signerAddress = Address(
    getBase58Decoder().decode(createKeyPairFromBytes(secretKey).publicKey),
  );
  final memoInstruction = Instruction(
    programAddress: const Address(memoProgramId),
    accounts: [
      AccountMeta(address: signerAddress, role: AccountRole.readonlySigner),
    ],
    data: utf8.encode(memo),
  );
  return buildAndSendTokenTransfer(
    TokenTransferParams(
      secretKey: secretKey,
      recipientAddress: treasuryAddress,
      mintAddress: usdcMint,
      amount: amount,
      additionalInstructions: [memoInstruction],
    ),
    rpcClient: rpcClient,
    client: client,
  );
}

final _centsToUsdcRaw = BigInt.from(10000);

/// Pays a hosted-checkout [paymentLink], returning the transaction signature.
Future<String> payPaymentLink(
  Uint8List secretKey,
  PaymentLink paymentLink, {
  JsonRpcClient? rpcClient,
  http.Client? client,
}) {
  final rawAmount = BigInt.from(paymentLink.amountCents) * _centsToUsdcRaw;
  return payWithMemo(
    secretKey,
    paymentLink.destinationWallet,
    rawAmount,
    paymentLink.paymentIntentId,
    rpcClient: rpcClient,
    client: client,
  );
}
