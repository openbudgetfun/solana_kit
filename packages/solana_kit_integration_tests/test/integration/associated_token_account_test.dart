/// On-chain integration tests for the Associated Token Account program client
/// against SurfPool.
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

  test(
    'createAssociatedTokenAccountIdempotent creates the ATA on-chain',
    () async {
      final mint = generateKeyPairSigner();
      const mintRent = 1461600;
      final ata = getAssociatedTokenAddressSync(
        owner: env.payer.address,
        tokenProgram: tokenProgramAddress,
        mint: mint.address,
      );

      // Set up the mint first so the ATA creation has a valid mint to reference.
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
        ],
        extraSigners: [mint],
      );

      // The ATA must not exist yet.
      final before = await env.rpc.getAccountInfoValue(ata).send();
      expect(before.value, isNull);

      await env.sendInstructions([
        getCreateAssociatedTokenIdempotentInstruction(
          programAddress: associatedTokenProgramAddress,
          payer: env.payer.address,
          ata: ata,
          owner: env.payer.address,
          mint: mint.address,
          systemProgram: systemProgramAddress,
          tokenProgram: tokenProgramAddress,
        ),
      ]);

      // The ATA now exists and is owned by the Token program.
      final after = await env.rpc.getAccountInfoValue(ata).send();
      expect(after.value, isNotNull);
      expect(after.value!['owner'], equals(tokenProgramAddress.value));
    },
  );

  test('idempotent create succeeds when the ATA already exists', () async {
    final mint = generateKeyPairSigner();
    const mintRent = 1461600;
    final ata = getAssociatedTokenAddressSync(
      owner: env.payer.address,
      tokenProgram: tokenProgramAddress,
      mint: mint.address,
    );

    // Set up the mint + ATA once.
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
      ],
      extraSigners: [mint],
    );

    // Calling it again must succeed (that is the point of idempotent).
    await env.sendInstructions([
      getCreateAssociatedTokenIdempotentInstruction(
        programAddress: associatedTokenProgramAddress,
        payer: env.payer.address,
        ata: ata,
        owner: env.payer.address,
        mint: mint.address,
        systemProgram: systemProgramAddress,
        tokenProgram: tokenProgramAddress,
      ),
    ]);
  });

  test('non-idempotent create fails when the ATA already exists', () async {
    final mint = generateKeyPairSigner();
    const mintRent = 1461600;
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
      ],
      extraSigners: [mint],
    );

    // The non-idempotent variant must fail because the ATA exists.
    await expectLater(
      env.sendInstructions([
        getCreateAssociatedTokenInstruction(
          programAddress: associatedTokenProgramAddress,
          payer: env.payer.address,
          ata: ata,
          owner: env.payer.address,
          mint: mint.address,
          systemProgram: systemProgramAddress,
          tokenProgram: tokenProgramAddress,
        ),
      ]),
      throwsA(isA<Object>()),
    );
  });
}
