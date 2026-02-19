import 'package:solana_kit_helius/src/internal/rest_client.dart';
import 'package:solana_kit_helius/src/types/auth_types.dart';

/// Calls the Helius create project endpoint.
///
/// Sends a POST request to `/v0/auth/projects?api-key={apiKey}` with the
/// project name in the request body. Returns the newly created
/// [HeliusProject].
Future<HeliusProject> authCreateProject(
  RestClient restClient,
  String apiKey,
  CreateProjectRequest request,
) async {
  final result = await restClient.post(
    '/v0/auth/projects?api-key=$apiKey',
    body: request.toJson(),
  );
  return HeliusProject.fromJson(result! as Map<String, Object?>);
}
