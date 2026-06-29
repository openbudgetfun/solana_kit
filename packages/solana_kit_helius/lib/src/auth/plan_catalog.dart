/// Catalog of Helius billing plans with their pricing and limits.
class PlanInfo {
  /// Creates a [PlanInfo] with the given name, pricing, and limits.
  const PlanInfo({
    required this.name,
    required this.monthlyPrice,
    required this.yearlyPrice,
    required this.credits,
    required this.requestsPerSecond,
  });

  /// Display name of the plan.
  final String name;

  /// Monthly price in the smallest currency unit.
  final int monthlyPrice;

  /// Yearly price in the smallest currency unit.
  final int yearlyPrice;

  /// Number of credits included in the plan.
  final int credits;

  /// Maximum allowed requests per second for the plan.
  final int requestsPerSecond;
}

/// Catalog of available Helius plans keyed by plan identifier.
const planCatalog = <String, PlanInfo>{
  'developer': PlanInfo(
    name: 'Developer',
    monthlyPrice: 4900,
    yearlyPrice: 49000,
    credits: 10000000,
    requestsPerSecond: 50,
  ),
  'business': PlanInfo(
    name: 'Business',
    monthlyPrice: 49900,
    yearlyPrice: 499000,
    credits: 100000000,
    requestsPerSecond: 200,
  ),
  'professional': PlanInfo(
    name: 'Professional',
    monthlyPrice: 99900,
    yearlyPrice: 999000,
    credits: 200000000,
    requestsPerSecond: 500,
  ),
};

/// Mapping of Helius plan identifiers to usage plan identifiers.
const planToUsagePlan = <String, String>{
  'developer': 'developer_v4',
  'business': 'business_v4',
  'professional': 'professional_v4',
  'agent': 'agent_v4',
};
