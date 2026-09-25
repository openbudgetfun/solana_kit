import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'package:solana_kit_dapp_publisher_cli/src/files.dart';
import 'package:solana_kit_dapp_publisher_cli/src/portal_client.dart';
import 'package:solana_kit_dapp_publisher_cli/src/portal_translators.dart';
import 'package:solana_kit_dapp_publisher_cli/src/portal_types.dart';
import 'package:solana_kit_dapp_publisher_cli/src/publication_models.dart';
import 'package:solana_kit_dapp_publisher_cli/src/release_metadata.dart';
import 'package:solana_kit_dapp_publisher_cli/src/workflow_client.dart';

/// Creates the portal-backed workflow client used by the CLI.
PublicationWorkflowClient createPortalWorkflowClient(
  PortalClientConfig config,
) => PortalWorkflowClient(config);

/// Creates the portal-backed attestation client used by the CLI.
PublicationAttestationClient createPortalAttestationClient(
  PortalClientConfig config,
) => PortalAttestationClient(config).getBlockData;

/// The portal-backed publication workflow client.
final class PortalWorkflowClient implements PublicationWorkflowClient {
  /// Creates a portal workflow client from [config].
  PortalWorkflowClient(this.config) : _client = config.client;

  /// The portal configuration.
  final PortalClientConfig config;

  final http.Client? _client;

  String? _currentPublicationSessionId;
  String? _currentReleaseId;
  final Map<String, String> _metadataUriByReleaseId = {};
  final Map<String, String> _publicationSessionIdByReleaseId = {};

  void _trackBackendIdentifiers(Map<String, Object?> backendResult) {
    final releaseId = optionalString(backendResult['releaseId']);
    if (releaseId != null && releaseId.isNotEmpty) {
      _currentReleaseId = releaseId;
    }
    final publicationSessionId = optionalString(
      backendResult['publicationSessionId'],
    );
    if (publicationSessionId != null && publicationSessionId.isNotEmpty) {
      _currentPublicationSessionId = publicationSessionId;
    }
    _rememberLinkedPublicationSession(
      _currentReleaseId,
      _currentPublicationSessionId,
    );
  }

  void _trackTranslatedIngestionSession(PublicationIngestionSession session) {
    _rememberLinkedPublicationSession(
      session.releaseId,
      session.publicationSessionId,
    );
    if (session.publicationSessionId != null &&
        session.publicationSessionId!.isNotEmpty) {
      _currentPublicationSessionId = session.publicationSessionId;
    } else if (session.publicationSession != null) {
      _currentPublicationSessionId = session.publicationSession!.id;
    }
    if (session.releaseId != null && session.releaseId!.isNotEmpty) {
      _currentReleaseId = session.releaseId;
    }
  }

  void _rememberLinkedPublicationSession(
    String? releaseId,
    String? publicationSessionId,
  ) {
    if (releaseId != null &&
        releaseId.isNotEmpty &&
        publicationSessionId != null &&
        publicationSessionId.isNotEmpty) {
      _publicationSessionIdByReleaseId[releaseId] = publicationSessionId;
    }
  }

  Future<Map<String, Object?>> _call(
    String procedure,
    Object? input,
    String method, {
    http.Client? client,
  }) => callPortalProcedure<Map<String, Object?>>(
    config,
    procedure,
    input,
    method,
    client: client ?? _client,
  );

  @override
  Future<PortalUploadTarget> createUploadTarget(
    CreateUploadTargetInput input,
  ) async {
    final result = await _call(
      'publication.createUploadTarget',
      input.toMap(),
      'mutation',
    );
    return PortalUploadTarget.fromMap(result);
  }

  @override
  Future<PublicationIngestionSession> createIngestionSession(
    CreateIngestionSessionInput input,
  ) async {
    final backendResult = await callCreateIngestionSessionWithRetry(
      config,
      input.toMap(),
      client: _client,
    );
    _trackBackendIdentifiers(backendResult);
    return _translateIngestionBackendResult(backendResult);
  }

  @override
  Future<PublicationIngestionSession> getIngestionSession({
    required String sessionId,
  }) async {
    final backendResult = await _call(
      'publication.getIngestionSession',
      {'sessionId': sessionId},
      'query',
    );
    _trackBackendIdentifiers(backendResult);
    return _translateIngestionBackendResult(backendResult);
  }

  PublicationIngestionSession _translateIngestionBackendResult(
    Map<String, Object?> backendResult,
  ) {
    final translated = translateBackendIngestionSession(
      backendResult,
      bundle: asRecord(backendResult['bundle']),
      publicationSession: asRecord(backendResult['publicationSession']),
    );
    _trackTranslatedIngestionSession(translated);
    return translated;
  }

  @override
  Future<PublicationBundle> getPublicationBundle({
    required String releaseId,
  }) async {
    final backendBundle = await _call(
      'publication.getPublicationBundle',
      {'releaseId': releaseId},
      'query',
    );

    final linkedPublicationSessionId =
        _publicationSessionIdByReleaseId[releaseId] ??
        _currentPublicationSessionId;
    final linkedPublicationSession = linkedPublicationSessionId == null
        ? null
        : translateBackendPublicationSession(
            await _call(
              'publication.getPublicationSession',
              {
                'publicationSessionId': linkedPublicationSessionId,
                'releaseId': releaseId,
              },
              'query',
            ),
          );

    final cachedMetadataUri = _metadataUriByReleaseId[releaseId];
    final backendMetadataUri = asRecord(
      backendBundle['release'],
    )['nftMetadataUri'];
    final releaseMetadataUri =
        cachedMetadataUri ??
        ((backendMetadataUri is String && backendMetadataUri.isNotEmpty)
            ? backendMetadataUri
            : await _uploadReleaseMetadata(
                mapBackendBundleToPublicationBundle(
                  backendBundle,
                  '',
                  PortalSourceKind.portalUpload,
                ),
              ));

    _metadataUriByReleaseId[releaseId] = releaseMetadataUri;

    final sourceKind =
        (_currentReleaseId != null &&
            _publicationSessionIdByReleaseId.containsKey(_currentReleaseId))
        ? PortalSourceKind.portalUpload
        : PortalSourceKind.externalUrl;

    var translated = mapBackendBundleToPublicationBundle(
      backendBundle,
      releaseMetadataUri,
      sourceKind,
    );
    final resolvedPublicationSessionId =
        _firstNonEmpty(
          translated.publicationSessionId,
          linkedPublicationSession?.id,
          linkedPublicationSessionId,
          _publicationSessionIdByReleaseId[releaseId],
          _currentPublicationSessionId,
        ) ??
        '';
    translated = PublicationBundle(
      ingestionSessionId: translated.ingestionSessionId,
      publicationSessionId: resolvedPublicationSessionId,
      releaseId: translated.releaseId,
      dapp: translated.dapp,
      publisher: translated.publisher,
      installFile: translated.installFile,
      metadata: BundleMetadata(
        localizedName: translated.metadata.localizedName,
        shortDescription: translated.metadata.shortDescription,
        longDescription: translated.metadata.longDescription,
        newInVersion: translated.metadata.newInVersion,
        publisherWebsite: translated.metadata.publisherWebsite,
        supportEmail: translated.metadata.supportEmail,
        website: translated.metadata.website,
        locales: translated.metadata.locales,
        legal: translated.metadata.legal,
        media: translated.metadata.media,
        installFile: translated.metadata.installFile,
        localizedStrings: translated.metadata.localizedStrings,
        releaseMetadataUri: releaseMetadataUri,
      ),
      signerAuthority: translated.signerAuthority,
      release: translated.release,
    );

    _currentReleaseId = translated.releaseId;
    _currentPublicationSessionId = resolvedPublicationSessionId;
    _rememberLinkedPublicationSession(
      translated.releaseId,
      translated.publicationSessionId,
    );

    return translated;
  }

  Future<String> _uploadReleaseMetadata(PublicationBundle bundle) async {
    final releaseId = bundle.releaseId;
    final cached = _metadataUriByReleaseId[releaseId];
    if (cached != null) {
      return cached;
    }

    final bundleReleaseMetadataUri = bundle.release.releaseMetadataUri;
    if (bundleReleaseMetadataUri != null &&
        bundleReleaseMetadataUri.isNotEmpty) {
      _metadataUriByReleaseId[releaseId] = bundleReleaseMetadataUri;
      return bundleReleaseMetadataUri;
    }

    final metadataClient = _ReleaseMetadataPortalClient(this);
    final sourceKind =
        bundle.metadata.installFile.origin == PortalSourceKind.externalUrl
        ? PortalSourceKind.externalUrl
        : PortalSourceKind.portalUpload;
    final metadataDocument = await buildReleaseMetadataDocument(
      metadataClient,
      bundle,
      sourceKind,
      uploadClient: _client,
    );
    metadataDocument.remove('__origin');

    final metadataBytes = utf8Encode(jsonEncodeDocument(metadataDocument));
    final fileHash = sha256Hex(metadataBytes);
    final uploadTarget = await createUploadTarget(
      CreateUploadTargetInput(
        fileHash: fileHash,
        fileExtension: 'json',
        contentType: 'application/json',
      ),
    );

    await uploadBytes(
      uploadTarget.uploadUrl,
      metadataBytes,
      'application/json',
      client: _client,
    );

    _metadataUriByReleaseId[releaseId] = uploadTarget.publicUrl;
    return uploadTarget.publicUrl;
  }

  @override
  Future<PublicationSession> getPublicationSession({
    String? publicationSessionId,
    String? releaseId,
  }) async {
    final backendResult = await _call(
      'publication.getPublicationSession',
      {
        'publicationSessionId':
            publicationSessionId ??
            (releaseId == null
                ? null
                : _publicationSessionIdByReleaseId[releaseId]),
        'releaseId': releaseId,
      },
      'query',
    );

    final translated = translateBackendPublicationSession(backendResult);
    _currentPublicationSessionId = translated.id;
    _currentReleaseId = translated.releaseId;
    _rememberLinkedPublicationSession(translated.releaseId, translated.id);
    return translated;
  }

  @override
  Future<PreparedReleaseTransaction> prepareReleaseNftTransaction(
    PrepareReleaseNftTransactionInput input,
  ) async {
    final result = await _call(
      'publication.prepareReleaseNftTransaction',
      input.toMap(),
      'mutation',
    );
    return PreparedReleaseTransaction.fromMap(result);
  }

  @override
  Future<SubmitSignedTransactionResult> submitSignedTransaction({
    required String signedTransaction,
    String? publicationSessionId,
  }) async {
    final result = await _call(
      'publication.submitSignedTransaction',
      {
        'signedTransaction': signedTransaction,
        'publicationSessionId':
            publicationSessionId ?? _currentPublicationSessionId,
      },
      'mutation',
    );
    return SubmitSignedTransactionResult.fromMap(result);
  }

  @override
  Future<SaveReleaseNftDataResult> saveReleaseNftData(
    SaveReleaseNftDataInput input,
  ) async {
    final result = await _call(
      'publication.saveReleaseNftData',
      input.toMap(),
      'mutation',
    );
    return SaveReleaseNftDataResult.fromMap(result);
  }

  @override
  Future<PreparedVerifyCollectionTransaction>
  prepareVerifyCollectionTransaction(
    PrepareVerifyCollectionTransactionInput input,
  ) async {
    final result = await _call(
      'publication.prepareVerifyCollectionTransaction',
      input.toMap(),
      'mutation',
    );
    return PreparedVerifyCollectionTransaction.fromMap(result);
  }

  @override
  Future<MarkReleaseCollectionAsVerifiedResult>
  markReleaseCollectionAsVerified({
    required String releaseId,
  }) async {
    final result = await _call(
      'publication.markReleaseCollectionAsVerified',
      {'releaseId': releaseId},
      'mutation',
    );
    return MarkReleaseCollectionAsVerifiedResult.fromMap(result);
  }

  @override
  Future<CleanupReleaseResult> cleanupRelease(CleanupReleaseInput input) async {
    final result = await _call(
      'publication.cleanupRelease',
      input.toMap(),
      'mutation',
    );
    return CleanupReleaseResult.fromMap(result);
  }

  @override
  Future<SubmitToStoreResult> submitToStore(SubmitToStoreInput input) async {
    final result = await _call(
      'publication.submitToStore',
      input.toMap(),
      'mutation',
    );
    return SubmitToStoreResult.fromMap(result);
  }
}

String? _firstNonEmpty(
  String? value, [
  String? other,
  String? third,
  String? fourth,
  String? fifth,
]) {
  for (final candidate in [value, other, third, fourth, fifth]) {
    if (candidate != null && candidate.isNotEmpty) {
      return candidate;
    }
  }
  return null;
}

final class _ReleaseMetadataPortalClient
    implements ReleaseMetadataPortalClient {
  _ReleaseMetadataPortalClient(this._parent);

  final PortalWorkflowClient _parent;

  @override
  Future<PortalUploadTarget> createUploadTarget(
    CreateUploadTargetInput input,
  ) => _parent.createUploadTarget(input);

  @override
  Future<RemoteFilePayload> fetchRemoteFile({
    required String url,
    String? fileName,
    String? expectedMimeType,
  }) async {
    final result = await callPortalProcedure<Map<String, Object?>>(
      _parent.config,
      'fetchRemoteFile',
      {
        'url': url,
        'fileName': ?fileName,
        'expectedMimeType': ?expectedMimeType,
      },
      'query',
      client: _parent._client,
    );
    return RemoteFilePayload(
      data: asString(result['data']),
      fileName: asString(result['fileName']),
      mimeType: asString(result['mimeType']),
    );
  }
}

/// UTF-8 encodes a JSON string.
Uint8List utf8Encode(String value) => Uint8List.fromList(utf8.encode(value));

/// Serializes [document] to JSON.
String jsonEncodeDocument(Map<String, Object?> document) =>
    jsonEncode(document);
