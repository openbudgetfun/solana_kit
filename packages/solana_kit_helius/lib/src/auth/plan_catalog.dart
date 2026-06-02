// ignore_for_file: public_member_api_docs

class PlanInfo {
  const PlanInfo({
    required this.name,
    required this.monthlyPrice,
    required this.yearlyPrice,
    required this.credits,
    required this.requestsPerSecond,
  });

  final String name;
  final int monthlyPrice;
  final int yearlyPrice;
  final int credits;
  final int requestsPerSecond;
}

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

const planToUsagePlan = <String, String>{
  'developer': 'developer_v4',
  'business': 'business_v4',
  'professional': 'professional_v4',
  'agent': 'agent_v4',
};
