import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_privacy_rings/solana_kit_privacy_rings.dart';
import 'package:test/test.dart';

Map<String, Object?> _proof({required String pin, List<String>? ar}) {
  return {
    'ar': ar ?? ['0x0', '0x0'],
    'bs': [
      ['0x0', '0x0'],
      ['0x0', '0x0'],
    ],
    'krs': ['0x1', '0x2'],
    'provingKeySha256': pin,
  };
}

void main() {
  const circuit = 'transfer_confidential_1_2';
  final pin = provingKeySha256(circuit)!;

  test(
    'proof A is negated and compressed the way the TypeScript client does',
    () {
      final proof = parseProverProof(
        _proof(pin: pin, ar: ['0x1', '0x2']),
        circuit: circuit,
      );
      expect(proof.a[0], 0x80);
      expect(proof.a[31], 1);
      expect(proof.c[0] & 0x80, 0);
      expect(proof.c[31], 1);
      expect(proof.b, Uint8List(128));
    },
  );

  test('a missing or foreign proving key is rejected', () {
    expect(
      () => parseProverProof({
        'ar': ['0x0', '0x0'],
        'bs': [
          ['0x0', '0x0'],
          ['0x0', '0x0'],
        ],
        'krs': ['0x0', '0x0'],
      }, circuit: circuit),
      throwsA(
        isA<PrivacyRingsException>().having(
          (error) => error.code,
          'code',
          'proving_key_missing',
        ),
      ),
    );
    expect(
      () => parseProverProof(
        _proof(pin: 'ab' * 32),
        circuit: circuit,
      ),
      throwsA(
        isA<PrivacyRingsException>().having(
          (error) => error.code,
          'code',
          'proving_key_mismatch',
        ),
      ),
    );
  });

  test('a 429 falls back to a queued proof and the status poll', () async {
    final calls = <String>[];
    final httpClient = MockClient((request) async {
      calls.add(
        '${request.method} ${request.url.path} '
        'sync=${request.headers['x-sync']} async=${request.headers['x-async']}',
      );
      if (request.headers['x-sync'] == 'true') {
        return http.Response('busy', 429);
      }
      if (request.url.path.endsWith('/status')) {
        return http.Response(
          jsonEncode({
            'status': 'completed',
            'result': _proof(pin: pin),
          }),
          200,
        );
      }
      return http.Response(jsonEncode({'jobId': 'job_1'}), 200);
    });
    final prover = PrivacyProverClient(
      endpoint: Uri.parse('http://127.0.0.1:3001'),
      httpClient: httpClient,
      pollInterval: Duration.zero,
      maxPollInterval: Duration.zero,
    );
    final proof = await prover.prove(
      circuit: circuit,
      witness: const {'inputs': <Object?>[]},
    );
    expect(proof.c[31], 1);
    expect(calls.first, contains('sync=true'));
    expect(calls[1], contains('/prove/$circuit'));
    expect(calls[1], contains('async=true'));
    expect(calls.last, contains('/status'));
  });

  test('a remote prover is not called in the clear unless asked', () async {
    var called = false;
    final prover = PrivacyProverClient(
      endpoint: Uri.parse('https://mainnet.helius-rpc.com/v1/spr'),
      httpClient: MockClient((request) async {
        called = true;
        return http.Response('{}', 200);
      }),
    );
    expect(
      prover.prove(circuit: circuit, witness: const {}),
      throwsA(
        isA<PrivacyRingsException>().having(
          (error) => error.code,
          'code',
          'prover_tee_required',
        ),
      ),
    );
    expect(called, isFalse);
  });
}
