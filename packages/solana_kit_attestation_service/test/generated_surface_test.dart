import 'dart:convert';
import 'dart:typed_data';

import 'package:solana_kit_accounts/solana_kit_accounts.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_attestation_service/solana_kit_attestation_service.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
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

Uint8List bytes(List<int> values) => Uint8List.fromList(values);

/// UTF-8 bytes of [text], the content form of a Schema text blob.
Uint8List utf8Name(String text) => Uint8List.fromList(utf8.encode(text));

Account<Uint8List> encodedAccount(Uint8List data) {
  return Account<Uint8List>(
    address: a1,
    data: data,
    executable: false,
    lamports: Lamports(BigInt.zero),
    programAddress: program,
    space: BigInt.from(data.length),
  );
}

final Uint8List _issuerName = bytes(utf8Name('issuer'));

final _credential = Credential(
  discriminator: 0,
  authority: a1,
  name: _issuerName,
  authorizedSigners: const [a1, a2],
);
final _credentialClone = Credential(
  discriminator: 0,
  authority: a1,
  name: _issuerName,
  authorizedSigners: const [a1, a2],
);
final _credentialAlt = Credential(
  discriminator: 0,
  authority: a2,
  name: _issuerName,
  authorizedSigners: const [a1, a2],
);

final Uint8List _personName = bytes(utf8Name('person'));
final Uint8List _personLayout = bytes([12, 0]);
final Uint8List _personDescription = bytes(utf8Name('A person'));
final Uint8List _personFieldNames = bytes([
  4, 0, 0, 0, ...utf8Name('name'), //
  3, 0, 0, 0, ...utf8Name('age'),
]);
final _schema = Schema(
  discriminator: 1,
  credential: a1,
  name: _personName,
  description: _personDescription,
  layout: _personLayout,
  fieldNames: _personFieldNames,
  isPaused: false,
  version: 1,
);
final _schemaClone = Schema(
  discriminator: 1,
  credential: a1,
  name: _personName,
  description: _personDescription,
  layout: _personLayout,
  fieldNames: _personFieldNames,
  isPaused: false,
  version: 1,
);
final _schemaAlt = Schema(
  discriminator: 1,
  credential: a1,
  name: _personName,
  description: _personDescription,
  layout: bytes([0, 12]),
  fieldNames: _personFieldNames,
  isPaused: false,
  version: 1,
);

final Uint8List _attestationData = bytes([1, 2, 3]);
final _attestation = Attestation(
  discriminator: 2,
  nonce: a1,
  credential: a2,
  schema: a3,
  data: _attestationData,
  signer: a4,
  expiry: BigInt.from(99),
  tokenAccount: a5,
);
final _attestationClone = Attestation(
  discriminator: 2,
  nonce: a1,
  credential: a2,
  schema: a3,
  data: _attestationData,
  signer: a4,
  expiry: BigInt.from(99),
  tokenAccount: a5,
);
final _attestationAlt = Attestation(
  discriminator: 2,
  nonce: a1,
  credential: a2,
  schema: a3,
  data: _attestationData,
  signer: a4,
  expiry: BigInt.from(100),
  tokenAccount: a5,
);

final Uint8List _eventData = bytes([9, 9]);
final _event = CloseAttestationEvent(
  discriminator: 7,
  schema: a1,
  attestationData: _eventData,
);
final _eventClone = CloseAttestationEvent(
  discriminator: 7,
  schema: a1,
  attestationData: _eventData,
);
final _eventAlt = CloseAttestationEvent(
  discriminator: 7,
  schema: a2,
  attestationData: _eventData,
);

void main() {
  group('generated accounts', () {
    test('round trips every account codec and decoder helper', () {
      _roundTripAccount(getCredentialCodec(), _credential, decodeCredential);
      _roundTripAccount(getSchemaCodec(), _schema, decodeSchema);
      _roundTripAccount(
        getAttestationCodec(),
        _attestation,
        decodeAttestation,
      );

      _expectValueObject(
        _credential,
        _credentialClone,
        _credentialAlt,
        'Credential',
      );
      _expectValueObject(_schema, _schemaClone, _schemaAlt, 'Schema');
      _expectValueObject(
        _attestation,
        _attestationClone,
        _attestationAlt,
        'Attestation',
      );
    });
  });

  group('generated types', () {
    test('round trips the close attestation event', () {
      _roundTrip(getCloseAttestationEventCodec(), _event);
      _expectValueObject(
        _event,
        _eventClone,
        _eventAlt,
        'CloseAttestationEvent',
      );
    });

    test('round trips the schema data type enum', () {
      for (final type in SchemaDataType.values) {
        _roundTrip(getSchemaDataTypeCodec(), type);
      }
      expect(SchemaDataType.u8.toString(), 'SchemaDataType.u8');
    });
  });

  group('generated instruction data', () {
    test('round trips every instruction data codec', () {
      _roundTrip(
        getCreateCredentialInstructionDataCodec(),
        const CreateCredentialInstructionData(name: 'test', signers: [a1]),
      );
      _roundTrip(
        getCreateSchemaInstructionDataCodec(),
        const CreateSchemaInstructionData(
          name: 'person',
          description: 'A person',
          layout: [SchemaDataType.string, SchemaDataType.u8],
          fieldNames: ['name', 'age'],
        ),
      );
      _roundTrip(
        getChangeSchemaStatusInstructionDataCodec(),
        const ChangeSchemaStatusInstructionData(isPaused: true),
      );
      _roundTrip(
        getChangeAuthorizedSignersInstructionDataCodec(),
        const ChangeAuthorizedSignersInstructionData(signers: [a1, a2]),
      );
      _roundTrip(
        getChangeSchemaDescriptionInstructionDataCodec(),
        const ChangeSchemaDescriptionInstructionData(description: 'updated'),
      );
      _roundTrip(
        getChangeSchemaVersionInstructionDataCodec(),
        const ChangeSchemaVersionInstructionData(
          layout: [SchemaDataType.vecString],
          fieldNames: ['tags'],
        ),
      );
      _roundTrip(
        getCreateAttestationInstructionDataCodec(),
        CreateAttestationInstructionData(
          nonce: a1,
          data: bytes([1, 2]),
          expiry: BigInt.from(7),
        ),
      );
      _roundTrip(
        getCloseAttestationInstructionDataCodec(),
        const CloseAttestationInstructionData(),
      );
      _roundTrip(
        getTokenizeSchemaInstructionDataCodec(),
        TokenizeSchemaInstructionData(maxSize: BigInt.from(1024)),
      );
      _roundTrip(
        getCreateTokenizedAttestationInstructionDataCodec(),
        CreateTokenizedAttestationInstructionData(
          nonce: a1,
          data: bytes([1]),
          expiry: BigInt.one,
          name: 'badge',
          uri: 'https://example.com',
          symbol: 'BAG',
          mintAccountSpace: 82,
        ),
      );
      _roundTrip(
        getCloseTokenizedAttestationInstructionDataCodec(),
        const CloseTokenizedAttestationInstructionData(),
      );
      _roundTrip(
        getEmitEventInstructionDataCodec(),
        const EmitEventInstructionData(),
      );
    });

    test('compares instruction data values', () {
      // Instruction data classes define equality but not toString.
      const value = CreateCredentialInstructionData(
        name: 'test',
        signers: [a1],
      );
      const clone = CreateCredentialInstructionData(
        name: 'test',
        signers: [a1],
      );
      const alt = CreateCredentialInstructionData(
        name: 'other',
        signers: [a1],
      );
      expect(value, equals(clone));
      expect(value.hashCode, equals(clone.hashCode));
      expect(value, isNot(equals(alt)));
      expect(
        const CloseAttestationInstructionData(),
        equals(const CloseAttestationInstructionData()),
      );
      expect(
        const CloseAttestationInstructionData().hashCode,
        equals(const CloseAttestationInstructionData().hashCode),
      );
      expect(
        const CloseAttestationInstructionData(),
        isNot(equals(const EmitEventInstructionData())),
      );
    });
  });

  group('generated instruction builders and parsers', () {
    test('builders, parsers, and account metas agree', () {
      final createCredential = getCreateCredentialInstruction(
        programAddress: program,
        payer: a1,
        credential: a9,
        authority: a2,
        systemProgram: a1,
        name: 'test',
        signers: [a2],
      );
      expect(
        parseCreateCredentialInstruction(createCredential).name,
        'test',
      );
      final createSchema = getCreateSchemaInstruction(
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
      expect(
        parseCreateSchemaInstruction(createSchema).description,
        'A person',
      );
      final changeSchemaStatus = getChangeSchemaStatusInstruction(
        programAddress: program,
        authority: a2,
        credential: a9,
        schema: a3,
        isPaused: true,
      );
      expect(
        parseChangeSchemaStatusInstruction(changeSchemaStatus).isPaused,
        isTrue,
      );
      final changeAuthorizedSigners = getChangeAuthorizedSignersInstruction(
        programAddress: program,
        payer: a1,
        authority: a2,
        credential: a9,
        systemProgram: a1,
        signers: [a3],
      );
      expect(
        parseChangeAuthorizedSignersInstruction(
          changeAuthorizedSigners,
        ).signers,
        [a3],
      );
      final changeSchemaDescription = getChangeSchemaDescriptionInstruction(
        programAddress: program,
        payer: a1,
        authority: a2,
        credential: a9,
        schema: a3,
        systemProgram: a1,
        description: 'updated',
      );
      expect(
        parseChangeSchemaDescriptionInstruction(
          changeSchemaDescription,
        ).description,
        'updated',
      );
      final changeSchemaVersion = getChangeSchemaVersionInstruction(
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
      expect(
        parseChangeSchemaVersionInstruction(changeSchemaVersion).layout,
        [SchemaDataType.vecString],
      );
      final createAttestation = getCreateAttestationInstruction(
        programAddress: program,
        payer: a1,
        authority: a2,
        credential: a9,
        schema: a3,
        attestation: a4,
        systemProgram: a1,
        nonce: a5,
        data: bytes([10, 5, 0, 0, 0, 104, 105]),
        expiry: BigInt.from(12345),
      );
      expect(
        parseCreateAttestationInstruction(createAttestation).expiry,
        BigInt.from(12345),
      );
      final closeAttestation = getCloseAttestationInstruction(
        programAddress: program,
        payer: a1,
        authority: a2,
        credential: a9,
        attestation: a4,
        eventAuthority: a6,
        systemProgram: a1,
        attestationProgram: program,
      );
      expect(
        parseCloseAttestationInstruction(closeAttestation).discriminator,
        7,
      );
      final tokenizeSchema = getTokenizeSchemaInstruction(
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
      expect(
        parseTokenizeSchemaInstruction(tokenizeSchema).maxSize,
        BigInt.from(1024),
      );
      final createTokenized = getCreateTokenizedAttestationInstruction(
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
        data: bytes([1]),
        expiry: BigInt.from(42),
        name: 'badge',
        uri: 'https://example.com',
        symbol: 'BAG',
        mintAccountSpace: 82,
      );
      expect(
        parseCreateTokenizedAttestationInstruction(createTokenized).symbol,
        'BAG',
      );
      final closeTokenized = getCloseTokenizedAttestationInstruction(
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
      expect(
        parseCloseTokenizedAttestationInstruction(closeTokenized).discriminator,
        11,
      );
      final emitEvent = getEmitEventInstruction(
        programAddress: program,
        eventAuthority: a6,
      );
      expect(parseEmitEventInstruction(emitEvent).discriminator, 228);
    });
  });

  group('codec byte-length guards', () {
    test('instruction data codecs reject wrong byte lengths', () {
      final factories = <Codec<Object?, Object?> Function()>[
        getCreateCredentialInstructionDataCodec,
        getCreateSchemaInstructionDataCodec,
        getChangeSchemaStatusInstructionDataCodec,
        getChangeAuthorizedSignersInstructionDataCodec,
        getChangeSchemaDescriptionInstructionDataCodec,
        getChangeSchemaVersionInstructionDataCodec,
        getCreateAttestationInstructionDataCodec,
        getCloseAttestationInstructionDataCodec,
        getTokenizeSchemaInstructionDataCodec,
        getCreateTokenizedAttestationInstructionDataCodec,
        getCloseTokenizedAttestationInstructionDataCodec,
        getEmitEventInstructionDataCodec,
      ];
      for (final factory in factories) {
        final codec = factory();
        // Shorter and longer than every fixed-size struct.
        expect(
          () => codec.decode(bytes([1, 2, 3])),
          throwsA(anything),
          reason: '$codec must reject truncated data',
        );
        expect(
          () => codec.decode(bytes(List.filled(64, 1))),
          throwsA(anything),
          reason: '$codec must reject oversized data',
        );
      }
    });

    test('account codecs reject wrong byte lengths', () {
      final factories = <Codec<Object?, Object?> Function()>[
        getCredentialCodec,
        getSchemaCodec,
        getAttestationCodec,
        getCloseAttestationEventCodec,
      ];
      for (final factory in factories) {
        final codec = factory();
        expect(
          () => codec.decode(bytes([1, 2, 3])),
          throwsA(anything),
          reason: '$codec must reject truncated data',
        );
        expect(
          () => codec.decode(bytes(List.filled(200, 1))),
          throwsA(anything),
          reason: '$codec must reject oversized data',
        );
      }
    });

    test('list equality compares element wise', () {
      const signers = [a1, a2];
      final value = Credential(
        discriminator: 0,
        authority: a1,
        name: bytes(utf8Name('issuer')),
        authorizedSigners: signers,
      );
      expect(
        value,
        isNot(
          equals(
            Credential(
              discriminator: 0,
              authority: a1,
              name: bytes(utf8Name('issuer')),
              authorizedSigners: const [a1],
            ),
          ),
        ),
      );
      expect(
        value,
        isNot(
          equals(
            Credential(
              discriminator: 0,
              authority: a1,
              name: bytes(utf8Name('issuer')),
              authorizedSigners: const [a1, a3],
            ),
          ),
        ),
      );
    });
  });

  group('generated program metadata', () {
    test('parses every instruction through the program API', () {
      final built = [
        getCreateCredentialInstruction(
          programAddress: program,
          payer: a1,
          credential: a9,
          authority: a2,
          systemProgram: a1,
          name: 'test',
          signers: [a2],
        ),
        getCreateSchemaInstruction(
          programAddress: program,
          payer: a1,
          authority: a2,
          credential: a9,
          schema: a3,
          systemProgram: a1,
          name: 'person',
          description: 'A person',
          layout: [SchemaDataType.u8],
          fieldNames: ['age'],
        ),
        getChangeSchemaStatusInstruction(
          programAddress: program,
          authority: a2,
          credential: a9,
          schema: a3,
          isPaused: false,
        ),
        getChangeAuthorizedSignersInstruction(
          programAddress: program,
          payer: a1,
          authority: a2,
          credential: a9,
          systemProgram: a1,
          signers: [a3],
        ),
        getChangeSchemaDescriptionInstruction(
          programAddress: program,
          payer: a1,
          authority: a2,
          credential: a9,
          schema: a3,
          systemProgram: a1,
          description: 'updated',
        ),
        getChangeSchemaVersionInstruction(
          programAddress: program,
          payer: a1,
          authority: a2,
          credential: a9,
          existingSchema: a3,
          newSchema: a4,
          systemProgram: a1,
          layout: [SchemaDataType.u8],
          fieldNames: ['age'],
        ),
        getCreateAttestationInstruction(
          programAddress: program,
          payer: a1,
          authority: a2,
          credential: a9,
          schema: a3,
          attestation: a4,
          systemProgram: a1,
          nonce: a5,
          data: bytes([1]),
          expiry: BigInt.zero,
        ),
        getCloseAttestationInstruction(
          programAddress: program,
          payer: a1,
          authority: a2,
          credential: a9,
          attestation: a4,
          eventAuthority: a6,
          systemProgram: a1,
          attestationProgram: program,
        ),
        getTokenizeSchemaInstruction(
          programAddress: program,
          payer: a1,
          authority: a2,
          credential: a9,
          schema: a3,
          mint: a8,
          sasPda: a5,
          systemProgram: a1,
          tokenProgram: a2,
          maxSize: BigInt.one,
        ),
        getCreateTokenizedAttestationInstruction(
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
          data: bytes([1]),
          expiry: BigInt.zero,
          name: 'badge',
          uri: 'https://example.com',
          symbol: 'BAG',
          mintAccountSpace: 82,
        ),
        getCloseTokenizedAttestationInstruction(
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
        ),
        getEmitEventInstruction(programAddress: program, eventAuthority: a6),
      ];

      const expectedTypes = SolanaAttestationServiceInstruction.values;
      for (var i = 0; i < built.length; i++) {
        final parsed = parseSolanaAttestationServiceInstruction(built[i]);
        expect(parsed.instructionType, expectedTypes[i]);
      }

      final parsed = [
        for (final instruction in built)
          parseSolanaAttestationServiceInstruction(instruction),
      ];
      expect(parsed[0], isA<ParsedCreateCredential>());
      expect(parsed[1], isA<ParsedCreateSchema>());
      expect(parsed[2], isA<ParsedChangeSchemaStatus>());
      expect(parsed[3], isA<ParsedChangeAuthorizedSigners>());
      expect(parsed[4], isA<ParsedChangeSchemaDescription>());
      expect(parsed[5], isA<ParsedChangeSchemaVersion>());
      expect(parsed[6], isA<ParsedCreateAttestation>());
      expect(parsed[7], isA<ParsedCloseAttestation>());
      expect(parsed[8], isA<ParsedTokenizeSchema>());
      expect(parsed[9], isA<ParsedCreateTokenizedAttestation>());
      expect(parsed[10], isA<ParsedCloseTokenizedAttestation>());
      expect(parsed[11], isA<ParsedEmitEvent>());
    });
  });
}

void _roundTrip<T>(Codec<T, T> codec, T value) {
  final encoded = codec.encode(value);
  final decoded = codec.decode(Uint8List.fromList(encoded));
  expect(codec.encode(decoded), encoded);
}

void _roundTripAccount<T>(
  Codec<T, T> codec,
  T value,
  Account<T> Function(EncodedAccount) decode,
) {
  final data = codec.encode(value);
  final decoded = codec.decode(Uint8List.fromList(data));
  expect(codec.encode(decoded), data);
  final account = decode(encodedAccount(data));
  expect(codec.encode(account.data), data);
}

void _expectValueObject(
  Object value,
  Object clone,
  Object alt,
  String typeName,
) {
  expect(value, equals(clone));
  expect(value.hashCode, equals(clone.hashCode));
  expect(value, isNot(equals(alt)));
  expect(value.toString(), startsWith('$typeName('));
}
