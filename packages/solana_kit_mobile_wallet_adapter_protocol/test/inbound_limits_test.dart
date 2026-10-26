import 'dart:typed_data';

import 'package:solana_kit_mobile_wallet_adapter_protocol/solana_kit_mobile_wallet_adapter_protocol.dart';
import 'package:test/test.dart';

void main() {
  final secret = Uint8List.fromList(List.filled(32, 7));

  test('rejects oversized encrypted bytes before cryptographic processing', () {
    expect(
      () => decryptMessage(
        Uint8List(9),
        secret,
        inboundLimits: const InboundPayloadLimits(maxBytes: 8),
      ),
      throwsA(isA<InboundPayloadLimitException>()),
    );
  });

  test('bounds JSON tokens before decoding a wallet response', () {
    final frame = encryptMessage('{"id":1,"result":{"ok":true}}', 1, secret);
    expect(
      () => decryptJsonRpcResponse(
        frame,
        secret,
        inboundLimits: const InboundPayloadLimits(maxJsonTokens: 3),
      ),
      throwsA(isA<InboundPayloadLimitException>()),
    );
    expect(decryptJsonRpcResponse(frame, secret), {'ok': true});
  });

  test(
    'applies complexity limits to encrypted handshake session properties',
    () {
      final frame = encryptMessage('{"v":1,"other":[[[0]]]}', 1, secret);
      expect(
        () => parseSessionProps(
          frame,
          secret,
          inboundLimits: const InboundPayloadLimits(maxJsonDepth: 2),
        ),
        throwsA(isA<InboundPayloadLimitException>()),
      );
      expect(
        parseSessionProps(frame, secret).protocolVersion,
        ProtocolVersion.v1,
      );
    },
  );
}
