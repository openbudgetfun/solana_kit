# solana_kit_subscribable

[![pub package](https://img.shields.io/pub/v/solana_kit_subscribable.svg)](https://pub.dev/packages/solana_kit_subscribable)
[![docs](https://img.shields.io/badge/docs-pub.dev-0175C2.svg)](https://pub.dev/documentation/solana_kit_subscribable/latest/)
[![website](https://img.shields.io/badge/website-solana__kit__docs-0A7EA4.svg)](https://openbudgetfun.github.io/solana_kit/reference/package-catalog#solana_kit_subscribable)
[![CI](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml)
[![coverage](https://codecov.io/gh/openbudgetfun/solana_kit/branch/main/graph/badge.svg?flag=solana_kit_subscribable)](https://codecov.io/gh/openbudgetfun/solana_kit?flag=solana_kit_subscribable)

Subscribable and observable patterns for the Solana Kit Dart SDK -- a publish/subscribe event system with named channels, Dart `Stream` bridging, cancellation tokens, and event demultiplexing.

> [!NOTE]
> New Dart-facing APIs should prefer exposing `Stream`s directly. Use
> `CancellationToken` / `CancellationTokenSource` for cancellation, and
> `ChannelStreamController` for named-channel compatibility adapters.

This is the Dart port of [`@solana/subscribable`](https://github.com/anza-xyz/kit/tree/main/packages/subscribable) from the Solana TypeScript SDK.

<!-- {=packageInstallSection:"solana_kit_subscribable"} -->

## Installation

Install the package directly:

```yaml
dependencies:
  "solana_kit_subscribable": ^0.6.0
```

If your app uses several Solana Kit packages together, you can also depend on the umbrella package instead:

```bash
dart pub add solana_kit
```

Inside this monorepo, Dart workspace resolution uses the local package automatically.

<!-- {/packageInstallSection} -->

<!-- {=packageDocumentationSection:"solana_kit_subscribable"} -->

## Documentation

- Package page: https://pub.dev/packages/solana_kit_subscribable
- API reference: https://pub.dev/documentation/solana_kit_subscribable/latest/
- Workspace docs: https://openbudgetfun.github.io/solana_kit/
- Package catalog entry: https://openbudgetfun.github.io/solana_kit/reference/package-catalog#solana_kit_subscribable
- Source code: https://github.com/openbudgetfun/solana_kit/tree/main/packages/solana_kit_subscribable

For architecture notes, getting-started guides, and cross-package examples, start with the workspace docs site and then drill down into the package README and API reference.

<!-- {/packageDocumentationSection} -->

## Usage

### Preferred: expose Dart Streams

If you are designing a new Dart API, prefer returning `Stream<T>` directly.
Use the `ChannelStreamController` primitive in this package when you need
named channels internally while still exposing Dart `Stream`s to callers.

### Stream-native channel controllers

Use `ChannelStreamController` when you need named channels internally while still exposing Dart `Stream`s to callers.

```dart
import 'package:solana_kit_subscribable/solana_kit_subscribable.dart';

Future<void> main() async {
  final channels = ChannelStreamController();

  final subscription = channels.stream<String>('data').listen((message) {
    print('Got message: $message');
  });

  channels.add('data', 'hello');
  // Prints: Got message: hello

  await subscription.cancel();
  await channels.close();
}
```

### Cancellation tokens

Use `CancellationTokenSource` and `CancellationToken` to coordinate
cancellation across long-running operations. Multiple listeners can react to
the same cancellation via `CancellationToken.future`.

```dart
import 'package:solana_kit_subscribable/solana_kit_subscribable.dart';

void main() {
  final source = CancellationTokenSource();

  // Pass the token to operations that should observe cancellation.
  source.token.future.then((_) {
    print('Operation was cancelled: ${source.token.reason}');
  });

  // Trigger cancellation when ready.
  source.cancel('user requested');
  // Prints: Operation was cancelled: user requested
}
```

### Notification streams

`NotificationStreams` bundles a pair of broadcast streams -- `notifications`
and `errors` -- and is the standard transport contract for subscription
notification channels.

```dart
import 'dart:async';

import 'package:solana_kit_subscribable/solana_kit_subscribable.dart';

void main() {
  final messages = StreamController<Object?>.broadcast(sync: true);
  final errors = StreamController<Object?>.broadcast(sync: true);
  final streams = NotificationStreams(
    notifications: messages.stream,
    errors: errors.stream,
  );

  streams.notifications.listen((data) => print('Notification: $data'));
  streams.errors.listen((error) => print('Error: $error'));

  messages.add('hello');
  errors.add('something failed');
  // Prints:
  //   Notification: hello
  //   Error: something failed
}
```

### Combining data and error streams

The `createStreamFromDataAndErrorStreams` function creates a broadcast stream
that forwards values from a data stream and errors from an error stream.

```dart
import 'dart:async';

import 'package:solana_kit_subscribable/solana_kit_subscribable.dart';

void main() {
  final dataController = StreamController<String>.broadcast(sync: true);
  final errorController = StreamController<Object?>.broadcast(sync: true);

  final stream = createStreamFromDataAndErrorStreams<String>(
    dataStream: dataController.stream,
    errorStream: errorController.stream,
  );

  stream.listen(
    (message) => print('Got: $message'),
    onError: (Object error) => print('Error: $error'),
  );

  dataController.add('update 1');
  // Prints: Got: update 1

  errorController.add(StateError('connection lost'));
  // Prints: Error: Bad state: connection lost
}
```

### Demultiplexing streams

The `demultiplexStream` function splits a source stream into per-channel
broadcast streams. The source subscription is lazy -- it only starts when the
first destination listener subscribes and stops when the last listener
cancels.

```dart
import 'dart:async';

import 'package:solana_kit_subscribable/solana_kit_subscribable.dart';

void main() {
  final source = StreamController<Map<String, Object?>>.broadcast(sync: true);

  // Create a derived stream that only forwards messages for 'matched'.
  final stream = demultiplexStream<Map<String, Object?>, Object?>(
    source: source.stream,
    channelName: 'matched',
    messageTransformer: (message) {
      final channel = message['channel']! as String;
      return (channel, message['payload']);
    },
  );

  stream.listen((data) => print('Matched: $data'));

  source.add({'channel': 'ignored', 'payload': 'nope'});
  source.add({'channel': 'matched', 'payload': 'hello'});
  // Prints: Matched: hello
}
```

### Reactive stores

`ReactiveStore` tracks the latest data value and first error from a pair of
streams. `ReactiveStreamStore` adds lifecycle states (loading, loaded, error,
retrying) with optional retry support.

```dart
import 'dart:async';

import 'package:solana_kit_subscribable/solana_kit_subscribable.dart';

void main() {
  final dataController = StreamController<int>.broadcast(sync: true);
  final errorController = StreamController<Object?>.broadcast(sync: true);

  final store = createReactiveStoreFromStreams<int>(
    dataStream: dataController.stream,
    errorStream: errorController.stream,
  );

  store.subscribe(() {
    print('State: ${store.getState()}, Error: ${store.getError()}');
  });

  dataController.add(42);
  // Prints: State: 42, Error: null

  store.dispose();
}
```

## API Reference

### Interfaces

| Interface                 | Description                                                                                                  |
| ------------------------- | ------------------------------------------------------------------------------------------------------------ |
| `ChannelStreamController` | Stream-native named-channel controller for compatibility adapters that still need string-keyed channels.     |
| `CancellationToken`       | A readable token that completes when an operation is cancelled. Obtain one from a `CancellationTokenSource`. |
| `CancellationTokenSource` | A source that owns a `CancellationToken` and can cancel it.                                                  |
| `NotificationStreams`     | A pair of broadcast streams carrying subscription `notifications` and `errors`.                              |

### Factory functions

| Function                                                            | Description                                                                     |
| ------------------------------------------------------------------- | ------------------------------------------------------------------------------- |
| `createStreamFromDataAndErrorStreams<T>({dataStream, errorStream})` | Creates a broadcast `Stream<T>` from separate data and error streams.           |
| `demultiplexStream<TSource, TDestination>({...})`                   | Splits a source stream into one derived channel stream with lazy subscription.  |
| `createReactiveStoreFromStreams<T>({dataStream, errorStream})`      | Creates a `ReactiveStore<T>` backed by data and error streams.                  |
| `createReactiveStreamStore<T>({dataStream, errorStream, retry})`    | Creates a `ReactiveStreamStore<T>` backed by data and error streams with retry. |

### Type aliases

| Type                    | Description                                                                                                     |
| ----------------------- | --------------------------------------------------------------------------------------------------------------- |
| `UnsubscribeFn`         | `void Function()` -- returned by `subscribe()` to unsubscribe a listener.                                       |
| `Subscriber<T>`         | `void Function(T data)` -- a function that receives published data.                                             |
| `MessageTransformer<T>` | `(String, Object?)? Function(T)` -- transforms a source message into a channel/message pair, or `null` to drop. |

<!-- {=packageExampleSection|replace:"__PACKAGE__":"solana_kit_subscribable"|replace:"__EXAMPLE_PATH__":"example/main.dart"|replace:"__IMPORT_PATH__":"package:solana_kit_subscribable/solana_kit_subscribable.dart"} -->

## Example

Use [`example/main.dart`](./example/main.dart) as a runnable starting point for `solana_kit_subscribable`.

- Import path: `package:solana_kit_subscribable/solana_kit_subscribable.dart`
- This section is centrally maintained with `mdt` to keep package guidance aligned.
- After updating shared docs templates, run `docs:update` from the repo root.

## Maintenance

- Validate docs in CI and locally with `docs:check`.
- Keep examples focused on one workflow and reference package README sections for deeper API details.

<!-- {/packageExampleSection} -->
