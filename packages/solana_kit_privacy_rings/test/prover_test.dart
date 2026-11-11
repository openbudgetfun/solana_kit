import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_privacy_rings/solana_kit_privacy_rings.dart';
import 'package:test/test.dart';

Matcher _code(String code) => throwsA(
  isA<PrivacyRingsException>().having((error) => error.code, 'code', code),
);

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

  test(
    'prover transport, status, and proof parsing cover the failure paths',
    () async {
      expect(
        () => parseProverProof(null, circuit: 'missing-circuit'),
        _code('unknown_circuit'),
      );
      expect(
        () => parseProverProof(null, circuit: circuit),
        _code('prover_server'),
      );
      expect(
        () => parseProverProof({
          'proof': _proof(pin: pin)..['provingKeySha256'] = 'ZZ',
        }, circuit: circuit),
        _code('invalid_response'),
      );
      expect(
        () =>
            parseProverProof(_proof(pin: pin)..['ar'] = null, circuit: circuit),
        _code('proof_parse'),
      );
      final committed = _proof(pin: pin, ar: ['0x1', '0x2'])
        ..['proofCommitment'] = ['0x1', '0x2']
        ..['proofCommitmentPok'] = ['0X1', '0x2'];
      expect(parseProverProof(committed, circuit: circuit).a[31], 1);
      expect(
        () => parseProverProof(
          _proof(pin: pin)..['krs'] = ['0x1', '0x1'],
          circuit: circuit,
        ),
        _code('proof_point'),
      );
      expect(
        () => parseProverProof(
          _proof(pin: pin)..['bs'] = ['0x1'],
          circuit: circuit,
        ),
        _code('proof_parse'),
      );
      expect(
        () => parseProverProof(
          _proof(pin: pin)..['ar'] = ['0x', '0x1'],
          circuit: circuit,
        ),
        _code('proof_parse'),
      );
      expect(
        () => parseProverProof(
          _proof(pin: pin)
            ..['ar'] = [
              '0x${List.filled(64, 'f').join()}',
              '0x1',
            ],
          circuit: circuit,
        ),
        _code('proof_parse'),
      );
      expect(
        () => parseProverProof(
          _proof(pin: pin, ar: ['0x1', '0x2'])..['krs'] = ['0x1', '0x1'],
          circuit: circuit,
        ),
        _code('proof_point'),
      );

      expect(
        () => PrivacyProverClient(
          endpoint: Uri.parse('http://127.0.0.1:3001/?api-key=a'),
          apiKey: 'b',
        ),
        _code('invalid_config'),
      );
      expect(
        () => PrivacyProverClient(
          endpoint: Uri.parse('http://127.0.0.1:3001'),
          apiKey: '',
        ),
        _code('invalid_config'),
      );
      PrivacyProverClient(endpoint: Uri.parse('http://127.0.0.1:3001')).close();

      final direct = PrivacyProverClient(
        endpoint: Uri.parse('http://localhost:3001/?api-key=secret-key'),
        httpClient: MockClient((request) async {
          expect(request.url.queryParameters['api-key'], 'secret-key');
          return http.Response(jsonEncode(_proof(pin: pin)), 200);
        }),
      );
      expect(
        (await direct.prove(circuit: '$circuit.key', witness: const {})).c[31],
        1,
      );

      Future<void> reject(String name) {
        return PrivacyProverClient(
          endpoint: Uri.parse('http://127.0.0.1:3001'),
          httpClient: MockClient((request) async => http.Response('{}', 200)),
        ).prove(circuit: name, witness: const {});
      }

      expect(reject(''), _code('invalid_request'));
      expect(reject('a/b'), _code('invalid_request'));
      expect(reject('..'), _code('invalid_request'));
      expect(
        PrivacyProverClient(
          endpoint: Uri.parse('http://127.0.0.1:3001'),
          httpClient: MockClient((request) async => http.Response('nope', 500)),
        ).prove(circuit: circuit, witness: const {}),
        _code('prover_http'),
      );
      expect(
        PrivacyProverClient(
          endpoint: Uri.parse('http://127.0.0.1:3001'),
          httpClient: MockClient((request) async => http.Response('nope', 200)),
        ).prove(circuit: circuit, witness: const {}),
        _code('invalid_response'),
      );
      expect(
        PrivacyProverClient(
          endpoint: Uri.parse('http://127.0.0.1:3001'),
          httpClient: MockClient((request) async => throw StateError('down')),
        ).prove(circuit: circuit, witness: const {}),
        _code('prover_transport'),
      );
      expect(
        PrivacyProverClient(
          endpoint: Uri.parse('http://example.test/prove'),
          allowUnauthenticatedRemoteProver: true,
          httpClient: MockClient((request) async => http.Response('{}', 200)),
        ).prove(circuit: circuit, witness: const {}),
        _code('invalid_config'),
      );
      expect(
        PrivacyProverClient(
          endpoint: Uri.parse('https://example.test/prove'),
          allowUnauthenticatedRemoteProver: true,
          httpClient: MockClient((request) async {
            return http.Response(jsonEncode(_proof(pin: pin)), 200);
          }),
        ).prove(circuit: circuit, witness: const {}),
        completion(isA<TransactProof>()),
      );
      expect(
        PrivacyProverClient(
          endpoint: Uri.parse('http://[::1]:3001'),
          httpClient: MockClient((request) async {
            return http.Response(jsonEncode({'jobId': 'bad id'}), 200);
          }),
        ).prove(circuit: circuit, witness: const {}),
        _code('prover_job'),
      );
      expect(
        PrivacyProverClient(
          endpoint: Uri.parse('http://127.0.0.1:3001'),
          maxWait: Duration.zero,
          httpClient: MockClient((request) async {
            return http.Response(jsonEncode({'jobId': 'job_1'}), 200);
          }),
        ).prove(circuit: circuit, witness: const {}),
        _code('prover_timeout'),
      );
      expect(
        PrivacyProverClient(
          endpoint: Uri.parse('http://127.0.0.1:3001'),
          maxWait: const Duration(milliseconds: 20),
          httpClient: MockClient((request) async {
            if (request.method == 'POST') {
              return http.Response(jsonEncode({'jobId': 'job_1'}), 200);
            }
            await Future<void>.delayed(const Duration(milliseconds: 40));
            return http.Response('{"status":"queued"}', 500);
          }),
        ).prove(circuit: circuit, witness: const {}),
        _code('prover_timeout'),
      );
      expect(
        PrivacyProverClient(
          endpoint: Uri.parse('http://127.0.0.1:3001'),
          pollInterval: const Duration(milliseconds: 1),
          maxPollInterval: const Duration(milliseconds: 4),
          httpClient: MockClient((request) async {
            if (request.method == 'POST') {
              return http.Response(jsonEncode({'jobId': 'job_1'}), 200);
            }
            return http.Response('{"status":"queued"}', 404);
          }),
        ).prove(circuit: circuit, witness: const {}),
        _code('prover_http'),
      );
      PrivacyProverClient polling(MockClient httpClient) => PrivacyProverClient(
        endpoint: Uri.parse('http://127.0.0.1:3001'),
        pollInterval: const Duration(milliseconds: 1),
        maxPollInterval: const Duration(milliseconds: 4),
        httpClient: httpClient,
      );
      http.Response job(http.Request request) {
        if (request.method == 'POST') {
          return http.Response(jsonEncode({'jobId': 'job_1'}), 200);
        }
        throw StateError('status handler missing');
      }

      expect(
        polling(
          MockClient((request) async {
            if (request.method == 'POST') return job(request);
            return http.Response('[]', 200);
          }),
        ).prove(circuit: circuit, witness: const {}),
        _code('invalid_response'),
      );
      expect(
        polling(
          MockClient((request) async {
            if (request.method == 'POST') return job(request);
            return http.Response(jsonEncode({'status': 'failed'}), 200);
          }),
        ).prove(circuit: circuit, witness: const {}),
        _code('prover_server'),
      );
      var polls = 0;
      final recovered = await polling(
        MockClient((request) async {
          if (request.method == 'POST') return job(request);
          polls++;
          if (polls == 1) {
            return http.Response(jsonEncode({'status': 'queued'}), 200);
          }
          return http.Response(
            jsonEncode({'status': 'completed', 'proof': _proof(pin: pin)}),
            200,
          );
        }),
      ).prove(circuit: circuit, witness: const {});
      expect(recovered.a, hasLength(32));
      expect(polls, 2);
    },
  );
}
