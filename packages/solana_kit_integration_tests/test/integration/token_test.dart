/// On-chain integration tests for the Token program client against SurfPool.
///
/// Exercises the full mint lifecycle: create the mint account, initialize it,
/// create the payer's associated token account, mint tokens into it, then
/// verify the token account exists and is owned by the Token program.
@TestOn('vm')
@Tags(['integration'])
library;

import 'package:solana_kit_address_constants/solana_kit_address_constants.dart';
import 'package:solana_kit_integration_tests/solana_kit_integration_tests.dart';
import 'package:solana_kit_rpc/solana_kit_rpc.dart';
import 'package:solana_kit_signers/solana_kit_signers.dart';
import 'package:solana_kit_system/solana_kit_system.dart';
import 'package:solana_kit_token/solana_kit_token.dart';
import 'package:test/test.dart';

void main() {
  late IntegrationTestEnv env;

  setUpAll(() async {
    env = await IntegrationTestEnv.create();
  });

  tearDownAll(() => env.dispose());

  test('createMint, mintTo and verify the token account on-chain', () async {
    final mint = generateKeyPairSigner();
    const mintRent = 1461600; // rent-exempt lamports for an 82-byte Mint.
    final ata = getAssociatedTokenAddressSync(
      owner: env.payer.address,
      tokenProgram: tokenProgramAddress,
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
          programAddress: tokenProgramAddress,
        ),
        getInitializeMint2Instruction(
          programAddress: tokenProgramAddress,
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
          tokenProgram: tokenProgramAddress,
        ),
        getMintToInstruction(
          programAddress: tokenProgramAddress,
          mint: mint.address,
          token: ata,
          mintAuthority: env.payer.address,
          amount: BigInt.from(1_000_000),
        ),
      ],
      extraSigners: [mint],
    );

    // The associated token account must now exist and be owned by the Token
    // program — proving createATA + mintTo landed on-chain.
    final account = await env.rpc.getAccountInfoValue(ata).send();
    expect(account.value, isNotNull);
    expect(account.value!['owner'], equals(tokenProgramAddress.value));
  });
}
