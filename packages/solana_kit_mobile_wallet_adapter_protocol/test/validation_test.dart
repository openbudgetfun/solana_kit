import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_mobile_wallet_adapter_protocol/solana_kit_mobile_wallet_adapter_protocol.dart';
import 'package:test/test.dart';

void main() {
  group('assertAssociationPort', () {
    test('accepts minimum valid port', () {
      expect(assertAssociationPort(49152), 49152);
    });

    test('accepts maximum valid port', () {
      expect(assertAssociationPort(65535), 65535);
    });

    test('accepts port in the middle of range', () {
      expect(assertAssociationPort(55000), 55000);
    });

    test('rejects port below minimum', () {
      expect(
        () => assertAssociationPort(49151),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.mwaAssociationPortOutOfRange,
          ),
        ),
      );
    });

    test('rejects port above maximum', () {
      expect(
        () => assertAssociationPort(65536),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.mwaAssociationPortOutOfRange,
          ),
        ),
      );
    });

    test('rejects zero', () {
      expect(
        () => assertAssociationPort(0),
        throwsA(isA<SolanaError>()),
      );
    });

    test('rejects negative port', () {
      expect(
        () => assertAssociationPort(-1),
        throwsA(isA<SolanaError>()),
      );
    });
  });

  group('getRandomAssociationPort', () {
    test('returns port within valid range', () {
      for (var i = 0; i < 100; i++) {
        final port = getRandomAssociationPort();
        expect(port, greaterThanOrEqualTo(49152));
        expect(port, lessThanOrEqualTo(65535));
      }
    });
  });

  group('assertReflectorId', () {
    test('accepts zero', () {
      expect(assertReflectorId(0), 0);
    });

    test('accepts maximum valid id', () {
      expect(assertReflectorId(9007199254740991), 9007199254740991);
    });

    test('accepts positive id', () {
      expect(assertReflectorId(12345), 12345);
    });

    test('rejects negative id', () {
      expect(
        () => assertReflectorId(-1),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.mwaReflectorIdOutOfRange,
          ),
        ),
      );
    });
  });

  group('createSequenceNumberVector', () {
    test('creates 4-byte big-endian vector for zero', () {
      final vector = createSequenceNumberVector(0);
      expect(vector, hasLength(4));
      expect(vector, [0, 0, 0, 0]);
    });

    test('creates 4-byte big-endian vector for 1', () {
      final vector = createSequenceNumberVector(1);
      expect(vector, [0, 0, 0, 1]);
    });

    test('creates correct big-endian vector for 256', () {
      final vector = createSequenceNumberVector(256);
      expect(vector, [0, 0, 1, 0]);
    });

    test('creates correct big-endian vector for 0x01020304', () {
      final vector = createSequenceNumberVector(0x01020304);
      expect(vector, [1, 2, 3, 4]);
    });

    test('handles max valid sequence number (2^32 - 1)', () {
      final vector = createSequenceNumberVector(4294967295);
      expect(vector, [255, 255, 255, 255]);
    });

    test('throws on overflow at 2^32', () {
      expect(
        () => createSequenceNumberVector(4294967296),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.mwaSequenceNumberOverflow,
          ),
        ),
      );
    });

    test('throws on value greater than 2^32', () {
      expect(
        () => createSequenceNumberVector(5000000000),
        throwsA(isA<SolanaError>()),
      );
    });
  });

  group('MwaProtocolError', () {
    test('creates error with required fields', () {
      const error = MwaProtocolError(
        jsonRpcMessageId: 1,
        code: MwaProtocolErrorCode.authorizationFailed,
        message: 'Authorization failed',
      );
      expect(error.jsonRpcMessageId, 1);
      expect(error.code, -1);
      expect(error.message, 'Authorization failed');
      expect(error.data, isNull);
    });

    test('creates error with data', () {
      const error = MwaProtocolError(
        jsonRpcMessageId: 2,
        code: MwaProtocolErrorCode.attestOriginAndroid,
        message: 'Attestation required',
        data: {'attest_origin_uri': 'https://example.com'},
      );
      expect(error.code, -100);
      expect(error.data, isNotNull);
    });

    test('toString includes id, code, and message', () {
      const error = MwaProtocolError(
        jsonRpcMessageId: 1,
        code: -2,
        message: 'Invalid payloads',
      );
      expect(
        error.toString(),
        'MwaProtocolError(id: 1, code: -2, message: Invalid payloads)',
      );
    });
  });

  group('MwaProtocolErrorCode', () {
    test('has correct values matching wallet ProtocolContract', () {
      expect(MwaProtocolErrorCode.authorizationFailed, -1);
      expect(MwaProtocolErrorCode.invalidPayloads, -2);
      expect(MwaProtocolErrorCode.notSigned, -3);
      expect(MwaProtocolErrorCode.notSubmitted, -4);
      expect(MwaProtocolErrorCode.tooManyPayloads, -5);
      expect(MwaProtocolErrorCode.attestOriginAndroid, -100);
    });
  });
}
