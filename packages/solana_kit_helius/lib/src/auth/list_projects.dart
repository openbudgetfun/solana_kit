import 'package:solana_kit_helius/src/internal/rest_client.dart';
import 'package:solana_kit_helius/src/types/auth_types.dart';

/// Calls the Helius list projects endpoint.
///
/// Sends a GET request to `/v0/auth/projects?api-key={apiKey}`. Returns a
/// list of all [HeliusProject] objects for the current account.
Future<List<HeliusProject>> authListProjects(
  RestClient restClient,
  String apiKey,
) async {
  final result = await restClient.get('/v0/auth/projects?api-key=$apiKey');
  final list = result! as List<Object?>;
  return list.cast<Map<String, Object?>>().map(HeliusProject.fromJson).toList();
}
