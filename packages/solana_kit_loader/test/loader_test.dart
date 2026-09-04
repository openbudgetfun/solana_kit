import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_instruction_plans/solana_kit_instruction_plans.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_loader/solana_kit_loader.dart';
import 'package:test/test.dart';

void main() {
  const a1 = Address('11111111111111111111111111111111');
  const a2 = Address('11111111111111111111111111111112');
  const a3 = Address('11111111111111111111111111111113');
  const a4 = Address('11111111111111111111111111111114');
  const a5 = Address('11111111111111111111111111111115');

  group('program constants', () {
    test('exports executable loader addresses', () {
      expect(
        solanaLoaderV3ProgramProgramAddress,
        bpfLoaderUpgradeableProgramAddress,
      );
      expect(
        loaderV4ProgramAddress,
        const Address('LoaderV411111111111111111111111111111111111'),
      );
    });
  });

  group('loader v3 generated instructions', () {
    test('builds and parses a write instruction with a u64 byte length', () {
      final bytes = Uint8List.fromList([1, 2, 3]);
      final instruction = getWriteInstruction(
        programAddress: solanaLoaderV3ProgramProgramAddress,
        bufferAccount: a1,
        bufferAuthority: a2,
        offset: 7,
        bytes: bytes,
      );

      expect(instruction.programAddress, bpfLoaderUpgradeableProgramAddress);
      expect(instruction.accounts, hasLength(2));
      expect(instruction.accounts![0].role, AccountRole.writable);
      expect(instruction.accounts![1].role, AccountRole.readonlySigner);
      expect(
        instruction.data,
        Uint8List.fromList([
          1,
          0,
          0,
          0,
          7,
          0,
          0,
          0,
          3,
          0,
          0,
          0,
          0,
          0,
          0,
          0,
          1,
          2,
          3,
        ]),
      );

      final parsed = parseWriteInstruction(instruction);
      expect(parsed.discriminator, 1);
      expect(parsed.offset, 7);
      expect(parsed.bytes, bytes);
    });

    test('builds deploy, upgrade, and checked-authority instructions', () {
      final deploy = getDeployWithMaxDataLenInstruction(
        programAddress: solanaLoaderV3ProgramProgramAddress,
        payerAccount: a1,
        programDataAccount: a2,
        programAccount: a3,
        bufferAccount: a4,
        rentSysvar: sysvarRentAddress,
        clockSysvar: sysvarClockAddress,
        systemProgram: systemProgramAddress,
        authority: a5,
        maxDataLen: BigInt.from(1024),
      );
      expect(deploy.accounts, hasLength(8));
      expect(deploy.accounts![0].role, AccountRole.writableSigner);
      expect(
        parseDeployWithMaxDataLenInstruction(deploy).maxDataLen,
        BigInt.from(1024),
      );

      final upgrade = getUpgradeInstruction(
        programAddress: solanaLoaderV3ProgramProgramAddress,
        programDataAccount: a1,
        programAccount: a2,
        bufferAccount: a3,
        spillAccount: a4,
        rentSysvar: sysvarRentAddress,
        clockSysvar: sysvarClockAddress,
        authority: a5,
      );
      expect(upgrade.accounts, hasLength(7));
      expect(parseUpgradeInstruction(upgrade).discriminator, 3);

      final checked = getSetAuthorityCheckedInstruction(
        programAddress: solanaLoaderV3ProgramProgramAddress,
        bufferOrProgramDataAccount: a1,
        currentAuthority: a2,
        newAuthority: a3,
      );
      expect(checked.accounts![2].role, AccountRole.readonlySigner);
    });
  });

  group('loader v4 handwritten instructions', () {
    test('builds and parses write and truncate instructions', () {
      final write = getLoaderV4WriteInstruction(
        program: a1,
        authority: a2,
        offset: 4,
        bytes: Uint8List.fromList([9, 8]),
      );
      expect(write.programAddress, loaderV4ProgramAddress);
      expect(write.accounts![0].role, AccountRole.writable);
      expect(parseLoaderV4WriteInstruction(write).offset, 4);
      expect(parseLoaderV4Discriminator(write), loaderV4WriteDiscriminator);

      final truncate = getLoaderV4TruncateInstruction(
        program: a1,
        authority: a2,
        destination: a3,
        newSize: 64,
      );
      expect(truncate.accounts, hasLength(3));
      expect(truncate.accounts![0].role, AccountRole.writableSigner);
      expect(parseLoaderV4TruncateInstruction(truncate).newSize, 64);

      final truncateWithoutDestination = getLoaderV4TruncateInstruction(
        program: a1,
        authority: a2,
        newSize: 0,
      );
      expect(truncateWithoutDestination.accounts, hasLength(2));
    });

    test('matches current deploy and authority account layouts', () {
      expect(
        getLoaderV4DeployInstruction(
          program: a1,
          authority: a2,
          source: a3,
        ).accounts,
        hasLength(3),
      );
      expect(
        getLoaderV4DeployInstruction(
          program: a1,
          authority: a2,
        ).accounts,
        hasLength(2),
      );

      final transfer = getLoaderV4TransferAuthorityInstruction(
        program: a1,
        currentAuthority: a2,
        newAuthority: a3,
      );
      expect(transfer.accounts, hasLength(3));
      expect(transfer.accounts![1].role, AccountRole.readonlySigner);
      expect(transfer.accounts![2].role, AccountRole.readonlySigner);

      expect(
        getLoaderV4FinalizeInstruction(
          program: a1,
          authority: a2,
          nextVersion: a3,
        ).accounts![2].role,
        AccountRole.readonly,
      );
    });
  });

  group('handwritten account codecs', () {
    test('encodes loader v3 headers with one-byte option tags', () {
      const buffer = BufferAccount(authorityAddress: a1);
      final bufferBytes = getBufferAccountEncoder().encode(buffer);
      expect(bufferAccountSize, 37);
      expect(bufferBytes, hasLength(bufferAccountSize));
      expect(bufferBytes.sublist(0, 5), [1, 0, 0, 0, 1]);
      expect(getBufferAccountDecoder().decode(bufferBytes), buffer);

      const immutableBuffer = BufferAccount();
      final immutableBytes = getBufferAccountEncoder().encode(immutableBuffer);
      expect(immutableBytes, hasLength(bufferAccountSize));
      expect(immutableBytes[4], 0);
      expect(getBufferAccountDecoder().decode(immutableBytes), immutableBuffer);

      final programData = ProgramDataAccount(
        slot: BigInt.from(55),
        upgradeAuthorityAddress: a2,
      );
      final programDataBytes = getProgramDataAccountEncoder().encode(
        programData,
      );
      expect(programDataAccountSize, 45);
      expect(programDataBytes, hasLength(programDataAccountSize));
      expect(programDataBytes[12], 1);
      expect(
        getProgramDataAccountDecoder().decode(programDataBytes),
        programData,
      );
    });

    test('encodes loader v4 status as a little-endian u64', () {
      final state = ProgramStateAccount(
        slot: BigInt.from(9),
        authorityAddressOrNextVersion: a1,
        status: LoaderV4Status.deployed,
      );
      final encoded = getProgramStateAccountEncoder().encode(state);
      expect(programStateAccountSize, 48);
      expect(encoded, hasLength(programStateAccountSize));
      expect(encoded.sublist(40), [1, 0, 0, 0, 0, 0, 0, 0]);
      expect(getProgramStateAccountDecoder().decode(encoded), state);
    });
  });

  group('instruction plans', () {
    test('chunks deploy and upgrade plans', () {
      final bytes = Uint8List.fromList(List<int>.generate(5, (index) => index));
      final deploy = getDeployProgramInstructionPlan(
        payerAccount: a1,
        programDataAccount: a2,
        programAccount: a3,
        bufferAccount: a4,
        authority: a5,
        programBytes: bytes,
        chunkSize: 2,
      );
      expect(deploy, isA<SequentialInstructionPlan>());
      final deployPlans = (deploy as SequentialInstructionPlan).plans;
      expect(deploy.divisible, isTrue);
      expect(deployPlans, hasLength(4));
      final firstWrite =
          (deployPlans.first as SingleInstructionPlan).instruction;
      expect(firstWrite.programAddress, bpfLoaderUpgradeableProgramAddress);
      expect(firstWrite.accounts![0].address, a4);

      final upgrade = getUpgradeProgramInstructionPlan(
        programDataAccount: a1,
        programAccount: a2,
        bufferAccount: a3,
        spillAccount: a4,
        authority: a5,
        programBytes: bytes,
        chunkSize: 3,
      );
      expect((upgrade as SequentialInstructionPlan).plans, hasLength(3));
    });

    test('rejects non-positive write chunk sizes', () {
      expect(
        () => getDeployProgramInstructionPlan(
          payerAccount: a1,
          programDataAccount: a2,
          programAccount: a3,
          bufferAccount: a4,
          authority: a5,
          programBytes: Uint8List.fromList([1]),
          chunkSize: 0,
        ),
        throwsArgumentError,
      );
    });
  });
}
