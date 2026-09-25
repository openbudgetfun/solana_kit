import 'package:solana_kit_address/solana_kit_address.dart';

// ---------------------------------------------------------------------------
// Well-known token mint addresses
// ---------------------------------------------------------------------------
// These are the canonical mainnet addresses for widely-used tokens.
// They are provided as convenience constants for common operations like
// creating ATAs, checking mint addresses, or displaying token info.

/// The mint address of Wrapped SOL (native SOL in the Token program).
///
/// Sending lamports to the associated token account for this mint wraps SOL
/// into an SPL token balance.
const wrappedSolMintAddress = Address(
  'So11111111111111111111111111111111111111112',
);

/// The mint address of USDC (USD Coin) on Solana mainnet.
const usdcMintAddress = Address('EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v');

/// The mint address of USDT (Tether) on Solana mainnet.
const usdtMintAddress = Address('Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB');
