import 'dart:convert';
import 'dart:typed_data';

import 'package:solana_kit_anchor/solana_kit_anchor.dart';

/// The length of an Anchor discriminator in bytes.
const int anchorDiscriminatorLength = 8;

/// Computes the first eight bytes of `sha256("<namespace>:<name>")`.
///
/// This is Anchor's "sighash" scheme: instruction discriminators use the
/// `global` namespace (or `state` for single-state programs), account
/// discriminators use the `account` namespace, and event discriminators use
/// the `event` namespace.
Uint8List anchorSighash(String namespace, String name) {
  final preimage = utf8.encode('$namespace:$name');
  final digest = sha256(preimage);
  return Uint8List.sublistView(digest, 0, anchorDiscriminatorLength);
}

/// Computes the Anchor instruction discriminator for [name].
Uint8List instructionDiscriminator(String name) =>
    anchorSighash('global', name);

/// Computes the Anchor account discriminator for [name].
Uint8List accountDiscriminator(String name) => anchorSighash('account', name);

/// Computes the Anchor event discriminator for [name].
Uint8List eventDiscriminator(String name) => anchorSighash('event', name);

/// Returns true when [data] starts with [discriminator].
bool hasDiscriminator(List<int> data, List<int> discriminator) {
  if (data.length < discriminator.length) return false;
  for (var i = 0; i < discriminator.length; i++) {
    if (data[i] != discriminator[i]) return false;
  }
  return true;
}
