import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

import 'test_helpers.dart';

void main() {
  group('smart_transaction_types', () {
    expectJsonRoundTrip(
      'CreateSmartTransactionInput roundtrips',
      {
        'instructions': [
          {'programId': '1111'},
        ],
        'signers': ['signer-1'],
        'feePayer': 'payer-1',
        'computeUnitLimit': 1000,
        'computeUnitPrice': 2,
        'lookupTableAddresses': 'lookup-1',
      },
      CreateSmartTransactionInput.fromJson,
      (value) => value.toJson(),
    );

    expectJsonRoundTrip(
      'SmartTransactionResult roundtrips',
      {
        'signature': 'sig-1',
        'confirmationStatus': 'confirmed',
      },
      SmartTransactionResult.fromJson,
      (value) => value.toJson(),
    );

    expectJsonRoundTrip(
      'SendSmartTransactionInput roundtrips',
      {
        'instructions': [
          {'programId': '1111'},
        ],
        'signers': ['signer-1'],
        'feePayer': 'payer-1',
        'computeUnitPrice': 2,
        'skipPreflight': true,
        'maxRetries': 3,
      },
      SendSmartTransactionInput.fromJson,
      (value) => value.toJson(),
    );

    expectJsonRoundTrip(
      'BroadcastTransactionRequest roundtrips',
      {'transaction': 'base64-tx'},
      BroadcastTransactionRequest.fromJson,
      (value) => value.toJson(),
    );

    expectJsonRoundTrip(
      'PollTransactionConfirmationRequest roundtrips with commitment',
      {
        'signature': 'sig-1',
        'timeoutMs': 1000,
        'intervalMs': 100,
        'commitment': 'finalized',
      },
      PollTransactionConfirmationRequest.fromJson,
      (value) => value.toJson(),
    );

    expectJsonRoundTrip(
      'ComputeUnitsEstimate roundtrips',
      {'units': 12345},
      ComputeUnitsEstimate.fromJson,
      (value) => value.toJson(),
    );
  });

  group('auth_types', () {
    expectJsonRoundTrip(
      'AgenticSignupRequest roundtrips',
      {'walletAddress': 'wallet-1'},
      AgenticSignupRequest.fromJson,
      (value) => value.toJson(),
    );
    expectJsonRoundTrip(
      'AgenticSignupResponse roundtrips',
      {'apiKey': 'key-1', 'projectId': 'project-1'},
      AgenticSignupResponse.fromJson,
      (value) => value.toJson(),
    );
    expectJsonRoundTrip(
      'WalletSignupRequest roundtrips',
      {
        'walletAddress': 'wallet-1',
        'signature': 'sig-1',
        'message': 'hello',
      },
      WalletSignupRequest.fromJson,
      (value) => value.toJson(),
    );
    expectJsonRoundTrip(
      'WalletSignupResponse roundtrips',
      {'apiKey': 'key-1', 'projectId': 'project-1'},
      WalletSignupResponse.fromJson,
      (value) => value.toJson(),
    );
    expectJsonRoundTrip(
      'CreateProjectRequest roundtrips',
      {'name': 'My Project'},
      CreateProjectRequest.fromJson,
      (value) => value.toJson(),
    );
    expectJsonRoundTrip(
      'HeliusProject roundtrips',
      {
        'id': 'project-1',
        'name': 'My Project',
        'apiKey': 'key-1',
        'createdAt': 123456,
      },
      HeliusProject.fromJson,
      (value) => value.toJson(),
    );
    expectJsonRoundTrip(
      'CreateApiKeyRequest roundtrips',
      {'projectId': 'project-1', 'name': 'primary'},
      CreateApiKeyRequest.fromJson,
      (value) => value.toJson(),
    );
    expectJsonRoundTrip(
      'HeliusApiKey roundtrips',
      {
        'id': 'api-key-1',
        'key': 'secret',
        'name': 'primary',
        'createdAt': 123456,
      },
      HeliusApiKey.fromJson,
      (value) => value.toJson(),
    );
    expectJsonRoundTrip(
      'CheckBalancesResponse roundtrips',
      {'credits': 100, 'creditsUsed': 20},
      CheckBalancesResponse.fromJson,
      (value) => value.toJson(),
    );
    expectJsonRoundTrip(
      'KeypairResult roundtrips',
      {'publicKey': 'pub', 'secretKey': 'secret'},
      KeypairResult.fromJson,
      (value) => value.toJson(),
    );
    expectJsonRoundTrip(
      'SignAuthMessageRequest roundtrips',
      {'message': 'hello', 'secretKey': 'secret'},
      SignAuthMessageRequest.fromJson,
      (value) => value.toJson(),
    );
    expectJsonRoundTrip(
      'SignAuthMessageResponse roundtrips',
      {'signature': 'sig-1'},
      SignAuthMessageResponse.fromJson,
      (value) => value.toJson(),
    );
  });

  group('rpc_v2_types', () {
    expectJsonRoundTrip(
      'GetProgramAccountsV2Request roundtrips',
      {
        'programAddress': 'program-1',
        'filters': [
          {'dataSize': 42},
        ],
        'encoding': 'base64',
        'dataSlice': 12,
        'after': 'cursor-1',
        'limit': 20,
      },
      GetProgramAccountsV2Request.fromJson,
      (value) => value.toJson(),
    );
    expectJsonRoundTrip(
      'ProgramAccountV2 roundtrips',
      {
        'pubkey': 'pubkey-1',
        'account': {'lamports': 1},
      },
      ProgramAccountV2.fromJson,
      (value) => value.toJson(),
    );
    expectJsonRoundTrip(
      'GetProgramAccountsV2Response roundtrips',
      {
        'accounts': [
          {
            'pubkey': 'pubkey-1',
            'account': {'lamports': 1},
          },
        ],
        'cursor': 'cursor-1',
      },
      GetProgramAccountsV2Response.fromJson,
      (value) => value.toJson(),
    );
    expectJsonRoundTrip(
      'GetTokenAccountsByOwnerV2Request roundtrips',
      {
        'ownerAddress': 'owner-1',
        'mint': 'mint-1',
        'programId': 'program-1',
        'encoding': 'jsonParsed',
        'after': 'cursor-1',
        'limit': 10,
      },
      GetTokenAccountsByOwnerV2Request.fromJson,
      (value) => value.toJson(),
    );
    expectJsonRoundTrip(
      'TokenAccountV2 roundtrips',
      {
        'pubkey': 'pubkey-1',
        'account': {'owner': 'owner-1'},
      },
      TokenAccountV2.fromJson,
      (value) => value.toJson(),
    );
    expectJsonRoundTrip(
      'GetTokenAccountsByOwnerV2Response roundtrips',
      {
        'accounts': [
          {
            'pubkey': 'pubkey-1',
            'account': {'owner': 'owner-1'},
          },
        ],
        'cursor': 'cursor-1',
      },
      GetTokenAccountsByOwnerV2Response.fromJson,
      (value) => value.toJson(),
    );
    expectJsonRoundTrip(
      'GetTransactionsForAddressRequest roundtrips',
      {
        'address': 'owner-1',
        'before': 'sig-before',
        'until': 'sig-until',
        'limit': 10,
        'commitment': 'processed',
      },
      GetTransactionsForAddressRequest.fromJson,
      (value) => value.toJson(),
    );
    expectJsonRoundTrip(
      'TransactionForAddress roundtrips',
      {
        'signature': 'sig-1',
        'slot': 10,
        'blockTime': 123456,
      },
      TransactionForAddress.fromJson,
      (value) => value.toJson(),
    );
    expectJsonRoundTrip(
      'GetTransactionsForAddressResponse roundtrips',
      {
        'transactions': [
          {'signature': 'sig-1', 'slot': 10, 'blockTime': 123456},
        ],
      },
      GetTransactionsForAddressResponse.fromJson,
      (value) => value.toJson(),
    );
  });

  group('webhook_types', () {
    expectJsonRoundTrip(
      'Webhook roundtrips',
      {
        'webhookId': 'hook-1',
        'wallet': 'wallet-1',
        'webhookUrl': 'https://example.com',
        'transactionTypes': ['SWAP'],
        'accountAddresses': ['wallet-1'],
        'webhookType': 'enhanced',
        'authHeader': 'Bearer token',
      },
      Webhook.fromJson,
      (value) => value.toJson(),
    );
    expectJsonRoundTrip(
      'CreateWebhookRequest roundtrips',
      {
        'webhookUrl': 'https://example.com',
        'transactionTypes': ['SWAP'],
        'accountAddresses': ['wallet-1'],
        'webhookType': 'enhancedDevnet',
        'authHeader': 'Bearer token',
        'txnStatus': 'success',
      },
      CreateWebhookRequest.fromJson,
      (value) => value.toJson(),
    );

    test('UpdateWebhookRequest serializes webhookType using enum name', () {
      const request = UpdateWebhookRequest(
        webhookId: 'hook-1',
        webhookType: WebhookType.enhancedDevnet,
        webhookUrl: 'https://example.com',
      );

      expect(request.toJson(), {
        'webhookId': 'hook-1',
        'webhookUrl': 'https://example.com',
        'webhookType': 'enhancedDevnet',
      });
    });

    expectJsonRoundTrip(
      'UpdateWebhookRequest fromJson roundtrips for all optional fields',
      {
        'webhookId': 'hook-1',
        'webhookUrl': 'https://example.com',
        'transactionTypes': ['SWAP'],
        'accountAddresses': ['wallet-1'],
        'webhookType': 'raw',
        'authHeader': 'Bearer token',
        'txnStatus': 'failed',
      },
      UpdateWebhookRequest.fromJson,
      (value) => {
        'webhookId': value.webhookId,
        'webhookUrl': value.webhookUrl,
        'transactionTypes': value.transactionTypes,
        'accountAddresses': value.accountAddresses,
        'webhookType': value.webhookType?.toJson(),
        'authHeader': value.authHeader,
        'txnStatus': value.txnStatus,
      },
    );
  });

  group('staking_types', () {
    expectJsonRoundTrip(
      'CreateStakeTransactionRequest roundtrips',
      {'from': 'wallet-1', 'amount': 1000, 'validatorVote': 'vote-1'},
      CreateStakeTransactionRequest.fromJson,
      (value) => value.toJson(),
    );
    expectJsonRoundTrip(
      'CreateUnstakeTransactionRequest roundtrips',
      {'from': 'wallet-1', 'stakeAccount': 'stake-1'},
      CreateUnstakeTransactionRequest.fromJson,
      (value) => value.toJson(),
    );
    expectJsonRoundTrip(
      'CreateWithdrawTransactionRequest roundtrips',
      {'from': 'wallet-1', 'stakeAccount': 'stake-1', 'amount': 5},
      CreateWithdrawTransactionRequest.fromJson,
      (value) => value.toJson(),
    );
    expectJsonRoundTrip(
      'StakeAccountInfo roundtrips',
      {
        'address': 'stake-1',
        'lamports': 1000,
        'state': 'active',
        'voter': 'vote-1',
        'activationEpoch': 1,
        'deactivationEpoch': 2,
      },
      StakeAccountInfo.fromJson,
      (value) => value.toJson(),
    );
    expectJsonRoundTrip(
      'GetHeliusStakeAccountsRequest roundtrips',
      {'owner': 'wallet-1'},
      GetHeliusStakeAccountsRequest.fromJson,
      (value) => value.toJson(),
    );
    expectJsonRoundTrip(
      'GetWithdrawableAmountRequest roundtrips',
      {'stakeAccount': 'stake-1'},
      GetWithdrawableAmountRequest.fromJson,
      (value) => value.toJson(),
    );
    expectJsonRoundTrip(
      'WithdrawableAmount roundtrips',
      {'amount': 10},
      WithdrawableAmount.fromJson,
      (value) => value.toJson(),
    );
    expectJsonRoundTrip(
      'StakeTransactionResult roundtrips',
      {'transaction': 'base64-tx'},
      StakeTransactionResult.fromJson,
      (value) => value.toJson(),
    );
  });

  group('priority_fee_types', () {
    expectJsonRoundTrip(
      'PriorityFeeOptions roundtrips',
      {
        'priorityLevel': 'High',
        'includeAllPriorityFeeLevels': true,
        'transactionEncoding': 'base64',
        'lookbackSlots': true,
        'includeVote': false,
        'recommended': true,
      },
      PriorityFeeOptions.fromJson,
      (value) => value.toJson(),
    );
    expectJsonRoundTrip(
      'GetPriorityFeeEstimateRequest roundtrips',
      {
        'accountKeys': ['acct-1', 'acct-2'],
        'transaction': 'base64-tx',
        'options': {
          'priorityLevel': 'High',
          'includeAllPriorityFeeLevels': true,
          'transactionEncoding': 'base64',
          'lookbackSlots': true,
          'includeVote': false,
          'recommended': true,
        },
      },
      GetPriorityFeeEstimateRequest.fromJson,
      (value) => value.toJson(),
    );
    expectJsonRoundTrip(
      'MicroLamportPriorityFeeLevels roundtrips',
      {
        'min': 1.0,
        'low': 2.0,
        'medium': 3.0,
        'high': 4.0,
        'veryHigh': 5.0,
        'unsafeMax': 6.0,
      },
      MicroLamportPriorityFeeLevels.fromJson,
      (value) => value.toJson(),
    );
    expectJsonRoundTrip(
      'GetPriorityFeeEstimateResponse roundtrips',
      {
        'priorityFeeEstimate': 7.5,
        'priorityFeeLevels': {
          'min': 1.0,
          'low': 2.0,
          'medium': 3.0,
          'high': 4.0,
          'veryHigh': 5.0,
          'unsafeMax': 6.0,
        },
      },
      GetPriorityFeeEstimateResponse.fromJson,
      (value) => value.toJson(),
    );
  });
}
