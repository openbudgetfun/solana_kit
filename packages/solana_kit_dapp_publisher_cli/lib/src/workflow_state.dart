import 'package:solana_kit_dapp_publisher_cli/src/errors.dart';
import 'package:solana_kit_dapp_publisher_cli/src/publication_models.dart';

/// Returns true when [checkpoint] is at or beyond [expected] in the
/// publication lifecycle.
bool checkpointAtLeast(
  PublicationCheckpoint checkpoint,
  PublicationCheckpoint expected,
) => checkpoint.index >= expected.index;

/// Normalizes a publication bundle, filling in missing release identifiers and
/// metadata fallbacks.
PublicationBundle normalizePublicationBundle(PublicationBundle bundle) {
  final releaseId = _firstNonEmpty(bundle.releaseId, bundle.release.id) ?? '';
  final metadata = bundle.metadata;
  final normalizedMetadata = BundleMetadata(
    localizedName: metadata.localizedName,
    shortDescription: metadata.shortDescription,
    longDescription: metadata.longDescription,
    newInVersion: metadata.newInVersion,
    publisherWebsite: metadata.publisherWebsite,
    supportEmail: metadata.supportEmail,
    website: metadata.website,
    locales: metadata.locales,
    legal: metadata.legal,
    media: metadata.media,
    installFile: metadata.installFile,
    localizedStrings: metadata.localizedStrings,
    releaseMetadataUri: metadata.releaseMetadataUri,
  );
  return PublicationBundle(
    ingestionSessionId: bundle.ingestionSessionId,
    publicationSessionId: bundle.publicationSessionId,
    releaseId: releaseId,
    dapp: bundle.dapp,
    publisher: bundle.publisher,
    installFile: bundle.installFile,
    metadata: normalizedMetadata,
    signerAuthority: bundle.signerAuthority,
    release: bundle.release,
  );
}

/// Overrides bundle identifiers with known session identifiers.
PublicationBundle withPublicationBundleIdentifiers(
  PublicationBundle bundle, {
  required String releaseId,
  String? publicationSessionId,
  String? ingestionSessionId,
}) {
  return PublicationBundle(
    ingestionSessionId:
        _firstNonEmpty(
          bundle.ingestionSessionId,
          ingestionSessionId,
        ) ??
        '',
    publicationSessionId:
        _firstNonEmpty(
          bundle.publicationSessionId,
          publicationSessionId,
        ) ??
        '',
    releaseId:
        _firstNonEmpty(
          bundle.releaseId,
          bundle.release.id,
          releaseId,
        ) ??
        '',
    dapp: bundle.dapp,
    publisher: bundle.publisher,
    installFile: bundle.installFile,
    metadata: bundle.metadata,
    signerAuthority: bundle.signerAuthority,
    release: bundle.release,
  );
}

String? _firstNonEmpty(
  String? value, [
  String? other,
  String? third,
  String? fourth,
]) {
  for (final candidate in [value, other, third, fourth]) {
    if (candidate != null && candidate.isNotEmpty) {
      return candidate;
    }
  }
  return null;
}

/// Resolves the release metadata URI from the session or bundle.
String? getReleaseMetadataUri(
  PublicationBundle bundle,
  PublicationSession? session,
) => _firstNonEmpty(
  session?.metadataUri,
  bundle.release.releaseMetadataUri,
  bundle.release.nftMetadataUri,
  bundle.metadata.releaseMetadataUri,
);

/// Throws when the bundle does not carry a release metadata URI.
String resolveReleaseMetadataUri(
  PublicationBundle bundle,
  PublicationSession? session,
) {
  final uri = getReleaseMetadataUri(bundle, session);
  if (uri == null) {
    throw const PublisherCliException(
      'Publication bundle did not include a release metadata URI',
    );
  }
  return uri;
}

/// Whether the release metadata URI can be resolved without extra calls.
bool hasResolvableReleaseMetadataUri(
  PublicationBundle bundle,
  PublicationSession? session,
) => getReleaseMetadataUri(bundle, session) != null;

/// Resolves the address that must sign portal transactions for [bundle].
String resolvePublicationSignerAddress(PublicationBundle bundle) =>
    _firstNonEmpty(
      bundle.signerAuthority.dappWalletAddress,
      bundle.signerAuthority.requiredSigner,
      bundle.signerAuthority.collectionAuthority,
    ) ??
    '';

/// Resolves the release display name for [bundle].
String resolveReleaseDisplayName(PublicationBundle bundle) =>
    _firstNonEmpty(
      bundle.release.localizedName,
      bundle.release.releaseName,
      bundle.dapp.dappName,
    ) ??
    'Release update';

/// Resolves the fee payer for portal transactions.
String resolvePublicationFeePayer(
  PublicationBundle bundle,
  String signerAddress,
) => bundle.signerAuthority.feePayer ?? signerAddress;

/// Resolves the release mint address from the session or bundle.
String? resolveReleaseMintAddress(
  PublicationBundle bundle,
  PublicationSession session,
) => _firstNonEmpty(
  session.releaseMintAddress,
  bundle.release.nftMintAddress,
  bundle.release.releaseMintAddress,
);

/// Validates that the bundle carries all required publication fields.
void validatePublicationBundle(PublicationBundle bundle) {
  final requiredFields = <(String, Object?)>[
    ('releaseId', bundle.releaseId),
    ('publicationSessionId', bundle.publicationSessionId),
    ('ingestionSessionId', bundle.ingestionSessionId),
    ('androidPackage', bundle.release.androidPackage),
    (
      'release.localizedName',
      _firstNonEmpty(bundle.release.localizedName, bundle.release.releaseName),
    ),
    ('versionName', bundle.release.versionName),
    ('appMintAddress', bundle.signerAuthority.appMintAddress),
    ('dappWalletAddress', bundle.signerAuthority.dappWalletAddress),
    ('collectionAuthority', bundle.signerAuthority.collectionAuthority),
    ('acceptedSignerRoles', bundle.signerAuthority.acceptedSignerRoles),
    ('metadata.localizedName', bundle.metadata.localizedName),
    ('shortDescription', bundle.metadata.shortDescription),
    ('longDescription', bundle.metadata.longDescription),
    ('newInVersion', bundle.metadata.newInVersion),
    ('installFile.uri', bundle.installFile.uri),
    ('installFile.mimeType', bundle.installFile.mimeType),
  ];

  final missing = <String>[];
  for (final (field, value) in requiredFields) {
    if (value is String) {
      if (value.trim().isEmpty) {
        missing.add(field);
      }
    } else if (value is List) {
      if (value.isEmpty) {
        missing.add(field);
      }
    } else if (value == null) {
      missing.add(field);
    }
  }

  if (missing.isNotEmpty) {
    throw PublisherCliException(
      'Publication bundle is missing required fields: ${missing.join(', ')}',
    );
  }
}

/// Normalizes a publication session, re-deriving the coarse stage from the
/// raw session fields.
PublicationSession normalizePublicationSession(PublicationSession session) {
  final stage = resolvePublicationSessionStage(session);
  return PublicationSession(
    id: session.id,
    ingestionSessionId: session.ingestionSessionId,
    releaseId: session.releaseId,
    status: session.status,
    stage: stage,
    checkpoint: session.checkpoint,
    metadataUri: session.metadataUri,
    releaseMintAddress: session.releaseMintAddress,
    mintTransactionSignature: session.mintTransactionSignature,
    verifyTransactionSignature: session.verifyTransactionSignature,
    attestationRequestUniqueId: session.attestationRequestUniqueId,
    hubspotTicketId: session.hubspotTicketId,
    error: session.error,
    lastError: session.lastError,
    created: session.created,
    updated: session.updated,
  );
}

/// Resolves the coarse stage of [session].
PublicationSessionStage resolvePublicationSessionStage(
  PublicationSession session,
) {
  if (session.stage != PublicationSessionStage.preparedForMint) {
    return session.stage;
  }
  if (session.status == PublicationSessionStatus.failed) {
    return PublicationSessionStage.failed;
  }
  if (session.status == PublicationSessionStatus.completed) {
    return PublicationSessionStage.submitted;
  }
  switch (session.checkpoint) {
    case PublicationCheckpoint.submitted:
    case PublicationCheckpoint.completed:
      return PublicationSessionStage.submitted;
    case PublicationCheckpoint.verified:
    case PublicationCheckpoint.attested:
      return PublicationSessionStage.verified;
    case PublicationCheckpoint.verificationSubmitted:
      return PublicationSessionStage.verificationSubmitted;
    case PublicationCheckpoint.mintSaved:
      return PublicationSessionStage.mintSaved;
    case PublicationCheckpoint.mintSubmitted:
      return PublicationSessionStage.mintSubmitted;
    case PublicationCheckpoint.bundleReady:
    case PublicationCheckpoint.created:
      return PublicationSessionStage.preparedForMint;
  }
}

/// Maps a stage to its lifecycle checkpoint.
PublicationCheckpoint publicationStageToCheckpoint(
  PublicationSessionStage? stage,
) => switch (stage) {
  null => PublicationCheckpoint.created,
  PublicationSessionStage.preparedForMint => PublicationCheckpoint.bundleReady,
  PublicationSessionStage.mintSubmitted => PublicationCheckpoint.mintSubmitted,
  PublicationSessionStage.mintSaved => PublicationCheckpoint.mintSaved,
  PublicationSessionStage.verificationSubmitted =>
    PublicationCheckpoint.verificationSubmitted,
  PublicationSessionStage.verified => PublicationCheckpoint.verified,
  PublicationSessionStage.attested => PublicationCheckpoint.attested,
  PublicationSessionStage.submitted => PublicationCheckpoint.submitted,
  PublicationSessionStage.failed => PublicationCheckpoint.created,
};

/// Maps a stage to its session status.
PublicationSessionStatus publicationStageToStatus(
  PublicationSessionStage? stage,
) => switch (stage) {
  null => PublicationSessionStatus.pending,
  PublicationSessionStage.submitted => PublicationSessionStatus.completed,
  PublicationSessionStage.failed => PublicationSessionStatus.failed,
  PublicationSessionStage.preparedForMint => PublicationSessionStatus.pending,
  _ => PublicationSessionStatus.running,
};
