import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'package:solana_kit_dapp_publisher_cli/src/errors.dart';
import 'package:solana_kit_dapp_publisher_cli/src/files.dart';
import 'package:solana_kit_dapp_publisher_cli/src/portal_client.dart';
import 'package:solana_kit_dapp_publisher_cli/src/portal_types.dart';
import 'package:solana_kit_dapp_publisher_cli/src/publication_models.dart';

/// The release NFT metadata schema version emitted by the CLI.
const nftSchemaVersion = '0.4.0';

/// The public R2 hosts that already serve portal-managed files.
const defaultR2PublicHosts = <String>[
  'r2.solanamobiledappstore.com',
  'r2-staging.solanamobiledappstore.com',
];

/// A media file fetched through the portal.
final class RemoteFilePayload {
  /// Creates the payload.
  const RemoteFilePayload({
    required this.data,
    required this.fileName,
    required this.mimeType,
  });

  /// Base64-encoded file bytes.
  final String data;

  /// The remote file name.
  final String fileName;

  /// The remote MIME type.
  final String mimeType;
}

/// Portal access used while building release metadata documents.
abstract interface class ReleaseMetadataPortalClient {
  /// Requests a presigned upload target.
  Future<PortalUploadTarget> createUploadTarget(CreateUploadTargetInput input);

  /// Fetches a remote file through the portal, returning base64 bytes.
  Future<RemoteFilePayload> fetchRemoteFile({
    required String url,
    String? fileName,
    String? expectedMimeType,
  });
}

/// The resolved media entry attached to a release metadata document.
final class ResolvedMediaItem {
  /// Creates the media item.
  const ResolvedMediaItem({
    required this.mime,
    required this.purpose,
    required this.uri,
    required this.width,
    required this.height,
    required this.sha256,
  });

  /// The resolved MIME type.
  final String mime;

  /// The media purpose (icon, screenshot, banner, featureGraphic).
  final String purpose;

  /// The public URI of the media file.
  final String uri;

  /// The media width in pixels.
  final int width;

  /// The media height in pixels.
  final int height;

  /// The SHA-256 of the media bytes.
  final String sha256;

  /// Serializes the media entry for the metadata document.
  Map<String, Object?> toMap() => {
    'mime': mime,
    'purpose': purpose,
    'width': width,
    'height': height,
    'sha256': sha256,
    'uri': uri,
  };
}

/// Builds the release NFT metadata document for [bundle].
///
/// [uploadClient] overrides the HTTP client used for raw media uploads.
Future<Map<String, Object?>> buildReleaseMetadataDocument(
  ReleaseMetadataPortalClient client,
  PublicationBundle bundle,
  PortalSourceKind sourceKind, {
  http.Client? uploadClient,
}) async {
  final releaseName = _normalizeReleaseName(
    _firstNonEmpty(
          bundle.metadata.localizedName,
          bundle.release.localizedName,
          bundle.release.releaseName,
          bundle.dapp.dappName,
        ) ??
        'Release update',
  );
  final shortDescription =
      _firstNonEmpty(
        bundle.metadata.shortDescription,
        bundle.release.shortDescription,
        bundle.dapp.subtitle,
      ) ??
      'Release NFT';
  final longDescription =
      _firstNonEmpty(
        bundle.metadata.longDescription,
        bundle.release.longDescription,
        bundle.dapp.description,
      ) ??
      shortDescription;
  final newInVersion = bundle.metadata.newInVersion;
  final publisherAddress =
      _firstNonEmpty(
        bundle.signerAuthority.dappWalletAddress,
        bundle.signerAuthority.collectionAuthority,
        bundle.dapp.walletAddress,
      ) ??
      '';
  final publisherName = bundle.publisher.name;
  final publisherWebsite = _normalizeOptionalUrl(
    _firstNonEmpty(
      bundle.metadata.publisherWebsite,
      bundle.publisher.website,
      bundle.dapp.appWebsite,
      bundle.dapp.website,
    ),
  );
  final publisherContact =
      _firstNonEmpty(
        bundle.publisher.email,
        bundle.dapp.contactEmail,
        bundle.dapp.supportEmail,
      ) ??
      '';
  final publisherSupportEmail =
      _firstNonEmpty(
        bundle.publisher.supportEmail,
        bundle.metadata.supportEmail,
        bundle.dapp.supportEmail,
        bundle.dapp.contactEmail,
        bundle.publisher.email,
      ) ??
      publisherContact;
  final iconUri = bundle.dapp.dappIconUrl ?? '';

  if (iconUri.isEmpty) {
    throw const PublisherCliException(
      'Publication bundle did not include a public app icon URL.',
    );
  }

  final installUri =
      _firstNonEmpty(
        bundle.installFile.uri,
        bundle.release.releaseFileUrl,
      ) ??
      '';
  final installMimeType = bundle.installFile.mimeType.isNotEmpty
      ? bundle.installFile.mimeType
      : inferMimeType(inferFileNameFromUrl(installUri));
  final installSize = bundle.installFile.size != 0
      ? bundle.installFile.size
      : bundle.release.releaseFileSize;
  final installSha256 =
      _firstNonEmpty(
        bundle.installFile.sha256,
        bundle.release.releaseFileHash,
      ) ??
      '';
  final androidPackage =
      _firstNonEmpty(
        bundle.release.androidPackage,
        bundle.dapp.androidPackage,
      ) ??
      '';
  final versionName = bundle.release.versionName;
  final versionCode = bundle.release.versionCode;
  final minSdkVersion = bundle.release.minSdkVersion ?? 1;
  final targetSdkVersion = bundle.release.targetSdkVersion;
  final certificateFingerprint = bundle.release.certificateFingerprint ?? '';
  final permissions = bundle.release.permissions;
  final locales = _firstNonEmptyList(
    bundle.release.locales,
    bundle.metadata.locales,
    bundle.dapp.languages,
    const ['en-US'],
  );
  final previewUris = bundle.dapp.dappPreviewUrls;
  final bannerUri = bundle.dapp.bannerUrl ?? '';
  final featureGraphicUri =
      _firstNonEmpty(
        bundle.dapp.editorsChoiceGraphicUrl,
        bundle.dapp.featureGraphicUrl,
      ) ??
      '';

  final media = <ResolvedMediaItem>[];
  final iconMedia = await _resolveMediaItem(
    client,
    defaultMimeType: 'image/png',
    fallbackFileName: 'release-icon.png',
    purpose: 'icon',
    uri: iconUri,
    uploadClient: uploadClient,
  );
  media.add(iconMedia);

  for (var index = 0; index < previewUris.length; index++) {
    media.add(
      await _resolveMediaItem(
        client,
        fallbackFileName: 'release-screenshot-${index + 1}',
        purpose: 'screenshot',
        uri: previewUris[index],
        uploadClient: uploadClient,
      ),
    );
  }

  if (bannerUri.isNotEmpty) {
    media.add(
      await _resolveMediaItem(
        client,
        defaultMimeType: inferMimeType(inferFileNameFromUrl(bannerUri)),
        fallbackFileName: 'release-banner.png',
        purpose: 'banner',
        uri: bannerUri,
        uploadClient: uploadClient,
      ),
    );
  }

  if (featureGraphicUri.isNotEmpty) {
    media.add(
      await _resolveMediaItem(
        client,
        defaultMimeType: inferMimeType(
          inferFileNameFromUrl(featureGraphicUri),
        ),
        fallbackFileName: 'release-feature-graphic.png',
        purpose: 'featureGraphic',
        uri: featureGraphicUri,
        uploadClient: uploadClient,
      ),
    );
  }

  final licenseUrl = _normalizeOptionalUrl(
    _firstNonEmpty(
      bundle.metadata.legal.licenseUrl,
      bundle.dapp.licenseUrl,
    ),
  );
  final copyrightUrl = _firstNonEmpty(
    bundle.metadata.legal.copyrightUrl,
    bundle.dapp.copyrightUrl,
  );
  final privacyPolicyUrl = _normalizeOptionalUrl(
    _firstNonEmpty(
      bundle.metadata.legal.privacyPolicyUrl,
      bundle.dapp.privacyPolicyUrl,
    ),
  );

  final document = <String, Object?>{
    'schema_version': nftSchemaVersion,
    'name': releaseName,
    'description': shortDescription,
    'image': iconMedia.uri,
    'external_url': ?publisherWebsite,
    'properties': {
      'category': 'dApp',
      'creators': [
        {'address': publisherAddress, 'share': 100},
      ],
    },
    'extensions': {
      'solana_dapp_store': {
        'publisher_details': {
          'name': publisherName,
          'website': ?publisherWebsite,
          'contact': publisherContact,
          'support_email': publisherSupportEmail,
        },
        'release_details': {
          'updated_on': DateTime.now().toUtc().toIso8601String(),
          'license_url': ?licenseUrl,
          'copyright_url': ?copyrightUrl,
          'privacy_policy_url': ?privacyPolicyUrl,
          'localized_resources': {
            'long_description': '1',
            'new_in_version': '2',
            'name': '4',
            'short_description': '5',
          },
        },
        'media': [for (final item in media) item.toMap()],
        'files': [
          {
            'mime': installMimeType,
            'purpose': 'install',
            'size': installSize,
            'sha256': installSha256,
            'uri': installUri,
          },
        ],
        'android_details': {
          'android_package': androidPackage,
          'version': versionName,
          'version_code': versionCode,
          'min_sdk': minSdkVersion,
          'target_sdk': ?targetSdkVersion,
          'cert_fingerprint': certificateFingerprint,
          'permissions': permissions,
          'locales': locales,
        },
      },
      'i18n': {
        'en-US': {
          '1': longDescription,
          '2': newInVersion,
          '4': releaseName,
          '5': shortDescription.substringSafe(0, 50),
        },
      },
    },
  };
  return document;
}

String? _normalizeOptionalUrl(String? value) {
  if (value == null) {
    return null;
  }
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    return null;
  }
  return ensureHttpsUrl(trimmed);
}

String _normalizeReleaseName(String value) {
  final trimmed = value.trim();
  return trimmed.length <= 32 ? trimmed : trimmed.substring(0, 32);
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

List<String> _firstNonEmptyList(
  List<String> first,
  List<String> second,
  List<String> third,
  List<String> fallback,
) {
  if (first.isNotEmpty) {
    return first;
  }
  if (second.isNotEmpty) {
    return second;
  }
  if (third.isNotEmpty) {
    return third;
  }
  return fallback;
}

/// Resolves a media item, re-hosting portal-external files on portal storage.
Future<ResolvedMediaItem> _resolveMediaItem(
  ReleaseMetadataPortalClient client, {
  required String purpose,
  required String uri,
  required String fallbackFileName,
  String? defaultMimeType,
  String? expectedMimeType,
  http.Client? uploadClient,
}) async {
  final resolvedUri = ensureHttpsUrl(uri);
  final isAlreadyPublicR2 = isR2PublicUrl(resolvedUri);

  final RemoteFilePayload remoteFile;
  try {
    remoteFile = await client.fetchRemoteFile(
      url: resolvedUri,
      fileName: fallbackFileName,
      expectedMimeType: expectedMimeType,
    );
  } on Object catch (error) {
    throw PublisherCliException(
      'Failed to fetch $purpose media from $resolvedUri: '
      '${_errorText(error)}',
    );
  }
  final fileBytes = base64DecodeBytes(remoteFile.data);

  if (fileBytes.isEmpty) {
    throw PublisherCliException(
      'Remote media file is empty: $resolvedUri',
    );
  }

  final remoteFileName = remoteFile.fileName.isNotEmpty
      ? remoteFile.fileName
      : fallbackFileName;
  final resolvedMimeType =
      normalizeMimeType(remoteFile.mimeType) ??
      defaultMimeType ??
      inferMimeType(remoteFileName);
  final fileHash = sha256Hex(fileBytes);
  final dimensions = getMediaDimensions(
    fileBytes,
    remoteFileName,
    resolvedMimeType,
  );

  if (isAlreadyPublicR2) {
    return ResolvedMediaItem(
      mime: resolvedMimeType,
      purpose: purpose,
      uri: resolvedUri,
      width: dimensions.$1,
      height: dimensions.$2,
      sha256: fileHash,
    );
  }

  final uploadTarget = await client.createUploadTarget(
    CreateUploadTargetInput(
      fileHash: fileHash,
      fileExtension: inferUploadFileExtension(
        remoteFileName,
        resolvedMimeType,
      ),
      contentType: resolvedMimeType,
    ),
  );

  if (uploadTarget.uploadUrl.isEmpty || uploadTarget.publicUrl.isEmpty) {
    throw PublisherCliException(
      'The portal did not return a valid upload target for $purpose.',
    );
  }

  await uploadBytes(
    uploadTarget.uploadUrl,
    fileBytes,
    resolvedMimeType,
    client: uploadClient,
  );

  return ResolvedMediaItem(
    mime: resolvedMimeType,
    purpose: purpose,
    uri: uploadTarget.publicUrl,
    width: dimensions.$1,
    height: dimensions.$2,
    sha256: fileHash,
  );
}

String _errorText(Object error) =>
    error is PublisherCliException ? error.message : error.toString();

/// Returns true when [url] points at a public portal R2 host.
bool isR2PublicUrl(String url) {
  final parsed = Uri.tryParse(url);
  if (parsed == null) {
    return false;
  }
  final hostname = parsed.host.toLowerCase();
  return defaultR2PublicHosts.contains(hostname);
}

/// Normalizes a MIME type by dropping parameters and lowercasing.
String? normalizeMimeType(String? value) {
  if (value == null) {
    return null;
  }
  final normalized = value.split(';').first.trim().toLowerCase();
  return normalized.isEmpty ? null : normalized;
}

/// Infers an upload file extension from the file name or MIME type.
String inferUploadFileExtension(String fileName, String mimeType) {
  final byName = fileName.contains('.')
      ? fileName.substring(fileName.lastIndexOf('.') + 1).trim().toLowerCase()
      : '';
  final isPlainExtension = byName.isNotEmpty && _isAlphanumeric(byName);
  if (isPlainExtension) {
    return byName;
  }
  return inferExtensionFromMimeType(mimeType) ?? 'bin';
}

bool _isAlphanumeric(String value) {
  for (var i = 0; i < value.length; i++) {
    final code = value.codeUnitAt(i);
    final isDigit = code >= 0x30 && code <= 0x39;
    final isLower = code >= 0x61 && code <= 0x7a;
    final isUpper = code >= 0x41 && code <= 0x5a;
    if (!isDigit && !isLower && !isUpper) {
      return false;
    }
  }
  return true;
}

/// Maps a MIME type to a canonical file extension.
String? inferExtensionFromMimeType(String mimeType) => switch (mimeType) {
  'image/png' => 'png',
  'image/jpeg' => 'jpg',
  'image/webp' => 'webp',
  'image/gif' => 'gif',
  'image/svg+xml' => 'svg',
  'video/mp4' => 'mp4',
  'video/webm' => 'webm',
  'video/quicktime' => 'mov',
  'application/json' => 'json',
  _ => _subtypeExtension(mimeType),
};

String? _subtypeExtension(String mimeType) {
  final parts = mimeType.split('/');
  if (parts.length < 2) {
    return null;
  }
  final subtype = parts[1].split('+').first.trim().toLowerCase();
  final cleaned = _stripNonAlphanumeric(subtype);
  return cleaned.isEmpty ? null : cleaned;
}

String _stripNonAlphanumeric(String value) {
  final buffer = StringBuffer();
  for (final code in value.codeUnits) {
    final isDigit = code >= 0x30 && code <= 0x39;
    final isLower = code >= 0x61 && code <= 0x7a;
    if (isDigit || isLower) {
      buffer.writeCharCode(code);
    }
  }
  return buffer.toString();
}

/// Reads media dimensions from [fileBytes], throwing a descriptive error when
/// the format is unsupported.
(int, int) getMediaDimensions(
  Uint8List fileBytes,
  String fileName,
  String mimeType,
) {
  final dimensions = readImageDimensions(fileBytes);
  if (dimensions == null || dimensions.$1 <= 0 || dimensions.$2 <= 0) {
    throw PublisherCliException(
      'Unable to determine media dimensions for $fileName',
    );
  }
  return dimensions;
}

/// Reads (width, height) from PNG, JPEG, GIF, or WebP bytes.
(int, int)? readImageDimensions(Uint8List bytes) {
  if (bytes.length >= 24 && _isPng(bytes)) {
    final view = ByteData.sublistView(bytes);
    return (view.getUint32(16), view.getUint32(20));
  }
  if (bytes.length >= 4 && bytes[0] == 0xFF && bytes[1] == 0xD8) {
    return _readJpegDimensions(bytes);
  }
  if (bytes.length >= 10 && _isGif(bytes)) {
    final view = ByteData.sublistView(bytes);
    return (view.getUint16(6, Endian.little), view.getUint16(8, Endian.little));
  }
  if (bytes.length >= 30 && _isWebp(bytes)) {
    return _readWebpDimensions(bytes);
  }
  return null;
}

bool _isPng(Uint8List bytes) =>
    bytes[0] == 0x89 &&
    bytes[1] == 0x50 &&
    bytes[2] == 0x4E &&
    bytes[3] == 0x47 &&
    bytes[4] == 0x0D &&
    bytes[5] == 0x0A &&
    bytes[6] == 0x1A &&
    bytes[7] == 0x0A;

bool _isGif(Uint8List bytes) =>
    bytes[0] == 0x47 &&
    bytes[1] == 0x49 &&
    bytes[2] == 0x46 &&
    bytes[3] == 0x38;

bool _isWebp(Uint8List bytes) =>
    bytes[0] == 0x52 &&
    bytes[1] == 0x49 &&
    bytes[2] == 0x46 &&
    bytes[3] == 0x46 &&
    bytes[8] == 0x57 &&
    bytes[9] == 0x45 &&
    bytes[10] == 0x42 &&
    bytes[11] == 0x50;

(int, int)? _readJpegDimensions(Uint8List bytes) {
  var offset = 2;
  while (offset + 9 < bytes.length) {
    if (bytes[offset] != 0xFF) {
      offset++;
      continue;
    }
    final marker = bytes[offset + 1];
    if (marker == 0xC0 || marker == 0xC1 || marker == 0xC2 || marker == 0xC3) {
      final view = ByteData.sublistView(bytes);
      final height = view.getUint16(offset + 5);
      final width = view.getUint16(offset + 7);
      return (width, height);
    }
    if (marker == 0xD8 || (marker >= 0xD0 && marker <= 0xD9)) {
      offset += 2;
      continue;
    }
    final length = (bytes[offset + 2] << 8) | bytes[offset + 3];
    if (length <= 0) {
      return null;
    }
    offset += 2 + length;
  }
  return null;
}

(int, int)? _readWebpDimensions(Uint8List bytes) {
  final format = String.fromCharCodes(bytes.sublist(12, 16));
  final view = ByteData.sublistView(bytes);
  switch (format) {
    case 'VP8X':
      final width = 1 + _readUint24(bytes, 24);
      final height = 1 + _readUint24(bytes, 27);
      return (width, height);
    case 'VP8L':
      final bits =
          bytes[21] | (bytes[22] << 8) | (bytes[23] << 16) | (bytes[24] << 24);
      final width = (bits & 0x3FFF) + 1;
      final height = ((bits >> 14) & 0x3FFF) + 1;
      return (width, height);
    case 'VP8 ':
      final width = view.getUint16(26, Endian.little) & 0x3FFF;
      final height = view.getUint16(28, Endian.little) & 0x3FFF;
      return (width, height);
    default:
      return null;
  }
}

int _readUint24(Uint8List bytes, int offset) =>
    bytes[offset] | (bytes[offset + 1] << 8) | (bytes[offset + 2] << 16);
