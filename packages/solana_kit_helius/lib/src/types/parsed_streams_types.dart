import 'package:solana_kit_helius/src/internal/json_reader.dart';
import 'package:solana_kit_helius/src/types/parsed_events_types.dart';

/// Endpoint that serves Parsed Streams subscriptions.
String parsedStreamsUrl(String apiKey) => Uri(
  scheme: 'wss',
  host: 'beta.helius-rpc.com',
  path: '/',
  queryParameters: {'api-key': apiKey},
).toString();

/// Endpoint that currently serves `describeProgram`.
String parsedStreamsDiscoveryUrl(String apiKey) => Uri(
  scheme: 'wss',
  host: 'fs-beta.helius-rpc.com',
  path: '/',
  queryParameters: {'api-key': apiKey},
).toString();

/// Which instructions a Parsed Streams subscription matches.
///
/// At least one of [programs] or `accounts.include` is required; the fields
/// you set combine with AND.
class ParsedTransactionFilter {
  /// Creates a filter.
  const ParsedTransactionFilter({
    this.programs,
    this.instructionNames,
    this.accounts,
    this.includeFailed,
    this.includeCpi,
  });

  /// Program IDs (base58 addresses, not names). Max 10.
  final List<String>? programs;

  /// Decoded instruction names, for example `route`. Max 50.
  final List<String>? instructionNames;

  /// Account constraints.
  final ParsedTransactionFilterAccounts? accounts;

  /// Include instructions from failed transactions. Defaults to `false`.
  final bool? includeFailed;

  /// Let inner (CPI) instructions match. Defaults to `true`.
  final bool? includeCpi;

  /// Serializes this filter to a JSON map.
  Map<String, Object?> toJson() => {
    if (programs != null) 'programs': programs,
    if (instructionNames != null) 'instructionNames': instructionNames,
    if (accounts != null) 'accounts': accounts!.toJson(),
    if (includeFailed != null) 'includeFailed': includeFailed,
    if (includeCpi != null) 'includeCpi': includeCpi,
  };
}

/// Account constraints for [ParsedTransactionFilter].
class ParsedTransactionFilterAccounts {
  /// Creates account constraints.
  const ParsedTransactionFilterAccounts({this.include, this.roles});

  /// Addresses an instruction must touch (any of). Max 100.
  final List<String>? include;

  /// Decoded role name to address; all must hold. Max 20.
  final Map<String, String>? roles;

  /// Serializes these constraints to a JSON map.
  Map<String, Object?> toJson() => {
    if (include != null) 'include': include,
    if (roles != null) 'roles': roles,
  };
}

/// Payload size for a Parsed Streams notification.
enum ParsedStreamDetails {
  /// The whole transaction plus `matchedIndexes`.
  full('full'),

  /// Only the matching instructions.
  matched('matched'),

  /// Matching instructions reduced to position, program, and base58 data.
  raw('raw');

  const ParsedStreamDetails(this.value);

  /// Wire value.
  final String value;

  /// Serializes this value to its wire string.
  String toJson() => value;

  /// Parses a wire string.
  static ParsedStreamDetails fromJson(String json) => switch (json) {
    'full' => full,
    'matched' => matched,
    'raw' => raw,
    _ => throw ArgumentError.value(json, 'json', 'Unknown details level'),
  };
}

/// Options for `parsedTransactionSubscribe`.
class ParsedTransactionSubscribeOptions {
  /// Creates subscribe options.
  const ParsedTransactionSubscribeOptions({
    this.commitment,
    this.details = ParsedStreamDetails.full,
  });

  /// Only `confirmed` is supported.
  final String? commitment;

  /// Payload size.
  final ParsedStreamDetails details;

  /// Serializes these options to a JSON map.
  Map<String, Object?> toJson() => {
    if (commitment != null) 'commitment': commitment,
    'details': details.toJson(),
  };
}

/// Transaction context in a `full` or `matched` notification.
class ParsedStreamTransaction {
  /// Creates a parsed stream transaction.
  const ParsedStreamTransaction({
    required this.signature,
    required this.slot,
    required this.blockTime,
    required this.feePayer,
    required this.fee,
    required this.accountKeys,
    required this.status,
    required this.error,
    required this.summary,
    required this.nativeTransfers,
    required this.tokenTransfers,
  });

  /// Builds a transaction from a JSON map.
  factory ParsedStreamTransaction.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return ParsedStreamTransaction(
      signature: r.requireString('signature'),
      slot: r.requireInt('slot'),
      blockTime: r.optInt('blockTime'),
      feePayer: r.optString('feePayer') ?? '',
      fee: r.optInt('fee') ?? 0,
      accountKeys: r.optList<String>('accountKeys') ?? const [],
      status: r.requireString('status'),
      error: r.raw('error'),
      summary: r.optDecoded('summary', ParsedSummary.fromJson),
      nativeTransfers:
          r.optDecodedList('nativeTransfers', ParsedNativeTransfer.fromJson) ??
          const [],
      tokenTransfers:
          r.optDecodedList('tokenTransfers', ParsedTokenTransfer.fromJson) ??
          const [],
    );
  }

  /// Transaction signature.
  final String signature;

  /// Slot containing the transaction.
  final int slot;

  /// Block time, currently always null upstream.
  final int? blockTime;

  /// Fee payer account.
  final String feePayer;

  /// Fee in lamports.
  final int fee;

  /// Every account key in chain order.
  final List<String> accountKeys;

  /// `ok` or `error`.
  final String status;

  /// Structured transaction error when [status] is `error`.
  final Object? error;

  /// The transaction's headline action, when recognized.
  final ParsedSummary? summary;

  /// SOL movements.
  final List<ParsedNativeTransfer> nativeTransfers;

  /// Token movements.
  final List<ParsedTokenTransfer> tokenTransfers;

  /// Serializes this transaction to a JSON map.
  Map<String, Object?> toJson() => {
    'signature': signature,
    'slot': slot,
    'blockTime': blockTime,
    'feePayer': feePayer,
    'fee': fee,
    'accountKeys': accountKeys,
    'status': status,
    if (error != null) 'error': error,
    'summary': summary?.toJson(),
    'nativeTransfers': nativeTransfers.map((e) => e.toJson()).toList(),
    'tokenTransfers': tokenTransfers.map((e) => e.toJson()).toList(),
  };
}

/// An instruction in a `full` or `matched` notification.
class ParsedStreamInstruction {
  /// Creates an instruction.
  const ParsedStreamInstruction({
    required this.instructionIndex,
    required this.innerInstructionIndex,
    required this.stackHeight,
    required this.programId,
    required this.programName,
    required this.instructionName,
    required this.summary,
    required this.decoded,
    this.rawData,
    this.rawAccounts,
  });

  /// Builds an instruction from a JSON map.
  factory ParsedStreamInstruction.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return ParsedStreamInstruction(
      instructionIndex: r.requireInt('instructionIndex'),
      innerInstructionIndex: r.optInt('innerInstructionIndex'),
      stackHeight: r.optInt('stackHeight'),
      programId: r.requireString('programId'),
      programName: r.optString('programName'),
      instructionName: r.optString('instructionName'),
      summary: r.optDecoded('summary', ParsedSummary.fromJson),
      decoded: r.optDecoded('decoded', DecodedInstruction.fromJson),
      rawData: r.optString('rawData'),
      rawAccounts: r.optList<String>('rawAccounts'),
    );
  }

  /// Top-level instruction this belongs to.
  final int instructionIndex;

  /// Position among inner calls, or null for the top-level instruction.
  final int? innerInstructionIndex;

  /// Call depth (1 for top level).
  final int? stackHeight;

  /// Program ID.
  final String programId;

  /// Parser-known program name.
  final String? programName;

  /// Decoded instruction name.
  final String? instructionName;

  /// Instruction-level summary, when recognized.
  final ParsedSummary? summary;

  /// Named args and accounts, or null when undecoded.
  final DecodedInstruction? decoded;

  /// Base58 instruction data, present when [decoded] is null.
  final String? rawData;

  /// Plain account list, present when [decoded] is null.
  final List<String>? rawAccounts;

  /// Serializes this instruction to a JSON map.
  Map<String, Object?> toJson() => {
    'instructionIndex': instructionIndex,
    'innerInstructionIndex': innerInstructionIndex,
    'stackHeight': stackHeight,
    'programId': programId,
    'programName': programName,
    'instructionName': instructionName,
    'summary': summary?.toJson(),
    'decoded': decoded?.toJson(),
    if (rawData != null) 'rawData': rawData,
    if (rawAccounts != null) 'rawAccounts': rawAccounts,
  };
}

/// Notification payload for `full` or `matched` details.
class ParsedTransactionValue {
  /// Creates a parsed transaction value.
  const ParsedTransactionValue({
    required this.transaction,
    required this.instructions,
    this.matchedIndexes,
  });

  /// Builds a value from a JSON map.
  factory ParsedTransactionValue.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return ParsedTransactionValue(
      transaction: r.requireDecoded(
        'transaction',
        ParsedStreamTransaction.fromJson,
      ),
      instructions: r.requireDecodedList(
        'instructions',
        ParsedStreamInstruction.fromJson,
      ),
      matchedIndexes: r.optList<int>('matchedIndexes'),
    );
  }

  /// Transaction context.
  final ParsedStreamTransaction transaction;

  /// Every instruction (`full`) or only the hits (`matched`).
  final List<ParsedStreamInstruction> instructions;

  /// Indexes into [instructions] that matched; absent with `matched`.
  final List<int>? matchedIndexes;
}

/// Transaction context in a `raw` notification.
class RawStreamTransaction {
  /// Creates a raw transaction context.
  const RawStreamTransaction({
    required this.signature,
    required this.slot,
    required this.blockTime,
    required this.feePayer,
    required this.fee,
    required this.status,
    required this.error,
    required this.summary,
  });

  /// Builds a raw transaction from a JSON map.
  factory RawStreamTransaction.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return RawStreamTransaction(
      signature: r.requireString('signature'),
      slot: r.requireInt('slot'),
      blockTime: r.optInt('blockTime'),
      feePayer: r.optString('feePayer') ?? '',
      fee: r.optInt('fee') ?? 0,
      status: r.requireString('status'),
      error: r.raw('error'),
      summary: r.optDecoded('summary', ParsedSummary.fromJson),
    );
  }

  /// Transaction signature.
  final String signature;

  /// Slot containing the transaction.
  final int slot;

  /// Block time.
  final int? blockTime;

  /// Fee payer account.
  final String feePayer;

  /// Fee in lamports.
  final int fee;

  /// `ok` or `error`.
  final String status;

  /// Structured transaction error.
  final Object? error;

  /// Headline summary, when recognized.
  final ParsedSummary? summary;
}

/// A matched instruction in a `raw` notification.
class RawStreamInstruction {
  /// Creates a raw instruction.
  const RawStreamInstruction({
    required this.instructionIndex,
    required this.innerInstructionIndex,
    required this.stackHeight,
    required this.programId,
    required this.data,
  });

  /// Builds a raw instruction from a JSON map.
  factory RawStreamInstruction.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return RawStreamInstruction(
      instructionIndex: r.requireInt('instructionIndex'),
      innerInstructionIndex: r.optInt('innerInstructionIndex'),
      stackHeight: r.optInt('stackHeight'),
      programId: r.requireString('programId'),
      data: r.requireString('data'),
    );
  }

  /// Top-level instruction index.
  final int instructionIndex;

  /// Inner instruction index, or null for top level.
  final int? innerInstructionIndex;

  /// Call depth.
  final int? stackHeight;

  /// Program ID.
  final String programId;

  /// Instruction data as it appears on chain, base58.
  final String data;
}

/// Notification payload for `raw` details.
class RawTransactionValue {
  /// Creates a raw transaction value.
  const RawTransactionValue({
    required this.transaction,
    required this.instructions,
  });

  /// Builds a value from a JSON map.
  factory RawTransactionValue.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return RawTransactionValue(
      transaction: r.requireDecoded(
        'transaction',
        RawStreamTransaction.fromJson,
      ),
      instructions: r.requireDecodedList(
        'instructions',
        RawStreamInstruction.fromJson,
      ),
    );
  }

  /// Transaction context.
  final RawStreamTransaction transaction;

  /// Matching instructions.
  final List<RawStreamInstruction> instructions;
}

/// One matching transaction.
class ParsedTransactionNotification {
  /// Creates a notification.
  const ParsedTransactionNotification({
    required this.contextSlot,
    required this.value,
  });

  /// The slot in the notification's context.
  final int contextSlot;

  /// Payload chosen by the subscription's details level.
  final Object value;
}

/// `describeProgram` result: the exact names the matcher compares against.
class ProgramDescription {
  /// Creates a program description.
  const ProgramDescription({
    required this.id,
    required this.name,
    required this.instructions,
    required this.events,
    required this.roles,
  });

  /// Builds a description from a JSON map.
  factory ProgramDescription.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return ProgramDescription(
      id: r.requireString('id'),
      name: r.requireString('name'),
      instructions: r.optList<String>('instructions') ?? const [],
      events: r.optList<String>('events') ?? const [],
      roles: r.optList<String>('roles') ?? const [],
    );
  }

  /// Program address.
  final String id;

  /// Catalog name.
  final String name;

  /// Decoded instruction names.
  final List<String> instructions;

  /// Event names the parser recognizes.
  final List<String> events;

  /// Account role names.
  final List<String> roles;
}

/// Passed to `onReconnect` once subscriptions are restored on a new
/// connection.
class ParsedStreamsReconnectInfo {
  /// Creates reconnect information.
  const ParsedStreamsReconnectInfo({
    required this.closeCode,
    required this.lastSlot,
  });

  /// WebSocket close code that caused the reconnect.
  final int closeCode;

  /// Highest `context.slot` delivered before the disconnect.
  final int? lastSlot;
}

/// A JSON-RPC error from Parsed Streams, with its `code` when provided.
class ParsedStreamsError implements Exception {
  /// Creates a Parsed Streams error.
  ParsedStreamsError(this.code, this.message);

  /// JSON-RPC error code (for example `-32602`).
  final int? code;

  /// Human-readable error message.
  final String message;

  @override
  String toString() => 'ParsedStreamsError(${code ?? 'unknown'}): $message';
}

/// An active Parsed Streams subscription.
class ParsedTransactionSubscription {
  /// Creates a subscription handle.
  ParsedTransactionSubscription({
    required this.notifications,
    required int? Function() subscriptionId,
    required this.unsubscribe,
  }) : _subscriptionId = subscriptionId; // ignore: prefer_initializing_formals

  /// Notifications delivered for this subscription.
  final Stream<ParsedTransactionNotification> notifications;

  final int? Function() _subscriptionId;

  /// Current server-assigned id, which changes after a reconnect.
  int? get subscriptionId => _subscriptionId();

  /// Stops the subscription. Resolves `true` if the server confirmed it.
  final Future<bool> Function() unsubscribe;
}
