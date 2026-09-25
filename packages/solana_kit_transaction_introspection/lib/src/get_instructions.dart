import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_transaction_introspection/src/loaded_addresses.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';

/// An outer transaction instruction with its account indices resolved to
/// full [AccountMeta]s and its data exposed as a [Uint8List].
///
/// Following the kit [Instruction] conventions, `accounts` and `data` are
/// `null` when empty, so `isInstructionWithAccounts` and
/// `isInstructionWithData` behave as expected and can be used to narrow
/// before passing the instruction to the auto-generated `parseXInstruction`
/// helpers.
typedef ResolvedInstruction = Instruction;

/// The normalized shape of an instruction inside a compiled transaction
/// message; `legacy`, `0`, and `1` are all reduced to this form before
/// resolution.
class _NormalizedCompiledInstruction {
  const _NormalizedCompiledInstruction({
    required this.accountIndices,
    required this.data,
    required this.programAddressIndex,
  });

  final List<int> accountIndices;
  final Uint8List data;
  final int programAddressIndex;
}

/// Builds the full ordered list of [AccountMeta]s for a compiled transaction
/// message.
///
/// The order matches the runtime's resolution order:
///
/// 1. Static accounts, with role bits derived from the message header
///    (writable signers, readonly signers, writable non-signers, readonly
///    non-signers).
/// 2. ALT-loaded writable accounts (always non-signer, writable).
/// 3. ALT-loaded readonly accounts (always non-signer, readonly).
///
/// Inner-instruction account indices reference the same flat list, so this
/// helper is also useful for resolving inner instructions.
///
/// Throws a [SolanaError] when the supplied loaded address counts do not match
/// the message's address table lookups. Messages with lookups require complete
/// loaded addresses before their accounts can be resolved.
List<AccountMeta> getAccountMetasFromCompiledTransactionMessage(
  CompiledTransactionMessage compiledMessage, {
  LoadedAddresses? loadedAddresses,
}) {
  // The signed lookup counts define where readonly addresses begin. Accepting
  // partial or extra RPC metadata would silently resolve different accounts.
  final lookups = compiledMessage.version == TransactionVersion.v0
      ? compiledMessage.addressTableLookups ?? const <AddressTableLookup>[]
      : const <AddressTableLookup>[];
  final numLoadedWritable = lookups.fold<int>(
    0,
    (count, lookup) => count + lookup.writableIndexes.length,
  );
  final numLoadedReadonly = lookups.fold<int>(
    0,
    (count, lookup) => count + lookup.readonlyIndexes.length,
  );

  if ((loadedAddresses?.writable.length ?? 0) != numLoadedWritable ||
      (loadedAddresses?.readonly.length ?? 0) != numLoadedReadonly) {
    throw SolanaError(
      SolanaErrorCode
          .transactionIntrospectionUnrecognizedGetTransactionResponse,
    );
  }

  final header = compiledMessage.header;
  final staticAccounts = compiledMessage.staticAccounts;
  final numWritableSignerAccounts =
      header.numSignerAccounts - header.numReadonlySignerAccounts;
  final numWritableNonSignerAccounts =
      staticAccounts.length -
      header.numSignerAccounts -
      header.numReadonlyNonSignerAccounts;

  final metas = <AccountMeta>[];
  var i = 0;
  for (var n = 0; n < numWritableSignerAccounts; n++, i++) {
    metas.add(
      AccountMeta(address: staticAccounts[i], role: AccountRole.writableSigner),
    );
  }
  for (var n = 0; n < header.numReadonlySignerAccounts; n++, i++) {
    metas.add(
      AccountMeta(address: staticAccounts[i], role: AccountRole.readonlySigner),
    );
  }
  for (var n = 0; n < numWritableNonSignerAccounts; n++, i++) {
    metas.add(
      AccountMeta(address: staticAccounts[i], role: AccountRole.writable),
    );
  }
  for (var n = 0; n < header.numReadonlyNonSignerAccounts; n++, i++) {
    metas.add(
      AccountMeta(address: staticAccounts[i], role: AccountRole.readonly),
    );
  }

  if (loadedAddresses != null) {
    for (final address in loadedAddresses.writable) {
      metas.add(AccountMeta(address: address, role: AccountRole.writable));
    }
    for (final address in loadedAddresses.readonly) {
      metas.add(AccountMeta(address: address, role: AccountRole.readonly));
    }
  }

  return metas;
}

/// Returns the outer instructions of a compiled transaction message as kit
/// [Instruction] objects.
///
/// Each returned instruction has its account indices resolved to
/// [AccountMeta]s (with the proper signer/writable bits) and its data exposed
/// as a [Uint8List], the form the auto-generated `@solana-program/*`
/// `parseXInstruction` functions expect. `accounts` and `data` are `null` when
/// empty.
///
/// Supports `legacy`, `v0`, and `v1` compiled messages. Throws a [SolanaError]
/// with code [SolanaErrorCode.transactionVersionNumberNotSupported] for any
/// other version,
/// [SolanaErrorCode.transactionFailedToDecompileInstructionProgramAddressNotFound]
/// if a `programAddressIndex` falls outside the resolved account list, and
/// [SolanaErrorCode.transactionFailedToDecompileInstructionAccountIndexOutOfRange]
/// if an account index does.
List<ResolvedInstruction> getInstructionsFromCompiledTransactionMessage(
  CompiledTransactionMessage compiledMessage, {
  LoadedAddresses? loadedAddresses,
}) {
  final metas = getAccountMetasFromCompiledTransactionMessage(
    compiledMessage,
    loadedAddresses: loadedAddresses,
  );
  return getInstructionsFromCompiledTransactionMessageWithMetas(
    compiledMessage,
    metas,
  );
}

/// Internal variant of [getInstructionsFromCompiledTransactionMessage] that
/// takes pre-built [AccountMeta]s. Used by `walkInstructions` to avoid
/// rebuilding the meta list when it is already needed for resolving inner
/// instructions.
@internal
List<ResolvedInstruction>
getInstructionsFromCompiledTransactionMessageWithMetas(
  CompiledTransactionMessage compiledMessage,
  List<AccountMeta> accountMetas,
) {
  return _normalizeCompiledInstructions(
    compiledMessage,
  ).map((ix) => _resolveInstruction(ix, accountMetas)).toList();
}

List<_NormalizedCompiledInstruction> _normalizeCompiledInstructions(
  CompiledTransactionMessage compiledMessage,
) {
  final version = compiledMessage.version;
  if (version == TransactionVersion.legacy ||
      version == TransactionVersion.v0) {
    return compiledMessage.instructions
        .map(
          (ix) => _NormalizedCompiledInstruction(
            accountIndices: ix.accountIndices ?? const [],
            data: ix.data ?? Uint8List(0),
            programAddressIndex: ix.programAddressIndex,
          ),
        )
        .toList();
  }
  if (version == TransactionVersion.v1) {
    final headers = compiledMessage.instructionHeaders ?? const [];
    final payloads = compiledMessage.instructionPayloads ?? const [];
    if (headers.length != payloads.length) {
      throw SolanaError(
        SolanaErrorCode.transactionInstructionHeadersPayloadsMismatch,
        {
          'numInstructionHeaders': headers.length,
          'numInstructionPayloads': payloads.length,
        },
      );
    }
    return List.generate(headers.length, (i) {
      final header = headers[i];
      final payload = payloads[i];
      return _NormalizedCompiledInstruction(
        accountIndices: payload.instructionAccountIndices,
        data: payload.instructionData,
        programAddressIndex: header.programAccountIndex,
      );
    });
  }
  // Unreachable for the current TransactionVersion enum (legacy/v0/v1), kept
  // for forward-compatibility.
  throw SolanaError(
    SolanaErrorCode.transactionVersionNumberNotSupported,
    {'unsupportedVersion': version.versionNumber},
  );
}

ResolvedInstruction _resolveInstruction(
  _NormalizedCompiledInstruction ix,
  List<AccountMeta> metas,
) {
  if (ix.programAddressIndex < 0 || ix.programAddressIndex >= metas.length) {
    throw SolanaError(
      SolanaErrorCode
          .transactionFailedToDecompileInstructionProgramAddressNotFound,
      {'index': ix.programAddressIndex},
    );
  }
  final programMeta = metas[ix.programAddressIndex];
  final accounts = <AccountMeta>[];
  for (final i in ix.accountIndices) {
    if (i < 0 || i >= metas.length) {
      throw SolanaError(
        SolanaErrorCode
            .transactionFailedToDecompileInstructionAccountIndexOutOfRange,
        {'index': i},
      );
    }
    accounts.add(metas[i]);
  }
  return Instruction(
    programAddress: programMeta.address,
    accounts: accounts.isEmpty ? null : accounts,
    data: ix.data.isEmpty ? null : ix.data,
  );
}
