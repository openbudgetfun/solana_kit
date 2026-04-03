import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_system/solana_kit_system.dart';
import 'package:test/test.dart';

void main() {
  test('builds and parses CreateAccount instruction', () {
    const payer = Address('11111111111111111111111111111111');
    const newAccount = Address('11111111111111111111111111111112');
    const owner = Address('TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA');

    final ix = getCreateAccountInstruction(
      payer: payer,
      newAccount: newAccount,
      lamports: BigInt.from(1461600),
      space: BigInt.from(82),
      programOwner: owner,
    );

    expect(ix.programAddress, systemProgramAddress);
    final accounts = ix.accounts!;
    expect(accounts, hasLength(2));
    expect(accounts[0].role, AccountRole.writableSigner);
    expect(accounts[1].role, AccountRole.writableSigner);

    final parsed = parseCreateAccountInstruction(ix);
    expect(parsed.discriminator, 0);
    expect(parsed.lamports, BigInt.from(1461600));
    expect(parsed.space, BigInt.from(82));
    expect(parsed.programOwner, owner);
  });
}
