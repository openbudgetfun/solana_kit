import 'dart:async';

/// A readable token that completes when an operation is cancelled.
///
/// Obtain one from a [CancellationTokenSource] and pass it to long-running
/// operations so they can observe cancellation. Multiple listeners can react
/// to the same cancellation via [future].
class CancellationToken {
  CancellationToken._(this._completer);

  final Completer<void> _completer;
  bool _isCancelled = false;
  Object? _reason;

  /// Whether this token has been cancelled.
  bool get isCancelled => _isCancelled;

  /// The reason the token was cancelled, if any.
  Object? get reason => _reason;

  /// A future that completes when the token is cancelled.
  Future<void> get future => _completer.future;
}

/// A source that owns a [CancellationToken] and can cancel it.
class CancellationTokenSource {
  /// Creates a new source with a fresh [CancellationToken].
  CancellationTokenSource() : token = CancellationToken._(Completer<void>());

  /// The token associated with this source.
  final CancellationToken token;

  /// Cancels the token with an optional [reason].
  void cancel([Object? reason]) {
    if (token._isCancelled) return;
    token._isCancelled = true;
    token._reason = reason;
    if (!token._completer.isCompleted) {
      token._completer.complete();
    }
  }
}
