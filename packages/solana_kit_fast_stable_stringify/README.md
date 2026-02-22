# solana_kit_fast_stable_stringify

[![pub package](https://img.shields.io/pub/v/solana_kit_fast_stable_stringify.svg)](https://pub.dev/packages/solana_kit_fast_stable_stringify)
[![docs](https://img.shields.io/badge/docs-pub.dev-0175C2.svg)](https://pub.dev/documentation/solana_kit_fast_stable_stringify/latest/)
[![CI](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml)
[![coverage](https://codecov.io/gh/openbudgetfun/solana_kit/branch/main/graph/badge.svg)](https://codecov.io/gh/openbudgetfun/solana_kit)

Deterministic JSON serialization with sorted keys for the Solana Kit Dart SDK.

This is the Dart port of [`@solana/fast-stable-stringify`](https://github.com/anza-xyz/kit/tree/main/packages/fast-stable-stringify) from the Solana TypeScript SDK.

## Installation

Install with:

```bash
dart pub add solana_kit_fast_stable_stringify
```

If you are working within the `solana_kit` monorepo, the package resolves through the Dart workspace. Otherwise, specify a version or path as needed.

## Documentation

- Package page: https://pub.dev/packages/solana_kit_fast_stable_stringify
- API reference: https://pub.dev/documentation/solana_kit_fast_stable_stringify/latest/

## Usage

### Basic stringification

`fastStableStringify` works like `jsonEncode` but sorts object keys alphabetically, producing deterministic output regardless of insertion order.

```dart
import 'package:solana_kit_fast_stable_stringify/solana_kit_fast_stable_stringify.dart';

final json = fastStableStringify({
  'zebra': 1,
  'apple': 2,
  'mango': 3,
});
print(json); // {"apple":2,"mango":3,"zebra":1}
```

Compare with standard `jsonEncode`, which preserves insertion order:

```dart
import 'dart:convert';

// jsonEncode preserves insertion order -- non-deterministic.
print(jsonEncode({'zebra': 1, 'apple': 2, 'mango': 3}));
// {"zebra":1,"apple":2,"mango":3}
```

### Supported types

The function handles all common Dart types:

```dart
import 'package:solana_kit_fast_stable_stringify/solana_kit_fast_stable_stringify.dart';

// null
fastStableStringify(null);          // 'null'

// Booleans
fastStableStringify(true);          // 'true'
fastStableStringify(false);         // 'false'

// Integers
fastStableStringify(42);            // '42'
fastStableStringify(-1);            // '-1'

// Doubles
fastStableStringify(3.14);          // '3.14'
fastStableStringify(double.nan);    // 'null'  (non-finite becomes null)
fastStableStringify(double.infinity); // 'null'

// Strings (JSON-escaped)
fastStableStringify('hello');       // '"hello"'
fastStableStringify('line\nbreak'); // '"line\\nbreak"'

// BigInt (appends 'n' suffix, matching JavaScript BigInt convention)
fastStableStringify(BigInt.from(200)); // '200n'

// Lists (recursively stringified)
fastStableStringify([1, 'two', null]); // '[1,"two",null]'

// Maps with sorted keys (recursively stringified)
fastStableStringify({'b': 2, 'a': 1}); // '{"a":1,"b":2}'
```

### Nested structures

Keys are sorted at every level of nesting:

```dart
import 'package:solana_kit_fast_stable_stringify/solana_kit_fast_stable_stringify.dart';

final result = fastStableStringify({
  'users': [
    {'name': 'Alice', 'age': 30},
    {'name': 'Bob', 'age': 25},
  ],
  'count': 2,
});
print(result);
// {"count":2,"users":[{"age":30,"name":"Alice"},{"age":25,"name":"Bob"}]}
```

### BigInt handling

BigInt values are serialized with a trailing `n` suffix to match the JavaScript BigInt serialization convention. This is important for interoperability with the TypeScript SDK.

```dart
import 'package:solana_kit_fast_stable_stringify/solana_kit_fast_stable_stringify.dart';

final result = fastStableStringify({
  'age': BigInt.from(100),
  'name': 'Hrushi',
});
print(result); // {"age":100n,"name":"Hrushi"}

// BigInt values in arrays
final arrayResult = fastStableStringify({
  'values': [BigInt.from(100), BigInt.from(200), BigInt.from(300)],
});
print(arrayResult); // {"values":[100n,200n,300n]}
```

### Custom objects with `ToJsonable`

Classes that mix in `ToJsonable` and implement `toJson()` are automatically stringified by recursively processing the return value:

```dart
import 'package:solana_kit_fast_stable_stringify/solana_kit_fast_stable_stringify.dart';

class User with ToJsonable {
  User(this.name, this.age);

  final String name;
  final int age;

  @override
  Object? toJson() => {'name': name, 'age': age};
}

final result = fastStableStringify(User('Alice', 30));
print(result); // {"age":30,"name":"Alice"}
```

### Return value

`fastStableStringify` returns `String?`. It returns `null` for values that have no JSON representation (such as functions or objects without a `toJson()` method that cannot be encoded by `jsonEncode`).

```dart
import 'package:solana_kit_fast_stable_stringify/solana_kit_fast_stable_stringify.dart';

// Returns null for non-serializable top-level values.
final result = fastStableStringify(Object());
print(result); // null (if Object has no toJson and jsonEncode fails)

// Inside arrays, non-serializable values become 'null'.
final arrayResult = fastStableStringify([1, Object(), 3]);
print(arrayResult); // [1,null,3]
```

### Use case: request deduplication

The primary use of this function in the Solana Kit SDK is to produce stable cache keys for RPC request deduplication. Because the output is deterministic, two requests with the same parameters but different key ordering will produce the same string, allowing them to be correctly identified as duplicates.

```dart
import 'package:solana_kit_fast_stable_stringify/solana_kit_fast_stable_stringify.dart';

// These produce the same output regardless of key order.
final key1 = fastStableStringify({'method': 'getBalance', 'params': ['abc']});
final key2 = fastStableStringify({'params': ['abc'], 'method': 'getBalance'});
print(key1 == key2); // true
// Both: {"method":"getBalance","params":["abc"]}
```

## API Reference

### Functions

- **`fastStableStringify(Object? value)`** -- Returns a deterministic JSON string with sorted keys, or `null` if the value cannot be serialized.

### Mixins

- **`ToJsonable`** -- Mixin for classes that implement `Object? toJson()`. When an object with this mixin is passed to `fastStableStringify`, its `toJson()` return value is recursively stringified.
