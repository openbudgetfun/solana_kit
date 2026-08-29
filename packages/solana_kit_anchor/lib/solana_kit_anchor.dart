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
/// 
/// <!-- {=docsAnchorRuntimeSection} -->
///
/// ### Parse an Anchor IDL and code accounts dynamically
///
/// Use the runtime coder when a program ships an Anchor IDL: encode instruction arguments, decode account data, and pull typed events out of program logs without writing codecs by hand.
///
/// ```dart
/// import 'dart:io';
///
/// import 'package:solana_kit_anchor/solana_kit_anchor.dart';
///
/// void main() {
///   final idl = AnchorIdlProgram.parse(
///     File('idls/counter.json').readAsStringSync(),
///   );
///   final coder = AnchorCoder(idl);
///
///   final data = coder.encodeInstructionData('increment', {
///     'delta': BigInt.one,
///   });
///   // 8-byte discriminator + encoded arguments, ready for an Instruction.
///   print(data.length);
///
///   // Account data as fetched from RPC, starting with the 8-byte
///   // account discriminator.
///   final fetchedAccountBytes = <int>[];
///   final counter = coder.decodeAccount('Counter', fetchedAccountBytes);
///   print(counter.data['count']); // BigInt
///
///   // Program logs from a transaction, e.g. lines like
///   // "Program data: dW5rbm93bkRlY29kZXI=".
///   final logs = <String>[];
///   final events = coder.decodeEventLogs(logs);
///   for (final event in events) {
///     print('${event.name}: ${event.data}');
///   }
/// }
/// ```
///
/// Discriminator helpers and error resolution round out the runtime: `instructionDiscriminator`, `accountDiscriminator`, `eventDiscriminator`, and `anchorProgramError` resolve against the standard Anchor table plus program-defined IDL errors.
///
/// <!-- {/docsAnchorRuntimeSection} -->
///
/// <!-- {=docsAnchorRuntimeSection -->
///
/// ### Parse an Anchor IDL and code accounts dynamically
///
/// Use the runtime coder when a program ships an Anchor IDL: encode instruction arguments, decode account data, and pull typed events out of program logs without writing codecs by hand.
///
/// ```dart
/// import 'dart:io';
///
/// import 'package:solana_kit_anchor/solana_kit_anchor.dart';
///
/// void main() {
///   final idl = AnchorIdlProgram.parse(
///     File('idls/counter.json').readAsStringSync(),
///   );
///   final coder = AnchorCoder(idl);
///
///   final data = coder.encodeInstructionData('increment', {
///     'delta': BigInt.one,
///   });
///   // 8-byte discriminator + encoded arguments, ready for an Instruction.
///   print(data.length);
///
///   // Account data as fetched from RPC, starting with the 8-byte
///   // account discriminator.
///   final fetchedAccountBytes = <int>[];
///   final counter = coder.decodeAccount('Counter', fetchedAccountBytes);
///   print(counter.data['count']); // BigInt
///
///   // Program logs from a transaction, e.g. lines like
///   // "Program data: dW5rbm93bkRlY29kZXI=".
///   final logs = <String>[];
///   final events = coder.decodeEventLogs(logs);
///   for (final event in events) {
///     print('${event.name}: ${event.data}');
///   }
/// }
/// ```
///
/// Discriminator helpers and error resolution round out the runtime: `instructionDiscriminator`, `accountDiscriminator`, `eventDiscriminator`, and `anchorProgramError` resolve against the standard Anchor table plus program-defined IDL errors.
///
/// <!-- {/docsAnchorRuntimeSection -->

library;
///
export 'src/coder.dart';
export 'src/discriminator.dart';
export 'src/errors.dart';
export 'src/idl.dart';
export 'src/sha256.dart';
