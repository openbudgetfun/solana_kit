/// On-chain integration tests for the Token program client against SurfPool.
///
/// Exercises the full mint lifecycle: create the mint account, initialize it,
/// create the payer's associated token account, mint tokens into it, then
/// verify the token account exists and is owned by the Token program.
@TestOn('vm')
@Tags(['integration'])
library;

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_integration_tests/solana_kit_integration_tests.dart';
import 'package:solana_kit_rpc/solana_kit_rpc.dart';
import 'package:solana_kit_rpc_api/solana_kit_rpc_api.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:solana_kit_signers/solana_kit_signers.dart';
import 'package:solana_kit_system/solana_kit_system.dart';
import 'package:solana_kit_token/solana_kit_token.dart';
import 'package:test/test.dart';

/// Reads the token amount (as raw units) from a jsonParsed token account.
Future<BigInt> _tokenAmount(IntegrationTestEnv env, Address account) async {
  final response = await env.rpc
      .getAccountInfoValue(
        account,
        const GetAccountInfoConfig(encoding: AccountEncoding.jsonParsed),
      )
      .send();
  final parsed = response.value!['data']! as Map<String, Object?>;
  final info = parsed['parsed']! as Map<String, Object?>;
  final tokenAmount = info['info']! as Map<String, Object?>;
  return BigInt.parse(
    (tokenAmount['tokenAmount']! as Map<String, Object?>)['amount']! as String,
  );
}

/// Reads the total supply (raw units) from a jsonParsed mint account.
Future<BigInt> _mintSupply(IntegrationTestEnv env, Address mint) async {
  final response = await env.rpc
      .getAccountInfoValue(
        mint,
        const GetAccountInfoConfig(encoding: AccountEncoding.jsonParsed),
      )
      .send();
  final parsed = response.value!['data']! as Map<String, Object?>;
  final info = parsed['parsed']! as Map<String, Object?>;
  return BigInt.parse(
    (info['info']! as Map<String, Object?>)['supply']! as String,
  );
}

void main() {
  late IntegrationTestEnv env;

  setUpAll(() async {
    env = await IntegrationTestEnv.create();
  });

  tearDownAll(() => env.dispose());

  test('createMint, mintTo and verify the token account on-chain', () async {
    final mint = generateKeyPairSigner();
    const mintRent = 1461600; // rent-exempt lamports for an 82-byte Mint.
    final ata = getAssociatedTokenAddressSync(
      owner: env.payer.address,
      tokenProgram: tokenProgramAddress,
      mint: mint.address,
    );

    await env.sendInstructions(
      [
        getCreateAccountInstruction(
          instructionProgramAddress: systemProgramAddress,
          payer: env.payer.address,
          newAccount: mint.address,
          lamports: BigInt.from(mintRent),
          space: BigInt.from(82),
          programAddress: tokenProgramAddress,
        ),
        getInitializeMint2Instruction(
          programAddress: tokenProgramAddress,
          mint: mint.address,
          decimals: 9,
          mintAuthority: env.payer.address,
        ),
        getCreateAssociatedTokenIdempotentInstruction(
          programAddress: associatedTokenProgramAddress,
          payer: env.payer.address,
          ata: ata,
          owner: env.payer.address,
          mint: mint.address,
          systemProgram: systemProgramAddress,
          tokenProgram: tokenProgramAddress,
        ),
        getMintToInstruction(
          programAddress: tokenProgramAddress,
          mint: mint.address,
          token: ata,
          mintAuthority: env.payer.address,
          amount: BigInt.from(1_000_000),
        ),
      ],
      extraSigners: [mint],
    );

    // The associated token account must now exist and be owned by the Token
    // program — proving createATA + mintTo landed on-chain.
    final account = await env.rpc.getAccountInfoValue(ata).send();
    expect(account.value, isNotNull);
    expect(account.value!['owner'], equals(tokenProgramAddress.value));
  });

  test('transfer moves tokens between accounts on-chain', () async {
    final mint = generateKeyPairSigner();
    final recipient = generateKeyPairSigner();
    const mintRent = 1461600; // rent-exempt lamports for an 82-byte Mint.
    final payerAta = getAssociatedTokenAddressSync(
      owner: env.payer.address,
      tokenProgram: tokenProgramAddress,
      mint: mint.address,
    );
    final recipientAta = getAssociatedTokenAddressSync(
      owner: recipient.address,
      tokenProgram: tokenProgramAddress,
      mint: mint.address,
    );

    // Set up the mint and fund the payer's ATA with 1_000_000 tokens.
    await env.sendInstructions(
      [
        getCreateAccountInstruction(
          instructionProgramAddress: systemProgramAddress,
          payer: env.payer.address,
          newAccount: mint.address,
          lamports: BigInt.from(mintRent),
          space: BigInt.from(82),
          programAddress: tokenProgramAddress,
        ),
        getInitializeMint2Instruction(
          programAddress: tokenProgramAddress,
          mint: mint.address,
          decimals: 9,
          mintAuthority: env.payer.address,
        ),
        getCreateAssociatedTokenIdempotentInstruction(
          programAddress: associatedTokenProgramAddress,
          payer: env.payer.address,
          ata: payerAta,
          owner: env.payer.address,
          mint: mint.address,
          systemProgram: systemProgramAddress,
          tokenProgram: tokenProgramAddress,
        ),
        getCreateAssociatedTokenIdempotentInstruction(
          programAddress: associatedTokenProgramAddress,
          payer: env.payer.address,
          ata: recipientAta,
          owner: recipient.address,
          mint: mint.address,
          systemProgram: systemProgramAddress,
          tokenProgram: tokenProgramAddress,
        ),
        getMintToInstruction(
          programAddress: tokenProgramAddress,
          mint: mint.address,
          token: payerAta,
          mintAuthority: env.payer.address,
          amount: BigInt.from(1_000_000),
        ),
      ],
      extraSigners: [mint],
    );

    const transferAmount = 250_000;
    await env.sendInstructions([
      getTransferInstruction(
        programAddress: tokenProgramAddress,
        source: payerAta,
        destination: recipientAta,
        authority: env.payer.address,
        amount: BigInt.from(transferAmount),
      ),
    ]);

    // The recipient's ATA now holds exactly the transferred amount and the
    // payer's ATA lost it — proving the transfer landed on-chain.
    expect(
      await _tokenAmount(env, recipientAta),
      equals(BigInt.from(transferAmount)),
    );
    expect(
      await _tokenAmount(env, payerAta),
      equals(BigInt.from(1_000_000 - transferAmount)),
    );
  });

  test('burn reduces the token supply on-chain', () async {
    final mint = generateKeyPairSigner();
    const mintRent = 1461600;
    final ata = getAssociatedTokenAddressSync(
      owner: env.payer.address,
      tokenProgram: tokenProgramAddress,
      mint: mint.address,
    );

    await env.sendInstructions(
      [
        getCreateAccountInstruction(
          instructionProgramAddress: systemProgramAddress,
          payer: env.payer.address,
          newAccount: mint.address,
          lamports: BigInt.from(mintRent),
          space: BigInt.from(82),
          programAddress: tokenProgramAddress,
        ),
        getInitializeMint2Instruction(
          programAddress: tokenProgramAddress,
          mint: mint.address,
          decimals: 9,
          mintAuthority: env.payer.address,
        ),
        getCreateAssociatedTokenIdempotentInstruction(
          programAddress: associatedTokenProgramAddress,
          payer: env.payer.address,
          ata: ata,
          owner: env.payer.address,
          mint: mint.address,
          systemProgram: systemProgramAddress,
          tokenProgram: tokenProgramAddress,
        ),
        getMintToInstruction(
          programAddress: tokenProgramAddress,
          mint: mint.address,
          token: ata,
          mintAuthority: env.payer.address,
          amount: BigInt.from(1_000_000),
        ),
      ],
      extraSigners: [mint],
    );

    const burnAmount = 100_000;
    await env.sendInstructions([
      getBurnInstruction(
        programAddress: tokenProgramAddress,
        account: ata,
        mint: mint.address,
        authority: env.payer.address,
        amount: BigInt.from(burnAmount),
      ),
    ]);

    // The account balance and the mint supply both dropped by the burn amount.
    expect(await _tokenAmount(env, ata), equals(BigInt.from(900_000)));
    expect(await _mintSupply(env, mint.address), equals(BigInt.from(900_000)));
  });

  test('setAuthority changes the mint authority on-chain', () async {
    final mint = generateKeyPairSigner();
    final newAuthority = generateKeyPairSigner();
    const mintRent = 1461600;

    await env.sendInstructions(
      [
        getCreateAccountInstruction(
          instructionProgramAddress: systemProgramAddress,
          payer: env.payer.address,
          newAccount: mint.address,
          lamports: BigInt.from(mintRent),
          space: BigInt.from(82),
          programAddress: tokenProgramAddress,
        ),
        getInitializeMint2Instruction(
          programAddress: tokenProgramAddress,
          mint: mint.address,
          decimals: 9,
          mintAuthority: env.payer.address,
        ),
      ],
      extraSigners: [mint],
    );

    await env.sendInstructions([
      getSetAuthorityInstruction(
        programAddress: tokenProgramAddress,
        owned: mint.address,
        owner: env.payer.address,
        authorityType: AuthorityType.mintTokens,
        newAuthority: newAuthority.address,
      ),
    ]);

    // The parsed mint account now reports the new mint authority.
    final account = await env.rpc
        .getAccountInfoValue(
          mint.address,
          const GetAccountInfoConfig(encoding: AccountEncoding.jsonParsed),
        )
        .send();
    final parsed = account.value!['data']! as Map<String, Object?>;
    final info = parsed['parsed']! as Map<String, Object?>;
    final mintInfo = info['info']! as Map<String, Object?>;
    expect(mintInfo['mintAuthority'], equals(newAuthority.address.value));
  });
}
