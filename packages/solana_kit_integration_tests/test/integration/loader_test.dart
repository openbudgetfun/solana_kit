/// On-chain integration tests for the BPF Loader (upgradeable) program client
/// against SurfPool.
///
/// Creates and initializes a program buffer account, then verifies it exists
/// on-chain and is owned by the upgradeable BPF Loader. (Full program deploy
/// requires compiled BPF bytes, which is out of scope for this suite.)
@TestOn('vm')
@Tags(['integration'])
library;

import 'dart:io';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_integration_tests/solana_kit_integration_tests.dart';
import 'package:solana_kit_loader/solana_kit_loader.dart';
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

  test(
    'initializeBuffer creates a buffer account owned by the BPF loader',
    () async {
      final buffer = generateKeyPairSigner();
      // A 37-byte buffer account (authority header) is rent-exempt around
      // 1_148_400 lamports; fund a little extra to be safe.
      const bufferRent = 1_500_000;

      await env.sendInstructions(
        [
          getCreateAccountInstruction(
            instructionProgramAddress: systemProgramAddress,
            payer: env.payer.address,
            newAccount: buffer.address,
            lamports: BigInt.from(bufferRent),
            space: BigInt.from(37),
            programAddress: bpfLoaderUpgradeableProgramAddress,
          ),
          getInitializeBufferInstruction(
            programAddress: bpfLoaderUpgradeableProgramAddress,
            sourceAccount: buffer.address,
            bufferAuthority: env.payer.address,
          ),
        ],
        extraSigners: [buffer],
      );

      final account = await env.rpc.getAccountInfoValue(buffer.address).send();
      expect(account.value, isNotNull);
      expect(
        account.value!['owner'],
        equals(bpfLoaderUpgradeableProgramAddress.value),
      );
    },
  );

  test('write + deployWithMaxDataLen deploys a program on-chain', () async {
    // Deploy the committed noop program (18 KB) through the loader client.
    final programBytes = File(
      resolveWorkspaceArtifactPath('config/programs/noop-v0.2.0.so'),
    ).readAsBytesSync();
    final buffer = generateKeyPairSigner();
    final programAccount = generateKeyPairSigner();
    // The program-data account is a PDA derived from the program account.
    final (programDataAddress, _) = await getProgramDerivedAddress(
      seeds: [getAddressEncoder().encode(programAccount.address)],
      programAddress: bpfLoaderUpgradeableProgramAddress,
    );
    // The buffer holds the loader header (37 bytes) plus the program bytes;
    // 130M lamports is rent-exempt for that size.
    final bufferSpace = 37 + programBytes.length;
    const bufferRent = 130_000_000;

    // Create + initialize the buffer.
    await env.sendInstructions(
      [
        getCreateAccountInstruction(
          instructionProgramAddress: systemProgramAddress,
          payer: env.payer.address,
          newAccount: buffer.address,
          lamports: BigInt.from(bufferRent),
          space: BigInt.from(bufferSpace),
          programAddress: bpfLoaderUpgradeableProgramAddress,
        ),
        getInitializeBufferInstruction(
          programAddress: bpfLoaderUpgradeableProgramAddress,
          sourceAccount: buffer.address,
          bufferAuthority: env.payer.address,
        ),
      ],
      extraSigners: [buffer],
    );

    // Write the program bytes in 900-byte chunks (one tx per chunk).
    const chunkSize = 900;
    for (var offset = 0; offset < programBytes.length; offset += chunkSize) {
      final end = (offset + chunkSize).clamp(0, programBytes.length);
      await env.sendInstructions([
        getWriteInstruction(
          programAddress: bpfLoaderUpgradeableProgramAddress,
          bufferAccount: buffer.address,
          bufferAuthority: env.payer.address,
          offset: offset,
          bytes: programBytes.sublist(offset, end),
        ),
      ]);
    }

    // The loader's deploy expects the program account to already exist and
    // be owned by the BPF loader (the solana CLI creates it the same way).
    await env.sendInstructions(
      [
        getCreateAccountInstruction(
          instructionProgramAddress: systemProgramAddress,
          payer: env.payer.address,
          newAccount: programAccount.address,
          lamports: BigInt.from(1_500_000),
          space: BigInt.from(36),
          programAddress: bpfLoaderUpgradeableProgramAddress,
        ),
      ],
      extraSigners: [programAccount],
    );

    // Deploy from the buffer to the program account.
    await env.sendInstructions([
      getDeployWithMaxDataLenInstruction(
        programAddress: bpfLoaderUpgradeableProgramAddress,
        payerAccount: env.payer.address,
        programDataAccount: programDataAddress,
        programAccount: programAccount.address,
        bufferAccount: buffer.address,
        rentSysvar: sysvarRentAddress,
        clockSysvar: sysvarClockAddress,
        systemProgram: systemProgramAddress,
        authority: env.payer.address,
        maxDataLen: BigInt.from(programBytes.length),
      ),
    ]);

    // The program account is now executable and owned by the BPF loader.
    final program = await env.rpc
        .getAccountInfoValue(programAccount.address)
        .send();
    expect(program.value, isNotNull);
    expect(program.value!['executable'], equals(true));
    expect(
      program.value!['owner'],
      equals(bpfLoaderUpgradeableProgramAddress.value),
    );
  });

  test('setAuthority and close manage the buffer lifecycle on-chain', () async {
    final buffer = generateKeyPairSigner();
    final newAuthority = generateKeyPairSigner();
    const bufferRent = 1_500_000;

    await env.sendInstructions(
      [
        getCreateAccountInstruction(
          instructionProgramAddress: systemProgramAddress,
          payer: env.payer.address,
          newAccount: buffer.address,
          lamports: BigInt.from(bufferRent),
          space: BigInt.from(37),
          programAddress: bpfLoaderUpgradeableProgramAddress,
        ),
        getInitializeBufferInstruction(
          programAddress: bpfLoaderUpgradeableProgramAddress,
          sourceAccount: buffer.address,
          bufferAuthority: env.payer.address,
        ),
      ],
      extraSigners: [buffer],
    );

    // Transfer buffer authority to a new keypair.
    await env.sendInstructions([
      getSetAuthorityInstruction(
        programAddress: bpfLoaderUpgradeableProgramAddress,
        bufferOrProgramDataAccount: buffer.address,
        currentAuthority: env.payer.address,
        newAuthority: newAuthority.address,
      ),
    ]);

    // The new authority closes the buffer, returning lamports to the payer.
    final payerBefore = await env.rpc.getBalanceValue(env.payer.address).send();
    await env.sendInstructions(
      [
        getCloseInstruction(
          programAddress: bpfLoaderUpgradeableProgramAddress,
          bufferOrProgramDataAccount: buffer.address,
          destinationAccount: env.payer.address,
          authority: newAuthority.address,
        ),
      ],
      extraSigners: [newAuthority],
    );

    final closed = await env.rpc.getAccountInfoValue(buffer.address).send();
    expect(closed.value, isNull);
    final payerAfter = await env.rpc.getBalanceValue(env.payer.address).send();
    expect(payerAfter.value.value, greaterThan(payerBefore.value.value));
  });
}
