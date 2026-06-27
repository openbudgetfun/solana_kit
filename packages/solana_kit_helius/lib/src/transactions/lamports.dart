const lamportsPerSol = 1000000000;

BigInt solToLamports(double sol) => BigInt.from((sol * lamportsPerSol).round());
