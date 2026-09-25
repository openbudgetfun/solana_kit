/// Returns [url] without user credentials and with sensitive queries redacted.
String redactUrl(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null || (!uri.hasQuery && uri.userInfo.isEmpty)) return url;

  final redactedKeys = {'api-key', 'apikey', 'api_key', 'key', 'token'};
  final query = <String, String>{};
  for (final entry in uri.queryParameters.entries) {
    query[entry.key] = redactedKeys.contains(entry.key.toLowerCase())
        ? '[REDACTED]'
        : entry.value;
  }

  return uri
      .replace(userInfo: '', queryParameters: query.isEmpty ? null : query)
      .toString();
}
