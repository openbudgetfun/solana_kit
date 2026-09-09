# solana_kit_attestation_service

[![Coverage](https://codecov.io/gh/openbudgetfun/solana_kit/branch/main/graph/badge.svg?flag=solana_kit_attestation_service)](https://codecov.io/gh/openbudgetfun/solana_kit?flag=solana_kit_attestation_service) [![website](https://img.shields.io/badge/website-solana__kit__docs-0A7EA4.svg)](https://openbudgetfun.github.io/solana_kit/reference/package-catalog#solana_kit_attestation_service) Solana Attestation Service program client for the [Solana Kit](https://github.com/openbudgetfun/solana_kit) Dart SDK.

Provides instruction builders, account codecs, PDA helpers, and a schema-driven attestation data codec for the Solana Attestation Service, the on-chain protocol for verifiable credentials: issuers register credentials, declare schemas, and issue attestations that verifiers can fetch and decode.

## Installation

<!-- {=packageInstallSection:"solana_kit_attestation_service"} -->

## Installation

Install the package directly:

```yaml
dependencies:
  "solana_kit_attestation_service": ^
```

If your app uses several Solana Kit packages together, you can also depend on the umbrella package instead:

```bash
dart pub add solana_kit
```

Inside this monorepo, Dart workspace resolution uses the local package automatically.

<!-- {/packageInstallSection} -->

<!-- {=generatedProgramClientSection} -->

## How generated program clients work

Generated program clients share one API shape, so what you learn in one program transfers to the next:

- **Program address constant** — a `...ProgramAddress` constant identifies the program on-chain.
- **Identification helpers** — `identify...Program` and `identify...Instruction` match programs and instructions without string comparisons.
- **Instruction builders and parsers** — `get...Instruction` encodes parameters, `parse...Instruction` decodes a transaction instruction back into typed arguments.
- **Account codecs** — `get...AccountCodec` and `decode...Account` turn on-chain bytes into typed account objects.
- **Plan helpers** — `get...InstructionPlan` helpers compose multi-instruction flows (such as creating an account before acting on it) into transaction plans the standard executor can run.

Errors thrown by these helpers and by transaction execution surface as `SolanaError`; match program-specific failures with the program error helpers.

<!-- {/generatedProgramClientSection} -->

<!-- {=programErrorHandlingSection} -->

## Match program errors from your program

Transaction failures surface as `SolanaError` values. When a transaction fails with a custom program error, the RPC response identifies the failing instruction by index — pair it with the transaction message to attribute the error to a program and match custom error codes.

```dart
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_programs/solana_kit_programs.dart';

Future<void> handleTransactionFailure(Object error) async {
  const myProgramAddress = Address('11111111111111111111111111111111');
  final transactionMessage = TransactionMessageInput(
    instructions: {0: InstructionInput(programAddress: myProgramAddress)},
  );

  if (isProgramError(error, transactionMessage, myProgramAddress, 42)) {
    // Custom program error code 42 from this program.
  } else if (isProgramError(error, transactionMessage, myProgramAddress)) {
    // Any other custom error from this program.
  }
}
```

`transactionMessage` is a lightweight `TransactionMessageInput` — a map from instruction index to `InstructionInput(programAddress: ...)`. Build it from the same instructions you sent, so matching stays accurate even when the transaction mixes instructions from several programs.

<!-- {/programErrorHandlingSection} -->

## Usage

```dart
import 'package:solana_kit_address_constants/solana_kit_address_constants.dart';
import 'package:solana_kit_attestation_service/solana_kit_attestation_service.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';

Future<void> main() async {
  const authority = Address('11111111111111111111111111111111');

  // Derive the issuer's credential and its schema addresses.
  final (credential, _) = await findCredentialPda(
    seeds: const CredentialSeeds(authority: authority, name: 'my-credential'),
  );
  final (schema, _) = await findSchemaPda(
    seeds: SchemaSeeds(credential: credential, name: 'person', version: 1),
  );

  // Build the create-credential instruction.
  final createCredentialIx = getCreateCredentialInstruction(
    programAddress: solanaAttestationServiceProgramAddress,
    payer: authority,
    credential: credential,
    authority: authority,
    systemProgram: systemProgramAddress,
    name: 'my-credential',
    signers: [authority],
  );

  // Declare a schema whose layout is a run of SchemaDataType discriminants.
  final createSchemaIx = getCreateSchemaInstruction(
    programAddress: solanaAttestationServiceProgramAddress,
    payer: authority,
    authority: authority,
    credential: credential,
    schema: schema,
    systemProgram: systemProgramAddress,
    name: 'person',
    description: 'A person',
    layout: [SchemaDataType.string, SchemaDataType.u8],
    fieldNames: ['name', 'age'],
  );

  print(createCredentialIx.programAddress);
  print(createSchemaIx.programAddress);
}
```

## Encoding attestation data

An attestation stores its payload as raw bytes laid out by its schema. `serializeAttestationData` turns a field map into that byte blob using the schema's declared layout, and `deserializeAttestationData` reads it back:

```dart
import 'package:solana_kit_attestation_service/solana_kit_attestation_service.dart';

Future<void> encodeData(Schema schema) async {
  final data = serializeAttestationData(schema, {'name': 'Alice', 'age': 42});

  final decoded = deserializeAttestationData(schema, data);
  print(decoded['name']); // Alice
}
```

Fields declared as strings decode strictly: bytes that are not valid UTF-8 (raw hashes, ciphertext) are surfaced losslessly as `0x`-prefixed hex strings instead of replacement characters. A `char` field holds exactly one Unicode character and is encoded as its 4-byte little-endian code point, matching the Rust program.

## Instructions

| Instruction                  | Discriminator | Description                                                 |
| ---------------------------- | ------------- | ----------------------------------------------------------- |
| `CreateCredential`           | 0             | Register a credential (issuer) with its authorized signers. |
| `CreateSchema`               | 1             | Declare a schema layout under a credential.                 |
| `ChangeSchemaStatus`         | 2             | Pause or unpause a schema.                                  |
| `ChangeAuthorizedSigners`    | 3             | Rotate a credential's authorized signers.                   |
| `ChangeSchemaDescription`    | 4             | Update a schema's description.                              |
| `ChangeSchemaVersion`        | 5             | Create a new version of a schema.                           |
| `CreateAttestation`          | 6             | Issue an attestation conforming to a schema.                |
| `CloseAttestation`           | 7             | Close an attestation and reclaim rent.                      |
| `TokenizeSchema`             | 9             | Create the schema mint for tokenized attestations.          |
| `CreateTokenizedAttestation` | 10            | Issue an attestation as a Token-2022 NFT.                   |
| `CloseTokenizedAttestation`  | 11            | Close a tokenized attestation and burn its mint.            |
| `EmitEvent`                  | 228           | Emit an event through the program's event authority.        |

Discriminant 8 is unused. The program's entrypoint assigns `EmitEvent` the first byte of its event instruction tag (228), and `TokenizeSchema` starts at 9.

## Reading schema accounts

The generated `Schema` account keeps its `name`, `description`, `layout`, and `fieldNames` as raw length-prefixed byte blobs, exactly as stored on-chain. Decode them with the typed helpers:

```dart
import 'package:solana_kit_attestation_service/solana_kit_attestation_service.dart';

Future<void> readSchema(Schema schema) async {
  final name = decodeSchemaText(schema.name);
  final fieldNames = decodeSchemaFieldNames(schema.fieldNames);
  final layout = decodeSchemaLayout(schema.layout);
  print('$name declares $fieldNames as $layout');
}
```

## Upstream reference

Generated layer mirrors [solana-foundation/solana-attestation-service](https://github.com/solana-foundation/solana-attestation-service) at commit `5b64cf09843d62ca800f7d73f8438ad3505de70e`.
