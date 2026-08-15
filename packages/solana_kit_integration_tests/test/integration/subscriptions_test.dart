/// On-chain integration tests for the Subscriptions program client against
/// SurfPool.
///
/// The compiled Subscriptions program (`.so`, pinned to `ts-client-v0.5.0`) is
/// committed under `config/programs/` and deployed to SurfPool by this suite.
@TestOn('vm')
@Tags(['integration'])
library;

import 'dart:typed_data';

import 'package:solana_kit_accounts/solana_kit_accounts.dart';
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
      'config/programs/subscriptions-v0.5.0.so',
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

  test(
    'createPlan, subscribe, cancelSubscription and resumeSubscription run on-chain',
    () async {
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
      final planId = BigInt.from(7);
      final (planPda, planBump) = await findPlanPda(
        seeds: PlanSeeds(owner: env.payer.address, planId: planId),
        programAddress: subscriptionsProgram,
      );
      final (subscriptionPda, _) = await findSubscriptionDelegationPda(
        seeds: SubscriptionDelegationSeeds(
          planPda: planPda,
          subscriber: env.payer.address,
        ),
        programAddress: subscriptionsProgram,
      );
      final (eventAuthority, _) = await findEventAuthorityPda(
        programAddress: subscriptionsProgram,
      );

      // Set up the mint, ATA, and subscription authority.
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
          getInitSubscriptionAuthorityInstruction(
            programAddress: subscriptionsProgram,
            owner: env.payer.address,
            subscriptionAuthority: authorityPda,
            tokenMint: mint.address,
            userAta: userAta,
            systemProgram: systemProgramAddress,
            tokenProgram: tokenProgramAddress,
          ),
        ],
        extraSigners: [mint],
      );

      // The subscription authority's init_id (set to the slot at init time)
      // must be echoed back in the subscribe instruction.
      final authorityAccount = await fetchEncodedAccount(env.rpc, authorityPda);
      final authority = decodeSubscriptionAuthority(
        (authorityAccount as ExistingAccount<Uint8List>).account,
      );
      final authorityInitId = authority.data.initId;

      // createPlan lands on-chain: the plan PDA now exists. The program
      // overwrites `created_at` with the current timestamp and requires
      // `end_ts` to be zero or in the future.
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      await env.sendInstructions([
        getCreatePlanInstruction(
          programAddress: subscriptionsProgram,
          merchant: env.payer.address,
          planPda: planPda,
          tokenMint: mint.address,
          systemProgram: systemProgramAddress,
          tokenProgram: tokenProgramAddress,
          planData: PlanData(
            planId: planId,
            mint: mint.address,
            terms: PlanTerms(
              amount: BigInt.from(42),
              periodHours: BigInt.from(24),
              createdAt: BigInt.from(now - 3600),
            ),
            endTs: BigInt.from(now + 2 * 24 * 3600),
            destinations: List.filled(4, env.payer.address),
            pullers: List.filled(4, env.payer.address),
            metadataUri: 'https://example.com/plan',
          ),
        ),
      ]);
      final planAccount = await env.rpc.getAccountInfoValue(planPda).send();
      expect(planAccount.value, isNotNull);
      expect(planAccount.value!['owner'], equals(subscriptionsProgram.value));

      // The program set `created_at` to the current timestamp; read it back so
      // the subscribe instruction can echo the live plan terms.
      final plan = decodePlan(
        (await fetchEncodedAccount(env.rpc, planPda)
                as ExistingAccount<Uint8List>)
            .account,
      );
      final planCreatedAt = plan.data.data.terms.createdAt;

      // subscribe creates the subscription delegation PDA on-chain.
      await env.sendInstructions([
        getSubscribeInstruction(
          programAddress: subscriptionsProgram,
          subscriber: env.payer.address,
          merchant: env.payer.address,
          planPda: planPda,
          subscriptionPda: subscriptionPda,
          subscriptionAuthorityPda: authorityPda,
          systemProgram: systemProgramAddress,
          eventAuthority: eventAuthority,
          selfProgram: subscriptionsProgram,
          subscribeData: SubscribeData(
            planId: planId,
            planBump: planBump,
            expectedMint: mint.address,
            expectedAmount: BigInt.from(42),
            expectedPeriodHours: BigInt.from(24),
            expectedCreatedAt: planCreatedAt,
            expectedSubscriptionAuthorityInitId: authorityInitId,
          ),
        ),
      ]);
      final subscriptionAccount = await env.rpc
          .getAccountInfoValue(subscriptionPda)
          .send();
      expect(subscriptionAccount.value, isNotNull);
      expect(
        subscriptionAccount.value!['owner'],
        equals(subscriptionsProgram.value),
      );

      // cancelSubscription confirms on-chain; it sets `expires_at_ts` to the
      // end of the current period (a future timestamp), which resume requires.
      await env.sendInstructions([
        getCancelSubscriptionInstruction(
          programAddress: subscriptionsProgram,
          subscriber: env.payer.address,
          planPda: planPda,
          subscriptionPda: subscriptionPda,
          eventAuthority: eventAuthority,
          selfProgram: subscriptionsProgram,
        ),
      ]);

      // resumeSubscription confirms on-chain; it requires the expires_at_ts
      // the cancel instruction just wrote.
      final cancelled = decodeSubscriptionDelegation(
        (await fetchEncodedAccount(env.rpc, subscriptionPda)
                as ExistingAccount<Uint8List>)
            .account,
      );
      final expiresAtTs = cancelled.data.expiresAtTs;
      await env.sendInstructions([
        getResumeSubscriptionInstruction(
          programAddress: subscriptionsProgram,
          subscriber: env.payer.address,
          planPda: planPda,
          subscriptionPda: subscriptionPda,
          subscriptionAuthority: authorityPda,
          eventAuthority: eventAuthority,
          selfProgram: subscriptionsProgram,
          resumeData: ResumeData(expectedExpiresAtTs: expiresAtTs),
        ),
      ]);
    },
  );
}
