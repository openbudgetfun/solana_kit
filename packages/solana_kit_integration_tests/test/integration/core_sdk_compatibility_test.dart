/// Live compatibility contracts for the hardened Solana Kit core packages.
///
/// Every test states an observable outcome and sends real transactions to an
/// isolated Surfpool process. Together they cover the normal data path through
/// addresses, accounts, codecs, instruction plans, instructions, keys,
/// signers, RPC, transaction messages, transaction serialization,
/// confirmation, and transaction introspection.
@TestOn('vm')
@Tags(['integration'])
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:solana_kit_accounts/solana_kit_accounts.dart';
import 'package:solana_kit_address_lookup_table/solana_kit_address_lookup_table.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_compute_budget/solana_kit_compute_budget.dart';
import 'package:solana_kit_instruction_plans/solana_kit_instruction_plans.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_integration_tests/solana_kit_integration_tests.dart';
import 'package:solana_kit_keys/solana_kit_keys.dart';
import 'package:solana_kit_memo/solana_kit_memo.dart';
import 'package:solana_kit_rpc/solana_kit_rpc.dart';
import 'package:solana_kit_rpc_api/solana_kit_rpc_api.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart'
    hide TransactionVersion;
import 'package:solana_kit_signers/solana_kit_signers.dart';
import 'package:solana_kit_system/solana_kit_system.dart';
import 'package:solana_kit_token/solana_kit_token.dart';
import 'package:solana_kit_transaction_confirmation/solana_kit_transaction_confirmation.dart';
import 'package:solana_kit_transaction_introspection/solana_kit_transaction_introspection.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';
import 'package:solana_kit_transactions/solana_kit_transactions.dart';
import 'package:test/test.dart';

void main() {
  late IntegrationTestEnv env;

  setUpAll(() async {
    env = await IntegrationTestEnv.create();
  });

  tearDownAll(() => env.dispose());

  test(
    'a defensively copied signed wire transaction still lands on-chain',
    () async {
      // A wallet can safely retain a transaction while the caller mutates the
      // byte arrays originally supplied to its constructor. The immutable
      // copy must keep a valid Ed25519 signature and preserve the approved
      // memo through encode -> decode -> RPC submission.
      const expectedMemo = 'approved payload survives caller mutation';
      final memoBytes = Uint8List.fromList(utf8.encode(expectedMemo));
      final message = await _message(
        env,
        [
          Instruction(
            programAddress: memoProgramAddress,
            accounts: const [],
            data: memoBytes,
          ),
        ],
      );
      final signed = await signTransactionMessageWithSigners(message);
      final compiled = compileTransaction(message);
      final suppliedMessageBytes = Uint8List.fromList(signed.messageBytes);
      final suppliedSignatureBytes = Uint8List.fromList(
        signed.signatures[env.payer.address]!.value,
      );
      final protected = TransactionWithLifetime(
        messageBytes: suppliedMessageBytes,
        signatures: {
          env.payer.address: SignatureBytes(suppliedSignatureBytes),
        },
        lifetimeConstraint: compiled.lifetimeConstraint,
      );

      memoBytes.fillRange(0, memoBytes.length, 120);
      suppliedMessageBytes.fillRange(0, suppliedMessageBytes.length, 0);
      suppliedSignatureBytes.fillRange(0, suppliedSignatureBytes.length, 0);

      expect(
        verifySignature(
          env.payer.keyPair.publicKey,
          protected.signatures[env.payer.address]!,
          protected.messageBytes,
        ),
        isTrue,
      );
      final wireBytes = getTransactionEncoder().encode(protected);
      final decoded = getTransactionDecoder().decode(wireBytes);
      expect(getTransactionEncoder().encode(decoded), wireBytes);

      final signature = await sendAndConfirmTransaction(
        rpc: env.rpc,
        transaction: TransactionWithLifetime(
          messageBytes: decoded.messageBytes,
          signatures: decoded.signatures,
          lifetimeConstraint: compiled.lifetimeConstraint,
        ),
      );
      expect(
        await env.transactionLogMessages(signature),
        anyElement(contains(expectedMemo)),
      );
    },
  );

  test(
    'confirmed RPC wire data introspects back into the submitted System instruction',
    () async {
      // This follows the path used by explorers and policy engines: submit a
      // generated instruction, fetch base64 wire bytes from RPC, resolve the
      // compiled account indexes, and parse with the generated client.
      final recipient = generateKeyPairSigner();
      final amount = BigInt.from(1_234_567);
      final signature = await env.sendInstructions([
        getTransferSolInstruction(
          programAddress: systemProgramAddress,
          source: env.payer.address,
          destination: recipient.address,
          amount: amount,
        ),
      ]);

      final rpcTransaction = await env.rpc
          .getTransaction(
            signature,
            const GetTransactionConfig(
              commitment: Commitment.confirmed,
              encoding: TransactionEncoding.base64,
              maxSupportedTransactionVersion: 0,
            ),
          )
          .send();
      final decoded = decodeTransactionFromRpcResponse(rpcTransaction);
      final instructions = getInstructionsFromCompiledTransactionMessage(
        decoded.compiledMessage,
        loadedAddresses: decoded.loadedAddresses,
      );

      expect(instructions, hasLength(1));
      expect(instructions.single.programAddress, systemProgramAddress);
      expect(instructions.single.accounts, [
        AccountMeta(
          address: env.payer.address,
          role: AccountRole.writableSigner,
        ),
        AccountMeta(
          address: recipient.address,
          role: AccountRole.writable,
        ),
      ]);
      expect(parseTransferSolInstruction(instructions.single).amount, amount);
      expect(decoded.transaction, isNotNull);
      expect(
        getSignatureFromTransaction(decoded.transaction!),
        signature,
      );
      final balance = await env.rpc.getBalanceValue(recipient.address).send();
      expect(balance.value.value, amount);
    },
  );

  test(
    'a lookup-table account keeps its identity and writable role on-chain',
    () async {
      // The recipient is intentionally absent from the static account list.
      // Surfpool must resolve it from the on-chain ALT, while decompilation and
      // introspection must recover the same address and writable role.
      final recipient = generateKeyPairSigner();
      final recentSlot = await env.rpc.getSlot().send();
      final (lookupTable, bump) = await findAddressLookupTablePda(
        seeds: AddressLookupTableSeeds(
          authority: env.payer.address,
          recentSlot: recentSlot,
        ),
        programAddress: addressLookupTableProgramAddress,
      );
      await env.sendInstructions([
        getCreateLookupTableInstruction(
          programAddress: addressLookupTableProgramAddress,
          address: lookupTable,
          authority: env.payer.address,
          payer: env.payer.address,
          systemProgram: systemProgramAddress,
          recentSlot: recentSlot,
          bump: bump,
        ),
      ]);
      await env.sendInstructions([
        getExtendLookupTableInstruction(
          programAddress: addressLookupTableProgramAddress,
          address: lookupTable,
          authority: env.payer.address,
          payer: env.payer.address,
          systemProgram: systemProgramAddress,
          addresses: [recipient.address],
        ),
      ]);
      final extensionSlot = await env.rpc.getSlot().send();
      await _waitForLaterSlot(env, extensionSlot);

      final generated = getTransferSolInstruction(
        programAddress: systemProgramAddress,
        source: env.payer.address,
        destination: recipient.address,
        amount: BigInt.from(1_345_678),
      );
      final lookedUpInstruction = Instruction(
        programAddress: generated.programAddress,
        accounts: [
          generated.accounts!.first,
          AccountLookupMeta(
            address: recipient.address,
            addressIndex: 0,
            lookupTableAddress: lookupTable,
            role: AccountRole.writable,
          ),
        ],
        data: generated.data,
      );
      final message = await _message(env, [lookedUpInstruction]);
      final compiledMessage = compileTransactionMessage(message);

      expect(
        compiledMessage.staticAccounts,
        isNot(contains(recipient.address)),
      );
      expect(compiledMessage.addressTableLookups, hasLength(1));
      expect(compiledMessage.addressTableLookups!.single.writableIndexes, [0]);

      final decompiled = decompileTransactionMessage(
        compiledMessage,
        DecompileTransactionMessageConfig(
          addressesByLookupTableAddress: {
            lookupTable: [recipient.address],
          },
          lastValidBlockHeight:
              (message.lifetimeConstraint! as BlockhashLifetimeConstraint)
                  .lastValidBlockHeight,
        ),
      );
      final recoveredMeta = decompiled.instructions.single.accounts!.last;
      expect(recoveredMeta, isA<AccountLookupMeta>());
      expect(recoveredMeta.address, recipient.address);
      expect(recoveredMeta.role, AccountRole.writable);

      final resolved = getInstructionsFromCompiledTransactionMessage(
        compiledMessage,
        loadedAddresses: LoadedAddresses(writable: [recipient.address]),
      );
      expect(resolved.single.accounts!.last.address, recipient.address);
      expect(resolved.single.accounts!.last.role, AccountRole.writable);

      await _signAndSendMessage(env, message);
      final balance = await env.rpc.getBalanceValue(recipient.address).send();
      expect(balance.value.value, BigInt.from(1_345_678));
    },
  );

  test(
    'account batches retain request identity while caller input changes',
    () async {
      // A caller may reuse its mutable address list as soon as the asynchronous
      // request starts. Results must still be paired with the original two
      // accounts and their distinct on-chain balances.
      final first = generateKeyPairSigner().address;
      final second = generateKeyPairSigner().address;
      await env.surfnet.fundSol(first, 11_111);
      await env.surfnet.fundSol(second, 22_222);
      final requested = [first, second];
      final pending = createSolanaAccountClient(
        env.rpc,
      ).fetchEncodedAccounts(requested);

      requested
        ..clear()
        ..add(env.payer.address);
      final accounts = await pending;

      expect(accounts.map((account) => account.address), [first, second]);
      expect(accounts, everyElement(isA<ExistingAccount<Uint8List>>()));
      expect(
        (accounts[0] as ExistingAccount<Uint8List>).lamports.value,
        BigInt.from(11_111),
      );
      expect(
        (accounts[1] as ExistingAccount<Uint8List>).lamports.value,
        BigInt.from(22_222),
      );
    },
  );

  test(
    'the create-mint plan keeps allocation and initialization atomic',
    () async {
      // The security contract requires both instructions in one transaction:
      // exposing the funded signerless account between transactions would let
      // another party initialize the mint first.
      final mint = generateKeyPairSigner();
      final instructionPlan = transformInstructionPlan(
        getCreateMintInstructionPlan(
          CreateMintInput(
            payer: env.payer.address,
            newMint: mint.address,
            decimals: 6,
            mintAuthority: env.payer.address,
          ),
        ),
        (plan) => switch (plan) {
          SingleInstructionPlan(:final instruction) => SingleInstructionPlan(
            instruction: addSignersToInstruction(
              [env.payer, mint],
              instruction,
            ),
          ),
          _ => plan,
        },
      );
      final planner = createTransactionPlanner(
        TransactionPlannerConfig(
          createTransactionMessage: () => _message(env),
        ),
      );
      final transactionPlan = await planner(instructionPlan);
      final transactions = flattenTransactionPlan(transactionPlan);

      expect(transactions, hasLength(1));
      expect(transactions.single.message.instructions, hasLength(2));
      expect(
        transactions.single.message.instructions.map(
          (instruction) => instruction.programAddress,
        ),
        [systemProgramAddress, tokenProgramAddress],
      );

      await _signAndSendMessage(env, transactions.single.message);
      final response = await env.rpc
          .getAccountInfoValue(
            mint.address,
            const GetAccountInfoConfig(encoding: AccountEncoding.jsonParsed),
          )
          .send();
      expect(response.value, isNotNull);
      expect(response.value!['owner'], tokenProgramAddress.value);
      final data = response.value!['data']! as Map<String, Object?>;
      final parsed = data['parsed']! as Map<String, Object?>;
      final info = parsed['info']! as Map<String, Object?>;
      expect(info['isInitialized'], isTrue);
      expect(info['decimals'], 6);
      expect(info['mintAuthority'], env.payer.address.value);
    },
  );

  test(
    'message packing submits every oversized memo in order',
    () async {
      // Two large instructions cannot share a v0 packet. The packer must move
      // the second instruction to another transaction without consuming or
      // omitting it. Both observable memo logs prove the complete plan landed.
      final firstMemo = 'first-packed-memo:${List.filled(560, 'a').join()}';
      final secondMemo = 'second-packed-memo:${List.filled(560, 'b').join()}';
      final planner = createTransactionPlanner(
        TransactionPlannerConfig(
          createTransactionMessage: () => _message(env),
        ),
      );
      final transactionPlan = await planner(
        getMessagePackerInstructionPlanFromInstructions([
          getAddMemoInstruction(
            programAddress: memoProgramAddress,
            memo: firstMemo,
          ),
          getAddMemoInstruction(
            programAddress: memoProgramAddress,
            memo: secondMemo,
          ),
        ]),
      );
      final transactions = flattenTransactionPlan(transactionPlan);
      expect(transactions, hasLength(2));
      expect(
        transactions.expand((plan) => plan.message.instructions),
        hasLength(2),
      );

      final observedMemos = <String>[];
      for (final transaction in transactions) {
        final signature = await _signAndSendMessage(env, transaction.message);
        final logs = await env.transactionLogMessages(signature);
        if (logs.any((log) => log.contains('first-packed-memo:'))) {
          observedMemos.add('first');
        }
        if (logs.any((log) => log.contains('second-packed-memo:'))) {
          observedMemos.add('second');
        }
      }
      expect(observedMemos, ['first', 'second']);
    },
  );

  test(
    'a valid priority fee survives helper, wire, RPC, and decompile layers',
    () async {
      // The unsigned-fee hardening must preserve normal u64 values. A wallet
      // that inspects a submitted transaction should recover the same value
      // that the Compute Budget program accepted.
      final price = BigInt.from(75_000);
      const memo = 'priority fee compatibility';
      final message = await _message(env, [
        getSetComputeUnitPriceInstruction(
          programAddress: computeBudgetProgramAddress,
          microLamports: price,
        ),
        getAddMemoInstruction(programAddress: memoProgramAddress, memo: memo),
      ]);
      expect(
        findSetComputeUnitPriceInstructionIndexAndMicroLamports(
          message,
        )!.microLamports,
        price,
      );

      final signature = await _signAndSendMessage(env, message);
      final rpcTransaction = await env.rpc
          .getTransaction(
            signature,
            const GetTransactionConfig(
              commitment: Commitment.confirmed,
              encoding: TransactionEncoding.base64,
              maxSupportedTransactionVersion: 0,
            ),
          )
          .send();
      final decoded = decodeTransactionFromRpcResponse(rpcTransaction);
      final inspected = decompileTransactionMessage(
        decoded.compiledMessage,
        DecompileTransactionMessageConfig(
          lastValidBlockHeight:
              (message.lifetimeConstraint! as BlockhashLifetimeConstraint)
                  .lastValidBlockHeight,
        ),
      );
      expect(
        findSetComputeUnitPriceInstructionIndexAndMicroLamports(
          inspected,
        )!.microLamports,
        price,
      );
      expect(
        await env.transactionLogMessages(signature),
        anyElement(contains(memo)),
      );
    },
  );
}

Future<TransactionMessageWithFeePayerSigner> _message(
  IntegrationTestEnv env, [
  List<Instruction> instructions = const [],
]) async => TransactionMessageWithFeePayerSigner(
  feePayerSigner: env.payer,
  version: TransactionVersion.v0,
  instructions: instructions,
  lifetimeConstraint: await env.recentBlockhashLifetime(),
);

Future<Signature> _signAndSendMessage(
  IntegrationTestEnv env,
  TransactionMessage message,
) async {
  final compiled = compileTransaction(message);
  final signed = await signTransactionMessageWithSigners(message);
  return sendAndConfirmTransaction(
    rpc: env.rpc,
    transaction: TransactionWithLifetime(
      messageBytes: signed.messageBytes,
      signatures: signed.signatures,
      lifetimeConstraint: compiled.lifetimeConstraint,
    ),
  );
}

Future<void> _waitForLaterSlot(
  IntegrationTestEnv env,
  Slot currentSlot,
) async {
  final deadline = DateTime.now().add(const Duration(seconds: 5));
  while (DateTime.now().isBefore(deadline)) {
    if (await env.rpc.getSlot().send() > currentSlot) return;
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  throw StateError('Surfpool did not advance beyond slot $currentSlot');
}
