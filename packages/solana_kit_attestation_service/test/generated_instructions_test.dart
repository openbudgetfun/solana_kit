import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_attestation_service/solana_kit_attestation_service.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:test/test.dart';

const Address program = solanaAttestationServiceProgramAddress;
const a1 = Address('11111111111111111111111111111111');
const a2 = Address('22zoJMtdu4tQc2PzL74ZUT7FrwgB1Udec8DdW4yw4BdG');
const a3 = Address('4o5sW6bULdwncLFDudgnhZjNhcQsiC75MekVF5LXAhdM');
const a4 = Address('HngMQFF6Yoqj9VqA31r43HQsnuYZ6BxopRWQLQAS6zk');
const a5 = Address('2QnMhu6vbDrX4n2xz9HeiCFzUVRbRXeLqXYcnERDqPax');
const a6 = Address('DzSpKpST2TSyrxokMXchFz3G2yn5WEGoxzpGEUDjCX4g');
const a7 = Address('FpMk2wcb1oV7iASnH3UVs9oiYAA2i6JhXTq4qmDhBvLu');
const a8 = Address('3CF6r7ety7yPZZbW6KsKqn9dKqZWrCV7woaJG6EyMMu4');
const a9 = Address('CdUAYGvNc7NdtNgXmxTXoUWR5NjpcU4Za4vtoP2AVZD4');

Uint8List _bytes(List<int> values) => Uint8List.fromList(values);

void main() {
  group('create credential', () {
    test('encodes the discriminator, name, and signers', () {
      final instruction = getCreateCredentialInstruction(
        programAddress: program,
        payer: a1,
        credential: a9,
        authority: a2,
        systemProgram: a1,
        name: 'test',
        signers: [a2],
      );

      expect(instruction.programAddress, equals(program));
      expect(instruction.data, isNotNull);
      expect(instruction.data![0], equals(0));
      // u32 length prefix for the name, then 'test'.
      expect(
        instruction.data!.sublist(1, 9),
        equals(_bytes([4, 0, 0, 0, 116, 101, 115, 116])),
      );
      // Vec<Address> with one element.
      expect(instruction.data![9], equals(1));
      expect(instruction.accounts, hasLength(4));
      expect(
        instruction.accounts![0],
        isA<AccountMeta>()
            .having((meta) => meta.address, 'address', a1)
            .having((meta) => meta.role, 'role', AccountRole.writableSigner),
      );
    });

    test('round trips the instruction data codec', () {
      final codec = getCreateCredentialInstructionDataCodec();
      final decoded = codec.decode(
        codec.encode(
          const CreateCredentialInstructionData(name: 'test', signers: [a1]),
        ),
      );
      expect(decoded.discriminator, equals(0));
      expect(decoded.name, equals('test'));
      expect(decoded.signers, equals([a1]));
    });

    test('parses a create credential instruction', () {
      final instruction = getCreateCredentialInstruction(
        programAddress: program,
        payer: a1,
        credential: a9,
        authority: a2,
        systemProgram: a1,
        name: 'test',
        signers: [a2],
      );
      final parsed = parseCreateCredentialInstruction(instruction);
      expect(parsed.name, equals('test'));
      expect(parsed.signers, equals([a2]));
    });
  });

  group('create schema', () {
    test('encodes the typed layout as data type discriminants', () {
      final instruction = getCreateSchemaInstruction(
        programAddress: program,
        payer: a1,
        authority: a2,
        credential: a9,
        schema: a3,
        systemProgram: a1,
        name: 'person',
        description: 'A person',
        layout: [SchemaDataType.string, SchemaDataType.u8],
        fieldNames: ['name', 'age'],
      );

      expect(instruction.data![0], equals(1));
      // discriminator(1) + name(4 + 6) + description(4 + 8).
      const layoutOffset = 23;
      // The layout blob is a u32-prefixed run of u8 discriminants:
      // 2, 0, 0, 0, 12, 0.
      expect(
        instruction.data!.sublist(layoutOffset, layoutOffset + 6),
        equals(_bytes([2, 0, 0, 0, 12, 0])),
      );
    });

    test('parses a create schema instruction', () {
      final instruction = getCreateSchemaInstruction(
        programAddress: program,
        payer: a1,
        authority: a2,
        credential: a9,
        schema: a3,
        systemProgram: a1,
        name: 'person',
        description: 'A person',
        layout: [SchemaDataType.string, SchemaDataType.u8],
        fieldNames: ['name', 'age'],
      );
      final parsed = parseCreateSchemaInstruction(instruction);
      expect(parsed.name, equals('person'));
      expect(parsed.description, equals('A person'));
      expect(
        parsed.layout,
        equals([SchemaDataType.string, SchemaDataType.u8]),
      );
      expect(parsed.fieldNames, equals(['name', 'age']));
    });
  });

  group('change schema status', () {
    test('builds without a payer and round trips', () {
      final instruction = getChangeSchemaStatusInstruction(
        programAddress: program,
        authority: a2,
        credential: a9,
        schema: a3,
        isPaused: true,
      );

      expect(instruction.data![0], equals(2));
      expect(instruction.data![1], equals(1));
      expect(instruction.accounts, hasLength(3));

      final parsed = parseChangeSchemaStatusInstruction(instruction);
      expect(parsed.isPaused, isTrue);
    });
  });

  group('change authorized signers', () {
    test('round trips the signers list', () {
      final instruction = getChangeAuthorizedSignersInstruction(
        programAddress: program,
        payer: a1,
        authority: a2,
        credential: a9,
        systemProgram: a1,
        signers: [a3, a4],
      );

      expect(instruction.data![0], equals(3));
      final parsed = parseChangeAuthorizedSignersInstruction(instruction);
      expect(parsed.signers, equals([a3, a4]));
    });
  });

  group('change schema description', () {
    test('round trips the description', () {
      final instruction = getChangeSchemaDescriptionInstruction(
        programAddress: program,
        payer: a1,
        authority: a2,
        credential: a9,
        schema: a3,
        systemProgram: a1,
        description: 'updated',
      );

      expect(instruction.data![0], equals(4));
      final parsed = parseChangeSchemaDescriptionInstruction(instruction);
      expect(parsed.description, equals('updated'));
    });
  });

  group('change schema version', () {
    test('round trips the typed layout', () {
      final instruction = getChangeSchemaVersionInstruction(
        programAddress: program,
        payer: a1,
        authority: a2,
        credential: a9,
        existingSchema: a3,
        newSchema: a4,
        systemProgram: a1,
        layout: [SchemaDataType.vecString],
        fieldNames: ['tags'],
      );

      expect(instruction.data![0], equals(5));
      final parsed = parseChangeSchemaVersionInstruction(instruction);
      expect(parsed.layout, equals([SchemaDataType.vecString]));
      expect(parsed.fieldNames, equals(['tags']));
    });
  });

  group('create attestation', () {
    test('encodes data, nonce, and expiry', () {
      final instruction = getCreateAttestationInstruction(
        programAddress: program,
        payer: a1,
        authority: a2,
        credential: a9,
        schema: a3,
        attestation: a4,
        systemProgram: a1,
        nonce: a5,
        data: _bytes([10, 5, 0, 0, 0, 104, 101, 108, 108, 111]),
        expiry: BigInt.from(12345),
      );

      expect(instruction.data![0], equals(6));
      final parsed = parseCreateAttestationInstruction(instruction);
      expect(parsed.nonce, equals(a5));
      expect(
        parsed.data,
        equals(_bytes([10, 5, 0, 0, 0, 104, 101, 108, 108, 111])),
      );
      expect(parsed.expiry, equals(BigInt.from(12345)));
    });
  });

  group('close attestation', () {
    test('targets the event authority and the program itself', () {
      final instruction = getCloseAttestationInstruction(
        programAddress: program,
        payer: a1,
        authority: a2,
        credential: a9,
        attestation: a4,
        eventAuthority: a6,
        systemProgram: a1,
        attestationProgram: program,
      );

      // No args: data is only the discriminator byte.
      expect(instruction.data, equals(_bytes([7])));
      expect(instruction.accounts, hasLength(7));
    });
  });

  group('tokenize schema', () {
    test('encodes the max size as u64', () {
      final instruction = getTokenizeSchemaInstruction(
        programAddress: program,
        payer: a1,
        authority: a2,
        credential: a9,
        schema: a3,
        mint: a8,
        sasPda: a5,
        systemProgram: a1,
        tokenProgram: a2,
        maxSize: BigInt.from(1024),
      );

      expect(instruction.data![0], equals(9));
      final parsed = parseTokenizeSchemaInstruction(instruction);
      expect(parsed.maxSize, equals(BigInt.from(1024)));
    });
  });

  group('create tokenized attestation', () {
    test('round trips every argument', () {
      final instruction = getCreateTokenizedAttestationInstruction(
        programAddress: program,
        payer: a1,
        authority: a2,
        credential: a9,
        schema: a3,
        attestation: a4,
        systemProgram: a1,
        schemaMint: a8,
        attestationMint: a7,
        sasPda: a5,
        recipientTokenAccount: a6,
        recipient: a9,
        tokenProgram: a2,
        associatedTokenProgram: a1,
        nonce: a5,
        data: _bytes([1, 2, 3]),
        expiry: BigInt.from(42),
        name: 'badge',
        uri: 'https://example.com',
        symbol: 'BAG',
        mintAccountSpace: 82,
      );

      expect(instruction.data![0], equals(10));
      final parsed = parseCreateTokenizedAttestationInstruction(instruction);
      expect(parsed.data, equals(_bytes([1, 2, 3])));
      expect(parsed.expiry, equals(BigInt.from(42)));
      expect(parsed.name, equals('badge'));
      expect(parsed.uri, equals('https://example.com'));
      expect(parsed.symbol, equals('BAG'));
      expect(parsed.mintAccountSpace, equals(82));
    });
  });

  group('close tokenized attestation', () {
    test('builds with its token accounts', () {
      final instruction = getCloseTokenizedAttestationInstruction(
        programAddress: program,
        payer: a1,
        authority: a2,
        credential: a9,
        attestation: a4,
        eventAuthority: a6,
        systemProgram: a1,
        attestationProgram: program,
        attestationMint: a7,
        sasPda: a5,
        attestationTokenAccount: a6,
        tokenProgram: a2,
      );

      expect(instruction.data, equals(_bytes([11])));
      expect(instruction.accounts, hasLength(11));
    });
  });

  group('emit event', () {
    test('builds with only the event authority', () {
      final instruction = getEmitEventInstruction(
        programAddress: program,
        eventAuthority: a6,
      );

      expect(instruction.data, equals(_bytes([228])));
      expect(instruction.accounts, hasLength(1));
    });
  });

  group('identify', () {
    test('identifies every instruction by its on-chain discriminant', () {
      // Discriminants are assigned by the program's entrypoint: 0-7, then
      // 9-11 (8 is unused), and EmitEvent tags itself with EVENT_IX_TAG
      // (228).
      final discriminants = [
        [0],
        [1],
        [2],
        [3],
        [4],
        [5],
        [6],
        [7],
        [9],
        [10],
        [11],
        [228],
      ];
      for (var i = 0; i < discriminants.length; i++) {
        expect(
          identifySolanaAttestationServiceInstruction(
            _bytes(discriminants[i]),
          ),
          equals(SolanaAttestationServiceInstruction.values[i]),
        );
      }
    });
  });

  group('parse program instruction', () {
    test('parses a create credential instruction through the program API', () {
      final instruction = getCreateCredentialInstruction(
        programAddress: program,
        payer: a1,
        credential: a9,
        authority: a2,
        systemProgram: a1,
        name: 'test',
        signers: [a2],
      );

      final parsed = parseSolanaAttestationServiceInstruction(instruction);
      expect(
        parsed,
        isA<ParsedCreateCredential>().having(
          (parsed) => parsed.data.name,
          'name',
          'test',
        ),
      );
    });
  });
}
