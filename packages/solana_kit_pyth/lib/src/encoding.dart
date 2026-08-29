import 'package:solana_kit_pyth/src/exceptions.dart';

/// Encoding of the binary price update payload returned by Hermes.
enum HermesEncoding {
  /// Hexadecimal (lowercase) encoding. This is the default encoding used by
  /// the upstream `@pythnetwork/hermes-client`.
  hex._('hex'),

  /// Base64 encoding.
  base64._('base64');

  const HermesEncoding._(this.value);

  /// The wire name of the encoding as used in Hermes query parameters.
  final String value;

  /// Resolves the encoding name returned by the API.
  static HermesEncoding fromName(String name) => values.firstWhere(
    (encoding) => encoding.value == name,
    orElse: () => throw PythException('Unknown Hermes encoding: $name'),
  );
}
