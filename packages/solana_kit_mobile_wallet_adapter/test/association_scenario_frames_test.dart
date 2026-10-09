import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:solana_kit_mobile_wallet_adapter_protocol/solana_kit_mobile_wallet_adapter_protocol.dart';
import 'package:solana_kit_mobile_wallet_adapter/src/local_association_scenario.dart';
import 'package:solana_kit_mobile_wallet_adapter/src/remote_association_scenario.dart';

void main() {
  // The association handshake cannot be driven in a unit test (local
  // sessions bind a random port and remote sessions require TLS), so the
  // connected-state frame pipeline is exercised through the test-only
  // delivery hook on each session class.
  final sharedSecret = Uint8List.fromList(List.filled(32, 7));

  Uint8List frameWithSequence(int sequenceNumber) {
    final frame = Uint8List(4);
    ByteData.view(frame.buffer).setUint32(0, sequenceNumber);
    return frame;
  }

  group('connected-state frame handling (upstream protocol-kit@3.0.0)', () {
    test('an empty frame is ignored and does not tear down the session', () {
      final local = LocalAssociationScenario();
      expect(
        local.deliverConnectedFrameForTesting(
          sharedSecret: sharedSecret,
          message: Uint8List(0),
        ),
        isTrue,
        reason: 'empty frames (e.g. keep-alives) must not fail the session',
      );
      local.close();
    });

    test('the remote session also survives an empty frame', () {
      final remote = createRemoteAssociationSessionForTesting(
        const RemoteWalletAssociationConfig(reflectorHost: 'unused:0'),
      );
      expect(
        remote.deliverConnectedFrameForTesting(
          sharedSecret: sharedSecret,
          message: Uint8List(0),
        ),
        isTrue,
      );
    });

    test('empty frames do not advance the inbound sequence number', () {
      final local = LocalAssociationScenario();
      expect(
        local.deliverConnectedFrameForTesting(
          sharedSecret: sharedSecret,
          message: Uint8List(0),
        ),
        isTrue,
      );
      // The next expected sequence number is still 1: an empty frame must
      // not consume it, so a frame claiming sequence 2 fails the session.
      expect(
        local.deliverConnectedFrameForTesting(
          sharedSecret: sharedSecret,
          message: frameWithSequence(2),
        ),
        isFalse,
      );
      local.close();
    });

    test(
      'a frame shorter than the sequence prefix still fails the session',
      () {
        final local = LocalAssociationScenario();
        expect(
          local.deliverConnectedFrameForTesting(
            sharedSecret: sharedSecret,
            message: Uint8List.fromList([1, 2, 3]),
          ),
          isFalse,
          reason:
              'only empty frames are tolerated; short frames stay malformed',
        );
        local.close();
      },
    );

    test('startRemoteScenario rejects a malformed reflector host', () async {
      // `Uri.parse` fails synchronously before any connection-retry timer
      // is armed, so the scenario rejects immediately instead of retrying
      // for the full connection deadline.
      await expectLater(
        startRemoteScenario(
          const RemoteWalletAssociationConfig(reflectorHost: '['),
        ),
        throwsA(isA<FormatException>()),
      );
    });

    test('an out-of-order sequence number still fails the session', () {
      final local = LocalAssociationScenario();
      expect(
        local.deliverConnectedFrameForTesting(
          sharedSecret: sharedSecret,
          message: frameWithSequence(999),
        ),
        isFalse,
        reason: 'sequence-number enforcement is unchanged',
      );
      local.close();
    });
  });
}
