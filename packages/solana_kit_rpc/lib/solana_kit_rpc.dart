/// Primary RPC client for the Solana Kit Dart SDK.
///
/// This package provides the high-level factory functions for creating Solana
/// RPC clients. It combines transport, API, and transformers into a cohesive
/// RPC client interface.
///
/// Unless you plan to create a custom RPC interface, you can use
/// `createSolanaRpc` to obtain a default implementation of the
/// [Solana JSON RPC API](https://solana.com/docs/rpc/http).
library;

export 'src/rpc.dart';
export 'src/rpc_default_config.dart';
export 'src/rpc_integer_overflow_error.dart';
export 'src/rpc_request_coalescer.dart';
export 'src/rpc_request_deduplication.dart';
export 'src/rpc_transport.dart';
