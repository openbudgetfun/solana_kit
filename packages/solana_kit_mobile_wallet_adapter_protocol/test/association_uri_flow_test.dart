import 'dart:typed_data';

import 'package:solana_kit_mobile_wallet_adapter_protocol/solana_kit_mobile_wallet_adapter_protocol.dart';
import 'package:test/test.dart';

void main() {
  final key = generateAssociationKeypair().publicKey;

  group('association endpoint paths', () {
    for (final prefix in [
      '',
      '/',
      '/mobilewalletadapter',
      '/mobilewalletadapter/',
    ]) {
      for (final remote in [false, true]) {
        final method = remote ? 'remote' : 'local';
        test(
          'preserves the wallet prefix "$prefix" for $method association',
          () {
            final base = 'https://wallet.example$prefix';
            final uri = remote
                ? buildRemoteAssociationUri(
                    key,
                    'reflector.example',
                    Uint8List.fromList([1]),
                    baseUri: base,
                  )
                : buildLocalAssociationUri(key, 55123, baseUri: base);
            final expectedPrefix = prefix.endsWith('/')
                ? prefix.substring(0, prefix.length - 1)
                : prefix;
            expect(uri.path, '$expectedPrefix/v1/associate/$method');
            expect(uri.host, 'wallet.example');
          },
        );
      }
    }

    test(
      'remote association round-trips under a local-named wallet prefix',
      () {
        final uri = buildRemoteAssociationUri(
          key,
          'reflector.example',
          Uint8List.fromList([1]),
          baseUri: 'https://wallet.example/localwallet/',
        );
        final parsed = parseAssociationUri(uri);
        expect(parsed, isA<RemoteAssociationParams>());
        expect(
          (parsed as RemoteAssociationParams).reflectorHost,
          'reflector.example',
        );
      },
    );

    test(
      'local association round-trips under a remote-named wallet prefix',
      () {
        final uri = buildLocalAssociationUri(
          key,
          55123,
          baseUri: 'https://wallet.example/remotewallet/',
        );
        final parsed = parseAssociationUri(uri);
        expect(parsed, isA<LocalAssociationParams>());
        expect((parsed as LocalAssociationParams).port, 55123);
      },
    );

    test('rejects unrelated paths containing local or remote text', () {
      final local = buildLocalAssociationUri(key, 55123);
      for (final path in [
        '/local-settings',
        '/remote-settings',
        '/v2/associate/local',
      ]) {
        expect(
          () => parseAssociationUri(local.replace(path: path)),
          throwsArgumentError,
        );
      }
    });
  });
}
