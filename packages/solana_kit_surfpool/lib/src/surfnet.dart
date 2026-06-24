import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:solana_kit_address_constants/solana_kit_address_constants.dart'
    show tokenProgramAddress;
import 'package:solana_kit_addresses/solana_kit_addresses.dart'
    show Address, getAddressFromPublicKey;
import 'package:solana_kit_associated_token_account/solana_kit_associated_token_account.dart';
import 'package:solana_kit_keys/solana_kit_keys.dart';
import 'package:solana_kit_surfpool/src/builders.dart';
import 'package:solana_kit_surfpool/src/config.dart';
import 'package:solana_kit_surfpool/src/errors.dart';
import 'package:solana_kit_surfpool/src/internal/hex.dart';
import 'package:solana_kit_surfpool/src/internal/json_rpc_client.dart';
import 'package:solana_kit_surfpool/src/types.dart';

const int _programChunkSize = 15 * 1024 * 1024;
const _defaultStartupTimeout = Duration(seconds: 30);
const _defaultShutdownTimeout = Duration(seconds: 5);
const _readinessPollInterval = Duration(milliseconds: 100);
const _maxBufferedEvents = 500;

/// A local Surfpool Surfnet controlled from Dart.
///
/// This implementation is intentionally pure Dart. `start` launches the
/// `surfpool` CLI and communicates with the Surfnet over Surfpool's JSON-RPC
/// cheatcode methods. It does not embed the Rust runtime in-process, so runtime
/// events are best-effort CLI log events rather than the upstream SDK's native
/// event channel.
class Surfnet {
  Surfnet._({
    required this.rpcUri,
    required this.wsUri,
    required this.payer,
    required Uint8List payerSecretKey,
    required this.instanceId,
    required http.Client client,
    required bool closeClientOnStop,
    Process? process,
  }) : _payerSecretKey = Uint8List.fromList(payerSecretKey),
       _client = client,
       // ignore: prefer_initializing_formals
       _closeClientOnStop = closeClientOnStop,
       _process = process,
       _exitCodeFuture = process?.exitCode,
       _rpcClient = SurfpoolJsonRpcClient(url: rpcUri, client: client) {
    final exitCodeFuture = _exitCodeFuture;
    if (exitCodeFuture != null) {
      unawaited(exitCodeFuture.then((exitCode) => _exitCode = exitCode));
    }
  }

  /// Connects to an already-running Surfpool JSON-RPC endpoint.
  ///
  /// If [payer] is omitted, a fresh keypair is generated for the metadata
  /// fields. That generated payer is not automatically funded on the connected
  /// Surfnet; pass a known funded payer when tests need to sign transactions.
  factory Surfnet.connect({
    required Uri rpcUrl,
    Uri? wsUrl,
    KeypairInfo? payer,
    String? instanceId,
    http.Client? client,
  }) {
    final effectivePayer = payer ?? newKeypair();
    final effectiveClient = client ?? http.Client();
    return Surfnet._(
      rpcUri: rpcUrl,
      wsUri: wsUrl ?? _defaultWsUrlFor(rpcUrl),
      payer: effectivePayer.publicKey,
      payerSecretKey: effectivePayer.secretKey,
      instanceId: instanceId ?? _newInstanceId(),
      client: effectiveClient,
      closeClientOnStop: client == null,
    );
  }

  /// Starts a CLI-backed Surfnet with the upstream SDK defaults.
  ///
  /// Pass [command] when the `surfpool` binary is not on `PATH`. The command is
  /// executed as `command start ...`.
  static Future<Surfnet> start({
    SurfnetConfig? config,
    String command = 'surfpool',
    Duration startupTimeout = _defaultStartupTimeout,
    http.Client? client,
  }) {
    return startWithConfig(
      config ?? SurfnetConfig(),
      command: command,
      startupTimeout: startupTimeout,
      client: client,
    );
  }

  /// Starts a CLI-backed Surfnet with [config].
  ///
  /// This mirrors the upstream JS `Surfnet.startWithConfig` shape but uses a
  /// separate `surfpool start` process instead of native napi bindings.
  static Future<Surfnet> startWithConfig(
    SurfnetConfig config, {
    String command = 'surfpool',
    Duration startupTimeout = _defaultStartupTimeout,
    http.Client? client,
  }) async {
    final rpcPort = config.rpcPort ?? await _findAvailablePort();
    final wsPort = config.wsPort ?? await _findDistinctAvailablePort(rpcPort);
    // SurfnetConfig validates this for user-provided ports; keep the runtime
    // guard for future internal port selection changes.
    // coverage:ignore-start
    if (rpcPort == wsPort) {
      throw ArgumentError.value(wsPort, 'wsPort', 'must differ from rpcPort');
    }
    // coverage:ignore-end

    final payerInfo = _payerFromSecretKey(config.payerSecretKey);
    final args = _buildStartArgs(
      config,
      rpcPort: rpcPort,
      wsPort: wsPort,
      payer: payerInfo.publicKey,
    );

    final Process process;
    try {
      process = await Process.start(command, args);
    } on Object catch (error) {
      throw SurfnetProcessException(
        'Failed to start `$command start`',
        cause: error,
      );
    }

    final effectiveClient = client ?? http.Client();
    final surfnet = Surfnet._(
      rpcUri: Uri(scheme: 'http', host: config.host, port: rpcPort),
      wsUri: Uri(scheme: 'ws', host: config.host, port: wsPort),
      payer: payerInfo.publicKey,
      payerSecretKey: payerInfo.secretKey,
      instanceId: _newInstanceId(),
      client: effectiveClient,
      closeClientOnStop: client == null,
      process: process,
    ).._captureProcessOutput(process);

    try {
      await surfnet._waitForReady(startupTimeout);
      return surfnet;
    } on Object {
      await surfnet.stop();
      rethrow;
    }
  }

  /// Generates a new Solana keypair using workspace key primitives.
  static KeypairInfo newKeypair() {
    final keyPair = generateKeyPair();
    try {
      return _keypairInfoFromKeyPair(keyPair);
    } finally {
      keyPair.dispose();
    }
  }

  /// HTTP RPC URL for this Surfnet.
  final Uri rpcUri;

  /// WebSocket RPC URL for this Surfnet.
  final Uri wsUri;

  /// Payer address associated with this Surfnet.
  final Address payer;

  /// Unique identifier generated by this Dart wrapper.
  final String instanceId;

  /// HTTP RPC URL as a string, matching the upstream JS SDK property.
  String get rpcUrl => rpcUri.toString();

  /// WebSocket RPC URL as a string, matching the upstream JS SDK property.
  String get wsUrl => wsUri.toString();

  /// 64-byte Solana CLI-compatible payer secret key.
  Uint8List get payerSecretKey => Uint8List.fromList(_payerSecretKey);

  final Uint8List _payerSecretKey;
  final http.Client _client;
  final bool _closeClientOnStop;
  final Process? _process;
  final Future<int>? _exitCodeFuture;
  final SurfpoolJsonRpcClient _rpcClient;
  int? _exitCode;
  final List<SimnetEventValue> _events = <SimnetEventValue>[];
  final List<String> _processOutput = <String>[];

  StreamSubscription<String>? _stdoutSubscription;
  StreamSubscription<String>? _stderrSubscription;
  bool _stopped = false;

  /// Stops the CLI-backed Surfnet and releases owned resources.
  ///
  /// For instances created with `Surfnet.connect`, this only closes the HTTP client that
  /// the wrapper created internally. It does not stop an external Surfpool
  /// process.
  Future<void> stop({Duration timeout = _defaultShutdownTimeout}) async {
    if (_stopped) return;
    _stopped = true;

    final process = _process;
    final exitCodeFuture = _exitCodeFuture;
    if (process != null && exitCodeFuture != null) {
      process.kill(ProcessSignal.sigint);
      try {
        await exitCodeFuture.timeout(timeout);
      } on TimeoutException {
        process.kill();
        await exitCodeFuture.timeout(
          const Duration(seconds: 1),
          // Processes that ignore termination can outlive this wrapper; callers
          // should still get resource cleanup without waiting indefinitely.
          onTimeout: () => -1, // coverage:ignore-line
        );
      }
    }

    await _stdoutSubscription?.cancel();
    await _stderrSubscription?.cancel();

    if (_closeClientOnStop) {
      _client.close();
    }
  }

  /// Drains events captured by this Dart wrapper.
  ///
  /// CLI-backed Surfnet instances do not expose the upstream in-process event
  /// channel. This method returns best-effort `stdoutLog` and `stderrLog` events
  /// captured from the child process. Instances created with `Surfnet.connect` return an
  /// empty list unless future APIs attach an event source.
  List<SimnetEventValue> drainEvents() {
    final drained = List<SimnetEventValue>.unmodifiable(_events);
    _events.clear();
    return drained;
  }

  /// Executes a typed cheatcode builder.
  Future<Object?> execute(CheatcodeBuilder builder) {
    return _rpcClient.call(builder.method, builder.params);
  }

  /// Sets [address] to [lamports], creating it if necessary.
  Future<void> fundSol(Address address, int lamports) async {
    _assertNonNegative(lamports, 'lamports');
    await execute(SetAccount(address).withLamports(lamports));
  }

  /// Sets the lamport balances for several accounts.
  Future<void> fundSolMany(Iterable<SolAccountFunding> accounts) async {
    for (final account in accounts) {
      await fundSol(account.address, account.lamports);
    }
  }

  /// Sets arbitrary account state in one call.
  Future<void> setAccount(
    Address address,
    int lamports,
    Uint8List data,
    Address owner,
  ) async {
    _assertNonNegative(lamports, 'lamports');
    await execute(
      SetAccount(
        address,
      ).withLamports(lamports).withData(data).withOwner(owner),
    );
  }

  /// Funds the associated token account for [owner] and [mint].
  Future<void> fundToken(
    Address owner,
    Address mint,
    int amount, {
    Address tokenProgram = tokenProgramAddress,
  }) async {
    await setTokenBalance(owner, mint, amount, tokenProgram: tokenProgram);
  }

  /// Funds many owners with the same [mint] and [amount].
  Future<void> fundTokenMany(
    Iterable<Address> owners,
    Address mint,
    int amount, {
    Address tokenProgram = tokenProgramAddress,
  }) async {
    for (final owner in owners) {
      await fundToken(owner, mint, amount, tokenProgram: tokenProgram);
    }
  }

  /// Sets the token balance for [owner]'s associated token account.
  Future<void> setTokenBalance(
    Address owner,
    Address mint,
    int amount, {
    Address tokenProgram = tokenProgramAddress,
  }) async {
    _assertNonNegative(amount, 'amount');
    await _rpcClient.call('surfnet_setTokenAccount', <Object?>[
      owner.value,
      mint.value,
      <String, Object?>{'amount': amount},
      tokenProgram.value,
    ]);
  }

  /// Mutates advanced token-account fields.
  Future<void> setTokenAccount(
    Address owner,
    Address mint,
    SetTokenAccountUpdate update, {
    Address tokenProgram = tokenProgramAddress,
  }) async {
    await _rpcClient.call('surfnet_setTokenAccount', <Object?>[
      owner.value,
      mint.value,
      update.toJson(),
      tokenProgram.value,
    ]);
  }

  /// Derives the associated token account for [owner] and [mint].
  Address getAta(
    Address owner,
    Address mint, {
    Address tokenProgram = tokenProgramAddress,
  }) {
    return getAssociatedTokenAddressSync(
      owner: owner,
      tokenProgram: tokenProgram,
      mint: mint,
    );
  }

  /// Resets an account to upstream state, when an upstream RPC is configured.
  Future<void> resetAccount(
    Address address, {
    ResetAccountOptions? options,
  }) async {
    await execute(
      ResetAccount(
        address,
        includeOwnedAccounts: options?.includeOwnedAccounts,
      ),
    );
  }

  /// Streams an account from the upstream RPC, when an upstream RPC is configured.
  Future<void> streamAccount(
    Address address, {
    StreamAccountOptions? options,
  }) async {
    await execute(
      StreamAccount(
        address,
        includeOwnedAccounts: options?.includeOwnedAccounts,
      ),
    );
  }

  /// Moves the local clock forward to [slot].
  Future<EpochInfoValue> timeTravelToSlot(int slot) async {
    _assertNonNegative(slot, 'slot');
    final result = await _rpcClient.call('surfnet_timeTravel', <Object?>[
      <String, Object?>{'absoluteSlot': slot},
    ]);
    return EpochInfoValue.fromJson(result);
  }

  /// Moves the local clock forward to [epoch].
  Future<EpochInfoValue> timeTravelToEpoch(int epoch) async {
    _assertNonNegative(epoch, 'epoch');
    final result = await _rpcClient.call('surfnet_timeTravel', <Object?>[
      <String, Object?>{'absoluteEpoch': epoch},
    ]);
    return EpochInfoValue.fromJson(result);
  }

  /// Moves the local clock forward to [timestampMs].
  Future<EpochInfoValue> timeTravelToTimestamp(int timestampMs) async {
    _assertNonNegative(timestampMs, 'timestampMs');
    final result = await _rpcClient.call('surfnet_timeTravel', <Object?>[
      <String, Object?>{'absoluteTimestamp': timestampMs},
    ]);
    return EpochInfoValue.fromJson(result);
  }

  /// Deploys a program from conventional Anchor/Agave artifacts.
  ///
  /// Looks for `target/deploy/{programName}.so`,
  /// `target/deploy/{programName}-keypair.json`, and optional
  /// `target/idl/{programName}.json` starting at [workingDirectory] and then
  /// walking ancestors. `CARGO_TARGET_DIR` is checked first when set.
  Future<Address> deployProgram(
    String programName, {
    String? workingDirectory,
  }) async {
    final artifacts = await _discoverProgramArtifacts(
      programName,
      workingDirectory: workingDirectory ?? Directory.current.path,
    );
    final programId = await _readProgramIdFromKeypair(artifacts.keypairPath);
    return deploy(
      DeployOptions(
        programId: programId,
        soPath: artifacts.soPath,
        idlPath: artifacts.idlPath,
      ),
    );
  }

  /// Deploys a program from explicit [options].
  Future<Address> deploy(DeployOptions options) async {
    final bytes = await _readProgramBytes(options);
    var offset = 0;
    while (offset < bytes.length) {
      final nextOffset = offset + _programChunkSize;
      final end = nextOffset > bytes.length ? bytes.length : nextOffset;
      final chunk = Uint8List.sublistView(bytes, offset, end);
      await _rpcClient.call('surfnet_writeProgram', <Object?>[
        options.programId.value,
        bytesToHex(chunk),
        offset,
      ]);
      offset = end;
    }

    final idlPath = options.idlPath;
    if (idlPath != null) {
      await _registerIdl(idlPath, options.programId);
    }

    return options.programId;
  }

  void _captureProcessOutput(Process process) {
    _stdoutSubscription = process.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen((line) => _recordProcessLine('stdoutLog', line));
    _stderrSubscription = process.stderr
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen((line) => _recordProcessLine('stderrLog', line));
  }

  void _recordProcessLine(String kind, String line) {
    final event = SimnetEventValue(
      kind: kind,
      message: line,
      timestamp: DateTime.now().toUtc().toIso8601String(),
    );
    _events.add(event);
    _processOutput.add('[$kind] $line');
    if (_events.length > _maxBufferedEvents) {
      _events.removeAt(0);
    }
    if (_processOutput.length > _maxBufferedEvents) {
      _processOutput.removeAt(0);
    }
  }

  Future<void> _waitForReady(Duration timeout) async {
    final deadline = DateTime.now().add(timeout);
    Object? lastError;

    while (DateTime.now().isBefore(deadline)) {
      final exitCode = await _exitCodeOrNull();
      if (exitCode != null) {
        throw SurfnetProcessException(
          '`surfpool start` exited before becoming ready with code $exitCode',
          cause: _recentProcessOutput(),
        );
      }

      try {
        await _rpcClient.call('getHealth');
        return;
      } on Object catch (error) {
        lastError = error;
      }

      await Future<void>.delayed(_readinessPollInterval);
    }

    throw SurfnetProcessException(
      'Timed out waiting for Surfpool RPC at $rpcUrl',
      cause: <String, Object?>{
        'lastError': lastError?.toString(),
        'processOutput': _recentProcessOutput(),
      },
    );
  }

  Future<int?> _exitCodeOrNull() async {
    final exitCode = _exitCode;
    if (exitCode != null) return exitCode;

    final exitCodeFuture = _exitCodeFuture;
    if (exitCodeFuture == null) return null;

    return exitCodeFuture
        .then<int?>((exitCode) => exitCode)
        .timeout(
          const Duration(milliseconds: 1),
          onTimeout: () => null,
        );
  }

  String _recentProcessOutput() {
    if (_processOutput.isEmpty) return '<no process output captured>';
    return _processOutput.join('\n');
  }

  Future<void> _registerIdl(String idlPath, Address programId) async {
    final content = await File(idlPath).readAsString();
    final Object? decoded;
    try {
      decoded = jsonDecode(content);
    } on FormatException catch (error) {
      throw SurfpoolException('Invalid IDL JSON at $idlPath', cause: error);
    }

    if (decoded is! Map) {
      throw SurfpoolException('IDL JSON at $idlPath must be an object');
    }

    final idl = decoded.cast<String, Object?>();
    idl['address'] = programId.value;
    await _rpcClient.call('surfnet_registerIdl', <Object?>[idl]);
  }
}

List<String> _buildStartArgs(
  SurfnetConfig config, {
  required int rpcPort,
  required int wsPort,
  required Address payer,
}) {
  return <String>[
    'start',
    '--port',
    '$rpcPort',
    '--ws-port',
    '$wsPort',
    '--host',
    config.host,
    '--no-tui',
    '--no-studio',
    '--block-production-mode',
    config.blockProductionMode.cliValue,
    '--slot-time',
    '${config.slotTimeMs}',
    '--airdrop-amount',
    '${config.airdropSol}',
    if (config.remoteRpcUrl != null) ...<String>[
      '--rpc-url',
      config.remoteRpcUrl.toString(),
    ] else if (config.offline)
      '--offline',
    '--airdrop',
    payer.value,
    for (final address in config.airdropAddresses) ...<String>[
      '--airdrop',
      address.value,
    ],
    for (final feature in config.enableFeatures) ...<String>[
      '--feature',
      feature.value,
    ],
    for (final feature in config.disableFeatures) ...<String>[
      '--disable-feature',
      feature.value,
    ],
    if (config.allFeatures) '--features-all',
    if (config.skipBlockhashCheck) '--skip-blockhash-check',
  ];
}

Future<int> _findAvailablePort() async {
  final socket = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
  final port = socket.port;
  await socket.close();
  return port;
}

Future<int> _findDistinctAvailablePort(int otherPort) async {
  while (true) {
    final port = await _findAvailablePort();
    if (port != otherPort) return port;
  }
}

KeypairInfo _payerFromSecretKey(Uint8List? payerSecretKey) {
  if (payerSecretKey == null) return Surfnet.newKeypair();
  return _keypairInfoFromSecretKey(payerSecretKey);
}

KeypairInfo _keypairInfoFromSecretKey(Uint8List secretKey) {
  final keyPair = createKeyPairFromBytes(secretKey);
  try {
    return _keypairInfoFromKeyPair(keyPair);
  } finally {
    keyPair.dispose();
  }
}

KeypairInfo _keypairInfoFromKeyPair(KeyPair keyPair) {
  final publicKey = keyPair.publicKey;
  final secretKey = Uint8List.fromList(<int>[
    ...keyPair.privateKey,
    ...publicKey,
  ]);
  return KeypairInfo(
    publicKey: getAddressFromPublicKey(publicKey),
    secretKey: secretKey,
  );
}

String _newInstanceId() {
  return 'surfnet-${DateTime.now().toUtc().microsecondsSinceEpoch}';
}

Uri _defaultWsUrlFor(Uri rpcUrl) {
  final scheme = switch (rpcUrl.scheme) {
    'https' => 'wss',
    _ => 'ws',
  };
  return rpcUrl.replace(scheme: scheme);
}

Future<_ProgramArtifacts> _discoverProgramArtifacts(
  String programName, {
  required String workingDirectory,
}) async {
  final targetDirs = _targetDirectories(workingDirectory);
  for (final targetDir in targetDirs) {
    final soPath = _joinPath(targetDir, 'deploy', '$programName.so');
    final keypairPath = _joinPath(
      targetDir,
      'deploy',
      '$programName-keypair.json',
    );
    if (File(soPath).existsSync() && File(keypairPath).existsSync()) {
      final idlPath = _joinPath(targetDir, 'idl', '$programName.json');
      return _ProgramArtifacts(
        soPath: soPath,
        keypairPath: keypairPath,
        idlPath: File(idlPath).existsSync() ? idlPath : null,
      );
    }
  }

  throw SurfpoolException(
    'Could not find target/deploy/$programName.so and '
    'target/deploy/$programName-keypair.json from $workingDirectory',
  );
}

List<String> _targetDirectories(String workingDirectory) {
  final seen = <String>{};
  final dirs = <String>[];

  final cargoTargetDir = Platform.environment['CARGO_TARGET_DIR'];
  // This branch depends on process-level environment and is exercised in user
  // builds that set CARGO_TARGET_DIR; unit tests cover the default search path.
  // coverage:ignore-start
  if (cargoTargetDir != null && cargoTargetDir.isNotEmpty) {
    seen.add(cargoTargetDir);
    dirs.add(cargoTargetDir);
  }
  // coverage:ignore-end

  var directory = Directory(workingDirectory).absolute;
  while (true) {
    final targetDir = _joinPath(directory.path, 'target');
    if (seen.add(targetDir)) dirs.add(targetDir);

    final parent = directory.parent;
    if (parent.path == directory.path) break;
    directory = parent;
  }

  return dirs;
}

Future<Address> _readProgramIdFromKeypair(String keypairPath) async {
  final content = await File(keypairPath).readAsString();
  final Object? decoded;
  try {
    decoded = jsonDecode(content);
  } on FormatException catch (error) {
    throw SurfpoolException(
      'Invalid keypair JSON at $keypairPath',
      cause: error,
    );
  }

  if (decoded is! List) {
    throw SurfpoolException(
      'Keypair JSON at $keypairPath must be a byte array',
    );
  }

  final bytes = Uint8List(decoded.length);
  for (var index = 0; index < decoded.length; index++) {
    final value = decoded[index];
    if (value is! int || value < 0 || value > 255) {
      throw SurfpoolException(
        'Keypair byte at index $index in $keypairPath must be 0..255',
      );
    }
    bytes[index] = value;
  }

  return _keypairInfoFromSecretKey(bytes).publicKey;
}

Future<Uint8List> _readProgramBytes(DeployOptions options) async {
  final soBytes = options.soBytes;
  if (soBytes != null) return soBytes;

  final soPath = options.soPath;
  if (soPath == null) {
    throw const SurfpoolException('DeployOptions must include program bytes');
  }

  return File(soPath).readAsBytes();
}

String _joinPath(String first, String second, [String? third]) {
  final withSecond = _appendPath(first, second);
  if (third == null) return withSecond;
  return _appendPath(withSecond, third);
}

String _appendPath(String base, String part) {
  if (base.endsWith(Platform.pathSeparator)) return '$base$part';
  return '$base${Platform.pathSeparator}$part';
}

void _assertNonNegative(int value, String name) {
  if (value < 0) {
    throw ArgumentError.value(value, name, 'must be non-negative');
  }
}

@immutable
class _ProgramArtifacts {
  const _ProgramArtifacts({
    required this.soPath,
    required this.keypairPath,
    required this.idlPath,
  });

  final String soPath;
  final String keypairPath;
  final String? idlPath;
}
