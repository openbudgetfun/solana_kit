import 'dart:convert';
import 'dart:typed_data';

import 'package:solana_kit_address_lookup_table/solana_kit_address_lookup_table.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_config/solana_kit_config.dart';
import 'package:solana_kit_loader/solana_kit_loader.dart';
import 'package:solana_kit_memo/solana_kit_memo.dart';
import 'package:solana_kit_stake/solana_kit_stake.dart';

const payer = Address('11111111111111111111111111111111');
const authority = Address('11111111111111111111111111111112');
const account = Address('11111111111111111111111111111113');
const secondAccount = Address('11111111111111111111111111111114');
const thirdAccount = Address('11111111111111111111111111111115');

void main() {
  buildMemoInstruction();
  buildConfigInstruction();
  buildAddressLookupTableInstructions();
  buildLoaderInstructions();
  buildStakeInstructions();
}

void buildMemoInstruction() {
  final instruction = getAddMemoInstruction(memo: 'hello from solana_kit');

  print('memo program: ${instruction.programAddress}');
  print('memo bytes: ${utf8.decode(instruction.data ?? Uint8List(0))}');
}

void buildConfigInstruction() {
  final instruction = getStoreConfigInstruction(
    configAccount: account,
    keys: const [ConfigKey(address: authority, isSigner: true)],
    configData: Uint8List.fromList(utf8.encode('validator.example')),
  );

  print('config program: ${instruction.programAddress}');
  print('config account metas: ${instruction.accounts?.length ?? 0}');
}

void buildAddressLookupTableInstructions() {
  final create = getCreateLookupTableInstruction(
    address: account,
    authority: authority,
    payer: payer,
    recentSlot: BigInt.from(42),
    bump: 255,
  );
  final extend = getExtendLookupTableInstruction(
    address: account,
    authority: authority,
    payer: payer,
    addresses: const [secondAccount, thirdAccount],
  );

  print('lookup table program: ${create.programAddress}');
  print('lookup table extend bytes: ${extend.data?.length ?? 0}');
}

void buildLoaderInstructions() {
  final write = getLoaderV3WriteInstruction(
    bufferAccount: account,
    bufferAuthority: authority,
    offset: 0,
    bytes: Uint8List.fromList([1, 2, 3, 4]),
  );
  final truncate = getLoaderV4TruncateInstruction(
    program: account,
    authority: authority,
    destination: payer,
    newSize: 64,
  );

  print('loader v3 program: ${write.programAddress}');
  print('loader v4 program: ${truncate.programAddress}');
}

void buildStakeInstructions() {
  final delegate = getDelegateStakeInstructionPlan(
    stake: account,
    vote: secondAccount,
    stakeAuthority: authority,
  );
  final create = getCreateStakeAccountInstructionPlan(
    payer: payer,
    stake: account,
    authorized: const Authorized(staker: authority, withdrawer: authority),
    lamports: BigInt.from(1_000_000_000),
  );

  print('stake delegate plan: ${delegate.kind}');
  print('stake create plan: ${create.kind}');
}
