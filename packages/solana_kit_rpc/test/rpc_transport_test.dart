import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_rpc/solana_kit_rpc.dart';
import 'package:solana_kit_rpc_spec/solana_kit_rpc_spec.dart';
import 'package:test/test.dart';

void main() {
  group('createDefaultRpcTransport', () {
    late http.Request capturedRequest;
    late RpcTransport transport;

    setUp(() {
      final mockClient = MockClient((request) async {
        capturedRequest = request;
        return http.Response(
          jsonEncode({'ok': true}),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      transport = createDefaultRpcTransport(
        url: 'http://localhost',
        client: mockClient,
      );
    });

    test('sets the solana-client header', () async {
      await transport(const RpcTransportConfig(payload: 123));
      expect(capturedRequest.headers['solana-client'], 'dart/0.0.1');
    });

    test('user cannot override the solana-client header', () async {
      final mockClient = MockClient((request) async {
        capturedRequest = request;
        return http.Response(
          jsonEncode({'ok': true}),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final customTransport = createDefaultRpcTransport(
        url: 'http://localhost',
        headers: {'Solana-Client': 'fakeversion'},
        client: mockClient,
      );

      await customTransport(const RpcTransportConfig(payload: 123));
      expect(capturedRequest.headers['solana-client'], 'dart/0.0.1');
    });

    test('adds configured headers to each request with lowercased property '
        'names', () async {
      final mockClient = MockClient((request) async {
        capturedRequest = request;
        return http.Response(
          jsonEncode({'ok': true}),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final customTransport = createDefaultRpcTransport(
        url: 'http://localhost',
        headers: {'aUtHoRiZaTiOn': 'Picard, 4 7 Alpha Tango'},
        client: mockClient,
      );

      await customTransport(const RpcTransportConfig(payload: 123));
      expect(
        capturedRequest.headers['authorization'],
        'Picard, 4 7 Alpha Tango',
      );
    });

    test(
      'request coalescing is applied for identical JSON-RPC payloads',
      () async {
        var callCount = 0;
        final mockClient = MockClient((request) async {
          callCount++;
          return http.Response(
            jsonEncode({'jsonrpc': '2.0', 'result': 42, 'id': '1'}),
            200,
            headers: {'content-type': 'application/json'},
          );
        });

        final coalescedTransport = createDefaultRpcTransport(
          url: 'http://localhost',
          client: mockClient,
        );

        final payload = <String, Object?>{
          'jsonrpc': '2.0',
          'method': 'getSlot',
          'params': <Object?>[],
          'id': '1',
        };

        // Make two identical requests in the same tick.
        final responseA = coalescedTransport(
          RpcTransportConfig(payload: payload),
        );
        final responseB = coalescedTransport(
          RpcTransportConfig(payload: payload),
        );

        await Future.wait([responseA, responseB]);

        // Only one HTTP call should have been made due to coalescing.
        expect(callCount, 1);
      },
    );
  });
}
