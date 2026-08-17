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
    return _validatePaymentHost(explicit);
  }

  final value = (environment ?? Platform.environment)['HELIUS_PAYMENT_HOST'];
  if (value != null && value.isNotEmpty) return _validatePaymentHost(value);

  return heliusPaymentHost;
}

/// Builds a payment URL for the given [paymentIntentId], optionally overriding
/// the host.
String buildPaymentUrl(String paymentIntentId, {String? hostOverride}) {
  final encodedId = Uri.encodeComponent(paymentIntentId);
  return '${resolvePaymentHost(override: hostOverride)}/pay/$encodedId';
}

String _stripTrailingSlash(String value) =>
    value.endsWith('/') ? value.substring(0, value.length - 1) : value;

String _validatePaymentHost(String value) {
  final normalized = _stripTrailingSlash(value);
  final uri = Uri.tryParse(normalized);
  if (uri == null ||
      !uri.isAbsolute ||
      uri.host.isEmpty ||
      (uri.scheme != 'https' && uri.scheme != 'http') ||
      uri.userInfo.isNotEmpty ||
      uri.query.isNotEmpty ||
      uri.fragment.isNotEmpty) {
    throw ArgumentError.value(
      value,
      'paymentHost',
      'must be an absolute HTTP(S) origin without credentials, query, or fragment',
    );
  }
  return normalized;
}
