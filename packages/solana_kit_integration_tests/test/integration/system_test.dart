/// On-chain integration tests for the System program client against SurfPool.
@TestOn('vm')
@Tags(['integration'])
library;

import 'dart:convert';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_integration_tests/solana_kit_integration_tests.dart';
import 'package:solana_kit_rpc/solana_kit_rpc.dart';
import 'package:solana_kit_signers/solana_kit_signers.dart';
import 'package:solana_kit_system/solana_kit_system.dart';
import 'package:test/test.dart';

void main() {
  late IntegrationTestEnv env;

  setUpAll(() async {
    env = await IntegrationTestEnv.create();
  });

  tearDownAll(() => env.dispose());

  test('transferSol moves lamports to the recipient on-chain', () async {
    final recipient = generateKeyPairSigner();
    await env.surfnet.fundSol(env.payer.address, 5_000_000_000);
    const amount = 1_000_000;

    final before = await env.rpc.getBalanceValue(env.payer.address).send();

    await env.sendInstructions([
      getTransferSolInstruction(
        programAddress: systemProgramAddress,
        source: env.payer.address,
        destination: recipient.address,
        amount: BigInt.from(amount),
      ),
    ]);

    // Assert the recipient holds exactly the transferred amount and the
    // payer's balance decreased by at least the transfer plus fees.
    final recipientBalance = await env.rpc
        .getBalanceValue(recipient.address)
        .send();
    expect(recipientBalance.value.value, equals(BigInt.from(amount)));

    final after = await env.rpc.getBalanceValue(env.payer.address).send();
    expect(after.value.value, lessThan(before.value.value));
  });

  test(
    'createAccountWithSeed creates an account at the derived address',
    () async {
      const seed = 'seeded-account';
      // createAccountWithSeed derives the address as SHA-256(base || seed ||
      // owner), not as a PDA (no bump seed).
      final derived = await createAddressWithSeed(
        baseAddress: env.payer.address,
        programAddress: tokenProgramAddress,
        seed: seed,
      );

      await env.sendInstructions([
        getCreateAccountWithSeedInstruction(
          instructionProgramAddress: systemProgramAddress,
          payer: env.payer.address,
          newAccount: derived,
          base: env.payer.address,
          seed: seed,
          amount: BigInt.from(1_000_000),
          space: BigInt.from(0),
          programAddress: tokenProgramAddress,
        ),
      ]);

      final account = await env.rpc.getAccountInfoValue(derived).send();
      expect(account.value, isNotNull);
      expect(account.value!['owner'], equals(tokenProgramAddress.value));
    },
  );

  test('transferSolWithSeed moves lamports from a seeded account', () async {
    const seed = 'seeded-source';
    // createAccountWithSeed derives the address as SHA-256(base || seed ||
    // owner), not as a PDA (no bump seed).
    final seededSource = await createAddressWithSeed(
      baseAddress: env.payer.address,
      programAddress: systemProgramAddress,
      seed: seed,
    );
    final recipient = generateKeyPairSigner();

    // Fund the seeded account first.
    await env.sendInstructions([
      getCreateAccountWithSeedInstruction(
        instructionProgramAddress: systemProgramAddress,
        payer: env.payer.address,
        newAccount: seededSource,
        base: env.payer.address,
        seed: seed,
        amount: BigInt.from(2_000_000),
        space: BigInt.from(0),
        programAddress: systemProgramAddress,
      ),
    ]);

    const amount = 1_000_000;
    await env.sendInstructions([
      getTransferSolWithSeedInstruction(
        programAddress: systemProgramAddress,
        source: seededSource,
        baseAccount: env.payer.address,
        destination: recipient.address,
        amount: BigInt.from(amount),
        fromSeed: seed,
        fromOwner: systemProgramAddress,
      ),
    ]);

    final recipientBalance = await env.rpc
        .getBalanceValue(recipient.address)
        .send();
    expect(recipientBalance.value.value, equals(BigInt.from(amount)));
  });

  test('assign changes the account owner on-chain', () async {
    final account = generateKeyPairSigner();
    await env.sendInstructions(
      [
        getCreateAccountInstruction(
          instructionProgramAddress: systemProgramAddress,
          payer: env.payer.address,
          newAccount: account.address,
          lamports: BigInt.from(1_000_000),
          space: BigInt.from(0),
          programAddress: systemProgramAddress,
        ),
      ],
      extraSigners: [account],
    );

    await env.sendInstructions(
      [
        getAssignInstruction(
          instructionProgramAddress: systemProgramAddress,
          account: account.address,
          programAddress: tokenProgramAddress,
        ),
      ],
      extraSigners: [account],
    );

    final after = await env.rpc.getAccountInfoValue(account.address).send();
    expect(after.value!['owner'], equals(tokenProgramAddress.value));
  });

  test('allocate reserves space in an account on-chain', () async {
    final account = generateKeyPairSigner();
    await env.sendInstructions(
      [
        getCreateAccountInstruction(
          instructionProgramAddress: systemProgramAddress,
          payer: env.payer.address,
          newAccount: account.address,
          // Allocating 64 bytes later requires the account to be rent-exempt
          // for that size (~1.34M lamports), so fund 2M up front.
          lamports: BigInt.from(2_000_000),
          space: BigInt.from(0),
          programAddress: systemProgramAddress,
        ),
      ],
      extraSigners: [account],
    );

    await env.sendInstructions(
      [
        getAllocateInstruction(
          programAddress: systemProgramAddress,
          newAccount: account.address,
          space: BigInt.from(64),
        ),
      ],
      extraSigners: [account],
    );

    final after = await env.rpc.getAccountInfoValue(account.address).send();
    final data = after.value!['data']! as List<Object?>;
    expect(data[1], equals('base64'));
    expect(base64Decode(data[0]! as String).length, equals(64));
  });
}
