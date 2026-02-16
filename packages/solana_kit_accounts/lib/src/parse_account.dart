import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_accounts/src/account.dart';
import 'package:solana_kit_accounts/src/maybe_account.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

/// Parses a base64-encoded account provided by the RPC client into an
/// [EncodedAccount] type or a [MaybeEncodedAccount] type if the raw data
/// is `null`.
///
/// The [rpcAccount] map is expected to have the structure returned by the
/// Solana RPC `getAccountInfo` method with `base64` encoding:
///
/// ```json
/// {
///   "data": ["base64EncodedString", "base64"],
///   "executable": false,
///   "lamports": 1000000000,
///   "owner": "11111111111111111111111111111111",
///   "space": 42
/// }
/// ```
MaybeEncodedAccount parseBase64RpcAccount(
  Address address,
  Map<String, dynamic>? rpcAccount,
) {
  if (rpcAccount == null) {
    return NonExistingAccount<Uint8List>(address);
  }

  final data = rpcAccount['data'];
  final String base64String;

  if (data is List) {
    base64String = data[0] as String;
  } else {
    base64String = data as String;
  }

  final decodedData = getBase64Encoder().encode(base64String);
  final baseAccount = parseBaseAccount(rpcAccount);

  return ExistingAccount<Uint8List>(
    Account<Uint8List>(
      address: address,
      data: decodedData,
      executable: baseAccount.executable,
      lamports: baseAccount.lamports,
      programAddress: baseAccount.programAddress,
      space: baseAccount.space,
    ),
  );
}

/// Parses a base58-encoded account provided by the RPC client into an
/// [EncodedAccount] type or a [MaybeEncodedAccount] type if the raw data
/// is `null`.
///
/// The [rpcAccount] map is expected to have the structure returned by the
/// Solana RPC `getAccountInfo` method with `base58` encoding:
///
/// ```json
/// {
///   "data": ["base58EncodedString", "base58"],
///   "executable": false,
///   "lamports": 1000000000,
///   "owner": "11111111111111111111111111111111",
///   "space": 42
/// }
/// ```
///
/// The data field may also be a plain base58 string (legacy format).
MaybeEncodedAccount parseBase58RpcAccount(
  Address address,
  Map<String, dynamic>? rpcAccount,
) {
  if (rpcAccount == null) {
    return NonExistingAccount<Uint8List>(address);
  }

  final data = rpcAccount['data'];
  final String base58String;

  if (data is String) {
    base58String = data;
  } else if (data is List) {
    base58String = data[0] as String;
  } else {
    base58String = data.toString();
  }

  final decodedData = getBase58Encoder().encode(base58String);
  final baseAccount = parseBaseAccount(rpcAccount);

  return ExistingAccount<Uint8List>(
    Account<Uint8List>(
      address: address,
      data: decodedData,
      executable: baseAccount.executable,
      lamports: baseAccount.lamports,
      programAddress: baseAccount.programAddress,
      space: baseAccount.space,
    ),
  );
}

/// Parsed account metadata that may be included with `jsonParsed` accounts.
@immutable
class ParsedAccountMeta {
  /// Creates a new [ParsedAccountMeta].
  const ParsedAccountMeta({required this.program, this.type});

  /// The program that owns this account.
  final String program;

  /// The type of the parsed account.
  final String? type;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ParsedAccountMeta &&
          runtimeType == other.runtimeType &&
          program == other.program &&
          type == other.type;

  @override
  int get hashCode => Object.hash(program, type);

  @override
  String toString() => 'ParsedAccountMeta(program: $program, type: $type)';
}

/// The data shape returned from [parseJsonRpcAccount].
///
/// Contains the parsed data along with optional metadata about the program
/// and type.
@immutable
class JsonParsedAccountData<TData> {
  /// Creates a new [JsonParsedAccountData].
  const JsonParsedAccountData({required this.data, this.parsedAccountMeta});

  /// The parsed data.
  final TData data;

  /// Optional metadata about the account's program and type.
  final ParsedAccountMeta? parsedAccountMeta;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JsonParsedAccountData<TData> &&
          runtimeType == other.runtimeType &&
          data == other.data &&
          parsedAccountMeta == other.parsedAccountMeta;

  @override
  int get hashCode => Object.hash(data, parsedAccountMeta);

  @override
  String toString() =>
      'JsonParsedAccountData(data: $data, '
      'parsedAccountMeta: $parsedAccountMeta)';
}

/// Parses an arbitrary `jsonParsed` account provided by the RPC client into
/// an [Account] type or a [MaybeAccount] type if the raw data is `null`.
///
/// The [rpcAccount] map is expected to have the structure returned by the
/// Solana RPC `getAccountInfo` method with `jsonParsed` encoding:
///
/// ```json
/// {
///   "data": {
///     "parsed": {
///       "info": { ... },
///       "type": "token"
///     },
///     "program": "splToken",
///     "space": 165
///   },
///   "executable": false,
///   "lamports": 1000000000,
///   "owner": "11111111111111111111111111111111",
///   "space": 165
/// }
/// ```
MaybeAccount<JsonParsedAccountData<Map<String, dynamic>>> parseJsonRpcAccount(
  Address address,
  Map<String, dynamic>? rpcAccount,
) {
  if (rpcAccount == null) {
    return NonExistingAccount<JsonParsedAccountData<Map<String, dynamic>>>(
      address,
    );
  }

  final dataField = rpcAccount['data'] as Map<String, dynamic>;
  final parsed = dataField['parsed'] as Map<String, dynamic>;
  final info = (parsed['info'] as Map<String, dynamic>?) ?? <String, dynamic>{};
  final program = dataField['program'] as String?;
  final type = parsed['type'] as String?;

  ParsedAccountMeta? meta;
  if (program != null || type != null) {
    meta = ParsedAccountMeta(program: program ?? '', type: type);
  }

  final parsedData = JsonParsedAccountData<Map<String, dynamic>>(
    data: info,
    parsedAccountMeta: meta,
  );

  final baseAccount = parseBaseAccount(rpcAccount);

  return ExistingAccount<JsonParsedAccountData<Map<String, dynamic>>>(
    Account<JsonParsedAccountData<Map<String, dynamic>>>(
      address: address,
      data: parsedData,
      executable: baseAccount.executable,
      lamports: baseAccount.lamports,
      programAddress: baseAccount.programAddress,
      space: baseAccount.space,
    ),
  );
}

/// Parses the base account properties from an RPC account map.
BaseAccount parseBaseAccount(Map<String, dynamic> rpcAccount) {
  final rawLamports = rpcAccount['lamports'];
  final BigInt lamportsValue;
  if (rawLamports is BigInt) {
    lamportsValue = rawLamports;
  } else if (rawLamports is int) {
    lamportsValue = BigInt.from(rawLamports);
  } else {
    lamportsValue = BigInt.parse(rawLamports.toString());
  }

  final rawSpace = rpcAccount['space'];
  final BigInt spaceValue;
  if (rawSpace is BigInt) {
    spaceValue = rawSpace;
  } else if (rawSpace is int) {
    spaceValue = BigInt.from(rawSpace);
  } else {
    spaceValue = BigInt.parse(rawSpace.toString());
  }

  return BaseAccount(
    executable: rpcAccount['executable'] as bool,
    lamports: Lamports(lamportsValue),
    programAddress: Address(rpcAccount['owner'] as String),
    space: spaceValue,
  );
}
