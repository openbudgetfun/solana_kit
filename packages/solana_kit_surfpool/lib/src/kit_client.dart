import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_rpc/solana_kit_rpc.dart';
import 'package:solana_kit_rpc_api/solana_kit_rpc_api.dart'
    show getMinimumBalanceForRentExemptionParams;
import 'package:solana_kit_rpc_spec/solana_kit_rpc_spec.dart' show Rpc;
import 'package:solana_kit_rpc_subscriptions/solana_kit_rpc_subscriptions.dart';
import 'package:solana_kit_signers/solana_kit_signers.dart';
import 'package:solana_kit_surfpool/src/cheatcodes.dart';
import 'package:solana_kit_surfpool/src/config.dart';
import 'package:solana_kit_surfpool/src/surfnet.dart';
import 'package:solana_kit_surfpool/src/types.dart';

/// A Solana Kit client wired to a Surfpool Surfnet, mirroring the
/// `@solana/surfpool/kit` plugin for TypeScript.
///
/// Bundles the Surfnet handle, a Solana RPC client, an RPC subscriptions
/// client, a pre-funded payer signer, and a typed cheatcode RPC — so tests
/// can build, sign, send, and confirm transactions without managing a
/// validator or RPC plumbing by hand.
class SurfpoolClient {
  SurfpoolClient._({
    required this.surfnet,
    required this.rpc,
    required this.rpcSubscriptions,
    required this.payer,
    required this.cheatcodes,
    required this._disposePayerOnStop,
  });

  /// The underlying Surfnet handle (`fundSol`, `deploy`, time travel, …).
  final Surfnet surfnet;

  /// Solana RPC client pointed at the Surfnet.
  final Rpc rpc;

  /// Solana RPC subscriptions client pointed at the Surfnet.
  final RpcSubscriptions rpcSubscriptions;

  /// Pre-funded payer signer for the Surfnet.
  final KeyPairSigner payer;

  /// Typed cheatcode RPC (method names have the `surfnet_` prefix stripped).
  final SurfnetCheatcodes cheatcodes;

  final bool _disposePayerOnStop;

  /// HTTP RPC URL for the Surfnet.
  String get rpcUrl => surfnet.rpcUrl;

  /// WebSocket RPC URL for the Surfnet.
  String get wsUrl => surfnet.wsUrl;

  /// Airdrops [lamports] to [address] via the Surfnet.
  Future<void> airdrop(Address address, BigInt lamports) =>
      surfnet.fundSol(address, lamports.toInt());

  /// Returns the rent-exempt minimum balance for an account of [space] bytes.
  Future<BigInt> getMinimumBalance(BigInt space) async {
    final response = await rpc
        .request<Object?>(
          'getMinimumBalanceForRentExemption',
          getMinimumBalanceForRentExemptionParams(space),
        )
        .send();
    if (response is BigInt) return response;
    // Defensive: the default response transformer upcasts numbers to BigInt.
    if (response is int) return BigInt.from(response); // coverage:ignore-line
    // Defensive: the RPC response shape is pinned by the Surfpool runtime.
    throw StateError('Unexpected response: $response'); // coverage:ignore-line
  }

  /// Stops the Surfnet and releases its resources.
  ///
  /// Idempotent; safe to call from test teardown.
  Future<void> stop() async {
    try {
      await surfnet.stop();
    } finally {
      if (_disposePayerOnStop) payer.keyPair.dispose();
    }
  }

  /// Creates a client bound to an existing [surfnet] for testing.
  @visibleForTesting
  static SurfpoolClient forTesting({
    required Surfnet surfnet,
    required KeyPairSigner payer,
  }) {
    return _wireClient(surfnet, payer: payer);
  }
}

/// Creates a Solana Kit client wired to a fresh Surfpool Surfnet.
///
/// Mirrors `createClient().use(surfpool())` from `@solana/surfpool/kit`:
/// starts an isolated Surfnet on auto-allocated ports, wires the RPC and
/// subscriptions clients to it, and installs the Surfnet's pre-funded payer
/// as [SurfpoolClient.payer].
///
/// If setup fails, the Surfnet is stopped before the error is rethrown so no
/// orphaned process or ports are left behind.
Future<SurfpoolClient> createSurfpoolClient({
  SurfnetConfig? config,
  String command = 'surfpool',
  Duration startupTimeout = const Duration(seconds: 30),
}) async {
  final surfnet = await Surfnet.start(
    config: config,
    command: command,
    startupTimeout: startupTimeout,
  );
  try {
    return _wireClient(surfnet);
  } catch (_) {
    // Defensive cleanup: only reachable if wiring the RPC clients fails,
    // which cannot happen with a successfully started Surfnet.
    await surfnet.stop(); // coverage:ignore-line
    rethrow;
  }
}

/// Creates a Solana Kit client attached to an already-running Surfpool.
///
/// Mirrors `createClient().use(surfpool({ rpcUrl }))` from
/// `@solana/surfpool/kit`. The [payer] must be a funded signer (the caller
/// is responsible for funding it); there is no Surfnet handle to stop, so
/// [SurfpoolClient.stop] only closes the attached HTTP client.
SurfpoolClient connectSurfpoolClient({
  required Uri rpcUrl,
  required KeyPairSigner payer,
  Uri? wsUrl,
}) {
  final surfnet = Surfnet.connect(
    rpcUrl: rpcUrl,
    wsUrl: wsUrl,
    payer: _keypairInfoFromSigner(payer),
  );
  return _wireClient(surfnet, payer: payer);
}

SurfpoolClient _wireClient(Surfnet surfnet, {KeyPairSigner? payer}) {
  final rpc = createSolanaRpc(url: surfnet.rpcUrl, allowInsecureHttp: true);
  final rpcSubscriptions = createSolanaRpcSubscriptions(
    surfnet.wsUrl,
    DefaultRpcSubscriptionsChannelConfig(
      url: surfnet.wsUrl,
      allowInsecureWs: true,
      allowPrivateHosts: true,
    ),
  );
  final effectivePayer =
      payer ?? createKeyPairSignerFromBytes(surfnet.payerSecretKey);
  return SurfpoolClient._(
    surfnet: surfnet,
    rpc: rpc,
    rpcSubscriptions: rpcSubscriptions,
    payer: effectivePayer,
    cheatcodes: SurfnetCheatcodes(surfnet),
    disposePayerOnStop: payer == null,
  );
}

KeypairInfo _keypairInfoFromSigner(KeyPairSigner signer) {
  final keyPair = signer.keyPair;
  final secretKey = Uint8List.fromList(<int>[
    ...keyPair.privateKey,
    ...keyPair.publicKey,
  ]);
  return KeypairInfo(publicKey: signer.address, secretKey: secretKey);
}
