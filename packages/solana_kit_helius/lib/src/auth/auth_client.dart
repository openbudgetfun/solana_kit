import 'package:solana_kit_helius/src/auth/agentic_signup.dart';
import 'package:solana_kit_helius/src/auth/check_balances.dart';
import 'package:solana_kit_helius/src/auth/create_api_key.dart';
import 'package:solana_kit_helius/src/auth/create_project.dart';
import 'package:solana_kit_helius/src/auth/generate_keypair.dart';
import 'package:solana_kit_helius/src/auth/get_project.dart';
import 'package:solana_kit_helius/src/auth/list_projects.dart';
import 'package:solana_kit_helius/src/auth/sign_auth_message.dart';
import 'package:solana_kit_helius/src/auth/wallet_signup.dart';
import 'package:solana_kit_helius/src/internal/rest_client.dart';
import 'package:solana_kit_helius/src/types/auth_types.dart';

/// Client for Helius Auth API methods.
class AuthClient {
  const AuthClient({required RestClient restClient, required String apiKey})
    : _restClient = restClient,
      _apiKey = apiKey;

  final RestClient _restClient;
  final String _apiKey;

  /// Performs an agentic signup with a wallet address.
  Future<AgenticSignupResponse> agenticSignup(AgenticSignupRequest request) =>
      authAgenticSignup(_restClient, _apiKey, request);

  /// Performs a wallet signup with signature verification.
  Future<WalletSignupResponse> walletSignup(WalletSignupRequest request) =>
      authWalletSignup(_restClient, _apiKey, request);

  /// Creates a new Helius project.
  Future<HeliusProject> createProject(CreateProjectRequest request) =>
      authCreateProject(_restClient, _apiKey, request);

  /// Returns the project configuration for the given [projectId].
  Future<HeliusProject> getProject(String projectId) =>
      authGetProject(_restClient, _apiKey, projectId);

  /// Returns all projects for the current account.
  Future<List<HeliusProject>> listProjects() =>
      authListProjects(_restClient, _apiKey);

  /// Creates a new API key for a project.
  Future<HeliusApiKey> createApiKey(CreateApiKeyRequest request) =>
      authCreateApiKey(_restClient, _apiKey, request);

  /// Returns credit balance information for the current account.
  Future<CheckBalancesResponse> checkBalances() =>
      authCheckBalances(_restClient, _apiKey);

  /// Generates a new Ed25519 keypair for authentication.
  KeypairResult generateKeypair() => authGenerateKeypair();

  /// Signs an authentication message with the given secret key.
  Future<SignAuthMessageResponse> signAuthMessage(
    SignAuthMessageRequest request,
  ) => authSignAuthMessage(request);
}
