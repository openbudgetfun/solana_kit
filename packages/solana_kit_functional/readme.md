# solana_kit_functional

Pipe and compose utilities for the Solana Kit Dart SDK, enabling functional pipeline composition on any value.

This is the Dart port of [`@solana/functional`](https://github.com/anza-xyz/kit/tree/main/packages/functional) from the Solana TypeScript SDK.

## Installation

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  solana_kit_functional:
```

If you are working within the `solana_kit` monorepo, the package resolves through the Dart workspace. Otherwise, specify a version or path as needed.

## Usage

### The `pipe` extension

The `Pipe<T>` extension adds a `.pipe()` method to every Dart value. It takes a function `R Function(T)` and returns the result, allowing you to chain transformations in a readable left-to-right pipeline.

```dart
import 'package:solana_kit_functional/solana_kit_functional.dart';

final result = 'hello'
    .pipe((value) => value.toUpperCase())
    .pipe((value) => '$value!');
print(result); // HELLO!
```

### Chaining multiple transforms

Pipes can be chained indefinitely. Each step receives the output of the previous step:

```dart
import 'package:solana_kit_functional/solana_kit_functional.dart';

final result = 1
    .pipe((value) => value + 1)   // 2
    .pipe((value) => value * 2)   // 4
    .pipe((value) => value - 1);  // 3
print(result); // 3
```

### Type-changing pipelines

The type can change at each step in the pipeline. Dart infers the types automatically:

```dart
import 'package:solana_kit_functional/solana_kit_functional.dart';

final result = 42
    .pipe((value) => value + 8)           // int: 50
    .pipe((value) => value.toString())    // String: '50'
    .pipe((value) => '$value items');     // String: '50 items'
print(result); // 50 items
```

### Building immutable objects

Pipe is especially useful for building up immutable data structures step by step:

```dart
import 'package:solana_kit_functional/solana_kit_functional.dart';

final config = <String, Object?>{'version': 1}
    .pipe((c) => {...c, 'name': 'my-app'})
    .pipe((c) => {...c, 'debug': false})
    .pipe((c) => {...c, 'maxRetries': 3});
print(config);
// {version: 1, name: my-app, debug: false, maxRetries: 3}
```

### Building Solana transaction messages

The primary use case for `pipe` in the Solana Kit SDK is constructing transaction messages through a series of transformations. Each SDK function returns a new message, and `pipe` chains them together fluently:

```dart
import 'package:solana_kit_functional/solana_kit_functional.dart';

// Illustrative example showing the intended usage pattern.
// The actual transaction builder functions come from other solana_kit packages.
final message = createTransactionMessage(version: 0)
    .pipe(setTransactionMessageFeePayer(myAddress))
    .pipe(setTransactionMessageLifetimeUsingBlockhash(blockhash))
    .pipe(appendTransactionMessageInstruction(transferInstruction))
    .pipe(appendTransactionMessageInstruction(memoInstruction));
```

This pattern mirrors the TypeScript SDK, where the `pipe()` function from `@solana/functional` is used throughout to build transaction messages:

```typescript
// TypeScript equivalent from @solana/kit
const message = pipe(
  createTransactionMessage({ version: 0 }),
  tx => setTransactionMessageFeePayer(myAddress, tx),
  tx => setTransactionMessageLifetimeUsingBlockhash(blockhash, tx),
  tx => appendTransactionMessageInstruction(transferInstruction, tx),
);
```

### Combining lists

```dart
import 'package:solana_kit_functional/solana_kit_functional.dart';

final combined = [1]
    .pipe((list) => [...list, 2])
    .pipe((list) => [...list, 3])
    .pipe((list) => [...list, 4]);
print(combined); // [1, 2, 3, 4]
```

### Nested pipes

Pipes can be nested within other pipes for complex transformations:

```dart
import 'package:solana_kit_functional/solana_kit_functional.dart';

final result = 1
    .pipe((value) => value + 1)
    .pipe((value) => value * 2)
    .pipe((value) => value - 1)
    .pipe(
      (value) => value
          .pipe((v) => v.toString())
          .pipe((v) => '$v!'),
    )
    .pipe((value) => '$value##')
    .pipe((value) => '$value$value');
print(result); // 3!##3!##
```

### Passing named functions

You can pass any function reference directly to `pipe`, not just lambdas:

```dart
import 'package:solana_kit_functional/solana_kit_functional.dart';

Map<String, Object?> dropNulls(Map<String, Object?> map) {
  return Map.fromEntries(map.entries.where((e) => e.value != null));
}

final cleaned = <String, Object?>{'a': 1, 'b': null, 'c': 3}
    .pipe(dropNulls);
print(cleaned); // {a: 1, c: 3}
```

### Error propagation

Errors thrown inside a pipe step propagate naturally:

```dart
import 'package:solana_kit_functional/solana_kit_functional.dart';

try {
  'start'
      .pipe((value) => value.toUpperCase())
      .pipe((value) => throw Exception('Something went wrong'))
      .pipe((value) => '$value!'); // never reached
} on Exception catch (e) {
  print(e); // Exception: Something went wrong
}
```

## API Reference

### Extensions

- **`Pipe<T>` on `T`** -- Adds the `pipe` method to every Dart value.
  - `R pipe<R>(R Function(T value) transform)` -- Applies the given transform function to this value and returns the result.
