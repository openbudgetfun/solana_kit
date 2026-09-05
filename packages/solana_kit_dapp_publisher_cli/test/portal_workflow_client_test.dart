import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:solana_kit_dapp_publisher_cli/src/portal_client.dart';
import 'package:solana_kit_dapp_publisher_cli/src/portal_types.dart';
import 'package:solana_kit_dapp_publisher_cli/src/portal_workflow_client.dart';
import 'package:solana_kit_dapp_publisher_cli/src/workflow_client.dart';
import 'package:test/test.dart';

class _ScriptedPortalServer extends http.BaseClient {
  final responses = <String, http.Response>{};
  final uploadBodies = <String, Uint8List>{};
  final requests = <http.BaseRequest>[];

  void respond(String fragment, http.Response response) {
    responses[fragment] = response;
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    requests.add(request);
    final path = request.url.toString();

    // Handle file uploads.
    if (path.contains('/upload/')) {
      uploadBodies[path] = (request as http.Request).bodyBytes;
      return _emptyResponse();
    }

    for (final entry in responses.entries) {
      if (path.contains(entry.key)) {
        return http.StreamedResponse(
          Stream.value(entry.value.bodyBytes),
          entry.value.statusCode,
          contentLength: entry.value.bodyBytes.length,
          headers: entry.value.headers,
        );
      }
    }
    return _emptyResponse();
  }

  http.StreamedResponse _emptyResponse() {
    return http.StreamedResponse(
      const Stream<List<int>>.empty(),
      200,
    );
  }

  @override
  void close() {}
}

Map<String, Object?> _trpcOk(Object data) => {
  'result': {'data': data},
};

Map<String, Object?> backendBundle({
  String? nftMetadataUri,
}) => {
  'ingestionSessionId': 'ing-1',
  'publicationSessionId': 'pub-1',
  'releaseId': 'rel-1',
  'release': {
    'id': 'rel-1',
    'dappId': 'dapp-1',
    'androidPackage': 'com.example.app',
    'versionName': '1.2.0',
    'versionCode': 120,
    'newInVersion': 'Faster',
    'localizedName': 'My App',
    'releaseFileName': 'app.apk',
    'releaseFileSize': 4,
    'nftMetadataUri': ?nftMetadataUri,
  },
  'dapp': {
    'id': 'dapp-1',
    'dappName': 'My App',
    'description': 'Long description',
    'androidPackage': 'com.example.app',
    'dappIconUrl': 'https://img.example.com/icon.png',
    'dappPreviewUrls': <String>[],
    'walletAddress': 'Wa11et1111111111111111111111111111111111111',
    'nftMintAddress': 'App111111111111111111111111111111111111111',
    'languages': ['en-US'],
  },
  'publisher': {
    'id': 'pub-1',
    'type': 'organization',
    'name': 'Example Inc',
    'website': 'https://example.com',
    'email': 'contact@example.com',
    'supportEmail': 'support@example.com',
  },
  'installFile': {
    'uri': 'https://files.example.com/app.apk',
    'mimeType': 'application/vnd.android.package-archive',
    'size': 4,
    'sha256': 'deadbeef',
  },
  'signerAuthority': {
    'dappWalletAddress': 'Wa11et1111111111111111111111111111111111111',
    'collectionAuthority': 'Wa11et1111111111111111111111111111111111111',
    'appMintAddress': 'App111111111111111111111111111111111111111',
    'acceptedSignerRoles': ['publisher', 'payer'],
    'feePayer': 'Wa11et1111111111111111111111111111111111111',
  },
};

const _apiKey = 'test-key';

void main() {
  late _ScriptedPortalServer client;
  late PortalWorkflowClient workflowClient;

  setUp(() {
    client = _ScriptedPortalServer();
    workflowClient = PortalWorkflowClient(
      PortalClientConfig(
        apiBaseUrl: 'https://portal.example.com/api',
        apiKey: const SensitiveString(_apiKey),
        client: client,
      ),
    );
  });

  group('getPublicationBundle', () {
    test('uploads release metadata when the backend omits it', () async {
      client
        ..respond(
          'getPublicationBundle',
          http.Response(
            jsonEncode(_trpcOk(backendBundle())),
            200,
          ),
        )
        ..respond(
          'createUploadTarget',
          http.Response(
            jsonEncode(
              _trpcOk({
                'uploadUrl': 'https://portal.example.com/upload/meta.json',
                'publicUrl': 'https://portal.example.com/files/meta.json',
              }),
            ),
            200,
          ),
        )
        ..respond(
          'fetchRemoteFile',
          http.Response(
            jsonEncode(
              _trpcOk({
                'data': base64Encode(_png(width: 100, height: 100)),
                'fileName': 'icon.png',
                'mimeType': 'image/png',
              }),
            ),
            200,
          ),
        );

      final bundle = await workflowClient.getPublicationBundle(
        releaseId: 'rel-1',
      );
      expect(
        bundle.metadata.releaseMetadataUri,
        'https://portal.example.com/files/meta.json',
      );
      // The upload target + upload happened.
      expect(client.uploadBodies, isNotEmpty);
    });

    test('uses the backend metadata uri when present', () async {
      client.respond(
        'getPublicationBundle',
        http.Response(
          jsonEncode(
            _trpcOk(
              backendBundle(
                nftMetadataUri: 'https://already.example.com/meta.json',
              ),
            ),
          ),
          200,
        ),
      );
      final bundle = await workflowClient.getPublicationBundle(
        releaseId: 'rel-1',
      );
      expect(
        bundle.metadata.releaseMetadataUri,
        'https://already.example.com/meta.json',
      );
      // No upload happened.
      expect(client.uploadBodies, isEmpty);
    });

    test('caches the metadata uri for repeated calls', () async {
      client
        ..respond(
          'getPublicationBundle',
          http.Response(
            jsonEncode(_trpcOk(backendBundle())),
            200,
          ),
        )
        ..respond(
          'createUploadTarget',
          http.Response(
            jsonEncode(
              _trpcOk({
                'uploadUrl': 'https://portal.example.com/upload/meta.json',
                'publicUrl': 'https://portal.example.com/files/meta.json',
              }),
            ),
            200,
          ),
        )
        ..respond(
          'fetchRemoteFile',
          http.Response(
            jsonEncode(
              _trpcOk({
                'data': base64Encode(_png(width: 100, height: 100)),
                'fileName': 'icon.png',
                'mimeType': 'image/png',
              }),
            ),
            200,
          ),
        );

      await workflowClient.getPublicationBundle(releaseId: 'rel-1');
      final uploadCount = client.uploadBodies.length;
      await workflowClient.getPublicationBundle(releaseId: 'rel-1');
      expect(client.uploadBodies.length, uploadCount);
    });
  });

  group('getPublicationSession', () {
    test('tracks the publication session id', () async {
      client.respond(
        'getPublicationSession',
        http.Response(
          jsonEncode(
            _trpcOk({
              'id': 'pub-99',
              'ingestionSessionId': 'ing-1',
              'releaseId': 'rel-1',
              'stage': 'PreparedForMint',
            }),
          ),
          200,
        ),
      );
      final session = await workflowClient.getPublicationSession(
        publicationSessionId: 'pub-99',
      );
      expect(session.id, 'pub-99');
    });
  });

  group('getIngestionSession', () {
    test('tracks the session and release ids', () async {
      client.respond(
        'getIngestionSession',
        http.Response(
          jsonEncode(
            _trpcOk({
              'id': 'ing-1',
              'status': 'Ready',
              'releaseId': 'rel-1',
              'publicationSessionId': 'pub-1',
              'publicationSession': {'id': 'pub-1'},
            }),
          ),
          200,
        ),
      );
      final session = await workflowClient.getIngestionSession(
        sessionId: 'ing-1',
      );
      expect(session.releaseId, 'rel-1');
      expect(session.publicationSessionId, 'pub-1');
    });

    test('tracks when the publication session id is absent', () async {
      client.respond(
        'getIngestionSession',
        http.Response(
          jsonEncode(
            _trpcOk({
              'id': 'ing-1',
              'status': 'Ready',
              'publicationSession': {'id': 'pub-7'},
            }),
          ),
          200,
        ),
      );
      final session = await workflowClient.getIngestionSession(
        sessionId: 'ing-1',
      );
      expect(session.publicationSessionId, isNull);
    });
  });

  group('mutations', () {
    test('cleanupRelease', () async {
      client.respond(
        'cleanupRelease',
        http.Response(
          jsonEncode(_trpcOk({'action': 'deleted'})),
          200,
        ),
      );
      final result = await workflowClient.cleanupRelease(
        const CleanupReleaseInput(releaseId: 'rel-1'),
      );
      expect(result.action, 'deleted');
    });

    test('markReleaseCollectionAsVerified', () async {
      client.respond(
        'markReleaseCollectionAsVerified',
        http.Response(
          jsonEncode(_trpcOk({'success': true, 'releaseId': 'rel-1'})),
          200,
        ),
      );
      final result = await workflowClient.markReleaseCollectionAsVerified(
        releaseId: 'rel-1',
      );
      expect(result.success, isTrue);
    });

    test('prepareReleaseNftTransaction', () async {
      client.respond(
        'prepareReleaseNftTransaction',
        http.Response(
          jsonEncode(
            _trpcOk({
              'transaction': 'dHg=',
              'mintAddress': 'm',
              'blockhash': 'b',
            }),
          ),
          200,
        ),
      );
      final result = await workflowClient.prepareReleaseNftTransaction(
        const PrepareReleaseNftTransactionInput(
          releaseId: 'rel-1',
          releaseName: 'n',
          releaseMetadataUri: 'u',
          appMintAddress: 'm',
          publisherAddress: 'p',
          payerAddress: 'p',
        ),
      );
      expect(result.mintAddress, 'm');
    });

    test('submitSignedTransaction without a session id', () async {
      client.respond(
        'submitSignedTransaction',
        http.Response(
          jsonEncode(_trpcOk({'transactionSignature': 'sig'})),
          200,
        ),
      );
      final result = await workflowClient.submitSignedTransaction(
        signedTransaction: 'tx',
      );
      expect(result.transactionSignature, 'sig');
    });

    test('saveReleaseNftData', () async {
      client.respond(
        'saveReleaseNftData',
        http.Response(
          jsonEncode(_trpcOk({'success': true})),
          200,
        ),
      );
      final result = await workflowClient.saveReleaseNftData(
        const SaveReleaseNftDataInput(
          releaseId: 'rel-1',
          mintAddress: 'm',
          transactionSignature: 's',
          metadataUri: 'u',
          ownerAddress: 'o',
          releaseName: 'n',
          releaseVersion: 'v',
          androidPackage: 'a',
          appMintAddress: 'm',
        ),
      );
      expect(result.success, isTrue);
    });

    test('prepareVerifyCollectionTransaction', () async {
      client.respond(
        'prepareVerifyCollectionTransaction',
        http.Response(
          jsonEncode(
            _trpcOk({
              'transaction': 'dHg=',
              'blockhash': 'b',
            }),
          ),
          200,
        ),
      );
      final result = await workflowClient.prepareVerifyCollectionTransaction(
        const PrepareVerifyCollectionTransactionInput(
          dappId: 'd',
          nftMintAddress: 'n',
          collectionMintAddress: 'c',
          collectionAuthority: 'a',
          payerAddress: 'p',
        ),
      );
      expect(result.blockhash, 'b');
    });

    test('submitToStore', () async {
      client.respond(
        'submitToStore',
        http.Response(
          jsonEncode(_trpcOk({'hubspotTicketId': 'HS-1'})),
          200,
        ),
      );
      final result = await workflowClient.submitToStore(
        const SubmitToStoreInput(
          releaseId: 'rel-1',
          whatsNew: 'n',
          criticalUpdate: false,
          attestationPayload: 'a',
          requestUniqueId: 'r',
        ),
      );
      expect(result.hubspotTicketId, 'HS-1');
    });

    test('createUploadTarget', () async {
      client.respond(
        'createUploadTarget',
        http.Response(
          jsonEncode(
            _trpcOk({
              'uploadUrl': 'https://u',
              'publicUrl': 'https://p',
            }),
          ),
          200,
        ),
      );
      final result = await workflowClient.createUploadTarget(
        const CreateUploadTargetInput(
          fileHash: 'h',
          fileExtension: 'apk',
          contentType: 'application/vnd.android.package-archive',
        ),
      );
      expect(result.uploadUrl, 'https://u');
    });
  });

  group('release metadata uri from the release', () {
    test('uses the backend metadata uri when present', () async {
      client.respond(
        'getPublicationBundle',
        http.Response(
          jsonEncode(
            _trpcOk(
              backendBundle(
                nftMetadataUri: 'https://already.example.com/meta.json',
              ),
            ),
          ),
          200,
        ),
      );
      final bundle = await workflowClient.getPublicationBundle(
        releaseId: 'rel-1',
      );
      expect(
        bundle.metadata.releaseMetadataUri,
        'https://already.example.com/meta.json',
      );
      // No upload happened since the metadata uri was already present.
      expect(client.uploadBodies, isEmpty);
    });
  });

  group('PortalAttestationClient', () {
    test('getBlockData through the portal', () async {
      client.respond(
        'getBlockData',
        http.Response(
          jsonEncode(_trpcOk({'slot': 42, 'blockhash': 'Bh'})),
          200,
        ),
      );
      final attestationClient = createPortalAttestationClient(
        PortalClientConfig(
          apiBaseUrl: 'https://portal.example.com/api',
          apiKey: const SensitiveString(_apiKey),
          client: client,
        ),
      );
      final blockData = await attestationClient();
      expect(blockData.slot, 42);
      expect(blockData.blockhash, 'Bh');
    });
  });
}

Uint8List _png({required int width, required int height}) {
  final data = ByteData(24)
    ..setUint32(0, 0x89504e47)
    ..setUint32(4, 0x0d0a1a0a)
    ..setUint32(8, 0x0000000d)
    ..setUint32(12, 0x49484452)
    ..setUint32(16, width)
    ..setUint32(20, height);
  return data.buffer.asUint8List();
}
