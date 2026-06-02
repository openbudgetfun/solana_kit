import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

void main() {
  group('planCatalog', () {
    test('has developer, business, and professional plans', () {
      expect(
        planCatalog.keys,
        containsAll(['developer', 'business', 'professional']),
      );
    });

    test('each plan has required fields', () {
      for (final plan in planCatalog.values) {
        expect(plan.name, isNotEmpty);
        expect(plan.monthlyPrice, greaterThan(0));
        expect(plan.yearlyPrice, greaterThan(0));
        expect(plan.credits, greaterThan(0));
        expect(plan.requestsPerSecond, greaterThan(0));
      }
    });

    test('contains upstream v3 catalog values', () {
      final developer = planCatalog['developer']!;
      final business = planCatalog['business']!;
      final professional = planCatalog['professional']!;

      expect(developer.monthlyPrice, 4900);
      expect(developer.yearlyPrice, 49000);
      expect(developer.credits, 10000000);
      expect(developer.requestsPerSecond, 50);
      expect(business.monthlyPrice, 49900);
      expect(business.yearlyPrice, 499000);
      expect(business.credits, 100000000);
      expect(business.requestsPerSecond, 200);
      expect(professional.monthlyPrice, 99900);
      expect(professional.yearlyPrice, 999000);
      expect(professional.credits, 200000000);
      expect(professional.requestsPerSecond, 500);
    });
  });

  group('planToUsagePlan', () {
    test('maps all catalog plans to backend config keys', () {
      expect(planToUsagePlan['developer'], 'developer_v4');
      expect(planToUsagePlan['business'], 'business_v4');
      expect(planToUsagePlan['professional'], 'professional_v4');
      expect(planToUsagePlan['agent'], 'agent_v4');
    });

    test('has entries for all plans in planCatalog', () {
      for (final key in planCatalog.keys) {
        expect(planToUsagePlan[key], isNotNull);
      }
    });
  });
}
