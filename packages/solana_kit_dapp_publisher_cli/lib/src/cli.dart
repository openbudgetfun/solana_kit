import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:solana_kit_dapp_publisher_cli/src/errors.dart';
import 'package:solana_kit_dapp_publisher_cli/src/files.dart';
import 'package:solana_kit_dapp_publisher_cli/src/funding_preflight.dart';
import 'package:solana_kit_dapp_publisher_cli/src/portal_client.dart';
import 'package:solana_kit_dapp_publisher_cli/src/portal_types.dart';
import 'package:solana_kit_dapp_publisher_cli/src/portal_workflow_client.dart';
import 'package:solana_kit_dapp_publisher_cli/src/publication_signer.dart';
import 'package:solana_kit_dapp_publisher_cli/src/publication_workflow.dart';
import 'package:solana_kit_dapp_publisher_cli/src/workflow_client.dart';

/// The CLI version reported by `--version`.
const dappStoreCliVersion = '0.1.0';

/// The documentation URL shown when CLI usage errors occur.
const updatedPublishingCliDocsUrl =
    'https://docs.solanamobile.com/dapp-store/publishing-cli';

const _valuedFlags = <String>{
  'apk-file',
  'apk-url',
  'whats-new',
  'portal-url',
  'api-key-env',
  'keypair',
  'rpc-url',
  'idempotency-key',
  'release-id',
  'session-id',
  'resume-release',
  'resume-session',
};

const _booleanFlags = <String>{
  'api-key-stdin',
  'local-dev',
  'skip-self-update',
  'verbose',
};

/// Options parsed for the root (new version) command.
final class NewVersionCliOptions {
  /// Creates the options.
  const NewVersionCliOptions({
    this.apkFile,
    this.apkUrl,
    this.whatsNew,
    this.portalUrl,
    this.apiKeyEnv,
    this.apiKeyStdin = false,
    this.keypair,
    this.rpcUrl,
    this.localDev = false,
    this.skipSelfUpdate = false,
    this.idempotencyKey,
    this.verbose = false,
  });

  /// Path to a local APK.
  final String? apkFile;

  /// HTTPS URL of an externally hosted APK.
  final String? apkUrl;

  /// What changed in this version.
  final String? whatsNew;

  /// Publishing portal base URL.
  final String? portalUrl;

  /// Environment variable that contains the portal API key.
  final String? apiKeyEnv;

  /// Whether to read the API key from stdin.
  final bool apiKeyStdin;

  /// Path to the Solana signer keypair.
  final String? keypair;

  /// Optional Solana RPC URL (hidden option).
  final String? rpcUrl;

  /// Whether local development mode is enabled.
  final bool localDev;

  /// Whether to skip the self-update gate (local development only).
  final bool skipSelfUpdate;

  /// Optional idempotency key for safe retries.
  final String? idempotencyKey;

  /// Whether to print detailed publication identifiers.
  final bool verbose;
}

/// Options parsed for the `resume` command.
final class ResumeCliOptions {
  /// Creates the options.
  const ResumeCliOptions({
    this.releaseId,
    this.sessionId,
    this.resumeRelease,
    this.resumeSession,
    this.portalUrl,
    this.apiKeyEnv,
    this.apiKeyStdin = false,
    this.keypair,
    this.rpcUrl,
    this.localDev = false,
    this.skipSelfUpdate = false,
    this.verbose = false,
  });

  /// The publication release identifier.
  final String? releaseId;

  /// The publication session identifier.
  final String? sessionId;

  /// Alias of [releaseId].
  final String? resumeRelease;

  /// Alias of [sessionId].
  final String? resumeSession;

  /// Publishing portal base URL.
  final String? portalUrl;

  /// Environment variable that contains the portal API key.
  final String? apiKeyEnv;

  /// Whether to read the API key from stdin.
  final bool apiKeyStdin;

  /// Path to the Solana signer keypair.
  final String? keypair;

  /// Optional Solana RPC URL (hidden option).
  final String? rpcUrl;

  /// Whether local development mode is enabled.
  final bool localDev;

  /// Whether to skip the self-update gate.
  final bool skipSelfUpdate;

  /// Whether to print detailed identifiers.
  final bool verbose;
}

/// Resolved portal endpoint targets.
final class ResolvedPortalTargets {
  /// Creates the targets.
  const ResolvedPortalTargets({required this.apiBaseUrl});

  /// The derived tRPC API base URL.
  final String apiBaseUrl;
}

/// Runtime dependencies for the CLI, overridable in tests.
abstract class DappStoreCliDependencies {
  /// Creates CLI dependencies.
  const DappStoreCliDependencies();

  /// The line writer for normal output.
  void write(String line) {
    stdout.writeln(line);
  }

  /// The environment variables used for portal/API key resolution.
  Map<String, String> get environment => const {};

  /// The stream to read a piped API key from.
  Stream<List<int>>? get stdinStream => null;

  /// Whether stdin is a terminal.
  bool get stdinIsTty => false;

  /// File existence check.
  bool fileExists(String path) => File(path).existsSync();

  /// File reader.
  Uint8List fileReader(String path) => File(path).readAsBytesSync();
}

/// The exit code returned by the CLI for the given arguments.
Future<int> runDappStoreCli(
  List<String> arguments,
  DappStoreCliDependencies dependencies,
) async {
  try {
    return await _run(arguments, dependencies);
  } on PublisherCliException catch (error) {
    _safePrintError(dependencies, error.message);
    return 1;
  } on Object catch (error) {
    _safePrintError(dependencies, 'An unexpected error occurred: $error');
    return 1;
  }
}

Future<int> _run(List<String> arguments, DappStoreCliDependencies deps) async {
  if (arguments.isEmpty) {
    _printHelp(deps);
    return 0;
  }

  if (arguments.contains('--version')) {
    deps.write('dapp-store $dappStoreCliVersion');
    return 0;
  }
  if (arguments.contains('--help') || arguments.contains('-h')) {
    _printHelp(deps);
    return 0;
  }

  final isResume = arguments.first == 'resume';
  final flags = parseCliFlags(
    isResume ? arguments.sublist(1) : arguments,
  );

  if (isResume) {
    return _runResume(flags, deps);
  }
  return _runNewVersion(flags, deps);
}

Future<int> _runNewVersion(
  Map<String, String?> flags,
  DappStoreCliDependencies deps,
) async {
  final options = NewVersionCliOptions(
    apkFile: flags['apk-file'],
    apkUrl: flags['apk-url'],
    whatsNew: flags['whats-new'],
    portalUrl: flags['portal-url'],
    apiKeyEnv: flags['api-key-env'],
    apiKeyStdin: flags.containsKey('api-key-stdin'),
    keypair: flags['keypair'],
    rpcUrl: flags['rpc-url'],
    localDev: flags.containsKey('local-dev'),
    skipSelfUpdate: flags.containsKey('skip-self-update'),
    idempotencyKey: flags['idempotency-key'],
    verbose: flags.containsKey('verbose'),
  );

  validateNewVersionArgs(
    options: options,
    fileExists: deps.fileExists,
  );
  enforceSelfUpdatePolicy(
    skipSelfUpdate: options.skipSelfUpdate,
    localDev: options.localDev,
  );

  final targets = resolvePortalTargets(
    portalUrl: options.portalUrl,
    localDev: options.localDev,
    environment: deps.environment,
  );
  final apiKey = await resolveApiKey(
    apiKeyEnv: options.apiKeyEnv,
    apiKeyStdin: options.apiKeyStdin,
    environment: deps.environment,
    stdinStream: deps.stdinStream,
    stdinIsTty: deps.stdinIsTty,
  );
  final signer = loadSignerKeypair(
    options.keypair,
    fileReader: deps.fileReader,
  );

  final balanceWarning = await ensurePublicationSignerBalance(
    publicKey: signer.address,
    localDev: options.localDev,
    rpcUrl: options.rpcUrl,
  );
  if (balanceWarning != null) {
    deps.write('Warning: $balanceWarning');
  }

  final attestationClient = createPortalAttestationClient(
    PortalClientConfig(apiBaseUrl: targets.apiBaseUrl, apiKey: apiKey),
  );
  return _executeWorkflow(
    deps: deps,
    targets: targets,
    apiKey: apiKey,
    signer: signer,
    verbose: options.verbose,
    title: 'Publishing version',
    start: (workflow) => workflow.startPublication(
      PublicationWorkflowInput(
        source: buildPublicationSource(options),
        whatsNew: options.whatsNew ?? '',
        idempotencyKey: options.idempotencyKey,
        signer: signer,
        attestationClient: attestationClient,
      ),
    ),
  );
}

Future<int> _runResume(
  Map<String, String?> flags,
  DappStoreCliDependencies deps,
) async {
  final options = ResumeCliOptions(
    releaseId: flags['release-id'],
    sessionId: flags['session-id'],
    resumeRelease: flags['resume-release'],
    resumeSession: flags['resume-session'],
    portalUrl: flags['portal-url'],
    apiKeyEnv: flags['api-key-env'],
    apiKeyStdin: flags.containsKey('api-key-stdin'),
    keypair: flags['keypair'],
    rpcUrl: flags['rpc-url'],
    localDev: flags.containsKey('local-dev'),
    skipSelfUpdate: flags.containsKey('skip-self-update'),
    verbose: flags.containsKey('verbose'),
  );

  validateResumeArgs(options: options);
  enforceSelfUpdatePolicy(
    skipSelfUpdate: options.skipSelfUpdate,
    localDev: options.localDev,
  );

  final targets = resolvePortalTargets(
    portalUrl: options.portalUrl,
    localDev: options.localDev,
    environment: deps.environment,
  );
  final apiKey = await resolveApiKey(
    apiKeyEnv: options.apiKeyEnv,
    apiKeyStdin: options.apiKeyStdin,
    environment: deps.environment,
    stdinStream: deps.stdinStream,
    stdinIsTty: deps.stdinIsTty,
  );
  final signer = loadSignerKeypair(
    options.keypair,
    fileReader: deps.fileReader,
  );

  final attestationClient = createPortalAttestationClient(
    PortalClientConfig(apiBaseUrl: targets.apiBaseUrl, apiKey: apiKey),
  );
  return _executeWorkflow(
    deps: deps,
    targets: targets,
    apiKey: apiKey,
    signer: signer,
    verbose: options.verbose,
    title: 'Resuming publication',
    start: (workflow) => workflow.resumePublication(
      PublicationResumeInput(
        publicationSessionId: resolveResumeTarget(
          options.sessionId,
          options.resumeSession,
          '--session-id',
          '--resume-session',
        ),
        releaseId: resolveResumeTarget(
          options.releaseId,
          options.resumeRelease,
          '--release-id',
          '--resume-release',
        ),
        signer: signer,
        attestationClient: attestationClient,
      ),
    ),
  );
}

Future<int> _executeWorkflow({
  required DappStoreCliDependencies deps,
  required ResolvedPortalTargets targets,
  required SensitiveString apiKey,
  required PublicationSigner signer,
  required bool verbose,
  required String title,
  required Future<PublicationWorkflowResult> Function(PublicationWorkflow)
  start,
}) async {
  final workflow = PublicationWorkflow(
    createPortalWorkflowClient(
      PortalClientConfig(apiBaseUrl: targets.apiBaseUrl, apiKey: apiKey),
    ),
    options: PublicationWorkflowOptions(
      logger: (message, {required step, required status}) {
        final line = verbose ? '$title [$step] $message' : '$title: $message';
        deps.write(line);
      },
    ),
  );

  final result = await start(workflow);

  if (verbose) {
    deps
      ..write('Ingestion session: ${result.ingestionSessionId}')
      ..write('Publication session: ${result.publicationSessionId}')
      ..write('Release: ${result.releaseId}');
  }
  for (final line in extractPublicationSummaryLines(result)) {
    deps.write(line);
  }
  return 0;
}

/// Builds the publication source from the parsed options.
PublicationSource buildPublicationSource(NewVersionCliOptions options) {
  final apkFile = options.apkFile;
  if (apkFile != null) {
    return ApkFileSource(
      filePath: apkFile,
      fileName: fileNameOf(apkFile),
    );
  }
  final apkUrl = options.apkUrl;
  if (apkUrl == null) {
    throw const PublisherCliException(
      '`--apk-file` or `--apk-url` is required.',
    );
  }
  return ApkUrlSource(
    url: apkUrl,
    fileName: inferFileNameFromUrl(apkUrl),
  );
}

/// The file name portion of a path.
String fileNameOf(String filePath) {
  final normalized = filePath.replaceAll(r'\', '/');
  final segments = normalized.split('/');
  return segments.isEmpty ? filePath : segments.last;
}

/// Whether any publication inputs were provided.
bool hasPublicationInputs(Map<String, String?> flags) => flags.isNotEmpty;

/// Validates the root command arguments.
void validateNewVersionArgs({
  required NewVersionCliOptions options,
  bool Function(String path)? fileExists,
}) {
  final apkSourceCount =
      (options.apkFile != null ? 1 : 0) + (options.apkUrl != null ? 1 : 0);
  if (apkSourceCount != 1) {
    throw const PublisherCliException(
      'Specify exactly one of `--apk-file` or `--apk-url`.',
    );
  }

  if (options.whatsNew == null || options.whatsNew!.trim().isEmpty) {
    throw const PublisherCliException('`--whats-new` is required.');
  }

  if (options.keypair == null || options.keypair!.trim().isEmpty) {
    throw const PublisherCliException('`--keypair` is required.');
  }

  if (options.apkFile != null) {
    final apkPath = options.apkFile!;
    final exists = fileExists?.call(apkPath) ?? File(apkPath).existsSync();
    if (!exists) {
      throw PublisherCliException('APK file not found: $apkPath');
    }
  }

  if (options.apkUrl != null) {
    final parsed = Uri.tryParse(options.apkUrl!);
    if (parsed == null || !parsed.hasScheme || parsed.scheme != 'https') {
      throw const PublisherCliException(
        '`--apk-url` must be a valid HTTPS URL.',
      );
    }
  }
}

/// Validates the `resume` command arguments.
void validateResumeArgs({required ResumeCliOptions options}) {
  final releaseId = resolveResumeTarget(
    options.releaseId,
    options.resumeRelease,
    '--release-id',
    '--resume-release',
  );
  final sessionId = resolveResumeTarget(
    options.sessionId,
    options.resumeSession,
    '--session-id',
    '--resume-session',
  );
  final resumeTargetCount =
      (releaseId != null ? 1 : 0) + (sessionId != null ? 1 : 0);
  if (resumeTargetCount != 1) {
    throw const PublisherCliException(
      'Specify exactly one of `--release-id` or `--session-id`.',
    );
  }

  if (options.keypair == null || options.keypair!.trim().isEmpty) {
    throw const PublisherCliException('`--keypair` is required.');
  }
}

/// Resolves a resume target, treating aliases and conflicts like the
/// upstream CLI.
String? resolveResumeTarget(
  String? primary,
  String? alias,
  String primaryLabel,
  String aliasLabel,
) {
  final trimmedPrimary = _trimToNull(primary);
  final trimmedAlias = _trimToNull(alias);
  if (trimmedPrimary != null &&
      trimmedAlias != null &&
      trimmedPrimary != trimmedAlias) {
    throw PublisherCliException(
      'Conflicting values were provided for $primaryLabel and $aliasLabel.',
    );
  }
  return trimmedPrimary ?? trimmedAlias;
}

/// Enforces the `--local-dev` self-update policy.
void enforceSelfUpdatePolicy({
  required bool skipSelfUpdate,
  required bool localDev,
}) {
  if (skipSelfUpdate && !localDev) {
    throw const PublisherCliException(
      '`--skip-self-update` is only allowed together with `--local-dev`.',
    );
  }
}

/// Resolves the portal endpoint targets with the CLI security checks.
ResolvedPortalTargets resolvePortalTargets({
  required bool localDev,
  String? portalUrl,
  Map<String, String>? environment,
}) {
  final envPortalUrl = environment == null
      ? null
      : _trimToNull(environment['DAPP_STORE_PORTAL_URL']);
  final resolvedPortalUrl =
      _trimToNull(portalUrl) ??
      envPortalUrl ??
      (localDev ? defaultLocalPortalUrl : null) ??
      defaultProductionPortalUrl;

  final normalizedPortalUrl = _normalizeUrl(resolvedPortalUrl, 'portal URL');
  final normalizedApiBaseUrl = _normalizeUrl(
    _deriveApiBaseUrl(normalizedPortalUrl),
    'portal API base URL',
  );

  if (localDev) {
    if (!_isLocalhostUrl(normalizedPortalUrl) ||
        !_isLocalhostUrl(normalizedApiBaseUrl)) {
      final target = _isLocalhostUrl(normalizedPortalUrl)
          ? 'portal API base URL: $normalizedApiBaseUrl'
          : 'portal URL: $normalizedPortalUrl';
      throw PublisherCliException(
        '--local-dev only allows localhost portal endpoints. Received $target',
      );
    }
  } else {
    if (Uri.parse(normalizedPortalUrl).scheme != 'https') {
      throw PublisherCliException(
        'Portal endpoints must use HTTPS unless --local-dev is set. '
        'Received portal URL: $normalizedPortalUrl',
      );
    }
  }

  return ResolvedPortalTargets(apiBaseUrl: normalizedApiBaseUrl);
}

String _normalizeUrl(String value, String label) {
  final parsed = Uri.tryParse(value);
  if (parsed == null || !parsed.hasScheme || parsed.host.isEmpty) {
    throw PublisherCliException('Invalid $label: $value');
  }
  return parsed.toString().replaceFirst(RegExp(r'/+$'), '');
}

String _deriveApiBaseUrl(String portalUrl) {
  final parsed = Uri.parse(portalUrl);
  final basePath = parsed.path.replaceFirst(RegExp(r'/+$'), '');
  final newPath = basePath.isEmpty ? '/api' : '$basePath/api';
  return parsed
      .replace(path: newPath)
      .toString()
      .replaceFirst(
        RegExp(r'/+$'),
        '',
      );
}

bool _isLocalhostUrl(String url) {
  final parsed = Uri.tryParse(url);
  if (parsed == null) {
    return false;
  }
  final host = parsed.host;
  return host == 'localhost' || host == '127.0.0.1' || host == '::1';
}

/// Resolves the portal API key from the environment or stdin.
Future<SensitiveString> resolveApiKey({
  bool apiKeyStdin = false,
  String? apiKeyEnv,
  Map<String, String>? environment,
  Stream<List<int>>? stdinStream,
  bool stdinIsTty = false,
}) async {
  final envVarName = apiKeyEnv ?? defaultApiKeyEnv;
  final env = environment ?? const <String, String>{};

  if (apiKeyStdin) {
    return readSecretFromStdin(
      stdinStream: stdinStream,
      stdinIsTty: stdinIsTty,
    );
  }

  final envValue = _trimToNull(env[envVarName]);
  if (envValue != null) {
    return SensitiveString(envValue);
  }

  throw PublisherCliException(
    _withUpdatedCliDocs(
      'Portal API key is required. Set $envVarName or pass --api-key-stdin.',
    ),
  );
}

/// Reads a secret from piped stdin.
Future<SensitiveString> readSecretFromStdin({
  Stream<List<int>>? stdinStream,
  bool stdinIsTty = false,
}) async {
  if (stdinIsTty) {
    throw PublisherCliException(
      _withUpdatedCliDocs('No API key was piped into stdin.'),
    );
  }
  final stream = stdinStream ?? stdin.cast<List<int>>();
  final chunks = await stream.toList();
  final bytes = <int>[for (final chunk in chunks) ...chunk];
  final value = utf8.decode(bytes).trim();
  if (value.isEmpty) {
    throw PublisherCliException(
      _withUpdatedCliDocs('No API key was provided on stdin.'),
    );
  }
  return SensitiveString(value);
}

/// Loads a Solana CLI keypair from a JSON file and returns its 64 bytes.
Uint8List parseKeypairFile(
  String path, {
  required Uint8List Function(String path) fileReader,
}) {
  final List<int> entries;
  try {
    final content = fileReader(path);
    final decoded = jsonDecode(utf8.decode(content));
    if (decoded is! List || decoded.isEmpty) {
      throw const FormatException('not a keypair array');
    }
    entries = <int>[];
    for (final entry in decoded) {
      if (entry is! num) {
        throw const FormatException('non-integer entry');
      }
      entries.add(entry.toInt() & 0xff);
    }
  } on Object {
    throw PublisherCliException(
      'Something went wrong when attempting to retrieve the keypair at '
      '$path. Failed to load the signer keypair.',
    );
  }
  if (entries.length != 64) {
    throw PublisherCliException(
      'Something went wrong when attempting to retrieve the keypair at '
      '$path. Failed to load the signer keypair.',
    );
  }
  return Uint8List.fromList(entries);
}

/// Loads the publication signer from a keypair path.
PublicationSigner loadSignerKeypair(
  String? keypairPath, {
  required Uint8List Function(String path) fileReader,
}) {
  if (keypairPath == null || keypairPath.trim().isEmpty) {
    throw const PublisherCliException('`--keypair` is required.');
  }
  final bytes = parseKeypairFile(keypairPath, fileReader: fileReader);
  return createPublicationSignerFromKeypairBytes(bytes);
}

/// Extracts the publication summary lines shown after a successful run.
List<String> extractPublicationSummaryLines(PublicationWorkflowResult result) {
  final lines = <String>['This app is now in review.'];
  final entries = <(String?, String)>[
    (result.releaseMintAddress, 'Release mint address'),
    (result.collectionMintAddress, 'Collection mint address'),
    (result.hubspotTicketId, 'Ticket ID'),
  ];
  for (final (value, label) in entries) {
    if (value != null && value.isNotEmpty) {
      lines.add('$label: $value');
    }
  }
  return lines;
}

/// Parses CLI flags into a name/value map.
///
/// Supports both `--flag value` and `--flag=value` forms, boolean flags, and
/// rejects unknown or unexpected arguments.
Map<String, String?> parseCliFlags(List<String> arguments) {
  final values = <String, String?>{};
  for (var i = 0; i < arguments.length; i++) {
    final argument = arguments[i];
    if (!argument.startsWith('--')) {
      throw PublisherCliException('Unexpected argument: $argument');
    }
    final withoutPrefix = argument.substring(2);
    final equalsIndex = withoutPrefix.indexOf('=');
    final name = equalsIndex >= 0
        ? withoutPrefix.substring(0, equalsIndex)
        : withoutPrefix;
    if (_valuedFlags.contains(name)) {
      if (equalsIndex >= 0) {
        values[name] = withoutPrefix.substring(equalsIndex + 1);
      } else {
        if (i + 1 >= arguments.length) {
          throw PublisherCliException(
            'Missing value for --$name. Provide it as --$name <value>.',
          );
        }
        values[name] = arguments[i + 1];
        i++;
      }
    } else if (_booleanFlags.contains(name)) {
      if (equalsIndex >= 0) {
        throw PublisherCliException(
          'The --$name flag does not accept a value.',
        );
      }
      values[name] = '';
    } else {
      throw PublisherCliException('Unknown argument: $argument');
    }
  }
  return values;
}

String? _trimToNull(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}

String _withUpdatedCliDocs(String message) => [
  message,
  '',
  'The publishing CLI has changed. See the updated usage guide:',
  updatedPublishingCliDocsUrl,
].join('\n');

void _printError(DappStoreCliDependencies deps, String message) {
  deps.write('Error: $message');
}

void _safePrintError(DappStoreCliDependencies deps, String message) {
  try {
    _printError(deps, message);
  } on Object {
    // The output stream is broken; there is nowhere left to report the error.
  }
}

/// The help text for the CLI.
String get dappStoreHelpText => [
  'dapp-store - Portal-backed CLI for Solana Mobile dApp version publishing',
  '',
  'Usage:',
  '  dapp-store --apk-file ./app.apk --whats-new "Bug fixes" --keypair ./keypair.json',
  '  dapp-store --apk-url https://example.com/app.apk --whats-new "Bug fixes" --keypair ./keypair.json',
  '  dapp-store resume --release-id <release-id> [--session-id <session-id>]',
  '',
  'Options:',
  '  --apk-file <path>      Path to the APK file to publish',
  '  --apk-url <url>        HTTPS URL for an externally hosted APK',
  '  --whats-new <text>     What changed in this version',
  '  --portal-url <url>     Publishing portal base URL',
  '  --api-key-env <name>   Environment variable with the portal API key',
  '                         (default: $defaultApiKeyEnv)',
  '  --api-key-stdin        Read the portal API key from stdin',
  '  --keypair <path>       Path to the Solana signer keypair',
  '  --local-dev            Allow localhost portal endpoints',
  '  --skip-self-update     Skip the self-update check (local development)',
  '  --idempotency-key <k>  Idempotency key for safe retries',
  '  --verbose              Print detailed publication identifiers',
  '',
  'Portal:',
  '  Set DAPP_STORE_PORTAL_URL to the portal origin. If unset, it defaults',
  '  to $defaultProductionPortalUrl. The target app must already exist in',
  '  the portal and already have its App NFT.',
  '',
  'Secrets:',
  '  Portal API key defaults to the $defaultApiKeyEnv environment variable',
  '  or the name passed via --api-key-env. Use --api-key-stdin to read the',
  '  key from stdin.',
].join('\n');

void _printHelp(DappStoreCliDependencies deps) {
  deps.write(dappStoreHelpText);
}
