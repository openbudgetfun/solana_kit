import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_signers/solana_kit_signers.dart';

/// How to handle null (optional) account values when converting resolved
/// instruction accounts to account metas.
enum OptionalAccountStrategy {
  /// Optional accounts are excluded from the instruction entirely.
  omitted,

  /// Optional accounts are replaced with the program address as a read-only
  /// account.
  programId,
}

/// Represents a resolved account input for an instruction.
///
/// During instruction building, account inputs are resolved to this type which
/// captures both the account value and whether it should be marked as writable.
/// The value can be an [Address], a [ProgramDerivedAddress], a
/// transaction signer (as an [Object]), or `null` for optional accounts.
class ResolvedInstructionAccount {
  /// Creates a [ResolvedInstructionAccount].
  const ResolvedInstructionAccount({
    required this.isWritable,
    required this.value,
  });

  /// Whether this account should be marked as writable.
  final bool isWritable;

  /// The resolved value of this account.
  ///
  /// Can be an [Address], a [ProgramDerivedAddress], a transaction signer
  /// object, or `null` for optional accounts.
  final Object? value;
}

/// Ensures a resolved instruction input is not null.
///
/// This function is used during instruction resolution to validate that
/// required inputs have been properly resolved to a non-null value.
///
/// Throws a [SolanaError] with code
/// [SolanaErrorCode.programClientsResolvedInstructionInputMustBeNonNull]
/// if the value is null.
T getNonNullResolvedInstructionInput<T>(String inputName, T? value) {
  if (value == null) {
    throw SolanaError(
      SolanaErrorCode.programClientsResolvedInstructionInputMustBeNonNull,
      {'inputName': inputName},
    );
  }
  return value;
}

/// Extracts the address from a resolved instruction account.
///
/// A resolved instruction account can be an [Address], a
/// [ProgramDerivedAddress], or a transaction signer. This function extracts
/// the underlying address from any of these types.
///
/// Throws a [SolanaError] if the value is null.
Address getAddressFromResolvedInstructionAccount(
  String inputName,
  Object? value,
) {
  final nonNullValue = getNonNullResolvedInstructionInput(inputName, value);

  // Check if it's a transaction signer (has an 'address' property).
  if (_isResolvedInstructionAccountSigner(nonNullValue)) {
    return getTransactionSignerAddress(nonNullValue);
  }

  // Check if it's a ProgramDerivedAddress (a record of (Address, int)).
  if (nonNullValue is ProgramDerivedAddress) {
    return nonNullValue.$1;
  }

  // Otherwise, it should be an Address.
  return nonNullValue as Address;
}

/// Extracts a [ProgramDerivedAddress] from a resolved instruction account.
///
/// This function validates that the resolved account is a PDA and returns it.
/// Use this when you need access to both the address and the bump seed of a
/// PDA.
///
/// Throws a [SolanaError] if the value is not a [ProgramDerivedAddress].
ProgramDerivedAddress getResolvedInstructionAccountAsProgramDerivedAddress(
  String inputName,
  Object? value,
) {
  if (value is! ProgramDerivedAddress) {
    throw SolanaError(
      SolanaErrorCode.programClientsUnexpectedResolvedInstructionInputType,
      {'expectedType': 'ProgramDerivedAddress', 'inputName': inputName},
    );
  }
  return value;
}

/// Extracts a transaction signer from a resolved instruction account.
///
/// This function validates that the resolved account is a transaction signer
/// and returns it. Use this when you need the resolved account to be a signer.
///
/// Throws a [SolanaError] if the value is not a transaction signer.
Object getResolvedInstructionAccountAsTransactionSigner(
  String inputName,
  Object? value,
) {
  if (!_isResolvedInstructionAccountSigner(value)) {
    throw SolanaError(
      SolanaErrorCode.programClientsUnexpectedResolvedInstructionInputType,
      {'expectedType': 'TransactionSigner', 'inputName': inputName},
    );
  }
  return value!;
}

/// Creates a factory function that converts resolved instruction accounts to
/// account metas.
///
/// The factory handles the conversion of [ResolvedInstructionAccount] objects
/// into [AccountMeta] or [AccountSignerMeta] objects suitable for building
/// instructions. It also determines how to handle optional accounts based on
/// the provided `strategy`.
///
/// Returns a function that takes an `inputName` and a
/// [ResolvedInstructionAccount] and returns an [AccountMeta],
/// [AccountSignerMeta], or `null` (when the strategy is
/// [OptionalAccountStrategy.omitted] and the account value is null).
AccountMeta? Function(String inputName, ResolvedInstructionAccount account)
getAccountMetaFactory(
  Address programAddress,
  OptionalAccountStrategy strategy,
) {
  return (String inputName, ResolvedInstructionAccount account) {
    if (account.value == null) {
      if (strategy == OptionalAccountStrategy.omitted) return null;
      return AccountMeta(address: programAddress, role: AccountRole.readonly);
    }

    final writableRole = account.isWritable
        ? AccountRole.writable
        : AccountRole.readonly;
    final isSigner = _isResolvedInstructionAccountSigner(account.value);
    final accountAddress = getAddressFromResolvedInstructionAccount(
      inputName,
      account.value,
    );

    if (isSigner) {
      return AccountSignerMeta(
        address: accountAddress,
        role: upgradeRoleToSigner(writableRole),
        signer: account.value!,
      );
    }

    return AccountMeta(address: accountAddress, role: writableRole);
  };
}

/// Checks whether the given value is a transaction signer.
bool _isResolvedInstructionAccountSigner(Object? value) {
  return value != null && isTransactionSigner(value);
}
