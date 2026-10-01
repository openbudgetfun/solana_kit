/// On-chain integration tests for the Config program client against SurfPool.
///
/// The Config program stores arbitrary keyed data in a config account. This
/// suite creates a config account, stores data into it, and verifies the bytes
/// landed on-chain.
@TestOn('vm')
@Tags(['integration'])
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:solana_kit_address_constants/solana_kit_address_constants.dart';
import 'package:solana_kit_config/solana_kit_config.dart';
import 'package:solana_kit_integration_tests/solana_kit_integration_tests.dart';
import 'package:solana_kit_rpc/solana_kit_rpc.dart';
import 'package:solana_kit_rpc_api/solana_kit_rpc_api.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:solana_kit_signers/solana_kit_signers.dart';
import 'package:solana_kit_system/solana_kit_system.dart';
import 'package:test/test.dart';

void main() {
  late IntegrationTestEnv env;

  setUpAll(() async {
    env = await IntegrationTestEnv.create();
    // The Config program is a Core BPF program (not a builtin); deploy the
    // committed artifact so the store instruction can execute on-chain.
    await env.deployProgram(
      configProgramAddress,
      'config/programs/config-v3.0.0.so',
    );
  });

  tearDownAll(() => env.dispose());

  test('store writes keyed data into a config account on-chain', () async {
    final configAccount = generateKeyPairSigner();
    const configRent = 10_000_000; // rent-exempt for a ~1000-byte account.

    // Create the config account owned by the Config program.
    await env.sendInstructions(
      [
        getCreateAccountInstruction(
          instructionProgramAddress: systemProgramAddress,
          payer: env.payer.address,
          newAccount: configAccount.address,
          lamports: BigInt.from(configRent),
          space: BigInt.from(1000),
          programAddress: configProgramAddress,
        ),
      ],
      extraSigners: [configAccount],
    );

    const storedData = 'hello config';
    await env.sendInstructions(
      [
        getStoreConfigInstruction(
          configAccount: configAccount.address,
          keys: [
            const ConfigKey(address: configProgramAddress, isSigner: false),
          ],
          configData: Uint8List.fromList(utf8.encode(storedData)),
          // The config account signs the first store call.
          configAccountIsSigner: true,
        ),
      ],
      extraSigners: [configAccount],
    );

    // The config account data now contains the stored bytes.
    final account = await env.rpc
        .getAccountInfoValue(
          configAccount.address,
          const GetAccountInfoConfig(encoding: AccountEncoding.base64),
        )
        .send();
    expect(account.value, isNotNull);
    expect(account.value!['owner'], equals(configProgramAddress.value));
    final data = account.value!['data']! as List<Object?>;
    final bytes = base64Decode(data[0]! as String);
    // The Config account layout is: shortU16 key count (1 byte for <128
    // keys), then one (32-byte pubkey + 1-byte is_signer) entry per key,
    // then the data.
    const dataOffset = 1 + 33; // 1 key
    expect(utf8.decode(bytes.sublist(dataOffset)), contains(storedData));
  });
}
