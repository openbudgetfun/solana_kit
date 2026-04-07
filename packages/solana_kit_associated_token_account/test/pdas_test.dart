import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_associated_token_account/solana_kit_associated_token_account.dart';
import 'package:test/test.dart';

void main() {
  const owner = Address('2ojv9BAiHUrvsm9gxDe7fJSzbNZSJcxZvf8dqmWGHG8S');
  const mint = Address('EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v');
  const tokenProgram = Address('TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA');

  group('findAssociatedTokenPda', () {
    test('uses the canonical ATA program address by default', () async {
      final (address, bump) = await findAssociatedTokenPda(
        seeds: const AssociatedTokenSeeds(
          owner: owner,
          tokenProgram: tokenProgram,
          mint: mint,
        ),
      );

      expect(address.value, '7dSpEsg3JwHpGST1RbTVCtL74nSTsoWU9udTN4WSJoZM');
      expect(bump, inInclusiveRange(0, 255));
    });

    test('sync and async helpers agree', () async {
      const seeds = AssociatedTokenSeeds(
        owner: owner,
        tokenProgram: tokenProgram,
        mint: mint,
      );

      final syncResult = findAssociatedTokenPdaSync(seeds: seeds);
      final asyncResult = await findAssociatedTokenPda(seeds: seeds);

      expect(syncResult, asyncResult);
    });

    test('getAssociatedTokenAddressSync returns just the address', () {
      final address = getAssociatedTokenAddressSync(
        owner: owner,
        tokenProgram: tokenProgram,
        mint: mint,
      );

      expect(address.value, '7dSpEsg3JwHpGST1RbTVCtL74nSTsoWU9udTN4WSJoZM');
    });

    test('different token programs derive different ATAs', () {
      final tokenAta = getAssociatedTokenAddressSync(
        owner: owner,
        tokenProgram: tokenProgram,
        mint: mint,
      );
      final token2022Ata = getAssociatedTokenAddressSync(
        owner: owner,
        tokenProgram: const Address(
          'TokenzQdBNbLqP5VEhdkAS6EPFLC1PHnBqCXEpPxuEb',
        ),
        mint: mint,
      );

      expect(tokenAta, isNot(token2022Ata));
    });
  });

  group('AssociatedTokenSeeds', () {
    test('has value semantics', () {
      const a = AssociatedTokenSeeds(
        owner: owner,
        tokenProgram: tokenProgram,
        mint: mint,
      );
      const b = AssociatedTokenSeeds(
        owner: owner,
        tokenProgram: tokenProgram,
        mint: mint,
      );

      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a.toString(), contains('AssociatedTokenSeeds'));
    });
  });
}
