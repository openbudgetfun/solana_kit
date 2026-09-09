import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

/// Seed used to derive a Credential account address.
const credentialSeed = 'credential';

/// Seed used to derive a Schema account address.
const schemaSeed = 'schema';

/// Seed used to derive an Attestation account address.
const attestationSeed = 'attestation';

/// Seed used to derive the Schema mint address for a tokenized schema.
const schemaMintSeed = 'schemaMint';

/// Seed used to derive the Attestation mint address for a tokenized
/// attestation.
const attestationMintSeed = 'attestationMint';

/// Seed used to derive the program's event authority address.
const eventAuthoritySeed = '__event_authority';

/// Seed used to derive the program's signing authority address.
const sasSeed = 'sas';

/// Seeds used to derive a Credential account address.
@immutable
class CredentialSeeds {
  /// Creates a [CredentialSeeds] value.
  const CredentialSeeds({required this.authority, required this.name});

  /// The authority of the credential.
  final Address authority;

  /// The name of the credential.
  final String name;
}

/// Seeds used to derive a Schema account address.
@immutable
class SchemaSeeds {
  /// Creates a [SchemaSeeds] value.
  const SchemaSeeds({
    required this.credential,
    required this.name,
    required this.version,
  });

  /// The credential the schema belongs to.
  final Address credential;

  /// The name of the schema.
  final String name;

  /// The schema version; new schemas start at version 1.
  final int version;
}

/// Seeds used to derive an Attestation account address.
@immutable
class AttestationSeeds {
  /// Creates an [AttestationSeeds] value.
  const AttestationSeeds({
    required this.credential,
    required this.schema,
    required this.nonce,
  });

  /// The credential the attestation belongs to.
  final Address credential;

  /// The schema the attestation conforms to.
  final Address schema;

  /// The caller-chosen nonce that uniquely identifies the attestation.
  final Address nonce;
}

/// Finds the program derived address for a Credential account.
Future<(Address, int)> findCredentialPda({
  required CredentialSeeds seeds,
  Address programAddress = solanaAttestationServiceProgramAddress,
}) {
  return getProgramDerivedAddress(
    programAddress: programAddress,
    seeds: [
      credentialSeed,
      getAddressEncoder().encode(seeds.authority),
      seeds.name,
    ],
  );
}

/// Finds the program derived address for a Schema account.
Future<(Address, int)> findSchemaPda({
  required SchemaSeeds seeds,
  Address programAddress = solanaAttestationServiceProgramAddress,
}) {
  return getProgramDerivedAddress(
    programAddress: programAddress,
    seeds: [
      schemaSeed,
      getAddressEncoder().encode(seeds.credential),
      seeds.name,
      getU8Encoder().encode(seeds.version),
    ],
  );
}

/// Finds the program derived address for an Attestation account.
Future<(Address, int)> findAttestationPda({
  required AttestationSeeds seeds,
  Address programAddress = solanaAttestationServiceProgramAddress,
}) {
  return getProgramDerivedAddress(
    programAddress: programAddress,
    seeds: [
      attestationSeed,
      getAddressEncoder().encode(seeds.credential),
      getAddressEncoder().encode(seeds.schema),
      getAddressEncoder().encode(seeds.nonce),
    ],
  );
}

/// Finds the program derived address for a tokenized schema's mint.
Future<(Address, int)> findSchemaMintPda({
  required Address schema,
  Address programAddress = solanaAttestationServiceProgramAddress,
}) {
  return getProgramDerivedAddress(
    programAddress: programAddress,
    seeds: [schemaMintSeed, getAddressEncoder().encode(schema)],
  );
}

/// Finds the program derived address for a tokenized attestation's mint.
Future<(Address, int)> findAttestationMintPda({
  required Address attestation,
  Address programAddress = solanaAttestationServiceProgramAddress,
}) {
  return getProgramDerivedAddress(
    programAddress: programAddress,
    seeds: [attestationMintSeed, getAddressEncoder().encode(attestation)],
  );
}

/// Finds the program derived address for the program's event authority.
Future<(Address, int)> findEventAuthorityPda({
  Address programAddress = solanaAttestationServiceProgramAddress,
}) {
  return getProgramDerivedAddress(
    programAddress: programAddress,
    seeds: [eventAuthoritySeed],
  );
}

/// Finds the program derived address for the program's signing authority.
Future<(Address, int)> findSasAuthorityPda({
  Address programAddress = solanaAttestationServiceProgramAddress,
}) {
  return getProgramDerivedAddress(
    programAddress: programAddress,
    seeds: [sasSeed],
  );
}
