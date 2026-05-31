import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

void main() {
  group('admin types', () {
    test('ProjectUsage round-trips JSON', () {
      final usage = ProjectUsage.fromJson(projectUsageJson());

      expect(usage.creditsRemaining, 900);
      expect(usage.creditsUsed, 100);
      expect(usage.prepaidCreditsRemaining, 50);
      expect(usage.prepaidCreditsUsed, 10);
      expect(usage.subscriptionDetails.plan, 'business');
      expect(usage.subscriptionDetails.creditsLimit, 1000);
      expect(usage.subscriptionDetails.billingCycle.start, '2026-05-01');
      expect(usage.subscriptionDetails.billingCycle.end, '2026-06-01');
      expect(usage.usage.api, 1);
      expect(usage.usage.archival, 2);
      expect(usage.usage.das, 3);
      expect(usage.usage.grpc, 4);
      expect(usage.usage.grpcGeyser, 5);
      expect(usage.usage.photon, 6);
      expect(usage.usage.rpc, 7);
      expect(usage.usage.stream, 8);
      expect(usage.usage.webhook, 9);
      expect(usage.usage.websocket, 10);
      expect(usage.toJson(), projectUsageJson());
    });

    test('nested admin value objects serialize to JSON', () {
      const billingCycle = AdminBillingCycle(start: '2026-01-01', end: '2026-02-01');
      const subscription = AdminSubscriptionDetails(
        billingCycle: billingCycle,
        creditsLimit: 500,
        plan: 'developer',
      );
      const usage = AdminUsageBreakdown(
        api: 11,
        archival: 12,
        das: 13,
        grpc: 14,
        grpcGeyser: 15,
        photon: 16,
        rpc: 17,
        stream: 18,
        webhook: 19,
        websocket: 20,
      );
      const projectUsage = ProjectUsage(
        creditsRemaining: 400,
        creditsUsed: 100,
        prepaidCreditsRemaining: 90,
        prepaidCreditsUsed: 10,
        subscriptionDetails: subscription,
        usage: usage,
      );

      expect(billingCycle.toJson(), {'start': '2026-01-01', 'end': '2026-02-01'});
      expect(subscription.toJson(), {
        'billingCycle': {'start': '2026-01-01', 'end': '2026-02-01'},
        'creditsLimit': 500,
        'plan': 'developer',
      });
      expect(usage.toJson(), {
        'api': 11,
        'archival': 12,
        'das': 13,
        'grpc': 14,
        'grpcGeyser': 15,
        'photon': 16,
        'rpc': 17,
        'stream': 18,
        'webhook': 19,
        'websocket': 20,
      });
      expect(projectUsage.toJson(), {
        'creditsRemaining': 400,
        'creditsUsed': 100,
        'prepaidCreditsRemaining': 90,
        'prepaidCreditsUsed': 10,
        'subscriptionDetails': subscription.toJson(),
        'usage': usage.toJson(),
      });
    });
  });
}

Map<String, Object?> projectUsageJson() => {
  'creditsRemaining': 900,
  'creditsUsed': 100,
  'prepaidCreditsRemaining': 50,
  'prepaidCreditsUsed': 10,
  'subscriptionDetails': {
    'billingCycle': {'start': '2026-05-01', 'end': '2026-06-01'},
    'creditsLimit': 1000,
    'plan': 'business',
  },
  'usage': {
    'api': 1,
    'archival': 2,
    'das': 3,
    'grpc': 4,
    'grpcGeyser': 5,
    'photon': 6,
    'rpc': 7,
    'stream': 8,
    'webhook': 9,
    'websocket': 10,
  },
};
