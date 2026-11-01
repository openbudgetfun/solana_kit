/// Finite budgets checked before buffering or decoding untrusted RPC payloads.
///
/// Defaults allow 16 MiB, 64 nested JSON containers, and one million JSON
/// tokens. Increase these explicitly for endpoints that return larger data.
class InboundPayloadLimits {
  /// Creates inbound byte and JSON complexity budgets.
  const InboundPayloadLimits({
    this.maxBytes = 16 * 1024 * 1024,
    this.maxJsonDepth = 64,
    this.maxJsonTokens = 1000000,
  });

  /// Maximum bytes in one HTTP response or decoded WebSocket message.
  final int maxBytes;

  /// Maximum nesting of JSON objects and arrays.
  final int maxJsonDepth;

  /// Maximum number of containers, member names, and scalar values in JSON.
  final int maxJsonTokens;

  /// Rejects non-positive budgets, including in release builds.
  void validate() {
    for (final entry in {
      'maxBytes': maxBytes,
      'maxJsonDepth': maxJsonDepth,
      'maxJsonTokens': maxJsonTokens,
    }.entries) {
      if (entry.value <= 0) {
        throw ArgumentError.value(entry.value, entry.key, 'Must be positive.');
      }
    }
  }

  /// Rejects a byte length before retaining or copying the payload.
  void checkByteLength(int length) {
    if (length > maxBytes) {
      throw InboundPayloadLimitException('bytes', maxBytes);
    }
  }

  /// Checks UTF-8 size and JSON complexity without allocating a decoded tree.
  ///
  /// Returns the UTF-8 byte length. This is a resource preflight, not a JSON
  /// syntax validator; the caller's JSON decoder still validates the grammar.
  /// Strings and escaped delimiters do not contribute to nesting depth.
  int checkText(String text) {
    // Security: avoid a full UTF-8 copy merely to measure a hostile string.
    checkByteLength(text.length);
    var bytes = 0;
    var depth = 0;
    var tokens = 0;
    var inString = false;
    var escaped = false;
    var inScalar = false;

    for (var i = 0; i < text.length; i++) {
      final unit = text.codeUnitAt(i);
      bytes += unit <= 0x7f ? 1 : (unit <= 0x7ff ? 2 : 3);

      // A surrogate pair encodes as four bytes, rather than six.
      if (unit >= 0xdc00 && unit <= 0xdfff && i > 0) {
        final previous = text.codeUnitAt(i - 1);

        if (previous >= 0xd800 && previous <= 0xdbff) bytes -= 2;
      }

      // Check at code point boundaries so a pair exactly at the limit fits.
      final startsPair =
          unit >= 0xd800 &&
          unit <= 0xdbff &&
          i + 1 < text.length &&
          text.codeUnitAt(i + 1) >= 0xdc00 &&
          text.codeUnitAt(i + 1) <= 0xdfff;

      if (!startsPair) checkByteLength(bytes);

      if (inString) {
        if (escaped) {
          escaped = false;
        } else if (unit == 0x5c) {
          escaped = true;
        } else if (unit == 0x22) {
          inString = false;
        }

        continue;
      }

      switch (unit) {
        case 0x22:
          inString = true;
          inScalar = false;
          tokens++;
        case 0x5b || 0x7b:
          depth++;
          tokens++;
          inScalar = false;

          if (depth > maxJsonDepth) {
            throw InboundPayloadLimitException('JSON depth', maxJsonDepth);
          }
        case 0x5d || 0x7d:
          depth--;
          inScalar = false;
        case 0x20 || 0x09 || 0x0a || 0x0d || 0x2c || 0x3a:
          inScalar = false;
        default:
          if (!inScalar) tokens++;
          inScalar = true;
      }

      if (tokens > maxJsonTokens) {
        throw InboundPayloadLimitException('JSON tokens', maxJsonTokens);
      }
    }

    return bytes;
  }
}

/// Signals that a peer exceeded a configured inbound resource budget.
class InboundPayloadLimitException implements Exception {
  /// Creates an error without retaining peer-controlled payload data.
  const InboundPayloadLimitException(this.resource, this.limit);

  /// The exhausted resource, such as bytes, JSON depth, or queued messages.
  final String resource;

  /// The configured maximum for [resource].
  final int limit;

  @override
  String toString() => 'Inbound payload exceeds $resource limit ($limit).';
}
