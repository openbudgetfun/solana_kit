/// On-chain integration tests for the Address Lookup Table program client
/// against SurfPool.
@TestOn('vm')
@Tags(['integration'])
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:solana_kit_address_lookup_table/solana_kit_address_lookup_table.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_integration_tests/solana_kit_integration_tests.dart';
import 'package:solana_kit_rpc/solana_kit_rpc.dart';
import 'package:solana_kit_rpc_api/solana_kit_rpc_api.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:solana_kit_signers/solana_kit_signers.dart';
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

  test('extendLookupTable adds addresses to the table on-chain', () async {
    final recentSlot = await env.rpc.getSlot().send();
    final (lookupTableAddress, bump) = await findAddressLookupTablePda(
      seeds: AddressLookupTableSeeds(
        authority: env.payer.address,
        recentSlot: recentSlot,
      ),
      programAddress: addressLookupTableProgramAddress,
    );
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

    final added = [
      generateKeyPairSigner().address,
      generateKeyPairSigner().address,
    ];
    await env.sendInstructions([
      getExtendLookupTableInstruction(
        programAddress: addressLookupTableProgramAddress,
        address: lookupTableAddress,
        authority: env.payer.address,
        payer: env.payer.address,
        systemProgram: systemProgramAddress,
        addresses: added,
      ),
    ]);

    // The table data now contains the 32-byte encodings of both addresses.
    final account = await env.rpc
        .getAccountInfoValue(
          lookupTableAddress,
          const GetAccountInfoConfig(encoding: AccountEncoding.base64),
        )
        .send();
    final data = account.value!['data']! as List<Object?>;
    final bytes = base64Decode(data[0]! as String);
    for (final address in added) {
      final encoded = getAddressEncoder().encode(address);
      var found = false;
      for (var i = 0; i + encoded.length <= bytes.length; i++) {
        var matches = true;
        for (var j = 0; j < encoded.length; j++) {
          if (bytes[i + j] != encoded[j]) {
            matches = false;
            break;
          }
        }
        if (matches) {
          found = true;
          break;
        }
      }
      expect(found, isTrue, reason: 'address $address should be in the table');
    }
  });

  test('deactivateLookupTable sets the deactivation slot on-chain', () async {
    final recentSlot = await env.rpc.getSlot().send();
    final (lookupTableAddress, bump) = await findAddressLookupTablePda(
      seeds: AddressLookupTableSeeds(
        authority: env.payer.address,
        recentSlot: recentSlot,
      ),
      programAddress: addressLookupTableProgramAddress,
    );
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

    await env.sendInstructions([
      getDeactivateLookupTableInstruction(
        programAddress: addressLookupTableProgramAddress,
        address: lookupTableAddress,
        authority: env.payer.address,
      ),
    ]);

    // The deactivation slot (u64 LE at offset 1) is now non-zero.
    final account = await env.rpc
        .getAccountInfoValue(
          lookupTableAddress,
          const GetAccountInfoConfig(encoding: AccountEncoding.base64),
        )
        .send();
    final data = account.value!['data']! as List<Object?>;
    final bytes = base64Decode(data[0]! as String);
    final deactivationSlot = ByteData.sublistView(bytes).getUint64(1);
    expect(deactivationSlot, greaterThan(0));
  });

  test('closeLookupTable closes the account and returns lamports', () async {
    final recentSlot = await env.rpc.getSlot().send();
    final (lookupTableAddress, bump) = await findAddressLookupTablePda(
      seeds: AddressLookupTableSeeds(
        authority: env.payer.address,
        recentSlot: recentSlot,
      ),
      programAddress: addressLookupTableProgramAddress,
    );
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

    final payerBefore = await env.rpc.getBalanceValue(env.payer.address).send();
    // Deactivate first; the table can only be closed once the deactivation
    // slot has fallen out of the SlotHashes sysvar (512 entries). Slot
    // production rate varies under parallel load, so poll until the close
    // succeeds (it is a no-op failure, so retrying is safe).
    await env.sendInstructions([
      getDeactivateLookupTableInstruction(
        programAddress: addressLookupTableProgramAddress,
        address: lookupTableAddress,
        authority: env.payer.address,
      ),
    ]);
    final deadline = DateTime.now().add(const Duration(seconds: 30));
    var closeSucceeded = false;
    while (!closeSucceeded && DateTime.now().isBefore(deadline)) {
      try {
        await env.sendInstructions([
          getCloseLookupTableInstruction(
            programAddress: addressLookupTableProgramAddress,
            address: lookupTableAddress,
            authority: env.payer.address,
            recipient: env.payer.address,
          ),
        ]);
        closeSucceeded = true;
      } on SolanaError {
        await Future<void>.delayed(const Duration(seconds: 1));
      }
    }
    expect(closeSucceeded, isTrue, reason: 'close should succeed within 30s');

    final closed = await env.rpc.getAccountInfoValue(lookupTableAddress).send();
    expect(closed.value, isNull);
    final payerAfter = await env.rpc.getBalanceValue(env.payer.address).send();
    expect(payerAfter.value.value, greaterThan(payerBefore.value.value));
  });
}
