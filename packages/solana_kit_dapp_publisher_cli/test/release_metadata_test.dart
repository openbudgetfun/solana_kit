import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:solana_kit_dapp_publisher_cli/src/errors.dart';
import 'package:solana_kit_dapp_publisher_cli/src/portal_translators.dart';
import 'package:solana_kit_dapp_publisher_cli/src/portal_types.dart';
import 'package:solana_kit_dapp_publisher_cli/src/publication_models.dart';
import 'package:solana_kit_dapp_publisher_cli/src/release_metadata.dart';
import 'package:test/test.dart';

PublicationBundle bundleWith({
  required String iconUrl,
  List<String> previewUrls = const [],
  String? bannerUrl,
  String? editorsChoiceGraphicUrl,
  String? featureGraphicUrl,
  bool includeInstallFile = true,
  bool includeLegalUrls = true,
  bool includePublisherWebsite = true,
  bool includeAppWebsite = true,
}) {
  final backend = <String, Object?>{
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
      'newInVersion': 'Faster',
      'localizedName': 'My App',
      'releaseFileName': 'app.apk',
      'releaseFileSize': 2048,
      'certificateFingerprint': 'AA:BB',
    },
    'dapp': {
      'id': 'dapp-1',
      'dappName': 'My App',
      'subtitle': 'Short',
      'description': 'Long description',
      'androidPackage': 'com.example.app',
      'dappIconUrl': iconUrl,
      'dappPreviewUrls': previewUrls,
      'bannerUrl': bannerUrl,
      'featureGraphicUrl': featureGraphicUrl,
      'editorsChoiceGraphicUrl': editorsChoiceGraphicUrl,
      if (includeAppWebsite) 'appWebsite': 'https://app.example.com',
      'contactEmail': 'contact@example.com',
      'supportEmail': 'support@example.com',
      'languages': ['en-US'],
      if (includeLegalUrls) ...{
        'licenseUrl': 'https://example.com/license',
        'copyrightUrl': 'https://example.com/copyright',
        'privacyPolicyUrl': 'https://example.com/privacy',
      },
      'walletAddress': 'Wa11et1111111111111111111111111111111111111',
      'nftMintAddress': 'App111111111111111111111111111111111111111',
    },
    'publisher': {
      'id': 'pub-1',
      'type': 'organization',
      'name': 'Example Inc',
      if (includePublisherWebsite) 'website': 'https://example.com',
      'email': 'contact@example.com',
      'supportEmail': 'support@example.com',
    },
    if (includeInstallFile)
      'installFile': {
        'uri': 'https://files.example.com/app.apk',
        'mimeType': 'application/vnd.android.package-archive',
        'size': 2048,
        'sha256': 'deadbeef',
      },
    'signerAuthority': {
      'dappWalletAddress': 'Wa11et1111111111111111111111111111111111111',
      'collectionAuthority': 'Wa11et1111111111111111111111111111111111111',
      'appMintAddress': 'App111111111111111111111111111111111111111',
      'acceptedSignerRoles': ['publisher', 'payer'],
    },
  };
  return mapBackendBundleToPublicationBundle(
    backend,
    'https://meta.example.com/rel-1.json',
    PortalSourceKind.portalUpload,
  );
}

/// A fake HTTP client that records uploads.
class FakeUploadClient extends http.BaseClient {
  final requests = <http.Request>[];

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final request2 = request as http.Request;
    requests.add(request2);
    return http.StreamedResponse(
      const Stream<List<int>>.empty(),
      200,
    );
  }
}

/// A fake portal client that returns deterministic payloads.
final class FakeMetadataClient implements ReleaseMetadataPortalClient {
  FakeMetadataClient({this.uploadTarget});

  PortalUploadTarget? uploadTarget;
  final fetchCalls = <String>[];
  final uploads = <(String, Uint8List)>[];
  Object? fetchError;
  final FakeUploadClient uploadClient = FakeUploadClient();

  @override
  Future<PortalUploadTarget> createUploadTarget(
    CreateUploadTargetInput input,
  ) async {
    if (uploadTarget != null) {
      return uploadTarget!;
    }
    return PortalUploadTarget(
      uploadUrl: 'https://upload.example.com',
      publicUrl: 'https://public.example.com/${input.fileExtension}',
    );
  }

  @override
  Future<RemoteFilePayload> fetchRemoteFile({
    required String url,
    String? fileName,
    String? expectedMimeType,
  }) async {
    fetchCalls.add(url);
    final error = fetchError;
    if (error != null) {
      if (error is Exception) {
        throw error;
      }
      throw PublisherCliException(error.toString());
    }
    return RemoteFilePayload(
      data: base64Encode(pngBytes(width: 512, height: 512)),
      fileName: fileName ?? 'icon.png',
      mimeType: 'image/png',
    );
  }
}

/// Builds a minimal PNG header with the given dimensions.
Uint8List pngBytes({required int width, required int height}) {
  final data = ByteData(24)
    ..setUint32(0, 0x89504e47)
    ..setUint32(4, 0x0d0a1a0a)
    ..setUint32(8, 0x0000000d)
    ..setUint32(12, 0x49484452)
    ..setUint32(16, width)
    ..setUint32(20, height);
  return data.buffer.asUint8List();
}

const iconUrl = 'https://img.example.com/icon.png';
const r2Url = 'https://r2.solanamobiledappstore.com/icon.png';

void main() {
  group('buildReleaseMetadataDocument', () {
    test('builds a complete document', () async {
      final client = FakeMetadataClient();
      final document = await buildReleaseMetadataDocument(
        client,
        bundleWith(
          iconUrl: iconUrl,
          previewUrls: const ['https://img.example.com/1.png'],
          bannerUrl: 'https://img.example.com/banner.png',
          featureGraphicUrl: 'https://img.example.com/feature.png',
        ),
        PortalSourceKind.portalUpload,
        uploadClient: client.uploadClient,
      );

      expect(document['schema_version'], '0.4.0');
      expect(document['name'], 'My App');
      expect(document['description'], 'Short');
      expect(document['image'], isA<String>());
      final extensions = document['extensions']! as Map<String, Object?>;
      final store = extensions['solana_dapp_store']! as Map<String, Object?>;
      final publisherDetails =
          store['publisher_details']! as Map<String, Object?>;
      expect(publisherDetails['name'], 'Example Inc');
      expect(publisherDetails['website'], 'https://example.com');
      expect(publisherDetails['contact'], 'contact@example.com');
      expect(publisherDetails['support_email'], 'support@example.com');
      final releaseDetails = store['release_details']! as Map<String, Object?>;
      expect(releaseDetails['license_url'], 'https://example.com/license');
      expect(releaseDetails['copyright_url'], 'https://example.com/copyright');
      expect(
        releaseDetails['privacy_policy_url'],
        'https://example.com/privacy',
      );
      expect(
        releaseDetails['localized_resources'],
        {
          'long_description': '1',
          'new_in_version': '2',
          'name': '4',
          'short_description': '5',
        },
      );
      final androidDetails = store['android_details']! as Map<String, Object?>;
      expect(androidDetails['android_package'], 'com.example.app');
      expect(androidDetails['version'], '1.2.0');
      expect(androidDetails['version_code'], 120);
      expect(androidDetails['min_sdk'], 21);
      expect(androidDetails['target_sdk'], 34);
      expect(androidDetails['cert_fingerprint'], 'AA:BB');
      expect(androidDetails['permissions'], ['INTERNET']);
      expect(androidDetails['locales'], ['en-US']);
      final media = store['media']! as List<Map<String, Object?>>;
      expect(media, hasLength(4));
      for (final entry in media) {
        expect(entry['width'], 512);
        expect(entry['height'], 512);
        expect(entry['sha256'], isNotEmpty);
      }
      expect(media.first['purpose'], 'icon');
      expect(media[1]['purpose'], 'screenshot');
      expect(media[2]['purpose'], 'banner');
      expect(media[3]['purpose'], 'featureGraphic');
      final files = store['files']! as List<Map<String, Object?>>;
      expect(files.single['purpose'], 'install');
      expect(files.single['uri'], 'https://files.example.com/app.apk');
      final i18n = extensions['i18n']! as Map<String, Object?>;
      final enUs = i18n['en-US']! as Map<String, Object?>;
      expect(enUs['1'], 'Long description');
      expect(enUs['2'], 'Faster');
      expect(enUs['4'], 'My App');
      expect(enUs['5'], 'Short');
      final properties = document['properties']! as Map<String, Object?>;
      expect(properties['category'], 'dApp');
      final creators = properties['creators']! as List<Map<String, Object?>>;
      expect(creators.single['share'], 100);
    });

    test('omits nullable fields when absent', () async {
      final client = FakeMetadataClient();
      final document = await buildReleaseMetadataDocument(
        client,
        bundleWith(
          iconUrl: iconUrl,
          includeLegalUrls: false,
          includePublisherWebsite: false,
          includeAppWebsite: false,
        ),
        PortalSourceKind.portalUpload,
        uploadClient: client.uploadClient,
      );
      expect(document.containsKey('external_url'), isFalse);
      final extensions = document['extensions']! as Map<String, Object?>;
      final store = extensions['solana_dapp_store']! as Map<String, Object?>;
      final releaseDetails = store['release_details']! as Map<String, Object?>;
      expect(releaseDetails.containsKey('license_url'), isFalse);
      expect(releaseDetails.containsKey('copyright_url'), isFalse);
      expect(releaseDetails.containsKey('privacy_policy_url'), isFalse);
      final media = store['media']! as List<Map<String, Object?>>;
      expect(media, hasLength(1));
      final publisherDetails =
          store['publisher_details']! as Map<String, Object?>;
      expect(publisherDetails.containsKey('website'), isFalse);
    });

    test('marks external origin', () async {
      final client = FakeMetadataClient();
      final document = await buildReleaseMetadataDocument(
        client,
        bundleWith(iconUrl: iconUrl),
        PortalSourceKind.externalUrl,
        uploadClient: client.uploadClient,
      );
      expect(document, isNotNull);
    });

    test('throws when the app icon URL is missing', () async {
      final client = FakeMetadataClient();
      await expectLater(
        buildReleaseMetadataDocument(
          client,
          bundleWith(iconUrl: ''),
          PortalSourceKind.portalUpload,
          uploadClient: client.uploadClient,
        ),
        throwsA(
          isA<PublisherCliException>().having(
            (error) => error.message,
            'message',
            contains('did not include a public app icon URL'),
          ),
        ),
      );
    });
  });

  group('isR2PublicUrl', () {
    test('matches portal R2 hosts', () {
      expect(isR2PublicUrl(r2Url), isTrue);
      expect(
        isR2PublicUrl('https://r2-staging.solanamobiledappstore.com/x'),
        isTrue,
      );
      expect(isR2PublicUrl('https://other.example.com/x'), isFalse);
      expect(isR2PublicUrl('not a url'), isFalse);
    });
  });

  group('normalizeMimeType', () {
    test('strips parameters and lowercases', () {
      expect(normalizeMimeType('Image/PNG; charset=utf-8'), 'image/png');
      expect(normalizeMimeType(null), isNull);
      expect(normalizeMimeType('  '), isNull);
    });
  });

  group('inferUploadFileExtension', () {
    test('prefers the file name extension', () {
      expect(
        inferUploadFileExtension('icon.PNG', 'image/png'),
        'png',
      );
      expect(inferUploadFileExtension('noextension', 'image/jpeg'), 'jpg');
      expect(inferUploadFileExtension('noextension', 'image/webp'), 'webp');
      expect(inferUploadFileExtension('noextension', 'image/gif'), 'gif');
      expect(inferUploadFileExtension('noextension', 'image/svg+xml'), 'svg');
      expect(inferUploadFileExtension('noextension', 'video/mp4'), 'mp4');
      expect(inferUploadFileExtension('noextension', 'video/webm'), 'webm');
      expect(
        inferUploadFileExtension('noextension', 'video/quicktime'),
        'mov',
      );
      expect(
        inferUploadFileExtension('noextension', 'application/json'),
        'json',
      );
      expect(inferUploadFileExtension('noextension', 'font/woff+zip'), 'woff');
      expect(inferUploadFileExtension('noextension', 'weird/type!'), 'type');
      expect(inferUploadFileExtension('noextension', 'nodashtype'), 'bin');
    });
  });

  group('readImageDimensions', () {
    test('reads PNG dimensions', () {
      final dimensions = readImageDimensions(
        pngBytes(width: 100, height: 200),
      );
      expect(dimensions, isNotNull);
      expect(dimensions!.$1, 100);
      expect(dimensions.$2, 200);
    });

    test('reads JPEG dimensions', () {
      final bytes = Uint8List.fromList([
        0xFF, 0xD8, // SOI
        0xFF, 0xC0, 0x00, 0x11, 0x08, 0x00, 0x64, 0x00, 0xC8, // SOF0
        0x03, 0x01, 0x22, 0x00, 0x02, 0x11, 0x01, 0x03, 0x11, 0x01,
        0xFF, 0xD9,
      ]);
      final dimensions = readImageDimensions(bytes);
      expect(dimensions!.$1, 200);
      expect(dimensions.$2, 100);
    });

    test('reads GIF dimensions', () {
      final bytes = Uint8List(20)
        ..[0] = 0x47
        ..[1] = 0x49
        ..[2] = 0x46
        ..[3] = 0x38
        ..[6] = 0x64
        ..[7] = 0x00
        ..[8] = 0xC8
        ..[9] = 0x00;
      final dimensions = readImageDimensions(bytes);
      expect(dimensions!.$1, 100);
      expect(dimensions.$2, 200);
    });

    test('reads WebP VP8X dimensions', () {
      final bytes = Uint8List(30)
        ..[0] = 0x52
        ..[1] = 0x49
        ..[2] = 0x46
        ..[3] = 0x46
        ..[8] = 0x57
        ..[9] = 0x45
        ..[10] = 0x42
        ..[11] = 0x50
        ..[12] = 0x56
        ..[13] = 0x50
        ..[14] = 0x38
        ..[15] = 0x58
        ..[24] = 99
        ..[25] = 1
        ..[27] = 199
        ..[28] = 1;
      final dimensions = readImageDimensions(bytes);
      expect(dimensions!.$1, 356);
      expect(dimensions.$2, 456);
    });

    test('returns null for unknown formats', () {
      expect(readImageDimensions(Uint8List.fromList([1, 2, 3, 4])), isNull);
    });

    test('throws for dimensions it cannot read', () {
      expect(
        () => getMediaDimensions(
          Uint8List.fromList([1, 2, 3, 4]),
          'media.bin',
          'application/octet-stream',
        ),
        throwsA(
          isA<PublisherCliException>().having(
            (error) => error.message,
            'message',
            contains('Unable to determine media dimensions'),
          ),
        ),
      );
    });
  });

  group('_resolveMediaItem', () {
    test('re-hosts non-R2 media on portal storage', () async {
      final client = FakeMetadataClient();
      final document = await buildReleaseMetadataDocument(
        client,
        bundleWith(iconUrl: iconUrl),
        PortalSourceKind.portalUpload,
        uploadClient: client.uploadClient,
      );
      expect(client.fetchCalls.single, 'https://img.example.com/icon.png');
      expect(client.uploadClient.requests, hasLength(1));
      final extensions = document['extensions']! as Map<String, Object?>;
      final store = extensions['solana_dapp_store']! as Map<String, Object?>;
      final media = store['media']! as List<Map<String, Object?>>;
      expect(
        media.single['uri'],
        'https://public.example.com/png',
      );
    });

    test('keeps already public R2 URIs', () async {
      final client = FakeMetadataClient();
      final document = await buildReleaseMetadataDocument(
        client,
        bundleWith(iconUrl: r2Url),
        PortalSourceKind.portalUpload,
        uploadClient: client.uploadClient,
      );
      final extensions = document['extensions']! as Map<String, Object?>;
      final store = extensions['solana_dapp_store']! as Map<String, Object?>;
      final media = store['media']! as List<Map<String, Object?>>;
      expect(media.single['uri'], r2Url);
    });

    test('rejects empty remote media', () async {
      final client = FakeMetadataClient()
        ..fetchError = const PublisherCliException('no bytes');
      await expectLater(
        buildReleaseMetadataDocument(
          client,
          bundleWith(iconUrl: iconUrl),
          PortalSourceKind.portalUpload,
        ),
        throwsA(
          isA<PublisherCliException>().having(
            (error) => error.message,
            'message',
            contains('Failed to fetch icon media from $iconUrl'),
          ),
        ),
      );
    });

    test('rejects invalid upload targets', () async {
      final client = FakeMetadataClient()
        ..uploadTarget = const PortalUploadTarget(uploadUrl: '', publicUrl: '');
      await expectLater(
        buildReleaseMetadataDocument(
          client,
          bundleWith(iconUrl: iconUrl),
          PortalSourceKind.portalUpload,
        ),
        throwsA(
          isA<PublisherCliException>().having(
            (error) => error.message,
            'message',
            contains('did not return a valid upload target for icon.'),
          ),
        ),
      );
    });

    test('propagates non-CLI fetch errors', () async {
      final client = FakeMetadataClient()
        ..fetchError = Exception('network down');
      await expectLater(
        buildReleaseMetadataDocument(
          client,
          bundleWith(iconUrl: iconUrl),
          PortalSourceKind.portalUpload,
        ),
        throwsA(
          isA<PublisherCliException>().having(
            (error) => error.message,
            'message',
            contains('network down'),
          ),
        ),
      );
    });
  });
}
