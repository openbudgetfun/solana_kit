import 'dart:typed_data';

import 'package:solana_kit_accounts/src/account.dart';
import 'package:solana_kit_accounts/src/maybe_account.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';

/// Transforms an [EncodedAccount] into an [Account] by decoding the account
/// data using the provided [Decoder] instance.
///
/// ```dart
/// final myDecodedAccount = decodeAccount(myEncodedAccount, myDecoder);
/// ```
Account<TData> decodeAccount<TData>(
  EncodedAccount encodedAccount,
  Decoder<TData> decoder,
) {
  try {
    final decodedData = decoder.decode(encodedAccount.data);
    return Account<TData>(
      address: encodedAccount.address,
      data: decodedData,
      executable: encodedAccount.executable,
      lamports: encodedAccount.lamports,
      programAddress: encodedAccount.programAddress,
      space: encodedAccount.space,
    );
  } on Object {
    throw SolanaError(SolanaErrorCode.accountsFailedToDecodeAccount, {
      'address': encodedAccount.address.value,
    });
  }
}

/// Transforms a [MaybeEncodedAccount] into a [MaybeAccount] by decoding the
/// account data using the provided [Decoder] instance.
///
/// If the account does not exist, it is returned as a [NonExistingAccount]
/// with the new type parameter.
MaybeAccount<TData> decodeMaybeAccount<TData>(
  MaybeEncodedAccount maybeEncodedAccount,
  Decoder<TData> decoder,
) {
  return switch (maybeEncodedAccount) {
    NonExistingAccount() => NonExistingAccount<TData>(
      maybeEncodedAccount.address,
    ),
    ExistingAccount<Uint8List>(account: final encodedAccount) =>
      ExistingAccount<TData>(decodeAccount(encodedAccount, decoder)),
  };
}

/// Asserts that an account stores decoded data, i.e. not a [Uint8List].
///
/// Note that it does not check the shape of the data matches the decoded
/// type, only that it is not a [Uint8List].
///
/// Throws a [SolanaError] with code
/// [SolanaErrorCode.accountsExpectedDecodedAccount] if the account data is
/// still encoded.
void assertAccountDecoded<TData>(Account<TData> account) {
  if (account.data is Uint8List) {
    throw SolanaError(SolanaErrorCode.accountsExpectedDecodedAccount, {
      'address': account.address.value,
    });
  }
}

/// Asserts that a [MaybeAccount] stores decoded data if it exists.
///
/// If the account does not exist, this is a no-op. If it exists and
/// the data is still a [Uint8List], throws a [SolanaError].
void assertMaybeAccountDecoded<TData>(MaybeAccount<TData> account) {
  if (account case ExistingAccount<TData>(account: final inner)) {
    assertAccountDecoded(inner);
  }
}

/// Asserts that all input accounts store decoded data, i.e. not a
/// [Uint8List].
///
/// Throws a [SolanaError] with code
/// [SolanaErrorCode.accountsExpectedAllAccountsToBeDecoded] if any
/// account data is still encoded.
void assertAccountsDecoded<TData>(List<Account<TData>> accounts) {
  final encoded = <Account<TData>>[];
  for (final account in accounts) {
    if (account.data is Uint8List) {
      encoded.add(account);
    }
  }
  if (encoded.isNotEmpty) {
    final encodedAddresses = encoded.map((a) => a.address.value).toList();
    throw SolanaError(SolanaErrorCode.accountsExpectedAllAccountsToBeDecoded, {
      'addresses': encodedAddresses,
    });
  }
}

/// Asserts that all input [MaybeAccount]s store decoded data if they exist.
///
/// Non-existing accounts are skipped. Throws a [SolanaError] with code
/// [SolanaErrorCode.accountsExpectedAllAccountsToBeDecoded] if any
/// existing account data is still encoded.
void assertMaybeAccountsDecoded<TData>(List<MaybeAccount<TData>> accounts) {
  final encoded = <MaybeAccount<TData>>[];
  for (final account in accounts) {
    if (account case ExistingAccount<TData>(account: final inner)) {
      if (inner.data is Uint8List) {
        encoded.add(account);
      }
    }
  }
  if (encoded.isNotEmpty) {
    final encodedAddresses = encoded.map((a) => a.address.value).toList();
    throw SolanaError(SolanaErrorCode.accountsExpectedAllAccountsToBeDecoded, {
      'addresses': encodedAddresses,
    });
  }
}
