import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_keys/solana_kit_keys.dart';
import 'package:solana_kit_rpc_subscriptions/src/rpc_subscriptions.dart';
import 'package:solana_kit_rpc_subscriptions_api/solana_kit_rpc_subscriptions_api.dart';

/// Typed convenience methods for common Solana RPC subscription requests.
///
/// These helpers wrap [RpcSubscriptions.request] so callers can rely on
/// method-specific parameter builders instead of assembling notification names
/// and positional params by hand.
extension SolanaRpcSubscriptionsMethods on RpcSubscriptions {
  /// Creates a pending account notification subscription request.
  PendingRpcSubscriptionsRequest<Object?> accountNotifications(
    Address address, [
    AccountNotificationsConfig? config,
  ]) {
    return request(
      'accountNotifications',
      accountNotificationsParams(address, config),
    );
  }

  /// Creates a pending block notification subscription request.
  ///
  /// This subscription is unstable and may not be available on every node.
  PendingRpcSubscriptionsRequest<Object?> blockNotifications(
    BlockNotificationsFilter filter, [
    BlockNotificationsConfig? config,
  ]) {
    return request(
      'blockNotifications',
      blockNotificationsParams(filter, config),
    );
  }

  /// Creates a pending logs notification subscription request.
  PendingRpcSubscriptionsRequest<Object?> logsNotifications(
    LogsFilter filter, [
    LogsNotificationsConfig? config,
  ]) {
    return request(
      'logsNotifications',
      logsNotificationsParams(filter, config),
    );
  }

  /// Creates a pending program notification subscription request.
  PendingRpcSubscriptionsRequest<Object?> programNotifications(
    Address programId, [
    ProgramNotificationsConfig? config,
  ]) {
    return request(
      'programNotifications',
      programNotificationsParams(programId, config),
    );
  }

  /// Creates a pending root notification subscription request.
  PendingRpcSubscriptionsRequest<Object?> rootNotifications() {
    return request('rootNotifications', rootNotificationsParams());
  }

  /// Creates a pending signature notification subscription request.
  PendingRpcSubscriptionsRequest<Object?> signatureNotifications(
    Signature signature, [
    SignatureNotificationsConfig? config,
  ]) {
    return request(
      'signatureNotifications',
      signatureNotificationsParams(signature, config),
    );
  }

  /// Creates a pending slot notification subscription request.
  PendingRpcSubscriptionsRequest<Object?> slotNotifications() {
    return request('slotNotifications', slotNotificationsParams());
  }

  /// Creates a pending slots-updates notification subscription request.
  ///
  /// This subscription is unstable and may not be available on every node.
  PendingRpcSubscriptionsRequest<Object?> slotsUpdatesNotifications() {
    return request(
      'slotsUpdatesNotifications',
      slotsUpdatesNotificationsParams(),
    );
  }

  /// Creates a pending vote notification subscription request.
  ///
  /// This subscription is unstable and may not be available on every node.
  PendingRpcSubscriptionsRequest<Object?> voteNotifications() {
    return request('voteNotifications', voteNotificationsParams());
  }
}
