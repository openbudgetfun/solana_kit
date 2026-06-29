/// Number of lamports in one SOL.
const lamportsPerSol = 1000000000;

/// Converts an amount in SOL to lamports.
BigInt solToLamports(double sol) => BigInt.from((sol * lamportsPerSol).round());
