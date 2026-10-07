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

/// Matches the query component of a URL carrying a credential, e.g.
/// `?api-key=SECRET`, including the key names Helius endpoints use.
final RegExp _sensitiveQueryPattern = RegExp(
  r'([?&](?:api[-_]?key|apikey|access[-_]?key|secret|token|password)=)[^&\s'
  '"]+',
  caseSensitive: false,
);

/// Matches the user-info component of a URL, e.g. `https://user:pass@host/`.
final RegExp _userInfoPattern = RegExp(
  r'([a-z][a-z0-9+.-]*://)([^\s/'
  '"]*@)',
);

/// Returns [text] with credentials embedded anywhere in the text replaced
/// by `[REDACTED]`.
///
/// Error responses can echo the request URL back inside the body; running
/// the body through this redaction keeps the API key out of error context
/// that callers may log.
String redactUrlCredentials(String text) => text
    .replaceAllMapped(
      _userInfoPattern,
      (match) => '${match.group(1)}[REDACTED]@',
    )
    .replaceAllMapped(
      _sensitiveQueryPattern,
      (match) => '${match.group(1)}[REDACTED]',
    );
