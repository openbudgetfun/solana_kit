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
    test('exports loader addresses', () {
      expect(
        bpfLoaderUpgradeableProgramAddress,
        const Address('BPFLoaderUpgradeab1e11111111111111111111111'),
      );
      expect(
        loaderV4ProgramAddress,
        const Address('LoaderV411111111111111111111111111111111111'),
      );
    });
  });

  group('loader v3 instructions', () {
    test('builds and parses write instruction', () {
      final bytes = Uint8List.fromList([1, 2, 3]);
      final ix = getLoaderV3WriteInstruction(
        bufferAccount: a1,
        bufferAuthority: a2,
        offset: 7,
        bytes: bytes,
      );

      expect(ix.programAddress, bpfLoaderUpgradeableProgramAddress);
      expect(ix.accounts, hasLength(2));
      expect(ix.accounts![0].role, AccountRole.writable);
      expect(ix.accounts![1].role, AccountRole.readonlySigner);

      final parsed = parseLoaderV3WriteInstruction(ix);
      expect(parsed.discriminator, loaderV3WriteDiscriminator);
      expect(parsed.offset, 7);
      expect(parsed.bytes, bytes);
    });

    test('builds deploy, upgrade and authority instructions', () {
      final deploy = getDeployWithMaxProgramLenInstruction(
        payerAccount: a1,
        programDataAccount: a2,
        programAccount: a3,
        bufferAccount: a4,
        authority: a5,
        maxDataLen: BigInt.from(1024),
      );
      expect(deploy.accounts, hasLength(8));
      expect(deploy.accounts![0].role, AccountRole.writableSigner);
      expect(
        parseDeployWithMaxProgramLenInstruction(deploy).maxDataLen,
        BigInt.from(1024),
      );

      final upgrade = getUpgradeInstruction(
        programDataAccount: a1,
        programAccount: a2,
        bufferAccount: a3,
        spillAccount: a4,
        authority: a5,
      );
      expect(upgrade.accounts, hasLength(7));
      expect(parseDiscriminator(upgrade), upgradeDiscriminator);

      final checked = getSetAuthorityCheckedInstruction(
        bufferOrProgramDataAccount: a1,
        currentAuthority: a2,
        newAuthority: a3,
      );
      expect(checked.accounts![2].role, AccountRole.readonlySigner);
    });
  });

  group('loader v4 instructions', () {
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
      expect(truncate.accounts![0].role, AccountRole.writableSigner);
      expect(parseLoaderV4TruncateInstruction(truncate).newSize, 64);
    });

    test('builds deploy, retract, transfer authority and finalize', () {
      expect(
        getLoaderV4DeployInstruction(
          program: a1,
          authority: a2,
          source: a3,
        ).accounts,
        hasLength(3),
      );
      expect(
        getLoaderV4RetractInstruction(program: a1, authority: a2).accounts,
        hasLength(2),
      );
      expect(
        getLoaderV4TransferAuthorityInstruction(
          program: a1,
          newAuthority: a2,
        ).accounts![1].role,
        AccountRole.readonlySigner,
      );
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

  group('account codecs', () {
    test('encodes and decodes loader v3 account headers', () {
      const buffer = BufferAccount(authorityAddress: a1);
      final decodedBuffer = getBufferAccountDecoder().decode(
        getBufferAccountEncoder().encode(buffer),
      );
      expect(bufferAccountSize, 40);
      expect(decodedBuffer, buffer);

      final programData = ProgramDataAccount(
        slot: BigInt.from(55),
        upgradeAuthorityAddress: a2,
      );
      final decodedProgramData = getProgramDataAccountDecoder().decode(
        getProgramDataAccountEncoder().encode(programData),
      );
      expect(programDataAccountSize, 48);
      expect(decodedProgramData, programData);
    });

    test('encodes and decodes loader v4 program state', () {
      final state = ProgramStateAccount(
        slot: BigInt.from(9),
        authorityAddressOrNextVersion: a1,
        status: LoaderV4Status.deployed,
      );
      final encoded = getProgramStateAccountEncoder().encode(state);
      final decoded = getProgramStateAccountDecoder().decode(encoded);
      expect(programStateAccountSize, 48);
      expect(encoded, hasLength(48));
      expect(decoded, state);
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
      expect(deploy.divisible, isFalse);
      expect(deployPlans, hasLength(4));
      expect(
        (deployPlans.first as SingleInstructionPlan)
            .instruction
            .accounts![0]
            .address,
        a4,
      );

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
