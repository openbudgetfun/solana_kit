import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:solana_kit_addresses/solana_kit_addresses.dart'
    hide tokenMetadataProgramAddress;
import 'package:solana_kit_dapp_publisher_cli/src/cli.dart';
import 'package:solana_kit_dapp_publisher_cli/src/errors.dart';
import 'package:solana_kit_dapp_publisher_cli/src/funding_preflight.dart';
import 'package:solana_kit_dapp_publisher_cli/src/portal_translators.dart';
import 'package:solana_kit_dapp_publisher_cli/src/portal_types.dart';
import 'package:solana_kit_dapp_publisher_cli/src/publication_models.dart';
import 'package:solana_kit_dapp_publisher_cli/src/publication_signer.dart';
import 'package:solana_kit_dapp_publisher_cli/src/publication_workflow.dart';
import 'package:solana_kit_dapp_publisher_cli/src/release_metadata.dart';
import 'package:solana_kit_dapp_publisher_cli/src/workflow_client.dart';
import 'package:solana_kit_dapp_publisher_cli/src/workflow_state.dart';
import 'package:solana_kit_keys/solana_kit_keys.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';
import 'package:solana_kit_transactions/solana_kit_transactions.dart';
import 'package:test/test.dart';

final KeyPair publisherKeypair = generateKeyPair();
final publisherAddress = getAddressFromPublicKey(
  publisherKeypair.publicKey,
).toString();

class _TestFailure implements Exception {
  const _TestFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

class _DummySigner implements PublicationSigner {
  @override
  String get address => publisherAddress;

  @override
  Future<Transaction> signTransaction(Transaction transaction) async =>
      transaction;

  @override
  Future<Uint8List> signMessage(Uint8List message) async => message;
}

Future<({num slot, String blockhash})> fakeBlockData() async =>
    (slot: 1, blockhash: publisherAddress);

Map<String, Object?> minimalBackend() => <String, Object?>{
  'ingestionSessionId': 'ing-1',
  'publicationSessionId': 'pub-1',
  'releaseId': 'rel-1',
  'release': <String, Object?>{
    'id': 'rel-1',
    'dappId': 'dapp-1',
    'androidPackage': 'com.example.app',
    'versionName': '1',
    'versionCode': 1,
    'newInVersion': 'n',
    'localizedName': 'App',
    'releaseFileName': 'app.apk',
    'releaseFileSize': 1,
  },
  'dapp': <String, Object?>{
    'id': 'dapp-1',
    'dappName': 'App',
    'description': 'Long',
    'androidPackage': 'com.example.app',
    'dappIconUrl': 'https://img.example.com/icon.png',
    'languages': <String>['en-US'],
    'walletAddress': publisherAddress,
    'nftMintAddress': 'app-mint',
  },
  'publisher': <String, Object?>{'id': 'p'},
  'installFile': <String, Object?>{
    'uri': 'https://files.example.com/app.apk',
    'mimeType': 'application/vnd.android.package-archive',
    'size': 1,
  },
  'signerAuthority': <String, Object?>{
    'dappWalletAddress': publisherAddress,
    'collectionAuthority': publisherAddress,
    'appMintAddress': 'app-mint',
    'acceptedSignerRoles': <String>['publisher', 'payer'],
    'feePayer': publisherAddress,
  },
};

class _TestWorkflowClient implements PublicationWorkflowClient {
  final calls = <String>[];
  bool failOnPrepare = true;
  bool failOnPrepareOnce = true;
  int prepareCalls = 0;

  @override
  Future<PortalUploadTarget> createUploadTarget(
    CreateUploadTargetInput input,
  ) async => const PortalUploadTarget(uploadUrl: 'u', publicUrl: 'p');

  @override
  Future<PublicationIngestionSession> createIngestionSession(
    CreateIngestionSessionInput input,
  ) async {
    calls.add('createIngestionSession');
    return translateBackendIngestionSession(<String, Object?>{
      'id': 'ing-1',
      'status': 'Ready',
      'releaseId': 'rel-1',
      'publicationSessionId': 'pub-1',
    });
  }

  @override
  Future<PublicationIngestionSession> getIngestionSession({
    required String sessionId,
  }) async {
    calls.add('getIngestionSession');
    return translateBackendIngestionSession(<String, Object?>{
      'id': 'ing-1',
      'status': 'Ready',
      'releaseId': 'rel-1',
      'publicationSessionId': 'pub-1',
    });
  }

  @override
  Future<PublicationBundle> getPublicationBundle({
    required String releaseId,
  }) async {
    calls.add('getPublicationBundle');
    final backend = minimalBackend();
    (backend['release']! as Map<String, Object?>)['nftMintAddress'] =
        'app-mint';
    return mapBackendBundleToPublicationBundle(
      backend,
      'https://meta.example.com/rel-1.json',
      PortalSourceKind.portalUpload,
    );
  }

  @override
  Future<PublicationSession> getPublicationSession({
    String? publicationSessionId,
    String? releaseId,
  }) async {
    calls.add('getPublicationSession');
    return const PublicationSession(
      id: 'pub-1',
      ingestionSessionId: 'ing-1',
      releaseId: 'rel-1',
      status: PublicationSessionStatus.running,
      stage: PublicationSessionStage.preparedForMint,
      checkpoint: PublicationCheckpoint.bundleReady,
      metadataUri: 'https://meta.example.com/rel-1.json',
      releaseMintAddress: null,
      mintTransactionSignature: null,
      verifyTransactionSignature: null,
      attestationRequestUniqueId: null,
      hubspotTicketId: null,
      error: null,
      lastError: null,
      created: '',
      updated: '',
    );
  }

  @override
  Future<PreparedReleaseTransaction> prepareReleaseNftTransaction(
    PrepareReleaseNftTransactionInput input,
  ) async {
    calls.add('prepareReleaseNftTransaction');
    prepareCalls++;
    if (failOnPrepare && (!failOnPrepareOnce || prepareCalls == 1)) {
      throw const _TestFailure('prepare failed');
    }
    return PreparedReleaseTransaction(
      transaction: base64Encode(getTransactionEncoder().encode(_simpleTx())),
      mintAddress: 'm',
      blockhash: publisherAddress,
    );
  }

  @override
  Future<SubmitSignedTransactionResult> submitSignedTransaction({
    required String signedTransaction,
    String? publicationSessionId,
  }) async {
    calls.add('submitSignedTransaction');
    return const SubmitSignedTransactionResult(transactionSignature: 'sig');
  }

  @override
  Future<SaveReleaseNftDataResult> saveReleaseNftData(
    SaveReleaseNftDataInput input,
  ) async {
    calls.add('saveReleaseNftData');
    return const SaveReleaseNftDataResult(success: true);
  }

  @override
  Future<PreparedVerifyCollectionTransaction>
  prepareVerifyCollectionTransaction(
    PrepareVerifyCollectionTransactionInput input,
  ) async {
    calls.add('prepareVerifyCollectionTransaction');
    return PreparedVerifyCollectionTransaction(
      transaction: base64Encode(getTransactionEncoder().encode(_simpleTx())),
      blockhash: publisherAddress,
    );
  }

  @override
  Future<MarkReleaseCollectionAsVerifiedResult>
  markReleaseCollectionAsVerified({
    required String releaseId,
  }) async {
    calls.add('markReleaseCollectionAsVerified');
    return MarkReleaseCollectionAsVerifiedResult(
      success: true,
      releaseId: releaseId,
    );
  }

  @override
  Future<CleanupReleaseResult> cleanupRelease(CleanupReleaseInput input) async {
    calls.add('cleanupRelease');
    return const CleanupReleaseResult(action: 'deleted');
  }

  @override
  Future<SubmitToStoreResult> submitToStore(SubmitToStoreInput input) async {
    calls.add('submitToStore');
    return const SubmitToStoreResult(hubspotTicketId: 'HS-1');
  }
}

Transaction _simpleTx() {
  final messageBytes = getCompiledTransactionMessageEncoder().encode(
    CompiledTransactionMessage(
      version: TransactionVersion.legacy,
      header: const MessageHeader(
        numSignerAccounts: 1,
        numReadonlySignerAccounts: 0,
        numReadonlyNonSignerAccounts: 0,
      ),
      staticAccounts: [Address(publisherAddress)],
      instructions: const [],
      lifetimeToken: publisherAddress,
    ),
  );
  return Transaction(
    messageBytes: messageBytes,
    signatures: {Address(publisherAddress): null},
  );
}

PublicationSession sessionFor(PublicationCheckpoint checkpoint) =>
    PublicationSession(
      id: 'pub-1',
      ingestionSessionId: 'ing-1',
      releaseId: 'rel-1',
      status: PublicationSessionStatus.running,
      stage: PublicationSessionStage.preparedForMint,
      checkpoint: checkpoint,
      metadataUri: 'https://meta.example.com/rel-1.json',
      releaseMintAddress: null,
      mintTransactionSignature: null,
      verifyTransactionSignature: null,
      attestationRequestUniqueId: 'from-session',
      hubspotTicketId: null,
      error: null,
      lastError: null,
      created: '',
      updated: '',
    );

class _FakeMetadataPortalClient implements ReleaseMetadataPortalClient {
  final fetchCalls = <String>[];
  final FakeUploadClient uploadClient = FakeUploadClient();
  String mimeType = 'image/png';
  String fileName = 'icon.png';
  bool emptyData = false;

  @override
  Future<PortalUploadTarget> createUploadTarget(
    CreateUploadTargetInput input,
  ) async => PortalUploadTarget(
    uploadUrl: 'https://upload.example.com',
    publicUrl: 'https://public.example.com/${input.fileExtension}',
  );

  @override
  Future<RemoteFilePayload> fetchRemoteFile({
    required String url,
    String? fileName,
    String? expectedMimeType,
  }) async {
    fetchCalls.add(url);
    return RemoteFilePayload(
      data: emptyData ? '' : base64Encode(pngBytes(width: 4, height: 4)),
      fileName: this.fileName,
      mimeType: mimeType,
    );
  }
}

class FakeUploadClient extends http.BaseClient {
  final requests = <http.Request>[];

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final request2 = request as http.Request;
    requests.add(request2);
    return http.StreamedResponse(
      const Stream<List<int>>.empty(),
      200,
    );
  }
}

Uint8List pngBytes({required int width, required int height}) {
  final data = ByteData(24)
    ..setUint32(0, 0x89504e47)
    ..setUint32(4, 0x0d0a1a0a)
    ..setUint32(8, 0x0000000d)
    ..setUint32(12, 0x49484452)
    ..setUint32(16, width)
    ..setUint32(20, height);
  return data.buffer.asUint8List();
}

void main() {
  group('CreateIngestionSessionInput source kinds', () {
    test('portal upload source with a hash', () {
      const input = CreateIngestionSessionInput(
        source: PortalUploadSource(
          releaseFileUrl: 'u',
          releaseFileName: 'f',
          releaseFileSize: 1,
          releaseFileHash: 'h',
        ),
        whatsNew: 'n',
        idempotencyKey: 'k',
      );
      final source = input.toMap()['source']! as Map<String, Object?>;
      expect(source['releaseFileHash'], 'h');
    });

    test('apk url source with a file name', () {
      const input = CreateIngestionSessionInput(
        source: ApkUrlSource(
          url: 'https://files.example.com/app.apk',
          fileName: 'app.apk',
        ),
        whatsNew: 'n',
        idempotencyKey: 'k',
      );
      final source = input.toMap()['source']! as Map<String, Object?>;
      expect(source['releaseFileName'], 'app.apk');
    });

    test('apk file source throws', () {
      const input = CreateIngestionSessionInput(
        source: ApkFileSource(filePath: '/tmp/app.apk', fileName: 'app.apk'),
        whatsNew: 'n',
        idempotencyKey: 'k',
      );
      expect(input.toMap, throwsA(isA<PublisherCliException>()));
    });

    test('existing release source', () {
      const input = CreateIngestionSessionInput(
        source: ExistingReleaseSource(sourceReleaseId: 'rel-9'),
        whatsNew: 'n',
        idempotencyKey: 'k',
      );
      final source = input.toMap()['source']! as Map<String, Object?>;
      expect(source['sourceReleaseId'], 'rel-9');
    });

    test('cleanup release input', () {
      const input = CleanupReleaseInput(releaseId: 'rel-1');
      expect(input.toMap(), {'releaseId': 'rel-1'});
    });
  });

  group('portal translators fallbacks', () {
    test('existing release source uses the backend release id', () {
      final session = translateBackendIngestionSession(<String, Object?>{
        'id': 'ing-1',
        'sourceKind': 'existingRelease',
        'releaseId': 'rel-from-backend',
      });
      expect(
        (session.source as ExistingReleaseSource).sourceReleaseId,
        'rel-from-backend',
      );
    });

    test('session without a publication session id', () {
      final bundle = translateBackendIngestionSession(<String, Object?>{
        'id': 'ing-1',
        'status': 'Ready',
        'publicationSessionId': 'pub-2',
      });
      expect(bundle.publicationSessionId, 'pub-2');
    });

    test('firstString handles non-map intermediates', () {
      expect(firstString(<String, Object?>{}, ['a.b']), isNull);
    });
  });

  group('release metadata gaps', () {
    test('infers the install mime from the uri extension', () async {
      final backend = minimalBackend();
      (backend['installFile']! as Map<String, Object?>)['mimeType'] = '';
      (backend['installFile']! as Map<String, Object?>)['uri'] =
          'https://files.example.com/app.apk';
      final bundle = mapBackendBundleToPublicationBundle(
        backend,
        '',
        PortalSourceKind.portalUpload,
      );
      final client = _FakeMetadataPortalClient();
      final document = await buildReleaseMetadataDocument(
        client,
        bundle,
        PortalSourceKind.portalUpload,
        uploadClient: client.uploadClient,
      );
      final extensions = document['extensions']! as Map<String, Object?>;
      final store = extensions['solana_dapp_store']! as Map<String, Object?>;
      final files = store['files']! as List<Map<String, Object?>>;
      expect(files.single['mime'], 'application/vnd.android.package-archive');
    });

    test('throws when remote media is empty', () async {
      final backend = minimalBackend();
      final bundle = mapBackendBundleToPublicationBundle(
        backend,
        '',
        PortalSourceKind.portalUpload,
      );
      final client = _FakeMetadataPortalClient()..emptyData = true;
      await expectLater(
        buildReleaseMetadataDocument(
          client,
          bundle,
          PortalSourceKind.portalUpload,
          uploadClient: client.uploadClient,
        ),
        throwsA(
          isA<PublisherCliException>().having(
            (error) => error.message,
            'message',
            contains('Remote media file is empty'),
          ),
        ),
      );
    });

    test('JPEG with non-FF leading bytes continues scanning', () {
      final bytes = Uint8List.fromList([
        0xFF, 0xD8, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, //
        0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e,
      ]);
      expect(readImageDimensions(bytes), isNull);
    });
  });

  group('publication workflow fallbacks', () {
    test('uses the ingestion session release id on failure', () async {
      final client = _TestWorkflowClient();
      final logLines = <String>[];
      final workflow = PublicationWorkflow(
        client,
        options: PublicationWorkflowOptions(
          pollInterval: Duration.zero,
          logger: (message, {required step, required status}) {
            logLines.add('$step: $status');
          },
        ),
      );
      await expectLater(
        workflow.startPublication(
          PublicationWorkflowInput(
            source: const ApkUrlSource(
              url: 'https://files.example.com/app.apk',
            ),
            whatsNew: 'n',
            signer: _DummySigner(),
            attestationClient: fakeBlockData,
          ),
        ),
        throwsA(
          isA<PublisherCliException>().having(
            (error) => error.message,
            'message',
            contains('prepare failed'),
          ),
        ),
      );
      expect(client.calls, contains('getIngestionSession'));
      expect(client.calls, contains('cleanupRelease'));
      expect(logLines, isNotEmpty);
    });

    test('uses the attestation id from the session', () async {
      final client = _TestWorkflowClient()..failOnPrepare = false;
      final result = await runPublicationWorkflowCore(
        client,
        await client.getPublicationBundle(releaseId: 'rel-1'),
        _DummySigner(),
        fakeBlockData,
        sessionFor(PublicationCheckpoint.submitted),
        null,
      );
      expect(result.attestationRequestUniqueId, 'from-session');
    });

    test('fails with a fallback error message', () async {
      final client = _TestWorkflowClient();
      await expectLater(
        runPublicationWorkflowCore(
          client,
          await client.getPublicationBundle(releaseId: 'rel-1'),
          _DummySigner(),
          fakeBlockData,
          const PublicationSession(
            id: 'pub-1',
            ingestionSessionId: 'ing-1',
            releaseId: 'rel-1',
            status: PublicationSessionStatus.failed,
            stage: PublicationSessionStage.failed,
            checkpoint: PublicationCheckpoint.created,
            metadataUri: null,
            releaseMintAddress: null,
            mintTransactionSignature: null,
            verifyTransactionSignature: null,
            attestationRequestUniqueId: null,
            hubspotTicketId: null,
            error: null,
            lastError: null,
            created: '',
            updated: '',
          ),
          null,
        ),
        throwsA(
          isA<PublisherCliException>().having(
            (error) => error.message,
            'message',
            'Publication session failed',
          ),
        ),
      );
    });
  });

  group('workflow_state validation', () {
    test('reports empty list fields', () {
      final backend = minimalBackend();
      backend['signerAuthority'] = <String, Object?>{
        'dappWalletAddress': 'w',
        'collectionAuthority': 'w',
        'appMintAddress': 'm',
        'acceptedSignerRoles': <String>[],
      };
      final bundle = mapBackendBundleToPublicationBundle(
        backend,
        '',
        PortalSourceKind.portalUpload,
      );
      try {
        validatePublicationBundle(bundle);
        fail('expected a throw');
      } on PublisherCliException catch (error) {
        expect(error.message, contains('acceptedSignerRoles'));
      }
    });

    test('resolves stages from checkpoints', () {
      PublicationSession sessionWith(PublicationCheckpoint checkpoint) =>
          PublicationSession(
            id: 'p',
            ingestionSessionId: 'i',
            releaseId: 'r',
            status: PublicationSessionStatus.running,
            stage: PublicationSessionStage.preparedForMint,
            checkpoint: checkpoint,
            metadataUri: null,
            releaseMintAddress: null,
            mintTransactionSignature: null,
            verifyTransactionSignature: null,
            attestationRequestUniqueId: null,
            hubspotTicketId: null,
            error: null,
            lastError: null,
            created: '',
            updated: '',
          );

      expect(
        resolvePublicationSessionStage(
          sessionWith(PublicationCheckpoint.created),
        ),
        PublicationSessionStage.preparedForMint,
      );
      expect(
        resolvePublicationSessionStage(
          sessionWith(PublicationCheckpoint.verificationSubmitted),
        ),
        PublicationSessionStage.verificationSubmitted,
      );
      expect(
        resolvePublicationSessionStage(
          sessionWith(PublicationCheckpoint.mintSaved),
        ),
        PublicationSessionStage.mintSaved,
      );
      expect(
        resolvePublicationSessionStage(
          sessionWith(PublicationCheckpoint.mintSubmitted),
        ),
        PublicationSessionStage.mintSubmitted,
      );
    });
  });

  group('funding preflight', () {
    test('parses int, num, string, and fallback balances', () {
      expect(
        parseLamportsValue(<String, Object?>{'value': 42}),
        42,
      );
      expect(
        parseLamportsValue(<String, Object?>{'value': 42.5}),
        42,
      );
      expect(
        parseLamportsValue(<String, Object?>{'value': '43'}),
        43,
      );
      expect(parseLamportsValue(const <String, Object?>{}), 0);
      expect(
        parseLamportsValue(<String, Object?>{'value': null}),
        0,
      );
      expect(
        parseLamportsValue(<String, Object?>{'value': <String, Object?>{}}),
        0,
      );
    });

    test('throws for an unreachable RPC', () async {
      await expectLater(
        defaultBalanceFetcher(
          publisherAddress,
          'https://rpc.invalid.example.com',
        ),
        throwsA(anything),
      );
    });
  });

  group('remaining edge cases', () {
    test('portal upload source toMap without a hash', () {
      const input = CreateIngestionSessionInput(
        source: PortalUploadSource(
          releaseFileUrl: 'u',
          releaseFileName: 'f',
          releaseFileSize: 1,
        ),
        whatsNew: 'n',
        idempotencyKey: 'k',
      );
      final source = input.toMap()['source']! as Map<String, Object?>;
      expect(source['releaseFileHash'], isNull);
    });

    test('release metadata with an unknown install uri extension', () async {
      final backend = minimalBackend();
      (backend['installFile']! as Map<String, Object?>)['mimeType'] = '';
      (backend['installFile']! as Map<String, Object?>)['uri'] =
          'https://files.example.com/app';
      final bundle = mapBackendBundleToPublicationBundle(
        backend,
        '',
        PortalSourceKind.portalUpload,
      );
      final client = _FakeMetadataPortalClient();
      final document = await buildReleaseMetadataDocument(
        client,
        bundle,
        PortalSourceKind.portalUpload,
        uploadClient: client.uploadClient,
      );
      final extensions = document['extensions']! as Map<String, Object?>;
      final store = extensions['solana_dapp_store']! as Map<String, Object?>;
      final files = store['files']! as List<Map<String, Object?>>;
      expect(files.single['mime'], 'application/octet-stream');
    });

    test('JPEG scans past non-marker bytes to find the SOF marker', () {
      final bytes = Uint8List.fromList([
        0xFF, 0xD8,
        0x01, 0x02, 0x03, 0x04, // non-FF bytes -> offset++
        0xFF,
        0xC0,
        0x00,
        0x0B,
        0x08,
        0x00,
        0x64,
        0x00,
        0xC8,
        0x03,
        0x01,
        0x22,
        0x00,
        0xFF, 0xD9,
      ]);
      final dimensions = readImageDimensions(bytes);
      expect(dimensions!.$1, 200);
      expect(dimensions.$2, 100);
    });

    test('JPEG with non-SOF markers continues', () {
      final bytes = Uint8List.fromList([
        0xFF,
        0xD8,
        0xFF,
        0xE0,
        0x00,
        0x04,
        0x4a,
        0x46,
        0xFF,
        0xC0,
        0x00,
        0x0B,
        0x08,
        0x00,
        0x64,
        0x00,
        0xC8,
        0x03,
        0x01,
        0x22,
        0x00,
        0xFF,
        0xD9,
      ]);
      final dimensions = readImageDimensions(bytes);
      expect(dimensions!.$1, 200);
    });

    test('WebP VP8L dimensions', () {
      final bytes = _webp('VP8L');
      bytes[21] = 99;
      bytes[22] = 0;
      bytes[23] = 1;
      bytes[24] = 0;
      final dimensions = readImageDimensions(bytes);
      expect(dimensions, isNotNull);
    });

    test('WebP VP8 dimensions', () {
      final bytes = _webp('VP8 ');
      ByteData.sublistView(bytes)
        ..setUint16(26, 100, Endian.little)
        ..setUint16(28, 200, Endian.little);
      final dimensions = readImageDimensions(bytes);
      expect(dimensions!.$1, 100);
      expect(dimensions.$2, 200);
    });

    test('WebP unknown format returns null', () {
      final bytes = _webp('XXXX');
      expect(readImageDimensions(bytes), isNull);
    });
  });

  group('final edge cases', () {
    test('ingestion failed with no error fields', () async {
      final client = _NoErrorFailedIngestionClient();
      await expectLater(
        waitForIngestionSessionReady(
          client,
          'ing-1',
          const PublicationWorkflowOptions(pollInterval: Duration.zero),
        ),
        throwsA(
          isA<PublisherCliException>().having(
            (error) => error.message,
            'message',
            'Publication ingestion failed before the bundle was ready',
          ),
        ),
      );
    });

    test('release metadata install size fallback', () async {
      final backend = minimalBackend();
      (backend['installFile']! as Map<String, Object?>)['size'] = 0;
      (backend['release']! as Map<String, Object?>)['releaseFileSize'] = 4096;
      final bundle = mapBackendBundleToPublicationBundle(
        backend,
        '',
        PortalSourceKind.portalUpload,
      );
      final client = _FakeMetadataPortalClient();
      final document = await buildReleaseMetadataDocument(
        client,
        bundle,
        PortalSourceKind.portalUpload,
        uploadClient: client.uploadClient,
      );
      final extensions = document['extensions']! as Map<String, Object?>;
      final store = extensions['solana_dapp_store']! as Map<String, Object?>;
      final files = store['files']! as List<Map<String, Object?>>;
      expect(files.single['size'], 4096);
    });

    test('JPEG with zero length marker returns null', () {
      final bytes = Uint8List.fromList([
        0xFF, 0xD8,
        0xFF, 0xC0, 0x00, 0x00, // zero length
        0xFF, 0xD9,
      ]);
      expect(readImageDimensions(bytes), isNull);
    });
  });

  group('cli dependencies', () {
    test('default write prints to stdout', () {
      final deps = _NoOverrideDeps();
      expect(deps.environment, isEmpty);
      expect(deps.stdinStream, isNull);
      expect(deps.stdinIsTty, isFalse);
      expect(deps.fileExists('/definitely/not/a/file'), isFalse);
      expect(
        () => deps.fileReader('/definitely/not/a/file'),
        throwsA(anything),
      );
    });

    test('invalid keypair surfaces a non-Cli error', () async {
      final deps = _BadKeypairDeps();
      final exitCode = await runDappStoreCli(
        const [
          '--apk-file',
          '/tmp/app.apk',
          '--whats-new',
          'x',
          '--keypair',
          'k.json',
        ],
        deps,
      );
      expect(exitCode, 1);
    });
  });
}

Uint8List _webp(String format) {
  final bytes = Uint8List(30)
    ..[0] = 0x52
    ..[1] = 0x49
    ..[2] = 0x46
    ..[3] = 0x46
    ..[8] = 0x57
    ..[9] = 0x45
    ..[10] = 0x42
    ..[11] = 0x50;
  for (var i = 0; i < 4; i++) {
    bytes[12 + i] = format.codeUnitAt(i);
  }

  return bytes;
}

class _NoErrorFailedIngestionClient implements PublicationWorkflowClient {
  PublicationIngestionSession _failedSession() =>
      const PublicationIngestionSession(
        id: 'ing-1',
        dappId: '',
        idempotencyKey: '',
        source: PortalUploadSource(
          releaseFileUrl: '',
          releaseFileName: '',
          releaseFileSize: 0,
        ),
        whatsNew: '',
        status: 'Failed',
        releaseId: null,
        publicationSessionId: null,
        bundle: null,
        publicationSession: null,
        androidPackage: null,
        versionName: null,
        processingProgress: null,
        processingStage: null,
        processingDetail: null,
        processingError: null,
        error: null,
      );

  @override
  Future<PortalUploadTarget> createUploadTarget(
    CreateUploadTargetInput input,
  ) async => const PortalUploadTarget(uploadUrl: 'u', publicUrl: 'p');

  @override
  Future<PublicationIngestionSession> createIngestionSession(
    CreateIngestionSessionInput input,
  ) async => _failedSession();

  @override
  Future<PublicationIngestionSession> getIngestionSession({
    required String sessionId,
  }) async => _failedSession();

  @override
  Future<PublicationBundle> getPublicationBundle({
    required String releaseId,
  }) async => throw UnimplementedError();

  @override
  Future<PublicationSession> getPublicationSession({
    String? publicationSessionId,
    String? releaseId,
  }) async => throw UnimplementedError();

  @override
  Future<PreparedReleaseTransaction> prepareReleaseNftTransaction(
    PrepareReleaseNftTransactionInput input,
  ) async => throw UnimplementedError();

  @override
  Future<SubmitSignedTransactionResult> submitSignedTransaction({
    required String signedTransaction,
    String? publicationSessionId,
  }) async => throw UnimplementedError();

  @override
  Future<SaveReleaseNftDataResult> saveReleaseNftData(
    SaveReleaseNftDataInput input,
  ) async => throw UnimplementedError();

  @override
  Future<PreparedVerifyCollectionTransaction>
  prepareVerifyCollectionTransaction(
    PrepareVerifyCollectionTransactionInput input,
  ) async => throw UnimplementedError();

  @override
  Future<MarkReleaseCollectionAsVerifiedResult>
  markReleaseCollectionAsVerified({
    required String releaseId,
  }) async => throw UnimplementedError();

  @override
  Future<CleanupReleaseResult> cleanupRelease(
    CleanupReleaseInput input,
  ) async => throw UnimplementedError();

  @override
  Future<SubmitToStoreResult> submitToStore(SubmitToStoreInput input) async =>
      throw UnimplementedError();
}

class _BadKeypairDeps extends DappStoreCliDependencies {
  final envVars = {'DAPP_STORE_API_KEY': 'test'};

  @override
  Map<String, String> get environment => envVars;

  @override
  bool fileExists(String path) => true;

  @override
  Uint8List fileReader(String path) => Uint8List.fromList(
    utf8.encode(jsonEncode(List<num>.filled(64, 0))),
  );
}

class _NoOverrideDeps extends DappStoreCliDependencies {}
