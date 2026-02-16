import 'package:solana_kit_errors/solana_kit_errors.dart';

/// These are headers that are fundamental to the JSON-RPC transport, and must
/// not be modified by the caller.
const _disallowedHeaders = <String, bool>{
  'accept': true,
  'content-length': true,
  'content-type': true,
};

/// [Forbidden headers](https://developer.mozilla.org/en-US/docs/Glossary/Forbidden_header_name)
/// per the MDN specification. Prefix matching for `proxy-*` and `sec-*` is
/// handled separately in the assertion function.
const _forbiddenHeaders = <String, bool>{
  'accept-charset': true,
  'accept-encoding': true,
  'access-control-request-headers': true,
  'access-control-request-method': true,
  'connection': true,
  'content-length': true,
  'cookie': true,
  'date': true,
  'dnt': true,
  'expect': true,
  'host': true,
  'keep-alive': true,
  'origin': true,
  'permissions-policy': true,
  'referer': true,
  'te': true,
  'trailer': true,
  'transfer-encoding': true,
  'upgrade': true,
  'via': true,
};

/// Asserts that none of the provided [headers] are forbidden or disallowed.
///
/// Throws a [SolanaError] with code
/// [SolanaErrorCode.rpcTransportHttpHeaderForbidden] if any header names match
/// a disallowed header, a forbidden header, or begin with `proxy-` or `sec-`.
///
/// Header names are compared case-insensitively (lowercased before checking).
void assertIsAllowedHttpRequestHeaders(Map<String, String> headers) {
  final badHeaders = headers.keys.where((headerName) {
    final lowercased = headerName.toLowerCase();
    return (_disallowedHeaders[lowercased] ?? false) ||
        (_forbiddenHeaders[lowercased] ?? false) ||
        lowercased.startsWith('proxy-') ||
        lowercased.startsWith('sec-');
  }).toList();

  if (badHeaders.isNotEmpty) {
    throw SolanaError(SolanaErrorCode.rpcTransportHttpHeaderForbidden, {
      'headers': badHeaders,
    });
  }
}

/// Normalizes the provided [headers] by lowercasing all header names.
///
/// Returns a new map with lowercased keys and the original values. This makes
/// it easier to override user-supplied headers with protocol headers.
Map<String, String> normalizeHeaders(Map<String, String> headers) {
  return {
    for (final entry in headers.entries) entry.key.toLowerCase(): entry.value,
  };
}
