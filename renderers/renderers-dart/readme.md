# codama-renderers-solana-kit-dart

A [Codama](https://github.com/codama-idl/codama) renderer that generates Dart code targeting the [solana_kit](https://github.com/openbudgetfun/solana_kit) SDK.

Given a Codama IDL (Interface Description Language) describing a Solana program, this renderer produces a complete Dart package with typed account classes, instruction builders, codec functions, error definitions, PDA helpers, and barrel exports.

## Installation

```bash
pnpm add codama-renderers-solana-kit-dart
# or
npm install codama-renderers-solana-kit-dart
```

## Quick Start

### Programmatic API

```typescript
import { renderVisitor } from "codama-renderers-solana-kit-dart";
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

### Codama CLI

Create a `codama.json` configuration file:

```json
{
  "idl": "idl.json",
  "scripts": {
    "dart": {
      "from": "codama-renderers-solana-kit-dart",
      "args": ["lib/src/generated"]
    }
  }
}
```

Then run:

```bash
codama run dart
```

## Generated Output Structure

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

## Generated Code Patterns

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

### Scalar Enums

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

### Data Enums (Discriminated Unions)

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

## Type Mapping

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

```typescript
import { renderVisitor, createDartNameApi } from "codama-renderers-solana-kit-dart";

const nameApi = {
  ...createDartNameApi(),
  dataType: (name) => `My${pascalCase(name)}`,
};

visit(root, renderVisitor("output", { nameApi }));
```

## Target Packages

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
# Install dependencies
pnpm install

# Type check
npx tsc --noEmit

# Run tests
pnpm test

# Watch mode
pnpm test:watch

# Build
pnpm build
```

## License

MIT
