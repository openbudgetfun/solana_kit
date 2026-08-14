import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_transaction_introspection/src/loaded_addresses.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';
import 'package:solana_kit_transactions/solana_kit_transactions.dart';

/// The result of decoding a `getTransaction` response: the
/// [CompiledTransactionMessage] (always carrying a `lifetimeToken`), the loaded
/// ALT addresses pulled from `meta` (if any), and — for `'base64'` and
/// `'base58'` responses — the wire-format [Transaction].
///
/// `transaction` is `null` for `encoding: 'json'` responses: the server has
/// already decompiled the wire format, so there are no message bytes to
/// round-trip. If you need a re-encodable [Transaction], fetch the response
/// with `encoding: 'base64'`.
class DecodedRpcTransaction {
  /// Creates a [DecodedRpcTransaction].
  const DecodedRpcTransaction({
    required this.compiledMessage,
    required this.loadedAddresses,
    this.transaction,
  });

  /// The decoded compiled transaction message.
  final CompiledTransactionMessage compiledMessage;

  /// The loaded ALT addresses pulled from `meta.loadedAddresses`, if any.
  final LoadedAddresses loadedAddresses;

  /// The wire-format transaction, for `'base64'` and `'base58'` responses.
  /// `null` for `'json'` responses.
  final Transaction? transaction;
}

const _emptyLoadedAddresses = LoadedAddresses();

Map<String, Object?>? _asMap(Object? v) =>
    v is Map ? Map<String, Object?>.from(v) : null;

List<Object?> _asList(Object? v) => v is List ? v : const [];

int? _asInt(Object? v) => v is int ? v : null;

String? _asString(Object? v) => v is String ? v : null;

List<Address> _addressList(Object? v) =>
    _asList(v).whereType<String>().map(Address.new).toList();

List<int> _intList(Object? v) => _asList(v).whereType<int>().toList();

LoadedAddresses _getLoadedAddresses(Map<String, Object?>? meta) {
  final loaded = _asMap(meta?['loadedAddresses']);
  if (loaded == null) return _emptyLoadedAddresses;
  return LoadedAddresses(
    readonly: _addressList(loaded['readonly']),
    writable: _addressList(loaded['writable']),
  );
}

({CompiledTransactionMessage compiledMessage, Transaction transaction})
_decodeFromWire(Uint8List wireBytes) {
  final transaction = getTransactionDecoder().decode(wireBytes);
  final compiledMessage = getCompiledTransactionMessageDecoder().decode(
    transaction.messageBytes,
  );
  return (compiledMessage: compiledMessage, transaction: transaction);
}

DecodedRpcTransaction _decodeFromBase64(
  List<Object?> tx,
  Map<String, Object?>? meta,
) {
  final b64 = _asString(tx[0]);
  if (b64 == null) {
    throw SolanaError(
      SolanaErrorCode
          .transactionIntrospectionUnrecognizedGetTransactionResponse,
    );
  }
  final wire = getBase64Encoder().encode(b64);
  final (:compiledMessage, :transaction) = _decodeFromWire(wire);
  return DecodedRpcTransaction(
    compiledMessage: compiledMessage,
    loadedAddresses: _getLoadedAddresses(meta),
    transaction: transaction,
  );
}

DecodedRpcTransaction _decodeFromBase58(
  List<Object?> tx,
  Map<String, Object?>? meta,
) {
  final b58 = _asString(tx[0]);
  if (b58 == null) {
    throw SolanaError(
      SolanaErrorCode
          .transactionIntrospectionUnrecognizedGetTransactionResponse,
    );
  }
  final wire = getBase58Encoder().encode(b58);
  final (:compiledMessage, :transaction) = _decodeFromWire(wire);
  return DecodedRpcTransaction(
    compiledMessage: compiledMessage,
    loadedAddresses: _getLoadedAddresses(meta),
    transaction: transaction,
  );
}

MessageHeader _readJsonHeader(Map<String, Object?> header) {
  final numSignerAccounts = _asInt(header['numRequiredSignatures']);
  final numReadonlySignerAccounts = _asInt(header['numReadonlySignedAccounts']);
  final numReadonlyNonSignerAccounts = _asInt(
    header['numReadonlyUnsignedAccounts'],
  );
  if (numSignerAccounts == null ||
      numReadonlySignerAccounts == null ||
      numReadonlyNonSignerAccounts == null) {
    throw SolanaError(
      SolanaErrorCode
          .transactionIntrospectionUnrecognizedGetTransactionResponse,
    );
  }
  return MessageHeader(
    numSignerAccounts: numSignerAccounts,
    numReadonlySignerAccounts: numReadonlySignerAccounts,
    numReadonlyNonSignerAccounts: numReadonlyNonSignerAccounts,
  );
}

List<CompiledInstruction> _readJsonInstructions(
  List<Object?> rawInstructions,
) {
  final base58 = getBase58Encoder();
  return rawInstructions.map((raw) {
    final ix = _asMap(raw);
    if (ix == null) {
      throw SolanaError(
        SolanaErrorCode
            .transactionIntrospectionUnrecognizedGetTransactionResponse,
      );
    }
    final programAddressIndex = _asInt(ix['programIdIndex']);
    if (programAddressIndex == null) {
      throw SolanaError(
        SolanaErrorCode
            .transactionIntrospectionUnrecognizedGetTransactionResponse,
      );
    }
    final accounts = _intList(ix['accounts']);
    final dataString = _asString(ix['data']);
    final data = dataString == null ? Uint8List(0) : base58.encode(dataString);
    return CompiledInstruction(
      programAddressIndex: programAddressIndex,
      accountIndices: accounts.isEmpty ? null : accounts,
      data: data.isEmpty ? null : data,
    );
  }).toList();
}

DecodedRpcTransaction _decodeFromJson(
  Map<String, Object?> message,
  Map<String, Object?>? meta,
  Object? version,
) {
  final headerRaw = _asMap(message['header']);
  if (headerRaw == null) {
    throw SolanaError(
      SolanaErrorCode
          .transactionIntrospectionUnrecognizedGetTransactionResponse,
    );
  }
  final header = _readJsonHeader(headerRaw);
  final staticAccounts = _addressList(message['accountKeys']);
  final instructionsRaw = _asList(message['instructions']);
  if (instructionsRaw.isEmpty && message['instructions'] is! List) {
    throw SolanaError(
      SolanaErrorCode
          .transactionIntrospectionUnrecognizedGetTransactionResponse,
    );
  }
  final instructions = _readJsonInstructions(instructionsRaw);
  final lifetimeToken = _asString(message['recentBlockhash']);
  if (lifetimeToken == null) {
    throw SolanaError(
      SolanaErrorCode
          .transactionIntrospectionUnrecognizedGetTransactionResponse,
    );
  }

  TransactionVersion resolvedVersion;
  if (version == 0) {
    resolvedVersion = TransactionVersion.v0;
  } else if (version == 1) {
    resolvedVersion = TransactionVersion.v1;
  } else {
    resolvedVersion = TransactionVersion.legacy;
  }

  final compiledMessage = switch (resolvedVersion) {
    TransactionVersion.legacy => CompiledTransactionMessage(
      version: TransactionVersion.legacy,
      header: header,
      staticAccounts: staticAccounts,
      instructions: instructions,
      lifetimeToken: lifetimeToken,
    ),
    TransactionVersion.v0 => () {
      final lookups = <AddressTableLookup>[];
      for (final lookup in _asList(message['addressTableLookups'])) {
        final l = _asMap(lookup);
        final accountKey = l == null ? null : _asString(l['accountKey']);
        if (accountKey == null) continue;
        lookups.add(
          AddressTableLookup(
            lookupTableAddress: Address(accountKey),
            writableIndexes: _intList(l!['writableIndexes']),
            readonlyIndexes: _intList(l['readonlyIndexes']),
          ),
        );
      }
      return CompiledTransactionMessage(
        version: TransactionVersion.v0,
        header: header,
        staticAccounts: staticAccounts,
        instructions: instructions,
        lifetimeToken: lifetimeToken,
        addressTableLookups: lookups.isEmpty ? null : lookups,
      );
    }(),
    TransactionVersion.v1 => () {
      final base58 = getBase58Encoder();
      final instructionHeaders = <V1InstructionHeader>[];
      final instructionPayloads = <V1InstructionPayload>[];
      for (final raw in instructionsRaw) {
        final ix = _asMap(raw);
        final programAccountIndex = ix == null
            ? null
            : _asInt(ix['programIdIndex']);
        if (programAccountIndex == null) continue;
        final accounts = _intList(ix!['accounts']);
        final dataString = _asString(ix['data']);
        final data = dataString == null
            ? Uint8List(0)
            : base58.encode(dataString);
        instructionHeaders.add(
          V1InstructionHeader(
            programAccountIndex: programAccountIndex,
            numInstructionAccounts: accounts.length,
            numInstructionDataBytes: data.length,
          ),
        );
        instructionPayloads.add(
          V1InstructionPayload(
            instructionAccountIndices: accounts,
            instructionData: data,
          ),
        );
      }
      return CompiledTransactionMessage(
        version: TransactionVersion.v1,
        header: header,
        staticAccounts: staticAccounts,
        instructions: const [],
        lifetimeToken: lifetimeToken,
        configMask: 0,
        configValues: const [],
        instructionHeaders: instructionHeaders,
        instructionPayloads: instructionPayloads,
        numInstructions: instructionHeaders.length,
        numStaticAccounts: staticAccounts.length,
      );
    }(),
  };

  return DecodedRpcTransaction(
    compiledMessage: compiledMessage,
    loadedAddresses: _getLoadedAddresses(meta),
  );
}

/// Decodes a `getTransaction` response (any of `encoding: 'base64'`,
/// `'base58'`, or `'json'`) into a [DecodedRpcTransaction].
///
/// `'jsonParsed'` is **not** supported — its instructions arrive pre-parsed by
/// the server and lack raw bytes, so they cannot be round-tripped through the
/// auto-generated `parseXInstruction` clients. Passing a `'jsonParsed'`
/// response throws a [SolanaError] with code
/// `transactionIntrospectionCannotDecodeJsonParsedTransaction`; any other
/// unrecognized input throws with code
/// `transactionIntrospectionUnrecognizedGetTransactionResponse`.
///
/// Use this together with `getInstructionsFromCompiledTransactionMessage` (or
/// `walkInstructions`) to inspect a confirmed transaction's instructions in a
/// form the auto-generated `@solana-program/*` clients can `parse` directly.
///
/// Prefer `encoding: 'base64'` when bandwidth allows — it is the most
/// compact, the wire bytes round-trip cleanly through the kit codecs, and the
/// returned `transaction` is re-encodable.
DecodedRpcTransaction decodeTransactionFromRpcResponse(
  Map<String, Object?>? rpcTx,
) {
  if (rpcTx == null) {
    throw SolanaError(
      SolanaErrorCode
          .transactionIntrospectionUnrecognizedGetTransactionResponse,
    );
  }
  final tx = rpcTx['transaction'];
  final metaRaw = rpcTx['meta'];
  final meta = metaRaw is Map<String, Object?> ? metaRaw : _asMap(metaRaw);

  // base64 / base58: `transaction` is a `[data, encoding]` array.
  if (tx is List) {
    if (tx.length >= 2 && tx[1] == 'base64') return _decodeFromBase64(tx, meta);
    if (tx.length >= 2 && tx[1] == 'base58') return _decodeFromBase58(tx, meta);
    throw SolanaError(
      SolanaErrorCode
          .transactionIntrospectionUnrecognizedGetTransactionResponse,
    );
  }

  // json / jsonParsed: `transaction` is a `{message: ...}` map.
  final txMap = _asMap(tx);
  final messageMap = _asMap(txMap?['message']);
  if (messageMap == null) {
    throw SolanaError(
      SolanaErrorCode
          .transactionIntrospectionUnrecognizedGetTransactionResponse,
    );
  }
  // jsonParsed responses have no `header` — the server has already resolved
  // roles onto each `accountKey` and pre-parsed the instructions, so they
  // cannot be round-tripped through the kit codecs.
  if (_asMap(messageMap['header']) == null) {
    throw SolanaError(
      SolanaErrorCode.transactionIntrospectionCannotDecodeJsonParsedTransaction,
    );
  }
  final version = rpcTx.containsKey('version') ? rpcTx['version'] : null;
  return _decodeFromJson(messageMap, meta, version);
}
