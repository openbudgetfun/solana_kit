import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_helius/src/auth/developer_api.dart';
import 'package:test/test.dart';

void main() {
  group('developer API', () {
    test('rejects relative and non-HTTP base URLs', () async {
      final client = MockClient((_) async => http.Response('{}', 200));

      for (final baseUrl in ['/v0', 'ftp://developer.example/v0']) {
        await expectLater(
          developerListProjects('jwt', client: client, baseUrl: baseUrl),
          throwsA(isA<ArgumentError>()),
        );
      }
    });

    test('uses an owned HTTP client and forwards the user agent', () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(() => server.close(force: true));

      final responseFuture = developerWalletSignup(
        message: 'message',
        signature: 'signature',
        walletAddress: 'wallet',
        userAgent: 'solana-kit-test',
        baseUrl: 'http://${server.address.host}:${server.port}/v0',
      );
      final request = await server.first;
      expect(request.method, 'POST');
      expect(request.uri.path, '/v0/wallet-signup');
      expect(
        request.headers.value(HttpHeaders.userAgentHeader),
        'solana-kit-test',
      );
      request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType = ContentType.json
        ..write(
          jsonEncode({'token': 'jwt', 'refId': 'ref', 'newUser': true}),
        );
      await request.response.close();

      final response = await responseFuture;
      expect(response.token, 'jwt');
      expect(response.refId, 'ref');
      expect(response.newUser, isTrue);
    });

    test(
      'reports bounded response bodies for developer API failures',
      () async {
        final longBody = List.filled(5000, 'x').join();
        for (final body in ['denied', longBody]) {
          final client = MockClient((_) async => http.Response(body, 403));
          await expectLater(
            developerListProjects(
              'jwt',
              client: client,
              baseUrl: 'https://developer.example/v0',
            ),
            throwsA(
              isA<SolanaError>()
                  .having(
                    (error) => error.code,
                    'code',
                    SolanaErrorCode.heliusRestError,
                  )
                  .having(
                    (error) => error.context[SolanaErrorContextKeys.statusCode],
                    'statusCode',
                    403,
                  )
                  .having(
                    (error) => error.context['message'],
                    'message',
                    body.length <= 4096
                        ? body
                        : '${List.filled(4096, 'x').join()}…',
                  ),
            ),
          );
        }
      },
    );

    test('rejects empty required response fields', () async {
      final client = MockClient(
        (_) async => http.Response(
          jsonEncode({'token': '', 'refId': 'ref', 'newUser': true}),
          200,
        ),
      );

      await expectLater(
        developerWalletSignup(
          message: 'message',
          signature: 'signature',
          walletAddress: 'wallet',
          client: client,
          baseUrl: 'https://developer.example/v0',
        ),
        throwsFormatException,
      );
    });
  });
}
