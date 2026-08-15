/// On-chain integration tests for the Address Lookup Table program client
/// against SurfPool.
@TestOn('vm')
@Tags(['integration'])
library;

import 'package:solana_kit_address_constants/solana_kit_address_constants.dart';
import 'package:solana_kit_address_lookup_table/solana_kit_address_lookup_table.dart';
import 'package:solana_kit_integration_tests/solana_kit_integration_tests.dart';
import 'package:solana_kit_rpc/solana_kit_rpc.dart';
import 'package:test/test.dart';

void main() {
  late IntegrationTestEnv env;

  setUpAll(() async {
    env = await IntegrationTestEnv.create();
  });

  tearDownAll(() => env.dispose());

  test('createLookupTable creates the lookup table account on-chain', () async {
    final recentSlot = await env.rpc.getSlot().send();
    final (lookupTableAddress, bump) = await findAddressLookupTablePda(
      seeds: AddressLookupTableSeeds(
        authority: env.payer.address,
        recentSlot: recentSlot,
      ),
      programAddress: addressLookupTableProgramAddress,
    );

    // The lookup table account must not exist yet.
    final before = await env.rpc.getAccountInfoValue(lookupTableAddress).send();
    expect(before.value, isNull);

    await env.sendInstructions([
      getCreateLookupTableInstruction(
        programAddress: addressLookupTableProgramAddress,
        address: lookupTableAddress,
        authority: env.payer.address,
        payer: env.payer.address,
        systemProgram: systemProgramAddress,
        recentSlot: recentSlot,
        bump: bump,
      ),
    ]);

    // The lookup table account now exists and is owned by the ALT program.
    final after = await env.rpc.getAccountInfoValue(lookupTableAddress).send();
    expect(after.value, isNotNull);
    expect(
      after.value!['owner'],
      equals(addressLookupTableProgramAddress.value),
    );
  });
}
