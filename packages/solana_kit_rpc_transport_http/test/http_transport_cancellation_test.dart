import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:solana_kit_rpc_spec/solana_kit_rpc_spec.dart';
import 'package:solana_kit_rpc_transport_http/solana_kit_rpc_transport_http.dart';
import 'package:test/test.dart';

void main() {
  group('HTTP cancellation', () {
    for (final sendHeaders in [false, true]) {
      test('aborts a stalled response after headers: $sendHeaders', () async {
        final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
        final client = http.Client();
        final received = Completer<void>();
        final requests = server.listen((request) async {
          await request.drain<void>();
          if (sendHeaders) {
            request.response.headers.contentType = ContentType.json;
            request.response.write('{');
            await request.response.flush();
          }
          received.complete();
          // Deliberately keep the response open to simulate a stalled RPC node.
        });
        addTearDown(() async {
          client.close();
          await server.close(force: true);
          await requests.cancel();
        });

        final transport = createHttpTransport(
          HttpTransportConfig(
            url: 'http://127.0.0.1:${server.port}',
            allowInsecureHttp: true,
          ),
          client: client,
        );
        final abort = Completer<void>();
        final response = transport(
          RpcTransportConfig(
            payload: const {'method': 'getSlot'},
            signal: abort.future,
          ),
        );
        final assertion = expectLater(
          response.timeout(const Duration(seconds: 2)),
          throwsA(isA<http.RequestAbortedException>()),
        );
        await received.future;
        abort.complete();
        await assertion;
      });
    }
  });
}
