import 'dart:async';

/// A plugin that transforms a Solana Kit client value.
///
/// Plugins may return synchronously or asynchronously. Use [SolanaKitClient.use]
/// to compose them without having to split sync and async plugin pipelines.
typedef ClientPlugin<TInput extends Object, TOutput extends Object> =
    FutureOr<TOutput> Function(TInput client);

/// A Dart-native client builder for composing Solana Kit capabilities.
///
/// The TypeScript SDK models clients as object literals augmented by plugins.
/// Dart applications are better served by composing typed values, so this
/// wrapper stores the current client [value] and lets each plugin return the
/// next typed value.
final class SolanaKitClient<T extends Object> {
  const SolanaKitClient._(this.value);

  /// The current client value.
  final T value;

  /// Applies [plugin] to this client.
  ///
  /// The returned future resolves to the next typed client value whether the
  /// plugin itself completes synchronously or asynchronously.
  Future<SolanaKitClient<TOutput>> use<TOutput extends Object>(
    ClientPlugin<T, TOutput> plugin,
  ) async {
    return createClient<TOutput>(await plugin(value));
  }
}

/// Creates a new client builder.
///
/// When [value] is omitted, the client starts with an empty, immutable map.
SolanaKitClient<T> createClient<T extends Object>([T? value]) {
  final clientValue = value ?? const <String, Object?>{};
  return SolanaKitClient<T>._(clientValue as T);
}

/// Extends a map-backed client with [additions].
///
/// This mirrors the upstream `extendClient` helper for Dart's common map-backed
/// client shape. Keys in [additions] replace keys in [client]. The returned map
/// is immutable.
Map<K, V> extendClient<K, V>(Map<K, V> client, Map<K, V> additions) {
  return Map<K, V>.unmodifiable({...client, ...additions});
}

/// A client value paired with cleanup logic.
final class CleanableClient<T extends Object> {
  /// Creates a cleanable client wrapper.
  const CleanableClient({required this.value, required this.cleanup});

  /// The wrapped client value.
  final T value;

  /// The cleanup callback registered for this client.
  final FutureOr<void> Function() cleanup;

  /// Runs the registered cleanup callback.
  FutureOr<void> dispose() => cleanup();
}

/// Wraps [client] with [cleanup] logic.
CleanableClient<T> withCleanup<T extends Object>(
  T client,
  FutureOr<void> Function() cleanup,
) {
  return CleanableClient<T>(value: client, cleanup: cleanup);
}
