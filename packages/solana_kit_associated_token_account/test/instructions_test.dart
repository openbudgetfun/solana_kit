import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_associated_token_account/solana_kit_associated_token_account.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:test/test.dart';

void main() {
  const payer = Address('11111111111111111111111111111111');
  const ata = Address('11111111111111111111111111111112');
  const owner = Address('11111111111111111111111111111113');
  const mint = Address('EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v');
  const systemProgram = Address('11111111111111111111111111111114');
  const tokenProgram = Address('TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA');

  group('getCreateAssociatedTokenInstruction', () {
    test('builds the expected accounts and discriminator', () {
      final instruction = getCreateAssociatedTokenInstruction(
        programAddress: associatedTokenProgramAddress,
        payer: payer,
        ata: ata,
        owner: owner,
        mint: mint,
        systemProgram: systemProgram,
        tokenProgram: tokenProgram,
      );

      expect(instruction.programAddress, associatedTokenProgramAddress);
      expect(instruction.accounts, hasLength(6));
      expect(instruction.accounts![0].role, AccountRole.writableSigner);
      expect(instruction.accounts![1].role, AccountRole.writable);
      expect(
        parseCreateAssociatedTokenInstruction(instruction).discriminator,
        0,
      );
      expect(
        getCreateAssociatedTokenInstructionDataCodec().decode(
          instruction.data!,
        ),
        const CreateAssociatedTokenInstructionData(),
      );
    });

    test('account alias builds the same instruction', () {
      final direct = getCreateAssociatedTokenInstruction(
        programAddress: associatedTokenProgramAddress,
        payer: payer,
        ata: ata,
        owner: owner,
        mint: mint,
        systemProgram: systemProgram,
        tokenProgram: tokenProgram,
      );
      final alias = getCreateAssociatedTokenAccountInstruction(
        programAddress: associatedTokenProgramAddress,
        payer: payer,
        ata: ata,
        owner: owner,
        mint: mint,
        systemProgram: systemProgram,
        tokenProgram: tokenProgram,
      );

      expect(alias.programAddress, direct.programAddress);
      expect(alias.accounts, direct.accounts);
      expect(alias.data, direct.data);
    });
  });

  group('getCreateAssociatedTokenIdempotentInstruction', () {
    test('uses discriminator 1', () {
      final instruction = getCreateAssociatedTokenIdempotentInstruction(
        programAddress: associatedTokenProgramAddress,
        payer: payer,
        ata: ata,
        owner: owner,
        mint: mint,
        systemProgram: systemProgram,
        tokenProgram: tokenProgram,
      );

      expect(
        parseCreateAssociatedTokenIdempotentInstruction(
          instruction,
        ).discriminator,
        1,
      );
      expect(
        getCreateAssociatedTokenIdempotentInstructionDataCodec().decode(
          instruction.data!,
        ),
        const CreateAssociatedTokenIdempotentInstructionData(),
      );
    });
  });

  group('recover nested associated token', () {
    test('uses discriminator 2 and seven accounts', () {
      final instruction = getRecoverNestedAssociatedTokenInstruction(
        programAddress: associatedTokenProgramAddress,
        nestedAssociatedAccountAddress: ata,
        nestedTokenMintAddress: mint,
        destinationAssociatedAccountAddress: payer,
        ownerAssociatedAccountAddress: owner,
        ownerTokenMintAddress: const Address(
          'Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB',
        ),
        walletAddress: payer,
        tokenProgram: tokenProgram,
      );

      expect(instruction.accounts, hasLength(7));
      expect(instruction.accounts![5].role, AccountRole.writableSigner);
      expect(
        parseRecoverNestedAssociatedTokenInstruction(instruction).discriminator,
        2,
      );
      expect(
        getRecoverNestedAssociatedTokenInstructionDataCodec().decode(
          instruction.data!,
        ),
        const RecoverNestedAssociatedTokenInstructionData(),
      );
    });
  });

  group('error helpers', () {
    test('recognize invalid owner', () {
      expect(associatedTokenErrorInvalidOwner, 0);
      expect(isAssociatedTokenError(0), isTrue);
      expect(getAssociatedTokenErrorMessage(0), isNotNull);
    });
  });
}
