import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_attestation_service/solana_kit_attestation_service.dart';
import 'package:test/test.dart';

const authority = Address('11111111111111111111111111111111');
const credentialAddress = Address(
  '22zoJMtdu4tQc2PzL74ZUT7FrwgB1Udec8DdW4yw4BdG',
);
const schemaAddress = Address(
  '4o5sW6bULdwncLFDudgnhZjNhcQsiC75MekVF5LXAhdM',
);
const attestationAddress = Address(
  'HngMQFF6Yoqj9VqA31r43HQsnuYZ6BxopRWQLQAS6zk',
);

void main() {
  group('barrel exports', () {
    test('program address is accessible', () {
      expect(
        solanaAttestationServiceProgramAddress,
        const Address('22zoJMtdu4tQc2PzL74ZUT7FrwgB1Udec8DdW4yw4BdG'),
      );
    });

    test('enums have all variants', () {
      expect(SolanaAttestationServiceInstruction.values, hasLength(12));
      expect(SolanaAttestationServiceAccount.values, hasLength(3));
      expect(SchemaDataType.values, hasLength(26));
      expect(AttestationServiceError.values, hasLength(12));
    });

    test('instruction builders are callable', () {
      final credentialIx = getCreateCredentialInstruction(
        programAddress: solanaAttestationServiceProgramAddress,
        payer: authority,
        credential: credentialAddress,
        authority: authority,
        systemProgram: authority,
        name: 'my-credential',
        signers: [authority],
      );
      expect(
        credentialIx.programAddress,
        equals(solanaAttestationServiceProgramAddress),
      );

      final attestationIx = getCreateAttestationInstruction(
        programAddress: solanaAttestationServiceProgramAddress,
        payer: authority,
        authority: authority,
        credential: credentialAddress,
        schema: schemaAddress,
        attestation: attestationAddress,
        systemProgram: authority,
        nonce: authority,
        data: Uint8List.fromList([1]),
        expiry: BigInt.zero,
      );
      expect(
        attestationIx.programAddress,
        equals(solanaAttestationServiceProgramAddress),
      );
    });

    test('schema helpers are exported', () {
      expect(decodeSchemaText, isNotNull);
      expect(decodeSchemaFieldNames, isNotNull);
      expect(decodeSchemaLayout, isNotNull);
      expect(getAttestationDataCodec, isNotNull);
      expect(serializeAttestationData, isNotNull);
      expect(deserializeAttestationData, isNotNull);
      expect(findCredentialPda, isNotNull);
      expect(findSchemaPda, isNotNull);
      expect(findAttestationPda, isNotNull);
      expect(findSchemaMintPda, isNotNull);
      expect(findAttestationMintPda, isNotNull);
      expect(findEventAuthorityPda, isNotNull);
      expect(findSasAuthorityPda, isNotNull);
      expect(isAttestationServiceError, isNotNull);
    });

    test('pda seed constants are exported', () {
      expect(credentialSeed, equals('credential'));
      expect(schemaSeed, equals('schema'));
      expect(attestationSeed, equals('attestation'));
      expect(schemaMintSeed, equals('schemaMint'));
      expect(attestationMintSeed, equals('attestationMint'));
      expect(eventAuthoritySeed, equals('__event_authority'));
      expect(sasSeed, equals('sas'));
    });
  });
}
