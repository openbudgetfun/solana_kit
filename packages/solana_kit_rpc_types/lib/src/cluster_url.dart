/// A branded URL string for Solana mainnet.
extension type const MainnetUrl(String value) implements String {}

/// A branded URL string for Solana devnet.
extension type const DevnetUrl(String value) implements String {}

/// A branded URL string for Solana testnet.
extension type const TestnetUrl(String value) implements String {}

/// A union type of all cluster URL types.
///
/// Can be a [MainnetUrl], [DevnetUrl], [TestnetUrl], or any arbitrary
/// [String].
typedef ClusterUrl = String;

/// Given a URL, casts it to a type that is only accepted where mainnet URLs
/// are expected.
MainnetUrl mainnet(String putativeString) {
  return MainnetUrl(putativeString);
}

/// Given a URL, casts it to a type that is only accepted where devnet URLs
/// are expected.
DevnetUrl devnet(String putativeString) {
  return DevnetUrl(putativeString);
}

/// Given a URL, casts it to a type that is only accepted where testnet URLs
/// are expected.
TestnetUrl testnet(String putativeString) {
  return TestnetUrl(putativeString);
}
