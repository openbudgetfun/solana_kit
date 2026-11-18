final _sensitiveQuery = RegExp(
  r'([?&](?:api[-_]?key|apikey|access[-_]?key|secret|token|password|key)=)[^&\s"]+',
  caseSensitive: false,
);

final _userInfo = RegExp(
  r'([a-z][a-z0-9+.-]*://)([^\s/"]*@)',
  caseSensitive: false,
);

/// Replaces credentials embedded in [text].
///
/// Indexer and prover errors can echo the request URL. The API key stays
/// out of the exception text.
String redactSecrets(String text, {String? apiKey}) {
  final withoutKey = apiKey == null || apiKey.isEmpty
      ? text
      : text.replaceAll(apiKey, '[REDACTED]');
  return withoutKey
      .replaceAllMapped(_userInfo, (match) => '${match.group(1)}[REDACTED]@')
      .replaceAllMapped(
        _sensitiveQuery,
        (match) => '${match.group(1)}[REDACTED]',
      );
}

/// [url] with credential query values replaced.
Uri redactUri(Uri url) {
  const keys = {'api-key', 'apikey', 'api_key', 'key', 'token', 'secret'};
  if (!url.hasQuery && url.userInfo.isEmpty) return url;
  final query = <String, String>{
    for (final entry in url.queryParameters.entries)
      entry.key: keys.contains(entry.key.toLowerCase())
          ? '[REDACTED]'
          : entry.value,
  };
  return url.replace(
    userInfo: '',
    queryParameters: query.isEmpty ? null : query,
  );
}
