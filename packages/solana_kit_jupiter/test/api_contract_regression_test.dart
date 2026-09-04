import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_jupiter/solana_kit_jupiter.dart';
import 'package:test/test.dart';

const _mint = Address('So11111111111111111111111111111111111111112');

void main() {
  test('orders include the taker needed to assemble a transaction', () {
    final request = JupiterOrderRequest(
      inputMint: _mint,
      outputMint: _mint,
      amount: BigInt.one,
      taker: _mint,
    );
    expect(request.toQueryParameters()['taker'], _mint.toString());
  });

  test('managed execution sends the Swap v2 contract', () async {
    final config = JupiterConfig(
      client: MockClient((request) async {
        final body = jsonDecode(request.body) as Map<String, Object?>;
        expect(body, {
          'signedTransaction': 'c2lnbmVk',
          'requestId': 'request-1',
          'lastValidBlockHeight': '1000',
        });
        return http.Response(
          '{"status":"Success","code":0,"signature":"signature"}',
          200,
        );
      }),
    );
    addTearDown(config.client.close);
    final execution = await createJupiterClient(config).swap.executeOrder(
      userPublicKey: _mint,
      order: JupiterOrderResponse(
        inAmount: null,
        outAmount: null,
        encodedTransaction: null,
        requestId: 'request-1',
        lastValidBlockHeight: BigInt.from(1000),
      ),
      signedTransaction: 'c2lnbmVk',
    );
    expect(execution.signature, 'signature');
    expect(execution.status, 'Success');
    expect(execution.code, 0);
    expect(execution.rawResponse['status'], 'Success');
  });

  for (final requestId in [null, '', '  ']) {
    test(
      'managed execution rejects a missing request ID ($requestId)',
      () async {
        var requests = 0;
        final config = JupiterConfig(
          client: MockClient((request) async {
            requests++;
            return http.Response('{}', 200);
          }),
        );
        addTearDown(config.client.close);
        await expectLater(
          createJupiterClient(config).swap.executeOrder(
            userPublicKey: _mint,
            order: JupiterOrderResponse(
              inAmount: null,
              outAmount: null,
              encodedTransaction: null,
              requestId: requestId,
            ),
            signedTransaction: 'c2lnbmVk',
          ),
          throwsArgumentError,
        );
        expect(requests, 0);
      },
    );
  }

  test('token tags use the documented query parameter', () async {
    final config = JupiterConfig(
      client: MockClient((request) async {
        expect(request.url.path, '/tokens/v2/tag');
        expect(request.url.queryParameters, {'query': 'verified'});
        return http.Response('[]', 200);
      }),
    );
    addTearDown(config.client.close);
    await createJupiterClient(config).tokens.tagged('verified');
  });

  test('token categories use a category and interval in the path', () async {
    final config = JupiterConfig(
      client: MockClient((request) async {
        expect(request.url.path, '/tokens/v2/toptrending/24h');
        expect(request.url.queryParameters, {'limit': '10'});
        return http.Response('[]', 200);
      }),
    );
    addTearDown(config.client.close);
    await createJupiterClient(config).tokens.category('toptrending', limit: 10);
  });

  test('build responses preserve v2 lookup table addresses', () {
    final result = JupiterBuildResponse.fromJson({
      'otherInstructions': [
        {'programId': 'other', 'accounts': <Object?>[], 'data': 'AA=='},
      ],
      'tipInstruction': {'programId': 'tip'},
      'blockhashWithMetadata': {
        'blockhash': List<int>.generate(32, (index) => index),
        'lastValidBlockHeight': 1000,
      },
      'addressesByLookupTableAddress': {
        'lookup-table': ['first-account', 'second-account'],
      },
    });
    expect(result.addressLookupTableAddresses, ['lookup-table']);
    expect(result.addressesByLookupTableAddress, {
      'lookup-table': ['first-account', 'second-account'],
    });
    expect(result.otherInstructions!.single.programId, 'other');
    expect(result.tipInstruction!.programId, 'tip');
    expect(
      result.blockhashWithMetadata!.blockhash,
      List<int>.generate(32, (index) => index),
    );
    expect(
      result.blockhashWithMetadata!.lastValidBlockHeight,
      BigInt.from(1000),
    );
  });

  test('failed executions retain status even when a signature is present', () {
    final result = JupiterExecutionResponse.fromJson({
      'status': 'Failed',
      'code': -1000,
      'signature': 'failed-signature',
    });
    expect(result.status, 'Failed');
    expect(result.code, -1000);
    expect(result.signature, 'failed-signature');
    expect(result.rawResponse['code'], -1000);
  });

  test('token categories accept each documented interval', () async {
    final paths = <String>[];
    final config = JupiterConfig(
      client: MockClient((request) async {
        paths.add(request.url.path);
        expect(request.url.queryParameters, isEmpty);
        return http.Response('[]', 200);
      }),
    );
    addTearDown(config.client.close);
    final client = createJupiterClient(config);
    for (final interval in ['5m', '1h', '6h', '24h']) {
      await client.tokens.category('toptraded', interval: interval);
    }
    expect(paths, [
      for (final interval in ['5m', '1h', '6h', '24h'])
        '/tokens/v2/toptraded/$interval',
    ]);
  });

  test(
    'token category paths and limits reject invalid input before sending',
    () async {
      var requests = 0;
      final config = JupiterConfig(
        client: MockClient((request) async {
          requests++;
          return http.Response('[]', 200);
        }),
      );
      addTearDown(config.client.close);
      final client = createJupiterClient(config);
      await expectLater(
        client.tokens.category('../recent'),
        throwsArgumentError,
      );
      await expectLater(
        client.tokens.category('toptrending', interval: '../recent'),
        throwsArgumentError,
      );
      for (final limit in [0, 101]) {
        await expectLater(
          client.tokens.category('toptrending', limit: limit),
          throwsArgumentError,
        );
      }
      expect(requests, 0);
    },
  );

  test(
    'malformed price responses cannot appear to be an empty market',
    () async {
      final config = JupiterConfig(
        client: MockClient(
          (request) async => http.Response('["invalid"]', 200),
        ),
      );
      addTearDown(config.client.close);
      await expectLater(
        createJupiterClient(config).price.getPrices([_mint]),
        throwsA(isA<JupiterException>()),
      );
    },
  );
}
