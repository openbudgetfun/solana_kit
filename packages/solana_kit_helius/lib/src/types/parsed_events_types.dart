import 'package:solana_kit_helius/src/internal/json_reader.dart';

/// Commitment level for Parsed Events queries.
///
/// `processed` is not supported by the Parsed Events API.
enum ParsedEventsCommitment {
  /// Confirmed commitment.
  confirmed('confirmed'),

  /// Finalized commitment.
  finalized('finalized');

  const ParsedEventsCommitment(this.value);

  /// Wire value.
  final String value;

  /// Serializes this value to its wire string.
  String toJson() => value;

  /// Parses a wire string.
  static ParsedEventsCommitment fromJson(String json) => switch (json) {
    'confirmed' => confirmed,
    'finalized' => finalized,
    _ => throw ArgumentError.value(json, 'json', 'Unknown commitment'),
  };
}

/// Sort order for Parsed Events transaction history.
enum ParsedEventsSortOrder {
  /// Oldest first.
  asc('asc'),

  /// Newest first.
  desc('desc');

  const ParsedEventsSortOrder(this.value);

  /// Wire value.
  final String value;

  /// Serializes this value to its wire string.
  String toJson() => value;

  /// Parses a wire string.
  static ParsedEventsSortOrder fromJson(String json) => switch (json) {
    'asc' => asc,
    'desc' => desc,
    _ => throw ArgumentError.value(json, 'json', 'Unknown sort order'),
  };
}

/// Execution status of a parsed transaction.
enum ParsedTransactionStatus {
  /// The transaction executed successfully.
  ok('OK'),

  /// The transaction failed.
  error('ERROR');

  const ParsedTransactionStatus(this.value);

  /// Wire value.
  final String value;

  /// Serializes this value to its wire string.
  String toJson() => value;

  /// Parses a wire string.
  static ParsedTransactionStatus fromJson(String json) => switch (json) {
    'OK' => ok,
    'ERROR' => error,
    _ => throw ArgumentError.value(json, 'json', 'Unknown transaction status'),
  };
}

/// Encoding of the raw Solana transaction returned next to each parsed one.
enum ParsedEventsRawTransactionEncoding {
  /// Do not return a raw transaction.
  none('none'),

  /// Return the transaction in JSON shape.
  json('json'),

  /// Return the transaction in parsed JSON shape.
  jsonParsed('jsonParsed'),

  /// Return the transaction as base64.
  base64('base64');

  const ParsedEventsRawTransactionEncoding(this.value);

  /// Wire value.
  final String value;

  /// Serializes this value to its wire string.
  String toJson() => value;

  /// Parses a wire string.
  static ParsedEventsRawTransactionEncoding fromJson(String json) =>
      switch (json) {
        'none' => none,
        'json' => ParsedEventsRawTransactionEncoding.json,
        'jsonParsed' => jsonParsed,
        'base64' => base64,
        _ => throw ArgumentError.value(json, 'json', 'Unknown encoding'),
      };
}

/// Execution result to include in history and scan requests.
enum ParsedEventsStatusFilter {
  /// Only successful transactions.
  succeeded('succeeded'),

  /// Only failed transactions.
  failed('failed'),

  /// Both successful and failed transactions.
  any('any');

  const ParsedEventsStatusFilter(this.value);

  /// Wire value.
  final String value;

  /// Serializes this value to its wire string.
  String toJson() => value;

  /// Parses a wire string.
  static ParsedEventsStatusFilter fromJson(String json) => switch (json) {
    'succeeded' => succeeded,
    'failed' => failed,
    'any' => any,
    _ => throw ArgumentError.value(json, 'json', 'Unknown status filter'),
  };
}

/// Which token-account-only transactions are included.
enum ParsedEventsTokenAccountsFilter {
  /// Leave them out.
  none('none'),

  /// Include those that changed the token account balance.
  balanceChanged('balanceChanged'),

  /// Include all of them.
  all('all');

  const ParsedEventsTokenAccountsFilter(this.value);

  /// Wire value.
  final String value;

  /// Serializes this value to its wire string.
  String toJson() => value;

  /// Parses a wire string.
  static ParsedEventsTokenAccountsFilter fromJson(String json) =>
      switch (json) {
        'none' => none,
        'balanceChanged' => balanceChanged,
        'all' => all,
        _ => throw ArgumentError.value(json, 'json', 'Unknown token filter'),
      };
}

/// What a scan returns for its matches.
enum ScanReturnShape {
  /// Parsed transactions.
  transactions('transactions'),

  /// Signatures and positions.
  signatures('signatures'),

  /// Only the match count.
  count('count');

  const ScanReturnShape(this.value);

  /// Wire value.
  final String value;

  /// Serializes this value to its wire string.
  String toJson() => value;

  /// Parses a wire string.
  static ScanReturnShape fromJson(String json) => switch (json) {
    'transactions' => transactions,
    'signatures' => signatures,
    'count' => count,
    _ => throw ArgumentError.value(json, 'json', 'Unknown return shape'),
  };
}

/// Where a program instruction or mint balance must be to count.
enum ScanMatchScope {
  /// It must involve the scanned address.
  address('address'),

  /// It may appear anywhere in the transaction.
  transaction('transaction');

  const ScanMatchScope(this.value);

  /// Wire value.
  final String value;

  /// Serializes this value to its wire string.
  String toJson() => value;

  /// Parses a wire string.
  static ScanMatchScope fromJson(String json) => switch (json) {
    'address' => address,
    'transaction' => transaction,
    _ => throw ArgumentError.value(json, 'json', 'Unknown scan scope'),
  };
}

/// Why a scan request stopped.
enum ScanStopReason {
  /// Reached the end of the history or requested window.
  windowEnd('windowEnd'),

  /// Returned the requested number of matches.
  limit('limit'),

  /// Scanned the request's transaction budget.
  budget('budget'),

  /// Reached the request time limit.
  deadline('deadline');

  const ScanStopReason(this.value);

  /// Wire value.
  final String value;

  /// Serializes this value to its wire string.
  String toJson() => value;

  /// Parses a wire string.
  static ScanStopReason fromJson(String json) => switch (json) {
    'windowEnd' => windowEnd,
    'limit' => limit,
    'budget' => budget,
    'deadline' => deadline,
    _ => throw ArgumentError.value(json, 'json', 'Unknown stop reason'),
  };
}

/// Integer comparison bounds.
class ComparisonBounds {
  /// Creates comparison bounds.
  const ComparisonBounds({this.gt, this.gte, this.lt, this.lte});

  /// Builds comparison bounds from a JSON map.
  factory ComparisonBounds.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return ComparisonBounds(
      gt: r.optInt('gt'),
      gte: r.optInt('gte'),
      lt: r.optInt('lt'),
      lte: r.optInt('lte'),
    );
  }

  /// Match values greater than this.
  final int? gt;

  /// Match values greater than or equal to this.
  final int? gte;

  /// Match values less than this.
  final int? lt;

  /// Match values less than or equal to this.
  final int? lte;

  /// Serializes these bounds to a JSON map.
  Map<String, Object?> toJson() => {
    if (gt != null) 'gt': gt,
    if (gte != null) 'gte': gte,
    if (lt != null) 'lt': lt,
    if (lte != null) 'lte': lte,
  };
}

/// A SOL movement detected at transaction level.
class ParsedNativeTransfer {
  /// Creates a native transfer.
  const ParsedNativeTransfer({
    required this.fromUserAccount,
    required this.toUserAccount,
    required this.amount,
  });

  /// Builds a native transfer from a JSON map.
  factory ParsedNativeTransfer.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return ParsedNativeTransfer(
      fromUserAccount: r.optString('fromUserAccount'),
      toUserAccount: r.optString('toUserAccount'),
      amount: r.optNum('amount') ?? 0,
    );
  }

  /// Account sending lamports.
  final String? fromUserAccount;

  /// Account receiving lamports.
  final String? toUserAccount;

  /// Amount in lamports.
  final num amount;

  /// Serializes this transfer to a JSON map.
  Map<String, Object?> toJson() => {
    'fromUserAccount': fromUserAccount,
    'toUserAccount': toUserAccount,
    'amount': amount,
  };
}

/// An SPL Token or Token-2022 movement detected at transaction level.
class ParsedTokenTransfer {
  /// Creates a token transfer.
  const ParsedTokenTransfer({
    required this.fromUserAccount,
    required this.toUserAccount,
    required this.fromTokenAccount,
    required this.toTokenAccount,
    required this.rawTokenAmount,
    required this.decimals,
    required this.tokenStandard,
    required this.mint,
  });

  /// Builds a token transfer from a JSON map.
  factory ParsedTokenTransfer.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return ParsedTokenTransfer(
      fromUserAccount: r.optString('fromUserAccount'),
      toUserAccount: r.optString('toUserAccount'),
      fromTokenAccount: r.optString('fromTokenAccount'),
      toTokenAccount: r.optString('toTokenAccount'),
      rawTokenAmount: r.optNum('rawTokenAmount') ?? 0,
      decimals: r.requireInt('decimals'),
      tokenStandard: r.optString('tokenStandard') ?? 'UnknownStandard',
      mint: r.requireString('mint'),
    );
  }

  /// Owner or authority for the source side.
  final String? fromUserAccount;

  /// Owner for the destination side.
  final String? toUserAccount;

  /// Source token account.
  final String? fromTokenAccount;

  /// Destination token account.
  final String? toTokenAccount;

  /// Raw integer token amount.
  final num rawTokenAmount;

  /// Mint decimals used to interpret [rawTokenAmount].
  final int decimals;

  /// Token standard, when known.
  final String tokenStandard;

  /// Token mint address.
  final String mint;

  /// Serializes this transfer to a JSON map.
  Map<String, Object?> toJson() => {
    'fromUserAccount': fromUserAccount,
    'toUserAccount': toUserAccount,
    'fromTokenAccount': fromTokenAccount,
    'toTokenAccount': toTokenAccount,
    'rawTokenAmount': rawTokenAmount,
    'decimals': decimals,
    'tokenStandard': tokenStandard,
    'mint': mint,
  };
}

/// Human-readable summary for a transaction or instruction.
class ParsedSummary {
  /// Creates a summary.
  const ParsedSummary({
    required this.type,
    required this.description,
    this.parsedData,
  });

  /// Builds a summary from a JSON map.
  factory ParsedSummary.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return ParsedSummary(
      type: r.requireString('type'),
      description: r.requireString('description'),
      parsedData: r.optMap('parsedData'),
    );
  }

  /// Summary type (for example `swap` or `transfer`).
  final String type;

  /// Human-readable summary text.
  final String description;

  /// Structured payload behind the summary, when available.
  final Map<String, Object?>? parsedData;

  /// Serializes this summary to a JSON map.
  Map<String, Object?> toJson() => {
    'type': type,
    'description': description,
    if (parsedData != null) 'parsedData': parsedData,
  };
}

/// Named account used by a decoded instruction.
class DecodedAccount {
  /// Creates a decoded account.
  const DecodedAccount({
    required this.name,
    required this.pubkey,
    required this.isSigner,
    required this.isWritable,
  });

  /// Builds a decoded account from a JSON map.
  factory DecodedAccount.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return DecodedAccount(
      name: r.requireString('name'),
      pubkey: r.requireString('pubkey'),
      isSigner: r.requireBool('isSigner'),
      isWritable: r.requireBool('isWritable'),
    );
  }

  /// Parser-known account name.
  final String name;

  /// Account public key.
  final String pubkey;

  /// Whether the account signed the transaction.
  final bool isSigner;

  /// Whether the account was writable for the instruction.
  final bool isWritable;

  /// Serializes this account to a JSON map.
  Map<String, Object?> toJson() => {
    'name': name,
    'pubkey': pubkey,
    'isSigner': isSigner,
    'isWritable': isWritable,
  };
}

/// Decoded instruction args and named accounts.
class DecodedInstruction {
  /// Creates a decoded instruction.
  const DecodedInstruction({required this.args, required this.accounts});

  /// Builds a decoded instruction from a JSON map.
  factory DecodedInstruction.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return DecodedInstruction(
      args: r.requireMap('args'),
      accounts: r.requireDecodedList('accounts', DecodedAccount.fromJson),
    );
  }

  /// Decoded instruction arguments.
  final Map<String, Object?> args;

  /// Decoded instruction accounts.
  final List<DecodedAccount> accounts;

  /// Serializes this instruction to a JSON map.
  Map<String, Object?> toJson() => {
    'args': args,
    'accounts': accounts.map((account) => account.toJson()).toList(),
  };
}

/// A parsed top-level or inner (CPI) instruction.
class ParsedInstruction {
  /// Creates a parsed instruction.
  const ParsedInstruction({
    required this.instructionIndex,
    required this.innerInstructionIndex,
    required this.stackHeight,
    required this.programId,
    required this.rawAccounts,
    required this.rawData,
    required this.summary,
    required this.programName,
    required this.instructionName,
    required this.decoded,
  });

  /// Builds a parsed instruction from a JSON map.
  factory ParsedInstruction.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return ParsedInstruction(
      instructionIndex: r.requireInt('instructionIndex'),
      innerInstructionIndex: r.optInt('innerInstructionIndex'),
      stackHeight: r.optInt('stackHeight'),
      programId: r.requireString('programId'),
      rawAccounts: r.requireList<String>('rawAccounts'),
      rawData: r.requireString('rawData'),
      summary: r.optDecoded('summary', ParsedSummary.fromJson),
      programName: r.optString('programName'),
      instructionName: r.optString('instructionName'),
      decoded: r.optDecoded('decoded', DecodedInstruction.fromJson),
    );
  }

  /// Top-level instruction index.
  final int instructionIndex;

  /// Inner instruction index, or `null` for top-level instructions.
  final int? innerInstructionIndex;

  /// Stack height, when available.
  final int? stackHeight;

  /// Program ID that executed the instruction.
  final String programId;

  /// Account pubkeys resolved from the instruction's account indexes.
  final List<String> rawAccounts;

  /// Raw instruction data.
  final String rawData;

  /// Instruction-level summary, when available.
  final ParsedSummary? summary;

  /// Parser-known program name, when available.
  final String? programName;

  /// Decoded instruction name, when available.
  final String? instructionName;

  /// Decoded args and accounts, when decoding succeeds.
  final DecodedInstruction? decoded;

  /// Serializes this instruction to a JSON map.
  Map<String, Object?> toJson() => {
    'instructionIndex': instructionIndex,
    'innerInstructionIndex': innerInstructionIndex,
    'stackHeight': stackHeight,
    'programId': programId,
    'rawAccounts': rawAccounts,
    'rawData': rawData,
    'summary': summary?.toJson(),
    'programName': programName,
    'instructionName': instructionName,
    'decoded': decoded?.toJson(),
  };
}

/// A custom program error decoded from a failed transaction.
class ParsedDecodedError {
  /// Creates a decoded error.
  const ParsedDecodedError({
    required this.instructionIndex,
    required this.programId,
    required this.programName,
    required this.code,
    required this.name,
    this.msg,
  });

  /// Builds a decoded error from a JSON map.
  factory ParsedDecodedError.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return ParsedDecodedError(
      instructionIndex: r.requireInt('instructionIndex'),
      programId: r.requireString('programId'),
      programName: r.requireString('programName'),
      code: r.requireInt('code'),
      name: r.requireString('name'),
      msg: r.optString('msg'),
    );
  }

  /// Index of the failing instruction.
  final int instructionIndex;

  /// Failing program ID.
  final String programId;

  /// Failing program name.
  final String programName;

  /// Program error code.
  final int code;

  /// Program error name.
  final String name;

  /// Program error message, when available.
  final String? msg;

  /// Serializes this error to a JSON map.
  Map<String, Object?> toJson() => {
    'instructionIndex': instructionIndex,
    'programId': programId,
    'programName': programName,
    'code': code,
    'name': name,
    if (msg != null) 'msg': msg,
  };
}

/// A transaction parsed by Parsed Events.
class ParsedTransaction {
  /// Creates a parsed transaction.
  const ParsedTransaction({
    required this.slot,
    required this.blockTime,
    required this.fee,
    required this.feePayer,
    required this.transactionStatus,
    required this.nativeTransfers,
    required this.tokenTransfers,
    required this.summary,
    required this.instructions,
    this.error,
    this.decodedError,
  });

  /// Builds a parsed transaction from a JSON map.
  factory ParsedTransaction.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return ParsedTransaction(
      slot: r.requireInt('slot'),
      blockTime: r.optInt('blockTime'),
      fee: r.requireInt('fee'),
      feePayer: r.optString('feePayer'),
      transactionStatus: ParsedTransactionStatus.fromJson(
        r.requireString('transactionStatus'),
      ),
      error: r.raw('error'),
      decodedError: r.optDecoded('decodedError', ParsedDecodedError.fromJson),
      nativeTransfers: r.requireDecodedList(
        'nativeTransfers',
        ParsedNativeTransfer.fromJson,
      ),
      tokenTransfers: r.requireDecodedList(
        'tokenTransfers',
        ParsedTokenTransfer.fromJson,
      ),
      summary: r.optDecoded('summary', ParsedSummary.fromJson),
      instructions: r.requireDecodedList(
        'instructions',
        ParsedInstruction.fromJson,
      ),
    );
  }

  /// Slot containing the transaction.
  final int slot;

  /// Unix timestamp of the block, when available.
  final int? blockTime;

  /// Transaction fee in lamports.
  final int fee;

  /// Fee payer account, when available.
  final String? feePayer;

  /// Whether the transaction executed successfully.
  final ParsedTransactionStatus transactionStatus;

  /// Raw execution error when [transactionStatus] is [ParsedTransactionStatus.error].
  final Object? error;

  /// Custom program error decoded from [error], when available.
  final ParsedDecodedError? decodedError;

  /// Transaction-level SOL transfers.
  final List<ParsedNativeTransfer> nativeTransfers;

  /// Transaction-level SPL Token and Token-2022 transfers.
  final List<ParsedTokenTransfer> tokenTransfers;

  /// Best transaction-level summary, when recognized.
  final ParsedSummary? summary;

  /// Parsed top-level and inner instructions.
  final List<ParsedInstruction> instructions;

  /// Serializes this transaction to a JSON map.
  Map<String, Object?> toJson() => {
    'slot': slot,
    'blockTime': blockTime,
    'fee': fee,
    'feePayer': feePayer,
    'transactionStatus': transactionStatus.toJson(),
    if (error != null) 'error': error,
    if (decodedError != null) 'decodedError': decodedError!.toJson(),
    'nativeTransfers': nativeTransfers.map((e) => e.toJson()).toList(),
    'tokenTransfers': tokenTransfers.map((e) => e.toJson()).toList(),
    'summary': summary?.toJson(),
    'instructions': instructions.map((e) => e.toJson()).toList(),
  };
}

/// Item-level parser error.
class ParserError {
  /// Creates a parser error.
  const ParserError({required this.code, required this.message});

  /// Builds a parser error from a JSON map.
  factory ParserError.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return ParserError(
      code: r.requireString('code'),
      message: r.requireString('message'),
    );
  }

  /// Machine-readable error code.
  final String code;

  /// Human-readable error message.
  final String message;

  /// Serializes this error to a JSON map.
  Map<String, Object?> toJson() => {'code': code, 'message': message};
}

/// Per-signature parser result.
///
/// Missing transactions and parser failures come back as results with
/// [parserStatus] set to [ParsedTransactionStatus.error] rather than failing
/// the whole request.
class ParsedTransactionResult {
  /// Creates a parser result.
  const ParsedTransactionResult({
    required this.signature,
    required this.parserStatus,
    this.parsed,
    this.parserError,
    this.rawTransaction,
  });

  /// Builds a parser result from a JSON map.
  factory ParsedTransactionResult.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    final status = ParsedTransactionStatus.fromJson(
      r.requireString('parserStatus'),
    );
    return ParsedTransactionResult(
      signature: r.requireString('signature'),
      parserStatus: status,
      parsed: r.optDecoded('parsed', ParsedTransaction.fromJson),
      parserError: r.optDecoded('parserError', ParserError.fromJson),
      rawTransaction: r.optMap('rawTransaction'),
    );
  }

  /// Transaction signature for this item.
  final String signature;

  /// Whether the item was parsed successfully.
  final ParsedTransactionStatus parserStatus;

  /// Parsed transaction for successful items.
  final ParsedTransaction? parsed;

  /// Item-level error for failed items.
  final ParserError? parserError;

  /// Original transaction, when requested.
  final Map<String, Object?>? rawTransaction;

  /// Serializes this result to a JSON map.
  Map<String, Object?> toJson() => {
    'signature': signature,
    'parserStatus': parserStatus.toJson(),
    if (parsed != null) 'parsed': parsed!.toJson(),
    if (parserError != null) 'parserError': parserError!.toJson(),
    if (rawTransaction != null) 'rawTransaction': rawTransaction,
  };
}

/// Request parameters for `parsedEvents.parseTransactions`.
class ParseTransactionsRequest {
  /// Creates a request.
  const ParseTransactionsRequest({
    required this.transactions,
    this.commitment,
    this.rawTransaction,
    this.includeRawTransaction,
  });

  /// Builds a request from a JSON map.
  factory ParseTransactionsRequest.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return ParseTransactionsRequest(
      transactions: r.requireList<String>('transactions'),
      commitment: r.optEnum('commitment', ParsedEventsCommitment.fromJson),
      rawTransaction: r.optEnum(
        'rawTransaction',
        ParsedEventsRawTransactionEncoding.fromJson,
      ),
      includeRawTransaction: r.optBool('includeRawTransaction'),
    );
  }

  /// Transaction signatures to parse (max 100).
  final List<String> transactions;

  /// Commitment level.
  final ParsedEventsCommitment? commitment;

  /// Encoding of the original transaction to include.
  final ParsedEventsRawTransactionEncoding? rawTransaction;

  /// Deprecated alias for `rawTransaction: json`.
  final bool? includeRawTransaction;

  /// Serializes this request to a JSON map.
  Map<String, Object?> toJson() => {
    'transactions': transactions,
    if (commitment != null) 'commitment': commitment!.toJson(),
    if (rawTransaction != null) 'rawTransaction': rawTransaction!.toJson(),
    if (includeRawTransaction == true) 'includeRawTransaction': true,
  };
}

/// Window, cursor, filter, and output options shared by history and scan.
abstract class ParsedHistoryWindowOptions {
  /// Creates shared history/scan options.
  const ParsedHistoryWindowOptions({
    this.beforeSignature,
    this.afterSignature,
    this.paginationToken,
    this.sortOrder,
    this.commitment,
    this.status,
    this.tokenAccounts,
    this.minContextSlot,
    this.rawTransaction,
    this.slot,
    this.time,
  });

  /// Only transactions before this signature.
  final String? beforeSignature;

  /// Only transactions after this signature.
  final String? afterSignature;

  /// Cursor returned by a previous request.
  final String? paginationToken;

  /// Order in which history is walked.
  final ParsedEventsSortOrder? sortOrder;

  /// Commitment level.
  final ParsedEventsCommitment? commitment;

  /// Execution result to include.
  final ParsedEventsStatusFilter? status;

  /// Token-account-only transactions to include.
  final ParsedEventsTokenAccountsFilter? tokenAccounts;

  /// Minimum slot at which the request can be evaluated.
  final int? minContextSlot;

  /// Encoding of the original transaction to include.
  final ParsedEventsRawTransactionEncoding? rawTransaction;

  /// Slot comparison bounds.
  final ComparisonBounds? slot;

  /// Block-time comparison bounds.
  final ComparisonBounds? time;

  /// Serializes the shared options to a JSON map.
  Map<String, Object?> windowToJson() => {
    if (beforeSignature != null) 'beforeSignature': beforeSignature,
    if (afterSignature != null) 'afterSignature': afterSignature,
    if (paginationToken != null && paginationToken!.isNotEmpty)
      'paginationToken': paginationToken,
    if (sortOrder != null) 'sortOrder': sortOrder!.toJson(),
    if (commitment != null) 'commitment': commitment!.toJson(),
    if (status != null) 'status': status!.toJson(),
    if (tokenAccounts != null) 'tokenAccounts': tokenAccounts!.toJson(),
    if (minContextSlot != null) 'minContextSlot': minContextSlot,
    if (rawTransaction != null) 'rawTransaction': rawTransaction!.toJson(),
    if (slot != null) 'slot': slot!.toJson(),
    if (time != null) 'time': time!.toJson(),
  };
}

/// Request parameters for `parsedEvents.getTransactionHistory`.
class GetParsedTransactionHistoryRequest extends ParsedHistoryWindowOptions {
  /// Creates a request.
  const GetParsedTransactionHistoryRequest({
    required this.address,
    this.limit,
    this.includeRawTransaction,
    super.beforeSignature,
    super.afterSignature,
    super.paginationToken,
    super.sortOrder,
    super.commitment,
    super.status,
    super.tokenAccounts,
    super.minContextSlot,
    super.rawTransaction,
    super.slot,
    super.time,
  });

  /// Builds a request from a JSON map.
  factory GetParsedTransactionHistoryRequest.fromJson(
    Map<String, Object?> json,
  ) {
    final r = JsonReader(json);
    return GetParsedTransactionHistoryRequest(
      address: r.requireString('address'),
      limit: r.optInt('limit'),
      includeRawTransaction: r.optBool('includeRawTransaction'),
      beforeSignature: r.optString('beforeSignature'),
      afterSignature: r.optString('afterSignature'),
      paginationToken: r.optString('paginationToken'),
      sortOrder: r.optEnum('sortOrder', ParsedEventsSortOrder.fromJson),
      commitment: r.optEnum('commitment', ParsedEventsCommitment.fromJson),
      status: r.optEnum('status', ParsedEventsStatusFilter.fromJson),
      tokenAccounts: r.optEnum(
        'tokenAccounts',
        ParsedEventsTokenAccountsFilter.fromJson,
      ),
      minContextSlot: r.optInt('minContextSlot'),
      rawTransaction: r.optEnum(
        'rawTransaction',
        ParsedEventsRawTransactionEncoding.fromJson,
      ),
      slot: r.optDecoded('slot', ComparisonBounds.fromJson),
      time: r.optDecoded('time', ComparisonBounds.fromJson),
    );
  }

  /// Address whose transaction history should be fetched.
  final String address;

  /// Number of transactions to return, 1 to 100.
  final int? limit;

  /// Deprecated alias for `rawTransaction: json`.
  final bool? includeRawTransaction;

  /// Serializes this request to a JSON map.
  Map<String, Object?> toJson() => {
    'address': address,
    if (limit != null) 'limit': limit,
    if (includeRawTransaction == true) 'includeRawTransaction': true,
    ...windowToJson(),
  };
}

/// Response from `parsedEvents.getTransactionHistory`.
class GetParsedTransactionHistoryResponse {
  /// Creates a history response.
  const GetParsedTransactionHistoryResponse({
    required this.data,
    this.paginationToken,
  });

  /// Builds a history response from a JSON map.
  factory GetParsedTransactionHistoryResponse.fromJson(
    Map<String, Object?> json,
  ) {
    final r = JsonReader(json);
    return GetParsedTransactionHistoryResponse(
      data: r.requireDecodedList('data', ParsedTransactionResult.fromJson),
      paginationToken: r.optString('paginationToken'),
    );
  }

  /// Parsed transaction results for this page.
  final List<ParsedTransactionResult> data;

  /// Cursor for the next page.
  final String? paginationToken;

  /// Serializes this response to a JSON map.
  Map<String, Object?> toJson() => {
    'data': data.map((e) => e.toJson()).toList(),
    if (paginationToken != null) 'paginationToken': paginationToken,
  };
}

/// Matches transactions with an instruction of a specific program.
class ScanProgramMatch {
  /// Creates a program match.
  const ScanProgramMatch({
    required this.programId,
    this.instructions,
    this.discriminators,
    this.scope,
  });

  /// Builds a program match from a JSON map.
  factory ScanProgramMatch.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return ScanProgramMatch(
      programId: r.requireString('programId'),
      instructions: r.optList<String>('instructions'),
      discriminators: r.optList<String>('discriminators'),
      scope: r.optEnum('scope', ScanMatchScope.fromJson),
    );
  }

  /// Program address.
  final String programId;

  /// Instruction names from any IDL version of the program.
  final List<String>? instructions;

  /// Instruction data prefixes as hex.
  final List<String>? discriminators;

  /// Which of the program's instructions count.
  final ScanMatchScope? scope;

  /// Serializes this match to a JSON map.
  Map<String, Object?> toJson() => {
    'programId': programId,
    if (instructions != null) 'instructions': instructions,
    if (discriminators != null) 'discriminators': discriminators,
    if (scope != null) 'scope': scope!.toJson(),
  };
}

/// Matches transactions with a token balance of a specific mint.
class ScanMintMatch {
  /// Creates a mint match.
  const ScanMintMatch({required this.mint, this.scope});

  /// Builds a mint match from a JSON map.
  factory ScanMintMatch.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return ScanMintMatch(
      mint: r.requireString('mint'),
      scope: r.optEnum('scope', ScanMatchScope.fromJson),
    );
  }

  /// Token mint address.
  final String mint;

  /// Which of the mint's balances count.
  final ScanMatchScope? scope;

  /// Serializes this match to a JSON map.
  Map<String, Object?> toJson() => {
    'mint': mint,
    if (scope != null) 'scope': scope!.toJson(),
  };
}

/// What a transaction must match in a scan.
class ScanMatch {
  /// Creates a scan match.
  const ScanMatch({this.programs, this.mints});

  /// Builds a scan match from a JSON map.
  factory ScanMatch.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return ScanMatch(
      programs: r.optDecodedList('programs', ScanProgramMatch.fromJson),
      mints: r.optDecodedList('mints', ScanMintMatch.fromJson),
    );
  }

  /// Programs whose instructions match.
  final List<ScanProgramMatch>? programs;

  /// Mints whose balances match.
  final List<ScanMintMatch>? mints;

  /// Serializes this match to a JSON map.
  Map<String, Object?> toJson() => {
    if (programs != null) 'programs': programs!.map((e) => e.toJson()).toList(),
    if (mints != null) 'mints': mints!.map((e) => e.toJson()).toList(),
  };
}

/// Limits on how much history one scan request covers.
class ScanBudget {
  /// Creates a scan budget.
  const ScanBudget({this.maxScannedTransactions});

  /// Builds a budget from a JSON map.
  factory ScanBudget.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return ScanBudget(
      maxScannedTransactions: r.optInt('maxScannedTransactions'),
    );
  }

  /// Most transactions to scan in this request, 1 to 10,000.
  final int? maxScannedTransactions;

  /// Serializes this budget to a JSON map.
  Map<String, Object?> toJson() => {
    if (maxScannedTransactions != null)
      'maxScannedTransactions': maxScannedTransactions,
  };
}

/// Request parameters for `parsedEvents.scan`.
class ScanParsedTransactionHistoryRequest extends ParsedHistoryWindowOptions {
  /// Creates a scan request.
  const ScanParsedTransactionHistoryRequest({
    required this.address,
    required this.match,
    this.returnShape,
    this.limit,
    this.budget,
    super.beforeSignature,
    super.afterSignature,
    super.paginationToken,
    super.sortOrder,
    super.commitment,
    super.status,
    super.tokenAccounts,
    super.minContextSlot,
    super.rawTransaction,
    super.slot,
    super.time,
  });

  /// Builds a scan request from a JSON map.
  factory ScanParsedTransactionHistoryRequest.fromJson(
    Map<String, Object?> json,
  ) {
    final r = JsonReader(json);
    return ScanParsedTransactionHistoryRequest(
      address: r.requireString('address'),
      match: r.requireDecoded('match', ScanMatch.fromJson),
      returnShape: r.optEnum('returnShape', ScanReturnShape.fromJson),
      limit: r.optInt('limit'),
      budget: r.optDecoded('budget', ScanBudget.fromJson),
      beforeSignature: r.optString('beforeSignature'),
      afterSignature: r.optString('afterSignature'),
      paginationToken: r.optString('paginationToken'),
      sortOrder: r.optEnum('sortOrder', ParsedEventsSortOrder.fromJson),
      commitment: r.optEnum('commitment', ParsedEventsCommitment.fromJson),
      status: r.optEnum('status', ParsedEventsStatusFilter.fromJson),
      tokenAccounts: r.optEnum(
        'tokenAccounts',
        ParsedEventsTokenAccountsFilter.fromJson,
      ),
      minContextSlot: r.optInt('minContextSlot'),
      rawTransaction: r.optEnum(
        'rawTransaction',
        ParsedEventsRawTransactionEncoding.fromJson,
      ),
      slot: r.optDecoded('slot', ComparisonBounds.fromJson),
      time: r.optDecoded('time', ComparisonBounds.fromJson),
    );
  }

  /// Address whose history is scanned.
  final String address;

  /// What a transaction must match.
  final ScanMatch match;

  /// What the response carries for the matches.
  final ScanReturnShape? returnShape;

  /// Most matches to return with the `transactions` shape.
  final int? limit;

  /// Limits on how much history this request scans.
  final ScanBudget? budget;

  /// Serializes this request to a JSON map.
  Map<String, Object?> toJson() => {
    'address': address,
    'match': match.toJson(),
    if (returnShape != null) 'returnShape': returnShape!.toJson(),
    if (limit != null) 'limit': limit,
    if (budget != null) 'budget': budget!.toJson(),
    ...windowToJson(),
  };
}

/// A match returned with `returnShape: signatures`.
class ScanSignature {
  /// Creates a scan signature.
  const ScanSignature({
    required this.signature,
    required this.slot,
    required this.transactionIndex,
    required this.blockTime,
  });

  /// Builds a scan signature from a JSON map.
  factory ScanSignature.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return ScanSignature(
      signature: r.requireString('signature'),
      slot: r.requireInt('slot'),
      transactionIndex: r.requireInt('transactionIndex'),
      blockTime: r.optInt('blockTime'),
    );
  }

  /// Transaction signature.
  final String signature;

  /// Slot containing the transaction.
  final int slot;

  /// Position of the transaction within its slot.
  final int transactionIndex;

  /// Unix timestamp of the block, when available.
  final int? blockTime;

  /// Serializes this signature to a JSON map.
  Map<String, Object?> toJson() => {
    'signature': signature,
    'slot': slot,
    'transactionIndex': transactionIndex,
    'blockTime': blockTime,
  };
}

/// Position of the last transaction a scan request covered.
class ScannedThrough {
  /// Creates a scanned-through marker.
  const ScannedThrough({required this.slot, required this.blockTime});

  /// Builds a marker from a JSON map.
  factory ScannedThrough.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return ScannedThrough(
      slot: r.requireInt('slot'),
      blockTime: r.optInt('blockTime'),
    );
  }

  /// Slot of the last transaction scanned.
  final int slot;

  /// Block time of the last transaction scanned.
  final int? blockTime;

  /// Serializes this marker to a JSON map.
  Map<String, Object?> toJson() => {'slot': slot, 'blockTime': blockTime};
}

/// How far a scan request got and why it stopped.
class ScanSummary {
  /// Creates a scan summary.
  const ScanSummary({
    required this.stoppedOn,
    required this.scannedTransactions,
    required this.matchedTransactions,
    required this.creditsCharged,
    this.scannedThrough,
  });

  /// Builds a scan summary from a JSON map.
  factory ScanSummary.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return ScanSummary(
      stoppedOn: ScanStopReason.fromJson(r.requireString('stoppedOn')),
      scannedTransactions: r.requireInt('scannedTransactions'),
      matchedTransactions: r.requireInt('matchedTransactions'),
      creditsCharged: r.requireInt('creditsCharged'),
      scannedThrough: r.optDecoded('scannedThrough', ScannedThrough.fromJson),
    );
  }

  /// Why the scan stopped.
  final ScanStopReason stoppedOn;

  /// Transactions scanned in this request.
  final int scannedTransactions;

  /// Matches found in this request.
  final int matchedTransactions;

  /// Credits charged for this request.
  final int creditsCharged;

  /// Position of the last transaction scanned.
  final ScannedThrough? scannedThrough;

  /// Serializes this summary to a JSON map.
  Map<String, Object?> toJson() => {
    'stoppedOn': stoppedOn.toJson(),
    'scannedTransactions': scannedTransactions,
    'matchedTransactions': matchedTransactions,
    'creditsCharged': creditsCharged,
    if (scannedThrough != null) 'scannedThrough': scannedThrough!.toJson(),
  };
}

/// Response from `parsedEvents.scan`.
///
/// [data] holds [ParsedTransactionResult] items for the default
/// `transactions` shape and [ScanSignature] items for `signatures`. It is
/// absent for the `count` shape, where [ScanSummary.matchedTransactions] is
/// the result.
class ScanResponse {
  /// Creates a scan response.
  const ScanResponse({required this.scan, this.data, this.paginationToken});

  /// Builds a scan response from a JSON map.
  factory ScanResponse.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    final rawData = r.raw('data');
    return ScanResponse(
      data: rawData is List
          ? rawData.map(_decodeScanEntry).toList(growable: false)
          : null,
      paginationToken: r.optString('paginationToken'),
      scan: r.requireDecoded('scan', ScanSummary.fromJson),
    );
  }

  /// Matches, as [ParsedTransactionResult] or [ScanSignature] entries.
  final List<Object>? data;

  /// Cursor for the next scan request.
  final String? paginationToken;

  /// How far this request got and why it stopped.
  final ScanSummary scan;

  /// Parsed transaction matches.
  List<ParsedTransactionResult> get transactions =>
      data?.whereType<ParsedTransactionResult>().toList() ?? const [];

  /// Signature matches.
  List<ScanSignature> get signatures =>
      data?.whereType<ScanSignature>().toList() ?? const [];

  /// Serializes this response to a JSON map.
  Map<String, Object?> toJson() => {
    if (data != null) 'data': data!.map(_encodeScanEntry).toList(),
    if (paginationToken != null) 'paginationToken': paginationToken,
    'scan': scan.toJson(),
  };
}

Object _decodeScanEntry(Object? entry) {
  final json = entry! as Map<String, Object?>;

  if (json.containsKey('signature') && json.containsKey('transactionIndex')) {
    return ScanSignature.fromJson(json);
  }

  return ParsedTransactionResult.fromJson(json);
}

Object _encodeScanEntry(Object entry) => switch (entry) {
  final ScanSignature signature => signature.toJson(),
  final ParsedTransactionResult transaction => transaction.toJson(),
  _ => throw ArgumentError.value(entry, 'entry', 'Unsupported scan entry'),
};
