/// Surfpool SDK helpers for Solana Kit Dart tests.
///
/// This package provides a pure-Dart client for Surfpool's local Surfnet
/// cheatcode JSON-RPC methods. `Surfnet.start` launches the `surfpool` CLI and
/// then talks to it over HTTP; `Surfnet.connect` attaches to an already running
/// Surfpool instance.
library;

export 'src/builders.dart';
export 'src/config.dart';
export 'src/errors.dart';
export 'src/surfnet.dart';
export 'src/types.dart';
