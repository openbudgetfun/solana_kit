import 'dart:async';

import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_rpc_spec_types/solana_kit_rpc_spec_types.dart';
import 'package:solana_kit_rpc_subscriptions/src/rpc_subscriptions_transport.dart';
import 'package:solana_kit_rpc_subscriptions_api/solana_kit_rpc_subscriptions_api.dart';
import 'package:solana_kit_rpc_subscriptions_channel_websocket/solana_kit_rpc_subscriptions_channel_websocket.dart';
import 'package:solana_kit_subscribable/solana_kit_subscribable.dart';

/// Executes a JSON-RPC subscription and isolates its server notifications.
Future<NotificationStreams> executeRpcSubscription(
  RpcSubscriptionsTransportExecuteConfig config,
  String notificationName,
  List<Object?> params,
) {
  final signal = config.signal;
  if (signal.isCancelled) {
    return Future.error(signal.reason ?? const AbortError());
  }

  final request = createRpcMessage(
    RpcRequest(
      methodName: notificationNameToSubscribeMethod(notificationName),
      params: params,
    ),
  );
  final notificationMethod = notificationName.replaceFirst(
    RegExp(r'Notifications$'),
    'Notification',
  );
  final notifications = StreamController<Object?>(sync: true);
  final errors = StreamController<Object?>(sync: true);
  final ready = Completer<NotificationStreams>();
  final listeners = <StreamSubscription<Object?>>[];
  Object? subscriptionId;
  var disposed = false;
  var bufferedNotificationCount = 0;

  void dispose() {
    disposed = true;
    for (final listener in listeners) {
      unawaited(listener.cancel());
    }
    unawaited(notifications.close());
    unawaited(errors.close());
  }

  void fail(Object? error) {
    if (disposed) return;
    final failure =
        error ??
        SolanaError(SolanaErrorCode.rpcSubscriptionsChannelConnectionClosed);
    if (!ready.isCompleted) {
      ready.completeError(failure);
    } else if (!signal.isCancelled) {
      errors.add(failure);
    }
    dispose();
  }

  void unsubscribe() {
    // A pooled channel may already have closed when its final caller aborts.
    Future<void>.sync(
      () => config.channel.send(
        createRpcMessage(
          RpcRequest(
            methodName: notificationNameToUnsubscribeMethod(notificationName),
            params: [subscriptionId],
          ),
        ),
      ),
    ).ignore();
    dispose();
  }

  void receive(Object? message) {
    if (disposed ||
        message is! Map<String, Object?> ||
        message['jsonrpc'] != '2.0') {
      return;
    }
    if (subscriptionId == null && message['id'] == request['id']) {
      if (message.containsKey('error')) {
        fail(getSolanaErrorFromJsonRpcError(message['error']));
        return;
      }
      final id = message['result'];
      if (!_isSubscriptionId(id)) {
        fail(
          SolanaError(
            SolanaErrorCode.rpcSubscriptionsExpectedServerSubscriptionId,
          ),
        );
        return;
      }
      subscriptionId = id;
      if (signal.isCancelled) {
        unsubscribe();
      } else {
        ready.complete(
          NotificationStreams(
            notifications: notifications.stream.asBroadcastStream(),
            errors: errors.stream.asBroadcastStream(),
          ),
        );
      }
      return;
    }
    if (signal.isCancelled ||
        subscriptionId == null ||
        message['method'] != notificationMethod) {
      return;
    }
    final notification = message['params'];
    if (notification is! Map<String, Object?> ||
        !_isSubscriptionId(notification['subscription']) ||
        notification['subscription'].toString() != subscriptionId.toString()) {
      return;
    }
    if (!notification.containsKey('result')) {
      fail(const FormatException('Subscription notification has no result.'));
      return;
    }
    if (!notifications.hasListener && ++bufferedNotificationCount > 1024) {
      fail(
        StateError('Subscription notification buffer exceeded 1024 events.'),
      );
      return;
    }
    notifications.add(notification['result']);
  }

  final streams = config.channel.streams;
  listeners
    ..add(
      streams.notifications.listen(
        (message) {
          try {
            receive(message);
          } on Object catch (error) {
            fail(error);
          }
        },
        onError: fail,
        onDone: () => fail(null),
      ),
    )
    ..add(streams.errors.listen(fail, onError: fail));
  signal.future.then((_) {
    if (disposed) return;
    if (subscriptionId != null) {
      unsubscribe();
    } else {
      // Retain the channel listeners until a late acknowledgement or
      // channel closure so a server subscription cannot be abandoned.
      ready.completeError(signal.reason ?? const AbortError());
    }
  }).ignore();
  Future<void>.sync(() => config.channel.send(request))
      .then<void>(
        (_) {},
        onError: fail,
      )
      .ignore();
  return ready.future;
}

bool _isSubscriptionId(Object? value) =>
    (value is int && value >= 0) || (value is BigInt && !value.isNegative);
