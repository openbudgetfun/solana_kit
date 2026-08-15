/// On-chain integration tests for the Stake program client against SurfPool.
///
/// Creates and initializes a stake account, then verifies it exists on-chain
/// and is owned by the Stake program. (Delegation/rewards require a vote
/// account and epoch advancement, which are out of scope for this suite.)
@TestOn('vm')
@Tags(['integration'])
library;

import 'package:solana_kit_address_constants/solana_kit_address_constants.dart';
import 'package:solana_kit_integration_tests/solana_kit_integration_tests.dart';
import 'package:solana_kit_rpc/solana_kit_rpc.dart';
import 'package:solana_kit_rpc_api/solana_kit_rpc_api.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:solana_kit_signers/solana_kit_signers.dart';
import 'package:solana_kit_stake/solana_kit_stake.dart';
import 'package:solana_kit_system/solana_kit_system.dart';
import 'package:test/test.dart';

void main() {
  late IntegrationTestEnv env;

  setUpAll(() async {
    env = await IntegrationTestEnv.create();
  });

  tearDownAll(() => env.dispose());

  test('initialize creates a stake account owned by the Stake program', () async {
    final stakeAccount = generateKeyPairSigner();
    // A stake account is 200 bytes; 2_282_880 lamports is rent-exempt for that.
    const stakeRent = 2_282_880;

    await env.sendInstructions(
      [
        getCreateAccountInstruction(
          instructionProgramAddress: systemProgramAddress,
          payer: env.payer.address,
          newAccount: stakeAccount.address,
          lamports: BigInt.from(stakeRent),
          space: BigInt.from(200),
          programAddress: stakeProgramAddress,
        ),
        getInitializeInstruction(
          programAddress: stakeProgramAddress,
          stake: stakeAccount.address,
          rentSysvar: sysvarRentAddress,
          arg0: Authorized(
            staker: env.payer.address,
            withdrawer: env.payer.address,
          ),
          arg1: Lockup(
            unixTimestamp: BigInt.zero,
            epoch: BigInt.zero,
            custodian: systemProgramAddress,
          ),
        ),
      ],
      extraSigners: [stakeAccount],
    );

    final account = await env.rpc
        .getAccountInfoValue(stakeAccount.address)
        .send();
    expect(account.value, isNotNull);
    expect(account.value!['owner'], equals(stakeProgramAddress.value));
  });

  test('authorize changes the withdrawer on-chain', () async {
    final stakeAccount = generateKeyPairSigner();
    final newWithdrawer = generateKeyPairSigner();
    const stakeRent = 2_282_880;

    await env.sendInstructions(
      [
        getCreateAccountInstruction(
          instructionProgramAddress: systemProgramAddress,
          payer: env.payer.address,
          newAccount: stakeAccount.address,
          lamports: BigInt.from(stakeRent),
          space: BigInt.from(200),
          programAddress: stakeProgramAddress,
        ),
        getInitializeInstruction(
          programAddress: stakeProgramAddress,
          stake: stakeAccount.address,
          rentSysvar: sysvarRentAddress,
          arg0: Authorized(
            staker: env.payer.address,
            withdrawer: env.payer.address,
          ),
          arg1: Lockup(
            unixTimestamp: BigInt.zero,
            epoch: BigInt.zero,
            custodian: systemProgramAddress,
          ),
        ),
      ],
      extraSigners: [stakeAccount],
    );

    await env.sendInstructions([
      getAuthorizeInstruction(
        programAddress: stakeProgramAddress,
        stake: stakeAccount.address,
        clockSysvar: sysvarClockAddress,
        authority: env.payer.address,
        arg0: newWithdrawer.address,
        arg1: StakeAuthorize.withdrawer,
      ),
    ]);

    // The parsed stake account now reports the new withdrawer.
    final account = await env.rpc
        .getAccountInfoValue(
          stakeAccount.address,
          const GetAccountInfoConfig(encoding: AccountEncoding.jsonParsed),
        )
        .send();
    final parsed = account.value!['data']! as Map<String, Object?>;
    final info = parsed['parsed']! as Map<String, Object?>;
    final stakeInfo = info['info']! as Map<String, Object?>;
    final meta = stakeInfo['meta']! as Map<String, Object?>;
    final authorized = meta['authorized']! as Map<String, Object?>;
    expect(authorized['withdrawer'], equals(newWithdrawer.address.value));
  });
}
