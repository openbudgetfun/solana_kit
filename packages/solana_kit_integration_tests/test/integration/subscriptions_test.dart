/// On-chain integration tests for the Subscriptions program client against
/// SurfPool.
///
/// The compiled Subscriptions program (`.so`, pinned to `ts-client-v0.5.0`) is
/// committed under `config/programs/` and deployed to SurfPool by this suite.
@TestOn('vm')
@Tags(['integration'])
library;

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_integration_tests/solana_kit_integration_tests.dart';
import 'package:solana_kit_rpc/solana_kit_rpc.dart';
import 'package:solana_kit_signers/solana_kit_signers.dart';
import 'package:solana_kit_subscriptions/solana_kit_subscriptions.dart';
import 'package:solana_kit_system/solana_kit_system.dart';
import 'package:solana_kit_token/solana_kit_token.dart';
import 'package:test/test.dart';

void main() {
  late IntegrationTestEnv env;
  // The Subscriptions program bakes this canonical ID into its binary
  // (`crate::ID`), so it must be deployed at this exact address for PDA
  // derivation and program-id checks to match.
  const subscriptionsProgram = Address(
    'De1egAFMkMWZSN5rYXRj9CAdheBamobVNubTsi9avR44',
  );

  setUpAll(() async {
    env = await IntegrationTestEnv.create();
    await env.deployProgram(
      subscriptionsProgram,
      'config/programs/subscriptions-ts-client-v0.5.0.so',
    );
  });

  tearDownAll(() => env.dispose());

  test('initSubscriptionAuthority creates the authority PDA on-chain', () async {
    final mint = generateKeyPairSigner();
    const mintRent = 1461600;
    final userAta = getAssociatedTokenAddressSync(
      owner: env.payer.address,
      tokenProgram: tokenProgramAddress,
      mint: mint.address,
    );
    final (authorityPda, _) = await findSubscriptionAuthorityPda(
      seeds: SubscriptionAuthoritySeeds(
        user: env.payer.address,
        tokenMint: mint.address,
      ),
      programAddress: subscriptionsProgram,
    );

    // Set up a mint + ATA so the subscriptions instruction has valid accounts.
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
          ata: userAta,
          owner: env.payer.address,
          mint: mint.address,
          systemProgram: systemProgramAddress,
          tokenProgram: tokenProgramAddress,
        ),
      ],
      extraSigners: [mint],
    );

    // The authority PDA must not exist yet.
    final before = await env.rpc.getAccountInfoValue(authorityPda).send();
    expect(before.value, isNull);

    await env.sendInstructions([
      getInitSubscriptionAuthorityInstruction(
        programAddress: subscriptionsProgram,
        owner: env.payer.address,
        subscriptionAuthority: authorityPda,
        tokenMint: mint.address,
        userAta: userAta,
        systemProgram: systemProgramAddress,
        tokenProgram: tokenProgramAddress,
      ),
    ]);

    // The authority PDA now exists and is owned by the deployed program.
    final after = await env.rpc.getAccountInfoValue(authorityPda).send();
    expect(after.value, isNotNull);
    expect(after.value!['owner'], equals(subscriptionsProgram.value));
  });

  test('createPlan instruction encodes with the v0.5.0 API', () {
    final instruction = getCreatePlanInstruction(
      programAddress: subscriptionsProgram,
      merchant: env.payer.address,
      planPda: env.payer.address,
      tokenMint: env.payer.address,
      systemProgram: systemProgramAddress,
      tokenProgram: tokenProgramAddress,
      planData: PlanData(
        planId: BigInt.one,
        mint: env.payer.address,
        terms: PlanTerms(
          amount: BigInt.from(42),
          periodHours: BigInt.from(24),
          createdAt: BigInt.from(1000),
        ),
        endTs: BigInt.from(2000),
        destinations: List.filled(4, env.payer.address),
        pullers: List.filled(4, env.payer.address),
        metadataUri: 'https://example.com/plan',
      ),
    );
    expect(instruction.programAddress, equals(subscriptionsProgram));
    expect(instruction.data, isNotNull);
  });

  test('cancelSubscriptionNow instruction encodes (v0.5.0 addition)', () {
    final instruction = getCancelSubscriptionNowInstruction(
      programAddress: subscriptionsProgram,
      subscriber: env.payer.address,
      merchant: env.payer.address,
      planPda: env.payer.address,
      subscriptionPda: env.payer.address,
      eventAuthority: env.payer.address,
      selfProgram: subscriptionsProgram,
      cancelSubscriptionNowData: CancelSubscriptionNowData(
        expectedCurrentPeriodStartTs: BigInt.from(1000),
      ),
    );
    expect(instruction.programAddress, equals(subscriptionsProgram));
    expect(instruction.data, isNotNull);
  });

  test('resumeSubscription instruction encodes with resumeData', () {
    final instruction = getResumeSubscriptionInstruction(
      programAddress: subscriptionsProgram,
      subscriber: env.payer.address,
      planPda: env.payer.address,
      subscriptionPda: env.payer.address,
      subscriptionAuthority: env.payer.address,
      eventAuthority: env.payer.address,
      selfProgram: subscriptionsProgram,
      resumeData: ResumeData(expectedExpiresAtTs: BigInt.from(5000)),
    );
    expect(instruction.programAddress, equals(subscriptionsProgram));
    expect(instruction.data, isNotNull);
  });
}
