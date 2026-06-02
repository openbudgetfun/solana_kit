// ignore_for_file: public_member_api_docs

import 'dart:io' show Platform;

const heliusPaymentHost = 'https://dashboard.helius.dev';

String resolvePaymentHost({
  String? override,
  Map<String, String>? environment,
}) {
  final explicit = override;
  if (explicit != null && explicit.isNotEmpty) {
    return _stripTrailingSlash(explicit);
  }

  final value = (environment ?? Platform.environment)['HELIUS_PAYMENT_HOST'];
  if (value != null && value.isNotEmpty) return _stripTrailingSlash(value);

  return heliusPaymentHost;
}

String buildPaymentUrl(String paymentIntentId, {String? hostOverride}) {
  return '${resolvePaymentHost(override: hostOverride)}/pay/$paymentIntentId';
}

String _stripTrailingSlash(String value) =>
    value.endsWith('/') ? value.substring(0, value.length - 1) : value;
