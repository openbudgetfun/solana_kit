/// Subscribable and observable patterns for the Solana Kit Dart SDK.
///
/// This package provides utilities for creating subscription-based event
/// systems. It is the Dart port of the TypeScript `@solana/subscribable`
/// package.
///
/// The primary components are:
///
/// - `CancellationToken` / `CancellationTokenSource` - a Dart-native
///   cancellation token pair for long-running operations.
/// - `NotificationStreams` - a pair of broadcast streams carrying
///   subscription notifications and errors.
/// - `ChannelStreamController` - a stream-native named-channel controller for
///   compatibility adapters.
/// - `createStreamFromDataAndErrorStreams` - combines data and error streams
///   into one broadcast stream.
/// - `demultiplexStream` - splits a source stream into lazily subscribed typed
///   channel streams.
/// - `ReactiveActionStore` - a reactive store for dispatchable actions (e.g.
///   RPC requests) with idle/running/success/error states.
/// - `ReactiveStreamStore` - a reactive store for streaming data with
///   loading/loaded/error/retry states.
///
/// Prefer exposing `Stream`s at package boundaries when writing new Dart APIs.
library;

export 'src/async_iterable.dart';
export 'src/cancellation_token.dart';
export 'src/data_publisher.dart';
export 'src/demultiplex.dart';
export 'src/notification_streams.dart';
export 'src/reactive_action_store.dart';
export 'src/reactive_store.dart';
export 'src/reactive_stream_store.dart';
