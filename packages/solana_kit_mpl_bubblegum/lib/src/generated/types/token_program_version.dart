// Auto-generated. Do not edit.
// ignore_for_file: type=lint

/// Token program version used by the compressed NFT.
enum TokenProgramVersion {
  /// Original SPL Token program.
  original(0),

  /// SPL Token 2022 program.
  token2022(1);

  const TokenProgramVersion(this.value);

  /// The numeric value of the token program version.
  final int value;
}
