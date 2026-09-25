/// On-chain integration tests for the Token-2022 program client against
/// SurfPool.
///
/// Mirrors the Token program lifecycle but uses the Token-2022 program and its
/// associated token accounts.
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
import 'package:solana_kit_token_2022/solana_kit_token_2022.dart';
import 'package:test/test.dart';

/// Reads the token amount (raw units) from a jsonParsed token account.
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

  test('createMint and mintTo via Token-2022 verify on-chain', () async {
    final mint = generateKeyPairSigner();
    const mintRent = 1461600;
    final ata = getAssociatedTokenAddressSync(
      owner: env.payer.address,
      tokenProgram: token2022ProgramAddress,
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
          programAddress: token2022ProgramAddress,
        ),
        getInitializeMint2Instruction(
          programAddress: token2022ProgramAddress,
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
          tokenProgram: token2022ProgramAddress,
        ),
        getMintToInstruction(
          programAddress: token2022ProgramAddress,
          mint: mint.address,
          token: ata,
          mintAuthority: env.payer.address,
          amount: BigInt.from(2_000_000),
        ),
      ],
      extraSigners: [mint],
    );

    // The Token-2022 ATA must exist and be owned by the Token-2022 program.
    final account = await env.rpc.getAccountInfoValue(ata).send();
    expect(account.value, isNotNull);
    expect(account.value!['owner'], equals(token2022ProgramAddress.value));
  });

  test('transfer moves tokens between Token-2022 accounts on-chain', () async {
    final mint = generateKeyPairSigner();
    final recipient = generateKeyPairSigner();
    const mintRent = 1461600;
    final payerAta = getAssociatedTokenAddressSync(
      owner: env.payer.address,
      tokenProgram: token2022ProgramAddress,
      mint: mint.address,
    );
    final recipientAta = getAssociatedTokenAddressSync(
      owner: recipient.address,
      tokenProgram: token2022ProgramAddress,
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
          programAddress: token2022ProgramAddress,
        ),
        getInitializeMint2Instruction(
          programAddress: token2022ProgramAddress,
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
          tokenProgram: token2022ProgramAddress,
        ),
        getCreateAssociatedTokenIdempotentInstruction(
          programAddress: associatedTokenProgramAddress,
          payer: env.payer.address,
          ata: recipientAta,
          owner: recipient.address,
          mint: mint.address,
          systemProgram: systemProgramAddress,
          tokenProgram: token2022ProgramAddress,
        ),
        getMintToInstruction(
          programAddress: token2022ProgramAddress,
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
        programAddress: token2022ProgramAddress,
        source: payerAta,
        destination: recipientAta,
        authority: env.payer.address,
        amount: BigInt.from(transferAmount),
      ),
    ]);

    expect(
      await _tokenAmount(env, recipientAta),
      equals(BigInt.from(transferAmount)),
    );
    expect(
      await _tokenAmount(env, payerAta),
      equals(BigInt.from(1_000_000 - transferAmount)),
    );
  });

  test('burn reduces the Token-2022 supply on-chain', () async {
    final mint = generateKeyPairSigner();
    const mintRent = 1461600;
    final ata = getAssociatedTokenAddressSync(
      owner: env.payer.address,
      tokenProgram: token2022ProgramAddress,
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
          programAddress: token2022ProgramAddress,
        ),
        getInitializeMint2Instruction(
          programAddress: token2022ProgramAddress,
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
          tokenProgram: token2022ProgramAddress,
        ),
        getMintToInstruction(
          programAddress: token2022ProgramAddress,
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
        programAddress: token2022ProgramAddress,
        account: ata,
        mint: mint.address,
        authority: env.payer.address,
        amount: BigInt.from(burnAmount),
      ),
    ]);

    // The account balance and the mint supply both dropped by the burn amount.
    expect(
      await _tokenAmount(env, ata),
      equals(BigInt.from(900_000)),
    );
    expect(
      await _mintSupply(env, mint.address),
      equals(BigInt.from(900_000)),
    );
  });

  test('setAuthority changes the Token-2022 mint authority on-chain', () async {
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
          programAddress: token2022ProgramAddress,
        ),
        getInitializeMint2Instruction(
          programAddress: token2022ProgramAddress,
          mint: mint.address,
          decimals: 9,
          mintAuthority: env.payer.address,
        ),
      ],
      extraSigners: [mint],
    );

    await env.sendInstructions([
      getSetAuthorityInstruction(
        programAddress: token2022ProgramAddress,
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

  test(
    'closeAccount closes the Token-2022 account and returns lamports',
    () async {
      final mint = generateKeyPairSigner();
      const mintRent = 1461600;
      final ata = getAssociatedTokenAddressSync(
        owner: env.payer.address,
        tokenProgram: token2022ProgramAddress,
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
            programAddress: token2022ProgramAddress,
          ),
          getInitializeMint2Instruction(
            programAddress: token2022ProgramAddress,
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
            tokenProgram: token2022ProgramAddress,
          ),
        ],
        extraSigners: [mint],
      );

      // The ATA holds rent-exempt lamports that closeAccount returns to the
      // owner (the destination account). The account must hold zero tokens to
      // be closable, so no tokens are minted.
      final before = await env.rpc.getAccountInfoValue(ata).send();
      final ataLamports = before.value!['lamports']! as BigInt;
      final ownerBefore = await env.rpc
          .getBalanceValue(env.payer.address)
          .send();

      await env.sendInstructions([
        getCloseAccountInstruction(
          programAddress: token2022ProgramAddress,
          account: ata,
          destination: env.payer.address,
          owner: env.payer.address,
        ),
      ]);

      // The account is gone and the owner received the ATA's lamports.
      final after = await env.rpc.getAccountInfoValue(ata).send();
      expect(after.value, isNull);
      final ownerAfter = await env.rpc
          .getBalanceValue(env.payer.address)
          .send();
      // The owner receives the ATA's lamports minus the transaction fee.
      expect(
        ownerAfter.value.value - ownerBefore.value.value,
        greaterThanOrEqualTo(ataLamports - BigInt.from(10_000)),
      );
    },
  );
}
