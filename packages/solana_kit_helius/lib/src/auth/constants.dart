// ignore_for_file: public_member_api_docs

/// Constants matching upstream helius-sdk v3.0.0.

/// Host that serves the public hosted-checkout page.
const String paymentHost = 'https://dashboard.helius.dev';

/// Helius treasury wallet address (USDC recipient for payments).
const String treasury = 'CEs84tEowsXpH8u4VBf8rJSVgSRypFMfXw9CpGRtQgb6';

/// USDC mint address on Solana mainnet.
const String usdcMintMainnet =
    'EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v';

/// USDC mint address on Solana devnet.
const String usdcMintDevnet =
    '4zMMC9srt5Ri5X14GAgXhaHii3GnPAEERYPJgZJDncDU';

/// USDC mint address to use (mainnet by default).
const String usdcMint = usdcMintMainnet;

/// Legacy: 1 USDC (6 decimals). Only used by payUSDC.
BigInt get paymentAmount => BigInt.from(1000000);

/// Solana memo program address.
const String memoProgramId = 'MemoSq4gqABAXKb96qnH8TysNcWxMyWCqXgDLGmfcHr';

/// Checkout polling interval (ms).
const int checkoutPollIntervalMs = 1000;

/// Checkout polling timeout (ms).
const int checkoutPollTimeoutMs = 60000;

/// Project provisioning polling interval (ms).
const int projectPollIntervalMs = 2000;

/// Project provisioning polling timeout (ms).
const int projectPollTimeoutMs = 30000;

/// Minimum SOL needed for transaction fees (~0.001 SOL).
BigInt get minSolForTx => BigInt.from(1000000);

/// Solana mainnet RPC URL.
const String solanaRpcUrlMainnet = 'https://api.mainnet-beta.solana.com';

/// Solana devnet RPC URL.
const String solanaRpcUrlDevnet = 'https://api.devnet.solana.com';

/// Agent plan identifier used internally by the backend.
const String agentPlanId = 'agent_v4';

/// Prepaid credits per unit quantity (1 unit = 1M credits).
const int prepaidCreditsPerUnitQty = 1000000;
