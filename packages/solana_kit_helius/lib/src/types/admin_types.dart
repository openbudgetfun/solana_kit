import 'package:solana_kit_helius/src/internal/json_reader.dart';

/// Usage and credit information for a Helius project.
class ProjectUsage {
  /// Creates a project usage summary.
  const ProjectUsage({
    required this.creditsRemaining,
    required this.creditsUsed,
    required this.prepaidCreditsRemaining,
    required this.prepaidCreditsUsed,
    required this.subscriptionDetails,
    required this.usage,
  });

  /// Creates a [ProjectUsage] from a JSON map.
  factory ProjectUsage.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return ProjectUsage(
      creditsRemaining: r.requireInt('creditsRemaining'),
      creditsUsed: r.requireInt('creditsUsed'),
      prepaidCreditsRemaining: r.requireInt('prepaidCreditsRemaining'),
      prepaidCreditsUsed: r.requireInt('prepaidCreditsUsed'),
      subscriptionDetails: AdminSubscriptionDetails.fromJson(
        r.requireMap('subscriptionDetails'),
      ),
      usage: AdminUsageBreakdown.fromJson(r.requireMap('usage')),
    );
  }

  /// Subscription credits remaining for the billing cycle.
  final int creditsRemaining;

  /// Subscription credits used in the billing cycle.
  final int creditsUsed;

  /// Prepaid credits remaining on the project.
  final int prepaidCreditsRemaining;

  /// Prepaid credits used on the project.
  final int prepaidCreditsUsed;

  /// Details of the project's subscription plan.
  final AdminSubscriptionDetails subscriptionDetails;

  /// Breakdown of API usage by service.
  final AdminUsageBreakdown usage;

  /// Serializes this project usage to a JSON map.
  Map<String, Object?> toJson() => {
    'creditsRemaining': creditsRemaining,
    'creditsUsed': creditsUsed,
    'prepaidCreditsRemaining': prepaidCreditsRemaining,
    'prepaidCreditsUsed': prepaidCreditsUsed,
    'subscriptionDetails': subscriptionDetails.toJson(),
    'usage': usage.toJson(),
  };
}

/// Subscription details for a Helius project.
class AdminSubscriptionDetails {
  /// Creates subscription details.
  const AdminSubscriptionDetails({
    required this.billingCycle,
    required this.creditsLimit,
    required this.plan,
  });

  /// Creates an [AdminSubscriptionDetails] from a JSON map.
  factory AdminSubscriptionDetails.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return AdminSubscriptionDetails(
      billingCycle: AdminBillingCycle.fromJson(r.requireMap('billingCycle')),
      creditsLimit: r.requireInt('creditsLimit'),
      plan: r.requireString('plan'),
    );
  }

  /// Billing cycle for the subscription.
  final AdminBillingCycle billingCycle;

  /// Credit limit granted by the subscription plan.
  final int creditsLimit;

  /// Name of the subscription plan.
  final String plan;

  /// Serializes these subscription details to a JSON map.
  Map<String, Object?> toJson() => {
    'billingCycle': billingCycle.toJson(),
    'creditsLimit': creditsLimit,
    'plan': plan,
  };
}

/// Billing cycle window for a subscription.
class AdminBillingCycle {
  /// Creates a billing cycle.
  const AdminBillingCycle({required this.start, required this.end});

  /// Creates an [AdminBillingCycle] from a JSON map.
  factory AdminBillingCycle.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return AdminBillingCycle(
      start: r.requireString('start'),
      end: r.requireString('end'),
    );
  }

  /// Start timestamp of the billing cycle.
  final String start;

  /// End timestamp of the billing cycle.
  final String end;

  /// Serializes this billing cycle to a JSON map.
  Map<String, Object?> toJson() => {'start': start, 'end': end};
}

/// Per-service usage breakdown for a Helius project.
class AdminUsageBreakdown {
  /// Creates a usage breakdown.
  const AdminUsageBreakdown({
    required this.api,
    required this.archival,
    required this.das,
    required this.grpc,
    required this.grpcGeyser,
    required this.photon,
    required this.rpc,
    required this.stream,
    required this.webhook,
    required this.websocket,
  });

  /// Creates an [AdminUsageBreakdown] from a JSON map.
  factory AdminUsageBreakdown.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return AdminUsageBreakdown(
      api: r.requireInt('api'),
      archival: r.requireInt('archival'),
      das: r.requireInt('das'),
      grpc: r.requireInt('grpc'),
      grpcGeyser: r.requireInt('grpcGeyser'),
      photon: r.requireInt('photon'),
      rpc: r.requireInt('rpc'),
      stream: r.requireInt('stream'),
      webhook: r.requireInt('webhook'),
      websocket: r.requireInt('websocket'),
    );
  }

  /// Number of API requests used.
  final int api;

  /// Number of archival requests used.
  final int archival;

  /// Number of DAS requests used.
  final int das;

  /// Number of gRPC requests used.
  final int grpc;

  /// Number of gRPC Geyser requests used.
  final int grpcGeyser;

  /// Number of Photon requests used.
  final int photon;

  /// Number of RPC requests used.
  final int rpc;

  /// Number of stream requests used.
  final int stream;

  /// Number of webhook requests used.
  final int webhook;

  /// Number of websocket requests used.
  final int websocket;

  /// Serializes this usage breakdown to a JSON map.
  Map<String, Object?> toJson() => {
    'api': api,
    'archival': archival,
    'das': das,
    'grpc': grpc,
    'grpcGeyser': grpcGeyser,
    'photon': photon,
    'rpc': rpc,
    'stream': stream,
    'webhook': webhook,
    'websocket': websocket,
  };
}
