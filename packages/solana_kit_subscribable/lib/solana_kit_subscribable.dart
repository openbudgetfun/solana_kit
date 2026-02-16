/// Subscribable and observable patterns for the Solana Kit Dart SDK.
///
/// This package provides utilities for creating subscription-based event
/// systems. It is the Dart port of the TypeScript `@solana/subscribable`
/// package.
///
/// The primary components are:
///
/// - `DataPublisher` / `WritableDataPublisher` - subscription-based event
///   system with `on(channelName, subscriber)` returning an unsubscribe
///   function.
/// - `createStreamFromDataPublisher` / `createAsyncIterableFromDataPublisher` -
///   converts a `DataPublisher` into a Dart `Stream`.
/// - `demultiplexDataPublisher` - splits a single channel into multiple typed
///   channels with lazy subscription and reference counting.
library;

export 'src/async_iterable.dart';
export 'src/data_publisher.dart';
export 'src/demultiplex.dart';
