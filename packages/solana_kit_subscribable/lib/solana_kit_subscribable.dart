/// Subscribable and observable patterns for the Solana Kit Dart SDK.
///
/// This package provides utilities for creating subscription-based event
/// systems. It is the Dart port of the TypeScript `@solana/subscribable`
/// package.
///
/// The primary components are:
///
/// - `ChannelStreamController` - a stream-native named-channel controller for
///   compatibility adapters.
/// - `createStreamFromDataAndErrorStreams` - combines data and error streams
///   into one broadcast stream.
/// - `demultiplexStream` - splits a source stream into lazily subscribed typed
///   channel streams.
/// - `DataPublisher` / `WritableDataPublisher` - deprecated compatibility
///   layers for the upstream TypeScript channel-publisher abstraction.
///
/// Prefer exposing `Stream`s at package boundaries when writing new Dart APIs.
/// Keep `DataPublisher`-based APIs only where they are still needed for
/// compatibility with the upstream Solana Kit design.
library;

export 'src/async_iterable.dart';
export 'src/data_publisher.dart';
export 'src/demultiplex.dart';
export 'src/reactive_store.dart';
