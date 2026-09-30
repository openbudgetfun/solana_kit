/// The default maximum number of top-level instructions per planned
/// transaction message.
///
/// This is intentionally lower than the transaction format's instruction limit
/// (see [transactionInstructionLimit]) to leave headroom for inner
/// instructions (CPIs), which are not visible at planning time.
///
/// Added in @solana/kit v7.0.0.
const int defaultMaxInstructionsPerTransaction = 16;

/// The hard maximum number of top-level instructions the transaction format
/// can encode.
///
/// Every current transaction version shares this limit. It is intentionally
/// duplicated here, rather than derived from `solana_kit_transactions`, so a
/// configured maximum can be validated without compiling a transaction
/// message. If a future transaction version raises the limit, update this
/// constant (and consider making it version-aware).
///
/// Added in @solana/kit v7.0.0.
const int transactionInstructionLimit = 64;
