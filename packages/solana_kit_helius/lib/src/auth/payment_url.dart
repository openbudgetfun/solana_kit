import 'dart:io' show Platform;

/// Default base URL for the Helius payment dashboard.
const heliusPaymentHost = 'https://dashboard.helius.dev';

/// Resolves the payment host, preferring an [override] or the
/// `HELIUS_PAYMENT_HOST` environment variable before falling back to
/// [heliusPaymentHost].
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

/// Builds a payment URL for the given [paymentIntentId], optionally overriding
/// the host.
String buildPaymentUrl(String paymentIntentId, {String? hostOverride}) {
  return '${resolvePaymentHost(override: hostOverride)}/pay/$paymentIntentId';
}

String _stripTrailingSlash(String value) =>
    value.endsWith('/') ? value.substring(0, value.length - 1) : value;
