import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_attestation_service/solana_kit_attestation_service.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_programs/solana_kit_programs.dart';
import 'package:test/test.dart';

const Address program = solanaAttestationServiceProgramAddress;
const otherProgram = Address('11111111111111111111111111111111');

Uint8List content(List<int> bytes) => Uint8List.fromList(bytes);

Schema makeSchema(List<SchemaDataType> layout, List<String> fieldNames) {
  final fieldNamesBytes = <int>[];
  for (final name in fieldNames) {
    final length = name.length;
    fieldNamesBytes.addAll([length, 0, 0, 0, ...name.codeUnits]);
  }

  return Schema(
    discriminator: 1,
    credential: otherProgram,
    name: content([0]),
    description: content([0]),
    layout: content(layout.map((type) => type.index).toList()),
    fieldNames: Uint8List.fromList(fieldNamesBytes),
    isPaused: false,
    version: 1,
  );
}

void main() {
  group('blob decoding', () {
    test('decodes malformed utf-8 text as replacement characters', () {
      expect(
        decodeSchemaText(content([0xff, 0xfe])),
        equals('\u{FFFD}\u{FFFD}'),
      );
    });

    test('rejects a field-names blob with dangling bytes', () {
      // 'name' is 4 bytes but the inner prefix promises 8.
      expect(
        () => decodeSchemaFieldNames(
          content([8, 0, 0, 0, 110, 97, 109, 101]),
        ),
        throwsA(anything),
      );
    });

    test('rejects an unknown layout discriminant', () {
      expect(
        () => decodeSchemaLayout(content([26])),
        throwsFormatException,
      );
      expect(
        () => decodeSchemaLayout(content([255])),
        throwsFormatException,
      );
    });
  });

  group('attestation data validation', () {
    test('rejects struct data with a missing field on encode', () {
      final schema = makeSchema([SchemaDataType.u8], ['count']);

      expect(
        () => serializeAttestationData(schema, {'other': 1}),
        throwsA(anything),
      );
    });

    test('rejects truncated attestation data on decode', () {
      final schema = makeSchema([SchemaDataType.string], ['id']);

      expect(
        () => deserializeAttestationData(
          schema,
          Uint8List.fromList([5, 0, 0, 0, 104]),
        ),
        throwsA(anything),
      );
    });

    test('rejects a char field holding a surrogate', () {
      final schema = makeSchema([SchemaDataType.char], ['grade']);

      expect(
        () => deserializeAttestationData(
          schema,
          Uint8List.fromList([0, 0xd8, 0, 0]),
        ),
        throwsFormatException,
      );
    });
  });

  group('instruction identification', () {
    test('rejects empty instruction data', () {
      expect(
        () => identifySolanaAttestationServiceInstruction(Uint8List(0)),
        throwsA(isA<SolanaError>()),
      );
    });

    test('rejects an unknown discriminator', () {
      expect(
        () => identifySolanaAttestationServiceInstruction(
          Uint8List.fromList([200]),
        ),
        throwsA(isA<SolanaError>()),
      );
    });

    test('parses only instructions of this program', () {
      expect(
        () => parseSolanaAttestationServiceInstruction(
          Instruction(
            programAddress: otherProgram,
            accounts: const [],
            data: Uint8List.fromList([0, 4, 0, 0, 0, 1, 1, 1, 1]),
          ),
        ),
        throwsA(anything),
      );
    });
  });

  group('pda seed limits', () {
    test('rejects credential names longer than 32 bytes', () {
      expect(
        () => findCredentialPda(
          seeds: const CredentialSeeds(
            authority: otherProgram,
            name: 'a-credential-name-that-is-far-too-long-for-a-pda-seed',
          ),
        ),
        throwsA(isA<SolanaError>()),
      );
    });
  });

  group('isAttestationServiceError', () {
    const message = TransactionMessageInput(
      instructions: {
        0: InstructionInput(programAddress: program),
      },
    );

    test('matches a custom error code from this program', () {
      final error = SolanaError(SolanaErrorCode.instructionErrorCustom, {
        'index': 0,
        'code': AttestationServiceError.schemaPaused.code,
      });

      expect(
        isAttestationServiceError(
          error,
          message,
          AttestationServiceError.schemaPaused,
        ),
        isTrue,
      );
    });

    test('does not match another error code from this program', () {
      final error = SolanaError(SolanaErrorCode.instructionErrorCustom, {
        'index': 0,
        'code': 99,
      });

      expect(
        isAttestationServiceError(
          error,
          message,
          AttestationServiceError.schemaPaused,
        ),
        isFalse,
      );
    });

    test('does not match errors from another program', () {
      final error = SolanaError(SolanaErrorCode.instructionErrorCustom, {
        'index': 0,
        'code': AttestationServiceError.schemaPaused.code,
      });
      const otherProgramMessage = TransactionMessageInput(
        instructions: {
          0: InstructionInput(programAddress: otherProgram),
        },
      );

      expect(
        isAttestationServiceError(
          error,
          otherProgramMessage,
          AttestationServiceError.schemaPaused,
        ),
        isFalse,
      );
    });

    test('does not match unrelated errors', () {
      expect(
        isAttestationServiceError(
          StateError('unrelated'),
          message,
          AttestationServiceError.schemaPaused,
        ),
        isFalse,
      );
    });

    test('exposes the on-chain code of every variant', () {
      expect(AttestationServiceError.invalidCredential.code, equals(0));
      expect(AttestationServiceError.schemaPaused.code, equals(11));
    });
  });
}
