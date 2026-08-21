# solana_kit_subscribable

[![pub package](https://img.shields.io/pub/v/solana_kit_subscribable.svg)](https://pub.dev/packages/solana_kit_subscribable) [![docs](https://img.shields.io/badge/docs-pub.dev-0175C2.svg)](https://pub.dev/documentation/solana_kit_subscribable/latest/) [![website](https://img.shields.io/badge/website-solana__kit__docs-0A7EA4.svg)](https://openbudgetfun.github.io/solana_kit/reference/package-catalog#solana_kit_subscribable) [![CI](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml) [![coverage](https://codecov.io/gh/openbudgetfun/solana_kit/branch/main/graph/badge.svg?flag=solana_kit_subscribable)](https://codecov.io/gh/openbudgetfun/solana_kit?flag=solana_kit_subscribable)

Pub/sub event primitives with named channels, Dart `Stream` bridging, cancellation tokens, and reactive stores.

> [!NOTE]
> New Dart-facing APIs should prefer exposing `Stream`s directly. Use `CancellationToken` / `CancellationTokenSource` for cancellation, and `ChannelStreamController` for named-channel compatibility adapters.

<!-- {=packageInstallSection:"solana_kit_subscribable"} -->

## Installation

Install the package directly:

```yaml
dependencies:
  "solana_kit_subscribable": ^0.8.0
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

Use `CancellationTokenSource` and `CancellationToken` to coordinate cancellation across long-running operations. Multiple listeners can react to the same cancellation via `CancellationToken.future`.

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

### Reactive action stores

`createReactiveActionStore` wraps an asynchronous action in an idle/running/success/error state machine. The action receives a fresh `CancellationToken` and the dispatch arguments. A newer dispatch, `reset()`, or `dispose()` cancels the active token and suppresses late results.

```dart
import 'package:solana_kit_subscribable/solana_kit_subscribable.dart';

Future<void> main() async {
  final store = createReactiveActionStore<List<Object?>, String>(
    (signal, args) async {
      await Future<void>.delayed(const Duration(milliseconds: 10));
      if (signal.isCancelled) throw signal.reason!;
      return args.single! as String;
    },
  );

  final timeout = CancellationTokenSource();
  final result = await store
      .withSignal(timeout.token)
      .dispatchAsync(['account']);
  print(result);
}
```

Use `dispatch()` for fire-and-forget UI handlers; it consumes asynchronous errors after recording them in store state. Use `dispatchAsync()` when the caller needs the result or propagated errors. Caller cancellation is exposed as an error state, while cancellation caused by supersession, reset, or disposal does not overwrite the newer state.

### Notification streams

`NotificationStreams` bundles a pair of broadcast streams (notifications and errors) as the standard transport contract for subscription notification channels.

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

`createStreamFromDataAndErrorStreams` creates a broadcast stream that forwards values from a data stream and errors from an error stream.

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

`demultiplexStream` splits a source stream into per-channel broadcast streams. The source subscription is lazy: it only starts when the first destination listener subscribes and stops when the last listener cancels.

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

`ReactiveStreamStore` tracks the lifecycle of an async data source with loading, loaded, error, and retrying states. Create one by providing a `createDataPublisher` factory function that returns a `ReactiveStreamConnection` for each subscription.

```dart
import 'dart:async';

import 'package:solana_kit_subscribable/solana_kit_subscribable.dart';

void main() {
  final store = createReactiveStreamStore<int>(
    createDataPublisher: (signal) async => ReactiveStreamConnection(
      dataStream: Stream.value(42),
      errorStream: Stream.empty(),
    ),
  );

  store.subscribe(() {
    final snapshot = store.getState();
    print('State: ${snapshot.data}');
  });

  store.dispose();
}
```

## API reference

### Interfaces

| Interface                 | Description                                                                                                  |
| ------------------------- | ------------------------------------------------------------------------------------------------------------ |
| `ChannelStreamController` | Stream-native named-channel controller for compatibility adapters that still need string-keyed channels.     |
| `CancellationToken`       | A readable token that completes when an operation is cancelled. Obtain one from a `CancellationTokenSource`. |
| `CancellationTokenSource` | A source that owns a `CancellationToken` and can cancel it.                                                  |
| `NotificationStreams`     | A pair of broadcast streams carrying subscription `notifications` and `errors`.                              |

### Factory functions

| Function                                                            | Description                                                                    |
| ------------------------------------------------------------------- | ------------------------------------------------------------------------------ |
| `createStreamFromDataAndErrorStreams<T>({dataStream, errorStream})` | Creates a broadcast `Stream<T>` from separate data and error streams.          |
| `demultiplexStream<TSource, TDestination>({...})`                   | Splits a source stream into one derived channel stream with lazy subscription. |
| `createReactiveStreamStore<T>({createDataPublisher})`               | Creates a `ReactiveStreamStore<T>` from a data publisher factory function.     |

### Type aliases

| Type                    | Description                                                                                                  |
| ----------------------- | ------------------------------------------------------------------------------------------------------------ |
| `UnsubscribeFn`         | `void Function()` returned by `subscribe()` to unsubscribe a listener.                                       |
| `Subscriber<T>`         | `void Function(T data)` receives published data.                                                             |
| `MessageTransformer<T>` | `(String, Object?)? Function(T)` transforms a source message into a channel/message pair, or `null` to drop. |

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
