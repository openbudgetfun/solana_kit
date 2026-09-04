import 'dart:convert';
import 'dart:typed_data';

import 'package:solana_kit_dapp_publisher_cli/src/cli.dart';
import 'package:solana_kit_dapp_publisher_cli/src/errors.dart';
import 'package:solana_kit_dapp_publisher_cli/src/portal_client.dart';
import 'package:solana_kit_dapp_publisher_cli/src/portal_translators.dart';
import 'package:solana_kit_dapp_publisher_cli/src/portal_types.dart';
import 'package:solana_kit_dapp_publisher_cli/src/publication_models.dart';
import 'package:solana_kit_dapp_publisher_cli/src/workflow_client.dart';
import 'package:solana_kit_keys/solana_kit_keys.dart';
import 'package:test/test.dart';

class _CapturingDependencies extends DappStoreCliDependencies {
  _CapturingDependencies(this.files);
  final Map<String, Uint8List> files;
  final lines = <String>[];

  @override
  void write(String line) {
    lines.add(line);
  }

  @override
  bool fileExists(String path) => files.containsKey(path);

  @override
  Uint8List fileReader(String path) {
    final content = files[path];
    if (content == null) {
      throw const _PathNotFound();
    }
    return content;
  }
}

class _PathNotFound implements Exception {
  const _PathNotFound();
}

const _testKeypairJson = <num>[
  123, 45, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, //
  20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35,
  36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51,
  52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67,
];

Uint8List keypairBytes() =>
    Uint8List.fromList(utf8.encode(jsonEncode(_testKeypairJson)));

void main() {
  group('parseCliFlags', () {
    test('parses valued and boolean flags', () {
      final flags = parseCliFlags([
        '--apk-file',
        './app.apk',
        '--whats-new=Bug fixes',
        '--verbose',
        '--keypair',
        'k.json',
      ]);
      expect(flags['apk-file'], './app.apk');
      expect(flags['whats-new'], 'Bug fixes');
      expect(flags['keypair'], 'k.json');
      expect(flags.containsKey('verbose'), isTrue);
    });

    test('rejects unknown and unexpected arguments', () {
      expect(
        () => parseCliFlags(['--unknown']),
        throwsA(
          isA<PublisherCliException>().having(
            (error) => error.message,
            'message',
            contains('Unknown argument'),
          ),
        ),
      );
      expect(
        () => parseCliFlags(['positional']),
        throwsA(
          isA<PublisherCliException>().having(
            (error) => error.message,
            'message',
            contains('Unexpected argument'),
          ),
        ),
      );
      expect(
        () => parseCliFlags(['--apk-file']),
        throwsA(
          isA<PublisherCliException>().having(
            (error) => error.message,
            'message',
            contains('Missing value'),
          ),
        ),
      );
      expect(
        () => parseCliFlags(['--verbose=true']),
        throwsA(
          isA<PublisherCliException>().having(
            (error) => error.message,
            'message',
            contains('does not accept a value'),
          ),
        ),
      );
    });
  });

  group('validateNewVersionArgs', () {
    NewVersionCliOptions options({
      String? apkFile,
      String? apkUrl,
      String? whatsNew,
      String? keypair,
    }) => NewVersionCliOptions(
      apkFile: apkFile,
      apkUrl: apkUrl,
      whatsNew: whatsNew,
      keypair: keypair,
    );

    test('requires exactly one apk source', () {
      expect(
        () => validateNewVersionArgs(options: options()),
        throwsA(
          isA<PublisherCliException>().having(
            (error) => error.message,
            'message',
            contains('Specify exactly one'),
          ),
        ),
      );
      expect(
        () => validateNewVersionArgs(
          options: const NewVersionCliOptions(
            apkFile: 'a',
            apkUrl: 'b',
            whatsNew: 'x',
            keypair: 'k',
          ),
        ),
        throwsA(
          isA<PublisherCliException>().having(
            (error) => error.message,
            'message',
            contains('Specify exactly one'),
          ),
        ),
      );
    });

    test('requires whats-new', () {
      expect(
        () => validateNewVersionArgs(
          options: const NewVersionCliOptions(
            apkFile: 'a',
            whatsNew: '   ',
            keypair: 'k',
          ),
        ),
        throwsA(
          isA<PublisherCliException>().having(
            (error) => error.message,
            'message',
            '`--whats-new` is required.',
          ),
        ),
      );
    });

    test('requires keypair', () {
      expect(
        () => validateNewVersionArgs(
          options: const NewVersionCliOptions(
            apkFile: 'a',
            whatsNew: 'x',
          ),
        ),
        throwsA(
          isA<PublisherCliException>().having(
            (error) => error.message,
            'message',
            '`--keypair` is required.',
          ),
        ),
      );
    });

    test('requires the apk file to exist', () {
      expect(
        () => validateNewVersionArgs(
          options: const NewVersionCliOptions(
            apkFile: '/missing/app.apk',
            whatsNew: 'x',
            keypair: 'k',
          ),
          fileExists: (_) => false,
        ),
        throwsA(
          isA<PublisherCliException>().having(
            (error) => error.message,
            'message',
            contains('APK file not found'),
          ),
        ),
      );
      expect(
        () => validateNewVersionArgs(
          options: const NewVersionCliOptions(
            apkFile: '/existing/app.apk',
            whatsNew: 'x',
            keypair: 'k',
          ),
          fileExists: (_) => true,
        ),
        returnsNormally,
      );
    });

    test('validates the apk url', () {
      expect(
        () => validateNewVersionArgs(
          options: const NewVersionCliOptions(
            apkUrl: 'http://example.com/app.apk',
            whatsNew: 'x',
            keypair: 'k',
          ),
        ),
        throwsA(
          isA<PublisherCliException>().having(
            (error) => error.message,
            'message',
            '`--apk-url` must be a valid HTTPS URL.',
          ),
        ),
      );
      expect(
        () => validateNewVersionArgs(
          options: const NewVersionCliOptions(
            apkUrl: '::bad',
            whatsNew: 'x',
            keypair: 'k',
          ),
        ),
        throwsA(
          isA<PublisherCliException>().having(
            (error) => error.message,
            'message',
            contains('HTTPS URL'),
          ),
        ),
      );
      expect(
        () => validateNewVersionArgs(
          options: const NewVersionCliOptions(
            apkUrl: 'https://example.com/app.apk',
            whatsNew: 'x',
            keypair: 'k',
          ),
        ),
        returnsNormally,
      );
    });
  });

  group('validateResumeArgs', () {
    test('requires exactly one resume target', () {
      expect(
        () => validateResumeArgs(options: const ResumeCliOptions(keypair: 'k')),
        throwsA(
          isA<PublisherCliException>().having(
            (error) => error.message,
            'message',
            contains('Specify exactly one'),
          ),
        ),
      );
      expect(
        () => validateResumeArgs(
          options: const ResumeCliOptions(
            releaseId: 'r',
            sessionId: 's',
            keypair: 'k',
          ),
        ),
        throwsA(
          isA<PublisherCliException>().having(
            (error) => error.message,
            'message',
            contains('Specify exactly one'),
          ),
        ),
      );
    });

    test('requires a keypair', () {
      expect(
        () => validateResumeArgs(
          options: const ResumeCliOptions(releaseId: 'r'),
        ),
        throwsA(
          isA<PublisherCliException>().having(
            (error) => error.message,
            'message',
            '`--keypair` is required.',
          ),
        ),
      );
    });

    test('accepts aliases', () {
      validateResumeArgs(
        options: const ResumeCliOptions(resumeRelease: 'r', keypair: 'k'),
      );
      validateResumeArgs(
        options: const ResumeCliOptions(resumeSession: 's', keypair: 'k'),
      );
    });
  });

  group('resolveResumeTarget', () {
    test('resolves aliases and rejects conflicts', () {
      expect(
        resolveResumeTarget('a', null, '--a', '--b'),
        'a',
      );
      expect(
        resolveResumeTarget(null, 'b', '--a', '--b'),
        'b',
      );
      expect(
        () => resolveResumeTarget('a', 'b', '--a', '--b'),
        throwsA(
          isA<PublisherCliException>().having(
            (error) => error.message,
            'message',
            contains('Conflicting values'),
          ),
        ),
      );
      expect(resolveResumeTarget('  ', '  ', '--a', '--b'), isNull);
    });
  });

  group('enforceSelfUpdatePolicy', () {
    test('rejects skip-self-update outside local development', () {
      expect(
        () => enforceSelfUpdatePolicy(skipSelfUpdate: true, localDev: false),
        throwsA(
          isA<PublisherCliException>().having(
            (error) => error.message,
            'message',
            contains('`--skip-self-update` is only allowed'),
          ),
        ),
      );
      expect(
        () => enforceSelfUpdatePolicy(skipSelfUpdate: true, localDev: true),
        returnsNormally,
      );
      expect(
        () => enforceSelfUpdatePolicy(skipSelfUpdate: false, localDev: false),
        returnsNormally,
      );
    });
  });

  group('resolvePortalTargets', () {
    test('defaults to production', () {
      final targets = resolvePortalTargets(
        localDev: false,
        environment: const {},
      );
      expect(
        targets.apiBaseUrl,
        'https://publish.solanamobile.com/api',
      );
    });

    test('derives /api from a custom portal url', () {
      final targets = resolvePortalTargets(
        portalUrl: 'https://staging.example.com/',
        localDev: false,
        environment: const {},
      );
      expect(targets.apiBaseUrl, 'https://staging.example.com/api');
    });

    test('honors the environment portal url', () {
      final targets = resolvePortalTargets(
        localDev: false,
        environment: {
          'DAPP_STORE_PORTAL_URL': 'https://env.example.com',
        },
      );
      expect(targets.apiBaseUrl, 'https://env.example.com/api');
    });

    test('prefers the explicit portal url over the environment', () {
      final targets = resolvePortalTargets(
        portalUrl: 'https://cli.example.com',
        localDev: false,
        environment: {
          'DAPP_STORE_PORTAL_URL': 'https://env.example.com',
        },
      );
      expect(targets.apiBaseUrl, 'https://cli.example.com/api');
    });

    test('uses localhost in local development', () {
      final targets = resolvePortalTargets(
        localDev: true,
        environment: const {},
      );
      expect(targets.apiBaseUrl, 'http://localhost:3333/api');
    });

    test('rejects non-localhost endpoints in local development', () {
      expect(
        () => resolvePortalTargets(
          portalUrl: 'https://production.example.com',
          localDev: true,
          environment: const {},
        ),
        throwsA(
          isA<PublisherCliException>().having(
            (error) => error.message,
            'message',
            contains('--local-dev only allows localhost portal endpoints'),
          ),
        ),
      );
      expect(
        resolvePortalTargets(
          portalUrl: 'http://localhost:9999',
          localDev: true,
          environment: const {},
        ).apiBaseUrl,
        'http://localhost:9999/api',
      );
    });

    test('rejects insecure endpoints outside local development', () {
      expect(
        () => resolvePortalTargets(
          portalUrl: 'http://insecure.example.com',
          localDev: false,
          environment: const {},
        ),
        throwsA(
          isA<PublisherCliException>().having(
            (error) => error.message,
            'message',
            contains('must use HTTPS'),
          ),
        ),
      );
    });

    test('rejects invalid urls', () {
      expect(
        () => resolvePortalTargets(
          portalUrl: 'not a url',
          localDev: false,
          environment: const {},
        ),
        throwsA(
          isA<PublisherCliException>().having(
            (error) => error.message,
            'message',
            contains('Invalid portal URL'),
          ),
        ),
      );
    });
  });

  group('resolveApiKey', () {
    test('reads the key from the environment', () async {
      final key = await resolveApiKey(
        environment: {'DAPP_STORE_API_KEY': ' secret '},
      );
      expect(key.value, 'secret');
    });

    test('honors custom env names', () async {
      final key = await resolveApiKey(
        apiKeyEnv: 'CUSTOM_KEY',
        environment: {'CUSTOM_KEY': 'custom'},
      );
      expect(key.value, 'custom');
    });

    test('reads the key from stdin', () async {
      final key = await resolveApiKey(
        apiKeyStdin: true,
        stdinStream: Stream.value(utf8.encode('piped-secret\n')),
        environment: const {},
      );
      expect(key.value, 'piped-secret');
    });

    test('rejects a tty stdin', () async {
      await expectLater(
        resolveApiKey(
          apiKeyStdin: true,
          stdinIsTty: true,
          environment: const {},
        ),
        throwsA(
          isA<PublisherCliException>().having(
            (error) => error.message,
            'message',
            contains('No API key was piped into stdin.'),
          ),
        ),
      );
    });

    test('rejects an empty stdin payload', () async {
      await expectLater(
        resolveApiKey(
          apiKeyStdin: true,
          stdinStream: Stream.value(utf8.encode('   \n')),
          environment: const {},
        ),
        throwsA(
          isA<PublisherCliException>().having(
            (error) => error.message,
            'message',
            contains('No API key was provided on stdin.'),
          ),
        ),
      );
    });

    test('reports the missing env var with docs', () async {
      await expectLater(
        resolveApiKey(environment: const {}),
        throwsA(
          isA<PublisherCliException>().having(
            (error) => error.message,
            'message',
            allOf(
              contains('Portal API key is required'),
              contains('DAPP_STORE_API_KEY'),
              contains(updatedPublishingCliDocsUrl),
            ),
          ),
        ),
      );
    });

    test('redacts the api key', () {
      const key = SensitiveString('secret-value');
      expect(key.toString(), 'SensitiveString(****)');
    });
  });

  group('parseKeypairFile', () {
    test('parses a 64-byte json keypair', () {
      final bytes = parseKeypairFile(
        'k.json',
        fileReader: (_) => validKeypairFileBytes(),
      );
      expect(bytes, hasLength(64));
    });

    test('reports load failures', () {
      expect(
        () => parseKeypairFile('k.json', fileReader: (_) => Uint8List(0)),
        throwsA(
          isA<PublisherCliException>().having(
            (error) => error.message,
            'message',
            contains('Failed to load the signer keypair'),
          ),
        ),
      );
      expect(
        () => parseKeypairFile(
          'k.json',
          fileReader: (_) => Uint8List.fromList('[1,2'.codeUnits),
        ),
        throwsA(
          isA<PublisherCliException>().having(
            (error) => error.message,
            'message',
            contains('Failed to load the signer keypair'),
          ),
        ),
      );
      expect(
        () => parseKeypairFile(
          'k.json',
          fileReader: (_) => Uint8List.fromList('[1,2]'.codeUnits),
        ),
        throwsA(
          isA<PublisherCliException>().having(
            (error) => error.message,
            'message',
            contains('Failed to load the signer keypair'),
          ),
        ),
      );
      expect(
        () => parseKeypairFile(
          'k.json',
          fileReader: (_) => Uint8List.fromList('["x",2]'.codeUnits),
        ),
        throwsA(
          isA<PublisherCliException>().having(
            (error) => error.message,
            'message',
            contains('Failed to load the signer keypair'),
          ),
        ),
      );
    });

    test('loadSignerKeypair requires a path', () {
      expect(
        () => loadSignerKeypair(
          null,
          fileReader: (_) => validKeypairFileBytes(),
        ),
        throwsA(
          isA<PublisherCliException>().having(
            (error) => error.message,
            'message',
            '`--keypair` is required.',
          ),
        ),
      );
      final signer = loadSignerKeypair(
        'k.json',
        fileReader: (_) => validKeypairFileBytes(),
      );
      expect(signer.address, isNotEmpty);
    });
  });

  group('buildPublicationSource', () {
    test('builds a file source', () {
      final source = buildPublicationSource(
        const NewVersionCliOptions(apkFile: '/tmp/release.apk'),
      );
      expect(source, isA<ApkFileSource>());
      expect((source as ApkFileSource).fileName, 'release.apk');
    });

    test('builds a url source', () {
      final source = buildPublicationSource(
        const NewVersionCliOptions(
          apkUrl: 'https://files.example.com/downloads/app.apk',
        ),
      );
      expect(source, isA<ApkUrlSource>());
      expect(
        (source as ApkUrlSource).url,
        'https://files.example.com/downloads/app.apk',
      );
    });

    test('throws without any source', () {
      expect(
        () => buildPublicationSource(const NewVersionCliOptions()),
        throwsA(
          isA<PublisherCliException>().having(
            (error) => error.message,
            'message',
            contains('`--apk-file` or `--apk-url` is required.'),
          ),
        ),
      );
    });
  });

  group('hasPublicationInputs', () {
    test('detects flags', () {
      expect(hasPublicationInputs(const {}), isFalse);
      expect(hasPublicationInputs(const {'apk-file': 'a'}), isTrue);
      expect(hasPublicationInputs(const {'verbose': ''}), isTrue);
    });
  });

  group('extractPublicationSummaryLines', () {
    test('reports the review state and identifiers', () {
      final lines = extractPublicationSummaryLines(
        PublicationWorkflowResult(
          ingestionSessionId: 'i',
          publicationSessionId: 'p',
          releaseId: 'r',
          releaseMintAddress: 'Mint',
          collectionMintAddress: 'Collection',
          releaseTransactionSignature: 'sig1',
          collectionTransactionSignature: 'sig2',
          attestationRequestUniqueId: 'att',
          hubspotTicketId: 'HS-1',
          bundle: _dummyBundle(),
          session: _dummySession(),
        ),
      );
      expect(lines, [
        'This app is now in review.',
        'Release mint address: Mint',
        'Collection mint address: Collection',
        'Ticket ID: HS-1',
      ]);
    });
  });

  group('runDappStoreCli', () {
    test('prints help when invoked without arguments', () async {
      final deps = _CapturingDependencies(const {});
      final exitCode = await runDappStoreCli(const [], deps);
      expect(exitCode, 0);
      expect(deps.lines.single, contains('dapp-store'));
    });

    test('prints the version', () async {
      final deps = _CapturingDependencies(const {});
      final exitCode = await runDappStoreCli(const ['--version'], deps);
      expect(exitCode, 0);
      expect(deps.lines.single, 'dapp-store $dappStoreCliVersion');
    });

    test('prints help for --help', () async {
      final deps = _CapturingDependencies(const {});
      final exitCode = await runDappStoreCli(const ['--help'], deps);
      expect(exitCode, 0);
      expect(deps.lines.single, dappStoreHelpText);
    });

    test('fails when only verbose is provided', () async {
      final deps = _CapturingDependencies(const {});
      final exitCode = await runDappStoreCli(const ['--verbose'], deps);
      expect(exitCode, 1);
      expect(deps.lines.single, contains('Specify exactly one'));
    });

    test('reports validation errors with exit code 1', () async {
      final deps = _CapturingDependencies(const {});
      final exitCode = await runDappStoreCli(
        const [
          '--apk-file',
          './app.apk',
          '--keypair',
          'k.json',
        ],
        deps,
      );
      expect(exitCode, 1);
      expect(deps.lines.single, contains('`--whats-new` is required.'));
    });

    test('reports unexpected errors with exit code 1', () async {
      final deps = _ThrowingDependencies();
      final exitCode = await runDappStoreCli(const ['--version'], deps);
      expect(exitCode, 0);
    });

    test('rejects unknown arguments', () async {
      final deps = _CapturingDependencies(const {});
      final exitCode = await runDappStoreCli(const ['--nope'], deps);
      expect(exitCode, 1);
      expect(deps.lines.single, contains('Unknown argument'));
    });
  });

  group('fileNameOf', () {
    test('extracts the file name from paths', () {
      expect(fileNameOf('/a/b/app.apk'), 'app.apk');
      expect(fileNameOf('app.apk'), 'app.apk');
      expect(fileNameOf(r'C:\x\app.apk'), 'app.apk');
    });
  });

  group('dappStoreHelpText', () {
    test('includes the default env var and portal url', () {
      expect(dappStoreHelpText, contains('--apk-file'));
      expect(dappStoreHelpText, contains('DAPP_STORE_API_KEY'));
      expect(dappStoreHelpText, contains('publish.solanamobile.com'));
    });
  });

  group('cli constants', () {
    test('exposes the version and docs url', () {
      expect(dappStoreCliVersion, isNotEmpty);
      expect(
        updatedPublishingCliDocsUrl,
        'https://docs.solanamobile.com/dapp-store/publishing-cli',
      );
    });
  });
}

Uint8List validKeypairFileBytes() {
  final keyPair = generateKeyPair();
  final bytes = Uint8List.fromList([
    ...keyPair.privateKey,
    ...keyPair.publicKey,
  ]);
  return Uint8List.fromList(
    utf8.encode(jsonEncode(List<num>.from(bytes))),
  );
}

PublicationBundle _dummyBundle() {
  final backend = <String, Object?>{
    'ingestionSessionId': 'i',
    'publicationSessionId': 'p',
    'releaseId': 'r',
    'release': {
      'id': 'r',
      'dappId': 'd',
      'androidPackage': 'com.example.app',
      'versionName': '1',
      'versionCode': 1,
      'localizedName': 'App',
      'newInVersion': 'n',
      'releaseFileName': 'app.apk',
      'releaseFileSize': 1,
    },
    'dapp': {
      'id': 'd',
      'dappName': 'App',
      'description': 'x',
      'androidPackage': 'com.example.app',
      'dappIconUrl': 'https://img.example.com/icon.png',
      'walletAddress': 'w',
      'nftMintAddress': 'm',
      'languages': ['en-US'],
    },
    'publisher': {
      'id': 'p',
      'type': 'organization',
      'name': 'n',
      'website': 'https://example.com',
      'email': 'e',
      'supportEmail': 's',
    },
    'installFile': {
      'uri': 'https://files.example.com/app.apk',
      'mimeType': 'application/vnd.android.package-archive',
      'size': 1,
      'sha256': 'h',
    },
    'signerAuthority': {
      'dappWalletAddress': 'w',
      'collectionAuthority': 'w',
      'appMintAddress': 'm',
      'acceptedSignerRoles': ['publisher', 'payer'],
    },
  };
  return mapBackendBundleToPublicationBundle(
    backend,
    'https://meta.example.com/r.json',
    PortalSourceKind.portalUpload,
  );
}

PublicationSession _dummySession() => translateBackendPublicationSession({
  'id': 'p',
  'ingestionSessionId': 'i',
  'releaseId': 'r',
});

class _ThrowingDependencies extends DappStoreCliDependencies {
  @override
  void write(String line) {}

  @override
  Map<String, String> get environment => const {};

  @override
  Stream<List<int>>? get stdinStream => null;

  @override
  bool get stdinIsTty => false;

  @override
  bool fileExists(String path) => true;

  @override
  Uint8List fileReader(String path) => throw UnsupportedError('no');
}
