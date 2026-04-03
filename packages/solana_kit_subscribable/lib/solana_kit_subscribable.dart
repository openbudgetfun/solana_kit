/// Subscribable and observable patterns for the Solana Kit Dart SDK.
///
/// This package provides utilities for creating subscription-based event
/// systems. It is the Dart port of the TypeScript `@solana/subscribable`
/// package.
///
/// The primary components are:
///
/// - `createStreamFromDataPublisher` / `createAsyncIterableFromDataPublisher` -
///   converts channel-based publishers into Dart `Stream`s.
/// - `DataPublisher` / `WritableDataPublisher` - a compatibility layer for the
///   upstream TypeScript channel-publisher abstraction.
/// - `demultiplexDataPublisher` - splits a single channel into multiple typed
///   channels with lazy subscription and reference counting.
///
/// Prefer exposing `Stream`s at package boundaries when writing new Dart APIs.
/// Keep `DataPublisher`-based APIs only where they are still needed for
/// compatibility with the upstream Solana Kit design.
library;

export 'src/async_iterable.dart';
export 'src/data_publisher.dart';
export 'src/demultiplex.dart';
