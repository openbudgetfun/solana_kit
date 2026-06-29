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

/// Client for Helius ZK Compression API methods.
class ZkClient {
  /// Creates a ZkClient backed by the given JSON-RPC client.
  const ZkClient({required this._rpcClient});

  final JsonRpcClient _rpcClient;

  /// Returns a compressed account by its address.
  Future<CompressedAccount> getCompressedAccount(
    GetCompressedAccountRequest request,
  ) => zkGetCompressedAccount(_rpcClient, request);

  /// Returns the state proof hash path for a compressed account.
  Future<CompressedAccountProof> getCompressedAccountProof(
    GetCompressedAccountProofRequest request,
  ) => zkGetCompressedAccountProof(_rpcClient, request);

  /// Returns compressed accounts owned by the given address.
  Future<CompressedAccountList> getCompressedAccountsByOwner(
    GetCompressedAccountsByOwnerRequest request,
  ) => zkGetCompressedAccountsByOwner(_rpcClient, request);

  /// Returns the compressed balance for the given account.
  Future<CompressedBalance> getCompressedBalance(
    GetCompressedBalanceRequest request,
  ) => zkGetCompressedBalance(_rpcClient, request);

  /// Returns the compressed balance for the given owner address.
  Future<CompressedBalance> getCompressedBalanceByOwner(
    GetCompressedBalanceByOwnerRequest request,
  ) => zkGetCompressedBalanceByOwner(_rpcClient, request);

  /// Returns the compressed token accounts holding a given mint.
  Future<CompressedTokenAccountList> getCompressedMintTokenHolders(
    GetCompressedMintTokenHoldersRequest request,
  ) => zkGetCompressedMintTokenHolders(_rpcClient, request);

  /// Returns the compressed balance for a token account.
  Future<CompressedBalance> getCompressedTokenAccountBalance(
    GetCompressedTokenAccountBalanceRequest request,
  ) => zkGetCompressedTokenAccountBalance(_rpcClient, request);

  /// Returns compressed token accounts delegated to the given delegate.
  Future<CompressedTokenAccountList> getCompressedTokenAccountsByDelegate(
    GetCompressedTokenAccountsByDelegateRequest request,
  ) => zkGetCompressedTokenAccountsByDelegate(_rpcClient, request);

  /// Returns compressed token accounts owned by the given address.
  Future<CompressedTokenAccountList> getCompressedTokenAccountsByOwner(
    GetCompressedTokenAccountsByOwnerRequest request,
  ) => zkGetCompressedTokenAccountsByOwner(_rpcClient, request);

  /// Returns compressed token balances for the given owner address.
  Future<CompressedTokenBalanceList> getCompressedTokenBalancesByOwner(
    GetCompressedTokenBalancesByOwnerRequest request,
  ) => zkGetCompressedTokenBalancesByOwner(_rpcClient, request);

  /// Returns compressed token balances (V2) for the given owner address.
  Future<CompressedTokenBalanceV2List> getCompressedTokenBalancesByOwnerV2(
    GetCompressedTokenBalancesByOwnerRequest request,
  ) => zkGetCompressedTokenBalancesByOwnerV2(_rpcClient, request);

  /// Returns compression signatures for the given account.
  Future<CompressedSignatureList> getCompressionSignaturesForAccount(
    GetCompressionSignaturesForAccountRequest request,
  ) => zkGetCompressionSignaturesForAccount(_rpcClient, request);

  /// Returns compression signatures for the given address.
  Future<CompressedSignatureList> getCompressionSignaturesForAddress(
    GetCompressionSignaturesForAddressRequest request,
  ) => zkGetCompressionSignaturesForAddress(_rpcClient, request);

  /// Returns compression signatures for the given owner address.
  Future<CompressedSignatureList> getCompressionSignaturesForOwner(
    GetCompressionSignaturesForOwnerRequest request,
  ) => zkGetCompressionSignaturesForOwner(_rpcClient, request);

  /// Returns compression signatures for the given token owner.
  Future<CompressedSignatureList> getCompressionSignaturesForTokenOwner(
    GetCompressionSignaturesForTokenOwnerRequest request,
  ) => zkGetCompressionSignaturesForTokenOwner(_rpcClient, request);

  /// Returns the health status of the Helius indexer.
  Future<IndexerHealth> getIndexerHealth() => zkGetIndexerHealth(_rpcClient);

  /// Returns the current slot the indexer has synced up to.
  Future<int> getIndexerSlot() => zkGetIndexerSlot(_rpcClient);

  /// Returns the latest compression signatures.
  Future<CompressedSignatureList> getLatestCompressionSignatures(
    GetLatestCompressionSignaturesRequest request,
  ) => zkGetLatestCompressionSignatures(_rpcClient, request);

  /// Returns the latest non-voting signatures.
  Future<CompressedSignatureList> getLatestNonVotingSignatures(
    GetLatestNonVotingSignaturesRequest request,
  ) => zkGetLatestNonVotingSignatures(_rpcClient, request);

  /// Returns state proofs for multiple compressed accounts.
  Future<List<CompressedAccountProof>> getMultipleCompressedAccountProofs(
    GetMultipleCompressedAccountProofsRequest request,
  ) => zkGetMultipleCompressedAccountProofs(_rpcClient, request);

  /// Returns multiple compressed accounts in a single request.
  Future<List<CompressedAccount>> getMultipleCompressedAccounts(
    GetMultipleCompressedAccountsRequest request,
  ) => zkGetMultipleCompressedAccounts(_rpcClient, request);

  /// Returns validity proofs for multiple new addresses.
  Future<List<NewAddressProof>> getMultipleNewAddressProofs(
    GetMultipleNewAddressProofsRequest request,
  ) => zkGetMultipleNewAddressProofs(_rpcClient, request);

  /// Returns validity proofs (V2) for multiple new addresses.
  Future<List<NewAddressProof>> getMultipleNewAddressProofsV2(
    GetMultipleNewAddressProofsRequest request,
  ) => zkGetMultipleNewAddressProofsV2(_rpcClient, request);

  /// Returns a transaction along with its compression metadata.
  Future<TransactionWithCompressionInfo> getTransactionWithCompressionInfo(
    GetTransactionWithCompressionInfoRequest request,
  ) => zkGetTransactionWithCompressionInfo(_rpcClient, request);

  /// Returns a validity proof for the given hashes.
  Future<ValidityProof> getValidityProof(GetValidityProofRequest request) =>
      zkGetValidityProof(_rpcClient, request);

  /// Returns transaction signatures for the given compressed asset.
  Future<CompressedSignatureList> getSignaturesForAsset(
    GetZkSignaturesForAssetRequest request,
  ) => zkGetSignaturesForAsset(_rpcClient, request);
}
