import 'dart:async';
import 'dart:typed_data';

import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_mobile_wallet_adapter/src/kit_mobile_wallet.dart';
import 'package:solana_kit_mobile_wallet_adapter_protocol/solana_kit_mobile_wallet_adapter_protocol.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Result of starting a remote association session.
class RemoteAssociationResult {
  const RemoteAssociationResult({
    required this.associationUri,
    required this.wallet,
    required this.close,
  });

  /// The association URI to display to the user (e.g. as a QR code).
  final Uri associationUri;

  /// A future that resolves to the connected wallet proxy once the remote
  /// wallet connects.
  final Future<KitMobileWallet> wallet;

  /// Closes the remote session and cleans up resources.
  final void Function() close;
}

/// Starts a remote association session via a WebSocket reflector.
///
/// The reflector server relays messages between the dApp and wallet when
/// they are not on the same device.
///
/// Returns a [RemoteAssociationResult] containing:
/// - The association URI (to display as a QR code for the wallet to scan)
/// - A future that resolves to the [KitMobileWallet] when the wallet connects
/// - A close function to tear down the session
RemoteAssociationResult startRemoteScenario(
  RemoteWalletAssociationConfig config,
) {
  final associationKeyPair = generateAssociationKeypair();
  final ecdhKeyPair = generateEcdhKeypair();

  var closed = false;
  WebSocketChannel? channel;

  void close() {
    if (closed) return;
    closed = true;
    channel?.sink.close();
  }

  final walletFuture = _connectRemote(
    config: config,
    associationKeyPair: associationKeyPair,
    ecdhKeyPair: ecdhKeyPair,
    getChannel: () => channel,
    setChannel: (c) => channel = c,
    isClosed: () => closed,
  );

  // Build the association URI. We don't have the reflector ID yet, so
  // the URI will be set after connecting to the reflector.
  // For now, return a placeholder that will be replaced.
  final associationUri = buildRemoteAssociationUri(
    associationKeyPair.publicKey,
    config.reflectorHost,
    Uint8List(0),
    baseUri: config.baseUri,
  );

  return RemoteAssociationResult(
    associationUri: associationUri,
    wallet: walletFuture,
    close: close,
  );
}

Future<KitMobileWallet> _connectRemote({
  required RemoteWalletAssociationConfig config,
  required AssociationKeypair associationKeyPair,
  required EcdhKeypair ecdhKeyPair,
  required WebSocketChannel? Function() getChannel,
  required void Function(WebSocketChannel) setChannel,
  required bool Function() isClosed,
}) async {
  // Connect to reflector.
  final reflectorUri = Uri.parse('wss://${config.reflectorHost}/reflect');
  final reflectorChannel = WebSocketChannel.connect(reflectorUri);
  await reflectorChannel.ready;
  setChannel(reflectorChannel);

  // Wait for the wallet to connect via the reflector.
  final completer = Completer<Uint8List>();
  final subscription = reflectorChannel.stream.listen(
    (message) {
      if (!completer.isCompleted && message is List<int>) {
        completer.complete(Uint8List.fromList(message));
      }
    },
    onError: (Object error) {
      if (!completer.isCompleted) {
        completer.completeError(error);
      }
    },
    onDone: () {
      if (!completer.isCompleted) {
        completer.completeError(
          SolanaError(SolanaErrorCode.mwaSessionClosed),
        );
      }
    },
  );

  // Send HELLO_REQ.
  final helloReq = createHelloReq(ecdhKeyPair, associationKeyPair);
  reflectorChannel.sink.add(helloReq);

  // Wait for HELLO_RSP.
  Uint8List helloRsp;
  try {
    helloRsp = await completer.future.timeout(
      const Duration(milliseconds: mwaConnectionTimeoutMs),
      onTimeout: () => throw SolanaError(SolanaErrorCode.mwaSessionTimeout),
    );
  } finally {
    await subscription.cancel();
  }

  // Parse HELLO_RSP and derive shared secret.
  final result = parseHelloRsp(
    helloRsp,
    associationKeyPair,
    ecdhKeyPair,
  );
  final sharedSecret = result.sharedSecret;

  // Parse session properties.
  SessionProperties sessionProps;
  if (result.encryptedSessionProps != null) {
    sessionProps = parseSessionProps(
      result.encryptedSessionProps!,
      sharedSecret,
    );
  } else {
    sessionProps = const SessionProperties(
      protocolVersion: ProtocolVersion.legacy,
    );
  }

  // Create wallet proxy with send function.
  var nextSequenceNumber = 1;

  final wallet = createMobileWalletProxy(
    (method, params) async {
      if (isClosed()) {
        throw SolanaError(SolanaErrorCode.mwaSessionClosed);
      }

      final seqNum = nextSequenceNumber++;
      final encrypted = encryptJsonRpcRequest(
        seqNum,
        method,
        params,
        sharedSecret,
      );

      reflectorChannel.sink.add(encrypted);

      // Wait for response.
      final responseCompleter = Completer<Uint8List>();
      final responseSub = reflectorChannel.stream.listen(
        (message) {
          if (!responseCompleter.isCompleted && message is List<int>) {
            responseCompleter.complete(Uint8List.fromList(message));
          }
        },
        onError: (Object error) {
          if (!responseCompleter.isCompleted) {
            responseCompleter.completeError(error);
          }
        },
      );

      try {
        final responseBytes = await responseCompleter.future.timeout(
          const Duration(milliseconds: mwaConnectionTimeoutMs),
          onTimeout: () =>
              throw SolanaError(SolanaErrorCode.mwaSessionTimeout),
        );
        return decryptJsonRpcResponse(responseBytes, sharedSecret);
      } finally {
        await responseSub.cancel();
      }
    },
    sessionProps,
  );

  return wrapWithKitApi(wallet);
}
