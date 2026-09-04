@TestOn('vm')
library;

import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_jupiter/solana_kit_jupiter.dart';
import 'package:test/test.dart';

void main() {
  group('Jupiter credential transport security', () {
    for (final baseUrl in [
      'http://api.jup.ag',
      '/relative',
      'https://[broken',
      'ftp://api.jup.ag',
      'https:///missing-host',
      'https://username:password@api.jup.ag',
      'https://api.jup.ag?api-key=secret',
      'https://api.jup.ag#secret',
    ]) {
      test('rejects unsafe base URL $baseUrl', () {
        final transport = MockClient((_) async => http.Response('[]', 200));
        addTearDown(transport.close);
        expect(
          () => JupiterConfig(
            apiKey: 'private-project-key',
            baseUrl: baseUrl,
            client: transport,
          ),
          throwsArgumentError,
        );
      });
    }

    for (final method in ['GET', 'POST']) {
      test(
        '$method redirects cannot leak API keys to another origin',
        () async {
          final destination = await HttpServer.bind(
            InternetAddress.loopbackIPv4,
            0,
          );
          final origin = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
          addTearDown(() => destination.close(force: true));
          addTearDown(() => origin.close(force: true));
          String? leakedKey;
          destination.listen((request) async {
            leakedKey = request.headers.value('x-api-key');
            request.response.write(method == 'GET' ? '[]' : '{}');
            await request.response.close();
          });
          origin.listen((request) async {
            request.response.statusCode = HttpStatus.seeOther;
            request.response.headers.set(
              HttpHeaders.locationHeader,
              'http://127.0.0.1:${destination.port}/collect',
            );
            await request.response.close();
          });
          final config = JupiterConfig(
            apiKey: 'private-project-key',
            baseUrl: 'http://127.0.0.1:${origin.port}',
            allowInsecureHttp: true,
          );
          addTearDown(config.client.close);
          final client = createJupiterClient(config);
          Object? failure;
          try {
            if (method == 'GET') {
              await client.tokens.recent();
            } else {
              await client.swap.executeOrder(
                userPublicKey: const Address(
                  'So11111111111111111111111111111111111111112',
                ),
                order: const JupiterOrderResponse(
                  inAmount: null,
                  outAmount: null,
                  encodedTransaction: null,
                  requestId: 'request-1',
                ),
                signedTransaction: 'c2lnbmVk',
              );
            }
          } on JupiterException catch (error) {
            failure = error;
          }
          expect(
            leakedKey,
            isNull,
            reason: 'The redirect target received the key',
          );
          expect(
            failure,
            isA<JupiterException>().having(
              (error) => error.statusCode,
              'statusCode',
              HttpStatus.seeOther,
            ),
          );
        },
      );
    }
  });
}
