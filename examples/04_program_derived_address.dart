// ignore_for_file: avoid_print
/// Example 04: Derive program-derived addresses (PDAs).
///
/// Demonstrates [getProgramDerivedAddress] and [createProgramAddress] for
/// deterministically computing off-curve addresses from program + seeds.
///
/// Run:
///   dart examples/04_program_derived_address.dart
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';

Future<void> main() async {
  // ── 1. Well-known program addresses ──────────────────────────────────────
  const systemProgram = Address('11111111111111111111111111111111');
  const tokenProgram = Address('TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA');
  const associatedTokenProgram =
      Address('ATokenGPvbdGVxr1b2hvZbsiqW5xWH25efTNsLJe1bsn');

  print('System program   : ${systemProgram.value}');
  print('Token program    : ${tokenProgram.value}');
  print('ATA program      : ${associatedTokenProgram.value}');

  // ── 2. Derive a PDA with string seeds ─────────────────────────────────────
  // getProgramDerivedAddress searches for a bump seed, starting at 255,
  // until the derived address is NOT on the Ed25519 curve.
  final (vaultPda, vaultBump) = await getProgramDerivedAddress(
    programAddress: systemProgram,
    seeds: ['vault', 'user-42'],
  );

  print('\nVault PDA  : ${vaultPda.value}');
  print('Vault bump : $vaultBump');

  // ── 3. Derive a PDA with Uint8List seeds ─────────────────────────────────
  final walletBytes = Uint8List.fromList(
    utf8.encode('9B5XszUGdMaxCZ7uSQhPzdks5ZQSmWxrmzCSvtJ6Ns6g'),
  );
  final (pdaFromBytes, bumpFromBytes) = await getProgramDerivedAddress(
    programAddress: tokenProgram,
    seeds: [walletBytes.sublist(0, 32)],
  );

  print('\nPDA from bytes : ${pdaFromBytes.value}');
  print('Bump           : $bumpFromBytes');

  // ── 4. Validate that PDA is off-curve ─────────────────────────────────────
  // isOnCurve returns false for a correctly derived PDA.
  final onCurve = isOnCurveAddress(vaultPda);
  print('\nVault PDA on Ed25519 curve (should be false): $onCurve');

  // ── 5. Typical Associated Token Account PDA formula ───────────────────────
  // ATA = findProgramAddressSync([wallet, tokenProgramId, mint], ataProgram)
  // Here we demonstrate the same structure with placeholder bytes.
  const mint = Address('So11111111111111111111111111111111111111112');
  const wallet = Address('9B5XszUGdMaxCZ7uSQhPzdks5ZQSmWxrmzCSvtJ6Ns6g');

  // Seeds for ATA: wallet_pubkey || token_program_id || mint_pubkey (as bytes).
  final enc = getAddressEncoder();
  final (ataPda, ataBump) = await getProgramDerivedAddress(
    programAddress: associatedTokenProgram,
    seeds: [
      enc.encode(wallet),
      enc.encode(tokenProgram),
      enc.encode(mint),
    ],
  );

  print('\nWrapped-SOL ATA PDA : ${ataPda.value}');
  print('ATA bump            : $ataBump');
}
