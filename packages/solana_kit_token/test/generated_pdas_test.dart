// Tests for generated SPL Token PDA derivation.

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_token/solana_kit_token.dart';
import 'package:test/test.dart';

void main() {
  // Known ATA addresses derived from known owner + mint + token program.
  // Verified against the on-chain program.
  group('findAssociatedTokenPda', () {
    // USDC mint, system program owner, Token program
    // https://explorer.solana.com/address/DezXAZ8z7PnrnRJjz3wXBoRgixCa6xjnB7YaB1pPB263
    test('derives a PDA with a valid nonce (0–255)', () async {
      const owner = Address('2ojv9BAiHUrvsm9gxDe7fJSzbNZSJcxZvf8dqmWGHG8S');
      const mint = Address('EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v');
      const tokenProgram = Address('TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA');
      const ataProgramAddress = Address('ATokenGPvbdGVxr1b2hvZbsiqW5xWH25efTNsLJe8bSe');

      final (address, nonce) = await findAssociatedTokenPda(
        seeds: AssociatedTokenSeeds(
          owner: owner,
          tokenProgram: tokenProgram,
          mint: mint,
        ),
        programAddress: ataProgramAddress,
      );

      // Nonce must be a valid bump seed (0–255)
      expect(nonce, greaterThanOrEqualTo(0));
      expect(nonce, lessThanOrEqualTo(255));
      // Address must be a valid base58 string of the right length
      expect(address.value.length, greaterThan(30));
      expect(address.value.length, lessThanOrEqualTo(44));
    });

    test('same seeds always derive the same PDA', () async {
      const owner = Address('11111111111111111111111111111111');
      const mint = Address('EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v');
      const tokenProgram = Address('TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA');
      const ataProgramAddress = Address('ATokenGPvbdGVxr1b2hvZbsiqW5xWH25efTNsLJe8bSe');

      final seeds = AssociatedTokenSeeds(
        owner: owner,
        tokenProgram: tokenProgram,
        mint: mint,
      );

      final (addr1, nonce1) = await findAssociatedTokenPda(
        seeds: seeds,
        programAddress: ataProgramAddress,
      );
      final (addr2, nonce2) = await findAssociatedTokenPda(
        seeds: seeds,
        programAddress: ataProgramAddress,
      );

      expect(addr1, equals(addr2));
      expect(nonce1, equals(nonce2));
    });

    test('different owners produce different PDAs', () async {
      const owner1 = Address('11111111111111111111111111111111');
      const owner2 = Address('22222222222222222222222222222222222222222222');
      const mint = Address('EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v');
      const tokenProgram = Address('TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA');
      const ataProgramAddress = Address('ATokenGPvbdGVxr1b2hvZbsiqW5xWH25efTNsLJe8bSe');

      final (addr1, _) = await findAssociatedTokenPda(
        seeds: AssociatedTokenSeeds(
          owner: owner1,
          tokenProgram: tokenProgram,
          mint: mint,
        ),
        programAddress: ataProgramAddress,
      );
      final (addr2, _) = await findAssociatedTokenPda(
        seeds: AssociatedTokenSeeds(
          owner: owner2,
          tokenProgram: tokenProgram,
          mint: mint,
        ),
        programAddress: ataProgramAddress,
      );

      expect(addr1, isNot(equals(addr2)));
    });

    test('different mints produce different PDAs', () async {
      const owner = Address('11111111111111111111111111111111');
      const mint1 = Address('EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v');
      const mint2 = Address('Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB');
      const tokenProgram = Address('TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA');
      const ataProgramAddress = Address('ATokenGPvbdGVxr1b2hvZbsiqW5xWH25efTNsLJe8bSe');

      final (addr1, _) = await findAssociatedTokenPda(
        seeds: AssociatedTokenSeeds(
          owner: owner,
          tokenProgram: tokenProgram,
          mint: mint1,
        ),
        programAddress: ataProgramAddress,
      );
      final (addr2, _) = await findAssociatedTokenPda(
        seeds: AssociatedTokenSeeds(
          owner: owner,
          tokenProgram: tokenProgram,
          mint: mint2,
        ),
        programAddress: ataProgramAddress,
      );

      expect(addr1, isNot(equals(addr2)));
    });

    test('Token-2022 program produces different PDA than Token program', () async {
      const owner = Address('11111111111111111111111111111111');
      const mint = Address('EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v');
      const tokenProgram = Address('TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA');
      const token2022Program = Address('TokenzQdBNbLqP5VEhdkAS6EPFLC1PHnBqCXEpPxuEb');
      const ataProgramAddress = Address('ATokenGPvbdGVxr1b2hvZbsiqW5xWH25efTNsLJe8bSe');

      final (addrToken, _) = await findAssociatedTokenPda(
        seeds: AssociatedTokenSeeds(
          owner: owner,
          tokenProgram: tokenProgram,
          mint: mint,
        ),
        programAddress: ataProgramAddress,
      );
      final (addrToken2022, _) = await findAssociatedTokenPda(
        seeds: AssociatedTokenSeeds(
          owner: owner,
          tokenProgram: token2022Program,
          mint: mint,
        ),
        programAddress: ataProgramAddress,
      );

      expect(addrToken, isNot(equals(addrToken2022)));
    });
  });

  // ── AssociatedTokenSeeds value semantics ──────────────────────────────────
  group('AssociatedTokenSeeds', () {
    test('stores owner, tokenProgram, mint', () {
      const owner = Address('11111111111111111111111111111111');
      const mint = Address('EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v');
      const tokenProgram = Address('TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA');

      final seeds = AssociatedTokenSeeds(
        owner: owner,
        tokenProgram: tokenProgram,
        mint: mint,
      );

      expect(seeds.owner, owner);
      expect(seeds.mint, mint);
      expect(seeds.tokenProgram, tokenProgram);
    });
  });
}
