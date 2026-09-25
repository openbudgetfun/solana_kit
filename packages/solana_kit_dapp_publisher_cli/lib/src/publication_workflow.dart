import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'package:solana_kit_dapp_publisher_cli/src/attestation.dart';
import 'package:solana_kit_dapp_publisher_cli/src/errors.dart';
import 'package:solana_kit_dapp_publisher_cli/src/files.dart';
import 'package:solana_kit_dapp_publisher_cli/src/portal_client.dart';
import 'package:solana_kit_dapp_publisher_cli/src/portal_types.dart';
import 'package:solana_kit_dapp_publisher_cli/src/publication_models.dart';
import 'package:solana_kit_dapp_publisher_cli/src/publication_signer.dart';
import 'package:solana_kit_dapp_publisher_cli/src/workflow_client.dart';
import 'package:solana_kit_dapp_publisher_cli/src/workflow_state.dart';

/// Inputs for starting a new publication.
final class PublicationWorkflowInput {
  /// Creates the input.
  const PublicationWorkflowInput({
    required this.source,
    required this.whatsNew,
    required this.signer,
    required this.attestationClient,
    this.dappId,
    this.idempotencyKey,
  });

  /// The publication source.
  final PublicationSource source;

  /// The "what's new" text.
  final String whatsNew;

  /// The publication signer.
  final PublicationSigner signer;

  /// The attestation client.
  final PublicationAttestationClient attestationClient;

  /// Optional dApp identifier override.
  final String? dappId;

  /// Optional idempotency key override.
  final String? idempotencyKey;
}

/// Inputs for resuming a partially completed publication.
final class PublicationResumeInput {
  /// Creates the input.
  const PublicationResumeInput({
    required this.signer,
    required this.attestationClient,
    this.publicationSessionId,
    this.releaseId,
  });

  /// The publication signer.
  final PublicationSigner signer;

  /// The attestation client.
  final PublicationAttestationClient attestationClient;

  /// The publication session identifier to resume.
  final String? publicationSessionId;

  /// The release identifier to resume.
  final String? releaseId;
}

/// The publication workflow engine.
final class PublicationWorkflow {
  /// Creates a workflow bound to [client].
  const PublicationWorkflow(
    this.client, {
    this.options = const PublicationWorkflowOptions(),
  });

  /// The workflow client.
  final PublicationWorkflowClient client;

  /// Workflow options.
  final PublicationWorkflowOptions options;

  /// Starts a new publication from the source in [input].
  Future<PublicationWorkflowResult> startPublication(
    PublicationWorkflowInput input,
  ) async {
    String? createdReleaseId;
    String? createdIngestionSessionId;

    try {
      options.logger?.call(
        'Preparing publication source',
        step: 'source.prepare',
        status: 'running',
      );

      final source = await preparePublicationSource(client, input.source);

      options.logger?.call(
        'Creating ingestion session',
        step: 'ingestion.create',
        status: 'running',
      );

      final ingestionSession = await client.createIngestionSession(
        CreateIngestionSessionInput(
          source: source,
          whatsNew: input.whatsNew,
          idempotencyKey: input.idempotencyKey ?? newIdempotencyKey(),
          dappId: input.dappId,
        ),
      );

      createdReleaseId = ingestionSession.releaseId;
      createdIngestionSessionId = ingestionSession.id.trim();
      if (createdIngestionSessionId.isEmpty) {
        throw const PublisherCliException(
          'Portal createIngestionSession did not return an ingestion session id',
        );
      }

      options.logger?.call(
        'Ingestion session created',
        step: 'ingestion.create',
        status: 'complete',
      );

      final readySession = await waitForIngestionSessionReady(
        client,
        createdIngestionSessionId,
        options,
      );

      final releaseId = readySession.releaseId;
      if (releaseId == null || releaseId.isEmpty) {
        throw const PublisherCliException(
          'Publication ingestion completed without a release identifier',
        );
      }
      createdReleaseId = releaseId;

      final readyPublicationSession = readySession.publicationSession == null
          ? null
          : normalizePublicationSession(readySession.publicationSession!);
      final readyPublicationBundle = readySession.bundle == null
          ? null
          : withPublicationBundleIdentifiers(
              normalizePublicationBundle(readySession.bundle!),
              releaseId: releaseId,
              publicationSessionId: readySession.publicationSessionId,
              ingestionSessionId: readySession.id,
            );

      final publicationBundle = await loadPublicationBundle(
        client,
        releaseId: releaseId,
        publicationSessionId: readySession.publicationSessionId,
        ingestionSessionId: readySession.id,
        existingBundle: readyPublicationBundle,
        existingSession: readyPublicationSession,
        logger: options.logger,
      );

      final publicationSession = await loadPublicationSession(
        client,
        publicationSessionId: readySession.publicationSessionId,
        releaseId: releaseId,
        existingSession: readyPublicationSession,
        logger: options.logger,
      );

      return await runPublicationWorkflowCore(
        client,
        publicationBundle,
        input.signer,
        input.attestationClient,
        publicationSession,
        options.logger,
      );
    } on Object catch (error) {
      final normalizedError = normalizeWorkflowError(error);

      if ((createdReleaseId == null || createdReleaseId.isEmpty) &&
          createdIngestionSessionId != null &&
          createdIngestionSessionId.isNotEmpty) {
        try {
          final failedIngestionSession = await client.getIngestionSession(
            sessionId: createdIngestionSessionId,
          );
          final fallbackReleaseId = failedIngestionSession.releaseId;
          if (fallbackReleaseId != null && fallbackReleaseId.isNotEmpty) {
            createdReleaseId = fallbackReleaseId;
          }
        } on Object {
          // Ignore follow-up lookup failures and rethrow the original error.
        }
      }

      if (createdReleaseId == null || createdReleaseId.isEmpty) {
        throw normalizedError;
      }

      try {
        final cleanupResult = await cleanupFailedRelease(
          client,
          createdReleaseId,
          normalizedError,
          options.logger,
        );

        if (cleanupResult != null &&
            cleanupResult.action == 'preservedSubmitted') {
          return await recoverPublicationResult(
            client,
            createdReleaseId,
            input,
            options.logger,
          );
        }
      } on Object catch (cleanupError) {
        final normalizedCleanupError = normalizeWorkflowError(cleanupError);
        throw PublisherCliException(
          '${normalizedError.message} Cleanup also failed for release '
          '$createdReleaseId: ${normalizedCleanupError.message}',
        );
      }

      throw normalizedError;
    }
  }

  /// Resumes a partially completed publication.
  Future<PublicationWorkflowResult> resumePublication(
    PublicationResumeInput input,
  ) async {
    if ((input.publicationSessionId == null ||
            input.publicationSessionId!.isEmpty) &&
        (input.releaseId == null || input.releaseId!.isEmpty)) {
      throw const PublisherCliException(
        'Publication session id or release id is required to resume a publication',
      );
    }

    final publicationSession = await loadPublicationSession(
      client,
      publicationSessionId: input.publicationSessionId,
      releaseId: input.releaseId,
      logger: options.logger,
    );

    final publicationBundle = await loadPublicationBundle(
      client,
      releaseId: publicationSession.releaseId,
      publicationSessionId: publicationSession.id,
      ingestionSessionId: publicationSession.ingestionSessionId,
      logger: options.logger,
    );

    return runPublicationWorkflowCore(
      client,
      publicationBundle,
      input.signer,
      input.attestationClient,
      publicationSession,
      options.logger,
    );
  }
}

/// Generates a random idempotency key (UUID v4 shape).
String newIdempotencyKey() {
  final random = Random.secure();
  final bytes = Uint8List(16);
  for (var i = 0; i < bytes.length; i++) {
    bytes[i] = random.nextInt(256);
  }
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;
  final hex = bytes
      .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
      .join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
      '${hex.substring(12, 16)}-${hex.substring(16, 20)}-'
      '${hex.substring(20)}';
}

/// Normalizes any thrown object into a [PublisherCliException].
PublisherCliException normalizeWorkflowError(Object error) => switch (error) {
  final PublisherCliException exception => exception,
  _ => PublisherCliException(error.toString()),
};

/// Resolves the lookup key for a publication session.
({String? publicationSessionId, String? releaseId})
resolvePublicationSessionLookup({
  String? publicationSessionId,
  String? releaseId,
}) {
  if (publicationSessionId != null && publicationSessionId.isNotEmpty) {
    return (
      publicationSessionId: publicationSessionId,
      releaseId: null,
    );
  }
  if (releaseId == null || releaseId.isEmpty) {
    throw const PublisherCliException(
      'releaseId is required when publicationSessionId is absent',
    );
  }
  return (publicationSessionId: null, releaseId: releaseId);
}

/// Loads and normalizes a publication session.
Future<PublicationSession> loadPublicationSession(
  PublicationWorkflowClient client, {
  String? publicationSessionId,
  String? releaseId,
  PublicationSession? existingSession,
  WorkflowLogger? logger,
}) async {
  logger?.call(
    'Loading publication session',
    step: 'session.load',
    status: 'running',
  );

  final lookup = resolvePublicationSessionLookup(
    publicationSessionId: publicationSessionId,
    releaseId: releaseId,
  );
  final publicationSession =
      existingSession ??
      normalizePublicationSession(
        await client.getPublicationSession(
          publicationSessionId: lookup.publicationSessionId,
          releaseId: lookup.releaseId,
        ),
      );

  logger?.call(
    'Publication session loaded',
    step: 'session.load',
    status: 'complete',
  );

  return publicationSession;
}

/// Loads and normalizes a publication bundle.
Future<PublicationBundle> loadPublicationBundle(
  PublicationWorkflowClient client, {
  required String releaseId,
  String? publicationSessionId,
  String? ingestionSessionId,
  PublicationBundle? existingBundle,
  PublicationSession? existingSession,
  WorkflowLogger? logger,
}) async {
  logger?.call(
    'Loading publication bundle',
    step: 'bundle.load',
    status: 'running',
  );

  final useExistingBundle =
      existingBundle != null &&
      hasResolvableReleaseMetadataUri(existingBundle, existingSession);
  final publicationBundle = useExistingBundle
      ? existingBundle
      : withPublicationBundleIdentifiers(
          normalizePublicationBundle(
            await client.getPublicationBundle(releaseId: releaseId),
          ),
          releaseId: releaseId,
          publicationSessionId: publicationSessionId,
          ingestionSessionId: ingestionSessionId,
        );

  validatePublicationBundle(publicationBundle);

  logger?.call(
    'Publication bundle loaded',
    step: 'bundle.load',
    status: 'complete',
  );

  return publicationBundle;
}

/// Waits for an ingestion session to become ready.
Future<PublicationIngestionSession> waitForIngestionSessionReady(
  PublicationWorkflowClient client,
  String ingestionSessionId,
  PublicationWorkflowOptions options,
) async {
  options.logger?.call(
    'Waiting for portal ingestion to finish',
    step: 'ingestion.wait',
    status: 'running',
  );

  for (var attempt = 1; ; attempt++) {
    final session = await client.getIngestionSession(
      sessionId: ingestionSessionId,
    );
    if (session.isFailed) {
      throw PublisherCliException(
        session.error ??
            session.processingError ??
            'Publication ingestion failed before the bundle was ready',
      );
    }

    final statusMessage = buildIngestionStatusMessage(session);
    if (statusMessage != null) {
      options.logger?.call(
        statusMessage,
        step: 'ingestion.wait',
        status: 'running',
      );
    }

    if (session.isReady) {
      options.logger?.call(
        'Portal ingestion is ready',
        step: 'ingestion.wait',
        status: 'complete',
      );
      return session;
    }

    if (attempt >= options.maxPollAttempts) {
      throw PublisherCliException(
        'Timed out waiting for ingestion session $ingestionSessionId to become ready',
      );
    }

    await Future<void>.delayed(options.pollInterval);
  }
}

/// Builds the ingestion status message for the logger, when one applies.
String? buildIngestionStatusMessage(PublicationIngestionSession session) {
  final detail = session.processingDetail?.trim();
  if (detail != null && detail.isNotEmpty) {
    return detail;
  }
  final stage = session.processingStage?.trim();
  if (stage != null && stage.isNotEmpty) {
    return stage;
  }
  return switch (session.status) {
    'created' => 'Portal ingestion request created',
    'queued' => 'Portal ingestion queued',
    'processing' => 'Portal ingestion is processing the APK',
    'Ready' || 'ready' => 'Portal ingestion is ready',
    _ => null,
  };
}

/// Prepares the publication source, uploading local APKs to portal storage.
Future<PublicationSource> preparePublicationSource(
  PublicationWorkflowClient client,
  PublicationSource source,
) async {
  switch (source) {
    case ApkFileSource():
      return uploadLocalApkToPortal(client, source);
    case PortalUploadSource():
    case ApkUrlSource():
    case ExistingReleaseSource():
      return source;
  }
}

/// Uploads a local APK to portal storage.
///
/// [uploadClient] overrides the HTTP client used for the raw file upload.
Future<PublicationSource> uploadLocalApkToPortal(
  PublicationWorkflowClient client,
  ApkFileSource source, {
  http.Client? uploadClient,
}) async {
  final fileStat = await FileStat.stat(source.filePath);
  if (fileStat.type == FileSystemEntityType.notFound) {
    throw PublisherCliException(
      'Cannot read local APK at ${source.filePath}. '
      'Check that the file exists and that this process has permission to read it.',
    );
  }

  final contentType = source.mimeType ?? apkContentType;
  final fileHash = hashFileSha256(source.filePath);
  final fileName = ensureApkFileName(source.fileName);

  final uploadTarget = await client.createUploadTarget(
    CreateUploadTargetInput(
      fileHash: fileHash,
      fileExtension: 'apk',
      contentType: contentType,
    ),
  );

  await uploadBytes(
    uploadTarget.uploadUrl,
    File(source.filePath).readAsBytesSync(),
    contentType,
    client: uploadClient,
  );

  return PortalUploadSource(
    releaseFileUrl: uploadTarget.publicUrl,
    releaseFileName: fileName,
    releaseFileSize: fileStat.size,
    releaseFileHash: fileHash,
    contentType: contentType,
  );
}

/// Recovers the final publication result for a release that already reached
/// the submitted state.
Future<PublicationWorkflowResult> recoverPublicationResult(
  PublicationWorkflowClient client,
  String releaseId,
  PublicationWorkflowInput input,
  WorkflowLogger? logger,
) async {
  logger?.call(
    'Recovering final publication state',
    step: 'cleanup.recover',
    status: 'running',
  );

  final publicationSession = normalizePublicationSession(
    await client.getPublicationSession(releaseId: releaseId),
  );
  final publicationBundle = withPublicationBundleIdentifiers(
    normalizePublicationBundle(
      await client.getPublicationBundle(releaseId: releaseId),
    ),
    releaseId: releaseId,
    publicationSessionId: publicationSession.id,
    ingestionSessionId: publicationSession.ingestionSessionId,
  );

  logger?.call(
    'Recovered final publication state',
    step: 'cleanup.recover',
    status: 'complete',
  );

  return runPublicationWorkflowCore(
    client,
    publicationBundle,
    input.signer,
    input.attestationClient,
    publicationSession,
    logger,
  );
}

/// Cleans up a failed release, returning the portal cleanup result.
Future<CleanupReleaseResult?> cleanupFailedRelease(
  PublicationWorkflowClient client,
  String releaseId,
  PublisherCliException error,
  WorkflowLogger? logger,
) async {
  logger?.call(
    'Rolling back failed publication release',
    step: 'cleanup.release',
    status: 'running',
  );

  final cleanupResult = await client.cleanupRelease(
    CleanupReleaseInput(releaseId: releaseId),
  );

  logger?.call(
    cleanupResult.action == 'deleted'
        ? 'Failed publication release cleaned up'
        : 'Publication already reached the submitted state; preserving release',
    step: 'cleanup.release',
    status: 'complete',
  );

  return cleanupResult;
}

/// Runs the mint, save, verify, attest, and submit steps of a publication.
Future<PublicationWorkflowResult> runPublicationWorkflowCore(
  PublicationWorkflowClient client,
  PublicationBundle bundle,
  PublicationSigner signer,
  PublicationAttestationClient attestationClient,
  PublicationSession session,
  WorkflowLogger? logger,
) async {
  final normalizedBundle = normalizePublicationBundle(bundle);
  final normalizedSession = normalizePublicationSession(session);
  validatePublicationBundle(normalizedBundle);

  final requiredSignerAddress = resolvePublicationSignerAddress(
    normalizedBundle,
  );
  if (signer.address != requiredSignerAddress) {
    throw PublisherCliException(
      'Publication signer mismatch. '
      'Expected $requiredSignerAddress; received ${signer.address}.',
    );
  }

  if (normalizedSession.stage == PublicationSessionStage.failed) {
    throw PublisherCliException(
      normalizedSession.lastError ??
          normalizedSession.error ??
          'Publication session failed',
    );
  }

  final publicationSession = normalizedSession;
  final state = _PublicationExecutionState(
    releaseTransactionSignature: publicationSession.mintTransactionSignature,
    collectionTransactionSignature:
        publicationSession.verifyTransactionSignature,
    hubspotTicketId: publicationSession.hubspotTicketId,
    releaseMintAddress: resolveReleaseMintAddress(
      normalizedBundle,
      publicationSession,
    ),
  );

  final context = _PublicationExecutionContext(
    client: client,
    bundle: normalizedBundle,
    signer: signer,
    attestationClient: attestationClient,
    publicationSession: publicationSession,
    logger: logger,
    releaseMetadataUri: resolveReleaseMetadataUri(
      normalizedBundle,
      publicationSession,
    ),
    publisherAddress: requiredSignerAddress,
    payerAddress: resolvePublicationFeePayer(normalizedBundle, signer.address),
  );

  await _submitReleaseMintIfNeeded(context, state);
  await _saveReleaseMintIfNeeded(context, state);
  await _verifyReleaseCollectionIfNeeded(context, state);
  await _attestAndSubmitIfNeeded(context, state);

  final releaseMintAddress = state.releaseMintAddress;
  if (releaseMintAddress == null || releaseMintAddress.isEmpty) {
    throw const PublisherCliException(
      'Publication session did not resolve a release mint address',
    );
  }

  return PublicationWorkflowResult(
    ingestionSessionId:
        _firstNonEmpty(
          publicationSession.ingestionSessionId,
          normalizedBundle.ingestionSessionId,
        ) ??
        '',
    publicationSessionId: publicationSession.id,
    releaseId: normalizedBundle.releaseId,
    releaseMintAddress: releaseMintAddress,
    collectionMintAddress: normalizedBundle.signerAuthority.appMintAddress,
    releaseTransactionSignature: state.releaseTransactionSignature,
    collectionTransactionSignature: state.collectionTransactionSignature,
    attestationRequestUniqueId:
        state.attestation?.requestUniqueId ??
        publicationSession.attestationRequestUniqueId,
    hubspotTicketId: state.hubspotTicketId,
    bundle: normalizedBundle,
    session: publicationSession,
  );
}

String? _firstNonEmpty(String? value, String? other) =>
    value != null && value.isNotEmpty
    ? value
    : (other != null && other.isNotEmpty ? other : null);

final class _PublicationExecutionContext {
  const _PublicationExecutionContext({
    required this.client,
    required this.bundle,
    required this.signer,
    required this.attestationClient,
    required this.publicationSession,
    required this.logger,
    required this.releaseMetadataUri,
    required this.publisherAddress,
    required this.payerAddress,
  });

  final PublicationWorkflowClient client;
  final PublicationBundle bundle;
  final PublicationSigner signer;
  final PublicationAttestationClient attestationClient;
  final PublicationSession publicationSession;
  final WorkflowLogger? logger;
  final String releaseMetadataUri;
  final String publisherAddress;
  final String payerAddress;
}

final class _PublicationExecutionState {
  _PublicationExecutionState({
    this.releaseTransactionSignature,
    this.collectionTransactionSignature,
    this.hubspotTicketId,
    this.releaseMintAddress,
  }) : attestation = null;

  String? releaseTransactionSignature;
  String? collectionTransactionSignature;
  PublicationAttestation? attestation;
  String? hubspotTicketId;
  String? releaseMintAddress;
}

Future<void> _submitReleaseMintIfNeeded(
  _PublicationExecutionContext context,
  _PublicationExecutionState state,
) async {
  if (checkpointAtLeast(
    context.publicationSession.checkpoint,
    PublicationCheckpoint.mintSubmitted,
  )) {
    return;
  }

  context.logger?.call(
    'Preparing release NFT transaction',
    step: 'mint.prepare',
    status: 'running',
  );

  final preparedReleaseTransaction = await context.client
      .prepareReleaseNftTransaction(
        PrepareReleaseNftTransactionInput(
          releaseId: context.bundle.releaseId,
          releaseName: resolveReleaseDisplayName(context.bundle),
          releaseMetadataUri: context.releaseMetadataUri,
          appMintAddress: context.bundle.signerAuthority.appMintAddress,
          publisherAddress: context.publisherAddress,
          payerAddress: context.payerAddress,
        ),
      );

  state
    ..releaseMintAddress = preparedReleaseTransaction.mintAddress
    ..releaseTransactionSignature = await signPreparedTransaction(
      context.signer,
      preparedReleaseTransaction.transaction,
      ReleaseMintValidation(
        expectedBlockhash: preparedReleaseTransaction.blockhash,
        expectedFeePayerAddress: context.payerAddress,
        expectedSignerAddress: context.publisherAddress,
        expectedMintAddress: preparedReleaseTransaction.mintAddress,
        expectedAppMintAddress: context.bundle.signerAuthority.appMintAddress,
      ),
    );

  final signedTransactionResult = await context.client.submitSignedTransaction(
    signedTransaction: state.releaseTransactionSignature!,
    publicationSessionId: context.publicationSession.id,
  );

  state.releaseTransactionSignature =
      signedTransactionResult.transactionSignature;

  context.logger?.call(
    'Release NFT transaction submitted',
    step: 'mint.submit',
    status: 'complete',
  );
}

Future<void> _saveReleaseMintIfNeeded(
  _PublicationExecutionContext context,
  _PublicationExecutionState state,
) async {
  if (checkpointAtLeast(
    context.publicationSession.checkpoint,
    PublicationCheckpoint.mintSaved,
  )) {
    return;
  }

  final mintAddress =
      _firstNonEmpty(
        context.publicationSession.releaseMintAddress,
        context.bundle.release.releaseMintAddress,
      ) ??
      state.releaseMintAddress;

  if (mintAddress == null || mintAddress.isEmpty) {
    throw const PublisherCliException(
      'Publication bundle did not include a release mint address',
    );
  }
  if (state.releaseTransactionSignature == null) {
    throw const PublisherCliException(
      'Release transaction signature is missing',
    );
  }

  context.logger?.call(
    'Saving release NFT data',
    step: 'mint.save',
    status: 'running',
  );

  await context.client.saveReleaseNftData(
    SaveReleaseNftDataInput(
      releaseId: context.bundle.releaseId,
      mintAddress: mintAddress,
      transactionSignature: state.releaseTransactionSignature!,
      metadataUri: context.releaseMetadataUri,
      ownerAddress: context.publisherAddress,
      releaseName: resolveReleaseDisplayName(context.bundle),
      releaseVersion: context.bundle.release.versionName,
      androidPackage: context.bundle.release.androidPackage,
      appMintAddress: context.bundle.signerAuthority.appMintAddress,
    ),
  );

  state.releaseMintAddress = mintAddress;

  context.logger?.call(
    'Release NFT data saved',
    step: 'mint.save',
    status: 'complete',
  );
}

Future<void> _verifyReleaseCollectionIfNeeded(
  _PublicationExecutionContext context,
  _PublicationExecutionState state,
) async {
  if (checkpointAtLeast(
    context.publicationSession.checkpoint,
    PublicationCheckpoint.verificationSubmitted,
  )) {
    return;
  }

  if (state.releaseMintAddress == null || state.releaseMintAddress!.isEmpty) {
    throw const PublisherCliException(
      'Publication bundle did not include a release mint address for collection verification',
    );
  }

  context.logger?.call(
    'Preparing collection verification transaction',
    step: 'verify.prepare',
    status: 'running',
  );

  final preparedVerifyTransaction = await context.client
      .prepareVerifyCollectionTransaction(
        PrepareVerifyCollectionTransactionInput(
          dappId: context.bundle.signerAuthority.dappId,
          nftMintAddress: state.releaseMintAddress!,
          collectionMintAddress: context.bundle.signerAuthority.appMintAddress,
          collectionAuthority:
              context.bundle.signerAuthority.collectionAuthority,
          payerAddress: context.payerAddress,
        ),
      );

  state.collectionTransactionSignature = await signPreparedTransaction(
    context.signer,
    preparedVerifyTransaction.transaction,
    VerifyCollectionValidation(
      expectedBlockhash: preparedVerifyTransaction.blockhash,
      expectedFeePayerAddress: context.payerAddress,
      expectedSignerAddress: context.publisherAddress,
      expectedNftMintAddress: state.releaseMintAddress!,
      expectedCollectionMintAddress:
          context.bundle.signerAuthority.appMintAddress,
      expectedCollectionAuthority:
          context.bundle.signerAuthority.collectionAuthority,
    ),
  );

  context.logger?.call(
    'Submitting collection verification transaction',
    step: 'verify.submit',
    status: 'running',
  );

  final signedVerifyTransactionResult = await context.client
      .submitSignedTransaction(
        signedTransaction: state.collectionTransactionSignature!,
        publicationSessionId: context.publicationSession.id,
      );

  state.collectionTransactionSignature =
      signedVerifyTransactionResult.transactionSignature;

  await context.client.markReleaseCollectionAsVerified(
    releaseId: context.bundle.releaseId,
  );

  context.logger?.call(
    'Release collection verified',
    step: 'verify.submit',
    status: 'complete',
  );
}

Future<void> _attestAndSubmitIfNeeded(
  _PublicationExecutionContext context,
  _PublicationExecutionState state,
) async {
  if (checkpointAtLeast(
    context.publicationSession.checkpoint,
    PublicationCheckpoint.submitted,
  )) {
    return;
  }

  context.logger?.call(
    'Creating attestation payload',
    step: 'attestation.create',
    status: 'running',
  );

  state.attestation = await createAttestationPayloadFromClient(
    context.attestationClient,
    context.signer,
  );

  context.logger?.call(
    'Attestation payload created',
    step: 'attestation.create',
    status: 'complete',
  );

  context.logger?.call(
    'Submitting release to store',
    step: 'submit.store',
    status: 'running',
  );

  final submissionResult = await context.client.submitToStore(
    SubmitToStoreInput(
      releaseId: context.bundle.releaseId,
      whatsNew: context.bundle.release.newInVersion,
      criticalUpdate: false,
      attestationPayload: state.attestation!.payload,
      requestUniqueId: state.attestation!.requestUniqueId,
    ),
  );

  state.hubspotTicketId =
      submissionResult.hubspotTicketId ?? state.hubspotTicketId;

  context.logger?.call(
    'Release submitted to store',
    step: 'submit.store',
    status: 'complete',
  );
}
