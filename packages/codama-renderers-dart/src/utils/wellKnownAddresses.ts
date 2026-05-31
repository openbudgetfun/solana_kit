/**
 * Maps well-known Solana public keys to their canonical Dart constant names
 * in `package:solana_kit_addresses`. When the renderer encounters a known
 * address, it emits a re-export from that package instead of hardcoding the
 * address string.
 *
 * The keys are the base-58 public key strings as they appear in IDL/Codama nodes.
 * The values are the Dart constant names exported by `solana_kit_addresses`.
 */
export const WELL_KNOWN_ADDRESSES: ReadonlyMap<string, string> = new Map([
  // Agave / Solana native programs
  ['11111111111111111111111111111111', 'systemProgramAddress'],
  ['AddressLookupTab1e1111111111111111111111111', 'addressLookupTableProgramAddress'],
  ['BPFLoader2111111111111111111111111111111111', 'bpfLoaderProgramAddress'],
  ['BPFLoader1111111111111111111111111111111111', 'bpfLoaderDeprecatedProgramAddress'],
  ['BPFLoaderUpgradeab1e11111111111111111111111', 'bpfLoaderUpgradeableProgramAddress'],
  ['ComputeBudget111111111111111111111111111111', 'computeBudgetProgramAddress'],
  ['Config1111111111111111111111111111111111111', 'configProgramAddress'],
  ['Ed25519SigVerify111111111111111111111111111', 'ed25519ProgramAddress'],
  ['Feature111111111111111111111111111111111111', 'featureProgramAddress'],
  ['1nc1nerator11111111111111111111111111111111', 'incineratorAddress'],
  ['LoaderV411111111111111111111111111111111111', 'loaderV4ProgramAddress'],
  ['NativeLoader1111111111111111111111111111', 'nativeLoaderProgramAddress'],
  ['KeccakSecp256k11111111111111111111111111111', 'secp256k1ProgramAddress'],
  ['Secp256r1SigVerify1111111111111111111111111', 'secp256r1ProgramAddress'],
  ['Stake11111111111111111111111111111111111111', 'stakeProgramAddress'],
  ['StakeConfig1111111111111111111111111111', 'stakeConfigAddress'],
  ['Vote111111111111111111111111111111111111111', 'voteProgramAddress'],
  ['ZkTokenProof1111111111111111111111111111111', 'zkTokenProofProgramAddress'],
  ['ZkE1Gama1Proof11111111111111111111111111111', 'zkElgamalProofProgramAddress'],

  // Sysvars
  ['SysvarC1ock11111111111111111111111111111111', 'sysvarClockAddress'],
  ['Rent11111111111111111111111111111111111111', 'sysvarRentAddress'],
  ['11111111111111111111111111111111111111111111', 'sysvarRecentBlockhashesAddress'], // note: 44 chars
  ['SysvarFees1111111111111111111111111111111111', 'sysvarFeesAddress'],
  ['Sysvar1nstruct1ons11111111111111111111111111', 'sysvarInstructionsAddress'],
  ['SysvarEpochSchedu1e111111111111111111111111', 'sysvarEpochScheduleAddress'],
  ['SysvarRewards111111111111111111111111111111', 'sysvarRewardsAddress'],
  ['SysvarStakeHistory1111111111111111111111111', 'sysvarStakeHistoryAddress'],
  ['SysvarS1otHashes111111111111111111111111111', 'sysvarSlotHashesAddress'],
  ['SysvarS1otHistory11111111111111111111111111', 'sysvarSlotHistoryAddress'],
  ['Sysvar1111111111111111111111111111111111111', 'sysvarOwnerAddress'],

  // SPL programs
  ['TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA', 'tokenProgramAddress'],
  ['TokenzQdBNb4qyze1S1U9AHB8MGXmNK1REkTPT5Z3Y', 'token2022ProgramAddress'],
  ['ATokenGPvbdGVxr1b2hvZbsiqW5xWH25ef7s3c8BnQKu', 'associatedTokenProgramAddress'],
  ['Memo1UhkJRfRhVq1sR7Y7Nto1s3J2mXTT3L6Wk4K2m6', 'memoProgramAddress'],
  ['MemoSq4gqABXKKYWVqKkV3m3kb1cTR7F2UMy9r6kFNK', 'memoLegacyProgramAddress'],

  // Metaplex programs
  ['metaqbxxU9qX8rZXkmUJ7haCrXXz2W1PSUq1Rn3E1od', 'tokenMetadataProgramAddress'],
  ['BGUMAp9V1mQ2KV8t34L5u3gZsXYZaYDBdKkc1xYk1qA1', 'mplBubblegumProgramAddress'],
  ['auth9SigNpDKz4s8cHr3MFBPS1phbRKLSCN3aBe9sS', 'authRulesProgramAddress'],
  ['CoREENxT6tW1Ho6BW6W5Z4N41ci5Xz2mmrR2kErmM5TR', 'metaplexCoreProgramAddress'],
  ['cmtMqR4bPM9sEV3bPnJQq5s2EnYw4N5vQ8hWhEd1xzS', 'splAccountCompressionProgramAddress'],
  ['noopb9skMVngR5Qi4sczwFr1jU4V4F7nm8xzFQK9C', 'noopProgramAddress'],

  // Well-known mints
  ['So11111111111111111111111111111111111111112', 'wrappedSolAddress'],
  ['EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v', 'usdcAddress'],
  ['Es9vMFrzaCERm6YKXx6bqKr1Rmd9b5v3J8rM5e4rfF4', 'usdtAddress'],
]);