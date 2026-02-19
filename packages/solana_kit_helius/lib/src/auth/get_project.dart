import 'package:solana_kit_helius/src/internal/rest_client.dart';
import 'package:solana_kit_helius/src/types/auth_types.dart';

/// Calls the Helius get project endpoint.
///
/// Sends a GET request to `/v0/auth/projects/{projectId}?api-key={apiKey}`.
/// Returns the [HeliusProject] configuration for the given [projectId].
Future<HeliusProject> authGetProject(
  RestClient restClient,
  String apiKey,
  String projectId,
) async {
  final result = await restClient.get(
    '/v0/auth/projects/$projectId?api-key=$apiKey',
  );
  return HeliusProject.fromJson(result! as Map<String, Object?>);
}
