import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:solana_kit_addresses/solana_kit_addresses.dart'
    hide tokenMetadataProgramAddress;
import 'package:solana_kit_dapp_publisher_cli/src/errors.dart';
import 'package:solana_kit_dapp_publisher_cli/src/files.dart';
import 'package:solana_kit_dapp_publisher_cli/src/portal_translators.dart';
import 'package:solana_kit_dapp_publisher_cli/src/portal_types.dart';
import 'package:solana_kit_dapp_publisher_cli/src/publication_models.dart';
import 'package:solana_kit_dapp_publisher_cli/src/publication_signer.dart';
import 'package:solana_kit_dapp_publisher_cli/src/publication_workflow.dart';
import 'package:solana_kit_dapp_publisher_cli/src/workflow_client.dart';
import 'package:solana_kit_keys/solana_kit_keys.dart';
import 'package:solana_kit_mpl_token_metadata/solana_kit_mpl_token_metadata.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';
import 'package:solana_kit_transactions/solana_kit_transactions.dart';
import 'package:test/test.dart';

final KeyPair publisherKeypair = generateKeyPair();
final KeyPair mintKeypair = generateKeyPair();
final KeyPair appMintKeypair = generateKeyPair();
final KeyPair collectionAuthorityKeypair = generateKeyPair();

final publisherAddress = getAddressFromPublicKey(
  publisherKeypair.publicKey,
).toString();
final mintAddress = getAddressFromPublicKey(mintKeypair.publicKey).toString();
final appMintAddress = getAddressFromPublicKey(
  appMintKeypair.publicKey,
).toString();
final collectionAuthorityAddress = getAddressFromPublicKey(
  collectionAuthorityKeypair.publicKey,
).toString();

final KeyPair blockhashKeypair = generateKeyPair();
final blockhash = getAddressFromPublicKey(
  blockhashKeypair.publicKey,
).toString();

Address get tokenMetadataProgram =>
    const Address('metaqbxxUerdq28cj1RbAWkYQm3ybzjb6a8bt518x1s');

/// Builds a valid legacy release-mint transaction.
Future<Transaction> buildReleaseMintTransaction() async {
  final metadataPda = (await findMetadataPda(mint: Address(mintAddress))).$1;
  final accounts = <Address>[
    Address(publisherAddress),
    Address(mintAddress),
    tokenMetadataProgram,
    metadataPda,
    const Address('11111111111111111111111111111111'),
  ];
  final instructionData = getCreateInstructionDataEncoder().encode(
    CreateInstructionData(
      createArgs: CreateArgsV1(
        assetData: AssetData(
          name: 'Release',
          symbol: '',
          uri: 'https://meta.example.com/rel-1.json',
          sellerFeeBasisPoints: 0,
          creators: null,
          primarySaleHappened: false,
          isMutable: true,
          tokenStandard: TokenStandard.nonFungible,
          collection: Collection(key: Address(appMintAddress), verified: false),
          uses: null,
          collectionDetails: null,
          ruleSet: null,
        ),
        decimals: null,
        printSupply: null,
      ),
    ),
  );
  final message = CompiledTransactionMessage(
    version: TransactionVersion.legacy,
    header: const MessageHeader(
      numSignerAccounts: 2,
      numReadonlySignerAccounts: 1,
      numReadonlyNonSignerAccounts: 3,
    ),
    staticAccounts: accounts,
    instructions: [
      CompiledInstruction(
        programAddressIndex: 2,
        accountIndices: const [0, 1, 3, 4],
        data: instructionData,
      ),
    ],
    lifetimeToken: blockhash,
  );
  final messageBytes = getCompiledTransactionMessageEncoder().encode(
    message,
  );
  return Transaction(
    messageBytes: messageBytes,
    signatures: {
      Address(publisherAddress): null,
      Address(mintAddress): SignatureBytes(
        signBytes(mintKeypair.privateKey, messageBytes).value,
      ),
    },
  );
}

/// Builds a valid legacy collection-verification transaction.
Future<Transaction> buildVerifyCollectionTransaction() async {
  final nftMetadataPda = (await findMetadataPda(mint: Address(mintAddress))).$1;
  final collectionMetadataPda = (await findMetadataPda(
    mint: Address(appMintAddress),
  )).$1;
  final collectionEdition = (await findMasterEditionPda(
    mint: Address(appMintAddress),
  )).$1;
  final accounts = <Address>[
    Address(publisherAddress),
    Address(collectionAuthorityAddress),
    tokenMetadataProgram,
    nftMetadataPda,
    Address(appMintAddress),
    collectionMetadataPda,
    collectionEdition,
  ];
  final messageBytes = getCompiledTransactionMessageEncoder().encode(
    CompiledTransactionMessage(
      version: TransactionVersion.legacy,
      header: const MessageHeader(
        numSignerAccounts: 2,
        numReadonlySignerAccounts: 0,
        numReadonlyNonSignerAccounts: 5,
      ),
      staticAccounts: accounts,
      instructions: [
        CompiledInstruction(
          programAddressIndex: 2,
          accountIndices: const [0, 1, 3, 4],
          data: Uint8List.fromList([25, 1, 2, 3]),
        ),
      ],
      lifetimeToken: blockhash,
    ),
  );
  return Transaction(
    messageBytes: messageBytes,
    signatures: {
      Address(publisherAddress): null,
      Address(collectionAuthorityAddress): null,
    },
  );
}

class _FakeClient implements PublicationWorkflowClient {
  _FakeClient({PublicationSessionStage? initialStage})
    : stage = initialStage ?? PublicationSessionStage.preparedForMint;

  final List<String> calls = [];
  PublicationSessionStage stage;
  bool failOnPrepare = false;
  bool failOnlyOnce = false;
  bool preserveOnCleanup = false;
  Object? customError;
  int prepareCalls = 0;

  PublicationSession publicationSession() => PublicationSession(
    id: 'pub-1',
    ingestionSessionId: 'ing-1',
    releaseId: 'rel-1',
    status: stage == PublicationSessionStage.failed
        ? PublicationSessionStatus.failed
        : PublicationSessionStatus.running,
    stage: stage,
    checkpoint: _checkpointForStage(stage),
    metadataUri: null,
    releaseMintAddress: mintAddress,
    mintTransactionSignature: null,
    verifyTransactionSignature: null,
    attestationRequestUniqueId: null,
    hubspotTicketId: null,
    error: null,
    lastError: stage == PublicationSessionStage.failed ? 'session boom' : null,
    created: '2026-01-01T00:00:00Z',
    updated: '2026-01-01T00:00:00Z',
  );

  @override
  Future<PortalUploadTarget> createUploadTarget(
    CreateUploadTargetInput input,
  ) async {
    calls.add('createUploadTarget');
    return const PortalUploadTarget(
      uploadUrl: 'https://upload.example.com',
      publicUrl: 'https://public.example.com/file',
    );
  }

  @override
  Future<PublicationIngestionSession> createIngestionSession(
    CreateIngestionSessionInput input,
  ) async {
    calls.add('createIngestionSession');
    return translateBackendIngestionSession({
      'id': 'ing-1',
      'status': 'Ready',
      'releaseId': 'rel-1',
      'publicationSessionId': 'pub-1',
      'bundle': completeBackendBundle(),
      'publicationSession': {'id': 'pub-1'},
    });
  }

  @override
  Future<PublicationIngestionSession> getIngestionSession({
    required String sessionId,
  }) async {
    calls.add('getIngestionSession');
    return translateBackendIngestionSession({
      'id': 'ing-1',
      'status': 'Ready',
      'releaseId': 'rel-1',
      'publicationSessionId': 'pub-1',
      'bundle': completeBackendBundle(),
      'publicationSession': {'id': 'pub-1'},
    });
  }

  @override
  Future<PublicationBundle> getPublicationBundle({
    required String releaseId,
  }) async {
    calls.add('getPublicationBundle');
    return bundled();
  }

  @override
  Future<PublicationSession> getPublicationSession({
    String? publicationSessionId,
    String? releaseId,
  }) async {
    calls.add('getPublicationSession');
    return publicationSession();
  }

  @override
  Future<PreparedReleaseTransaction> prepareReleaseNftTransaction(
    PrepareReleaseNftTransactionInput input,
  ) async {
    calls.add('prepareReleaseNftTransaction');
    prepareCalls++;
    if (failOnPrepare && prepareCalls == 1) {
      final error = customError ?? const _TestFailure('prepare failed');
      if (error is Exception) {
        throw error;
      }
      throw PublisherCliException(error.toString());
    }
    return PreparedReleaseTransaction.fromMap({
      'transaction': base64Encode(
        getTransactionEncoder().encode(await buildReleaseMintTransaction()),
      ),
      'mintAddress': mintAddress,
      'blockhash': blockhash,
    });
  }

  @override
  Future<SubmitSignedTransactionResult> submitSignedTransaction({
    required String signedTransaction,
    String? publicationSessionId,
  }) async {
    calls.add('submitSignedTransaction');
    return const SubmitSignedTransactionResult(
      transactionSignature: 'sig-1',
    );
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
    return PreparedVerifyCollectionTransaction.fromMap({
      'transaction': base64Encode(
        getTransactionEncoder().encode(
          await buildVerifyCollectionTransaction(),
        ),
      ),
      'blockhash': blockhash,
    });
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
    return CleanupReleaseResult(
      action: preserveOnCleanup ? 'preservedSubmitted' : 'deleted',
    );
  }

  @override
  Future<SubmitToStoreResult> submitToStore(SubmitToStoreInput input) async {
    calls.add('submitToStore');
    return const SubmitToStoreResult(hubspotTicketId: 'HS-1');
  }

  PublicationBundle bundled() => mapBackendBundleToPublicationBundle(
    completeBackendBundle(),
    'https://meta.example.com/rel-1.json',
    PortalSourceKind.portalUpload,
  );

  Map<String, Object?> completeBackendBundle() {
    final backend = <String, Object?>{
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
        'releaseFileSize': 2048,
        'nftMetadataUri': 'https://meta.example.com/rel-1.json',
      },
      'dapp': {
        'id': 'dapp-1',
        'dappName': 'My App',
        'description': 'Long',
        'androidPackage': 'com.example.app',
        'dappIconUrl': 'https://img.example.com/icon.png',
        'walletAddress': publisherAddress,
        'nftMintAddress': appMintAddress,
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
        'size': 2048,
        'sha256': 'deadbeef',
      },
      'signerAuthority': {
        'dappWalletAddress': publisherAddress,
        'collectionAuthority': collectionAuthorityAddress,
        'appMintAddress': appMintAddress,
        'acceptedSignerRoles': ['publisher', 'payer'],
        'feePayer': publisherAddress,
      },
    };
    return backend;
  }
}

/// Builds a bundle without a release mint address anywhere.
PublicationBundle mintlessBundle() {
  final backend = <String, Object?>{
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
      'releaseFileSize': 2048,
    },
    'dapp': {
      'id': 'dapp-1',
      'dappName': 'My App',
      'description': 'Long',
      'androidPackage': 'com.example.app',
      'dappIconUrl': 'https://img.example.com/icon.png',
      'walletAddress': publisherAddress,
      'nftMintAddress': appMintAddress,
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
      'size': 2048,
      'sha256': 'deadbeef',
    },
    'signerAuthority': {
      'dappWalletAddress': publisherAddress,
      'collectionAuthority': collectionAuthorityAddress,
      'appMintAddress': appMintAddress,
      'acceptedSignerRoles': ['publisher', 'payer'],
      'feePayer': publisherAddress,
    },
  };
  return mapBackendBundleToPublicationBundle(
    backend,
    'https://meta.example.com/rel-1.json',
    PortalSourceKind.portalUpload,
  );
}

class _TestFailure implements Exception {
  const _TestFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

Future<({num slot, String blockhash})> fakeBlockData() async =>
    (slot: 1, blockhash: blockhash);

class _DummySigner implements PublicationSigner {
  @override
  String get address => publisherAddress;

  @override
  Future<Transaction> signTransaction(Transaction transaction) async =>
      transaction;

  @override
  Future<Uint8List> signMessage(Uint8List message) async => message;
}

PublicationCheckpoint _checkpointForStage(
  PublicationSessionStage stage,
) => switch (stage) {
  PublicationSessionStage.preparedForMint => PublicationCheckpoint.bundleReady,
  PublicationSessionStage.failed => PublicationCheckpoint.created,
  PublicationSessionStage.mintSubmitted => PublicationCheckpoint.mintSubmitted,
  PublicationSessionStage.mintSaved => PublicationCheckpoint.mintSaved,
  PublicationSessionStage.verificationSubmitted =>
    PublicationCheckpoint.verificationSubmitted,
  _ => PublicationCheckpoint.submitted,
};

void main() {
  group('normalizeWorkflowError', () {
    test('passes through PublisherCliException and wraps others', () {
      expect(
        normalizeWorkflowError(const _TestFailure('boom')).message,
        'boom',
      );
      const cli = _TestFailure('cli');
      expect(normalizeWorkflowError(cli).message, 'cli');
    });
  });

  group('resolvePublicationSessionLookup', () {
    test('prefers the session id and validates inputs', () {
      expect(
        resolvePublicationSessionLookup(
          publicationSessionId: 'p',
          releaseId: 'r',
        ),
        (publicationSessionId: 'p', releaseId: null),
      );
      expect(
        resolvePublicationSessionLookup(releaseId: 'r'),
        (publicationSessionId: null, releaseId: 'r'),
      );
      expect(
        resolvePublicationSessionLookup,
        throwsA(isA<PublisherCliException>()),
      );
    });
  });

  group('buildIngestionStatusMessage', () {
    PublicationIngestionSession sessionWith({
      required String status,
      String? detail,
      String? stage,
    }) => translateBackendIngestionSession({
      'id': 'i',
      'status': status,
      'processingDetail': detail,
      'processingStage': stage,
    });

    test('prefers detail, then stage, then status defaults', () {
      expect(
        buildIngestionStatusMessage(
          sessionWith(status: 'created', detail: 'd', stage: 's'),
        ),
        'd',
      );
      expect(
        buildIngestionStatusMessage(sessionWith(status: 'queued', stage: 's')),
        's',
      );
      expect(
        buildIngestionStatusMessage(sessionWith(status: 'created')),
        'Portal ingestion request created',
      );
      expect(
        buildIngestionStatusMessage(sessionWith(status: 'queued')),
        'Portal ingestion queued',
      );
      expect(
        buildIngestionStatusMessage(sessionWith(status: 'processing')),
        'Portal ingestion is processing the APK',
      );
      expect(
        buildIngestionStatusMessage(sessionWith(status: 'Ready')),
        'Portal ingestion is ready',
      );
      expect(
        buildIngestionStatusMessage(sessionWith(status: 'unknown')),
        isNull,
      );
    });
  });

  group('newIdempotencyKey', () {
    test('generates uuid-shaped keys', () {
      final key = newIdempotencyKey();
      expect(
        key,
        matches(
          RegExp(
            r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
          ),
        ),
      );
    });
  });

  group('uploadLocalApkToPortal', () {
    test('uploads an existing APK and returns a portal source', () async {
      final client = _FakeClient();
      final uploadClient = _RecordingUploadClient();
      final directory = await Directory.systemTemp.createTemp();
      addTearDown(() => directory.delete(recursive: true));
      final apkPath = '${directory.path}/release.apk';
      await File(apkPath).writeAsBytes([1, 2, 3, 4]);

      final source = await uploadLocalApkToPortal(
        client,
        ApkFileSource(filePath: apkPath, fileName: 'release.apk'),
        uploadClient: uploadClient,
      );
      expect(source, isA<PortalUploadSource>());
      final portal = source as PortalUploadSource;
      expect(portal.releaseFileName, 'release.apk');
      expect(portal.releaseFileSize, 4);
      expect(portal.contentType, apkContentType);
      expect(client.calls, contains('createUploadTarget'));
      expect(uploadClient.requests, hasLength(1));
    });

    test('throws a friendly error for missing files', () async {
      final client = _FakeClient();
      await expectLater(
        uploadLocalApkToPortal(
          client,
          const ApkFileSource(
            filePath: '/nonexistent/path/app.apk',
            fileName: 'app.apk',
          ),
        ),
        throwsA(
          isA<PublisherCliException>().having(
            (error) => error.message,
            'message',
            contains('Cannot read local APK'),
          ),
        ),
      );
    });

    test('uses custom content types', () async {
      final client = _FakeClient();
      final uploadClient = _RecordingUploadClient();
      final directory = await Directory.systemTemp.createTemp();
      addTearDown(() => directory.delete(recursive: true));
      final apkPath = '${directory.path}/release.apk';
      await File(apkPath).writeAsBytes([1]);
      final source = await uploadLocalApkToPortal(
        client,
        ApkFileSource(
          filePath: apkPath,
          fileName: 'release.apk',
          mimeType: 'application/octet-stream',
        ),
        uploadClient: uploadClient,
      );
      expect(
        (source as PortalUploadSource).contentType,
        'application/octet-stream',
      );
    });
  });

  group('preparePublicationSource', () {
    test('passes through non-file sources', () async {
      const urlSource = ApkUrlSource(url: 'https://x');
      final prepared = await preparePublicationSource(_FakeClient(), urlSource);
      expect(identical(prepared, urlSource), isTrue);
      const existing = ExistingReleaseSource(sourceReleaseId: 'r');
      expect(
        identical(
          await preparePublicationSource(_FakeClient(), existing),
          existing,
        ),
        isTrue,
      );
      const portal = PortalUploadSource(
        releaseFileUrl: 'u',
        releaseFileName: 'f',
        releaseFileSize: 1,
      );
      expect(
        identical(
          await preparePublicationSource(_FakeClient(), portal),
          portal,
        ),
        isTrue,
      );
    });
  });

  group('runPublicationWorkflowCore', () {
    test('rejects a signer mismatch', () async {
      final client = _FakeClient();
      await expectLater(
        runPublicationWorkflowCore(
          client,
          client.bundled(),
          _OtherSigner(),
          fakeBlockData,
          client.publicationSession(),
          null,
        ),
        throwsA(
          isA<PublisherCliException>().having(
            (error) => error.message,
            'message',
            contains('Publication signer mismatch'),
          ),
        ),
      );
    });

    test('throws when the session failed', () async {
      final client = _FakeClient(
        initialStage: PublicationSessionStage.failed,
      );
      await expectLater(
        runPublicationWorkflowCore(
          client,
          client.bundled(),
          _DummySigner(),
          fakeBlockData,
          client.publicationSession(),
          null,
        ),
        throwsA(
          isA<PublisherCliException>().having(
            (error) => error.message,
            'message',
            'session boom',
          ),
        ),
      );
    });

    test('runs all steps on a fresh session', () async {
      final client = _FakeClient();
      final result = await runPublicationWorkflowCore(
        client,
        client.bundled(),
        _DummySigner(),
        fakeBlockData,
        client.publicationSession(),
        null,
      );
      expect(client.calls, [
        'prepareReleaseNftTransaction',
        'submitSignedTransaction',
        'saveReleaseNftData',
        'prepareVerifyCollectionTransaction',
        'submitSignedTransaction',
        'markReleaseCollectionAsVerified',
        'submitToStore',
      ]);
      expect(result.releaseId, 'rel-1');
      expect(result.releaseMintAddress, mintAddress);
      expect(result.collectionMintAddress, appMintAddress);
      expect(result.hubspotTicketId, 'HS-1');
      expect(result.attestationRequestUniqueId, isNotNull);
    });

    test('skips completed steps when the checkpoint advanced', () async {
      final client = _FakeClient(
        initialStage: PublicationSessionStage.mintSaved,
      );
      final session = client.publicationSession();
      await runPublicationWorkflowCore(
        client,
        client.bundled(),
        _DummySigner(),
        fakeBlockData,
        session,
        null,
      );
      expect(client.calls, isNot(contains('prepareReleaseNftTransaction')));
      expect(client.calls, isNot(contains('saveReleaseNftData')));
      expect(client.calls, contains('submitToStore'));
    });

    test('throws when the release transaction signature is missing', () async {
      final client = _FakeClient(
        initialStage: PublicationSessionStage.mintSubmitted,
      );
      final session = PublicationSession(
        id: 'pub-1',
        ingestionSessionId: 'ing-1',
        releaseId: 'rel-1',
        status: PublicationSessionStatus.running,
        stage: PublicationSessionStage.mintSubmitted,
        checkpoint: PublicationCheckpoint.mintSubmitted,
        metadataUri: 'https://meta.example.com/rel-1.json',
        releaseMintAddress: mintAddress,
        mintTransactionSignature: null,
        verifyTransactionSignature: null,
        attestationRequestUniqueId: null,
        hubspotTicketId: null,
        error: null,
        lastError: null,
        created: '2026-01-01T00:00:00Z',
        updated: '2026-01-01T00:00:00Z',
      );
      await expectLater(
        runPublicationWorkflowCore(
          client,
          client.bundled(),
          _DummySigner(),
          fakeBlockData,
          session,
          null,
        ),
        throwsA(
          isA<PublisherCliException>().having(
            (error) => error.message,
            'message',
            contains('Release transaction signature is missing'),
          ),
        ),
      );
    });

    test('throws when no mint can be resolved after submission', () async {
      final client = _FakeClient(
        initialStage: PublicationSessionStage.submitted,
      );
      final bundle = mintlessBundle();
      await expectLater(
        runPublicationWorkflowCore(
          client,
          bundle,
          _DummySigner(),
          fakeBlockData,
          const PublicationSession(
            id: 'pub-1',
            ingestionSessionId: 'ing-1',
            releaseId: 'rel-1',
            status: PublicationSessionStatus.completed,
            stage: PublicationSessionStage.submitted,
            checkpoint: PublicationCheckpoint.submitted,
            metadataUri: 'https://meta.example.com/rel-1.json',
            releaseMintAddress: null,
            mintTransactionSignature: null,
            verifyTransactionSignature: null,
            attestationRequestUniqueId: null,
            hubspotTicketId: 'HS-1',
            error: null,
            lastError: null,
            created: '2026-01-01T00:00:00Z',
            updated: '2026-01-01T00:00:00Z',
          ),
          null,
        ),
        throwsA(
          isA<PublisherCliException>().having(
            (error) => error.message,
            'message',
            contains('did not resolve a release mint address'),
          ),
        ),
      );
    });
  });

  group('waitForIngestionSessionReady', () {
    test('returns when the session is ready', () async {
      final client = _FakeClient();
      final session = await waitForIngestionSessionReady(
        client,
        'ing-1',
        const PublicationWorkflowOptions(pollInterval: Duration.zero),
      );
      expect(session.isReady, isTrue);
    });

    test('times out after max attempts', () async {
      final client = _ProcessingClient();
      await expectLater(
        waitForIngestionSessionReady(
          client,
          'ing-1',
          const PublicationWorkflowOptions(
            pollInterval: Duration.zero,
            maxPollAttempts: 3,
          ),
        ),
        throwsA(
          isA<PublisherCliException>().having(
            (error) => error.message,
            'message',
            contains('Timed out waiting for ingestion session'),
          ),
        ),
      );
    });

    test('throws when ingestion failed', () async {
      final client = _PollingClient();
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
            'bad apk',
          ),
        ),
      );
    });
  });

  group('PublicationWorkflow.startPublication', () {
    test('drives the whole workflow end to end', () async {
      final client = _FakeClient();
      final workflow = PublicationWorkflow(
        client,
        options: const PublicationWorkflowOptions(
          pollInterval: Duration.zero,
        ),
      );
      final result = await workflow.startPublication(
        PublicationWorkflowInput(
          source: const ApkUrlSource(url: 'https://files.example.com/app.apk'),
          whatsNew: 'Bug fixes',
          signer: _DummySigner(),
          attestationClient: fakeBlockData,
        ),
      );
      expect(result.releaseId, 'rel-1');
      expect(client.calls, contains('createIngestionSession'));
      expect(client.calls, contains('submitToStore'));
    });

    test('cleans up failed releases and rethrows', () async {
      final client = _FakeClient()..failOnPrepare = true;
      final workflow = PublicationWorkflow(
        client,
        options: const PublicationWorkflowOptions(pollInterval: Duration.zero),
      );
      await expectLater(
        workflow.startPublication(
          PublicationWorkflowInput(
            source: const ApkUrlSource(
              url: 'https://files.example.com/app.apk',
            ),
            whatsNew: 'Bug fixes',
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
      expect(client.calls, contains('cleanupRelease'));
    });

    test('recovers preserved submissions', () async {
      final client = _FakeClient()
        ..failOnPrepare = true
        ..preserveOnCleanup = true
        ..customError = const _PreservedFailure();
      final workflow = PublicationWorkflow(
        client,
        options: const PublicationWorkflowOptions(pollInterval: Duration.zero),
      );
      final result = await workflow.startPublication(
        PublicationWorkflowInput(
          source: const ApkUrlSource(url: 'https://files.example.com/app.apk'),
          whatsNew: 'Bug fixes',
          signer: _DummySigner(),
          attestationClient: fakeBlockData,
        ),
      );
      expect(result.releaseId, 'rel-1');
    });

    test('rethrows when no release was created', () async {
      final client = _FailingIngestionClient();
      final workflow = PublicationWorkflow(
        client,
        options: const PublicationWorkflowOptions(pollInterval: Duration.zero),
      );
      await expectLater(
        workflow.startPublication(
          PublicationWorkflowInput(
            source: const ApkUrlSource(
              url: 'https://files.example.com/app.apk',
            ),
            whatsNew: 'Bug fixes',
            signer: _DummySigner(),
            attestationClient: fakeBlockData,
          ),
        ),
        throwsA(
          isA<PublisherCliException>().having(
            (error) => error.message,
            'message',
            contains('ingestion down'),
          ),
        ),
      );
      expect(client.calls, isNot(contains('cleanupRelease')));
    });

    test('reports cleanup failures alongside the original error', () async {
      final client = _CleanupFailureClient();
      final workflow = PublicationWorkflow(
        client,
        options: const PublicationWorkflowOptions(pollInterval: Duration.zero),
      );
      await expectLater(
        workflow.startPublication(
          PublicationWorkflowInput(
            source: const ApkUrlSource(
              url: 'https://files.example.com/app.apk',
            ),
            whatsNew: 'Bug fixes',
            signer: _DummySigner(),
            attestationClient: fakeBlockData,
          ),
        ),
        throwsA(
          isA<PublisherCliException>().having(
            (error) => error.message,
            'message',
            contains('Cleanup also failed for release'),
          ),
        ),
      );
    });
  });

  group('PublicationWorkflow.resumePublication', () {
    test('requires a session or release id', () async {
      final workflow = PublicationWorkflow(
        _FakeClient(),
        options: const PublicationWorkflowOptions(pollInterval: Duration.zero),
      );
      await expectLater(
        workflow.resumePublication(
          PublicationResumeInput(
            signer: _DummySigner(),
            attestationClient: fakeBlockData,
          ),
        ),
        throwsA(
          isA<PublisherCliException>().having(
            (error) => error.message,
            'message',
            contains('is required to resume'),
          ),
        ),
      );
    });

    test('resumes by release id', () async {
      final client = _FakeClient();
      final workflow = PublicationWorkflow(
        client,
        options: const PublicationWorkflowOptions(pollInterval: Duration.zero),
      );
      final result = await workflow.resumePublication(
        PublicationResumeInput(
          releaseId: 'rel-1',
          signer: _DummySigner(),
          attestationClient: fakeBlockData,
        ),
      );
      expect(result.releaseId, 'rel-1');
    });

    test('resumes by publication session id', () async {
      final client = _FakeClient();
      final workflow = PublicationWorkflow(
        client,
        options: const PublicationWorkflowOptions(pollInterval: Duration.zero),
      );
      final result = await workflow.resumePublication(
        PublicationResumeInput(
          publicationSessionId: 'pub-1',
          signer: _DummySigner(),
          attestationClient: fakeBlockData,
        ),
      );
      expect(result.releaseId, 'rel-1');
    });
  });
}

final KeyPair otherKeypair = generateKeyPair();

class _OtherSigner implements PublicationSigner {
  @override
  String get address =>
      getAddressFromPublicKey(otherKeypair.publicKey).toString();

  @override
  Future<Transaction> signTransaction(Transaction transaction) async =>
      transaction;

  @override
  Future<Uint8List> signMessage(Uint8List message) async => message;
}

class _RecordingUploadClient implements http.Client {
  final requests = <http.BaseRequest>[];

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    requests.add(request);
    return http.StreamedResponse(
      const Stream<List<int>>.empty(),
      200,
    );
  }

  @override
  Future<http.Response> put(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    final request = http.Request('PUT', url)
      ..headers.addAll(headers ?? const {})
      ..bodyBytes = body! as List<int>;
    await send(request);
    return http.Response('', 200);
  }

  @override
  void close() {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _PreservedFailure implements Exception {
  const _PreservedFailure();

  @override
  String toString() => 'preserved';
}

class _ProcessingClient extends _FakeClient {
  int polls = 0;

  @override
  Future<PublicationIngestionSession> getIngestionSession({
    required String sessionId,
  }) async {
    polls++;
    return translateBackendIngestionSession({
      'id': 'ing-1',
      'status': 'processing',
      'processingProgress': polls * 10,
    });
  }
}

class _PollingClient extends _FakeClient {
  _PollingClient() : failWith = 'bad apk';

  final String failWith;

  int polls = 0;

  @override
  Future<PublicationIngestionSession> getIngestionSession({
    required String sessionId,
  }) async {
    polls++;
    return translateBackendIngestionSession({
      'id': 'ing-1',
      'status': polls < 3 ? 'processing' : 'Failed',
      'error': failWith,
    });
  }
}

class _FailingIngestionClient extends _FakeClient {
  @override
  Future<PublicationIngestionSession> createIngestionSession(
    CreateIngestionSessionInput input,
  ) async {
    calls.add('createIngestionSession');
    return translateBackendIngestionSession({
      'id': 'ing-9',
      'status': 'Ready',
    });
  }

  @override
  Future<PublicationIngestionSession> getIngestionSession({
    required String sessionId,
  }) async {
    calls.add('getIngestionSession');
    throw const _TestFailure('ingestion down');
  }
}

class _CleanupFailureClient extends _FakeClient {
  @override
  Future<PortalUploadTarget> createUploadTarget(
    CreateUploadTargetInput input,
  ) async {
    calls.add('createUploadTarget');
    return const PortalUploadTarget(
      uploadUrl: 'https://upload.example.com',
      publicUrl: 'https://public.example.com/app.apk',
    );
  }

  @override
  Future<PublicationIngestionSession> createIngestionSession(
    CreateIngestionSessionInput input,
  ) async {
    calls.add('createIngestionSession');
    return translateBackendIngestionSession({
      'id': 'ing-1',
      'status': 'Ready',
      'releaseId': 'rel-1',
      'publicationSessionId': 'pub-1',
      'bundle': completeBackendBundle(),
      'publicationSession': {'id': 'pub-1'},
    });
  }

  @override
  Future<PreparedReleaseTransaction> prepareReleaseNftTransaction(
    PrepareReleaseNftTransactionInput input,
  ) async {
    calls.add('prepareReleaseNftTransaction');
    throw const _TestFailure('prepare failed');
  }

  @override
  Future<CleanupReleaseResult> cleanupRelease(CleanupReleaseInput input) async {
    calls.add('cleanupRelease');
    throw const _TestFailure('cleanup down');
  }
}
