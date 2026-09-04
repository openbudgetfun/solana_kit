import 'package:solana_kit_dapp_publisher_cli/src/portal_types.dart';

/// The dApp record from the portal.
final class DappInfo {
  /// Creates the dApp record.
  const DappInfo({
    required this.id,
    required this.dappName,
    required this.subtitle,
    required this.description,
    required this.androidPackage,
    required this.dappIconUrl,
    required this.dappPreviewUrls,
    required this.bannerUrl,
    required this.featureGraphicUrl,
    required this.editorsChoiceGraphicUrl,
    required this.appWebsite,
    required this.contactEmail,
    required this.supportEmail,
    required this.languages,
    required this.licenseUrl,
    required this.copyrightUrl,
    required this.privacyPolicyUrl,
    required this.walletAddress,
    required this.nftMintAddress,
    required this.lastApprovedReleaseId,
    required this.website,
  });

  /// Portal dApp identifier.
  final String id;

  /// The dApp display name.
  final String dappName;

  /// The subtitle, when present.
  final String? subtitle;

  /// The long description.
  final String description;

  /// The Android package name.
  final String androidPackage;

  /// The public app icon URL.
  final String? dappIconUrl;

  /// Screenshot URLs.
  final List<String> dappPreviewUrls;

  /// The banner URL.
  final String? bannerUrl;

  /// The feature graphic URL.
  final String? featureGraphicUrl;

  /// The editors' choice graphic URL.
  final String? editorsChoiceGraphicUrl;

  /// The app website.
  final String? appWebsite;

  /// The contact email.
  final String? contactEmail;

  /// The support email.
  final String supportEmail;

  /// Supported locales.
  final List<String> languages;

  /// The license URL.
  final String? licenseUrl;

  /// The copyright URL.
  final String? copyrightUrl;

  /// The privacy policy URL.
  final String? privacyPolicyUrl;

  /// The dApp wallet address.
  final String walletAddress;

  /// The app NFT mint address.
  final String nftMintAddress;

  /// The last approved release identifier.
  final String? lastApprovedReleaseId;

  /// The dApp website.
  final String? website;
}

/// The publisher record from the portal.
final class PublisherInfo {
  /// Creates the publisher record.
  const PublisherInfo({
    required this.id,
    required this.type,
    required this.name,
    required this.website,
    required this.email,
    required this.supportEmail,
  });

  /// Portal publisher identifier.
  final String id;

  /// The publisher type (`organization` or `individual`).
  final String type;

  /// The publisher display name.
  final String name;

  /// The publisher website.
  final String website;

  /// The publisher contact email.
  final String email;

  /// The publisher support email.
  final String supportEmail;
}

/// The legal links attached to a publication bundle.
final class BundleLegal {
  /// Creates the legal links.
  const BundleLegal({
    required this.licenseUrl,
    required this.copyrightUrl,
    required this.privacyPolicyUrl,
  });

  /// The license URL, when present.
  final String? licenseUrl;

  /// The copyright URL, when present.
  final String? copyrightUrl;

  /// The privacy policy URL, when present.
  final String? privacyPolicyUrl;
}

/// A localized metadata entry for a release.
final class LocalizedReleaseStrings {
  /// Creates the localized strings.
  const LocalizedReleaseStrings({
    required this.locale,
    required this.name,
    required this.shortDescription,
    required this.longDescription,
    required this.newInVersion,
  });

  /// The locale tag, e.g. `en-US`.
  final String locale;

  /// The localized name.
  final String name;

  /// The localized short description.
  final String shortDescription;

  /// The localized long description.
  final String longDescription;

  /// The localized "what's new" text.
  final String newInVersion;
}

/// Normalized metadata for a publication bundle.
final class BundleMetadata {
  /// Creates the metadata.
  const BundleMetadata({
    required this.localizedName,
    required this.shortDescription,
    required this.longDescription,
    required this.newInVersion,
    required this.publisherWebsite,
    required this.supportEmail,
    required this.website,
    required this.locales,
    required this.legal,
    required this.media,
    required this.installFile,
    required this.localizedStrings,
    required this.releaseMetadataUri,
  });

  /// The localized release name.
  final String localizedName;

  /// The short description.
  final String shortDescription;

  /// The long description.
  final String longDescription;

  /// The "what's new" text.
  final String newInVersion;

  /// The publisher website, when present.
  final String? publisherWebsite;

  /// The support email, when present.
  final String? supportEmail;

  /// The app website, when present.
  final String? website;

  /// Supported locales.
  final List<String> locales;

  /// Legal links.
  final BundleLegal legal;

  /// Media entries attached to the bundle.
  final List<Map<String, Object?>> media;

  /// The install file details.
  final InstallFileDetails installFile;

  /// Localized strings resolved by the translators.
  final List<LocalizedReleaseStrings> localizedStrings;

  /// The release metadata URI, when known.
  final String? releaseMetadataUri;
}

/// The signer authority attached to a publication bundle.
final class SignerAuthority {
  /// Creates the signer authority.
  const SignerAuthority({
    required this.dappWalletAddress,
    required this.collectionAuthority,
    required this.appMintAddress,
    required this.sameSignerRequired,
    required this.acceptedSignerRoles,
    required this.dappId,
    required this.requiredSigner,
    required this.mintSigner,
    required this.feePayer,
  });

  /// The dApp wallet address (primary signer).
  final String dappWalletAddress;

  /// The collection authority address.
  final String collectionAuthority;

  /// The app (collection) mint address.
  final String appMintAddress;

  /// Whether the same signer is required for all transactions.
  final bool sameSignerRequired;

  /// The accepted signer roles.
  final List<String> acceptedSignerRoles;

  /// The dApp identifier.
  final String dappId;

  /// The required signer address.
  final String requiredSigner;

  /// The mint signer address.
  final String mintSigner;

  /// The fee payer address, when provided by the portal.
  final String? feePayer;
}

/// The release record from the portal.
final class ReleaseInfo {
  /// Creates the release record.
  const ReleaseInfo({
    required this.id,
    required this.dappId,
    required this.releaseFileUrl,
    required this.releaseFileName,
    required this.releaseFileSize,
    required this.releaseFileHash,
    required this.releaseName,
    required this.versionName,
    required this.versionCode,
    required this.androidPackage,
    required this.minSdkVersion,
    required this.targetSdkVersion,
    required this.permissions,
    required this.locales,
    required this.certificateFingerprint,
    required this.shortDescription,
    required this.longDescription,
    required this.localizedName,
    required this.newInVersion,
    required this.sagaFeatures,
    required this.releaseMintAddress,
    required this.releaseMetadataUri,
    required this.nftMintAddress,
    required this.nftMetadataUri,
  });

  /// Portal release identifier.
  final String id;

  /// The dApp identifier.
  final String dappId;

  /// The release file URL, when present.
  final String? releaseFileUrl;

  /// The release file name.
  final String releaseFileName;

  /// The release file size in bytes.
  final num releaseFileSize;

  /// The release file SHA-256, when known.
  final String? releaseFileHash;

  /// The release display name.
  final String releaseName;

  /// The version name.
  final String versionName;

  /// The version code.
  final num versionCode;

  /// The Android package name.
  final String androidPackage;

  /// The minimum SDK version, when known.
  final num? minSdkVersion;

  /// The target SDK version, when known.
  final num? targetSdkVersion;

  /// Android permissions.
  final List<String> permissions;

  /// Release locales.
  final List<String> locales;

  /// The certificate fingerprint.
  final String? certificateFingerprint;

  /// The release short description, when present.
  final String? shortDescription;

  /// The release long description, when present.
  final String? longDescription;

  /// The localized release name.
  final String localizedName;

  /// The "what's new" text.
  final String newInVersion;

  /// Saga features, when present.
  final String? sagaFeatures;

  /// The release NFT mint address, when known.
  final String? releaseMintAddress;

  /// The release metadata URI, when known.
  final String? releaseMetadataUri;

  /// Alias of [releaseMintAddress].
  final String? nftMintAddress;

  /// The NFT metadata URI, when known.
  final String? nftMetadataUri;
}

/// A normalized publication bundle.
final class PublicationBundle {
  /// Creates the bundle.
  const PublicationBundle({
    required this.ingestionSessionId,
    required this.publicationSessionId,
    required this.releaseId,
    required this.dapp,
    required this.publisher,
    required this.installFile,
    required this.metadata,
    required this.signerAuthority,
    required this.release,
  });

  /// The ingestion session identifier.
  final String ingestionSessionId;

  /// The publication session identifier.
  final String publicationSessionId;

  /// The release identifier.
  final String releaseId;

  /// The dApp record.
  final DappInfo dapp;

  /// The publisher record.
  final PublisherInfo publisher;

  /// The install file details.
  final InstallFileDetails installFile;

  /// The normalized metadata.
  final BundleMetadata metadata;

  /// The signer authority.
  final SignerAuthority signerAuthority;

  /// The release record.
  final ReleaseInfo release;
}

/// The lifecycle checkpoint of a publication session.
enum PublicationCheckpoint {
  /// The session was created.
  created('created'),

  /// The publication bundle is ready to mint.
  bundleReady('bundle-ready'),

  /// The mint transaction was submitted.
  mintSubmitted('mint-submitted'),

  /// The release NFT data was saved.
  mintSaved('mint-saved'),

  /// The verification transaction was submitted.
  verificationSubmitted('verification-submitted'),

  /// The collection was verified.
  verified('verified'),

  /// The attestation was recorded.
  attested('attested'),

  /// The release was submitted to the store.
  submitted('submitted'),

  /// The publication completed.
  completed('completed');

  const PublicationCheckpoint(this.wireName);

  /// The wire representation used by the portal.
  final String wireName;

  /// Parses a checkpoint from its wire representation.
  static PublicationCheckpoint fromWire(String value) =>
      _checkpointByWire[value] ?? PublicationCheckpoint.created;

  /// The wire representation.
  String get wire => wireName;
}

const _checkpointByWire = <String, PublicationCheckpoint>{
  'created': PublicationCheckpoint.created,
  'bundle-ready': PublicationCheckpoint.bundleReady,
  'mint-submitted': PublicationCheckpoint.mintSubmitted,
  'mint-saved': PublicationCheckpoint.mintSaved,
  'verification-submitted': PublicationCheckpoint.verificationSubmitted,
  'verified': PublicationCheckpoint.verified,
  'attested': PublicationCheckpoint.attested,
  'submitted': PublicationCheckpoint.submitted,
  'completed': PublicationCheckpoint.completed,
};

/// The coarse stage of a publication session.
enum PublicationSessionStage {
  /// The session is prepared for minting.
  preparedForMint,

  /// The mint transaction was submitted.
  mintSubmitted,

  /// The release NFT data was saved.
  mintSaved,

  /// The verification transaction was submitted.
  verificationSubmitted,

  /// The collection was verified.
  verified,

  /// The attestation was recorded.
  attested,

  /// The release was submitted to the store.
  submitted,

  /// The session failed.
  failed;

  /// Parses a stage from its wire representation.
  static PublicationSessionStage fromWire(String? value) => switch (value) {
    'PreparedForMint' => PublicationSessionStage.preparedForMint,
    'MintSubmitted' => PublicationSessionStage.mintSubmitted,
    'MintSaved' => PublicationSessionStage.mintSaved,
    'VerificationSubmitted' => PublicationSessionStage.verificationSubmitted,
    'Verified' => PublicationSessionStage.verified,
    'Attested' => PublicationSessionStage.attested,
    'Submitted' => PublicationSessionStage.submitted,
    'Failed' => PublicationSessionStage.failed,
    _ => PublicationSessionStage.preparedForMint,
  };
}

/// The session status reported to the portal.
enum PublicationSessionStatus {
  /// The session is pending.
  pending,

  /// The session is running.
  running,

  /// The session completed.
  completed,

  /// The session failed.
  failed;

  /// Parses a status from its wire representation.
  static PublicationSessionStatus fromWire(String? value) => switch (value) {
    'pending' => PublicationSessionStatus.pending,
    'running' => PublicationSessionStatus.running,
    'completed' => PublicationSessionStatus.completed,
    'failed' => PublicationSessionStatus.failed,
    _ => PublicationSessionStatus.running,
  };
}

/// A normalized publication session.
final class PublicationSession {
  /// Creates the session.
  const PublicationSession({
    required this.id,
    required this.ingestionSessionId,
    required this.releaseId,
    required this.status,
    required this.stage,
    required this.checkpoint,
    required this.metadataUri,
    required this.releaseMintAddress,
    required this.mintTransactionSignature,
    required this.verifyTransactionSignature,
    required this.attestationRequestUniqueId,
    required this.hubspotTicketId,
    required this.error,
    required this.lastError,
    required this.created,
    required this.updated,
  });

  /// Portal publication session identifier.
  final String id;

  /// The ingestion session identifier.
  final String ingestionSessionId;

  /// The release identifier.
  final String releaseId;

  /// The session status.
  final PublicationSessionStatus status;

  /// The coarse session stage.
  final PublicationSessionStage stage;

  /// The precise lifecycle checkpoint.
  final PublicationCheckpoint checkpoint;

  /// The metadata URI recorded on the session, when present.
  final String? metadataUri;

  /// The release mint address, when known.
  final String? releaseMintAddress;

  /// The mint transaction signature, when known.
  final String? mintTransactionSignature;

  /// The verification transaction signature, when known.
  final String? verifyTransactionSignature;

  /// The attestation request unique id, when known.
  final String? attestationRequestUniqueId;

  /// The HubSpot ticket identifier, when known.
  final String? hubspotTicketId;

  /// The normalized error message, when present.
  final String? error;

  /// The raw last error from the backend, when present.
  final String? lastError;

  /// Creation timestamp.
  final String created;

  /// Update timestamp.
  final String updated;
}

/// An ingestion session as returned by the portal.
final class PublicationIngestionSession {
  /// Creates the session.
  const PublicationIngestionSession({
    required this.id,
    required this.dappId,
    required this.idempotencyKey,
    required this.source,
    required this.whatsNew,
    required this.status,
    required this.releaseId,
    required this.publicationSessionId,
    required this.bundle,
    required this.publicationSession,
    required this.androidPackage,
    required this.versionName,
    required this.processingProgress,
    required this.processingStage,
    required this.processingDetail,
    required this.processingError,
    required this.error,
  });

  /// Ingestion session identifier.
  final String id;

  /// The dApp identifier.
  final String dappId;

  /// The idempotency key for the session.
  final String idempotencyKey;

  /// The ingestion source.
  final PublicationSource source;

  /// The "what's new" text.
  final String whatsNew;

  /// The ingestion status (`created`, `queued`, `processing`, `Ready`, ...).
  final String status;

  /// The release identifier, when assigned.
  final String? releaseId;

  /// The publication session identifier, when assigned.
  final String? publicationSessionId;

  /// The bundle attached to the session, when present.
  final PublicationBundle? bundle;

  /// The publication session, when present.
  final PublicationSession? publicationSession;

  /// The Android package name, when known.
  final String? androidPackage;

  /// The version name, when known.
  final String? versionName;

  /// The processing progress percentage, when known.
  final num? processingProgress;

  /// The processing stage, when known.
  final String? processingStage;

  /// The processing detail message, when known.
  final String? processingDetail;

  /// The processing error, when known.
  final String? processingError;

  /// The session error, when present.
  final String? error;

  /// Whether ingestion has finished processing and is ready.
  bool get isReady => status == 'Ready' || status == 'ready';

  /// Whether ingestion failed.
  bool get isFailed => status == 'Failed' || status == 'failed';
}
