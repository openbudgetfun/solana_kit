import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_associated_token_account/solana_kit_associated_token_account.dart';
import 'package:test/test.dart';

void main() {
  group('solana_kit_associated_token_account barrel', () {
    test('re-exports program constants and PDA helpers', () async {
      expect(ataProgramAddress, associatedTokenProgramAddress);
      expect(
        associatedTokenProgramAddress.value,
        'ATokenGPvbdGVxr1b2hvZbsiqW5xWH25efTNsLJe8bSe',
      );

      final (address, bump) = await findAssociatedTokenPda(
        seeds: const AssociatedTokenSeeds(
          owner: Address('11111111111111111111111111111111'),
          tokenProgram: Address('TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA'),
          mint: Address('EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v'),
        ),
      );

      expect(address, isA<Address>());
      expect(bump, inInclusiveRange(0, 255));
    });
  });
}
