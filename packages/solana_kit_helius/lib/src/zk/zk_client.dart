import 'package:solana_kit_helius/src/internal/json_rpc_client.dart';
import 'package:solana_kit_helius/src/types/zk_types.dart';
import 'package:solana_kit_helius/src/zk/get_compressed_account.dart';
import 'package:solana_kit_helius/src/zk/get_compressed_account_proof.dart';
import 'package:solana_kit_helius/src/zk/get_compressed_accounts_by_owner.dart';
import 'package:solana_kit_helius/src/zk/get_compressed_balance.dart';
import 'package:solana_kit_helius/src/zk/get_compressed_balance_by_owner.dart';
import 'package:solana_kit_helius/src/zk/get_compressed_mint_token_holders.dart';
import 'package:solana_kit_helius/src/zk/get_compressed_token_account_balance.dart';
import 'package:solana_kit_helius/src/zk/get_compressed_token_accounts_by_delegate.dart';
import 'package:solana_kit_helius/src/zk/get_compressed_token_accounts_by_owner.dart';
import 'package:solana_kit_helius/src/zk/get_compressed_token_balances_by_owner.dart';
import 'package:solana_kit_helius/src/zk/get_compressed_token_balances_by_owner_v2.dart';
import 'package:solana_kit_helius/src/zk/get_compression_signatures_for_account.dart';
import 'package:solana_kit_helius/src/zk/get_compression_signatures_for_address.dart';
import 'package:solana_kit_helius/src/zk/get_compression_signatures_for_owner.dart';
import 'package:solana_kit_helius/src/zk/get_compression_signatures_for_token_owner.dart';
import 'package:solana_kit_helius/src/zk/get_indexer_health.dart';
import 'package:solana_kit_helius/src/zk/get_indexer_slot.dart';
import 'package:solana_kit_helius/src/zk/get_latest_compression_signatures.dart';
import 'package:solana_kit_helius/src/zk/get_latest_non_voting_signatures.dart';
import 'package:solana_kit_helius/src/zk/get_multiple_compressed_account_proofs.dart';
import 'package:solana_kit_helius/src/zk/get_multiple_compressed_accounts.dart';
import 'package:solana_kit_helius/src/zk/get_multiple_new_address_proofs.dart';
import 'package:solana_kit_helius/src/zk/get_multiple_new_address_proofs_v2.dart';
import 'package:solana_kit_helius/src/zk/get_signatures_for_asset.dart';
import 'package:solana_kit_helius/src/zk/get_transaction_with_compression_info.dart';
import 'package:solana_kit_helius/src/zk/get_validity_proof.dart';

class ZkClient {
  const ZkClient({required JsonRpcClient rpcClient}) : _rpcClient = rpcClient;

  final JsonRpcClient _rpcClient;

  Future<CompressedAccount> getCompressedAccount(
    GetCompressedAccountRequest request,
  ) => zkGetCompressedAccount(_rpcClient, request);

  Future<CompressedAccountProof> getCompressedAccountProof(
    GetCompressedAccountProofRequest request,
  ) => zkGetCompressedAccountProof(_rpcClient, request);

  Future<CompressedAccountList> getCompressedAccountsByOwner(
    GetCompressedAccountsByOwnerRequest request,
  ) => zkGetCompressedAccountsByOwner(_rpcClient, request);

  Future<CompressedBalance> getCompressedBalance(
    GetCompressedBalanceRequest request,
  ) => zkGetCompressedBalance(_rpcClient, request);

  Future<CompressedBalance> getCompressedBalanceByOwner(
    GetCompressedBalanceByOwnerRequest request,
  ) => zkGetCompressedBalanceByOwner(_rpcClient, request);

  Future<CompressedTokenAccountList> getCompressedMintTokenHolders(
    GetCompressedMintTokenHoldersRequest request,
  ) => zkGetCompressedMintTokenHolders(_rpcClient, request);

  Future<CompressedBalance> getCompressedTokenAccountBalance(
    GetCompressedTokenAccountBalanceRequest request,
  ) => zkGetCompressedTokenAccountBalance(_rpcClient, request);

  Future<CompressedTokenAccountList> getCompressedTokenAccountsByDelegate(
    GetCompressedTokenAccountsByDelegateRequest request,
  ) => zkGetCompressedTokenAccountsByDelegate(_rpcClient, request);

  Future<CompressedTokenAccountList> getCompressedTokenAccountsByOwner(
    GetCompressedTokenAccountsByOwnerRequest request,
  ) => zkGetCompressedTokenAccountsByOwner(_rpcClient, request);

  Future<CompressedTokenBalanceList> getCompressedTokenBalancesByOwner(
    GetCompressedTokenBalancesByOwnerRequest request,
  ) => zkGetCompressedTokenBalancesByOwner(_rpcClient, request);

  Future<CompressedTokenBalanceV2List> getCompressedTokenBalancesByOwnerV2(
    GetCompressedTokenBalancesByOwnerRequest request,
  ) => zkGetCompressedTokenBalancesByOwnerV2(_rpcClient, request);

  Future<CompressedSignatureList> getCompressionSignaturesForAccount(
    GetCompressionSignaturesForAccountRequest request,
  ) => zkGetCompressionSignaturesForAccount(_rpcClient, request);

  Future<CompressedSignatureList> getCompressionSignaturesForAddress(
    GetCompressionSignaturesForAddressRequest request,
  ) => zkGetCompressionSignaturesForAddress(_rpcClient, request);

  Future<CompressedSignatureList> getCompressionSignaturesForOwner(
    GetCompressionSignaturesForOwnerRequest request,
  ) => zkGetCompressionSignaturesForOwner(_rpcClient, request);

  Future<CompressedSignatureList> getCompressionSignaturesForTokenOwner(
    GetCompressionSignaturesForTokenOwnerRequest request,
  ) => zkGetCompressionSignaturesForTokenOwner(_rpcClient, request);

  Future<IndexerHealth> getIndexerHealth() => zkGetIndexerHealth(_rpcClient);

  Future<int> getIndexerSlot() => zkGetIndexerSlot(_rpcClient);

  Future<CompressedSignatureList> getLatestCompressionSignatures(
    GetLatestCompressionSignaturesRequest request,
  ) => zkGetLatestCompressionSignatures(_rpcClient, request);

  Future<CompressedSignatureList> getLatestNonVotingSignatures(
    GetLatestNonVotingSignaturesRequest request,
  ) => zkGetLatestNonVotingSignatures(_rpcClient, request);

  Future<List<CompressedAccountProof>> getMultipleCompressedAccountProofs(
    GetMultipleCompressedAccountProofsRequest request,
  ) => zkGetMultipleCompressedAccountProofs(_rpcClient, request);

  Future<List<CompressedAccount>> getMultipleCompressedAccounts(
    GetMultipleCompressedAccountsRequest request,
  ) => zkGetMultipleCompressedAccounts(_rpcClient, request);

  Future<List<NewAddressProof>> getMultipleNewAddressProofs(
    GetMultipleNewAddressProofsRequest request,
  ) => zkGetMultipleNewAddressProofs(_rpcClient, request);

  Future<List<NewAddressProof>> getMultipleNewAddressProofsV2(
    GetMultipleNewAddressProofsRequest request,
  ) => zkGetMultipleNewAddressProofsV2(_rpcClient, request);

  Future<TransactionWithCompressionInfo> getTransactionWithCompressionInfo(
    GetTransactionWithCompressionInfoRequest request,
  ) => zkGetTransactionWithCompressionInfo(_rpcClient, request);

  Future<ValidityProof> getValidityProof(GetValidityProofRequest request) =>
      zkGetValidityProof(_rpcClient, request);

  Future<CompressedSignatureList> getSignaturesForAsset(
    GetZkSignaturesForAssetRequest request,
  ) => zkGetSignaturesForAsset(_rpcClient, request);
}
