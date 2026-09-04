import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';
import 'package:test/test.dart';

const _payer = Address('7EqQdEULxWcraVx3mXKFjc84LhCkMGZCkRuDpvcMwJeK');
const _program = Address('11111111111111111111111111111111');
const _recipient = Address('HZMKVnRrWLyQLwPLTTLKtY7ET4Cf7pQugrTr9eTBrpsf');
const _blockhash = 'J4yED2jcMAHyQUg61DBmm4njmEydUr2WqrV9cdEcDDgL';

void main() {
  group('v1 transaction inspection security', () {
    for (final config in <V1TransactionConfig?>[
      null,
      V1TransactionConfig(priorityFeeLamports: BigInt.from(1000000000)),
      const V1TransactionConfig(computeUnitLimit: 200000),
      const V1TransactionConfig(loadedAccountsDataSizeLimit: 64000000),
      const V1TransactionConfig(heapSize: 32768),
      V1TransactionConfig(
        priorityFeeLamports: BigInt.from(1000000000),
        computeUnitLimit: 200000,
        loadedAccountsDataSizeLimit: 64000000,
        heapSize: 32768,
      ),
    ]) {
      test('preserves encoded instructions and config $config', () {
        final source = TransactionMessage(
          version: TransactionVersion.v1,
          feePayer: _payer,
          lifetimeConstraint: BlockhashLifetimeConstraint(
            blockhash: _blockhash,
            lastValidBlockHeight: BigInt.from(100),
          ),
          config: config,
          instructions: [
            Instruction(
              programAddress: _program,
              accounts: const [
                AccountMeta(address: _payer, role: AccountRole.writableSigner),
                AccountMeta(address: _recipient, role: AccountRole.writable),
              ],
              data: Uint8List.fromList([2, 0, 0, 0, 255, 255, 255, 255]),
            ),
            const Instruction(programAddress: _program),
          ],
        );
        final codec = getCompiledTransactionMessageCodec();
        final wire = codec.encode(compileTransactionMessage(source));
        final decoded = codec.decode(wire);
        final preview = decompileTransactionMessage(decoded);

        // A wallet or instruction allowlist must see the instructions that
        // will be executed, including a large priority fee in the config.
        expect(preview.instructions, source.instructions);
        expect(preview.version, TransactionVersion.v1);
        expect(preview.config, source.config);
        expect(codec.encode(compileTransactionMessage(preview)), wire);
      });
    }

    test('rejects mismatched v1 instruction header and payload lists', () {
      expect(
        () => decompileTransactionMessage(
          const CompiledTransactionMessage(
            version: TransactionVersion.v1,
            header: MessageHeader(
              numSignerAccounts: 1,
              numReadonlySignerAccounts: 0,
              numReadonlyNonSignerAccounts: 1,
            ),
            staticAccounts: [_payer, _program],
            instructions: [],
            instructionHeaders: [
              V1InstructionHeader(
                programAccountIndex: 1,
                numInstructionAccounts: 0,
                numInstructionDataBytes: 0,
              ),
            ],
            instructionPayloads: [],
          ),
        ),
        throwsA(
          isA<SolanaError>().having(
            (error) => error.code,
            'code',
            SolanaErrorCode.transactionInstructionHeadersPayloadsMismatch,
          ),
        ),
      );
    });
    test('preserves an empty v1 message without optional compiled fields', () {
      final message = decompileTransactionMessage(_compiledMessage());
      expect(message.version, TransactionVersion.v1);
      expect(message.instructions, isEmpty);
      expect(message.config, isNull);
    });

    for (final header in const [
      V1InstructionHeader(
        programAccountIndex: 1,
        numInstructionAccounts: 1,
        numInstructionDataBytes: 0,
      ),
      V1InstructionHeader(
        programAccountIndex: 1,
        numInstructionAccounts: 0,
        numInstructionDataBytes: 1,
      ),
    ]) {
      test('rejects v1 payload length mismatch $header', () {
        expect(
          () => decompileTransactionMessage(
            _compiledMessage(
              headers: [header],
              payloads: [
                V1InstructionPayload(
                  instructionAccountIndices: const [],
                  instructionData: Uint8List(0),
                ),
              ],
            ),
          ),
          throwsFormatException,
        );
      });
    }

    test('rejects a missing config value instead of hiding its fee', () {
      expect(
        () => decompileTransactionMessage(_compiledMessage(mask: 3)),
        throwsFormatException,
      );
    });

    test('rejects extra config values instead of silently discarding them', () {
      expect(
        () => decompileTransactionMessage(
          _compiledMessage(
            values: [CompiledTransactionConfigValue.u64(BigInt.one)],
          ),
        ),
        throwsFormatException,
      );
    });

    for (final value in const [
      CompiledTransactionConfigValue.u32(1),
      CompiledTransactionConfigValue.raw(kind: 'u64', value: 1),
    ]) {
      test('rejects incorrect priority fee value $value', () {
        expect(
          () => decompileTransactionMessage(
            _compiledMessage(
              mask: 3,
              values: [value],
            ),
          ),
          throwsA(
            isA<SolanaError>().having(
              (error) => error.code,
              'code',
              SolanaErrorCode.transactionInvalidConfigValueKind,
            ),
          ),
        );
      });
    }
  });
}

CompiledTransactionMessage _compiledMessage({
  int? mask,
  List<CompiledTransactionConfigValue>? values,
  List<V1InstructionHeader>? headers,
  List<V1InstructionPayload>? payloads,
}) => CompiledTransactionMessage(
  version: TransactionVersion.v1,
  header: const MessageHeader(
    numSignerAccounts: 1,
    numReadonlySignerAccounts: 0,
    numReadonlyNonSignerAccounts: 1,
  ),
  staticAccounts: const [_payer, _program],
  instructions: const [],
  configMask: mask,
  configValues: values,
  instructionHeaders: headers,
  instructionPayloads: payloads,
);
