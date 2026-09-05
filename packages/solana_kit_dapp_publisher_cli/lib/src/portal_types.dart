/// Small helpers for reading values out of untyped portal JSON payloads.
///
/// The portal backend returns loosely-shaped JSON; these accessors mirror the
/// upstream TypeScript translators so that unknown or missing fields degrade
/// exactly the same way.
library;

import 'package:solana_kit_dapp_publisher_cli/src/files.dart';

/// Returns the first value found at any of the [paths] as a string, or null.
String? firstString(Map<String, Object?> map, List<String> paths) {
  for (final path in paths) {
    var current = map;
    final segments = path.split('.');
    for (var i = 0; i < segments.length; i++) {
      final value = current[segments[i]];
      if (i == segments.length - 1) {
        if (value is String) {
          return value;
        }
        break;
      }
      if (value is Map<String, Object?>) {
        current = value;
      } else {
        break;
      }
    }
  }
  return null;
}

/// Coerces a value to a string the same way the upstream CLI does
/// (`String(value || '')`).
String asString(Object? value) {
  if (value == null || value == false) {
    return '';
  }
  if (value is num && value == 0) {
    return '';
  }
  final stringValue = value.toString();
  return stringValue == 'null' ? '' : stringValue;
}

/// Returns [value] when it is a string, otherwise null.
String? optionalString(Object? value) => value is String ? value : null;

/// Returns the list contents when [value] is a list, filtered to strings.
List<String> stringArray(Object? value) => [
  if (value is List) ...[
    for (final item in value)
      if (item is String) item,
  ],
];

/// Returns [value] when it is a finite number, otherwise [fallback].
num numberOrDefault(Object? value, num fallback) {
  if (value is num && value.isFinite) {
    return value;
  }
  return fallback;
}

/// Returns [value] when it is a JSON record, otherwise an empty map.
Map<String, Object?> asRecord(Object? value) =>
    value is Map<String, Object?> ? value : <String, Object?>{};

/// Returns true when [value] is a JSON object.
bool isRecord(Object? value) => value is Map<String, Object?>;

/// Reads a nested value from [map] using a dotted [path].
Object? readDeep(Map<String, Object?> map, String path) {
  var current = map;
  final segments = path.split('.');
  for (var i = 0; i < segments.length; i++) {
    final value = current[segments[i]];
    if (i == segments.length - 1) {
      return value;
    }
    if (value is Map<String, Object?>) {
      current = value;
    } else {
      return null;
    }
  }
  return null;
}

/// The portal-side kind of an ingestion source.
enum PortalSourceKind {
  /// The APK lives on portal-managed storage.
  portalUpload,

  /// The APK is hosted at an external HTTPS URL.
  externalUrl,
}

/// A source of APK bytes for a publication.
sealed class PublicationSource {
  const PublicationSource();
}

/// An APK uploaded from a local file path.
final class ApkFileSource extends PublicationSource {
  /// Creates a local APK source.
  const ApkFileSource({
    required this.filePath,
    required this.fileName,
    this.mimeType,
    this.size,
    this.sha256,
  });

  /// Resolved absolute file path.
  final String filePath;

  /// Upload file name (always ends in `.apk`).
  final String fileName;

  /// Optional content type override.
  final String? mimeType;

  /// Optional known file size override.
  final num? size;

  /// Optional known SHA-256 override.
  final String? sha256;
}

/// An APK hosted at an external HTTPS URL.
final class ApkUrlSource extends PublicationSource {
  /// Creates an external URL source.
  const ApkUrlSource({required this.url, this.fileName});

  /// The HTTPS URL of the APK.
  final String url;

  /// Optional file name inferred from the URL.
  final String? fileName;
}

/// An already-uploaded APK on portal storage.
final class PortalUploadSource extends PublicationSource {
  /// Creates a portal upload source.
  const PortalUploadSource({
    required this.releaseFileUrl,
    required this.releaseFileName,
    required this.releaseFileSize,
    this.releaseFileHash,
    this.contentType,
  });

  /// Public URL of the uploaded release file.
  final String releaseFileUrl;

  /// Release file name.
  final String releaseFileName;

  /// Release file size in bytes.
  final num releaseFileSize;

  /// SHA-256 of the release file.
  final String? releaseFileHash;

  /// Content type of the release file.
  final String? contentType;
}

/// An existing release reused as the source for a new publication.
final class ExistingReleaseSource extends PublicationSource {
  /// Creates an existing-release source.
  const ExistingReleaseSource({required this.sourceReleaseId});

  /// The release identifier to reuse.
  final String sourceReleaseId;
}

/// The on-disk or remote install file for a release.
final class InstallFileDetails {
  /// Creates install file details.
  const InstallFileDetails({
    required this.uri,
    required this.mimeType,
    required this.size,
    required this.sha256,
    required this.fileName,
    required this.canonicalUrl,
    required this.url,
    required this.origin,
  });

  /// Parses install file details from a backend bundle release record.
  factory InstallFileDetails.fromBackend(
    Map<String, Object?> release,
    Map<String, Object?> installFile,
    PortalSourceKind origin,
  ) {
    final url = asString(
      optionalString(installFile['uri']) ??
          optionalString(release['releaseFileUrl']) ??
          '',
    );
    final fileName =
        optionalString(release['releaseFileName']) ?? inferFileNameFromUrl(url);
    final mimeType =
        optionalString(installFile['mimeType']) ?? inferMimeType(fileName);
    return InstallFileDetails(
      uri: url,
      mimeType: mimeType,
      size: numberOrDefault(installFile['size'], 0),
      sha256: optionalString(installFile['sha256']),
      fileName: fileName,
      canonicalUrl: optionalString(installFile['canonicalUrl']) ?? url,
      url: url,
      origin: origin,
    );
  }

  /// The install file URL.
  final String uri;

  /// The MIME type.
  final String mimeType;

  /// The size in bytes.
  final num size;

  /// The SHA-256 hash, when known.
  final String? sha256;

  /// The inferred file name.
  final String? fileName;

  /// The canonical URL.
  final String canonicalUrl;

  /// The URL alias of [uri].
  final String url;

  /// Where the file originates from.
  final PortalSourceKind origin;
}

/// The upload target returned by the portal for a presigned upload.
final class PortalUploadTarget {
  /// Creates an upload target.
  const PortalUploadTarget({required this.uploadUrl, required this.publicUrl});

  /// Parses an upload target from a portal response.
  factory PortalUploadTarget.fromMap(Map<String, Object?> map) {
    return PortalUploadTarget(
      uploadUrl: asString(map['uploadUrl']),
      publicUrl: asString(map['publicUrl']),
    );
  }

  /// Presigned URL to PUT the file bytes to.
  final String uploadUrl;

  /// Public URL that the file will be served from.
  final String publicUrl;
}

/// Inputs for requesting a portal upload target.
final class CreateUploadTargetInput {
  /// Creates the input.
  const CreateUploadTargetInput({
    required this.fileHash,
    required this.fileExtension,
    required this.contentType,
  });

  /// SHA-256 of the file to upload, as lowercase hex.
  final String fileHash;

  /// File extension without a leading dot.
  final String fileExtension;

  /// Content type for the upload.
  final String contentType;

  /// Serializes the input for the portal procedure call.
  Map<String, Object?> toMap() => {
    'fileHash': fileHash,
    'fileExtension': fileExtension,
    'contentType': contentType,
  };
}

/// A prepared release NFT transaction from the portal.
final class PreparedReleaseTransaction {
  /// Creates a prepared transaction.
  const PreparedReleaseTransaction({
    required this.transaction,
    required this.mintAddress,
    required this.blockhash,
  });

  /// Parses a prepared transaction from a portal response.
  factory PreparedReleaseTransaction.fromMap(Map<String, Object?> map) {
    return PreparedReleaseTransaction(
      transaction: asString(map['transaction']),
      mintAddress: asString(map['mintAddress']),
      blockhash: asString(map['blockhash']),
    );
  }

  /// Base64-encoded legacy transaction.
  final String transaction;

  /// The release mint address.
  final String mintAddress;

  /// The recent blockhash the transaction was built with.
  final String blockhash;
}

/// A prepared collection verification transaction from the portal.
final class PreparedVerifyCollectionTransaction {
  /// Creates a prepared transaction.
  const PreparedVerifyCollectionTransaction({
    required this.transaction,
    required this.blockhash,
  });

  /// Parses a prepared transaction from a portal response.
  factory PreparedVerifyCollectionTransaction.fromMap(
    Map<String, Object?> map,
  ) {
    return PreparedVerifyCollectionTransaction(
      transaction: asString(map['transaction']),
      blockhash: asString(map['blockhash']),
    );
  }

  /// Base64-encoded legacy transaction.
  final String transaction;

  /// The recent blockhash the transaction was built with.
  final String blockhash;
}

/// Result of submitting a signed transaction through the portal.
final class SubmitSignedTransactionResult {
  /// Creates the result.
  const SubmitSignedTransactionResult({required this.transactionSignature});

  /// Parses the submission result from a portal response.
  factory SubmitSignedTransactionResult.fromMap(Map<String, Object?> map) {
    return SubmitSignedTransactionResult(
      transactionSignature: asString(map['transactionSignature']),
    );
  }

  /// The signature of the submitted transaction.
  final String transactionSignature;
}

/// Result of saving release NFT data with the portal.
final class SaveReleaseNftDataResult {
  /// Creates the result.
  const SaveReleaseNftDataResult({required this.success});

  /// Parses the result from a portal response.
  factory SaveReleaseNftDataResult.fromMap(Map<String, Object?> map) {
    return SaveReleaseNftDataResult(success: map['success'] == true);
  }

  /// Whether the portal accepted the release data.
  final bool success;
}

/// Result of marking a release collection as verified.
final class MarkReleaseCollectionAsVerifiedResult {
  /// Creates the result.
  const MarkReleaseCollectionAsVerifiedResult({
    required this.success,
    required this.releaseId,
  });

  /// Parses the result from a portal response.
  factory MarkReleaseCollectionAsVerifiedResult.fromMap(
    Map<String, Object?> map,
  ) {
    return MarkReleaseCollectionAsVerifiedResult(
      success: map['success'] == true,
      releaseId: asString(map['releaseId']),
    );
  }

  /// Whether the portal accepted the verification.
  final bool success;

  /// The release identifier.
  final String releaseId;
}

/// Result of the `publication.cleanupRelease` mutation.
final class CleanupReleaseResult {
  /// Creates the result.
  const CleanupReleaseResult({required this.action});

  /// Parses the cleanup result from a portal response.
  factory CleanupReleaseResult.fromMap(Map<String, Object?> map) {
    return CleanupReleaseResult(action: asString(map['action']));
  }

  /// The action taken by the portal (`deleted` or `preservedSubmitted`).
  final String action;
}

/// Result of submitting a release to the store.
final class SubmitToStoreResult {
  /// Creates the result.
  const SubmitToStoreResult({this.hubspotTicketId});

  /// Parses the submission result from a portal response.
  factory SubmitToStoreResult.fromMap(Map<String, Object?> map) {
    return SubmitToStoreResult(
      hubspotTicketId: optionalString(map['hubspotTicketId']),
    );
  }

  /// The HubSpot ticket identifier assigned to the submission, when present.
  final String? hubspotTicketId;
}

/// Inputs for `publication.submitToStore`.
final class SubmitToStoreInput {
  /// Creates the input.
  const SubmitToStoreInput({
    required this.releaseId,
    required this.whatsNew,
    required this.criticalUpdate,
    required this.attestationPayload,
    required this.requestUniqueId,
    this.testingInstructions,
    this.isResubmission,
  });

  /// The release identifier.
  final String releaseId;

  /// What changed in this version.
  final String whatsNew;

  /// Whether this is a critical update.
  final bool criticalUpdate;

  /// Optional testing instructions for reviewers.
  final String? testingInstructions;

  /// Whether this is a resubmission.
  final bool? isResubmission;

  /// The signed attestation payload (base64).
  final String attestationPayload;

  /// The unique request identifier from the attestation.
  final String requestUniqueId;

  /// Serializes the input for the portal procedure call.
  Map<String, Object?> toMap() => {
    'releaseId': releaseId,
    'whatsNew': whatsNew,
    'criticalUpdate': criticalUpdate,
    if (testingInstructions != null) 'testingInstructions': testingInstructions,
    if (isResubmission != null) 'isResubmission': isResubmission,
    'attestation': {
      'payload': attestationPayload,
      'requestUniqueId': requestUniqueId,
    },
  };
}

/// The signed attestation payload returned by the attestation builder.
final class PublicationAttestation {
  /// Creates the attestation payload.
  const PublicationAttestation({
    required this.payload,
    required this.attestationPayload,
    required this.requestUniqueId,
    required this.slotNumber,
    required this.blockhash,
  });

  /// Base64 of signature + attestation JSON bytes.
  final String payload;

  /// Alias of [payload] retained for parity with the upstream API.
  final String attestationPayload;

  /// The unique request identifier embedded in the attestation.
  final String requestUniqueId;

  /// The slot number used in the attestation.
  final num slotNumber;

  /// The blockhash used in the attestation.
  final String blockhash;
}
