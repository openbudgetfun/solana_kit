/// A parsed RPC account type with both a [type] discriminator and an [info]
/// payload.
///
/// This is the base class for parsed account data returned by the Solana RPC
/// when accounts are requested with `jsonParsed` encoding. The [TType] type
/// parameter is a string literal that discriminates the variant, and [TInfo]
/// carries the parsed data.
class RpcParsedType<TType extends String, TInfo extends Object> {
  /// Creates a new [RpcParsedType] with the given [type] and [info].
  const RpcParsedType({required this.type, required this.info});

  /// The type discriminator for this parsed account variant.
  final TType type;

  /// The parsed account data.
  final TInfo info;
}

/// A parsed RPC account type that carries only an [info] payload without a
/// type discriminator.
///
/// Used for account types where there is only a single variant (e.g. nonce
/// accounts, vote accounts, address lookup table accounts).
class RpcParsedInfo<TInfo extends Object> {
  /// Creates a new [RpcParsedInfo] with the given [info].
  const RpcParsedInfo({required this.info});

  /// The parsed account data.
  final TInfo info;
}
