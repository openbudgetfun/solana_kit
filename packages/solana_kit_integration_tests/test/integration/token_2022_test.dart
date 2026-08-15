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
}
