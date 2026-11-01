import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:solana_kit_mobile_wallet_adapter/src/local_association_scenario.dart';
import 'package:solana_kit_mobile_wallet_adapter/src/remote_association_scenario.dart';
import 'package:solana_kit_mobile_wallet_adapter_protocol/solana_kit_mobile_wallet_adapter_protocol.dart';

void main() {
  for (final remote in [false, true]) {
    test(
      '${remote ? 'remote' : 'local'} session closes on deeply nested wallet JSON',
      () async {
        final secret = Uint8List.fromList(List.filled(32, 7));
        final nested = '${'[' * 65}0${']' * 65}';
        final frame = encryptMessage(
          '{"id":1,"result":{"value":$nested}}',
          1,
          secret,
        );
        final local = LocalAssociationScenario();
        final session = createRemoteAssociationSessionForTesting(
          const RemoteWalletAssociationConfig(reflectorHost: 'unused:0'),
        );
        final survived = remote
            ? session.deliverConnectedFrameForTesting(
                sharedSecret: secret,
                message: frame,
              )
            : local.deliverConnectedFrameForTesting(
                sharedSecret: secret,
                message: frame,
              );

        await local.close();
        await session.close();
        expect(survived, isFalse);
        expect(secret, everyElement(0));
      },
    );
  }

  for (final remote in [false, true]) {
    for (final oversized in [false, true]) {
      test(
        '${remote ? 'remote' : 'local'} session ${oversized ? 'rejects oversized' : 'accepts exact-limit'} encrypted frames',
        () async {
          final secret = Uint8List.fromList(List.filled(32, 7));
          final frame = encryptMessage(
            '{"id":1,"result":{"ok":true}}',
            1,
            secret,
          );
          final limits = InboundPayloadLimits(
            maxBytes: frame.length - (oversized ? 1 : 0),
          );
          final local = LocalAssociationScenario(inboundLimits: limits);
          final session = createRemoteAssociationSessionForTesting(
            RemoteWalletAssociationConfig(
              reflectorHost: 'unused:0',
              inboundLimits: limits,
            ),
          );
          final survived = remote
              ? session.deliverConnectedFrameForTesting(
                  sharedSecret: secret,
                  message: frame,
                )
              : local.deliverConnectedFrameForTesting(
                  sharedSecret: secret,
                  message: frame,
                );

          expect(survived, !oversized);
          if (oversized) expect(secret, everyElement(0));
          await local.close();
          await session.close();
        },
      );
    }
  }

  test('remote base64 frames are bounded before and after decoding', () async {
    for (final excess in [0, 1, 3]) {
      final secret = Uint8List.fromList(List.filled(32, 7));
      final frame = encryptMessage('{"id":1,"result":{}}', 1, secret);
      final session = createRemoteAssociationSessionForTesting(
        RemoteWalletAssociationConfig(
          reflectorHost: 'unused:0',
          inboundLimits: InboundPayloadLimits(maxBytes: frame.length - excess),
        ),
      );
      expect(
        session.deliverConnectedFrameForTesting(
          sharedSecret: secret,
          message: base64.encode(frame),
        ),
        excess == 0,
      );
      await session.close();
    }
  });

  test('wallet JSON complexity budget can be increased explicitly', () async {
    final secret = Uint8List.fromList(List.filled(32, 7));
    final nested = '${'[' * 65}0${']' * 65}';
    final frame = encryptMessage(
      '{"id":1,"result":{"value":$nested}}',
      1,
      secret,
    );
    final session = LocalAssociationScenario(
      inboundLimits: const InboundPayloadLimits(maxJsonDepth: 128),
    );
    expect(
      session.deliverConnectedFrameForTesting(
        sharedSecret: secret,
        message: frame,
      ),
      isTrue,
    );
    await session.close();
  });
}
