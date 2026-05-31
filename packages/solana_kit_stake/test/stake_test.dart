import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_instruction_plans/solana_kit_instruction_plans.dart';
import 'package:solana_kit_stake/solana_kit_stake.dart';
import 'package:test/test.dart';

void main() {
  const payer = Address('11111111111111111111111111111111');
  const stake = Address('11111111111111111111111111111112');
  const vote = Address('Vote111111111111111111111111111111111111111');
  const authority = Address('11111111111111111111111111111113');

  group('stake program', () {
    test('exposes the canonical program address', () {
      expect(
        solanaStakeInterfaceProgramAddress.value,
        'Stake11111111111111111111111111111111111111',
      );
    });

    test('builds and parses delegate stake instructions', () {
      final instruction = getDelegateStakeInstruction(
        programAddress: solanaStakeInterfaceProgramAddress,
        stake: stake,
        vote: vote,
        clockSysvar: sysvarClockAddress,
        stakeHistory: sysvarStakeHistoryAddress,
        unused: stakeConfigAddress,
        stakeAuthority: authority,
      );

      final parsed = parseDelegateStakeInstruction(instruction);

      expect(parsed.discriminator, 2);
      expect(instruction.accounts, hasLength(6));
    });

    test('builds the delegate stake instruction plan', () {
      final plan = getDelegateStakeInstructionPlan(
        stake: stake,
        vote: vote,
        stakeAuthority: authority,
      );

      expect(plan, isA<SingleInstructionPlan>());
    });

    test('builds the create stake account instruction plan', () {
      final plan = getCreateStakeAccountInstructionPlan(
        payer: payer,
        stake: stake,
        lamports: BigInt.from(1_000_000_000),
        authorized: const Authorized(staker: authority, withdrawer: authority),
      );

      expect(plan, isA<SequentialInstructionPlan>());
      final sequential = plan as SequentialInstructionPlan;
      expect(sequential.divisible, isFalse);
      expect(sequential.plans, hasLength(2));
    });

    test('round-trips uninitialized stake accounts', () {
      const account = StakeAccount(state: StakeStateV2Uninitialized());

      final encoded = getStakeAccountEncoder().encode(account);
      final decoded = getStakeAccountDecoder().decode(encoded);

      expect(decoded.state, isA<StakeStateV2Uninitialized>());
    });
  });
}
