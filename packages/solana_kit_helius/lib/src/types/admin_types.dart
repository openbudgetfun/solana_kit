// ignore_for_file: public_member_api_docs
import 'package:solana_kit_helius/src/internal/json_reader.dart';

class ProjectUsage {
  const ProjectUsage({
    required this.creditsRemaining,
    required this.creditsUsed,
    required this.prepaidCreditsRemaining,
    required this.prepaidCreditsUsed,
    required this.subscriptionDetails,
    required this.usage,
  });

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

  final int creditsRemaining;
  final int creditsUsed;
  final int prepaidCreditsRemaining;
  final int prepaidCreditsUsed;
  final AdminSubscriptionDetails subscriptionDetails;
  final AdminUsageBreakdown usage;

  Map<String, Object?> toJson() => {
    'creditsRemaining': creditsRemaining,
    'creditsUsed': creditsUsed,
    'prepaidCreditsRemaining': prepaidCreditsRemaining,
    'prepaidCreditsUsed': prepaidCreditsUsed,
    'subscriptionDetails': subscriptionDetails.toJson(),
    'usage': usage.toJson(),
  };
}

class AdminSubscriptionDetails {
  const AdminSubscriptionDetails({
    required this.billingCycle,
    required this.creditsLimit,
    required this.plan,
  });

  factory AdminSubscriptionDetails.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return AdminSubscriptionDetails(
      billingCycle: AdminBillingCycle.fromJson(r.requireMap('billingCycle')),
      creditsLimit: r.requireInt('creditsLimit'),
      plan: r.requireString('plan'),
    );
  }

  final AdminBillingCycle billingCycle;
  final int creditsLimit;
  final String plan;

  Map<String, Object?> toJson() => {
    'billingCycle': billingCycle.toJson(),
    'creditsLimit': creditsLimit,
    'plan': plan,
  };
}

class AdminBillingCycle {
  const AdminBillingCycle({required this.start, required this.end});

  factory AdminBillingCycle.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return AdminBillingCycle(
      start: r.requireString('start'),
      end: r.requireString('end'),
    );
  }

  final String start;
  final String end;

  Map<String, Object?> toJson() => {'start': start, 'end': end};
}

class AdminUsageBreakdown {
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

  final int api;
  final int archival;
  final int das;
  final int grpc;
  final int grpcGeyser;
  final int photon;
  final int rpc;
  final int stream;
  final int webhook;
  final int websocket;

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
