// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_transaction_introspection/solana_kit_transaction_introspection.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';
import 'package:test/test.dart';

import 'test_helpers.dart';

void main() {
  group('getAccountMetasFromCompiledTransactionMessage', () {
    test('derives static account roles from the header', () {
      // 3 static accounts: writableSigner, readonlySigner, writable.
      final message = CompiledTransactionMessage(
        version: TransactionVersion.legacy,
        header: MessageHeader(
          numSignerAccounts: 2,
          numReadonlySignerAccounts: 1,
          numReadonlyNonSignerAccounts: 0,
        ),
        staticAccounts: const [
          Address(systemProgram),
          Address(feePayer),
          Address(tokenProgram),
        ],
        instructions: const [],
        lifetimeToken: blockhash,
      );
      final metas = getAccountMetasFromCompiledTransactionMessage(message);
      expect(metas[0].role, AccountRole.writableSigner);
      expect(metas[1].role, AccountRole.readonlySigner);
      expect(metas[2].role, AccountRole.writable);
    });

    test('appends ALT-loaded accounts after static accounts', () {
      final message = CompiledTransactionMessage(
        version: TransactionVersion.v0,
        header: MessageHeader(
          numSignerAccounts: 1,
          numReadonlySignerAccounts: 0,
          numReadonlyNonSignerAccounts: 1,
        ),
        staticAccounts: const [Address(systemProgram), Address(feePayer)],
        instructions: const [],
        lifetimeToken: blockhash,
      );
      final metas = getAccountMetasFromCompiledTransactionMessage(
        message,
        loadedAddresses: LoadedAddresses(
          writable: const [Address(tokenProgram)],
          readonly: const [Address(systemProgram)],
        ),
      );
      expect(metas.length, 4);
      expect(metas[2].address, const Address(tokenProgram));
      expect(metas[2].role, AccountRole.writable);
      expect(metas[3].role, AccountRole.readonly);
    });
  });

  group('getInstructionsFromCompiledTransactionMessage', () {
    test('resolves a legacy instruction', () {
      final message = CompiledTransactionMessage(
        version: TransactionVersion.legacy,
        header: MessageHeader(
          numSignerAccounts: 1,
          numReadonlySignerAccounts: 0,
          numReadonlyNonSignerAccounts: 0,
        ),
        staticAccounts: const [Address(systemProgram), Address(tokenProgram)],
        instructions: [
          CompiledInstruction(
            programAddressIndex: 0,
            accountIndices: const [1],
            data: Uint8List.fromList([9]),
          ),
        ],
        lifetimeToken: blockhash,
      );
      final instructions = getInstructionsFromCompiledTransactionMessage(
        message,
      );
      expect(instructions, hasLength(1));
      expect(instructions.first.programAddress, const Address(systemProgram));
      expect(
        instructions.first.accounts!.first.address,
        const Address(tokenProgram),
      );
      expect(instructions.first.data, Uint8List.fromList([9]));
    });

    test('omits empty accounts and data', () {
      final message = CompiledTransactionMessage(
        version: TransactionVersion.legacy,
        header: MessageHeader(
          numSignerAccounts: 1,
          numReadonlySignerAccounts: 0,
          numReadonlyNonSignerAccounts: 0,
        ),
        staticAccounts: const [Address(systemProgram)],
        instructions: [
          CompiledInstruction(programAddressIndex: 0),
        ],
        lifetimeToken: blockhash,
      );
      final instructions = getInstructionsFromCompiledTransactionMessage(
        message,
      );
      expect(instructions.first.accounts, isNull);
      expect(instructions.first.data, isNull);
    });

    test('resolves a v1 instruction from headers and payloads', () {
      final message = CompiledTransactionMessage(
        version: TransactionVersion.v1,
        header: MessageHeader(
          numSignerAccounts: 1,
          numReadonlySignerAccounts: 0,
          numReadonlyNonSignerAccounts: 0,
        ),
        staticAccounts: const [Address(systemProgram), Address(tokenProgram)],
        instructions: const [],
        lifetimeToken: blockhash,
        configMask: 0,
        configValues: const [],
        instructionHeaders: [
          V1InstructionHeader(
            programAccountIndex: 0,
            numInstructionAccounts: 1,
            numInstructionDataBytes: 1,
          ),
        ],
        instructionPayloads: [
          V1InstructionPayload(
            instructionAccountIndices: const [1],
            instructionData: Uint8List.fromList([5]),
          ),
        ],
        numInstructions: 1,
        numStaticAccounts: 2,
      );
      final instructions = getInstructionsFromCompiledTransactionMessage(
        message,
      );
      expect(instructions, hasLength(1));
      expect(instructions.first.programAddress, const Address(systemProgram));
      expect(
        instructions.first.accounts!.first.address,
        const Address(tokenProgram),
      );
    });

    test('throws on v1 header/payload length mismatch', () {
      final message = CompiledTransactionMessage(
        version: TransactionVersion.v1,
        header: MessageHeader(
          numSignerAccounts: 1,
          numReadonlySignerAccounts: 0,
          numReadonlyNonSignerAccounts: 0,
        ),
        staticAccounts: const [Address(systemProgram)],
        instructions: const [],
        lifetimeToken: blockhash,
        instructionHeaders: const [],
        instructionPayloads: [
          V1InstructionPayload(
            instructionAccountIndices: const [],
            instructionData: Uint8List(0),
          ),
        ],
      );
      expect(
        () => getInstructionsFromCompiledTransactionMessage(message),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.transactionInstructionHeadersPayloadsMismatch,
          ),
        ),
      );
    });

    test('throws when a programAddressIndex is out of range', () {
      final message = CompiledTransactionMessage(
        version: TransactionVersion.legacy,
        header: MessageHeader(
          numSignerAccounts: 1,
          numReadonlySignerAccounts: 0,
          numReadonlyNonSignerAccounts: 0,
        ),
        staticAccounts: const [Address(systemProgram)],
        instructions: [CompiledInstruction(programAddressIndex: 5)],
        lifetimeToken: blockhash,
      );
      expect(
        () => getInstructionsFromCompiledTransactionMessage(message),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode
                .transactionFailedToDecompileInstructionProgramAddressNotFound,
          ),
        ),
      );
    });

    test('throws when an account index is out of range', () {
      final message = CompiledTransactionMessage(
        version: TransactionVersion.legacy,
        header: MessageHeader(
          numSignerAccounts: 1,
          numReadonlySignerAccounts: 0,
          numReadonlyNonSignerAccounts: 0,
        ),
        staticAccounts: const [Address(systemProgram)],
        instructions: [
          CompiledInstruction(
            programAddressIndex: 0,
            accountIndices: const [9],
          ),
        ],
        lifetimeToken: blockhash,
      );
      expect(
        () => getInstructionsFromCompiledTransactionMessage(message),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode
                .transactionFailedToDecompileInstructionAccountIndexOutOfRange,
          ),
        ),
      );
    });
  });

  group('getInnerInstructionsFromMeta', () {
    final metas = [
      AccountMeta(
        address: const Address(systemProgram),
        role: AccountRole.writable,
      ),
      AccountMeta(
        address: const Address(tokenProgram),
        role: AccountRole.readonly,
      ),
    ];

    test('resolves inner instructions with inner traces and stackHeight', () {
      // '2' base58-decodes to a single non-empty byte, so `data` is present.
      final meta = <String, Object?>{
        'innerInstructions': [
          {
            'index': 0,
            'instructions': [
              {
                'accounts': const <int>[1],
                'data': '2',
                'programIdIndex': 0,
                'stackHeight': 2,
              },
            ],
          },
        ],
      };
      final inner = getInnerInstructionsFromMeta(meta, metas);
      expect(inner, hasLength(1));
      final trace = inner.first.trace;
      expect(trace, isA<InnerInstructionTrace>());
      trace as InnerInstructionTrace;
      expect(trace.outerIndex, 0);
      expect(trace.innerIndex, 0);
      expect(trace.stackHeight, 2);
      expect(inner.first.programAddress, const Address(systemProgram));
      expect(inner.first.accounts!.first.address, const Address(tokenProgram));
      expect(inner.first.data, isNotNull);
    });

    test('returns empty for a meta with no innerInstructions', () {
      expect(getInnerInstructionsFromMeta(null, metas), isEmpty);
      expect(getInnerInstructionsFromMeta(<String, Object?>{}, metas), isEmpty);
    });

    test('throws when a programIdIndex is out of range', () {
      final meta = <String, Object?>{
        'innerInstructions': [
          {
            'index': 0,
            'instructions': [
              {'accounts': const <int>[], 'data': '', 'programIdIndex': 9},
            ],
          },
        ],
      };
      expect(
        () => getInnerInstructionsFromMeta(meta, metas),
        throwsA(isA<SolanaError>()),
      );
    });

    test('throws when an inner account index is out of range', () {
      final meta = <String, Object?>{
        'innerInstructions': [
          {
            'index': 0,
            'instructions': [
              {
                'accounts': const <int>[9],
                'data': '2',
                'programIdIndex': 0,
              },
            ],
          },
        ],
      };
      expect(
        () => getInnerInstructionsFromMeta(meta, metas),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode
                .transactionFailedToDecompileInstructionAccountIndexOutOfRange,
          ),
        ),
      );
    });

    test('rejects malformed inner-instruction entries', () {
      final malformed = <Map<String, Object?>>[
        {
          'innerInstructions': [42],
        },
        {
          'innerInstructions': [
            {
              'index': 0,
              'instructions': [42],
            },
          ],
        },
        {
          'innerInstructions': [
            {
              'index': 0,
              'instructions': [
                {
                  'accounts': const <Object?>[0, '1'],
                  'data': '2',
                  'programIdIndex': 0,
                },
              ],
            },
          ],
        },
      ];

      for (final meta in malformed) {
        expect(
          () => getInnerInstructionsFromMeta(meta, metas),
          throwsA(isA<SolanaError>()),
        );
      }
    });
  });

  group('walkInstructions', () {
    test('interleaves outer instructions with their inner groups', () {
      final message = CompiledTransactionMessage(
        version: TransactionVersion.legacy,
        header: MessageHeader(
          numSignerAccounts: 1,
          numReadonlySignerAccounts: 0,
          numReadonlyNonSignerAccounts: 0,
        ),
        staticAccounts: const [Address(systemProgram), Address(tokenProgram)],
        instructions: [
          CompiledInstruction(programAddressIndex: 0),
          CompiledInstruction(programAddressIndex: 1),
        ],
        lifetimeToken: blockhash,
      );
      final meta = <String, Object?>{
        'innerInstructions': [
          {
            'index': 1,
            'instructions': [
              {
                'accounts': const <int>[0],
                'data': '2',
                'programIdIndex': 0,
              },
            ],
          },
        ],
      };
      final traced = walkInstructions(compiledMessage: message, meta: meta);
      // outer[0], outer[1], inner[outerIndex=1]
      expect(traced, hasLength(3));
      expect((traced[0].trace as OuterInstructionTrace).index, 0);
      expect((traced[1].trace as OuterInstructionTrace).index, 1);
      expect(traced[2].trace, isA<InnerInstructionTrace>());
    });

    test('returns only outer instructions when meta is null', () {
      final message = CompiledTransactionMessage(
        version: TransactionVersion.legacy,
        header: MessageHeader(
          numSignerAccounts: 1,
          numReadonlySignerAccounts: 0,
          numReadonlyNonSignerAccounts: 0,
        ),
        staticAccounts: const [Address(systemProgram)],
        instructions: [CompiledInstruction(programAddressIndex: 0)],
        lifetimeToken: blockhash,
      );
      final traced = walkInstructions(compiledMessage: message);
      expect(traced, hasLength(1));
      expect(traced.first.trace, isA<OuterInstructionTrace>());
    });

    test('rejects inner groups whose index matches no outer instruction', () {
      final message = CompiledTransactionMessage(
        version: TransactionVersion.legacy,
        header: MessageHeader(
          numSignerAccounts: 1,
          numReadonlySignerAccounts: 0,
          numReadonlyNonSignerAccounts: 0,
        ),
        staticAccounts: const [Address(systemProgram)],
        instructions: [CompiledInstruction(programAddressIndex: 0)],
        lifetimeToken: blockhash,
      );
      final meta = <String, Object?>{
        'innerInstructions': [
          {
            'index': 9,
            'instructions': [
              {
                'accounts': const <int>[0],
                'data': '2',
                'programIdIndex': 0,
              },
            ],
          },
        ],
      };
      expect(
        () => walkInstructions(compiledMessage: message, meta: meta),
        throwsA(isA<SolanaError>()),
      );
    });
  });
}
