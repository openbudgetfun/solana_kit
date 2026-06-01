/// Returns [url] with sensitive query parameter values redacted.
String redactUrl(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null || !uri.hasQuery) return url;

  final redactedKeys = {'api-key', 'apikey', 'api_key', 'key', 'token'};
  final query = <String, String>{};
  for (final entry in uri.queryParameters.entries) {
    query[entry.key] = redactedKeys.contains(entry.key.toLowerCase())
        ? '[REDACTED]'
        : entry.value;
  }

  return uri.replace(queryParameters: query).toString();
}
