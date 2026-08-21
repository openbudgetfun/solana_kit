# codama-renderers-dart

[![pub package](https://img.shields.io/pub/v/codama-renderers-dart.svg)](https://pub.dev/packages/codama-renderers-dart) [![CI](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml) [![Coverage](https://codecov.io/gh/openbudgetfun/solana_kit/branch/main/graph/badge.svg?flag=codama-renderers-dart)](https://codecov.io/gh/openbudgetfun/solana_kit?flag=codama-renderers-dart)

A [Codama](https://github.com/codama-idl/codama) renderer that generates Dart code targeting the [solana_kit](https://github.com/openbudgetfun/solana_kit) SDK.

Given a Codama IDL (Interface Description Language) describing a Solana program, this renderer produces a complete Dart package with typed account classes, instruction builders, codec functions, error definitions, PDA helpers, and barrel exports.

Fixed-size Codama types generate non-truncating encoders. Values within the declared byte capacity are zero-padded, while over-capacity values throw before any malformed bytes can be emitted. For UTF-8 strings, capacity is measured in encoded bytes rather than Dart code units.

## Installation

```bash
pnpm add codama-renderers-dart
# or
npm install codama-renderers-dart
```

## Quick start

### Programmatic API

```ts
import { renderVisitor } from "codama-renderers-dart";
import { visit } from "@codama/visitors-core";
import { rootNode, programNode /* ... */ } from "@codama/nodes";

// Build or load a Codama IDL root node
const root = rootNode(programNode({ /* ... */ }));

// Generate Dart files into the output directory
visit(root, renderVisitor("lib/src/generated", {
  formatCode: true,             // Run `dart format` on output (default: false)
  deleteFolderBeforeRendering: true, // Clean output dir first (default: true)
}));
```

### Serialized Pina IDLs

`renderVisitor` accepts parsed Codama JSON as well as roots made with Codama constructors. Pina omits empty collections from its serialized IDLs; the renderer restores those structural defaults on an internal copy before traversal, leaving the parsed object unchanged.

```ts
import { readFile } from "node:fs/promises";
import { visit } from "@codama/visitors-core";
import { renderVisitor } from "codama-renderers-dart";

const idl = JSON.parse(await readFile("target/codama/my_program.json", "utf8"));
visit(idl, renderVisitor("lib/src/generated"));
```

Use `normalizeRootNode(idl)` when calling lower-level visitors such as `getRenderMapVisitor` directly.

### Codama CLI

Create a `codama.json` configuration file:

```json
{
  "idl": "idl.json",
  "scripts": {
    "dart": {
      "from": "codama-renderers-dart",
      "args": ["lib/src/generated"]
    }
  }
}
```

Then run:

```bash
codama run dart
```

## Generated output structure

For a program called `myProgram`, the renderer generates:

```
lib/src/generated/
  my_program.dart                    # Root barrel export
  accounts/
    accounts.dart                    # Category barrel
    my_account.dart                  # Account type + codecs + decode helper
  instructions/
    instructions.dart                # Category barrel
    my_instruction.dart              # Instruction data + builder + parser
  types/
    types.dart                       # Category barrel
    my_struct.dart                   # Struct type + codecs
    my_enum.dart                     # Enum/sealed class + codecs
  errors/
    errors.dart                      # Category barrel
    my_program.dart                  # Error constants + message helpers
  programs/
    programs.dart                    # Category barrel
    my_program.dart                  # Program address + identifier enums
  pdas/
    pdas.dart                        # Category barrel
    my_pda.dart                      # PDA seeds class + finder function
```

## Generated code patterns

### Accounts

Each account generates an `@immutable` Dart class with typed fields, const constructor, proper `==`/`hashCode`/`toString` implementations, and codec functions:

```dart
@immutable
class MyAccount {
  const MyAccount({
    required this.authority,
    required this.count,
  });

  final Address authority;
  final BigInt count;

  // ... equality, hashCode, toString
}

Encoder<MyAccount> getMyAccountEncoder() { ... }
Decoder<MyAccount> getMyAccountDecoder() { ... }
Codec<MyAccount, MyAccount> getMyAccountCodec() { ... }
Account<MyAccount> decodeMyAccount(EncodedAccount encodedAccount) { ... }
```

### Instructions

Each instruction generates a data class, codec functions, a builder function, and a parse function:

```dart
@immutable
class TransferInstructionData {
  const TransferInstructionData({
    this.discriminator = 3,
    required this.amount,
  });

  final int discriminator;
  final BigInt amount;
}

Instruction getTransferInstruction({
  required Address programAddress,
  required Address source,
  required Address destination,
  required BigInt amount,
}) { ... }

TransferInstructionData parseTransferInstruction(Instruction instruction) { ... }
```

### Discriminators and omitted defaults

Generated codecs treat Codama discriminators as wire invariants rather than caller input. A struct field or instruction argument with a default value strategy of `omitted` is not accepted by the generated constructor or instruction builder. Its declared default is always written by the encoder.

Account and instruction decoders validate every declared constant, field, and size discriminator before returning typed data. Invalid discriminator bytes and unexpected discriminator sizes throw a `SolanaError` instead of decoding as the wrong account or instruction type. Generation fails when a field discriminator has no deterministic default or uses a value form the renderer cannot encode safely.

Top-level instruction decoders require exact input consumption. Account decoders always reject truncated data, but accept unread trailing capacity unless the account declares a `sizeDiscriminatorNode`; size-discriminated accounts reject both truncation and suffix bytes.

Optional instruction accounts use Codama's `programId` strategy by default. When an optional account is absent, the builder emits a readonly program-address placeholder so every later account keeps its declared index. The account slot is removed only when the instruction explicitly selects the legacy `omitted` strategy.

### Scalar enums

Scalar enums (all-empty variants) generate a Dart `enum` with index-based encoder/decoder:

```dart
enum AccountStatus {
  active,
  frozen,
  closed,
}

Encoder<AccountStatus> getAccountStatusEncoder() { ... }
Decoder<AccountStatus> getAccountStatusDecoder() { ... }
```

The generated enum API is the same for `u8`, `u16`, `u32`, and `u64` discriminators. The renderer converts `u64` indices to and from `BigInt` at the codec boundary and rejects out-of-range discriminators before converting them to Dart enum indices.

### Data enums (discriminated unions)

Data enums generate Dart 3 `sealed class` hierarchies:

```dart
sealed class TokenInstruction {
  const TokenInstruction();
}

final class Transfer extends TokenInstruction {
  const Transfer({required this.amount});
  final BigInt amount;
}

final class Approve extends TokenInstruction {
  const Approve({required this.amount});
  final BigInt amount;
}
```

### Errors

Program errors generate constants, a message map, and helper functions:

```dart
const int myProgramErrorInvalidAuthority = 0x1770; // 6000

String? getMyProgramErrorMessage(int code) { ... }
bool isMyProgramError(int code) { ... }
```

### PDAs

PDAs generate a seeds class and finder function:

```dart
@immutable
class MyPdaSeeds {
  const MyPdaSeeds({required this.authority});
  final Address authority;
}

Future<(Address, int)> findMyPdaPda({
  required MyPdaSeeds seeds,
  required Address programAddress,
}) async { ... }
```

## Type mapping

| Codama Type                         | Dart Type       | Codec                            |
| ----------------------------------- | --------------- | -------------------------------- |
| `numberTypeNode(u8/u16/u32)`        | `int`           | `getU8Encoder()` etc.            |
| `numberTypeNode(u64/u128/i64/i128)` | `BigInt`        | `getU64Encoder()` etc.           |
| `numberTypeNode(f32/f64)`           | `double`        | `getF32Encoder()` etc.           |
| `booleanTypeNode`                   | `bool`          | `getBooleanEncoder()`            |
| `stringTypeNode`                    | `String`        | `getUtf8Encoder()` etc.          |
| `publicKeyTypeNode`                 | `Address`       | `getAddressEncoder()`            |
| `bytesTypeNode`                     | `Uint8List`     | `getBytesEncoder()`              |
| `arrayTypeNode`                     | `List<T>`       | `getArrayEncoder()`              |
| `mapTypeNode`                       | `Map<K, V>`     | `getMapEncoder()`                |
| `setTypeNode`                       | `Set<T>`        | `getSetEncoder()`                |
| `tupleTypeNode`                     | `(T1, T2, ...)` | `getTupleEncoder()`              |
| `optionTypeNode`                    | `T?`            | `getNullableEncoder()`           |
| `structTypeNode`                    | Named class     | `getStructEncoder()`             |
| `enumTypeNode` (scalar)             | `enum`          | `transformEncoder()`             |
| `enumTypeNode` (data)               | `sealed class`  | `getDiscriminatedUnionEncoder()` |

## Options

### `RenderOptions`

| Option                        | Type                     | Default | Description                                         |
| ----------------------------- | ------------------------ | ------- | --------------------------------------------------- |
| `deleteFolderBeforeRendering` | `boolean`                | `true`  | Delete output directory before generating           |
| `formatCode`                  | `boolean`                | `false` | Run `dart format` on generated files                |
| `nameApi`                     | `Partial<DartNameApi>`   | —       | Override naming conventions                         |
| `dependencyMap`               | `Record<string, string>` | —       | Override logical module to Dart package URI mapping |

### `DartNameApi`

All naming conventions are customizable:

```ts
import { renderVisitor, createDartNameApi } from "codama-renderers-dart";

const nameApi = {
  ...createDartNameApi(),
  dataType: (name) => `My${pascalCase(name)}`,
};

visit(root, renderVisitor("output", { nameApi }));
```

## Target packages

Generated Dart code depends on these solana_kit packages:

- `solana_kit_addresses` — `Address` type and encoder/decoder
- `solana_kit_codecs_core` — `Encoder`, `Decoder`, `Codec` base types
- `solana_kit_codecs_data_structures` — Struct, array, boolean, nullable codecs
- `solana_kit_codecs_numbers` — Number codecs (u8–u128, i8–i128, f32, f64)
- `solana_kit_codecs_strings` — String codecs (utf8, base58, base64, base16)
- `solana_kit_accounts` — `Account`, `EncodedAccount`, `decodeAccount`
- `solana_kit_instructions` — `Instruction`, `AccountMeta`, `AccountRole`
- `solana_kit_errors` — `SolanaError` error types
- `meta` — `@immutable` annotation

## Architecture

This renderer follows the same architecture as the official Codama renderers:

1. **Visitor pattern** — Uses `@codama/visitors-core` to traverse the IDL node tree
2. **Fragment system** — Composable tagged template literals that track imports
3. **RenderMap** — Maps file paths to code fragments
4. **Type manifest** — Maps Codama type nodes to Dart types and codec expressions

Key source files:

- `src/visitors/renderVisitor.ts` — Top-level entry point (file I/O)
- `src/visitors/getRenderMapVisitor.ts` — Maps IDL nodes to output files
- `src/visitors/getTypeManifestVisitor.ts` — Maps type nodes to Dart types/codecs
- `src/fragments/*.ts` — Code generation for each entity type
- `src/utils/` — Import maps, naming, fragment helpers

## Development

```bash
pnpm install
npx tsc --noEmit
pnpm test
pnpm test:watch
pnpm build
```

## License

MIT
