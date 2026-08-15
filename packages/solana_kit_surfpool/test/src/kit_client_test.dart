import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_rpc/solana_kit_rpc.dart';
import 'package:solana_kit_signers/solana_kit_signers.dart';
import 'package:solana_kit_surfpool/solana_kit_surfpool.dart';
import 'package:test/test.dart';

void main() {
  group('SurfpoolClient', () {
    test('connectSurfpoolClient wires rpc, subscriptions, payer, and '
        'cheatcodes', () async {
      final payer = generateKeyPairSigner();
      final client = connectSurfpoolClient(
        rpcUrl: Uri.parse('http://localhost:8899'),
        wsUrl: Uri.parse('ws://localhost:8900'),
        payer: payer,
      );

      expect(client.rpcUrl, 'http://localhost:8899');
      expect(client.wsUrl, 'ws://localhost:8900');
      expect(client.payer.address, payer.address);
      expect(client.surfnet.payer, payer.address);
      expect(client.cheatcodes, isA<SurfnetCheatcodes>());
      expect(client.rpc, isNotNull);
      expect(client.rpcSubscriptions, isNotNull);

      await client.stop();
    });

    test('connectSurfpoolClient derives the ws URL from the rpc URL', () async {
      final payer = generateKeyPairSigner();
      final client = connectSurfpoolClient(
        rpcUrl: Uri.parse('http://localhost:8899'),
        payer: payer,
      );

      expect(client.wsUrl, 'ws://localhost:8899');
      await client.stop();
    });

    test('airdrop funds an address via the Surfnet', () async {
      final requests = <Map<String, Object?>>[];
      final payer = generateKeyPairSigner();
      final surfnet = Surfnet.connect(
        rpcUrl: Uri.parse('http://localhost:8899'),
        payer: Surfnet.newKeypair(),
        client: MockClient((request) async {
          final body = jsonDecode(request.body) as Map<String, Object?>;
          requests.add(body);
          return http.Response(
            jsonEncode(<String, Object?>{
              'jsonrpc': '2.0',
              'id': body['id'],
              'result': null,
            }),
            200,
            headers: const {'content-type': 'application/json'},
          );
        }),
      );
      final client = SurfpoolClient.forTesting(
        surfnet: surfnet,
        payer: payer,
      );

      await client.airdrop(payer.address, BigInt.from(1000));

      expect(requests.single['method'], 'surfnet_setAccount');
      final params = requests.single['params']! as List<Object?>;
      expect(params.first, payer.address.value);
      expect((params[1]! as Map<String, Object?>)['lamports'], 1000);
      await client.stop();
    });

    test('getMinimumBalance returns the rent-exempt lamports', () async {
      final client = await createSurfpoolClient();
      try {
        final minimum = await client.getMinimumBalance(BigInt.zero);
        expect(minimum, greaterThan(BigInt.zero));
      } finally {
        await client.stop();
      }
    });

    test(
      'createSurfpoolClient wires a fresh Surfnet with a funded payer',
      () async {
        final client = await createSurfpoolClient();
        try {
          expect(client.rpcUrl, startsWith('http://'));
          expect(client.wsUrl, startsWith('ws://'));
          expect(client.payer.address.value, isNotEmpty);

          // The Surfnet's pre-funded payer is funded on-chain.
          final balance = await client.rpc
              .getBalanceValue(client.payer.address)
              .send();
          expect(balance.value.value, greaterThan(BigInt.zero));

          // Airdrop works through the client.
          final recipient = generateKeyPairSigner();
          await client.airdrop(recipient.address, BigInt.from(1000000000));
          final recipientBalance = await client.rpc
              .getBalanceValue(recipient.address)
              .send();
          expect(recipientBalance.value.value, BigInt.from(1000000000));
        } finally {
          await client.stop();
        }
      },
    );
  });
}
