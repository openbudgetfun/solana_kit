import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_jupiter/solana_kit_jupiter.dart';
import 'package:test/test.dart';

const _wsol = 'So11111111111111111111111111111111111111112';
const _usdc = 'EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v';

void main() {
  JupiterConfig config(String json, {int status = 200}) => JupiterConfig(
    client: MockClient((request) async => http.Response(json, status)),
  );
  const wsol = Address(_wsol);

  test('JupiterException carries and prints its fields', () {
    final error = JupiterException(statusCode: 418, message: 'teapot');
    expect(error.statusCode, 418);
    expect(error.message, 'teapot');
    expect(error.body, isNull);
    expect(error.toString(), contains('418'));
    expect(error.toString(), contains('teapot'));
  });

  test('the default client exposes sub-clients', () {
    final client = createJupiterClient(JupiterConfig());
    expect(client.config.baseUrl, 'https://api.jup.ag');
    expect(client.swap, isNotNull);
    expect(client.price, isNotNull);
    expect(client.tokens, isNotNull);
  });

  test('non-object swap responses throw a friendly JupiterException', () async {
    final client = createJupiterClient(config('["array"]'));
    await expectLater(
      client.swap.getOrder(
        JupiterOrderRequest(
          inputMint: wsol,
          outputMint: const Address(_usdc),
          amount: BigInt.one,
        ),
      ),
      throwsA(
        isA<JupiterException>().having(
          (error) => error.message,
          'message',
          'Expected a JSON object from /swap/v2/order',
        ),
      ),
    );
    await expectLater(
      client.swap.buildSwap(
        JupiterOrderRequest(
          inputMint: wsol,
          outputMint: const Address(_usdc),
          amount: BigInt.one,
        ),
      ),
      throwsA(
        isA<JupiterException>().having(
          (error) => error.message,
          'message',
          'Expected a JSON object from /swap/v2/build',
        ),
      ),
    );
    await expectLater(
      client.price.getPrices([wsol]),
      throwsA(isA<JupiterException>()),
    );
    await expectLater(
      client.tokens.recent(),
      throwsA(isA<JupiterException>()),
    );
    // executeOrder with a non-object body throws too.
    await expectLater(
      client.swap.executeOrder(
        userPublicKey: wsol,
        order: const JupiterOrderResponse(
          inAmount: null,
          outAmount: null,
          encodedTransaction: null,
          requestId: 'request-1',
        ),
        signedTransaction: 'c2lnbmVk',
      ),
      throwsA(
        isA<JupiterException>().having(
          (error) => error.message,
          'message',
          'Expected a JSON object from /swap/v2/execute',
        ),
      ),
    );
  });

  test('JupiterAccountMetaPayload builds directly from JSON', () {
    final meta = JupiterAccountMetaPayload.fromJson({
      'pubkey': _wsol,
      'isSigner': false,
      'isWritable': true,
    });
    expect(meta.pubkey, _wsol);
    expect(meta.isWritable, isTrue);
  });

  test('JupiterInstructionPayload tolerates null fields', () {
    final payload = JupiterInstructionPayload.fromJson({});
    expect(payload.programId, isNull);
    expect(payload.accounts, isNull);
    expect(payload.data, isNull);
  });
}
