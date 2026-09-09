import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_attestation_service/solana_kit_attestation_service.dart';
import 'package:test/test.dart';

/// Program id the reference client is generated for.
const Address program = solanaAttestationServiceProgramAddress;

/// An unrelated program id used to exercise the `programAddress` overrides.
const otherProgramAddress = Address(
  'De1egAFMkMWZSN5rYXRj9CAdheBamobVNubTsi9avR44',
);

// Golden vectors validated against the Solana CLI
// (`solana find-program-derived-address`) and mirrored from the upstream
// TypeScript client tests at the pinned commit.
const issuer = 'tbFevHibEdBNFJfZ7xKC8k1th8pt2YPEXTk4sGMxCGa';
const credentialGolden = 'CdUAYGvNc7NdtNgXmxTXoUWR5NjpcU4Za4vtoP2AVZD4';
const credentialForSchema = '2zHazqL3MVayNGkDrTmAC7VsvP5QrSYfiyA7uf29Usmd';
const schemaGolden = 'bD7cVGpuTHY43fxtRoqJYi58U6Yi3kMyVck2DyZZRKq';
const attestationCredential = 'G6QmvUp3a1Kv9rX2LqHDH8AWcKD8yaufcoXEB1h6SzN8';
const attestationSchema = 'GSwz99vWPKnePyeYTM5iionEfArVmfrufV4AaV4SecTH';
const attestationNonce = 'Bdf3cgpzgboZq95T4AVYNxuYGDVE4pwLNQBhQ2ob8CoG';
const attestationGolden = 'CnhgnrLiawRWitfjrrUfWdR2jpwKbKGDccbk3ne171iu';
const schemaMintSchema = 'GCVt9SmgLF8bgEVwZAhQ9A2skwj5TvEnyn8Z7eUm583E';
const schemaMintGolden = '9JLQQK3zeEjiq2AJ1XPN765bYnLrBWJSFfyjDwdSMmyN';
const attestationMintAttestation =
    '3z8EuPHrzhfVWuDomSGjU13ABDgQC75DMHoDNBgxdzKR';
const attestationMintGolden = '61FeMtSXR8H22fodXNrTkwmrSmBuTNcAvKzZXvZRPMkX';
const eventAuthorityGolden = 'DzSpKpST2TSyrxokMXchFz3G2yn5WEGoxzpGEUDjCX4g';
const sasAuthorityGolden = 'HngMQFF6Yoqj9VqA31r43HQsnuYZ6BxopRWQLQAS6zk';

void main() {
  group('pda derivation', () {
    test('derives a credential address', () async {
      final (address, bump) = await findCredentialPda(
        seeds: const CredentialSeeds(
          authority: Address(issuer),
          name: 'test',
        ),
      );
      expect(address, equals(const Address(credentialGolden)));
      expect(bump, equals(255));
    });

    test('derives a schema address', () async {
      final (address, bump) = await findSchemaPda(
        seeds: const SchemaSeeds(
          credential: Address(credentialForSchema),
          name: 'test',
          version: 1,
        ),
      );
      expect(address, equals(const Address(schemaGolden)));
      expect(bump, equals(255));
    });

    test('derives an attestation address', () async {
      final (address, bump) = await findAttestationPda(
        seeds: const AttestationSeeds(
          credential: Address(attestationCredential),
          schema: Address(attestationSchema),
          nonce: Address(attestationNonce),
        ),
      );
      expect(address, equals(const Address(attestationGolden)));
      expect(bump, equals(255));
    });

    test('derives a schema mint address', () async {
      final (address, bump) = await findSchemaMintPda(
        schema: const Address(schemaMintSchema),
      );
      expect(address, equals(const Address(schemaMintGolden)));
      expect(bump, equals(245));
    });

    test('derives an attestation mint address', () async {
      final (address, bump) = await findAttestationMintPda(
        attestation: const Address(attestationMintAttestation),
      );
      expect(address, equals(const Address(attestationMintGolden)));
      expect(bump, equals(253));
    });

    test('derives the event authority address', () async {
      final (address, bump) = await findEventAuthorityPda();
      expect(address, equals(const Address(eventAuthorityGolden)));
      expect(bump, equals(255));
    });

    test('derives the SAS authority address', () async {
      final (address, bump) = await findSasAuthorityPda();
      expect(address, equals(const Address(sasAuthorityGolden)));
      expect(bump, equals(254));
    });

    test('derives a different address under an alternate program id', () async {
      final (address, bump) = await findSasAuthorityPda(
        programAddress: otherProgramAddress,
      );
      expect(address, isNot(equals(const Address(sasAuthorityGolden))));
      expect(bump, inInclusiveRange(0, 255));
    });
  });
}
