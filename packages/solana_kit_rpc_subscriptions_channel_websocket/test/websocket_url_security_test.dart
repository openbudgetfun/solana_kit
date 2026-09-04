import 'dart:io';

import 'package:solana_kit_rpc_subscriptions_channel_websocket/solana_kit_rpc_subscriptions_channel_websocket.dart';
import 'package:test/test.dart';

void main() {
  group('private-host normalization', () {
    for (final host in [
      'localhost.',
      'LOCALHOST.',
      '127.0.0.1.',
      '127.0x0.0.1',
      '0x7f.0.0.0x1',
      '0x7f.1',
      '[::ffff:7f00:1]',
      '[0:0:0:0:0:ffff:7f00:1]',
      '[::ffff:a00:1]',
      '[::ffff:a9fe:a9fe]',
      '[::7f00:1]',
      '[0000:0:0:0:0:0:0:1]',
      '[0000:0:0:0:0:0:0:0]',
      '[0::1]',
      '[2001:0db8::1]',
    ]) {
      test('rejects the private or non-canonical destination $host', () {
        expect(
          () => validateWebSocketUrl(Uri.parse('wss://$host/socket')),
          throwsArgumentError,
        );
      });

      test('allows $host only with an explicit private-host override', () {
        final url = Uri.parse('wss://$host/socket');
        expect(validateWebSocketUrl(url, allowPrivateHosts: true), same(url));
      });
    }

    for (final host in [
      'fc-rpc.example.com',
      'fd-rpc.example.com',
      'ff-rpc.example.com',
      'fe80-rpc.example.com',
      'example.com.',
      '8.8.8.8',
      '[2606:4700:4700::1111]',
      '[::ffff:808:808]',
      '[2001:db80::1]',
    ]) {
      test('does not misclassify the public destination $host', () {
        final url = Uri.parse('wss://$host/socket');
        expect(validateWebSocketUrl(url), same(url));
      });
    }

    test('blocks a mapped hexadecimal address that reaches loopback', () async {
      final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(server.close);
      final accepted = server.first;
      final socket = await Socket.connect('::ffff:7f00:1', server.port);
      final peer = await accepted;
      addTearDown(socket.destroy);
      addTearDown(peer.destroy);

      // This spelling reaches an IPv4 loopback listener without DNS.
      expect(peer.remoteAddress.isLoopback, isTrue);
      expect(
        () => validateWebSocketUrl(
          Uri.parse('wss://[::ffff:7f00:1]:${server.port}'),
        ),
        throwsArgumentError,
      );
    });
  });
}
