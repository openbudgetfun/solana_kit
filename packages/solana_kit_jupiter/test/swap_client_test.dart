import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_jupiter/solana_kit_jupiter.dart';
import 'package:solana_kit_signers/solana_kit_signers.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';
import 'package:solana_kit_transactions/solana_kit_transactions.dart';
import 'package:test/test.dart';

const _wsol = 'So11111111111111111111111111111111111111112';
const _usdc = 'EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v';
const _programId = 'JUP6LkbZbjS1jKKwapdHNy74zcZ3tLUZoi5QNyVTaV4';

void main() {
  group('JupiterConfig', () {
    test('defaults to the public base URL', () {
      final config = JupiterConfig();
      expect(config.baseUrl, 'https://api.jup.ag');
      expect(config.apiKey, isNull);
    });

    test('redacts the API key in toString', () {
      final config = JupiterConfig(apiKey: 'sk-live-123');
      expect(config.toString(), isNot(contains('sk-live-123')));
      expect(config.toString(), contains('***'));
    });
  });

  group('JupiterSwapClient', () {
    test(
      'getOrder sends query parameters, headers, and parses the order',
      () async {
        Uri? capturedUri;
        Map<String, String>? capturedHeaders;
        final config = JupiterConfig(
          apiKey: 'test-key',
          client: MockClient((request) async {
            capturedUri = request.url;
            capturedHeaders = request.headers;
            return http.Response(
              '{"inAmount":"10000000","outAmount":"19950000","transaction":"dHJhbnNhY3Rpb24=",'
              '"requestId":"req-1","router":"metis","mode":"ultra",'
              '"lastValidBlockHeight":"1234","expireAt":1735689600,'
              '"swapType":"ultraV1Aggregator","slippageBps":50}',
              200,
              headers: {'content-type': 'application/json; charset=utf-8'},
            );
          }),
        );
        final client = createJupiterClient(config);

        final order = await client.swap.getOrder(
          JupiterOrderRequest(
            inputMint: const Address(_wsol),
            outputMint: const Address(_usdc),
            amount: BigInt.from(10000000),
            slippageBps: 50,
            referralAccount: const Address(_usdc),
            referralFee: 10,
            restrictIntermediateTokens: true,
            platformFeeBps: 15,
            swapMode: JupiterSwapMode.exactOut,
            excludeDirectRouterRoutes: true,
            payer: const Address(_usdc),
          ),
        );

        expect(capturedHeaders?['accept'], 'application/json');
        expect(capturedHeaders?['x-api-key'], 'test-key');
        expect(capturedUri?.path, '/swap/v2/order');
        expect(capturedUri?.queryParameters['inputMint'], _wsol);
        expect(capturedUri?.queryParameters['outputMint'], _usdc);
        expect(capturedUri?.queryParameters['amount'], '10000000');
        expect(capturedUri?.queryParameters['slippageBps'], '50');
        expect(capturedUri?.queryParameters['swapMode'], 'ExactOut');
        expect(capturedUri?.queryParameters['referralAccount'], _usdc);
        expect(capturedUri?.queryParameters['referralFee'], '10');
        expect(
          capturedUri?.queryParameters['restrictIntermediateTokens'],
          'true',
        );
        expect(capturedUri?.queryParameters['platformFeeBps'], '15');
        expect(
          capturedUri?.queryParameters['excludeDirectRouterRoutes'],
          'true',
        );
        expect(capturedUri?.queryParameters['payer'], _usdc);

        expect(order.inAmount, BigInt.from(10000000));
        expect(order.outAmount, BigInt.from(19950000));
        expect(order.encodedTransaction, 'dHJhbnNhY3Rpb24=');
        expect(order.requestId, 'req-1');
        expect(order.router, 'metis');
        expect(order.mode, JupiterOrderMode.ultra);
        expect(order.lastValidBlockHeight, BigInt.from(1234));
        expect(order.expireAt, 1735689600);
        expect(order.slippageBps, 50);
        expect(order.rawResponse['swapType'], 'ultraV1Aggregator');
      },
    );

    test('getOrder omits unset fields and forwards extras', () async {
      Uri? capturedUri;
      final config = JupiterConfig(
        client: MockClient((request) async {
          capturedUri = request.url;
          return http.Response('{}', 200);
        }),
      );
      final client = createJupiterClient(config);

      final order = await client.swap.getOrder(
        JupiterOrderRequest(
          inputMint: const Address(_wsol),
          outputMint: const Address(_usdc),
          amount: BigInt.one,
          extraQueryParameters: {'ignore': 'me'},
        ),
      );

      expect(capturedUri?.queryParameters.containsKey('slippageBps'), isFalse);
      expect(capturedUri?.queryParameters.containsKey('swapMode'), isFalse);
      expect(capturedUri?.queryParameters['ignore'], 'me');
      expect(order.mode, isNull);
      expect(order.encodedTransaction, isNull);
      expect(order.rawResponse, isEmpty);
    });

    test('executeOrder posts the request id and signed transaction', () async {
      String? capturedBody;
      final config = JupiterConfig(
        apiKey: 'test-key',
        client: MockClient((request) async {
          capturedBody = request.body;
          return http.Response('{"swapTransaction":"c2lnbmVk"}', 200);
        }),
      );
      final client = createJupiterClient(config);

      final execution = await client.swap.executeOrder(
        userPublicKey: const Address(_wsol),
        order: const JupiterOrderResponse(
          inAmount: null,
          outAmount: null,
          encodedTransaction: null,
          requestId: 'req-9',
        ),
        signedTransaction: 'c2lnbmVk',
      );

      final body = jsonDecode(capturedBody!) as Map<String, Object?>;
      expect(body['userPublicKey'], _wsol);
      expect(body['requestId'], 'req-9');
      expect(body['transaction'], 'c2lnbmVk');
      expect(execution.encodedSwapTransaction, 'c2lnbmVk');
      expect(execution.signature, isNull);
      expect(execution.error, isNull);
    });

    test(
      'executeOrder omits the request id when absent and surfaces errors',
      () async {
        String? capturedBody;
        final config = JupiterConfig(
          client: MockClient((request) async {
            capturedBody = request.body;
            return http.Response('{"error":"Route expired"}', 200);
          }),
        );
        final client = createJupiterClient(config);
        final execution = await client.swap.executeOrder(
          userPublicKey: const Address(_wsol),
          order: const JupiterOrderResponse(
            inAmount: null,
            outAmount: null,
            encodedTransaction: null,
          ),
          signedTransaction: 'c2lnbmVk',
        );

        expect(
          (jsonDecode(capturedBody!) as Map<String, Object?>).containsKey(
            'requestId',
          ),
          isFalse,
        );
        expect(execution.error, 'Route expired');
      },
    );

    test('buildSwap parses the raw instruction set', () async {
      Uri? capturedUri;
      final config = JupiterConfig(
        client: MockClient((request) async {
          capturedUri = request.url;
          return http.Response(
            jsonEncode({
              'computeBudgetInstructions': [
                {
                  'programId': 'ComputeBudget111111111111111111111111111111',
                  'accounts': <Object?>[],
                  'data': 'AAA=',
                },
              ],
              'setupInstructions': <Object?>[],
              'swapInstruction': {
                'programId': _programId,
                'accounts': [
                  {'pubkey': _wsol, 'isSigner': false, 'isWritable': true},
                ],
                'data': 'AQID',
              },
              'cleanupInstruction': null,
              'addressLookupTableAddresses': [_usdc],
            }),
            200,
          );
        }),
      );
      final client = createJupiterClient(config);

      final built = await client.swap.buildSwap(
        JupiterOrderRequest(
          inputMint: const Address(_wsol),
          outputMint: const Address(_usdc),
          amount: BigInt.one,
        ),
      );

      expect(capturedUri?.path, '/swap/v2/build');
      expect(built.computeBudgetInstructions, hasLength(1));
      expect(
        built.computeBudgetInstructions![0].programId,
        'ComputeBudget111111111111111111111111111111',
      );
      expect(built.swapInstruction!.accounts![0].isWritable, isTrue);
      expect(built.cleanupInstruction, isNull);
      expect(built.addressLookupTableAddresses, [_usdc]);
    });

    test(
      'non-2xx responses throw JupiterException with the API detail',
      () async {
        final config = JupiterConfig(
          client: MockClient(
            (request) async => http.Response(
              '{"error":"rate limited","detail":"Slow down"}',
              429,
            ),
          ),
        );
        final client = createJupiterClient(config);

        await expectLater(
          client.swap.getOrder(
            JupiterOrderRequest(
              inputMint: const Address(_wsol),
              outputMint: const Address(_usdc),
              amount: BigInt.one,
            ),
          ),
          throwsA(
            isA<JupiterException>()
                .having((error) => error.statusCode, 'statusCode', 429)
                .having(
                  (error) => error.message,
                  'message',
                  '429: rate limited',
                )
                .having(
                  (error) => (error.body! as Map<String, Object?>)['error'],
                  'body',
                  'rate limited',
                ),
          ),
        );
      },
    );

    test('non-JSON error bodies fall back to the status code', () async {
      final config = JupiterConfig(
        client: MockClient((request) async => http.Response('boom', 502)),
      );
      final client = createJupiterClient(config);

      await expectLater(
        client.swap.getOrder(
          JupiterOrderRequest(
            inputMint: const Address(_wsol),
            outputMint: const Address(_usdc),
            amount: BigInt.one,
          ),
        ),
        throwsA(
          isA<JupiterException>()
              .having((error) => error.statusCode, 'statusCode', 502)
              .having((error) => error.message, 'message', 'HTTP 502')
              .having((error) => error.body, 'body', 'boom'),
        ),
      );
    });

    test(
      'decodeBase64SwapTransaction round-trips a compiled transaction',
      () async {
        final signer = generateKeyPairSigner();
        final message = setTransactionMessageLifetimeUsingBlockhash(
          BlockhashLifetimeConstraint(
            blockhash: '4Nd1mBQtrMJVYVfKf2PJy9NZUZdTAsp7D4xWLs4gDB4T',
            lastValidBlockHeight: BigInt.from(1234),
          ),
          setTransactionMessageFeePayer(
            signer.address,
            createTransactionMessage(version: TransactionVersion.v0),
          ),
        );
        final compiled = compileTransaction(message);
        final encoded = getBase64EncodedWireTransaction(compiled);

        final decoded = decodeBase64SwapTransaction(encoded);

        expect(decoded.signatures.containsKey(signer.address), isTrue);
        expect(decoded.messageBytes, compiled.messageBytes);
      },
    );

    test('decodeBase64SwapTransaction throws on malformed input', () {
      expect(
        () => decodeBase64SwapTransaction('@@not base64@@'),
        throwsA(isA<SolanaError>()),
      );
    });
  });
}
