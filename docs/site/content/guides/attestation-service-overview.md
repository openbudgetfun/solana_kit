# Attestation Service overview

<!-- {=docsAttestationServiceOverviewSection} -->

The Solana Attestation Service is an open, permissionless protocol for verifiable on-chain credentials. In Dart, use `solana_kit_attestation_service` for generated instruction builders, account codecs, PDAs, and a schema-driven attestation data codec.

An issuer registers a **Credential** with its authorized signers, declares a **Schema** that names and types its fields, and issues **Attestations** whose payloads are encoded exactly as the schema declares. Verifiers fetch an attestation, decode its payload with the schema, and check the signer and expiry.

| Model       | Use                                                                           |
| ----------- | ----------------------------------------------------------------------------- |
| Credential  | Register an issuer and rotate its authorized signers.                         |
| Schema      | Declare a versioned, pausable field layout under a credential.                |
| Attestation | Store a schema-conformant payload (optionally tokenized as a Token-2022 NFT). |

The canonical flow is create-credential, create-schema, create-attestation, then verify:

```dart
import 'dart:typed_data';

import 'package:solana_kit/solana_kit.dart';
import 'package:solana_kit_attestation_service/solana_kit_attestation_service.dart';

Future<void> main() async {
  const authority = Address('tbFevHibEdBNFJfZ7xKC8k1th8pt2YPEXTk4sGMxCGa');

  final (credential, _) = await findCredentialPda(
    seeds: const CredentialSeeds(authority: authority, name: 'my-credential'),
  );
  final (schema, _) = await findSchemaPda(
    seeds: SchemaSeeds(credential: credential, name: 'person', version: 1),
  );

  final instruction = getCreateAttestationInstruction(
    programAddress: solanaAttestationServiceProgramAddress,
    payer: authority,
    authority: authority,
    credential: credential,
    schema: schema,
    attestation: authority,
    systemProgram: systemProgramAddress,
    nonce: authority,
    data: Uint8List.fromList([0]),
    expiry: BigInt.zero,
  );
  print(instruction.programAddress);
}
```

<!-- {/docsAttestationServiceOverviewSection} -->

Verification closes the loop: fetch the `Attestation` and `Schema` accounts, decode the payload against the schema's declared layout, and check that the attestation's signer is one of the credential's authorized signers and that the expiry has not passed.

```dart
import 'dart:convert';
import 'dart:typed_data';

import 'package:solana_kit/solana_kit.dart';
import 'package:solana_kit_attestation_service/solana_kit_attestation_service.dart';

void main() {
  final schema = Schema(
    discriminator: 1,
    credential: const Address('11111111111111111111111111111111'),
    name: Uint8List.fromList(utf8.encode('person')),
    description: Uint8List.fromList(utf8.encode('A person')),
    layout: Uint8List.fromList([
      SchemaDataType.string.index,
      SchemaDataType.u8.index,
    ]),
    fieldNames: Uint8List.fromList([
      4, 0, 0, 0, ...utf8.encode('name'), //
      3, 0, 0, 0, ...utf8.encode('age'),
    ]),
    isPaused: false,
    version: 1,
  );

  // In practice, fetch the attestation with an RPC client, then decode its
  // payload against the schema and check the signer and expiry.
  final payload = serializeAttestationData(schema, {'name': 'Alice', 'age': 42});
  print(deserializeAttestationData(schema, payload));
}
```

Upstream documentation: <https://attest.solana.com/docs>
