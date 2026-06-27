import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_surfpool/solana_kit_surfpool.dart';
import 'package:test/test.dart';

void main() {
  group('Surfnet', () {
    const account = Address('11111111111111111111111111111111');
    const owner = Address('BPFLoaderUpgradeab1e11111111111111111111111');
    const mint = Address('EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v');

    test(
      'connect exposes default URLs, payer metadata, and empty events',
      () async {
        final payer = Surfnet.newKeypair();
        final surfnet = Surfnet.connect(
          rpcUrl: Uri.parse('https://localhost:8899/rpc'),
          payer: payer,
          instanceId: 'test-instance',
          client: MockClient((_) async => http.Response('{}', 200)),
        );

        expect(surfnet.rpcUri, Uri.parse('https://localhost:8899/rpc'));
        expect(surfnet.wsUri, Uri.parse('wss://localhost:8899/rpc'));
        expect(surfnet.rpcUrl, 'https://localhost:8899/rpc');
        expect(surfnet.wsUrl, 'wss://localhost:8899/rpc');
        expect(surfnet.payer, payer.publicKey);
        expect(surfnet.payerSecretKey, payer.secretKey);
        final generatedMetadataSurfnet = Surfnet.connect(
          rpcUrl: Uri.parse('http://localhost:8899'),
        );

        expect(surfnet.instanceId, 'test-instance');
        expect(surfnet.drainEvents(), isEmpty);
        expect(generatedMetadataSurfnet.wsUrl, 'ws://localhost:8899');
        expect(generatedMetadataSurfnet.payer.value, isNotEmpty);
        await surfnet.stop();
        await surfnet.stop();
        await generatedMetadataSurfnet.stop();
      },
    );

    test('newKeypair returns address and defensive secret key copies', () {
      final keypair = Surfnet.newKeypair();

      expect(keypair.publicKey.value, isNotEmpty);
      expect(keypair.address, keypair.publicKey);
      expect(keypair.secretKey, hasLength(64));

      final secretKey = keypair.secretKey;
      final firstByte = secretKey.first;
      secretKey[0] = firstByte ^ 0xff;

      expect(keypair.secretKey.first, firstByte);
    });

    test('serializes common cheatcode methods', () async {
      final requests = <Map<String, Object?>>[];
      final surfnet = _mockSurfnet(requests);

      await surfnet.fundSol(account, 123);
      await surfnet.fundSolMany(const <SolAccountFunding>[
        SolAccountFunding(address: account, lamports: 124),
      ]);
      await surfnet.setAccount(
        account,
        456,
        Uint8List.fromList(<int>[1, 2, 255]),
        owner,
      );
      await surfnet.fundToken(account, mint, 789);
      await surfnet.fundTokenMany(<Address>[owner], mint, 790);
      await surfnet.setTokenAccount(
        account,
        mint,
        const SetTokenAccountUpdate(clearDelegate: true),
      );
      await surfnet.resetAccount(
        account,
        options: const ResetAccountOptions(includeOwnedAccounts: true),
      );
      await surfnet.streamAccount(account);
      await surfnet.streamAccount(
        account,
        options: const StreamAccountOptions(includeOwnedAccounts: false),
      );
      await surfnet.execute(SetAccount(account).withLamports(1));
      final ata = surfnet.getAta(account, mint);

      expect(ata.value, isNotEmpty);
      expect(requests[0]['method'], 'surfnet_setAccount');
      expect(requests[0]['params'], <Object?>[
        account.value,
        <String, Object?>{'lamports': 123},
      ]);

      expect(requests[1]['params'], <Object?>[
        account.value,
        <String, Object?>{'lamports': 124},
      ]);

      expect(requests[2]['params'], <Object?>[
        account.value,
        <String, Object?>{
          'lamports': 456,
          'data': '0102ff',
          'owner': owner.value,
        },
      ]);

      expect(requests[3]['params'], <Object?>[
        account.value,
        mint.value,
        <String, Object?>{'amount': 789},
        tokenProgramAddress.value,
      ]);

      expect(requests[4]['params'], <Object?>[
        owner.value,
        mint.value,
        <String, Object?>{'amount': 790},
        tokenProgramAddress.value,
      ]);

      expect(requests[5]['params'], <Object?>[
        account.value,
        mint.value,
        <String, Object?>{'delegate': 'null'},
        tokenProgramAddress.value,
      ]);

      expect(requests[6]['method'], 'surfnet_resetAccount');
      expect(requests[6]['params'], <Object?>[
        account.value,
        <String, Object?>{'includeOwnedAccounts': true},
      ]);

      expect(requests[7]['method'], 'surfnet_streamAccount');
      expect(requests[7]['params'], <Object?>[account.value]);
      expect(requests[8]['params'], <Object?>[
        account.value,
        <String, Object?>{'includeOwnedAccounts': false},
      ]);
      expect(requests[9]['method'], 'surfnet_setAccount');
    });

    test('rejects negative balances and time travel inputs', () async {
      final surfnet = _mockSurfnet(<Map<String, Object?>>[]);

      await expectLater(
        surfnet.fundSol(account, -1),
        throwsA(isA<ArgumentError>()),
      );
      await expectLater(
        surfnet.setAccount(account, -1, Uint8List(0), owner),
        throwsA(isA<ArgumentError>()),
      );
      await expectLater(
        surfnet.setTokenBalance(account, mint, -1),
        throwsA(isA<ArgumentError>()),
      );
      await expectLater(
        surfnet.timeTravelToSlot(-1),
        throwsA(isA<ArgumentError>()),
      );
      await expectLater(
        surfnet.timeTravelToEpoch(-1),
        throwsA(isA<ArgumentError>()),
      );
      await expectLater(
        surfnet.timeTravelToTimestamp(-1),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('parses time travel epoch info', () async {
      final requests = <Map<String, Object?>>[];
      final surfnet = _mockSurfnet(
        requests,
        resultForMethod: (method) => method == 'surfnet_timeTravel'
            ? <String, Object?>{
                'absoluteSlot': 1_000,
                'slotIndex': 8,
                'slotsInEpoch': 32,
                'epoch': 31,
                'blockHeight': 999,
              }
            : null,
      );

      final slotInfo = await surfnet.timeTravelToSlot(1_000);
      final epochInfo = await surfnet.timeTravelToEpoch(31);
      final timestampInfo = await surfnet.timeTravelToTimestamp(
        1_700_000_000_000,
      );

      expect(slotInfo.absoluteSlot, 1_000);
      expect(epochInfo.epoch, 31);
      expect(timestampInfo.blockHeight, 999);
      expect(requests[0]['params'], <Object?>[
        <String, Object?>{'absoluteSlot': 1_000},
      ]);
      expect(requests[1]['params'], <Object?>[
        <String, Object?>{'absoluteEpoch': 31},
      ]);
      expect(requests[2]['params'], <Object?>[
        <String, Object?>{'absoluteTimestamp': 1_700_000_000_000},
      ]);
    });

    test('deploy writes inline bytes and skips optional IDL', () async {
      final requests = <Map<String, Object?>>[];
      final surfnet = _mockSurfnet(requests);

      final programId = await surfnet.deploy(
        DeployOptions(
          programId: account,
          soBytes: Uint8List.fromList(<int>[7]),
        ),
      );
      final emptyProgramId = await surfnet.deploy(
        DeployOptions(programId: owner, soBytes: Uint8List(0)),
      );

      expect(programId, account);
      expect(emptyProgramId, owner);
      expect(requests.single['params'], <Object?>[account.value, '07', 0]);
    });

    test('deploy writes bytes and registers IDL', () async {
      final requests = <Map<String, Object?>>[];
      final surfnet = _mockSurfnet(requests);
      final tempDir = await Directory.systemTemp.createTemp('surfpool_deploy_');

      try {
        final soFile = File('${tempDir.path}/demo.so');
        final idlFile = File('${tempDir.path}/demo.json');
        await soFile.writeAsBytes(<int>[0, 15, 255]);
        await idlFile.writeAsString(
          jsonEncode(<String, Object?>{'name': 'demo'}),
        );

        final programId = await surfnet.deploy(
          DeployOptions(
            programId: account,
            soPath: soFile.path,
            idlPath: idlFile.path,
          ),
        );

        expect(programId, account);
        expect(requests[0]['method'], 'surfnet_writeProgram');
        expect(requests[0]['params'], <Object?>[account.value, '000fff', 0]);
        expect(requests[1]['method'], 'surfnet_registerIdl');
        expect(requests[1]['params'], <Object?>[
          <String, Object?>{'name': 'demo', 'address': account.value},
        ]);
      } finally {
        await tempDir.delete(recursive: true);
      }
    });

    test('deploy rejects invalid IDL JSON', () async {
      final requests = <Map<String, Object?>>[];
      final surfnet = _mockSurfnet(requests);
      final tempDir = await Directory.systemTemp.createTemp(
        'surfpool_bad_idl_',
      );

      try {
        final invalidIdl = File('${tempDir.path}/invalid.json');
        final listIdl = File('${tempDir.path}/list.json');
        await invalidIdl.writeAsString('not json');
        await listIdl.writeAsString('[]');

        await expectLater(
          surfnet.deploy(
            DeployOptions(
              programId: account,
              soBytes: Uint8List(0),
              idlPath: invalidIdl.path,
            ),
          ),
          throwsA(isA<SurfpoolException>()),
        );
        await expectLater(
          surfnet.deploy(
            DeployOptions(
              programId: account,
              soBytes: Uint8List(0),
              idlPath: listIdl.path,
            ),
          ),
          throwsA(isA<SurfpoolException>()),
        );
      } finally {
        await tempDir.delete(recursive: true);
      }
    });

    test(
      'deployProgram discovers target artifacts and derives program id',
      () async {
        final requests = <Map<String, Object?>>[];
        final surfnet = _mockSurfnet(requests);
        final tempDir = await Directory.systemTemp.createTemp(
          'surfpool_program_',
        );

        try {
          final deployDir = Directory('${tempDir.path}/target/deploy');
          final idlDir = Directory('${tempDir.path}/target/idl');
          await deployDir.create(recursive: true);
          await idlDir.create(recursive: true);

          final keypair = Surfnet.newKeypair();
          await File('${deployDir.path}/demo.so').writeAsBytes(<int>[1, 2, 3]);
          await File(
            '${deployDir.path}/demo-keypair.json',
          ).writeAsString(jsonEncode(keypair.secretKey));
          await File(
            '${idlDir.path}/demo.json',
          ).writeAsString(jsonEncode(<String, Object?>{'name': 'demo'}));

          final previousCurrent = Directory.current;
          late final Address programId;
          try {
            Directory.current = tempDir;
            programId = await surfnet.deployProgram('demo');
          } finally {
            Directory.current = previousCurrent;
          }

          expect(programId, keypair.publicKey);
          expect(requests[0]['params'], <Object?>[
            keypair.publicKey.value,
            '010203',
            0,
          ]);
          expect(requests[1]['params'], <Object?>[
            <String, Object?>{
              'name': 'demo',
              'address': keypair.publicKey.value,
            },
          ]);
        } finally {
          await tempDir.delete(recursive: true);
        }
      },
    );

    test('deployProgram reports missing and malformed artifacts', () async {
      final surfnet = _mockSurfnet(<Map<String, Object?>>[]);
      final tempDir = await Directory.systemTemp.createTemp(
        'surfpool_missing_',
      );

      Future<void> writeArtifacts(Object? keypairJson) async {
        final deployDir = Directory('${tempDir.path}/target/deploy');
        await deployDir.create(recursive: true);
        await File('${deployDir.path}/demo.so').writeAsBytes(<int>[1]);
        await File(
          '${deployDir.path}/demo-keypair.json',
        ).writeAsString(jsonEncode(keypairJson));
      }

      try {
        await expectLater(
          surfnet.deployProgram('missing', workingDirectory: tempDir.path),
          throwsA(isA<SurfpoolException>()),
        );

        await writeArtifacts('not a list');
        await expectLater(
          surfnet.deployProgram('demo', workingDirectory: tempDir.path),
          throwsA(isA<SurfpoolException>()),
        );

        await writeArtifacts(<Object?>[999]);
        await expectLater(
          surfnet.deployProgram('demo', workingDirectory: tempDir.path),
          throwsA(isA<SurfpoolException>()),
        );

        await File(
          '${tempDir.path}/target/deploy/demo-keypair.json',
        ).writeAsString('not json');
        await expectLater(
          surfnet.deployProgram('demo', workingDirectory: tempDir.path),
          throwsA(isA<SurfpoolException>()),
        );
      } finally {
        await tempDir.delete(recursive: true);
      }
    });

    test('start reports missing CLI commands', () async {
      await expectLater(
        Surfnet.start(command: '${Directory.systemTemp.path}/missing-surfpool'),
        throwsA(isA<SurfnetProcessException>()),
      );
    });

    test(
      'start launches a CLI-backed Surfnet and captures process output',
      () async {
        final tempDir = await Directory.systemTemp.createTemp('surfpool_cli_');
        final argsPath = '${tempDir.path}/args.json';
        final command = await _writeFakeSurfpoolCommand(
          tempDir,
          argsPath: argsPath,
          outputLines: 505,
        );
        final payer = Surfnet.newKeypair();
        final rpcPort = await _availablePort();
        final wsPort = await _availablePort(except: rpcPort);
        final config = SurfnetConfig(
          remoteRpcUrl: Uri.parse('https://api.mainnet-beta.solana.com'),
          blockProductionMode: BlockProductionMode.clock,
          slotTimeMs: 2,
          airdropSol: 3,
          airdropAddresses: const <Address>[account],
          payerSecretKey: payer.secretKey,
          enableFeatures: const <Address>[owner],
          disableFeatures: const <Address>[mint],
          allFeatures: true,
          skipBlockhashCheck: true,
          rpcPort: rpcPort,
          wsPort: wsPort,
        );

        try {
          final surfnet = await Surfnet.startWithConfig(
            config,
            command: command,
            startupTimeout: const Duration(seconds: 5),
          );
          await Future<void>.delayed(const Duration(milliseconds: 250));
          final events = surfnet.drainEvents();
          await surfnet.stop();

          final args = (jsonDecode(await File(argsPath).readAsString()) as List)
              .cast<String>();
          expect(surfnet.rpcUri, Uri.parse('http://127.0.0.1:$rpcPort'));
          expect(surfnet.wsUri, Uri.parse('ws://127.0.0.1:$wsPort'));
          expect(surfnet.payer, payer.publicKey);
          expect(surfnet.payerSecretKey, payer.secretKey);
          expect(surfnet.instanceId, startsWith('surfnet-'));
          expect(events.length, lessThanOrEqualTo(500));
          expect(events.map((event) => event.kind), contains('stdoutLog'));
          expect(events.map((event) => event.kind), contains('stderrLog'));
          expect(
            args,
            containsAllInOrder(<String>[
              'start',
              '--port',
              '$rpcPort',
              '--ws-port',
              '$wsPort',
              '--host',
              '127.0.0.1',
              '--no-tui',
              '--no-studio',
              '--block-production-mode',
              'clock',
              '--slot-time',
              '2',
              '--airdrop-amount',
              '3',
              '--rpc-url',
              'https://api.mainnet-beta.solana.com',
              '--airdrop',
              payer.publicKey.value,
              '--airdrop',
              account.value,
              '--feature',
              owner.value,
              '--disable-feature',
              mint.value,
              '--features-all',
              '--skip-blockhash-check',
            ]),
          );
        } finally {
          await tempDir.delete(recursive: true);
        }
      },
    );

    test('start reports early process exit and readiness timeouts', () async {
      final exitTempDir = await Directory.systemTemp.createTemp(
        'surfpool_cli_exit_',
      );
      final timeoutTempDir = await Directory.systemTemp.createTemp(
        'surfpool_cli_timeout_',
      );
      final exitCommand = await _writeFakeSurfpoolCommand(
        exitTempDir,
        argsPath: '${exitTempDir.path}/args.json',
        exitImmediately: true,
      );
      final timeoutCommand = await _writeFakeSurfpoolCommand(
        timeoutTempDir,
        argsPath: '${timeoutTempDir.path}/args.json',
        serveRpc: false,
      );
      final exitRpcPort = await _availablePort();
      final exitWsPort = await _availablePort(except: exitRpcPort);
      final timeoutRpcPort = await _availablePort();
      final timeoutWsPort = await _availablePort(except: timeoutRpcPort);

      try {
        await expectLater(
          Surfnet.startWithConfig(
            SurfnetConfig(rpcPort: exitRpcPort, wsPort: exitWsPort),
            command: exitCommand,
            startupTimeout: const Duration(seconds: 1),
          ),
          throwsA(
            isA<SurfnetProcessException>().having(
              (error) => error.message,
              'message',
              anyOf(
                contains('exited before becoming ready'),
                contains('Timed out waiting for Surfpool RPC'),
              ),
            ),
          ),
        );
        await expectLater(
          Surfnet.startWithConfig(
            SurfnetConfig(rpcPort: timeoutRpcPort, wsPort: timeoutWsPort),
            command: timeoutCommand,
            startupTimeout: const Duration(milliseconds: 150),
          ),
          throwsA(isA<SurfnetProcessException>()),
        );
      } finally {
        await exitTempDir.delete(recursive: true);
        await timeoutTempDir.delete(recursive: true);
      }
    });

    test('stop escalates when a process ignores SIGINT', () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'surfpool_cli_stop_',
      );
      final command = await _writeFakeSurfpoolCommand(
        tempDir,
        argsPath: '${tempDir.path}/args.json',
        ignoreSigint: true,
      );
      final rpcPort = await _availablePort();
      final wsPort = await _availablePort(except: rpcPort);

      try {
        final surfnet = await Surfnet.startWithConfig(
          SurfnetConfig(rpcPort: rpcPort, wsPort: wsPort),
          command: command,
          startupTimeout: const Duration(seconds: 5),
        );

        await surfnet.stop(timeout: const Duration(milliseconds: 1));
      } finally {
        await tempDir.delete(recursive: true);
      }
    });
  });
}

Surfnet _mockSurfnet(
  List<Map<String, Object?>> requests, {
  Object? Function(String method)? resultForMethod,
}) {
  return Surfnet.connect(
    rpcUrl: Uri.parse('http://127.0.0.1:8899'),
    wsUrl: Uri.parse('ws://127.0.0.1:8900'),
    client: MockClient((request) async {
      final body = jsonDecode(request.body) as Map<String, Object?>;
      requests.add(body);
      return http.Response(
        jsonEncode(<String, Object?>{
          'jsonrpc': '2.0',
          'id': body['id'],
          'result': resultForMethod?.call(body['method']! as String),
        }),
        200,
      );
    }),
  );
}

Future<int> _availablePort({int? except}) async {
  while (true) {
    final socket = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
    final port = socket.port;
    await socket.close();
    if (port != except) return port;
  }
}

Future<String> _writeFakeSurfpoolCommand(
  Directory directory, {
  required String argsPath,
  bool serveRpc = true,
  bool exitImmediately = false,
  bool ignoreSigint = false,
  int outputLines = 1,
}) async {
  final script = File('${directory.path}/fake_surfpool.dart');
  final content =
      // ignore: leading_newlines_in_multiline_strings
      '''#!/usr/bin/env dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> args) async {
  await File(${jsonEncode(argsPath)}).writeAsString(jsonEncode(args));

  for (var index = 0; index < $outputLines; index += 1) {
    stdout.writeln('stdout line \$index');
  }
  stderr.writeln('stderr line');
  if ($exitImmediately) {
    await stdout.flush();
    await stderr.flush();
    exit(9);
  }

  HttpServer? server;
  if ($serveRpc) {
    final port = int.parse(args[args.indexOf('--port') + 1]);
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
  }

  if ($ignoreSigint) {
    ProcessSignal.sigint.watch().listen((_) => stderr.writeln('ignored sigint'));
  } else {
    ProcessSignal.sigint.watch().listen((_) async {
      await server?.close(force: true);
      exit(0);
    });
  }

  if (!$serveRpc) {
    await Completer<void>().future;
    return;
  }

  await for (final request in server!) {
    final body = await utf8.decoder.bind(request).join();
    final payload = jsonDecode(body) as Map<String, Object?>;
    request.response.headers.contentType = ContentType.json;
    request.response.write(jsonEncode(<String, Object?>{
      'jsonrpc': '2.0',
      'id': payload['id'],
      'result': 'ok',
    }));
    await request.response.close();
  }
}
''';

  await script.writeAsString(content);
  final chmod = await Process.run('chmod', <String>['755', script.path]);
  if (chmod.exitCode != 0) {
    throw StateError('Failed to chmod fake Surfpool command: ${chmod.stderr}');
  }
  return script.path;
}
