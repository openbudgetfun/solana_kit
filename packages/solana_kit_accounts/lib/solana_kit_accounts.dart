/// Account fetching, decoding, and maybe-account abstractions for the Solana
/// Kit Dart SDK.
///
/// Use this library to fetch raw or `jsonParsed` accounts, decode byte-backed
/// account data, and model account existence explicitly with `MaybeAccount`.
///
/// <!-- {=docsFetchAccountSection} -->
///
/// ## Fetch an account
///
/// Use `fetchEncodedAccount` when you want the raw account bytes plus its Solana
/// metadata. Decode it later with the codec or parser that matches your program.
///
/// ```dart
/// import 'dart:typed_data';
///
/// import 'package:solana_kit/solana_kit.dart';
///
/// Future<void> main() async {
///   final rpc = createSolanaRpc(url: 'https://api.devnet.solana.com');
///   const address = Address('11111111111111111111111111111111');
///
///   final maybeAccount = await fetchEncodedAccount(rpc, address);
///
///   switch (maybeAccount) {
///     case ExistingAccount<Uint8List>(:final account):
///       print('Owner: ${account.programAddress}');
///       print('Bytes: ${account.data.length}');
///     case NonExistingAccount():
///       print('No account exists at $address');
///   }
/// }
/// ```
///
/// Use `fetchJsonParsedAccount` when the RPC can return a structured
/// `jsonParsed` representation for a well-known program. Use encoded reads when
/// you need byte-perfect custom decoding or when the RPC does not expose a parsed
/// view for your program.
///
/// <!-- {/docsFetchAccountSection} -->
///
/// <!-- {=docsDecodeAccountSection} -->
///
/// ## Decode a fetched account
///
/// Keep transport and binary-layout logic separate: fetch the encoded account
/// first, then decode it with the codec or decoder that matches your program.
///
/// ```dart
/// import 'package:solana_kit/solana_kit.dart';
/// import 'package:solana_kit_rpc_spec/solana_kit_rpc_spec.dart';
///
/// Future<void> loadDecodedAccount(
///   Rpc rpc,
///   Address address,
///   Decoder<int> decoder,
/// ) async {
///   final maybeEncoded = await fetchEncodedAccount(rpc, address);
///   final maybeDecoded = decodeMaybeAccount(maybeEncoded, decoder);
///
///   switch (maybeDecoded) {
///     case ExistingAccount<int>(:final account):
///       print('Decoded value: ${account.data}');
///     case NonExistingAccount():
///       print('Account not found: $address');
///   }
/// }
/// ```
///
/// This boundary keeps RPC concerns, existence handling, and binary decoding easy
/// to test independently.
///
/// <!-- {/docsDecodeAccountSection} -->
library;

export 'src/account.dart';
export 'src/decode_account.dart';
export 'src/fetch_account.dart';
export 'src/maybe_account.dart';
export 'src/parse_account.dart';
