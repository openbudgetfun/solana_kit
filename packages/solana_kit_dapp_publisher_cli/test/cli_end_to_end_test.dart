import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart'
    hide tokenMetadataProgramAddress;
import 'package:solana_kit_dapp_publisher_cli/src/cli.dart';
import 'package:solana_kit_keys/solana_kit_keys.dart';
import 'package:solana_kit_mpl_token_metadata/solana_kit_mpl_token_metadata.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';
import 'package:solana_kit_transactions/solana_kit_transactions.dart';
import 'package:test/test.dart';

final KeyPair publisherKeypair = generateKeyPair();
final KeyPair mintKeypair = generateKeyPair();
final KeyPair appMintKeypair = generateKeyPair();
final KeyPair collectionAuthorityKeypair = generateKeyPair();
final KeyPair blockhashKeypair = generateKeyPair();

final publisherAddress = getAddressFromPublicKey(
  publisherKeypair.publicKey,
).toString();
final mintAddress = getAddressFromPublicKey(mintKeypair.publicKey).toString();
final appMintAddress = getAddressFromPublicKey(
  appMintKeypair.publicKey,
).toString();
final collectionAuthorityAddress = getAddressFromPublicKey(
  collectionAuthorityKeypair.publicKey,
).toString();
final blockhash = getAddressFromPublicKey(
  blockhashKeypair.publicKey,
).toString();

Address get tokenMetadataProgram =>
    const Address('metaqbxxUerdq28cj1RbAWkYQm3ybzjb6a8bt518x1s');

const _apiKey = 'e2e-api-key';

final _uploadedFiles = <String, Uint8List>{};

Future<String> _metadataPdaFor(String mint) async =>
    (await findMetadataPda(mint: Address(mint))).$1.toString();

Future<String> _masterEditionFor(String mint) async =>
    (await findMasterEditionPda(mint: Address(mint))).$1.toString();

Map<String, Object?> _trpcOk(Object data) => {
  'result': {'data': data},
};

Map<String, Object?> backendBundle() => {
  'ingestionSessionId': 'ing-1',
  'publicationSessionId': 'pub-1',
  'releaseId': 'rel-1',
  'release': {
    'id': 'rel-1',
    'dappId': 'dapp-1',
    'androidPackage': 'com.example.app',
    'versionName': '1.2.0',
    'versionCode': 120,
    'newInVersion': 'Faster',
    'localizedName': 'My App',
    'releaseFileName': 'release.apk',
    'releaseFileSize': 4,
    'nftMetadataUri': 'https://public.example.com/meta.json',
  },
  'dapp': {
    'id': 'dapp-1',
    'dappName': 'My App',
    'description': 'Long description',
    'androidPackage': 'com.example.app',
    'dappIconUrl': 'https://public.example.com/icon.png',
    'dappPreviewUrls': <String>[],
    'walletAddress': publisherAddress,
    'nftMintAddress': appMintAddress,
    'languages': ['en-US'],
  },
  'publisher': {
    'id': 'pub-1',
    'type': 'organization',
    'name': 'Example Inc',
    'website': 'https://example.com',
    'email': 'contact@example.com',
    'supportEmail': 'support@example.com',
  },
  'installFile': {
    'uri': 'https://public.example.com/release.apk',
    'mimeType': 'application/vnd.android.package-archive',
    'size': 4,
    'sha256': 'hash',
  },
  'signerAuthority': {
    'dappWalletAddress': publisherAddress,
    'collectionAuthority': collectionAuthorityAddress,
    'appMintAddress': appMintAddress,
    'acceptedSignerRoles': ['publisher', 'payer'],
    'feePayer': publisherAddress,
  },
};

Future<Transaction> buildReleaseMintTransaction() async {
  final metadataPda = Address(await _metadataPdaFor(mintAddress));
  final instructionData = getCreateInstructionDataEncoder().encode(
    CreateInstructionData(
      createArgs: CreateArgsV1(
        assetData: AssetData(
          name: 'Release',
          symbol: '',
          uri: 'https://meta.example.com/rel-1.json',
          sellerFeeBasisPoints: 0,
          creators: null,
          primarySaleHappened: false,
          isMutable: true,
          tokenStandard: TokenStandard.nonFungible,
          collection: Collection(key: Address(appMintAddress), verified: false),
          uses: null,
          collectionDetails: null,
          ruleSet: null,
        ),
        decimals: null,
        printSupply: null,
      ),
    ),
  );
  final messageBytes = getCompiledTransactionMessageEncoder().encode(
    CompiledTransactionMessage(
      version: TransactionVersion.legacy,
      header: const MessageHeader(
        numSignerAccounts: 2,
        numReadonlySignerAccounts: 1,
        numReadonlyNonSignerAccounts: 3,
      ),
      staticAccounts: [
        Address(publisherAddress),
        Address(mintAddress),
        tokenMetadataProgram,
        metadataPda,
        const Address('11111111111111111111111111111111'),
      ],
      instructions: [
        CompiledInstruction(
          programAddressIndex: 2,
          accountIndices: const [0, 1, 3, 4],
          data: instructionData,
        ),
      ],
      lifetimeToken: blockhash,
    ),
  );
  return Transaction(
    messageBytes: messageBytes,
    signatures: {
      Address(publisherAddress): null,
      Address(mintAddress): SignatureBytes(
        signBytes(mintKeypair.privateKey, messageBytes).value,
      ),
    },
  );
}

Future<Transaction> buildVerifyCollectionTransaction() async {
  final nftMetadataPda = Address(await _metadataPdaFor(mintAddress));
  final accounts = <Address>[
    Address(publisherAddress),
    Address(collectionAuthorityAddress),
    tokenMetadataProgram,
    nftMetadataPda,
    Address(appMintAddress),
    Address(await _metadataPdaFor(appMintAddress)),
    Address(await _masterEditionFor(appMintAddress)),
  ];
  final messageBytes = getCompiledTransactionMessageEncoder().encode(
    CompiledTransactionMessage(
      version: TransactionVersion.legacy,
      header: const MessageHeader(
        numSignerAccounts: 2,
        numReadonlySignerAccounts: 0,
        numReadonlyNonSignerAccounts: 5,
      ),
      staticAccounts: accounts,
      instructions: [
        CompiledInstruction(
          programAddressIndex: 2,
          accountIndices: const [0, 1, 3, 4],
          data: Uint8List.fromList([25, 1, 2, 3]),
        ),
      ],
      lifetimeToken: blockhash,
    ),
  );
  return Transaction(
    messageBytes: messageBytes,
    signatures: {
      Address(publisherAddress): null,
      Address(collectionAuthorityAddress): null,
    },
  );
}

class MockPortalServer {
  MockPortalServer(this.server);

  final HttpServer server;
  final signedTransactions = <Map<String, Object?>>[];
  final submittedToStore = <Map<String, Object?>>[];

  Uri get host => Uri.parse('http://127.0.0.1:${server.port}');

  Future<void> handle() async {
    await for (final request in server) {
      try {
        await _respond(request);
      } on Object {
        request.response.statusCode = 500;
        await request.response.close();
      }
    }
  }

  Future<void> _respond(HttpRequest request) async {
    final path = request.uri.path;
    if (path.contains('/rpc')) {
      final body =
          jsonDecode(utf8.decode(await _body(request))) as Map<String, Object?>;
      if (body['method'] == 'getBalance') {
        await _json(request, {
          'jsonrpc': '2.0',
          'result': {
            'context': {'slot': 1},
            'value': 100000000,
          },
          'id': body['id'],
        });
        return;
      }
      await _json(request, {'jsonrpc': '2.0', 'error': 'unknown', 'id': 1});
      return;
    }

    if (path.contains('/trpc/')) {
      final procedure = path.split('/trpc/').last;
      final inputJson = request.uri.queryParameters['input'];
      final input = inputJson == null
          ? <String, Object?>{}
          : jsonDecode(inputJson) as Map<String, Object?>;

      switch (procedure) {
        case 'publication.createUploadTarget':
          final fileExtension = (input['fileExtension'] ?? 'bin') as String;
          final fileHash = (input['fileHash'] ?? 'h') as String;
          await _json(
            request,
            _trpcOk({
              'uploadUrl': '$host/upload/$fileHash.$fileExtension',
              'publicUrl': '$host/files/$fileHash.$fileExtension',
            }),
          );
          return;
        case 'publication.createIngestionSession':
          await _json(
            request,
            _trpcOk({
              ...backendBundle(),
              'id': 'ing-1',
              'status': 'Ready',
              'publicationSession': {'id': 'pub-1'},
            }),
          );
          return;
        case 'publication.getIngestionSession':
          await _json(
            request,
            _trpcOk({
              ...backendBundle(),
              'id': 'ing-1',
              'status': 'Ready',
              'publicationSession': {'id': 'pub-1'},
            }),
          );
          return;
        case 'publication.getPublicationBundle':
          await _json(request, _trpcOk(backendBundle()));
          return;
        case 'publication.getPublicationSession':
          await _json(
            request,
            _trpcOk({
              'id': 'pub-1',
              'ingestionSessionId': 'ing-1',
              'releaseId': 'rel-1',
              'stage': 'PreparedForMint',
              'expectedMintAddress': mintAddress,
              'metadataUri': 'https://public.example.com/meta.json',
            }),
          );
          return;
        case 'publication.prepareReleaseNftTransaction':
          await _json(
            request,
            _trpcOk({
              'transaction': base64Encode(
                getTransactionEncoder().encode(
                  await buildReleaseMintTransaction(),
                ),
              ),
              'mintAddress': mintAddress,
              'blockhash': blockhash,
            }),
          );
          return;
        case 'publication.submitSignedTransaction':
          final body =
              jsonDecode(utf8.decode(await _body(request)))
                  as Map<String, Object?>;
          signedTransactions.add(body);
          await _json(
            request,
            _trpcOk({'transactionSignature': 'sig-1'}),
          );
          return;
        case 'publication.saveReleaseNftData':
          await _json(request, _trpcOk({'success': true}));
          return;
        case 'publication.prepareVerifyCollectionTransaction':
          await _json(
            request,
            _trpcOk({
              'transaction': base64Encode(
                getTransactionEncoder().encode(
                  await buildVerifyCollectionTransaction(),
                ),
              ),
              'blockhash': blockhash,
            }),
          );
          return;
        case 'publication.markReleaseCollectionAsVerified':
          await _json(
            request,
            _trpcOk({'success': true, 'releaseId': 'rel-1'}),
          );
          return;
        case 'publication.cleanupRelease':
          await _json(
            request,
            _trpcOk({'action': 'deleted', 'releaseId': 'rel-1'}),
          );
          return;
        case 'publication.submitToStore':
          final body =
              jsonDecode(utf8.decode(await _body(request)))
                  as Map<String, Object?>;
          submittedToStore.add(body);
          await _json(
            request,
            _trpcOk({'hubspotTicketId': 'HS-E2E'}),
          );
          return;
        case 'attestation.getBlockData':
          await _json(
            request,
            _trpcOk({'slot': 42, 'blockhash': blockhash}),
          );
          return;
        case 'fetchRemoteFile':
          await _json(
            request,
            _trpcOk({
              'data': base64Encode(pngBytes(width: 100, height: 100)),
              'fileName': 'icon.png',
              'mimeType': 'image/png',
            }),
          );
          return;
        default:
          request.response.statusCode = 404;
          await request.response.close();
          return;
      }
    }

    if (path.startsWith('/upload/')) {
      final bytes = await _body(request);
      _uploadedFiles[path] = bytes;
      request.response.statusCode = 200;
      await request.response.close();
      return;
    }

    request.response.statusCode = 404;
    await request.response.close();
  }
}

Future<Uint8List> _body(HttpRequest request) async {
  final builder = BytesBuilder();
  await for (final chunk in request) {
    builder.add(chunk);
  }
  return builder.toBytes();
}

Future<void> _json(HttpRequest request, Object payload) async {
  request.response.headers.contentType = ContentType.json;
  request.response.write(jsonEncode(payload));
  await request.response.close();
}

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

void main() {
  late MockPortalServer portal;
  late HttpServer httpServer;
  late Directory temp;
  late String apkPath;
  late String keypairPath;

  setUpAll(() async {
    httpServer = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    portal = MockPortalServer(httpServer);
    unawaited(portal.handle());
    temp = await Directory.systemTemp.createTemp();
    apkPath = '${temp.path}/release.apk';
    await File(apkPath).writeAsBytes([1, 2, 3, 4]);
    final keypairJson = jsonEncode([
      ...publisherKeypair.privateKey,
      ...publisherKeypair.publicKey,
    ]);
    keypairPath = '${temp.path}/keypair.json';
    await File(keypairPath).writeAsString(keypairJson);
  });

  tearDownAll(() async {
    await httpServer.close(force: true);
    await temp.delete(recursive: true);
  });

  test('publishes a dApp version end to end through the CLI', () async {
    final lines = <String>[];
    final exitCode = await runDappStoreCli(
      [
        '--apk-file',
        apkPath,
        '--whats-new',
        'Bug fixes',
        '--keypair',
        keypairPath,
        '--portal-url',
        portal.host.toString(),
        '--api-key-env',
        'E2E_KEY',
        '--local-dev',
        '--verbose',
      ],
      _CliDeps(lines, {
        'E2E_KEY': _apiKey,
        'DAPP_STORE_PORTAL_URL': portal.host.toString(),
      }),
    );

    // The CLI uses the same file for the keypair in this run to prove the
    // signer is only used locally; the keypair path is overridden below.
    expect(lines.where((line) => line.contains('Error')), isEmpty);
    expect(exitCode, 0);
    expect(
      lines.any((line) => line.contains('This app is now in review.')),
      isTrue,
    );
    expect(lines.any((line) => line.contains('Ticket ID: HS-E2E')), isTrue);
    expect(portal.submittedToStore, hasLength(1));
    expect(portal.signedTransactions, hasLength(2));
  });

  test('resume completes a partially published release', () async {
    final lines = <String>[];
    final exitCode = await runDappStoreCli(
      [
        'resume',
        '--release-id',
        'rel-1',
        '--keypair',
        keypairPath,
        '--portal-url',
        portal.host.toString(),
        '--api-key-env',
        'E2E_KEY',
        '--local-dev',
      ],
      _CliDeps(lines, {'E2E_KEY': _apiKey}),
    );
    expect(exitCode, 0);
    expect(
      lines.any((line) => line.contains('This app is now in review.')),
      isTrue,
    );
  });
}

class _CliDeps extends DappStoreCliDependencies {
  _CliDeps(this.lines, this.envVars);

  final List<String> lines;
  final Map<String, String> envVars;

  @override
  void write(String line) {
    lines.add(line);
  }

  @override
  Map<String, String> get environment => envVars;
}
