---
"solana_kit_attestation_service": major
"solana_kit_address_constants": minor
---

# Add the Solana Attestation Service program client

Introduces `solana_kit_attestation_service`, a generated program client for the Solana Attestation Service, the on-chain protocol for verifiable credentials where issuers register credentials, declare schemas, and issue attestations that verifiers can fetch and decode.

The package ships generated instruction builders and parsers for all 12 instructions, codecs for the `Credential`, `Schema`, and `Attestation` accounts with their 1-byte discriminators, the seven program PDAs (credential, schema, attestation, schema mint, attestation mint, event authority, and SAS authority), the `AttestationServiceError` codes with an `isAttestationServiceError` matcher, and a schema-driven codec that serializes and deserializes an attestation's raw `data` blob against its schema layout, including Rust `char` code points and lossless hex fallbacks for non-UTF-8 string bytes.

```dart
final (credential, _) = await findCredentialPda(
  seeds: const CredentialSeeds(authority: authority, name: 'my-credential'),
);
final data = serializeAttestationData(schema, {'name': 'Alice', 'age': 42});
```

`solana_kit_address_constants` gains the canonical `solanaAttestationServiceProgramAddress` constant.
