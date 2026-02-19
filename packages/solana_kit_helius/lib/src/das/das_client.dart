import 'package:solana_kit_helius/src/das/get_asset.dart';
import 'package:solana_kit_helius/src/das/get_asset_batch.dart';
import 'package:solana_kit_helius/src/das/get_asset_proof.dart';
import 'package:solana_kit_helius/src/das/get_asset_proof_batch.dart';
import 'package:solana_kit_helius/src/das/get_assets_by_authority.dart';
import 'package:solana_kit_helius/src/das/get_assets_by_creator.dart';
import 'package:solana_kit_helius/src/das/get_assets_by_group.dart';
import 'package:solana_kit_helius/src/das/get_assets_by_owner.dart';
import 'package:solana_kit_helius/src/das/get_nft_editions.dart';
import 'package:solana_kit_helius/src/das/get_signatures_for_asset.dart';
import 'package:solana_kit_helius/src/das/get_token_accounts.dart';
import 'package:solana_kit_helius/src/das/search_assets.dart';
import 'package:solana_kit_helius/src/internal/json_rpc_client.dart';
import 'package:solana_kit_helius/src/types/das_types.dart';

/// Client for Helius Digital Asset Standard (DAS) API methods.
class DasClient {
  const DasClient({required JsonRpcClient rpcClient}) : _rpcClient = rpcClient;

  final JsonRpcClient _rpcClient;

  /// Returns the metadata for a single digital asset by its ID.
  Future<HeliusAsset> getAsset(GetAssetRequest request) =>
      dasGetAsset(_rpcClient, request);

  /// Returns metadata for multiple digital assets in a single request.
  Future<List<HeliusAsset>> getAssetBatch(GetAssetBatchRequest request) =>
      dasGetAssetBatch(_rpcClient, request);

  /// Returns the Merkle proof for a compressed asset.
  Future<AssetProof> getAssetProof(GetAssetProofRequest request) =>
      dasGetAssetProof(_rpcClient, request);

  /// Returns Merkle proofs for multiple compressed assets in a single request.
  Future<Map<String, AssetProof>> getAssetProofBatch(
    GetAssetProofBatchRequest request,
  ) => dasGetAssetProofBatch(_rpcClient, request);

  /// Returns assets controlled by a given authority address.
  Future<AssetList> getAssetsByAuthority(GetAssetsByAuthorityRequest request) =>
      dasGetAssetsByAuthority(_rpcClient, request);

  /// Returns assets created by a given creator address.
  Future<AssetList> getAssetsByCreator(GetAssetsByCreatorRequest request) =>
      dasGetAssetsByCreator(_rpcClient, request);

  /// Returns assets belonging to a given group (e.g. a collection).
  Future<AssetList> getAssetsByGroup(GetAssetsByGroupRequest request) =>
      dasGetAssetsByGroup(_rpcClient, request);

  /// Returns assets owned by a given wallet address.
  Future<AssetList> getAssetsByOwner(GetAssetsByOwnerRequest request) =>
      dasGetAssetsByOwner(_rpcClient, request);

  /// Returns the edition records for a given NFT mint.
  Future<List<NftEdition>> getNftEditions(GetNftEditionsRequest request) =>
      dasGetNftEditions(_rpcClient, request);

  /// Returns transaction signatures associated with a given asset.
  Future<AssetSignatureList> getSignaturesForAsset(
    GetSignaturesForAssetRequest request,
  ) => dasGetSignaturesForAsset(_rpcClient, request);

  /// Returns token accounts matching the given criteria.
  Future<TokenAccountList> getTokenAccounts(GetTokenAccountsRequest request) =>
      dasGetTokenAccounts(_rpcClient, request);

  /// Searches for assets matching the given filter criteria.
  Future<AssetList> searchAssets(SearchAssetsRequest request) =>
      dasSearchAssets(_rpcClient, request);
}
