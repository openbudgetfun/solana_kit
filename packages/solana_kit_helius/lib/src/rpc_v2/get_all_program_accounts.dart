import 'package:solana_kit_helius/src/internal/json_rpc_client.dart';
import 'package:solana_kit_helius/src/rpc_v2/get_program_accounts_v2.dart';
import 'package:solana_kit_helius/src/types/rpc_v2_types.dart';

/// Auto-paginator that fetches all program accounts matching the given
/// [request].
///
/// Repeatedly calls `getProgramAccountsV2` with the cursor from each
/// response until all pages have been consumed, then returns the complete
/// list of [ProgramAccountV2] items.
Future<List<ProgramAccountV2>> rpcV2GetAllProgramAccounts(
  JsonRpcClient rpcClient,
  GetProgramAccountsV2Request request,
) async {
  final allAccounts = <ProgramAccountV2>[];
  var cursor = request.after;

  while (true) {
    final pageRequest = GetProgramAccountsV2Request(
      programAddress: request.programAddress,
      filters: request.filters,
      encoding: request.encoding,
      dataSlice: request.dataSlice,
      after: cursor,
      limit: request.limit,
    );
    final response = await rpcV2GetProgramAccountsV2(rpcClient, pageRequest);
    allAccounts.addAll(response.accounts);

    if (response.cursor == null || response.accounts.isEmpty) break;
    cursor = response.cursor;
  }

  return allAccounts;
}
