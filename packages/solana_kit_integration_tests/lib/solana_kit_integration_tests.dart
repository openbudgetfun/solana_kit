/// Shared harness for on-chain integration tests against a local SurfPool
/// validator.
///
/// Connects to a SurfPool instance at `localhost:8899` (started by the
/// `test:integration` workspace script), funds a payer, and exposes helpers
/// to build, sign, send, and confirm transactions using the Solana Kit
/// program clients.
library;

export 'src/integration_test_env.dart';
