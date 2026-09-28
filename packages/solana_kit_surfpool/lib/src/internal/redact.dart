/// Matches the query component of a URL carrying a credential, e.g.
/// `?api-key=SECRET` or `&token=SECRET`, including key names the Surfpool
/// CLI and upstream RPC providers commonly use.
final RegExp _sensitiveQueryPattern = RegExp(
  r"""([?&](?:api[-_]?key|apikey|access[-_]?key|secret|token|password)=)[^&\s'"]+""",
  caseSensitive: false,
);

/// Matches the user-info component of a URL, e.g. `https://user:pass@host/`.
final RegExp _userInfoPattern = RegExp(
  r"""([a-z][a-z0-9+.-]*://)([^\s/'"]*@)""",
);

/// Returns [text] with credentials embedded in URLs replaced by
/// `[REDACTED]`.
///
/// Exception messages and captured process output can contain URLs the
/// caller supplied — a forked Surfnet's upstream RPC endpoint commonly
/// carries `?api-key=...`. The redaction is textual so it also applies to
/// URLs embedded inside log lines rather than standing alone.
String redactUrlCredentials(String text) => text
    .replaceAllMapped(
      _userInfoPattern,
      (match) => '${match.group(1)}[REDACTED]@',
    )
    .replaceAllMapped(
      _sensitiveQueryPattern,
      (match) => '${match.group(1)}[REDACTED]',
    );
