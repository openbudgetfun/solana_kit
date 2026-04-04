// Test addresses are constructed dynamically.
// ignore_for_file: prefer_const_constructors

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_instruction_plans/solana_kit_instruction_plans.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_system/solana_kit_system.dart';
import 'package:solana_kit_token/solana_kit_token.dart';
import 'package:test/test.dart';

void main() {
  const mint = Address('EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v');
  const owner = Address('11111111111111111111111111111111');
  const destination = Address('11111111111111111111111111111112');
  const authority = Address('11111111111111111111111111111113');

  group('getTransferInstruction', () {
    test('builds instruction with correct program address and accounts', () {
      final ix = getTransferInstruction(
        programAddress: tokenProgramAddress,
        source: owner,
        destination: destination,
        authority: authority,
        amount: BigInt.from(1000),
      );

      expect(ix.programAddress, tokenProgramAddress);
      final accs = ix.accounts!;
      expect(accs, hasLength(3));
      expect(accs[0].address, owner);
      expect(accs[0].role, AccountRole.writable);
      expect(accs[1].address, destination);
      expect(accs[1].role, AccountRole.writable);
      expect(accs[2].address, authority);
      expect(accs[2].role, AccountRole.readonlySigner);

      final parsed = parseTransferInstruction(ix);
      expect(parsed.discriminator, 3);
      expect(parsed.amount, BigInt.from(1000));
    });
  });

  group('getInitializeMint2Instruction', () {
    test('builds instruction with correct accounts', () {
      final ix = getInitializeMint2Instruction(
        programAddress: tokenProgramAddress,
        mint: mint,
        decimals: 6,
        mintAuthority: authority,
      );

      expect(ix.programAddress, tokenProgramAddress);
      final accs = ix.accounts!;
      expect(accs, hasLength(1));
      expect(accs[0].address, mint);
      expect(accs[0].role, AccountRole.writable);

      final parsed = parseInitializeMint2Instruction(ix);
      expect(parsed.discriminator, 20);
      expect(parsed.decimals, 6);
      expect(parsed.mintAuthority, authority);
      expect(parsed.freezeAuthority, isNull);
    });
  });

  group('getCreateAssociatedTokenIdempotentInstruction', () {
    test('builds instruction with all required accounts', () {
      final ix = getCreateAssociatedTokenIdempotentInstruction(
        programAddress: associatedTokenProgramAddress,
        payer: owner,
        ata: destination,
        owner: authority,
        mint: mint,
        systemProgram: Address('11111111111111111111111111111111'),
        tokenProgram: tokenProgramAddress,
      );

      expect(ix.programAddress, associatedTokenProgramAddress);
      final accs = ix.accounts!;
      expect(accs, hasLength(6));
      expect(accs[0].role, AccountRole.writableSigner); // payer
      expect(accs[1].role, AccountRole.writable); // ata
    });
  });

  group('getCreateMintInstructionPlan', () {
    test('returns a sequential plan with two instructions', () {
      final plan = getCreateMintInstructionPlan(
        CreateMintInput(
          payer: owner,
          newMint: mint,
          decimals: 6,
          mintAuthority: authority,
        ),
      );

      expect(plan, isA<SequentialInstructionPlan>());
      final seq = plan as SequentialInstructionPlan;
      expect(seq.plans, hasLength(2));

      final createIx = (seq.plans[0] as SingleInstructionPlan).instruction;
      expect(
        createIx.programAddress,
        Address('11111111111111111111111111111111'),
      );

      final initIx = (seq.plans[1] as SingleInstructionPlan).instruction;
      expect(initIx.programAddress, tokenProgramAddress);
    });

    test(
      'supports freeze authority, custom lamports, and program overrides',
      () {
        const customSystemProgram = Address('11111111111111111111111111111114');
        const customTokenProgram = Address('11111111111111111111111111111115');

        final plan =
            getCreateMintInstructionPlan(
                  CreateMintInput(
                    payer: owner,
                    newMint: mint,
                    decimals: 9,
                    mintAuthority: authority,
                    freezeAuthority: destination,
                    mintAccountLamports: BigInt.from(99),
                  ),
                  const CreateMintConfig(
                    tokenProgram: customTokenProgram,
                    systemProgram: customSystemProgram,
                  ),
                )
                as SequentialInstructionPlan;

        final createIx = (plan.plans[0] as SingleInstructionPlan).instruction;
        final parsedCreate = parseCreateAccountInstruction(createIx);
        expect(createIx.programAddress, customSystemProgram);
        expect(parsedCreate.lamports, BigInt.from(99));
        expect(parsedCreate.programOwner, customTokenProgram);

        final initIx = (plan.plans[1] as SingleInstructionPlan).instruction;
        final parsedInit = parseInitializeMint2Instruction(initIx);
        expect(initIx.programAddress, customTokenProgram);
        expect(parsedInit.freezeAuthority, destination);
        expect(parsedInit.decimals, 9);
      },
    );
  });

  group('getMintToAtaInstructionPlan', () {
    test('returns a sequential plan with create-ATA + mint-to-checked', () {
      final plan = getMintToAtaInstructionPlan(
        MintToAtaInput(
          payer: owner,
          ata: destination,
          owner: authority,
          mint: mint,
          mintAuthority: authority,
          amount: BigInt.from(500),
          decimals: 6,
        ),
      );

      expect(plan, isA<SequentialInstructionPlan>());
      final seq = plan as SequentialInstructionPlan;
      expect(seq.plans, hasLength(2));

      final createAtaIx = (seq.plans[0] as SingleInstructionPlan).instruction;
      expect(createAtaIx.programAddress, associatedTokenProgramAddress);

      final mintToIx = (seq.plans[1] as SingleInstructionPlan).instruction;
      expect(mintToIx.programAddress, tokenProgramAddress);
    });

    test(
      'async helper derives the ATA and respects config overrides',
      () async {
        const customTokenProgram = Address('11111111111111111111111111111114');
        const customAtaProgram = Address('11111111111111111111111111111115');
        const customSystemProgram = Address('11111111111111111111111111111116');

        final plan =
            await getMintToAtaInstructionPlanAsync(
                  payer: owner,
                  owner: authority,
                  mint: mint,
                  mintAuthority: authority,
                  amount: BigInt.from(500),
                  decimals: 6,
                  config: const MintToAtaConfig(
                    tokenProgram: customTokenProgram,
                    associatedTokenProgram: customAtaProgram,
                    systemProgram: customSystemProgram,
                  ),
                )
                as SequentialInstructionPlan;

        final createAtaIx =
            (plan.plans[0] as SingleInstructionPlan).instruction;
        expect(createAtaIx.programAddress, customAtaProgram);
        expect(createAtaIx.accounts![2].address, authority);
        expect(createAtaIx.accounts![4].address, customSystemProgram);
        expect(createAtaIx.accounts![5].address, customTokenProgram);

        final mintToIx = (plan.plans[1] as SingleInstructionPlan).instruction;
        expect(mintToIx.programAddress, customTokenProgram);
        expect(mintToIx.accounts![1].address, createAtaIx.accounts![1].address);
      },
    );
  });

  group('getTransferToAtaInstructionPlan', () {
    test('returns a sequential plan with create-ATA + transfer-checked', () {
      final plan = getTransferToAtaInstructionPlan(
        TransferToAtaInput(
          payer: owner,
          mint: mint,
          source: owner,
          authority: authority,
          destination: destination,
          recipient: destination,
          amount: BigInt.from(100),
          decimals: 6,
        ),
      );

      expect(plan, isA<SequentialInstructionPlan>());
      final seq = plan as SequentialInstructionPlan;
      expect(seq.plans, hasLength(2));

      final createAtaIx = (seq.plans[0] as SingleInstructionPlan).instruction;
      expect(createAtaIx.programAddress, associatedTokenProgramAddress);

      final transferIx = (seq.plans[1] as SingleInstructionPlan).instruction;
      expect(transferIx.programAddress, tokenProgramAddress);
    });

    test('async helper derives source and destination ATAs', () async {
      const customTokenProgram = Address('11111111111111111111111111111114');
      const customAtaProgram = Address('11111111111111111111111111111115');

      final plan =
          await getTransferToAtaInstructionPlanAsync(
                payer: owner,
                mint: mint,
                authority: authority,
                recipient: destination,
                amount: BigInt.from(100),
                decimals: 6,
                config: const TransferToAtaConfig(
                  tokenProgram: customTokenProgram,
                  associatedTokenProgram: customAtaProgram,
                ),
              )
              as SequentialInstructionPlan;

      final createAtaIx = (plan.plans[0] as SingleInstructionPlan).instruction;
      expect(createAtaIx.programAddress, customAtaProgram);
      expect(createAtaIx.accounts![2].address, destination);
      expect(createAtaIx.accounts![5].address, customTokenProgram);

      final transferIx = (plan.plans[1] as SingleInstructionPlan).instruction;
      final parsedTransfer = parseTransferCheckedInstruction(transferIx);
      expect(transferIx.programAddress, customTokenProgram);
      expect(transferIx.accounts![2].address, createAtaIx.accounts![1].address);
      expect(
        transferIx.accounts![0].address,
        isNot(transferIx.accounts![2].address),
      );
      expect(transferIx.accounts![3].address, authority);
      expect(parsedTransfer.amount, BigInt.from(100));
    });
  });

  group('program constants', () {
    test('tokenProgramAddress is correct', () {
      expect(
        tokenProgramAddress,
        Address('TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA'),
      );
    });

    test('associatedTokenProgramAddress is correct', () {
      expect(
        associatedTokenProgramAddress,
        Address('ATokenGPvbdGVxr1b2hvZbsiqW5xWH25efTNsLJA8knL'),
      );
    });

    test('mintSize is 82', () => expect(mintSize, 82));
    test('tokenSize is 165', () => expect(tokenSize, 165));
  });

  group('error helpers', () {
    test('token error codes are defined', () {
      expect(tokenErrorNotRentExempt, 0);
      expect(tokenErrorInsufficientFunds, 1);
      expect(isTokenError(0), isTrue);
      expect(getTokenErrorMessage(0), isNotNull);
    });

    test('associated token error codes are defined', () {
      expect(associatedTokenErrorInvalidOwner, 0);
      expect(isAssociatedTokenError(0), isTrue);
      expect(getAssociatedTokenErrorMessage(0), isNotNull);
    });
  });
}
