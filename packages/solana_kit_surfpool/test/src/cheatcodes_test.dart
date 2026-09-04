import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_surfpool/solana_kit_surfpool.dart';
import 'package:test/test.dart';

/// Builds a [MockClient] that records every JSON-RPC request and answers each
/// with [result].
MockClient _recordingClient(
  List<Map<String, Object?>> requests,
  Object? result,
) {
  return MockClient((request) async {
    final body = jsonDecode(request.body) as Map<String, Object?>;
    requests.add(body);
    return http.Response(
      jsonEncode(<String, Object?>{
        'jsonrpc': '2.0',
        'id': body['id'],
        'result': result,
      }),
      200,
      headers: const {'content-type': 'application/json'},
    );
  });
}

void main() {
  group('SurfnetCheatcodes', () {
    const address = Address('11111111111111111111111111111111');
    const other = Address('22222222222222222222222222222222');

    SurfnetCheatcodes cheatcodesWith(
      List<Map<String, Object?>> requests,
      Object? result,
    ) {
      final surfnet = Surfnet.connect(
        rpcUrl: Uri.parse('http://localhost:8899'),
        client: _recordingClient(requests, result),
      );
      return SurfnetCheatcodes(surfnet);
    }

    test('timeTravel sends absoluteSlot and parses the epoch info', () async {
      final requests = <Map<String, Object?>>[];
      final cheatcodes = cheatcodesWith(requests, <String, Object?>{
        'absoluteSlot': 100,
        'slotIndex': 0,
        'slotsInEpoch': 432000,
        'epoch': 0,
        'blockHeight': 100,
      });

      final epochInfo = await cheatcodes.timeTravel(absoluteSlot: 100);

      expect(requests, hasLength(1));
      expect(requests.single['method'], 'surfnet_timeTravel');
      expect(
        requests.single['params'],
        <Object?>[
          <String, Object?>{'absoluteSlot': 100},
        ],
      );
      expect(epochInfo.absoluteSlot, 100);
      expect(epochInfo.epoch, 0);
    });

    test('timeTravel supports epoch and timestamp targets', () async {
      final requests = <Map<String, Object?>>[];
      final cheatcodes = cheatcodesWith(requests, <String, Object?>{
        'absoluteSlot': 1,
        'slotIndex': 0,
        'slotsInEpoch': 432000,
        'epoch': 1,
        'blockHeight': 1,
      });

      await cheatcodes.timeTravel(absoluteEpoch: 1);
      expect(
        requests.single['params'],
        <Object?>[
          <String, Object?>{'absoluteEpoch': 1},
        ],
      );

      requests.clear();
      await cheatcodes.timeTravel(absoluteTimestamp: 1234);
      expect(
        requests.single['params'],
        <Object?>[
          <String, Object?>{'absoluteTimestamp': 1234},
        ],
      );
    });

    test('pauseClock and resumeClock parse the epoch info', () async {
      final requests = <Map<String, Object?>>[];
      final cheatcodes = cheatcodesWith(requests, <String, Object?>{
        'absoluteSlot': 5,
        'slotIndex': 0,
        'slotsInEpoch': 432000,
        'epoch': 0,
        'blockHeight': 5,
      });

      final paused = await cheatcodes.pauseClock();
      expect(requests.single['method'], 'surfnet_pauseClock');
      expect(paused.absoluteSlot, 5);

      requests.clear();
      final resumed = await cheatcodes.resumeClock();
      expect(requests.single['method'], 'surfnet_resumeClock');
      expect(resumed.blockHeight, 5);
    });

    test('setAccount sends the account update', () async {
      final requests = <Map<String, Object?>>[];
      final cheatcodes = cheatcodesWith(requests, null);

      await cheatcodes.setAccount(
        address,
        lamports: 1000,
        data: Uint8List.fromList([1, 2, 3]),
        owner: other,
      );

      expect(requests.single['method'], 'surfnet_setAccount');
      final params = requests.single['params']! as List<Object?>;
      expect(params.first, address.value);
      final update = params[1]! as Map<String, Object?>;
      expect(update['lamports'], 1000);
      expect(update['data'], '010203');
      expect(update['owner'], other.value);
    });

    test(
      'setTokenBalance and setTokenAccount delegate to the Surfnet',
      () async {
        final requests = <Map<String, Object?>>[];
        final cheatcodes = cheatcodesWith(requests, null);

        await cheatcodes.setTokenBalance(address, other, 42);
        expect(requests.single['method'], 'surfnet_setTokenAccount');
        expect(
          (requests.single['params']! as List<Object?>).sublist(0, 2),
          <Object?>[address.value, other.value],
        );

        requests.clear();
        await cheatcodes.setTokenAccount(
          address,
          other,
          const SetTokenAccountUpdate(amount: 7),
        );
        expect(requests.single['method'], 'surfnet_setTokenAccount');
        final params = requests.single['params']! as List<Object?>;
        expect((params[2]! as Map<String, Object?>)['amount'], 7);
      },
    );

    test('resetAccount and streamAccount delegate to the Surfnet', () async {
      final requests = <Map<String, Object?>>[];
      final cheatcodes = cheatcodesWith(requests, null);

      await cheatcodes.resetAccount(address, includeOwnedAccounts: true);
      expect(requests.single['method'], 'surfnet_resetAccount');
      expect(
        (requests.single['params']! as List<Object?>).first,
        address.value,
      );

      requests.clear();
      await cheatcodes.streamAccount(address);
      expect(requests.single['method'], 'surfnet_streamAccount');
    });

    test('offlineAccount and streamAccounts send their params', () async {
      final requests = <Map<String, Object?>>[];
      final cheatcodes = cheatcodesWith(requests, null);

      await cheatcodes.offlineAccount(
        address,
        config: <String, Object?>{'reason': 'test'},
      );
      expect(requests.single['method'], 'surfnet_offlineAccount');
      expect(
        requests.single['params'],
        <Object?>[
          address.value,
          <String, Object?>{'reason': 'test'},
        ],
      );

      requests.clear();
      await cheatcodes.streamAccounts([
        <String, Object?>{'address': address.value},
      ]);
      expect(requests.single['method'], 'surfnet_streamAccounts');
      expect(requests.single['params'], hasLength(1));
    });

    test('getStreamedAccounts returns the raw response', () async {
      final requests = <Map<String, Object?>>[];
      final cheatcodes = cheatcodesWith(requests, <String, Object?>{
        'accounts': <Object?>[],
      });

      final result = await cheatcodes.getStreamedAccounts();
      expect(requests.single['method'], 'surfnet_getStreamedAccounts');
      expect(result, isA<Map<String, Object?>>());
    });

    test(
      'cloneProgramAccount and setProgramAuthority send addresses',
      () async {
        final requests = <Map<String, Object?>>[];
        final cheatcodes = cheatcodesWith(requests, null);

        await cheatcodes.cloneProgramAccount(address, other);
        expect(requests.single['method'], 'surfnet_cloneProgramAccount');
        expect(
          requests.single['params'],
          <Object?>[address.value, other.value],
        );

        requests.clear();
        await cheatcodes.setProgramAuthority(address, newAuthority: other);
        expect(requests.single['method'], 'surfnet_setProgramAuthority');
        expect(
          requests.single['params'],
          <Object?>[address.value, other.value],
        );
      },
    );

    test('writeProgram hex-encodes the data', () async {
      final requests = <Map<String, Object?>>[];
      final cheatcodes = cheatcodesWith(requests, null);

      await cheatcodes.writeProgram(
        address,
        Uint8List.fromList([0xde, 0xad]),
        8,
        authority: other,
      );

      expect(requests.single['method'], 'surfnet_writeProgram');
      expect(
        requests.single['params'],
        <Object?>[address.value, 'dead', 8, other.value],
      );
    });

    test(
      'profileTransaction and getTransactionProfile send their params',
      () async {
        final requests = <Map<String, Object?>>[];
        final cheatcodes = cheatcodesWith(requests, null);

        await cheatcodes.profileTransaction(
          'base64data',
          tag: 'tag',
          config: <String, Object?>{'depth': 1},
        );
        expect(requests.single['method'], 'surfnet_profileTransaction');
        expect(
          requests.single['params'],
          <Object?>[
            'base64data',
            'tag',
            <String, Object?>{'depth': 1},
          ],
        );

        requests.clear();
        await cheatcodes.getTransactionProfile(
          'sig',
          config: <String, Object?>{'depth': 1},
        );
        expect(requests.single['method'], 'surfnet_getTransactionProfile');
        expect(
          requests.single['params'],
          <Object?>[
            'sig',
            <String, Object?>{'depth': 1},
          ],
        );
      },
    );

    test('profileTransaction supports config without a tag', () async {
      final surfnet = Surfnet.connect(
        rpcUrl: Uri.parse('http://localhost:8899'),
        client: MockClient((request) async {
          final body = jsonDecode(request.body) as Map<String, Object?>;
          final params = body['params']! as List<Object?>;
          final validParams =
              params.length == 3 && params[1] == null && params[2] is Map;
          return http.Response(
            jsonEncode({
              'jsonrpc': '2.0',
              'id': body['id'],
              if (validParams)
                'result': 'profile'
              else
                'error': {'code': -32602, 'message': 'Invalid tag parameter'},
            }),
            200,
          );
        }),
      );
      addTearDown(surfnet.stop);

      expect(
        await SurfnetCheatcodes(surfnet).profileTransaction(
          'base64data',
          config: {'depth': 'instruction'},
        ),
        'profile',
      );
    });

    test('profileTransaction can omit both optional parameters', () async {
      final requests = <Map<String, Object?>>[];
      final cheatcodes = cheatcodesWith(requests, null);

      await cheatcodes.profileTransaction('base64data');

      expect(requests.single['params'], ['base64data']);
    });

    test('profile lookups unwrap context responses including null', () async {
      for (final value in <Object?>[
        {'computeUnitsConsumed': 123},
        null,
      ]) {
        final cheatcodes = cheatcodesWith([], {
          'context': {'slot': 123},
          'value': value,
        });

        expect(await cheatcodes.getTransactionProfile('signature'), value);
      }
    });

    test('getProfileResultsByTag sends the tag', () async {
      final requests = <Map<String, Object?>>[];
      final cheatcodes = cheatcodesWith(requests, null);

      await cheatcodes.getProfileResultsByTag(
        'my-tag',
        config: <String, Object?>{'depth': 1},
      );
      expect(requests.single['method'], 'surfnet_getProfileResultsByTag');
      expect(
        requests.single['params'],
        <Object?>[
          'my-tag',
          <String, Object?>{'depth': 1},
        ],
      );
    });

    test('registerIdl and getActiveIdl send the IDL and slot', () async {
      final requests = <Map<String, Object?>>[];
      final cheatcodes = cheatcodesWith(requests, null);

      await cheatcodes.registerIdl(
        <String, Object?>{'address': address.value},
        slot: 5,
      );
      expect(requests.single['method'], 'surfnet_registerIdl');
      expect(
        requests.single['params'],
        <Object?>[
          <String, Object?>{'address': address.value},
          5,
        ],
      );

      requests.clear();
      await cheatcodes.getActiveIdl(address, slot: 5);
      expect(requests.single['method'], 'surfnet_getActiveIdl');
      expect(requests.single['params'], <Object?>[address.value, 5]);
    });

    test('setSupply, resetNetwork, getSurfnetInfo, exportSnapshot, '
        'registerScenario, getLocalSignatures send their methods', () async {
      final requests = <Map<String, Object?>>[];
      final cheatcodes = cheatcodesWith(requests, null);

      await cheatcodes.setSupply(<String, Object?>{'total': 1});
      expect(requests.single['method'], 'surfnet_setSupply');

      requests.clear();
      await cheatcodes.resetNetwork();
      expect(requests.single['method'], 'surfnet_resetNetwork');

      requests.clear();
      await cheatcodes.getSurfnetInfo();
      expect(requests.single['method'], 'surfnet_getSurfnetInfo');

      requests.clear();
      await cheatcodes.exportSnapshot(
        config: <String, Object?>{'scope': 'all'},
      );
      expect(requests.single['method'], 'surfnet_exportSnapshot');
      expect(
        requests.single['params'],
        <Object?>[
          <String, Object?>{'scope': 'all'},
        ],
      );

      requests.clear();
      await cheatcodes.registerScenario(
        <String, Object?>{'name': 's'},
        slot: 5,
      );
      expect(requests.single['method'], 'surfnet_registerScenario');
      expect(
        requests.single['params'],
        <Object?>[
          <String, Object?>{'name': 's'},
          5,
        ],
      );

      requests.clear();
      await cheatcodes.getLocalSignatures(limit: 3);
      expect(requests.single['method'], 'surfnet_getLocalSignatures');
      expect(requests.single['params'], <Object?>[3]);
    });

    test('enableCheatcode and disableCheatcode send the filter', () async {
      final requests = <Map<String, Object?>>[];
      final cheatcodes = cheatcodesWith(requests, null);

      await cheatcodes.enableCheatcode('all');
      expect(requests.single['method'], 'surfnet_enableCheatcode');
      expect(requests.single['params'], <Object?>['all']);

      requests.clear();
      await cheatcodes.disableCheatcode(
        <String>['surfnet_setAccount'],
        lockout: <String, Object?>{'until': 1},
      );
      expect(requests.single['method'], 'surfnet_disableCheatcode');
      expect(
        requests.single['params'],
        <Object?>[
          <String>['surfnet_setAccount'],
          <String, Object?>{'until': 1},
        ],
      );
    });
  });
}
