import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_config/solana_kit_config.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:test/test.dart';

void main() {
  const configAccount = Address('11111111111111111111111111111111');
  const signer = solanaConfigProgramAddress;
  const observer = Address('SysvarC1ock11111111111111111111111111111111');
  const keys = [
    ConfigKey(address: signer, isSigner: true),
    ConfigKey(address: observer, isSigner: false),
  ];

  test('builds Store instruction accounts and data', () {
    final instruction = getStoreInstruction(
      configAccount: configAccount,
      keys: keys,
      data: Uint8List.fromList([9, 8, 7]),
      signers: [signer],
      configAccountIsSigner: true,
    );

    expect(instruction.programAddress, solanaConfigProgramAddress);
    expect(instruction.accounts, [
      const AccountMeta(
        address: configAccount,
        role: AccountRole.writableSigner,
      ),
      const AccountMeta(address: signer, role: AccountRole.readonlySigner),
    ]);

    final parsed = parseStoreInstruction(instruction);
    expect(parsed.keys, keys);
    expect(parsed.data, [9, 8, 7]);
  });

  test('helper derives signer accounts from typed config keys', () {
    final instruction = getStoreConfigInstruction(
      configAccount: configAccount,
      keys: keys,
      configData: Uint8List.fromList([42]),
    );

    expect(instruction.accounts, [
      const AccountMeta(address: configAccount, role: AccountRole.writable),
      const AccountMeta(address: signer, role: AccountRole.readonlySigner),
    ]);
    expect(parseStoreInstruction(instruction).data, [42]);
  });

  test('identifies Config program and instructions', () {
    final instruction = getStoreConfigInstruction(
      configAccount: configAccount,
      keys: keys,
      configData: Uint8List(0),
    );

    expect(identifySolanaConfigProgram(solanaConfigProgramAddress), isTrue);
    expect(identifySolanaConfigInstruction(instruction), isTrue);
  });
}
