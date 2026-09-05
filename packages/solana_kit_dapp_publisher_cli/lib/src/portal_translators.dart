import 'package:solana_kit_dapp_publisher_cli/src/files.dart';
import 'package:solana_kit_dapp_publisher_cli/src/portal_types.dart';
import 'package:solana_kit_dapp_publisher_cli/src/publication_models.dart';

/// Infers the portal source kind from a backend `sourceKind` value.
PortalSourceKind inferPublicationSourceKind(String? sourceKind) =>
    sourceKind == 'externalUrl'
    ? PortalSourceKind.externalUrl
    : PortalSourceKind.portalUpload;

/// Translates a backend publication session payload.
PublicationSession translateBackendPublicationSession(
  Map<String, Object?> backendSession,
) {
  final stage = optionalString(backendSession['stage']) ?? 'PreparedForMint';
  final hubspotTicketId = optionalString(backendSession['hubspotTicketId']);
  final mintTransactionSignature = optionalString(
    backendSession['mintTransactionSignature'],
  );
  final verificationTransactionSignature = optionalString(
    backendSession['verificationTransactionSignature'],
  );
  final attestationRequestUniqueId = optionalString(
    backendSession['attestationRequestUniqueId'],
  );
  final expectedMintAddress = optionalString(
    backendSession['expectedMintAddress'],
  );
  final metadataUri = optionalString(backendSession['metadataUri']);

  return PublicationSession(
    id: asString(backendSession['id']),
    ingestionSessionId: asString(backendSession['ingestionSessionId']),
    releaseId: asString(backendSession['releaseId']),
    status: normalizePublicationStatus(
      stage: stage,
      hubspotTicketId: hubspotTicketId,
    ),
    stage: PublicationSessionStage.fromWire(stage),
    checkpoint: normalizePublicationCheckpoint(
      stage: stage,
      mintTransactionSignature: mintTransactionSignature,
      verificationTransactionSignature: verificationTransactionSignature,
      attestationRequestUniqueId: attestationRequestUniqueId,
      hubspotTicketId: hubspotTicketId,
      expectedMintAddress: expectedMintAddress,
      metadataUri: metadataUri,
    ),
    metadataUri: metadataUri,
    releaseMintAddress: expectedMintAddress,
    mintTransactionSignature: mintTransactionSignature,
    verifyTransactionSignature: verificationTransactionSignature,
    attestationRequestUniqueId: attestationRequestUniqueId,
    hubspotTicketId: hubspotTicketId,
    error: optionalString(backendSession['lastError']),
    lastError: optionalString(backendSession['lastError']),
    created: optionalString(backendSession['created']) ?? nowIso8601(),
    updated: optionalString(backendSession['updated']) ?? nowIso8601(),
  );
}

/// Translates a backend ingestion session together with its bundle and
/// publication session payloads.
PublicationIngestionSession translateBackendIngestionSession(
  Map<String, Object?> backendSession, {
  Map<String, Object?>? bundle,
  Map<String, Object?>? publicationSession,
}) {
  final sourceKind =
      optionalString(backendSession['sourceKind']) ?? 'portalUpload';
  final translatedPublicationSession = publicationSession == null
      ? null
      : translateBackendPublicationSession(publicationSession);
  final translatedBundle = bundle == null
      ? null
      : _withSessionIdentifiers(
          mapBackendBundleToPublicationBundle(
            bundle,
            optionalString(publicationSession?['metadataUri']) ??
                optionalString(
                  asRecord(bundle['release'])['nftMetadataUri'],
                ) ??
                '',
            inferPublicationSourceKind(sourceKind),
          ),
          backendSession,
          translatedPublicationSession,
        );

  return PublicationIngestionSession(
    id: asString(backendSession['id']),
    dappId: asString(backendSession['dappId']),
    idempotencyKey: asString(backendSession['idempotencyKey']),
    source: _translateIngestionSource(
      backendSession,
      sourceKind,
      sourceKind == 'existingRelease'
          ? translatedBundle?.releaseId ?? asString(backendSession['releaseId'])
          : null,
    ),
    whatsNew: asString(backendSession['whatsNew']),
    status: optionalString(backendSession['status']) ?? sourceKind,
    releaseId: optionalString(backendSession['releaseId']),
    publicationSessionId: optionalString(
      backendSession['publicationSessionId'],
    ),
    bundle: translatedBundle,
    publicationSession: translatedPublicationSession,
    androidPackage: optionalString(backendSession['androidPackage']),
    versionName: optionalString(backendSession['versionName']),
    processingProgress: _optionalNumber(backendSession['processingProgress']),
    processingStage: optionalString(backendSession['processingStage']),
    processingDetail: optionalString(backendSession['processingDetail']),
    processingError: optionalString(backendSession['processingError']),
    error: optionalString(backendSession['error']),
  );
}

PublicationSource _translateIngestionSource(
  Map<String, Object?> backendSession,
  String sourceKind,
  String? existingReleaseId,
) {
  final sourceUrl = optionalString(backendSession['sourceUrl']) ?? '';
  final fileName =
      optionalString(backendSession['releaseFileName']) ??
      inferFileNameFromUrl(sourceUrl);
  if (sourceKind == 'existingRelease') {
    return ExistingReleaseSource(
      sourceReleaseId:
          existingReleaseId ?? asString(backendSession['releaseId']),
    );
  }
  if (sourceKind == 'externalUrl') {
    return ApkUrlSource(url: sourceUrl, fileName: fileName);
  }
  return PortalUploadSource(
    releaseFileUrl: sourceUrl,
    releaseFileName: fileName ?? '',
    releaseFileSize: _optionalNumber(backendSession['releaseFileSize']) ?? 0,
  );
}

/// Translates a backend publication bundle into the normalized shape.
PublicationBundle mapBackendBundleToPublicationBundle(
  Map<String, Object?> backendBundle,
  String releaseMetadataUri,
  PortalSourceKind sourceKind,
) {
  final release = asRecord(backendBundle['release']);
  final dapp = asRecord(backendBundle['dapp']);
  final publisher = asRecord(backendBundle['publisher']);
  final installFile = asRecord(backendBundle['installFile']);
  final signerAuthority = asRecord(backendBundle['signerAuthority']);
  final installFileDetails = InstallFileDetails.fromBackend(
    release,
    installFile,
    sourceKind,
  );

  final releaseName =
      optionalString(release['localizedName']) ??
      optionalString(dapp['dappName']) ??
      'Release update';
  final shortDescription =
      optionalString(release['shortDescription']) ??
      optionalString(dapp['subtitle']) ??
      asString(dapp['description']).substringSafe(0, 50);
  final localizedShortDescription =
      optionalString(release['shortDescription']) ??
      asString(dapp['description']).substringSafe(0, 50);
  final longDescription =
      optionalString(release['longDescription']) ??
      asString(dapp['description']);
  final newInVersion = optionalString(release['newInVersion']) ?? '';
  final dappName = optionalString(dapp['dappName']) ?? releaseName;
  final publisherType = optionalString(publisher['type']) == 'individual'
      ? 'individual'
      : 'organization';

  return PublicationBundle(
    ingestionSessionId: asString(backendBundle['ingestionSessionId']),
    publicationSessionId: asString(backendBundle['publicationSessionId']),
    releaseId: asString(
      optionalString(backendBundle['releaseId']) ?? release['id'],
    ),
    dapp: DappInfo(
      id: asString(dapp['id']),
      dappName: dappName,
      subtitle: optionalString(dapp['subtitle']),
      description: asString(dapp['description']),
      androidPackage: asString(
        optionalString(dapp['androidPackage']) ?? release['androidPackage'],
      ),
      dappIconUrl: optionalString(dapp['dappIconUrl']),
      dappPreviewUrls: stringArray(dapp['dappPreviewUrls']),
      bannerUrl: optionalString(dapp['bannerUrl']),
      featureGraphicUrl: optionalString(dapp['featureGraphicUrl']),
      editorsChoiceGraphicUrl: optionalString(dapp['editorsChoiceGraphicUrl']),
      appWebsite: optionalString(dapp['appWebsite']),
      contactEmail: optionalString(dapp['contactEmail']),
      supportEmail: asString(
        optionalString(dapp['supportEmail']) ?? publisher['supportEmail'],
      ),
      languages: stringArray(dapp['languages']),
      licenseUrl: optionalString(dapp['licenseUrl']),
      copyrightUrl: optionalString(dapp['copyrightUrl']),
      privacyPolicyUrl: optionalString(dapp['privacyPolicyUrl']),
      walletAddress: asString(dapp['walletAddress']),
      nftMintAddress: asString(dapp['nftMintAddress']),
      lastApprovedReleaseId: optionalString(dapp['lastApprovedReleaseId']),
      website: optionalString(dapp['website'] ?? dapp['appWebsite']),
    ),
    publisher: PublisherInfo(
      id: asString(publisher['id']),
      type: publisherType,
      name: asString(publisher['name']),
      website: asString(publisher['website']),
      email: asString(publisher['email']),
      supportEmail: asString(
        optionalString(publisher['supportEmail']) ??
            dapp['supportEmail'] ??
            publisher['email'],
      ),
    ),
    installFile: installFileDetails,
    metadata: BundleMetadata(
      localizedName: releaseName,
      shortDescription: shortDescription,
      longDescription: longDescription,
      newInVersion: newInVersion,
      publisherWebsite: optionalString(publisher['website']),
      supportEmail: optionalString(publisher['supportEmail']),
      website: optionalString(dapp['appWebsite']),
      locales: stringArray(dapp['languages']),
      legal: BundleLegal(
        licenseUrl: optionalString(dapp['licenseUrl']),
        copyrightUrl: optionalString(dapp['copyrightUrl']),
        privacyPolicyUrl: optionalString(dapp['privacyPolicyUrl']),
      ),
      media: [],
      installFile: installFileDetails,
      localizedStrings: [
        LocalizedReleaseStrings(
          locale: 'en-US',
          name: releaseName,
          shortDescription: localizedShortDescription,
          longDescription: longDescription,
          newInVersion: newInVersion,
        ),
      ],
      releaseMetadataUri: _firstNonEmpty(
        releaseMetadataUri,
        optionalString(release['nftMetadataUri']),
      ),
    ),
    signerAuthority: _translateSignerAuthority(signerAuthority, dapp),
    release: ReleaseInfo(
      id: asString(release['id'] ?? backendBundle['releaseId']),
      dappId: asString(release['dappId'] ?? dapp['id']),
      releaseFileUrl:
          optionalString(release['releaseFileUrl']) ?? installFileDetails.url,
      releaseFileName: asString(
        optionalString(release['releaseFileName']) ??
            installFileDetails.fileName,
      ),
      releaseFileSize: numberOrDefault(
        release['releaseFileSize'] ?? installFileDetails.size,
        installFileDetails.size,
      ),
      releaseFileHash:
          optionalString(release['releaseFileHash']) ??
          installFileDetails.sha256,
      releaseName: releaseName,
      versionName:
          optionalString(release['versionName']) ??
          asString(release['versionCode'] ?? '1'),
      versionCode: numberOrDefault(release['versionCode'], 1),
      androidPackage: asString(
        optionalString(release['androidPackage']) ?? dapp['androidPackage'],
      ),
      minSdkVersion: _optionalNumber(release['minSdkVersion']),
      targetSdkVersion: _optionalNumber(release['targetSdkVersion']),
      permissions: stringArray(release['permissions']),
      locales: stringArray(release['locales']),
      certificateFingerprint: optionalString(release['certificateFingerprint']),
      shortDescription: optionalString(release['shortDescription']),
      longDescription: optionalString(release['longDescription']),
      localizedName: optionalString(release['localizedName']) ?? releaseName,
      newInVersion: newInVersion,
      sagaFeatures: optionalString(release['sagaFeatures']),
      releaseMintAddress: optionalString(release['nftMintAddress']),
      releaseMetadataUri: _firstNonEmpty(
        releaseMetadataUri,
        optionalString(release['nftMetadataUri']),
      ),
      nftMintAddress: optionalString(release['nftMintAddress']),
      nftMetadataUri: optionalString(release['nftMetadataUri']),
    ),
  );
}

SignerAuthority _translateSignerAuthority(
  Map<String, Object?> signerAuthority,
  Map<String, Object?> dapp,
) {
  final fallbackSigner = asString(
    optionalString(signerAuthority['dappWalletAddress']) ??
        signerAuthority['collectionAuthority'] ??
        dapp['walletAddress'],
  );
  return SignerAuthority(
    dappWalletAddress: fallbackSigner,
    collectionAuthority: asString(
      optionalString(signerAuthority['collectionAuthority']) ??
          signerAuthority['dappWalletAddress'] ??
          dapp['walletAddress'],
    ),
    appMintAddress: asString(
      optionalString(signerAuthority['appMintAddress']) ??
          dapp['nftMintAddress'],
    ),
    sameSignerRequired:
        signerAuthority['sameSignerRequired'] is! bool ||
        signerAuthority['sameSignerRequired']! as bool,
    acceptedSignerRoles: (signerAuthority['acceptedSignerRoles'] is List)
        ? stringArray(signerAuthority['acceptedSignerRoles'])
        : ['publisher', 'payer'],
    dappId: asString(dapp['id']),
    requiredSigner:
        optionalString(signerAuthority['requiredSigner']) ?? fallbackSigner,
    mintSigner: optionalString(signerAuthority['mintSigner']) ?? fallbackSigner,
    feePayer: optionalString(signerAuthority['feePayer']),
  );
}

PublicationBundle _withSessionIdentifiers(
  PublicationBundle bundle,
  Map<String, Object?> backendSession,
  PublicationSession? translatedPublicationSession,
) {
  return PublicationBundle(
    ingestionSessionId: asString(backendSession['id']),
    publicationSessionId:
        optionalString(
          backendSession['publicationSessionId'],
        ) ??
        translatedPublicationSession?.id ??
        '',
    releaseId: optionalString(backendSession['releaseId']) ?? bundle.release.id,
    dapp: bundle.dapp,
    publisher: bundle.publisher,
    installFile: bundle.installFile,
    metadata: bundle.metadata,
    signerAuthority: bundle.signerAuthority,
    release: bundle.release,
  );
}

/// Normalizes a publication checkpoint from the translated session fields.
PublicationCheckpoint normalizePublicationCheckpoint({
  required String? stage,
  String? mintTransactionSignature,
  String? verificationTransactionSignature,
  String? attestationRequestUniqueId,
  String? hubspotTicketId,
  String? expectedMintAddress,
  String? metadataUri,
}) {
  switch (stage) {
    case 'Submitted':
      return PublicationCheckpoint.submitted;
    case 'Attested':
      return PublicationCheckpoint.verified;
    case 'Verified':
    case 'VerificationSubmitted':
      return PublicationCheckpoint.verified;
    case 'MintSaved':
      return PublicationCheckpoint.mintSaved;
    case 'MintSubmitted':
      return PublicationCheckpoint.mintSubmitted;
    case 'PreparedForMint':
      return PublicationCheckpoint.bundleReady;
  }

  if (_firstNonEmpty(hubspotTicketId) != null) {
    return PublicationCheckpoint.submitted;
  }
  if (_firstNonEmpty(attestationRequestUniqueId) != null) {
    return PublicationCheckpoint.verified;
  }
  if (_firstNonEmpty(verificationTransactionSignature) != null) {
    return PublicationCheckpoint.verified;
  }
  if (_firstNonEmpty(mintTransactionSignature) != null) {
    return PublicationCheckpoint.mintSubmitted;
  }
  if (_firstNonEmpty(expectedMintAddress) != null ||
      _firstNonEmpty(metadataUri) != null) {
    return PublicationCheckpoint.bundleReady;
  }
  return PublicationCheckpoint.created;
}

/// Normalizes a publication status from the stage and ticket identifier.
PublicationSessionStatus normalizePublicationStatus({
  required String? stage,
  String? hubspotTicketId,
}) {
  if (stage == 'Failed') {
    return PublicationSessionStatus.failed;
  }
  if (stage == 'Submitted' || _firstNonEmpty(hubspotTicketId) != null) {
    return PublicationSessionStatus.completed;
  }
  return PublicationSessionStatus.running;
}

num? _optionalNumber(Object? value) =>
    value is num && value.isFinite ? value : null;

String? _firstNonEmpty(String? value, [String? other]) =>
    value != null && value.isNotEmpty
    ? value
    : (other != null && other.isNotEmpty ? other : null);

/// The current UTC time as an ISO-8601 string.
String nowIso8601() => DateTime.now().toUtc().toIso8601String();
