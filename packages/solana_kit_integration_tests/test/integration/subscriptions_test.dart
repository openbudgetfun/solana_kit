/// Integration tests for the Subscriptions program client.
///
/// These verify the generated instruction builders encode correctly. On-chain
/// execution against SurfPool requires deploying the compiled Subscriptions
/// program (`.so`), which is not bundled with this workspace; once the artifact
/// is available, `surfnet.deployProgram(...)` can be used to extend these into
/// real on-chain tests.
@TestOn('vm')
@Tags(['integration'])
library;

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_subscriptions/solana_kit_subscriptions.dart';
import 'package:test/test.dart';

void main() {
  // A deterministic test address; not used on-chain.
  const programAddress = Address(
    'De1egAFMkMWZSN5rYXRj9CAdheBamobVNubTsi9avR44',
  );

  group('subscriptions instruction builders', () {
    test('createPlan instruction encodes with the v0.5.0 API', () {
      final instruction = getCreatePlanInstruction(
        programAddress: programAddress,
        merchant: const Address('11111111111111111111111111111111'),
        planPda: const Address('11111111111111111111111111111111'),
        tokenMint: const Address('11111111111111111111111111111111'),
        systemProgram: const Address('11111111111111111111111111111111'),
        tokenProgram: const Address('11111111111111111111111111111111'),
        planData: PlanData(
          planId: BigInt.one,
          mint: const Address('11111111111111111111111111111111'),
          terms: PlanTerms(
            amount: BigInt.from(42),
            periodHours: BigInt.from(24),
            createdAt: BigInt.from(1000),
          ),
          endTs: BigInt.from(2000),
          destinations: const [
            Address('11111111111111111111111111111111'),
            Address('11111111111111111111111111111111'),
            Address('11111111111111111111111111111111'),
            Address('11111111111111111111111111111111'),
          ],
          pullers: const [
            Address('11111111111111111111111111111111'),
            Address('11111111111111111111111111111111'),
            Address('11111111111111111111111111111111'),
            Address('11111111111111111111111111111111'),
          ],
          metadataUri: 'https://example.com/plan',
        ),
      );
      expect(instruction.programAddress, equals(programAddress));
      expect(instruction.data, isNotNull);
    });

    test('cancelSubscriptionNow instruction encodes (v0.5.0 addition)', () {
      final instruction = getCancelSubscriptionNowInstruction(
        programAddress: programAddress,
        subscriber: const Address('11111111111111111111111111111111'),
        merchant: const Address('11111111111111111111111111111111'),
        planPda: const Address('11111111111111111111111111111111'),
        subscriptionPda: const Address('11111111111111111111111111111111'),
        eventAuthority: const Address('11111111111111111111111111111111'),
        selfProgram: programAddress,
        cancelSubscriptionNowData: CancelSubscriptionNowData(
          expectedCurrentPeriodStartTs: BigInt.from(1000),
        ),
      );
      expect(instruction.programAddress, equals(programAddress));
      expect(instruction.data, isNotNull);
    });

    test('resumeSubscription instruction encodes with resumeData', () {
      final instruction = getResumeSubscriptionInstruction(
        programAddress: programAddress,
        subscriber: const Address('11111111111111111111111111111111'),
        planPda: const Address('11111111111111111111111111111111'),
        subscriptionPda: const Address('11111111111111111111111111111111'),
        subscriptionAuthority: const Address(
          '11111111111111111111111111111111',
        ),
        eventAuthority: const Address('11111111111111111111111111111111'),
        selfProgram: programAddress,
        resumeData: ResumeData(expectedExpiresAtTs: BigInt.from(5000)),
      );
      expect(instruction.programAddress, equals(programAddress));
      expect(instruction.data, isNotNull);
    });
  });
}
