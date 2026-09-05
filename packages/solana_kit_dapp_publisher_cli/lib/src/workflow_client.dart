import 'package:solana_kit_dapp_publisher_cli/src/errors.dart';
import 'package:solana_kit_dapp_publisher_cli/src/portal_types.dart';
import 'package:solana_kit_dapp_publisher_cli/src/publication_models.dart';

/// Inputs for `publication.createIngestionSession`.
final class CreateIngestionSessionInput {
  /// Creates the input.
  const CreateIngestionSessionInput({
    required this.source,
    required this.whatsNew,
    required this.idempotencyKey,
    this.dappId,
  });

  /// The prepared publication source.
  final PublicationSource source;

  /// The "what's new" text.
  final String whatsNew;

  /// Idempotency key for safe retries.
  final String idempotencyKey;

  /// Optional dApp identifier override.
  final String? dappId;

  /// Serializes the input for the portal procedure call.
  Map<String, Object?> toMap() => {
    'source': switch (source) {
      PortalUploadSource(
        :final releaseFileUrl,
        :final releaseFileName,
        :final releaseFileSize,
        :final releaseFileHash,
      ) =>
        {
          'kind': 'portalUpload',
          'releaseFileUrl': releaseFileUrl,
          'releaseFileName': releaseFileName,
          'releaseFileSize': releaseFileSize,
          'releaseFileHash': ?releaseFileHash,
        },
      ApkUrlSource(:final url, :final fileName) => {
        'kind': 'externalUrl',
        'apkUrl': url,
        'releaseFileName': ?fileName,
      },
      ApkFileSource() => throw const PublisherCliException(
        'Local APK sources must be uploaded to the portal before creating an ingestion session.',
      ),
      ExistingReleaseSource(:final sourceReleaseId) => {
        'kind': 'existingRelease',
        'sourceReleaseId': sourceReleaseId,
      },
    },
    'whatsNew': whatsNew,
    'idempotencyKey': idempotencyKey,
    'dappId': ?dappId,
  };
}

/// Inputs for preparing a release NFT transaction.
final class PrepareReleaseNftTransactionInput {
  /// Creates the input.
  const PrepareReleaseNftTransactionInput({
    required this.releaseId,
    required this.releaseName,
    required this.releaseMetadataUri,
    required this.appMintAddress,
    required this.publisherAddress,
    required this.payerAddress,
  });

  /// The release identifier.
  final String releaseId;

  /// The release display name.
  final String releaseName;

  /// The release metadata URI.
  final String releaseMetadataUri;

  /// The app (collection) mint address.
  final String appMintAddress;

  /// The publisher address that signs the transaction.
  final String publisherAddress;

  /// The fee payer address.
  final String payerAddress;

  /// Serializes the input for the portal procedure call.
  Map<String, Object?> toMap() => {
    'releaseId': releaseId,
    'releaseName': releaseName,
    'releaseMetadataUri': releaseMetadataUri,
    'appMintAddress': appMintAddress,
    'publisherAddress': publisherAddress,
    'payerAddress': payerAddress,
  };
}

/// Inputs for preparing a collection verification transaction.
final class PrepareVerifyCollectionTransactionInput {
  /// Creates the input.
  const PrepareVerifyCollectionTransactionInput({
    required this.dappId,
    required this.nftMintAddress,
    required this.collectionMintAddress,
    required this.collectionAuthority,
    required this.payerAddress,
  });

  /// The dApp identifier.
  final String dappId;

  /// The release NFT mint address.
  final String nftMintAddress;

  /// The app (collection) mint address.
  final String collectionMintAddress;

  /// The collection authority address.
  final String collectionAuthority;

  /// The fee payer address.
  final String payerAddress;

  /// Serializes the input for the portal procedure call.
  Map<String, Object?> toMap() => {
    'dappId': dappId,
    'nftMintAddress': nftMintAddress,
    'collectionMintAddress': collectionMintAddress,
    'collectionAuthority': collectionAuthority,
    'payerAddress': payerAddress,
  };
}

/// Inputs for saving release NFT data with the portal.
final class SaveReleaseNftDataInput {
  /// Creates the input.
  const SaveReleaseNftDataInput({
    required this.releaseId,
    required this.mintAddress,
    required this.transactionSignature,
    required this.metadataUri,
    required this.ownerAddress,
    required this.releaseName,
    required this.releaseVersion,
    required this.androidPackage,
    required this.appMintAddress,
  });

  /// The release identifier.
  final String releaseId;

  /// The release mint address.
  final String mintAddress;

  /// The mint transaction signature.
  final String transactionSignature;

  /// The release metadata URI.
  final String metadataUri;

  /// The owner address.
  final String ownerAddress;

  /// The release display name.
  final String releaseName;

  /// The release version name.
  final String releaseVersion;

  /// The Android package name.
  final String androidPackage;

  /// The app mint address.
  final String appMintAddress;

  /// Serializes the input for the portal procedure call.
  Map<String, Object?> toMap() => {
    'releaseId': releaseId,
    'mintAddress': mintAddress,
    'transactionSignature': transactionSignature,
    'metadataUri': metadataUri,
    'ownerAddress': ownerAddress,
    'releaseName': releaseName,
    'releaseVersion': releaseVersion,
    'androidPackage': androidPackage,
    'appMintAddress': appMintAddress,
  };
}

/// Inputs for cleaning up a failed release.
final class CleanupReleaseInput {
  /// Creates the input.
  const CleanupReleaseInput({required this.releaseId});

  /// The release identifier.
  final String releaseId;

  /// Serializes the input for the portal procedure call.
  Map<String, Object?> toMap() => {'releaseId': releaseId};
}

/// Fetches the slot and blockhash used to build attestation payloads.
typedef PublicationAttestationClient =
    Future<({num slot, String blockhash})> Function();

/// The workflow client used to drive a publication.
abstract class PublicationWorkflowClient {
  /// Requests a presigned upload target.
  Future<PortalUploadTarget> createUploadTarget(CreateUploadTargetInput input);

  /// Creates an ingestion session, uploading local APKs when needed.
  Future<PublicationIngestionSession> createIngestionSession(
    CreateIngestionSessionInput input,
  );

  /// Fetches an ingestion session by id.
  Future<PublicationIngestionSession> getIngestionSession({
    required String sessionId,
  });

  /// Fetches the publication bundle for a release.
  Future<PublicationBundle> getPublicationBundle({required String releaseId});

  /// Fetches a publication session.
  Future<PublicationSession> getPublicationSession({
    String? publicationSessionId,
    String? releaseId,
  });

  /// Asks the portal to prepare the release NFT mint transaction.
  Future<PreparedReleaseTransaction> prepareReleaseNftTransaction(
    PrepareReleaseNftTransactionInput input,
  );

  /// Submits a signed transaction to the portal for on-chain submission.
  Future<SubmitSignedTransactionResult> submitSignedTransaction({
    required String signedTransaction,
    String? publicationSessionId,
  });

  /// Saves release NFT data with the portal.
  Future<SaveReleaseNftDataResult> saveReleaseNftData(
    SaveReleaseNftDataInput input,
  );

  /// Asks the portal to prepare the collection verification transaction.
  Future<PreparedVerifyCollectionTransaction>
  prepareVerifyCollectionTransaction(
    PrepareVerifyCollectionTransactionInput input,
  );

  /// Marks the release collection as verified.
  Future<MarkReleaseCollectionAsVerifiedResult>
  markReleaseCollectionAsVerified({
    required String releaseId,
  });

  /// Cleans up a failed release.
  Future<CleanupReleaseResult> cleanupRelease(CleanupReleaseInput input);

  /// Submits the release to the store for review.
  Future<SubmitToStoreResult> submitToStore(SubmitToStoreInput input);
}

/// The final result of a publication workflow.
final class PublicationWorkflowResult {
  /// Creates the result.
  const PublicationWorkflowResult({
    required this.ingestionSessionId,
    required this.publicationSessionId,
    required this.releaseId,
    required this.releaseMintAddress,
    required this.collectionMintAddress,
    required this.releaseTransactionSignature,
    required this.collectionTransactionSignature,
    required this.attestationRequestUniqueId,
    required this.hubspotTicketId,
    required this.bundle,
    required this.session,
  });

  /// The ingestion session identifier.
  final String ingestionSessionId;

  /// The publication session identifier.
  final String publicationSessionId;

  /// The release identifier.
  final String releaseId;

  /// The release mint address.
  final String releaseMintAddress;

  /// The collection mint address.
  final String collectionMintAddress;

  /// The mint transaction signature, when known.
  final String? releaseTransactionSignature;

  /// The verification transaction signature, when known.
  final String? collectionTransactionSignature;

  /// The attestation request unique id, when known.
  final String? attestationRequestUniqueId;

  /// The HubSpot ticket identifier, when known.
  final String? hubspotTicketId;

  /// The normalized publication bundle.
  final PublicationBundle bundle;

  /// The normalized publication session.
  final PublicationSession session;
}

/// A logger that receives workflow progress events.
typedef WorkflowLogger =
    void Function(
      String message, {
      required String step,
      required String status,
    });

/// Options for the publication workflow.
final class PublicationWorkflowOptions {
  /// Creates the options.
  const PublicationWorkflowOptions({
    this.pollInterval = const Duration(milliseconds: 2500),
    this.maxPollAttempts = 1080,
    this.logger,
  });

  /// How long to wait between ingestion polls.
  final Duration pollInterval;

  /// The maximum number of ingestion polls before timing out.
  final int maxPollAttempts;

  /// Optional step logger.
  final WorkflowLogger? logger;
}
