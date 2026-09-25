// Pins `surfnetCheatcodeMethods` against the surface this package implements.
//
// Upstream generates `SURFNET_CHEATCODE_METHODS` from the Rust types and has a
// build-time assertion that its hand-written per-method API types cover the
// manifest exactly. This is the Dart equivalent: every method in the manifest
// must be reachable through `SurfnetCheatcodes`, and the manifest must not list
// a method this package cannot call.

import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_surfpool/solana_kit_surfpool.dart';
import 'package:test/test.dart';

/// Calls every cheatcode with arguments valid for its wire signature and
/// returns the set of JSON-RPC method names that reached the transport.
Future<Set<String>> _invokeEveryCheatcode() async {
  const address = Address('11111111111111111111111111111111');
  const other = Address('22222222222222222222222222222222');
  final methods = <String>{};

  final client = MockClient((request) async {
    final body = jsonDecode(request.body) as Map<String, Object?>;
    methods.add(body['method']! as String);

    return http.Response(
      jsonEncode(<String, Object?>{
        'jsonrpc': '2.0',
        'id': body['id'],
        'result': null,
      }),
      200,
    );
  });

  final surfnet = Surfnet.connect(
    rpcUrl: Uri.parse(defaultSurfnetEndpoint),
    client: client,
  );
  addTearDown(surfnet.stop);
  final cheatcodes = SurfnetCheatcodes(surfnet);

  Future<void> attempt(Future<Object?> Function() call) async {
    try {
      await call();

    } on Object {
      // The stub transport answers `null` for every method, so methods that
      // parse a typed response throw. The method name already reached the
      // transport, which is what this test observes.
    }
  }

  await attempt(() => cheatcodes.timeTravel(absoluteSlot: 1));
  await attempt(cheatcodes.pauseClock);
  await attempt(cheatcodes.resumeClock);
  await attempt(() => cheatcodes.setAccount(address));
  await attempt(() => cheatcodes.setTokenBalance(address, other, 1));
  await attempt(
    () => cheatcodes.setTokenAccount(
      address,
      other,
      const SetTokenAccountUpdate(amount: 1),
    ),
  );
  await attempt(
    () => cheatcodes.resetAccount(address, includeOwnedAccounts: true),
  );
  await attempt(() => cheatcodes.streamAccount(address));
  await attempt(() => cheatcodes.offlineAccount(address));
  await attempt(() => cheatcodes.streamAccounts(<Map<String, Object?>>[]));
  await attempt(cheatcodes.getStreamedAccounts);
  await attempt(
    () => cheatcodes.getConfidentialBalance(
      address,
      const ConfidentialBalanceKeys(aesKey: 'aes'),
    ),
  );
  await attempt(() => cheatcodes.deriveConfidentialKeys('signature'));
  await attempt(() => cheatcodes.cloneProgramAccount(address, other));
  await attempt(() => cheatcodes.setProgramAuthority(address));
  await attempt(() => cheatcodes.writeProgram(address, Uint8List(0), 0));
  await attempt(() => cheatcodes.profileTransaction('data'));
  await attempt(() => cheatcodes.getTransactionProfile('signature'));
  await attempt(() => cheatcodes.getProfileResultsByTag('tag'));
  await attempt(() => cheatcodes.registerIdl(<String, Object?>{}));
  await attempt(() => cheatcodes.getActiveIdl(address));
  await attempt(() => cheatcodes.setSupply(<String, Object?>{}));
  await attempt(cheatcodes.resetNetwork);
  await attempt(cheatcodes.getSurfnetInfo);
  await attempt(cheatcodes.exportSnapshot);
  await attempt(() => cheatcodes.registerScenario(<String, Object?>{}));
  await attempt(cheatcodes.getLocalSignatures);
  await attempt(() => cheatcodes.enableCheatcode('all'));
  await attempt(() => cheatcodes.disableCheatcode('all'));

  return methods;
}

void main() {
  group('surfnetCheatcodeMethods', () {
    test('matches the upstream manifest for Surfpool 1.6.0', () {
      expect(surfnetCheatcodeMethods, <String>[
        'surfnet_cloneProgramAccount',
        'surfnet_deriveConfidentialKeys',
        'surfnet_disableCheatcode',
        'surfnet_enableCheatcode',
        'surfnet_exportSnapshot',
        'surfnet_getActiveIdl',
        'surfnet_getConfidentialBalance',
        'surfnet_getLocalSignatures',
        'surfnet_getProfileResultsByTag',
        'surfnet_getStreamedAccounts',
        'surfnet_getSurfnetInfo',
        'surfnet_getTransactionProfile',
        'surfnet_offlineAccount',
        'surfnet_pauseClock',
        'surfnet_profileTransaction',
        'surfnet_registerIdl',
        'surfnet_registerScenario',
        'surfnet_resetAccount',
        'surfnet_resetNetwork',
        'surfnet_resumeClock',
        'surfnet_setAccount',
        'surfnet_setProgramAuthority',
        'surfnet_setSupply',
        'surfnet_setTokenAccount',
        'surfnet_streamAccount',
        'surfnet_streamAccounts',
        'surfnet_timeTravel',
        'surfnet_writeProgram',
      ]);
    });

    test('lists every method without duplicates', () {
      expect(
        surfnetCheatcodeMethods.toSet(),
        hasLength(surfnetCheatcodeMethods.length),
      );
      expect(surfnetCheatcodeMethods, everyElement(startsWith('surfnet_')));
    });

    test('SurfnetCheatcodes covers exactly the manifest', () async {
      final called = await _invokeEveryCheatcode();

      expect(
        called,
        unorderedEquals(surfnetCheatcodeMethods),
        reason:
            'SurfnetCheatcodes must call every method in the manifest and '
            'no method outside it',
      );
    });

    test('defaultSurfnetEndpoint matches the upstream CLI default', () {
      expect(defaultSurfnetEndpoint, 'http://127.0.0.1:8899');
    });
  });
}
