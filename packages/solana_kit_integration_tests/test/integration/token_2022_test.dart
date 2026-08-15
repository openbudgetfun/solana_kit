/// On-chain integration tests for the Token-2022 program client against
/// SurfPool.
///
/// Mirrors the Token program lifecycle but uses the Token-2022 program and its
/// associated token accounts.
@TestOn('vm')
@Tags(['integration'])
library;

import 'package:solana_kit_address_constants/solana_kit_address_constants.dart';
import 'package:solana_kit_integration_tests/solana_kit_integration_tests.dart';
import 'package:solana_kit_rpc/solana_kit_rpc.dart';
import 'package:solana_kit_signers/solana_kit_signers.dart';
import 'package:solana_kit_system/solana_kit_system.dart';
import 'package:solana_kit_token_2022/solana_kit_token_2022.dart';
import 'package:test/test.dart';

void main() {
  late IntegrationTestEnv env;

  setUpAll(() async {
    env = await IntegrationTestEnv.create();
  });

  tearDownAll(() => env.dispose());

  test('createMint and mintTo via Token-2022 verify on-chain', () async {
    final mint = generateKeyPairSigner();
    const mintRent = 1461600;
    final ata = getAssociatedTokenAddressSync(
      owner: env.payer.address,
      tokenProgram: token2022ProgramAddress,
      mint: mint.address,
    );

    await env.sendInstructions(
      [
        getCreateAccountInstruction(
          instructionProgramAddress: systemProgramAddress,
          payer: env.payer.address,
          newAccount: mint.address,
          lamports: BigInt.from(mintRent),
          space: BigInt.from(82),
          programAddress: token2022ProgramAddress,
        ),
        getInitializeMint2Instruction(
          programAddress: token2022ProgramAddress,
          mint: mint.address,
          decimals: 9,
          mintAuthority: env.payer.address,
        ),
        getCreateAssociatedTokenIdempotentInstruction(
          programAddress: associatedTokenProgramAddress,
          payer: env.payer.address,
          ata: ata,
          owner: env.payer.address,
          mint: mint.address,
          systemProgram: systemProgramAddress,
          tokenProgram: token2022ProgramAddress,
        ),
        getMintToInstruction(
          programAddress: token2022ProgramAddress,
          mint: mint.address,
          token: ata,
          mintAuthority: env.payer.address,
          amount: BigInt.from(2_000_000),
        ),
      ],
      extraSigners: [mint],
    );

    // The Token-2022 ATA must exist and be owned by the Token-2022 program.
    final account = await env.rpc.getAccountInfoValue(ata).send();
    expect(account.value, isNotNull);
    expect(account.value!['owner'], equals(token2022ProgramAddress.value));
  });
}
