import 'package:solana_kit_instructions/solana_kit_instructions.dart';

/// Maximum size of a version 1 transaction in bytes (SIMD-0296), versus 1,232
/// for legacy and v0.
const v1TransactionSizeLimit = 4096;

/// Detects an instruction account that resolves through an address lookup
/// table. Lookup accounts carry `lookupTableAddress`; static ones only carry
/// `address`.
///
/// Tests the value rather than the type, so an account that merely spreads an
/// explicit `lookupTableAddress: undefined` is not mistaken for a lookup.
bool _isLookupAccount(Object? account) {
  if (account is AccountLookupMeta) return true;
  if (account is Map<String, Object?> &&
      account['lookupTableAddress'] != null) {
    return true;
  }
  return false;
}

/// Returns the accounts of an instruction, whether it is a real
/// [Instruction] or a structurally-similar map, or `null` when it has none.
List<Object?>? _accountsOf(Object? instruction) {
  if (instruction is Instruction) return instruction.accounts;
  if (instruction is Map<String, Object?>) {
    final accounts = instruction['accounts'];
    if (accounts is List<Object?>) return accounts;
  }
  return null;
}

/// Returns the program address of an instruction for error messages, or
/// `null` when it cannot be read.
String? _programAddressOf(Object? instruction) {
  if (instruction is Instruction) return instruction.programAddress.toString();
  if (instruction is Map<String, Object?>) {
    final programAddress = instruction['programAddress'];
    if (programAddress != null) return programAddress.toString();
  }
  return null;
}

/// Rejects address lookup tables on version 1 transactions.
///
/// SIMD-0385 drops lookup table support from the v1 format. Rather than
/// failing, `@solana/kit` silently compiles a lookup account into a static
/// address — so a transaction built to save space via a lookup table would
/// quietly inline every address instead, and can then breach the 64-address
/// cap or the size limit for reasons that are hard to trace back to the
/// lookup table.
void assertNoAddressLookupsOnV1(int version, List<Object?> instructions) {
  if (version != 1) return;

  for (final ix in instructions) {
    final accounts = _accountsOf(ix);
    if (accounts == null || !accounts.any(_isLookupAccount)) continue;

    throw StateError(
      'Version 1 transactions do not support address lookup tables '
      '(SIMD-0385), but an instruction for program '
      '${_programAddressOf(ix) ?? 'unknown'} sources an account from one. '
      "Use version 0, or pass the account's address directly — v1 holds up "
      'to 64 addresses inline.',
    );
  }
}
