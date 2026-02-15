import 'dart:math' as math;

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_functional/solana_kit_functional.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

import 'package:solana_kit_transaction_messages/src/addresses_by_lookup_table_address.dart';
import 'package:solana_kit_transaction_messages/src/blockhash.dart';
import 'package:solana_kit_transaction_messages/src/compiled_transaction_message.dart';
import 'package:solana_kit_transaction_messages/src/create_transaction_message.dart';
import 'package:solana_kit_transaction_messages/src/durable_nonce.dart';
import 'package:solana_kit_transaction_messages/src/durable_nonce_instruction.dart';
import 'package:solana_kit_transaction_messages/src/fee_payer.dart';
import 'package:solana_kit_transaction_messages/src/instructions.dart'
    as tx_instructions;
import 'package:solana_kit_transaction_messages/src/lifetime.dart';
import 'package:solana_kit_transaction_messages/src/transaction_message.dart';

/// Configuration for decompiling a transaction message.
class DecompileTransactionMessageConfig {
  /// Creates a [DecompileTransactionMessageConfig].
  const DecompileTransactionMessageConfig({
    this.addressesByLookupTableAddress,
    this.lastValidBlockHeight,
  });

  /// A map of lookup table addresses to their contained addresses.
  final AddressesByLookupTableAddress? addressesByLookupTableAddress;

  /// The last valid block height for blockhash lifetime constraints.
  final BigInt? lastValidBlockHeight;
}

/// A decompiled account that can represent either a static account or a lookup
/// table account.
sealed class _DecompiledAccount {
  const _DecompiledAccount();

  Address get address;
  AccountRole get role;
}

class _StaticAccount extends _DecompiledAccount {
  const _StaticAccount({required this.address, required this.role});

  @override
  final Address address;

  @override
  final AccountRole role;
}

class _LookupAccount extends _DecompiledAccount {
  const _LookupAccount({
    required this.address,
    required this.role,
    required this.lookupTableAddress,
    required this.addressIndex,
  });

  @override
  final Address address;

  @override
  final AccountRole role;

  final Address lookupTableAddress;
  final int addressIndex;
}

List<_DecompiledAccount> _getAccountMetas(CompiledTransactionMessage message) {
  final header = message.header;
  final numWritableSignerAccounts =
      header.numSignerAccounts - header.numReadonlySignerAccounts;
  final numWritableNonSignerAccounts =
      message.staticAccounts.length -
      header.numSignerAccounts -
      header.numReadonlyNonSignerAccounts;

  final accountMetas = <_DecompiledAccount>[];
  var accountIndex = 0;

  for (var i = 0; i < numWritableSignerAccounts; i++) {
    accountMetas.add(
      _StaticAccount(
        address: message.staticAccounts[accountIndex],
        role: AccountRole.writableSigner,
      ),
    );
    accountIndex++;
  }

  for (var i = 0; i < header.numReadonlySignerAccounts; i++) {
    accountMetas.add(
      _StaticAccount(
        address: message.staticAccounts[accountIndex],
        role: AccountRole.readonlySigner,
      ),
    );
    accountIndex++;
  }

  for (var i = 0; i < numWritableNonSignerAccounts; i++) {
    accountMetas.add(
      _StaticAccount(
        address: message.staticAccounts[accountIndex],
        role: AccountRole.writable,
      ),
    );
    accountIndex++;
  }

  for (var i = 0; i < header.numReadonlyNonSignerAccounts; i++) {
    accountMetas.add(
      _StaticAccount(
        address: message.staticAccounts[accountIndex],
        role: AccountRole.readonly,
      ),
    );
    accountIndex++;
  }

  return accountMetas;
}

List<_DecompiledAccount> _getAddressLookupMetas(
  List<AddressTableLookup> compiledAddressTableLookups,
  AddressesByLookupTableAddress addressesByLookupTableAddress,
) {
  final compiledAddresses = compiledAddressTableLookups
      .map((l) => l.lookupTableAddress)
      .toList();
  final missing = compiledAddresses
      .where((a) => !addressesByLookupTableAddress.containsKey(a))
      .toList();

  if (missing.isNotEmpty) {
    throw SolanaError(
      SolanaErrorCode
          .transactionFailedToDecompileAddressLookupTableContentsMissing,
      {'lookupTableAddresses': missing.map((a) => a.value).toList()},
    );
  }

  final readOnlyMetas = <_DecompiledAccount>[];
  final writableMetas = <_DecompiledAccount>[];

  for (final lookup in compiledAddressTableLookups) {
    final addresses = addressesByLookupTableAddress[lookup.lookupTableAddress]!;
    final allIndexes = [...lookup.readonlyIndexes, ...lookup.writableIndexes];
    if (allIndexes.isNotEmpty) {
      final highestIndex = allIndexes.reduce(math.max);
      if (highestIndex >= addresses.length) {
        throw SolanaError(
          SolanaErrorCode
              .transactionFailedToDecompileAddressLookupTableIndexOutOfRange,
          {
            'highestKnownIndex': addresses.length - 1,
            'highestRequestedIndex': highestIndex,
            'lookupTableAddress': lookup.lookupTableAddress.value,
          },
        );
      }
    }

    for (final w in lookup.writableIndexes) {
      writableMetas.add(
        _LookupAccount(
          address: addresses[w],
          addressIndex: w,
          lookupTableAddress: lookup.lookupTableAddress,
          role: AccountRole.writable,
        ),
      );
    }

    for (final r in lookup.readonlyIndexes) {
      readOnlyMetas.add(
        _LookupAccount(
          address: addresses[r],
          addressIndex: r,
          lookupTableAddress: lookup.lookupTableAddress,
          role: AccountRole.readonly,
        ),
      );
    }
  }

  return [...writableMetas, ...readOnlyMetas];
}

Instruction _convertInstruction(
  CompiledInstruction instruction,
  List<_DecompiledAccount> transactionMetas,
) {
  if (instruction.programAddressIndex >= transactionMetas.length) {
    throw SolanaError(
      SolanaErrorCode
          .transactionFailedToDecompileInstructionProgramAddressNotFound,
      {'index': instruction.programAddressIndex},
    );
  }

  final programMeta = transactionMetas[instruction.programAddressIndex];
  final programAddress = programMeta.address;

  final accountIndices = instruction.accountIndices;
  List<AccountMeta>? accounts;
  if (accountIndices != null && accountIndices.isNotEmpty) {
    // Build a list of AccountMeta and AccountLookupMeta objects.
    // AccountLookupMeta extends AccountMeta, so both fit in List<AccountMeta>.
    final mixed = accountIndices.map((idx) {
      final meta = transactionMetas[idx];
      return switch (meta) {
        _StaticAccount() => AccountMeta(address: meta.address, role: meta.role),
        _LookupAccount() => AccountLookupMeta(
          address: meta.address,
          addressIndex: meta.addressIndex,
          lookupTableAddress: meta.lookupTableAddress,
          role: meta.role,
        ),
      };
    }).toList();
    accounts = List<AccountMeta>.unmodifiable(mixed);
  }

  final data = instruction.data;

  return Instruction(
    programAddress: programAddress,
    accounts: accounts,
    data: data != null && data.isNotEmpty ? data : null,
  );
}

/// Decompiles a [CompiledTransactionMessage] back into a
/// [TransactionMessage].
///
/// Because compilation is a lossy process, you cannot fully reconstruct a
/// source message from a compiled message without extra information. In order
/// to faithfully reconstruct the original source message you will need to
/// supply supporting details about the lifetime constraint and the concrete
/// addresses of any accounts sourced from account lookup tables.
TransactionMessage decompileTransactionMessage(
  CompiledTransactionMessage compiledTransactionMessage, [
  DecompileTransactionMessageConfig? config,
]) {
  if (compiledTransactionMessage.staticAccounts.isEmpty) {
    throw SolanaError(
      SolanaErrorCode.transactionFailedToDecompileFeePayerMissing,
    );
  }

  final feePayer = compiledTransactionMessage.staticAccounts[0];
  final accountMetas = _getAccountMetas(compiledTransactionMessage);

  final addressTableLookups = compiledTransactionMessage.addressTableLookups;
  final accountLookupMetas =
      (addressTableLookups != null && addressTableLookups.isNotEmpty)
      ? _getAddressLookupMetas(
          addressTableLookups,
          config?.addressesByLookupTableAddress ?? {},
        )
      : <_DecompiledAccount>[];

  final transactionMetas = [...accountMetas, ...accountLookupMetas];

  final instructions = compiledTransactionMessage.instructions
      .map(
        (compiledInstruction) =>
            _convertInstruction(compiledInstruction, transactionMetas),
      )
      .toList();

  final firstInstruction = instructions.isNotEmpty ? instructions[0] : null;
  final lifetimeToken = compiledTransactionMessage.lifetimeToken;

  final version =
      compiledTransactionMessage.version == TransactionVersion.legacy
      ? TransactionVersion.legacy
      : TransactionVersion.v0;

  return createTransactionMessage(version: version)
      .pipe((m) => setTransactionMessageFeePayer(feePayer, m))
      .pipe(
        (m) => instructions.fold<TransactionMessage>(
          m,
          (acc, instruction) => tx_instructions
              .appendTransactionMessageInstruction(instruction, acc),
        ),
      )
      .pipe((m) {
        if (lifetimeToken == null) return m;

        if (firstInstruction != null &&
            isAdvanceNonceAccountInstruction(firstInstruction)) {
          final nonceAccountAddress = firstInstruction.accounts![0].address;
          final nonceAuthorityAddress = firstInstruction.accounts![2].address;
          return setTransactionMessageLifetimeUsingDurableNonce(
            DurableNonceConfig(
              nonce: lifetimeToken,
              nonceAccountAddress: nonceAccountAddress,
              nonceAuthorityAddress: nonceAuthorityAddress,
            ),
            m,
          );
        } else {
          return setTransactionMessageLifetimeUsingBlockhash(
            BlockhashLifetimeConstraint(
              blockhash: lifetimeToken,
              lastValidBlockHeight:
                  config?.lastValidBlockHeight ??
                  (BigInt.two.pow(64) - BigInt.one),
            ),
            m,
          );
        }
      });
}
