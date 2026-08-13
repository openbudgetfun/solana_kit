// ignore_for_file: prefer_const_constructors, unnecessary_const
import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_transaction_introspection/solana_kit_transaction_introspection.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';
import 'package:test/test.dart';

import 'test_helpers.dart';

void main() {
  group('decodeTransactionFromRpcResponse (base58/base64)', () {
    test('round-trips a legacy base58 response', () {
      final message = legacyMessage(
        staticAccounts: const [Address(systemProgram)],
        instructions: [
          CompiledInstruction(
            programAddressIndex: 0,
            accountIndices: const [0],
            data: Uint8List.fromList([1, 2, 3]),
          ),
        ],
      );
      final wire = encodeWire(message);
      final rpcTx = <String, Object?>{
        'transaction': [base58String(wire), 'base58'],
        'meta': null,
      };
      final decoded = decodeTransactionFromRpcResponse(rpcTx);
      expect(decoded.compiledMessage.version, TransactionVersion.legacy);
      expect(
        decoded.compiledMessage.staticAccounts,
        equals(const [Address(systemProgram)]),
      );
      expect(decoded.compiledMessage.lifetimeToken, blockhash);
      expect(decoded.compiledMessage.instructions, hasLength(1));
      expect(decoded.compiledMessage.instructions.first.programAddressIndex, 0);
      expect(decoded.transaction, isNotNull);
      expect(decoded.loadedAddresses, const LoadedAddresses());
    });

    test(
      'round-trips a legacy base64 response and surfaces loaded addresses',
      () {
        final message = legacyMessage(
          staticAccounts: const [Address(systemProgram)],
        );
        final wire = encodeWire(message);
        final rpcTx = <String, Object?>{
          'transaction': [base64String(wire), 'base64'],
          'meta': {
            'loadedAddresses': {
              'readonly': const <String>[tokenProgram],
              'writable': const <String>[systemProgram],
            },
          },
        };
        final decoded = decodeTransactionFromRpcResponse(rpcTx);
        expect(decoded.compiledMessage.version, TransactionVersion.legacy);
        expect(decoded.transaction, isNotNull);
        expect(decoded.loadedAddresses.writable, [
          Address(systemProgram),
        ]);
        expect(decoded.loadedAddresses.readonly, [Address(tokenProgram)]);
      },
    );

    test('throws for an unrecognized array encoding', () {
      final rpcTx = <String, Object?>{
        'transaction': ['deadbeef', 'hex'],
        'meta': null,
      };
      expect(
        () => decodeTransactionFromRpcResponse(rpcTx),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode
                .transactionIntrospectionUnrecognizedGetTransactionResponse,
          ),
        ),
      );
    });
  });

  group('decodeTransactionFromRpcResponse (json)', () {
    test('decodes a legacy json response', () {
      final rpcTx = <String, Object?>{
        'transaction': {
          'message': {
            'header': {
              'numRequiredSignatures': 1,
              'numReadonlySignedAccounts': 0,
              'numReadonlyUnsignedAccounts': 1,
            },
            'accountKeys': const <String>[feePayer, systemProgram],
            'instructions': const <Object?>[
              {
                'accounts': const <int>[1],
                'data': '2',
                'programIdIndex': 1,
              },
            ],
            'recentBlockhash': blockhash,
          },
        },
      };
      final decoded = decodeTransactionFromRpcResponse(rpcTx);
      expect(decoded.compiledMessage.version, TransactionVersion.legacy);
      expect(
        decoded.compiledMessage.staticAccounts,
        [Address(feePayer), Address(systemProgram)],
      );
      expect(decoded.compiledMessage.lifetimeToken, blockhash);
      expect(decoded.compiledMessage.instructions, hasLength(1));
      expect(decoded.compiledMessage.instructions.first.programAddressIndex, 1);
      expect(decoded.transaction, isNull);
    });

    test('decodes a v0 json response with address table lookups', () {
      final rpcTx = <String, Object?>{
        'version': 0,
        'transaction': {
          'message': {
            'header': {
              'numRequiredSignatures': 1,
              'numReadonlySignedAccounts': 0,
              'numReadonlyUnsignedAccounts': 0,
            },
            'accountKeys': const <String>[feePayer],
            'instructions': const <Object?>[],
            'recentBlockhash': blockhash,
            'addressTableLookups': const <Object?>[
              {
                'accountKey': systemProgram,
                'writableIndexes': const <int>[0],
                'readonlyIndexes': const <int>[1],
              },
            ],
          },
        },
      };
      final decoded = decodeTransactionFromRpcResponse(rpcTx);
      expect(decoded.compiledMessage.version, TransactionVersion.v0);
      expect(decoded.compiledMessage.addressTableLookups, hasLength(1));
      expect(
        decoded.compiledMessage.addressTableLookups!.first.lookupTableAddress,
        Address(systemProgram),
      );
    });

    test('decodes a v1 json response with instruction headers/payloads', () {
      final rpcTx = <String, Object?>{
        'version': 1,
        'transaction': {
          'message': {
            'header': {
              'numRequiredSignatures': 1,
              'numReadonlySignedAccounts': 0,
              'numReadonlyUnsignedAccounts': 0,
            },
            'accountKeys': const <String>[feePayer],
            'instructions': const <Object?>[
              {
                'accounts': const <int>[0],
                'data': '2',
                'programIdIndex': 0,
              },
            ],
            'recentBlockhash': blockhash,
          },
        },
      };
      final decoded = decodeTransactionFromRpcResponse(rpcTx);
      expect(decoded.compiledMessage.version, TransactionVersion.v1);
      expect(decoded.compiledMessage.instructionHeaders, hasLength(1));
      expect(
        decoded.compiledMessage.instructionHeaders!.first.programAccountIndex,
        0,
      );
      expect(decoded.compiledMessage.instructionPayloads, hasLength(1));
      expect(decoded.compiledMessage.numInstructions, 1);
      expect(decoded.compiledMessage.configMask, 0);
    });

    test('rejects a jsonParsed response', () {
      final rpcTx = <String, Object?>{
        'transaction': {
          'message': {
            'accountKeys': const <String>[feePayer],
            'instructions': const <Object?>[
              {'programId': systemProgram, 'accounts': const <String>[]},
            ],
          },
        },
      };
      expect(
        () => decodeTransactionFromRpcResponse(rpcTx),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode
                .transactionIntrospectionCannotDecodeJsonParsedTransaction,
          ),
        ),
      );
    });

    test('throws for an unrecognized response shape', () {
      expect(
        () => decodeTransactionFromRpcResponse(null),
        throwsA(isA<SolanaError>()),
      );
      expect(
        () => decodeTransactionFromRpcResponse({'transaction': 42}),
        throwsA(isA<SolanaError>()),
      );
      expect(
        () => decodeTransactionFromRpcResponse({
          'transaction': {'noMessage': true},
        }),
        throwsA(isA<SolanaError>()),
      );
    });
  });
}
