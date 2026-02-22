# solana_kit_subscribable

[![pub package](https://img.shields.io/pub/v/solana_kit_subscribable.svg)](https://pub.dev/packages/solana_kit_subscribable)
[![docs](https://img.shields.io/badge/docs-pub.dev-0175C2.svg)](https://pub.dev/documentation/solana_kit_subscribable/latest/)
[![CI](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml)
[![coverage](https://codecov.io/gh/openbudgetfun/solana_kit/branch/main/graph/badge.svg)](https://codecov.io/gh/openbudgetfun/solana_kit)

Subscribable and observable patterns for the Solana Kit Dart SDK -- a publish/subscribe event system with named channels, Dart `Stream` bridging, and event demultiplexing.

This is the Dart port of [`@solana/subscribable`](https://github.com/anza-xyz/kit/tree/main/packages/subscribable) from the Solana TypeScript SDK.

## Installation

Add `solana_kit_subscribable` to your `pubspec.yaml`:

```yaml
dependencies:
  solana_kit_subscribable:
```

Or, if you are using the umbrella package:

```yaml
dependencies:
  solana_kit:
```

## Documentation

- Package page: https://pub.dev/packages/solana_kit_subscribable
- API reference: https://pub.dev/documentation/solana_kit_subscribable/latest/

## Usage

### Creating a data publisher

The `createDataPublisher()` factory returns a `WritableDataPublisher` that supports both subscribing to and publishing data on named channels.

```dart
import 'package:solana_kit_subscribable/solana_kit_subscribable.dart';

void main() {
  final publisher = createDataPublisher();

  // Subscribe to the 'data' channel.
  final unsubscribe = publisher.on('data', (message) {
    print('Got message: $message');
  });

  // Publish a message.
  publisher.publish('data', 'hello');
  // Prints: Got message: hello

  publisher.publish('data', 'world');
  // Prints: Got message: world

  // Unsubscribe -- idempotent and safe to call multiple times.
  unsubscribe();

  // This message is not received.
  publisher.publish('data', 'ignored');
}
```

### Multiple channels and subscribers

A single publisher supports multiple named channels, and each channel can have multiple subscribers.

```dart
import 'package:solana_kit_subscribable/solana_kit_subscribable.dart';

void main() {
  final publisher = createDataPublisher();

  // Subscribe to different channels.
  publisher.on('message', (data) {
    print('Message: $data');
  });

  publisher.on('error', (data) {
    print('Error: $data');
  });

  publisher.on('message', (data) {
    print('Also got: $data');
  });

  publisher.publish('message', 'hello');
  // Prints:
  //   Message: hello
  //   Also got: hello

  publisher.publish('error', 'something failed');
  // Prints:
  //   Error: something failed
}
```

### Converting a data publisher to a Dart Stream

The `createStreamFromDataPublisher` function bridges the `DataPublisher` pattern to Dart's native `Stream` API. It creates a broadcast stream that forwards messages from a data channel and errors from an error channel.

```dart
import 'package:solana_kit_subscribable/solana_kit_subscribable.dart';

void main() {
  final publisher = createDataPublisher();

  final stream = createStreamFromDataPublisher<String>(
    StreamFromDataPublisherConfig(
      dataChannelName: 'notification',
      dataPublisher: publisher,
      errorChannelName: 'error',
    ),
  );

  stream.listen(
    (message) => print('Got: $message'),
    onError: (Object error) => print('Error: $error'),
  );

  // Messages are forwarded to the stream.
  publisher.publish('notification', 'update 1');
  // Prints: Got: update 1

  publisher.publish('notification', 'update 2');
  // Prints: Got: update 2

  // Errors are forwarded as stream errors.
  publisher.publish('error', StateError('connection lost'));
  // Prints: Error: Bad state: connection lost
}
```

### Async iterable from a data publisher

The `createAsyncIterableFromDataPublisher` function creates a single-subscription `Stream` that closely matches the TypeScript async iterable behavior. It supports abort signals for lifecycle control.

```dart
import 'dart:async';

import 'package:solana_kit_subscribable/solana_kit_subscribable.dart';

void main() async {
  final publisher = createDataPublisher();
  final abortCompleter = Completer<void>();

  final stream = createAsyncIterableFromDataPublisher<String>(
    dataPublisher: publisher,
    dataChannelName: 'message',
    errorChannelName: 'error',
    abortSignal: abortCompleter.future,
  );

  // Publish some messages first (they will be queued until listened to).
  publisher.publish('message', 'first');
  publisher.publish('message', 'second');

  // Listen with await for.
  var count = 0;
  await for (final message in stream) {
    print('Got: $message');
    count++;
    if (count >= 2) {
      abortCompleter.complete(); // Stop the stream.
    }
  }
  // Prints:
  //   Got: first
  //   Got: second
}
```

### Demultiplexing events

The `demultiplexDataPublisher` function splits a single source channel into multiple derived channels using a message transformer. The source subscription is lazy -- it only starts when the first subscriber appears and stops when the last one unsubscribes.

```dart
import 'package:solana_kit_subscribable/solana_kit_subscribable.dart';

void main() {
  final sourcePublisher = createDataPublisher();

  // Create a demultiplexed publisher that routes by subscriber ID.
  final demuxed = demultiplexDataPublisher<Map<String, Object?>>(
    sourcePublisher: sourcePublisher,
    sourceChannelName: 'message',
    messageTransformer: (message) {
      final id = message['subscriberId'] as String;
      return ('notification-for:$id', message);
    },
  );

  // Subscribe to notifications for specific subscriber IDs.
  final unsub1 = demuxed.on('notification-for:abc', (data) {
    print('Subscriber abc got: $data');
  });

  demuxed.on('notification-for:xyz', (data) {
    print('Subscriber xyz got: $data');
  });

  // Publish to the source -- messages are routed to the right subscribers.
  sourcePublisher.publish('message', {
    'subscriberId': 'abc',
    'value': 42,
  });
  // Prints: Subscriber abc got: {subscriberId: abc, value: 42}

  sourcePublisher.publish('message', {
    'subscriberId': 'xyz',
    'value': 99,
  });
  // Prints: Subscriber xyz got: {subscriberId: xyz, value: 99}

  // When all subscribers unsubscribe, the source subscription is cancelled.
  unsub1();
}
```

## API Reference

### Interfaces

| Interface               | Description                                                                                      |
| ----------------------- | ------------------------------------------------------------------------------------------------ |
| `DataPublisher`         | Subscribe to named channels via `on(channelName, subscriber)`, which returns an `UnsubscribeFn`. |
| `WritableDataPublisher` | Extends `DataPublisher` with `publish(channelName, data)` for emitting events.                   |

### Factory functions

| Function                                                                                | Description                                                                                  |
| --------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------- |
| `createDataPublisher()`                                                                 | Creates a new `WritableDataPublisher` with named channel support.                            |
| `createStreamFromDataPublisher<T>(config)`                                              | Creates a broadcast `Stream<T>` from a `DataPublisher`.                                      |
| `createAsyncIterableFromDataPublisher<T>({...})`                                        | Creates a single-subscription `Stream<T>` with abort signal support.                         |
| `demultiplexDataPublisher<T>({sourcePublisher, sourceChannelName, messageTransformer})` | Splits one channel into many derived channels with lazy subscription and reference counting. |

### Type aliases

| Type                    | Description                                                                                                     |
| ----------------------- | --------------------------------------------------------------------------------------------------------------- |
| `UnsubscribeFn`         | `void Function()` -- returned by `on()` to unsubscribe a listener.                                              |
| `Subscriber<T>`         | `void Function(T data)` -- a function that receives published data.                                             |
| `MessageTransformer<T>` | `(String, Object?)? Function(T)` -- transforms a source message into a channel/message pair, or `null` to drop. |

### Configuration classes

| Class                           | Description                                                                                                |
| ------------------------------- | ---------------------------------------------------------------------------------------------------------- |
| `StreamFromDataPublisherConfig` | Configuration for `createStreamFromDataPublisher`: `dataChannelName`, `dataPublisher`, `errorChannelName`. |
