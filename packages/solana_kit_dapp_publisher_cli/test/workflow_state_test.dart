import 'package:solana_kit_dapp_publisher_cli/src/errors.dart';
import 'package:solana_kit_dapp_publisher_cli/src/portal_types.dart';
import 'package:solana_kit_dapp_publisher_cli/src/publication_models.dart';
import 'package:solana_kit_dapp_publisher_cli/src/workflow_state.dart';
import 'package:test/test.dart';

const sampleBundle = PublicationBundle(
  ingestionSessionId: 'ing-1',
  publicationSessionId: 'pub-1',
  releaseId: 'rel-1',
  dapp: DappInfo(
    id: 'dapp-1',
    dappName: 'My App',
    subtitle: 'Short',
    description: 'Long',
    androidPackage: 'com.example.app',
    dappIconUrl: 'https://img.example.com/icon.png',
    dappPreviewUrls: [],
    bannerUrl: null,
    featureGraphicUrl: null,
    editorsChoiceGraphicUrl: null,
    appWebsite: 'https://app.example.com',
    contactEmail: 'contact@example.com',
    supportEmail: 'support@example.com',
    languages: ['en-US'],
    licenseUrl: 'https://example.com/license',
    copyrightUrl: null,
    privacyPolicyUrl: 'https://example.com/privacy',
    walletAddress: 'Wa11et1111111111111111111111111111111111111',
    nftMintAddress: 'App111111111111111111111111111111111111111',
    lastApprovedReleaseId: null,
    website: 'https://app.example.com',
  ),
  publisher: PublisherInfo(
    id: 'pub-1',
    type: 'organization',
    name: 'Example Inc',
    website: 'https://example.com',
    email: 'contact@example.com',
    supportEmail: 'support@example.com',
  ),
  installFile: InstallFileDetails(
    uri: 'https://files.example.com/app.apk',
    mimeType: 'application/vnd.android.package-archive',
    size: 2048,
    sha256: 'deadbeef',
    fileName: 'app.apk',
    canonicalUrl: 'https://files.example.com/app.apk',
    url: 'https://files.example.com/app.apk',
    origin: PortalSourceKind.portalUpload,
  ),
  metadata: BundleMetadata(
    localizedName: 'My App',
    shortDescription: 'Short',
    longDescription: 'Long',
    newInVersion: 'Faster',
    publisherWebsite: 'https://example.com',
    supportEmail: 'support@example.com',
    website: 'https://app.example.com',
    locales: ['en-US'],
    legal: BundleLegal(
      licenseUrl: 'https://example.com/license',
      copyrightUrl: 'https://example.com/copyright',
      privacyPolicyUrl: 'https://example.com/privacy',
    ),
    media: [],
    installFile: InstallFileDetails(
      uri: 'https://files.example.com/app.apk',
      mimeType: 'application/vnd.android.package-archive',
      size: 2048,
      sha256: 'deadbeef',
      fileName: 'app.apk',
      canonicalUrl: 'https://files.example.com/app.apk',
      url: 'https://files.example.com/app.apk',
      origin: PortalSourceKind.portalUpload,
    ),
    localizedStrings: [],
    releaseMetadataUri: 'https://meta.example.com/rel-1.json',
  ),
  signerAuthority: SignerAuthority(
    dappWalletAddress: 'Wa11et1111111111111111111111111111111111111',
    collectionAuthority: 'Co111ection11111111111111111111111111111111',
    appMintAddress: 'App111111111111111111111111111111111111111',
    sameSignerRequired: true,
    acceptedSignerRoles: ['publisher', 'payer'],
    dappId: 'dapp-1',
    requiredSigner: 'Wa11et1111111111111111111111111111111111111',
    mintSigner: 'Wa11et1111111111111111111111111111111111111',
    feePayer: 'Payer111111111111111111111111111111111111111',
  ),
  release: ReleaseInfo(
    id: 'rel-1',
    dappId: 'dapp-1',
    releaseFileUrl: 'https://files.example.com/app.apk',
    releaseFileName: 'app.apk',
    releaseFileSize: 2048,
    releaseFileHash: 'abc123',
    releaseName: 'My App',
    versionName: '1.2.0',
    versionCode: 120,
    androidPackage: 'com.example.app',
    minSdkVersion: 21,
    targetSdkVersion: 34,
    permissions: [],
    locales: ['en-US'],
    certificateFingerprint: 'AA:BB',
    shortDescription: null,
    longDescription: null,
    localizedName: 'My App',
    newInVersion: 'Faster',
    sagaFeatures: null,
    releaseMintAddress: 'Mint111111111111111111111111111111111111111',
    releaseMetadataUri: 'https://meta.example.com/rel-1.json',
    nftMintAddress: 'Mint111111111111111111111111111111111111111',
    nftMetadataUri: 'https://meta.example.com/rel-1.json',
  ),
);

PublicationSession sampleSession() => normalizePublicationSession(
  const PublicationSession(
    id: 'pub-1',
    ingestionSessionId: 'ing-1',
    releaseId: 'rel-1',
    status: PublicationSessionStatus.running,
    stage: PublicationSessionStage.preparedForMint,
    checkpoint: PublicationCheckpoint.bundleReady,
    metadataUri: null,
    releaseMintAddress: null,
    mintTransactionSignature: null,
    verifyTransactionSignature: null,
    attestationRequestUniqueId: null,
    hubspotTicketId: null,
    error: null,
    lastError: null,
    created: '2026-01-01T00:00:00Z',
    updated: '2026-01-01T00:00:00Z',
  ),
);

void main() {
  group('checkpointAtLeast', () {
    test('orders checkpoints', () {
      expect(
        checkpointAtLeast(
          PublicationCheckpoint.created,
          PublicationCheckpoint.mintSubmitted,
        ),
        isFalse,
      );
      expect(
        checkpointAtLeast(
          PublicationCheckpoint.submitted,
          PublicationCheckpoint.bundleReady,
        ),
        isTrue,
      );
      expect(
        checkpointAtLeast(
          PublicationCheckpoint.completed,
          PublicationCheckpoint.completed,
        ),
        isTrue,
      );
    });
  });

  group('normalizePublicationBundle', () {
    test('falls back the release id from the nested release', () {
      final nested = sampleBundle.release;
      final normalized = normalizePublicationBundle(
        PublicationBundle(
          ingestionSessionId: sampleBundle.ingestionSessionId,
          publicationSessionId: sampleBundle.publicationSessionId,
          releaseId: '',
          dapp: sampleBundle.dapp,
          publisher: sampleBundle.publisher,
          installFile: sampleBundle.installFile,
          metadata: sampleBundle.metadata,
          signerAuthority: sampleBundle.signerAuthority,
          release: nested,
        ),
      );
      expect(normalized.releaseId, 'rel-1');
    });

    test('keeps metadata intact', () {
      final normalized = normalizePublicationBundle(sampleBundle);
      expect(normalized.metadata.localizedName, 'My App');
      expect(
        normalized.metadata.releaseMetadataUri,
        'https://meta.example.com/rel-1.json',
      );
    });
  });

  group('withPublicationBundleIdentifiers', () {
    test('overrides missing identifiers', () {
      final updated = withPublicationBundleIdentifiers(
        sampleBundle,
        releaseId: 'rel-2',
        publicationSessionId: 'pub-2',
        ingestionSessionId: 'ing-2',
      );
      expect(updated.releaseId, 'rel-1');
      expect(updated.publicationSessionId, 'pub-1');
      expect(updated.ingestionSessionId, 'ing-1');
    });

    test('fills empty identifiers', () {
      final empty = PublicationBundle(
        ingestionSessionId: '',
        publicationSessionId: '',
        releaseId: '',
        dapp: sampleBundle.dapp,
        publisher: sampleBundle.publisher,
        installFile: sampleBundle.installFile,
        metadata: sampleBundle.metadata,
        signerAuthority: sampleBundle.signerAuthority,
        release: sampleBundle.release,
      );
      final updated = withPublicationBundleIdentifiers(
        empty,
        releaseId: 'rel-9',
        publicationSessionId: 'pub-9',
        ingestionSessionId: 'ing-9',
      );
      expect(updated.releaseId, 'rel-1');
      expect(updated.publicationSessionId, 'pub-9');
      expect(updated.ingestionSessionId, 'ing-9');
    });
  });

  group('release metadata uri resolution', () {
    test('prefers the session metadata uri', () {
      final session = sampleSession();
      expect(
        resolveReleaseMetadataUri(sampleBundle, session),
        'https://meta.example.com/rel-1.json',
      );
    });

    test('falls back to the bundle metadata uri', () {
      final bundleWithoutReleaseUri = PublicationBundle(
        ingestionSessionId: sampleBundle.ingestionSessionId,
        publicationSessionId: sampleBundle.publicationSessionId,
        releaseId: sampleBundle.releaseId,
        dapp: sampleBundle.dapp,
        publisher: sampleBundle.publisher,
        installFile: sampleBundle.installFile,
        metadata: sampleBundle.metadata,
        signerAuthority: sampleBundle.signerAuthority,
        release: sampleBundle.release,
      );
      const session = PublicationSession(
        id: 'pub-1',
        ingestionSessionId: 'ing-1',
        releaseId: 'rel-1',
        status: PublicationSessionStatus.running,
        stage: PublicationSessionStage.preparedForMint,
        checkpoint: PublicationCheckpoint.bundleReady,
        metadataUri: 'https://session.example.com/meta.json',
        releaseMintAddress: null,
        mintTransactionSignature: null,
        verifyTransactionSignature: null,
        attestationRequestUniqueId: null,
        hubspotTicketId: null,
        error: null,
        lastError: null,
        created: '2026-01-01T00:00:00Z',
        updated: '2026-01-01T00:00:00Z',
      );
      expect(
        resolveReleaseMetadataUri(bundleWithoutReleaseUri, session),
        'https://session.example.com/meta.json',
      );
      expect(
        hasResolvableReleaseMetadataUri(bundleWithoutReleaseUri, null),
        isTrue,
      );
    });

    test('throws when the uri cannot be resolved', () {
      final emptyBundle = PublicationBundle(
        ingestionSessionId: sampleBundle.ingestionSessionId,
        publicationSessionId: sampleBundle.publicationSessionId,
        releaseId: sampleBundle.releaseId,
        dapp: sampleBundle.dapp,
        publisher: sampleBundle.publisher,
        installFile: sampleBundle.installFile,
        metadata: const BundleMetadata(
          localizedName: 'My App',
          shortDescription: 'Short',
          longDescription: 'Long',
          newInVersion: 'Faster',
          publisherWebsite: null,
          supportEmail: null,
          website: null,
          locales: [],
          legal: BundleLegal(
            licenseUrl: null,
            copyrightUrl: null,
            privacyPolicyUrl: null,
          ),
          media: [],
          installFile: InstallFileDetails(
            uri: 'https://files.example.com/app.apk',
            mimeType: 'application/vnd.android.package-archive',
            size: 2048,
            sha256: 'deadbeef',
            fileName: 'app.apk',
            canonicalUrl: 'https://files.example.com/app.apk',
            url: 'https://files.example.com/app.apk',
            origin: PortalSourceKind.portalUpload,
          ),
          localizedStrings: [],
          releaseMetadataUri: null,
        ),
        signerAuthority: sampleBundle.signerAuthority,
        release: const ReleaseInfo(
          id: 'rel-1',
          dappId: 'dapp-1',
          releaseFileUrl: null,
          releaseFileName: 'app.apk',
          releaseFileSize: 2048,
          releaseFileHash: null,
          releaseName: 'My App',
          versionName: '1.2.0',
          versionCode: 120,
          androidPackage: 'com.example.app',
          minSdkVersion: null,
          targetSdkVersion: null,
          permissions: [],
          locales: [],
          certificateFingerprint: null,
          shortDescription: null,
          longDescription: null,
          localizedName: 'My App',
          newInVersion: 'Faster',
          sagaFeatures: null,
          releaseMintAddress: null,
          releaseMetadataUri: null,
          nftMintAddress: null,
          nftMetadataUri: null,
        ),
      );
      expect(
        () => resolveReleaseMetadataUri(emptyBundle, null),
        throwsA(isA<PublisherCliException>()),
      );
      expect(
        hasResolvableReleaseMetadataUri(emptyBundle, null),
        isFalse,
      );
    });
  });

  group('resolvers', () {
    test('resolves signer, fee payer, and display names', () {
      expect(
        resolvePublicationSignerAddress(sampleBundle),
        'Wa11et1111111111111111111111111111111111111',
      );
      expect(
        resolvePublicationFeePayer(
          sampleBundle,
          'Wa11et1111111111111111111111111111111111111',
        ),
        'Payer111111111111111111111111111111111111111',
      );
      expect(resolveReleaseDisplayName(sampleBundle), 'My App');
      expect(
        resolveReleaseMintAddress(sampleBundle, sampleSession()),
        'Mint111111111111111111111111111111111111111',
      );
    });

    test('falls back the fee payer to the signer', () {
      const noFeePayer = sampleBundle;
      expect(
        resolvePublicationFeePayer(
          PublicationBundle(
            ingestionSessionId: noFeePayer.ingestionSessionId,
            publicationSessionId: noFeePayer.publicationSessionId,
            releaseId: noFeePayer.releaseId,
            dapp: noFeePayer.dapp,
            publisher: noFeePayer.publisher,
            installFile: noFeePayer.installFile,
            metadata: noFeePayer.metadata,
            signerAuthority: const SignerAuthority(
              dappWalletAddress: 'Wa11et1111111111111111111111111111111111111',
              collectionAuthority:
                  'Co111ection11111111111111111111111111111111',
              appMintAddress: 'App111111111111111111111111111111111111111',
              sameSignerRequired: true,
              acceptedSignerRoles: ['publisher', 'payer'],
              dappId: 'dapp-1',
              requiredSigner: 'Wa11et1111111111111111111111111111111111111',
              mintSigner: 'Wa11et1111111111111111111111111111111111111',
              feePayer: null,
            ),
            release: noFeePayer.release,
          ),
          'Signer111111111111111111111111111111111111111',
        ),
        'Signer111111111111111111111111111111111111111',
      );
    });
  });

  group('validatePublicationBundle', () {
    test('passes for a complete bundle', () {
      expect(() => validatePublicationBundle(sampleBundle), returnsNormally);
    });

    test('reports missing fields', () {
      final incomplete = PublicationBundle(
        ingestionSessionId: '',
        publicationSessionId: '',
        releaseId: '',
        dapp: sampleBundle.dapp,
        publisher: sampleBundle.publisher,
        installFile: const InstallFileDetails(
          uri: '',
          mimeType: '',
          size: 0,
          sha256: null,
          fileName: null,
          canonicalUrl: '',
          url: '',
          origin: PortalSourceKind.portalUpload,
        ),
        metadata: const BundleMetadata(
          localizedName: '',
          shortDescription: '',
          longDescription: '',
          newInVersion: '',
          publisherWebsite: null,
          supportEmail: null,
          website: null,
          locales: [],
          legal: BundleLegal(
            licenseUrl: null,
            copyrightUrl: null,
            privacyPolicyUrl: null,
          ),
          media: [],
          installFile: InstallFileDetails(
            uri: '',
            mimeType: '',
            size: 0,
            sha256: null,
            fileName: null,
            canonicalUrl: '',
            url: '',
            origin: PortalSourceKind.portalUpload,
          ),
          localizedStrings: [],
          releaseMetadataUri: null,
        ),
        signerAuthority: sampleBundle.signerAuthority,
        release: const ReleaseInfo(
          id: '',
          dappId: '',
          releaseFileUrl: null,
          releaseFileName: '',
          releaseFileSize: 0,
          releaseFileHash: null,
          releaseName: '',
          versionName: '',
          versionCode: 0,
          androidPackage: '',
          minSdkVersion: null,
          targetSdkVersion: null,
          permissions: [],
          locales: [],
          certificateFingerprint: null,
          shortDescription: null,
          longDescription: null,
          localizedName: '',
          newInVersion: '',
          sagaFeatures: null,
          releaseMintAddress: null,
          releaseMetadataUri: null,
          nftMintAddress: null,
          nftMetadataUri: null,
        ),
      );

      try {
        validatePublicationBundle(incomplete);
        fail('expected a throw');
      } on PublisherCliException catch (error) {
        expect(error.message, contains('releaseId'));
        expect(error.message, contains('publicationSessionId'));
        expect(error.message, contains('ingestionSessionId'));
        expect(error.message, contains('androidPackage'));
        expect(error.message, contains('versionName'));
        expect(error.message, contains('metadata.localizedName'));
        expect(error.message, contains('installFile.mimeType'));
      }
    });
  });

  group('stage mapping', () {
    test('publicationStageToCheckpoint maps stages', () {
      expect(
        publicationStageToCheckpoint(null),
        PublicationCheckpoint.created,
      );
      expect(
        publicationStageToCheckpoint(PublicationSessionStage.preparedForMint),
        PublicationCheckpoint.bundleReady,
      );
      expect(
        publicationStageToCheckpoint(PublicationSessionStage.failed),
        PublicationCheckpoint.created,
      );
      expect(
        publicationStageToCheckpoint(PublicationSessionStage.submitted),
        PublicationCheckpoint.submitted,
      );
    });

    test('publicationStageToStatus maps stages', () {
      expect(publicationStageToStatus(null), PublicationSessionStatus.pending);
      expect(
        publicationStageToStatus(PublicationSessionStage.submitted),
        PublicationSessionStatus.completed,
      );
      expect(
        publicationStageToStatus(PublicationSessionStage.failed),
        PublicationSessionStatus.failed,
      );
      expect(
        publicationStageToStatus(PublicationSessionStage.preparedForMint),
        PublicationSessionStatus.pending,
      );
      expect(
        publicationStageToStatus(PublicationSessionStage.mintSubmitted),
        PublicationSessionStatus.running,
      );
    });

    test('resolvePublicationSessionStage derives from raw fields', () {
      expect(
        resolvePublicationSessionStage(
          const PublicationSession(
            id: 'p',
            ingestionSessionId: 'i',
            releaseId: 'r',
            status: PublicationSessionStatus.failed,
            stage: PublicationSessionStage.preparedForMint,
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
        ),
        PublicationSessionStage.failed,
      );
      expect(
        resolvePublicationSessionStage(
          const PublicationSession(
            id: 'p',
            ingestionSessionId: 'i',
            releaseId: 'r',
            status: PublicationSessionStatus.completed,
            stage: PublicationSessionStage.preparedForMint,
            checkpoint: PublicationCheckpoint.submitted,
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
        ),
        PublicationSessionStage.submitted,
      );
    });

    test('checkpoint fromWire and wire round-trip', () {
      for (final checkpoint in PublicationCheckpoint.values) {
        expect(
          PublicationCheckpoint.fromWire(checkpoint.wire),
          checkpoint,
        );
      }
      expect(
        PublicationCheckpoint.fromWire('unknown'),
        PublicationCheckpoint.created,
      );
    });

    test('SessionStatus.fromWire maps unknown values to running', () {
      expect(
        PublicationSessionStatus.fromWire('unknown'),
        PublicationSessionStatus.running,
      );
      expect(
        PublicationSessionStatus.fromWire('pending'),
        PublicationSessionStatus.pending,
      );
      expect(
        PublicationSessionStatus.fromWire('completed'),
        PublicationSessionStatus.completed,
      );
    });
  });
}

final bundleWithoutReleaseUri = PublicationBundle(
  ingestionSessionId: 'ing-1',
  publicationSessionId: 'pub-1',
  releaseId: 'rel-1',
  dapp: sampleBundle.dapp,
  publisher: sampleBundle.publisher,
  installFile: sampleBundle.installFile,
  metadata: sampleBundle.metadata,
  signerAuthority: sampleBundle.signerAuthority,
  release: const ReleaseInfo(
    id: 'rel-1',
    dappId: 'dapp-1',
    releaseFileUrl: 'https://files.example.com/app.apk',
    releaseFileName: 'app.apk',
    releaseFileSize: 2048,
    releaseFileHash: 'abc123',
    releaseName: 'My App',
    versionName: '1.2.0',
    versionCode: 120,
    androidPackage: 'com.example.app',
    minSdkVersion: 21,
    targetSdkVersion: 34,
    permissions: [],
    locales: ['en-US'],
    certificateFingerprint: 'AA:BB',
    shortDescription: null,
    longDescription: null,
    localizedName: 'My App',
    newInVersion: 'Faster',
    sagaFeatures: null,
    releaseMintAddress: null,
    releaseMetadataUri: null,
    nftMintAddress: null,
    nftMetadataUri: null,
  ),
);
