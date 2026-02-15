/// Represents a slot number on the Solana blockchain.
typedef Slot = BigInt;

/// Represents an epoch number on the Solana blockchain.
typedef Epoch = BigInt;

/// Represents a quantity of micro-lamports (0.000001 lamports).
///
/// Micro-lamports are used for priority fee calculations. The value must be
/// in the range 0 to 2^64-1.
extension type const MicroLamports(BigInt value) implements Object {}

/// Represents a signed quantity of lamports that can be negative.
///
/// This is used in contexts where a balance change can be either positive
/// or negative, such as reward amounts.
typedef SignedLamports = BigInt;

/// A floating-point number returned by the RPC.
///
/// Beware that floating-point value precision can vary widely. For precision
/// of 1 decimal place, anything above 562949953421311 and for precision of
/// 2 decimal places, anything above 70368744177663 can be truncated or rounded.
typedef F64UnsafeSeeDocumentation = double;
