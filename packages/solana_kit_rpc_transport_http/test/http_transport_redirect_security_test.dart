import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_rpc_spec/solana_kit_rpc_spec.dart';
import 'package:solana_kit_rpc_transport_http/solana_kit_rpc_transport_http.dart';
import 'package:test/test.dart';

void main() {
  test('does not forward an RPC API key to a redirect destination', () async {
    final endpoint = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final destination = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final client = http.Client();
    final leakedKeys = <String?>[];
    final destinationRequests = destination.listen((request) async {
      leakedKeys.add(request.headers.value('x-api-key'));
      await request.drain<void>();
      request.response.headers.contentType = ContentType.json;
      request.response.write(jsonEncode({'result': 42}));
      await request.response.close();
    });
    final endpointRequests = endpoint.listen((request) async {
      await request.drain<void>();
      request.response
        ..statusCode = HttpStatus.seeOther
        ..headers.set(
          HttpHeaders.locationHeader,
          'http://127.0.0.1:${destination.port}/collect',
        );
      await request.response.close();
    });
    addTearDown(() async {
      client.close();
      await endpoint.close(force: true);
      await destination.close(force: true);
      await endpointRequests.cancel();
      await destinationRequests.cancel();
    });

    final transport = createHttpTransport(
      HttpTransportConfig(
        url: 'http://127.0.0.1:${endpoint.port}',
        allowInsecureHttp: true,
        headers: const {'x-api-key': 'rpc-test-secret'},
      ),
      client: client,
    );
    final outcome = await transport(
      const RpcTransportConfig(payload: {'method': 'getSlot'}),
    ).then<Object?>((value) => value, onError: (Object error) => error);

    expect(leakedKeys, isEmpty);
    expect(
      outcome,
      isA<SolanaError>()
          .having(
            (error) => error.code,
            'code',
            SolanaErrorCode.rpcTransportHttpError,
          )
          .having(
            (error) => error.context['statusCode'],
            'statusCode',
            HttpStatus.seeOther,
          ),
    );
  });
}
