import 'dart:typed_data';

import 'package:solana_kit_accounts/solana_kit_accounts.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_attestation_service/solana_kit_attestation_service.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:test/test.dart';

const Address program = solanaAttestationServiceProgramAddress;
const a1 = Address('11111111111111111111111111111111');
const a2 = Address('22zoJMtdu4tQc2PzL74ZUT7FrwgB1Udec8DdW4yw4BdG');

/// A Schema account captured from the upstream TypeScript client tests.
final schemaAccountBytes = Uint8List.fromList([
  1, 147, 244, 210, 208, 208, 76, 164, 106, 193, 96, 129, 24, 152, 59, 215, //
  13, 112, 136, 111, 235, 117, 29, 128, 253, 99, 200, 171, 204, 126, 178, 74, //
  175,
  9,
  0,
  0,
  0,
  116,
  101,
  115,
  116,
  95,
  100,
  97,
  116,
  97,
  20,
  0,
  0,
  0,
  115, //
  99, 104, 101, 109, 97, 32, 102, 111, 114, 32, 116, 101, 115, 116, 32, 100, //
  97, 116, 97, 2, 0, 0, 0, 12, 0, 20, 0, 0, 0, 4, 0, 0, 0, 110, 97, 109, 101, //
  8, 0, 0, 0, 108, 111, 99, 97, 116, 105, 111, 110, 0, 1,
]);

Account<Uint8List> encodedAccount(Uint8List bytes) {
  return Account<Uint8List>(
    address: a2,
    data: bytes,
    executable: false,
    lamports: Lamports(BigInt.zero),
    programAddress: program,
    space: BigInt.from(bytes.length),
  );
}

void main() {
  group('schema account', () {
    test('decodes the 1-byte discriminator and the blobs', () {
      final schema = getSchemaDecoder().decode(schemaAccountBytes);

      expect(schema.discriminator, equals(1));
      expect(decodeSchemaText(schema.name), equals('test_data'));
      expect(
        decodeSchemaText(schema.description),
        equals('schema for test data'),
      );
      expect(
        decodeSchemaLayout(schema.layout),
        equals([SchemaDataType.string, SchemaDataType.u8]),
      );
      expect(
        decodeSchemaFieldNames(schema.fieldNames),
        equals(['name', 'location']),
      );
      expect(schema.isPaused, isFalse);
      expect(schema.version, equals(1));
    });

    test('round trips the account bytes it decoded', () {
      final schema = getSchemaDecoder().decode(schemaAccountBytes);

      expect(getSchemaEncoder().encode(schema), equals(schemaAccountBytes));
    });

    test('decodes through the account wrapper', () {
      final account = decodeSchema(encodedAccount(schemaAccountBytes));

      expect(account.data.version, equals(1));
      expect(account.data.discriminator, equals(1));
    });
  });

  group('credential account', () {
    test('round trips authority, name, and signers', () {
      final credential = Credential(
        discriminator: 0,
        authority: a1,
        name: Uint8List.fromList([4, 0, 0, 0, 116, 101, 115, 116]),
        authorizedSigners: const [a1, a2],
      );

      final decoded = getCredentialDecoder().decode(
        getCredentialEncoder().encode(credential),
      );
      expect(decoded.discriminator, equals(0));
      expect(decoded.authority, equals(a1));
      expect(decoded.name, equals(credential.name));
      expect(decoded.authorizedSigners, equals([a1, a2]));

      final account = decodeCredential(
        encodedAccount(
          getCredentialEncoder().encode(credential),
        ),
      );
      expect(account.data.authority, equals(a1));
    });
  });

  group('attestation account', () {
    test('round trips every field', () {
      final attestation = Attestation(
        discriminator: 2,
        nonce: a1,
        credential: a2,
        schema: a1,
        data: Uint8List.fromList([1, 2, 3]),
        signer: a2,
        expiry: BigInt.from(99),
        tokenAccount: a1,
      );

      final decoded = getAttestationDecoder().decode(
        getAttestationEncoder().encode(attestation),
      );
      expect(decoded.discriminator, equals(2));
      expect(decoded.nonce, equals(a1));
      expect(decoded.credential, equals(a2));
      expect(decoded.schema, equals(a1));
      expect(decoded.data, equals(Uint8List.fromList([1, 2, 3])));
      expect(decoded.signer, equals(a2));
      expect(decoded.expiry, equals(BigInt.from(99)));
      expect(decoded.tokenAccount, equals(a1));

      final account = decodeAttestation(
        encodedAccount(
          getAttestationEncoder().encode(attestation),
        ),
      );
      expect(account.data.expiry, equals(BigInt.from(99)));
    });
  });

  group('close attestation event', () {
    test('round trips the event layout', () {
      final event = CloseAttestationEvent(
        discriminator: 7,
        schema: a1,
        attestationData: Uint8List.fromList([9, 9]),
      );

      final decoded = getCloseAttestationEventDecoder().decode(
        getCloseAttestationEventEncoder().encode(event),
      );
      expect(decoded.discriminator, equals(7));
      expect(decoded.schema, equals(a1));
      expect(
        decoded.attestationData,
        equals(Uint8List.fromList([9, 9])),
      );
    });
  });

  group('schema data type codec', () {
    test('encodes each variant as its discriminant', () {
      for (var i = 0; i < SchemaDataType.values.length; i++) {
        final codec = getSchemaDataTypeCodec();
        expect(
          codec.decode(codec.encode(SchemaDataType.values[i])),
          equals(SchemaDataType.values[i]),
        );
        expect(codec.encode(SchemaDataType.values[i]).length, equals(1));
      }
    });
  });
}
