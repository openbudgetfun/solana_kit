// ignore_for_file: public_member_api_docs

const lamportsPerSol = 1000000000;

BigInt solToLamports(double sol) => BigInt.from((sol * lamportsPerSol).round());
