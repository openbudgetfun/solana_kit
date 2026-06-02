import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

void main() {
  group('oauthTokenExchange', () {
    const request = OAuthTokenExchangeRequest(
      code: 'auth-code',
      codeVerifier: 'verifier-123',
      clientId: 'cli-client',
      redirectUri: 'http://127.0.0.1:0/callback',
      userAgent: 'solana-kit-test',
    );

    test(
      'POSTs to /oauth/token as application/x-www-form-urlencoded',
      () async {
        final client = MockClient((httpRequest) async {
          expect(httpRequest.method, 'POST');
          expect(
            httpRequest.url.toString(),
            '$heliusDeveloperApiUrl/oauth/token',
          );
          expect(
            httpRequest.headers['Content-Type'],
            'application/x-www-form-urlencoded',
          );
          expect(httpRequest.headers['User-Agent'], 'solana-kit-test');

          final params = Uri.splitQueryString(httpRequest.body);
          expect(params['grant_type'], 'authorization_code');
          expect(params['code'], request.code);
          expect(params['code_verifier'], request.codeVerifier);
          expect(params['client_id'], request.clientId);
          expect(params['redirect_uri'], request.redirectUri);

          return http.Response(
            jsonEncode(<String, Object?>{
              'access_token': 'jwt-token',
              'token_type': 'Bearer',
              'expires_in': 3600,
              'user': {'id': 'user-1', 'email': 'dev@helius.xyz'},
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        });

        final response = await oauthTokenExchange(request, client: client);

        expect(response.accessToken, 'jwt-token');
        expect(response.tokenType, 'Bearer');
        expect(response.expiresIn, 3600);
        expect(response.user.id, 'user-1');
        expect(response.user.email, 'dev@helius.xyz');
      },
    );

    test('throws on HTTP error', () async {
      final client = MockClient(
        (request) async => http.Response('Bad Request', 400),
      );

      await expectLater(
        oauthTokenExchange(request, client: client),
        throwsA(isA<Exception>()),
      );
    });
  });
}
