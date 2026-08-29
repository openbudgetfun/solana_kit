/// Anchor program runtime for Solana Kit Dart.
///
/// Ports the client-side runtime of the
/// [Anchor](https://github.com/otter-sec/anchor) framework: discriminators,
/// Anchor IDL parsing, dynamic account and event codecs, and error resolution.
/// It does not port the on-chain framework, the CLI, or client code
/// generation — Dart programs keep building instructions and accounts with
/// explicit codecs.
///
/// ## Key features
///
/// - **Discriminators** — Anchor sighash (`sha256("namespace:name")[0..8]`)
///   helpers for instructions, accounts, and events
/// - **IDL parsing** — a typed model of Anchor IDL 0.30 documents
/// - **Dynamic coder** — encode instruction args, encode/decode accounts,
///   and pull typed events out of program logs from an IDL at runtime
/// - **Error resolution** — decode Anchor error codes against the standard
///   table and program-defined IDL errors
///
/// Generic type instantiations in IDLs are rejected rather than silently
/// mis-encoded; use Codama clients for programs that require them.
///
/// ## Dependencies
///
/// The dynamic coder composes codecs from `solana_kit_codecs`,
/// `solana_kit_codecs_data_structures`, `solana_kit_codecs_numbers`, and
/// `solana_kit_codecs_strings`, and derives PDAs with
/// `solana_kit_addresses`.
library;

export 'src/coder.dart';
export 'src/discriminator.dart';
export 'src/errors.dart';
export 'src/idl.dart';
export 'src/sha256.dart';
