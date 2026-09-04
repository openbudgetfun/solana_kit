import 'package:solana_kit_dapp_publisher_cli/src/portal_translators.dart';
import 'package:solana_kit_dapp_publisher_cli/src/portal_types.dart';
import 'package:solana_kit_dapp_publisher_cli/src/publication_models.dart';
import 'package:test/test.dart';

Map<String, Object?> sampleBackendBundle() => {
  'ingestionSessionId': 'ing-1',
  'publicationSessionId': 'pub-1',
  'releaseId': 'rel-1',
  'release': {
    'id': 'rel-1',
    'dappId': 'dapp-1',
    'androidPackage': 'com.example.app',
    'versionName': '1.2.0',
    'versionCode': 120,
    'minSdkVersion': 21,
    'targetSdkVersion': 34,
    'permissions': ['INTERNET'],
    'locales': ['en-US'],
    'certificateFingerprint': 'AA:BB',
    'newInVersion': 'Faster',
    'localizedName': 'My App',
    'releaseFileUrl': 'https://files.example.com/app.apk',
    'releaseFileName': 'app.apk',
    'releaseFileSize': 2048,
    'releaseFileHash': 'abc123',
    'nftMintAddress': '9zM8vL2bFQhR4mkKKB1EJZDP4XcXKXbP7Lz9dH3nV4tQ',
  },
  'dapp': {
    'id': 'dapp-1',
    'dappName': 'My App',
    'subtitle': 'Short',
    'description': 'Long description',
    'androidPackage': 'com.example.app',
    'dappIconUrl': 'https://img.example.com/icon.png',
    'dappPreviewUrls': ['https://img.example.com/1.png'],
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
    'size': 2048,
    'sha256': 'deadbeef',
  },
  'signerAuthority': {
    'dappWalletAddress': 'Wa11et1111111111111111111111111111111111111',
    'collectionAuthority': 'Co111ection11111111111111111111111111111111',
    'appMintAddress': 'App111111111111111111111111111111111111111',
    'sameSignerRequired': true,
    'acceptedSignerRoles': ['publisher', 'payer'],
    'feePayer': 'Payer111111111111111111111111111111111111111',
  },
};

void main() {
  group('mapBackendBundleToPublicationBundle', () {
    test('maps a full backend bundle', () {
      final bundle = mapBackendBundleToPublicationBundle(
        sampleBackendBundle(),
        'https://meta.example.com/rel-1.json',
        PortalSourceKind.portalUpload,
      );

      expect(bundle.ingestionSessionId, 'ing-1');
      expect(bundle.publicationSessionId, 'pub-1');
      expect(bundle.releaseId, 'rel-1');
      expect(bundle.dapp.id, 'dapp-1');
      expect(bundle.dapp.dappName, 'My App');
      expect(bundle.dapp.subtitle, 'Short');
      expect(bundle.dapp.dappIconUrl, 'https://img.example.com/icon.png');
      expect(
        bundle.dapp.dappPreviewUrls,
        ['https://img.example.com/1.png'],
      );
      expect(bundle.publisher.name, 'Example Inc');
      expect(bundle.publisher.type, 'organization');
      expect(bundle.publisher.website, 'https://example.com');
      expect(bundle.installFile.uri, 'https://files.example.com/app.apk');
      expect(bundle.installFile.sha256, 'deadbeef');
      expect(bundle.metadata.localizedName, 'My App');
      expect(bundle.metadata.shortDescription, 'Short');
      expect(bundle.metadata.longDescription, 'Long description');
      expect(bundle.metadata.newInVersion, 'Faster');
      expect(
        bundle.metadata.releaseMetadataUri,
        'https://meta.example.com/rel-1.json',
      );
      expect(bundle.metadata.localizedStrings, hasLength(1));
      expect(
        bundle.signerAuthority.appMintAddress,
        'App111111111111111111111111111111111111111',
      );
      expect(
        bundle.signerAuthority.feePayer,
        'Payer111111111111111111111111111111111111111',
      );
      expect(bundle.release.versionName, '1.2.0');
      expect(bundle.release.versionCode, 120);
      expect(bundle.release.minSdkVersion, 21);
      expect(bundle.release.releaseMintAddress, isNotNull);
      expect(bundle.release.releaseMetadataUri, isNotNull);
    });

    test('handles an empty backend bundle with fallbacks', () {
      final bundle = mapBackendBundleToPublicationBundle(
        const <String, Object?>{},
        '',
        PortalSourceKind.externalUrl,
      );
      expect(bundle.releaseId, '');
      expect(bundle.release.releaseName, 'Release update');
      expect(bundle.release.versionName, '1');
      expect(bundle.release.versionCode, 1);
      expect(bundle.metadata.shortDescription, '');
      expect(bundle.publisher.type, 'organization');
      expect(bundle.signerAuthority.sameSignerRequired, isTrue);
      expect(bundle.signerAuthority.acceptedSignerRoles, [
        'publisher',
        'payer',
      ]);
      expect(bundle.release.nftMintAddress, isNull);
    });

    test('normalizes individual publisher type', () {
      final backend = sampleBackendBundle();
      (backend['publisher']! as Map<String, Object?>)['type'] = 'individual';
      final bundle = mapBackendBundleToPublicationBundle(
        backend,
        '',
        PortalSourceKind.portalUpload,
      );
      expect(bundle.publisher.type, 'individual');
    });
  });

  group('translateBackendPublicationSession', () {
    test('maps stages to checkpoints', () {
      expect(
        translateBackendPublicationSession({'stage': 'Submitted'}).checkpoint,
        PublicationCheckpoint.submitted,
      );
      expect(
        translateBackendPublicationSession({'stage': 'Attested'}).checkpoint,
        PublicationCheckpoint.verified,
      );
      expect(
        translateBackendPublicationSession({'stage': 'Verified'}).checkpoint,
        PublicationCheckpoint.verified,
      );
      expect(
        translateBackendPublicationSession({'stage': 'MintSaved'}).checkpoint,
        PublicationCheckpoint.mintSaved,
      );
      expect(
        translateBackendPublicationSession({
          'stage': 'MintSubmitted',
        }).checkpoint,
        PublicationCheckpoint.mintSubmitted,
      );
      expect(
        translateBackendPublicationSession({
          'stage': 'PreparedForMint',
        }).checkpoint,
        PublicationCheckpoint.bundleReady,
      );
    });

    test('derives checkpoints from raw fields', () {
      expect(
        translateBackendPublicationSession({
          'stage': 'Failed',
          'hubspotTicketId': 'HS-1',
        }).checkpoint,
        PublicationCheckpoint.submitted,
      );
      expect(
        translateBackendPublicationSession({
          'stage': 'Failed',
          'attestationRequestUniqueId': 'att-1',
        }).checkpoint,
        PublicationCheckpoint.verified,
      );
      expect(
        translateBackendPublicationSession({
          'stage': 'Failed',
          'verificationTransactionSignature': 'sig-1',
        }).checkpoint,
        PublicationCheckpoint.verified,
      );
      expect(
        translateBackendPublicationSession({
          'stage': 'Failed',
          'mintTransactionSignature': 'sig-1',
        }).checkpoint,
        PublicationCheckpoint.mintSubmitted,
      );
      expect(
        translateBackendPublicationSession({
          'stage': 'Failed',
          'expectedMintAddress': 'Mint1111111111111111111111111111111111111',
        }).checkpoint,
        PublicationCheckpoint.bundleReady,
      );
      expect(
        translateBackendPublicationSession({'stage': 'Failed'}).checkpoint,
        PublicationCheckpoint.created,
      );
    });

    test('normalizes status', () {
      expect(
        translateBackendPublicationSession({'stage': 'Failed'}).status,
        PublicationSessionStatus.failed,
      );
      expect(
        translateBackendPublicationSession({'stage': 'Submitted'}).status,
        PublicationSessionStatus.completed,
      );
      expect(
        translateBackendPublicationSession({
          'hubspotTicketId': 'HS-1',
        }).status,
        PublicationSessionStatus.completed,
      );
      expect(
        translateBackendPublicationSession({}).status,
        PublicationSessionStatus.running,
      );
    });

    test('passes through error and identifiers', () {
      final session = translateBackendPublicationSession({
        'id': 'pub-2',
        'ingestionSessionId': 'ing-2',
        'releaseId': 'rel-2',
        'lastError': 'boom',
        'created': '2026-01-01T00:00:00Z',
        'updated': '2026-01-02T00:00:00Z',
      });
      expect(session.id, 'pub-2');
      expect(session.ingestionSessionId, 'ing-2');
      expect(session.releaseId, 'rel-2');
      expect(session.error, 'boom');
      expect(session.created, '2026-01-01T00:00:00Z');
    });
  });

  group('translateBackendIngestionSession', () {
    test('translates ready sessions with bundle and publication session', () {
      final backend = <String, Object?>{
        'id': 'ing-3',
        'dappId': 'dapp-1',
        'idempotencyKey': 'idem-1',
        'whatsNew': 'Bug fixes',
        'status': 'Ready',
        'sourceKind': 'externalUrl',
        'sourceUrl': 'https://files.example.com/app.apk',
        'releaseFileName': 'app.apk',
        'releaseFileSize': 2048,
        'processingProgress': 100,
        'processingStage': 'Done',
        'processingDetail': 'APK processed',
        'androidPackage': 'com.example.app',
        'versionName': '1.2.0',
        'publicationSessionId': 'pub-3',
        'releaseId': 'rel-3',
        'bundle': sampleBackendBundle(),
        'publicationSession': {'id': 'pub-3', 'stage': 'PreparedForMint'},
      };
      final session = translateBackendIngestionSession(
        backend,
        bundle: asRecord(backend['bundle']),
        publicationSession: asRecord(backend['publicationSession']),
      );
      expect(session.isReady, isTrue);
      expect(session.releaseId, 'rel-3');
      expect(session.publicationSessionId, 'pub-3');
      expect(session.publicationSession, isNotNull);
      expect(session.bundle, isNotNull);
      expect(session.bundle!.releaseId, 'rel-3');
      expect(session.androidPackage, 'com.example.app');
      expect(session.versionName, '1.2.0');
      expect(session.processingProgress, 100);
      expect(session.source, isA<ApkUrlSource>());
      expect(
        (session.source as ApkUrlSource).url,
        'https://files.example.com/app.apk',
      );
    });

    test('translates failed sessions', () {
      final session = translateBackendIngestionSession({
        'id': 'ing-4',
        'status': 'Failed',
        'error': 'APK rejected',
        'processingError': 'aapt2 failed',
      });
      expect(session.isFailed, isTrue);
      expect(session.error, 'APK rejected');
    });

    test('translates portal upload and existing release sources', () {
      final portalSession = translateBackendIngestionSession({
        'id': 'ing-5',
        'sourceKind': 'portalUpload',
        'sourceUrl': 'https://portal.example.com/app.apk',
        'releaseFileName': 'app.apk',
        'releaseFileSize': 1024,
        'releaseId': 'rel-5',
      });
      expect(portalSession.source, isA<PortalUploadSource>());

      final existingSession = translateBackendIngestionSession({
        'id': 'ing-6',
        'sourceKind': 'existingRelease',
        'releaseId': 'rel-6',
        'releaseFileName': 'app.apk',
      });
      expect(existingSession.source, isA<ExistingReleaseSource>());
      expect(
        (existingSession.source as ExistingReleaseSource).sourceReleaseId,
        'rel-6',
      );
    });

    test('defaults unknown status fields', () {
      final session = translateBackendIngestionSession({'id': 'ing-7'});
      expect(session.status, 'portalUpload');
      expect(session.isReady, isFalse);
      expect(session.isFailed, isFalse);
      expect(session.bundle, isNull);
      expect(session.publicationSession, isNull);
    });
  });

  group('inferPublicationSourceKind', () {
    test('maps externalUrl to external', () {
      expect(
        inferPublicationSourceKind('externalUrl'),
        PortalSourceKind.externalUrl,
      );
      expect(
        inferPublicationSourceKind('portalUpload'),
        PortalSourceKind.portalUpload,
      );
      expect(inferPublicationSourceKind(null), PortalSourceKind.portalUpload);
    });
  });

  group('helpers', () {
    test('asString coerces values', () {
      expect(asString(null), '');
      expect(asString(false), '');
      expect(asString(0), '');
      expect(asString('text'), 'text');
      expect(asString(42), '42');
      expect(asString(nullString()), '');
    });

    test('optionalString only accepts strings', () {
      expect(optionalString('a'), 'a');
      expect(optionalString(1), isNull);
    });

    test('stringArray filters non-strings', () {
      expect(stringArray(['a', 1, null, 'b']), ['a', 'b']);
      expect(stringArray('nope'), isEmpty);
    });

    test('numberOrDefault handles invalid values', () {
      expect(numberOrDefault(5, 1), 5);
      expect(numberOrDefault('x', 2), 2);
      expect(numberOrDefault(double.nan, 3), 3);
      expect(numberOrDefault(null, 4), 4);
    });

    test('firstString reads dotted paths', () {
      expect(
        firstString(
          {
            'a': {'b': 'v'},
          },
          ['a.b', 'z'],
        ),
        'v',
      );
      expect(firstString({'a': 'x'}, ['z.y', 'a']), 'x');
      expect(firstString({'a': 'x'}, ['z']), isNull);
      expect(
        firstString({'a': 'not-a-map'}, ['a.b']),
        isNull,
      );
    });

    test('readDeep reads nested values', () {
      expect(
        readDeep({
          'a': {'b': 1},
        }, 'a.b'),
        1,
      );
      expect(readDeep({'a': 'x'}, 'a.b.c'), isNull);
      expect(readDeep(<String, Object?>{}, 'a'), isNull);
    });

    test('asRecord and isRecord type checks', () {
      expect(isRecord({'a': 1}), isTrue);
      expect(isRecord('x'), isFalse);
      expect(asRecord('x'), isEmpty);
      expect(asRecord({'a': 1}), {'a': 1});
    });

    test('nowIso8601 produces ISO timestamps', () {
      final value = nowIso8601();
      expect(value, contains('T'));
      expect(DateTime.tryParse(value), isNotNull);
    });
  });
}

String? nullString() => null;
