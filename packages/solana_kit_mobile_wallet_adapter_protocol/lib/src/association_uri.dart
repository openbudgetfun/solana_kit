import 'dart:convert';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';

import 'package:solana_kit_errors/solana_kit_errors.dart';

import 'package:solana_kit_mobile_wallet_adapter_protocol/src/association_keypair.dart';
import 'package:solana_kit_mobile_wallet_adapter_protocol/src/association_port.dart';
import 'package:solana_kit_mobile_wallet_adapter_protocol/src/constants.dart';
import 'package:solana_kit_mobile_wallet_adapter_protocol/src/types.dart';

/// Builds a local association URI for launching the wallet app.
///
/// Format: `solana-wallet:/v1/associate/local?association=<base64url>&port=<port>&v=v1`
///
/// If [baseUri] is provided, it must be an `https:` URL and will be used as
/// the base for the intent URI (for wallet-specific deep links).
Uri buildLocalAssociationUri(
  ECPublicKey associationPublicKey,
  int port, {
  String? baseUri,
  List<String> protocolVersions = const ['v1'],
}) {
  assertAssociationPort(port);
  final publicKeyBytes = exportPublicKeyBytes(associationPublicKey);
  final encodedKey = _toBase64Url(publicKeyBytes);

  final base = _getIntentUri('v1/associate/local', baseUri);

  return base.replace(
    queryParameters: {
      'association': encodedKey,
      'port': '$port',
      'v': protocolVersions.last,
    },
  );
}

/// Builds a remote association URI for connecting via a reflector.
///
/// Format: `solana-wallet:/v1/associate/remote?association=<base64url>&reflector=<host>&id=<id>&v=v1`
Uri buildRemoteAssociationUri(
  ECPublicKey associationPublicKey,
  String reflectorHost,
  Uint8List reflectorId, {
  String? baseUri,
  List<String> protocolVersions = const ['v1'],
}) {
  final publicKeyBytes = exportPublicKeyBytes(associationPublicKey);
  final encodedKey = _toBase64Url(publicKeyBytes);
  final encodedId = _toBase64Url(reflectorId);

  final base = _getIntentUri('v1/associate/remote', baseUri);

  return base.replace(
    queryParameters: {
      'association': encodedKey,
      'reflector': reflectorHost,
      'id': encodedId,
      'v': protocolVersions.last,
    },
  );
}

/// Parses an MWA association URI into its components.
///
/// Returns a [LocalAssociationParams] or [RemoteAssociationParams] depending
/// on the URI path.
AssociationParams parseAssociationUri(Uri uri) {
  final association = uri.queryParameters['association']!;
  final protocol = uri.queryParameters['v'] ?? 'v1';
  final publicKeyBytes = _fromBase64Url(association);

  final path = uri.path;
  if (path.contains('local')) {
    final port = int.parse(uri.queryParameters['port']!);
    return LocalAssociationParams(
      associationPublicKey: publicKeyBytes,
      protocol: protocol,
      port: port,
    );
  } else if (path.contains('remote')) {
    final reflectorHost = uri.queryParameters['reflector']!;
    final reflectorIdBytes = _fromBase64Url(uri.queryParameters['id']!);
    // Parse reflector ID from bytes (it's encoded as base64url).
    final reflectorId = reflectorIdBytes.isNotEmpty
        ? _bytesToInt(reflectorIdBytes)
        : 0;
    return RemoteAssociationParams(
      associationPublicKey: publicKeyBytes,
      protocol: protocol,
      reflectorHost: reflectorHost,
      reflectorId: reflectorId,
    );
  }

  throw ArgumentError('Unknown association URI path: $path');
}

/// Constructs the base intent URI with proper scheme handling.
Uri _getIntentUri(String methodPathname, String? intentUrlBase) {
  if (intentUrlBase != null) {
    final baseUrl = Uri.tryParse(intentUrlBase);
    if (baseUrl == null || baseUrl.scheme != 'https') {
      throw SolanaError(SolanaErrorCode.mwaForbiddenWalletBaseUrl, {
        'url': intentUrlBase,
      });
    }
    return baseUrl.resolve(methodPathname);
  }
  return Uri.parse('$mwaIntentScheme:/$methodPathname');
}

/// Encodes bytes as base64url without padding.
String _toBase64Url(Uint8List bytes) {
  return base64Url.encode(bytes).replaceAll('=', '');
}

/// Decodes a base64url string (with or without padding) to bytes.
Uint8List _fromBase64Url(String encoded) {
  // Restore padding.
  var padded = encoded;
  final remainder = padded.length % 4;
  if (remainder != 0) {
    padded = padded.padRight(padded.length + (4 - remainder), '=');
  }
  return Uint8List.fromList(base64Url.decode(padded));
}

/// Converts bytes to an integer (big-endian).
int _bytesToInt(Uint8List bytes) {
  var result = 0;
  for (var i = 0; i < bytes.length; i++) {
    result = (result << 8) | bytes[i];
  }
  return result;
}
