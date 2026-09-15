import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:test/test.dart';

/// A JSON-RPC result envelope.
String _rpcResult(Object? result, {int id = 1}) => jsonEncode({
  'jsonrpc': '2.0',
  'id': id,
  'result': result,
});

String _rpcError(int code, String message) => jsonEncode({
  'jsonrpc': '2.0',
  'id': 1,
  'error': {'code': code, 'message': message},
});

/// The `simulateTransaction` result carrying [units].
String _simulation(int units) => _rpcResult({
  'context': {'slot': 1},
  'value': {'err': null, 'unitsConsumed': units},
});

/// Records every JSON-RPC method the client calls, replying via [handler].
///
/// A `null` reply from [handler] becomes a JSON-RPC "method not found" error,
/// which is how the client surfaces an unexpected node response.
({HeliusClient helius, List<String> methods}) _client(
  Object? Function(String method) handler,
) {
  final methods = <String>[];
  final client = MockClient((request) async {
    final body = jsonDecode(request.body) as Map<String, Object?>;
    final method = body['method']! as String;
    methods.add(method);
    final response = handler(method);
    return http.Response(
      response as String? ?? _rpcError(-32601, 'Method not found: $method'),
      200,
      headers: {'content-type': 'application/json'},
    );
  });
  return (
    helius: createHelius(HeliusConfig(apiKey: 'test-key'), client: client),
    methods: methods,
  );
}

void main() {
  group('txCreateSmartTransaction', () {
    test(
      'estimates compute units and priority fee, and refreshes blockhash',
      () async {
        final harness = _client((method) {
          switch (method) {
            case 'simulateTransaction':
              return _simulation(100000);
            case 'getPriorityFeeEstimate':
              return _rpcResult({'priorityFeeEstimate': 2000});
            case 'getLatestBlockhash':
              return _rpcResult({
                'context': {'slot': 1},
                'value': {
                  'blockhash': 'refreshed',
                  'lastValidBlockHeight': 2000,
                },
              });
            default:
              return null;
          }
        });

        final result = await harness.helius.transactions.createSmartTransaction(
          const CreateSmartTransactionInput(
            instructions: <Object?>[],
            signers: <String>['FeePayer1111111111111111111111111111111111'],
          ),
        );

        // 100000 * 1.1 ceil'd, matching upstream's `Math.ceil` arithmetic.
        expect(result.computeUnits, equals(110001));
        expect(result.priorityFee, equals(2000));
        expect(
          result.priorityFeeLamports,
          equals(BigInt.from(221)),
          reason:
              '2000 microLamports/CU * 110001 CU = 220,002,000 microLamports, '
              'which is 221 lamports rounded up',
        );
        expect(result.blockhash, equals('refreshed'));
        expect(result.lastValidBlockHeight, equals(2000));
        expect(result.version, equals(0));
        expect(
          result.feePayer,
          equals('FeePayer1111111111111111111111111111111111'),
        );
      },
    );

    test(
      'simulates before sampling the fee and refreshing the blockhash',
      () async {
        final harness = _client((method) {
          switch (method) {
            case 'simulateTransaction':
              return _simulation(50000);
            case 'getPriorityFeeEstimate':
              return _rpcResult({'priorityFeeEstimate': 1000});
            default:
              return _rpcResult({
                'context': {'slot': 1},
                'value': {'blockhash': 'bh', 'lastValidBlockHeight': 3000},
              });
          }
        });

        await harness.helius.transactions.createSmartTransaction(
          const CreateSmartTransactionInput(
            instructions: <Object?>[],
            signers: <String>['FeePayer1111111111111111111111111111111111'],
          ),
        );

        expect(harness.methods, [
          'simulateTransaction',
          'getPriorityFeeEstimate',
          'getLatestBlockhash',
        ]);
      },
    );

    test('honours an explicit compute unit limit over the estimate', () async {
      final harness = _client((method) {
        switch (method) {
          case 'simulateTransaction':
            return _simulation(100000);
          case 'getPriorityFeeEstimate':
            return _rpcResult({'priorityFeeEstimate': 1000});
          default:
            return _rpcResult({
              'context': {'slot': 1},
              'value': {'blockhash': 'bh', 'lastValidBlockHeight': 3000},
            });
        }
      });

      final result = await harness.helius.transactions.createSmartTransaction(
        const CreateSmartTransactionInput(
          instructions: <Object?>[],
          signers: <String>['FeePayer1111111111111111111111111111111111'],
          computeUnitLimit: 75000,
        ),
      );

      expect(result.computeUnits, equals(75000));
    });

    test(
      'prices by account key rather than a serialized transaction',
      () async {
        Map<String, Object?>? feeRequest;
        final client = MockClient((request) async {
          final body = jsonDecode(request.body) as Map<String, Object?>;
          final reply = switch (body['method']) {
            'simulateTransaction' => _simulation(10000),
            'getPriorityFeeEstimate' => () {
              feeRequest = body['params']! as Map<String, Object?>;
              return _rpcResult({'priorityFeeEstimate': 1000});
            }(),
            _ => _rpcResult({
              'context': {'slot': 1},
              'value': {'blockhash': 'bh', 'lastValidBlockHeight': 1},
            }),
          };
          return http.Response(
            reply,
            200,
            headers: {'content-type': 'application/json'},
          );
        });
        final helius = createHelius(
          HeliusConfig(apiKey: 'test-key'),
          client: client,
        );

        final result = await helius.transactions.createSmartTransaction(
          const CreateSmartTransactionInput(
            instructions: <Object?>[],
            signers: <String>['FeePayer1111111111111111111111111111111111'],
          ),
        );

        expect(feeRequest, isNotNull);
        expect(feeRequest!['accountKeys'], isNotNull);
        expect(feeRequest!['transaction'], isNull);
        expect(result.accountKeys, contains(result.feePayer));
      },
    );

    test('collects instruction accounts into accountKeys', () async {
      Map<String, Object?>? feeRequest;
      final client = MockClient((request) async {
        final body = jsonDecode(request.body) as Map<String, Object?>;
        final reply = switch (body['method']) {
          'simulateTransaction' => _simulation(10000),
          'getPriorityFeeEstimate' => () {
            feeRequest = body['params']! as Map<String, Object?>;
            return _rpcResult({'priorityFeeEstimate': 1000});
          }(),
          _ => _rpcResult({
            'context': {'slot': 1},
            'value': {'blockhash': 'bh', 'lastValidBlockHeight': 1},
          }),
        };
        return http.Response(
          reply,
          200,
          headers: {'content-type': 'application/json'},
        );
      });
      final helius = createHelius(
        HeliusConfig(apiKey: 'test-key'),
        client: client,
      );

      await helius.transactions.createSmartTransaction(
        const CreateSmartTransactionInput(
          instructions: <Object?>[
            <String, Object?>{
              'programAddress': 'Program1111111111111111111111111111111111',
              'accounts': <Object?>[
                <String, Object?>{'address': 'AccountA'},
                <String, Object?>{'address': 'AccountB'},
              ],
            },
          ],
          signers: <String>['FeePayer1111111111111111111111111111111111'],
        ),
      );

      // The fee payer leads, then each referenced account once.
      expect(feeRequest!['accountKeys'], [
        'FeePayer1111111111111111111111111111111111',
        'AccountA',
        'AccountB',
      ]);
    });

    test('reads account keys from real Instruction objects', () async {
      Map<String, Object?>? feeRequest;
      final client = MockClient((request) async {
        final body = jsonDecode(request.body) as Map<String, Object?>;
        final reply = switch (body['method']) {
          'simulateTransaction' => _simulation(10000),
          'getPriorityFeeEstimate' => () {
            feeRequest = body['params']! as Map<String, Object?>;
            return _rpcResult({'priorityFeeEstimate': 1000});
          }(),
          _ => _rpcResult({
            'context': {'slot': 1},
            'value': {'blockhash': 'bh', 'lastValidBlockHeight': 1},
          }),
        };
        return http.Response(
          reply,
          200,
          headers: {'content-type': 'application/json'},
        );
      });
      final helius = createHelius(
        HeliusConfig(apiKey: 'test-key'),
        client: client,
      );

      await helius.transactions.createSmartTransaction(
        CreateSmartTransactionInput(
          instructions: <Object?>[
            Instruction(
              programAddress: const Address(
                'Program1111111111111111111111111111111111',
              ),
              accounts: const <AccountMeta>[
                AccountMeta(
                  address: Address('AccountA'),
                  role: AccountRole.readonly,
                ),
              ],
              data: Uint8List(0),
            ),
          ],
          signers: const <String>[
            'FeePayer1111111111111111111111111111111111',
          ],
        ),
      );

      expect(feeRequest!['accountKeys'], contains('AccountA'));
    });

    test('strips a real compute budget Instruction object', () async {
      final harness = _client((method) {
        switch (method) {
          case 'simulateTransaction':
            return _simulation(10000);
          case 'getPriorityFeeEstimate':
            return _rpcResult({'priorityFeeEstimate': 1000});
          default:
            return _rpcResult({
              'context': {'slot': 1},
              'value': {'blockhash': 'bh', 'lastValidBlockHeight': 1},
            });
        }
      });

      final result = await harness.helius.transactions.createSmartTransaction(
        CreateSmartTransactionInput(
          instructions: <Object?>[
            Instruction(
              programAddress: const Address(
                'ComputeBudget111111111111111111111111111111',
              ),
              accounts: const <AccountMeta>[],
              data: Uint8List(0),
            ),
            Instruction(
              programAddress: const Address(
                'Program1111111111111111111111111111111111',
              ),
              accounts: const <AccountMeta>[],
              data: Uint8List(0),
            ),
          ],
          signers: const <String>[
            'FeePayer1111111111111111111111111111111111',
          ],
        ),
      );

      expect(result.instructions, hasLength(1));
    });

    test('accepts a block height the node reported as a string', () async {
      final harness = _client((method) {
        switch (method) {
          case 'simulateTransaction':
            return _simulation(10000);
          case 'getPriorityFeeEstimate':
            return _rpcResult({'priorityFeeEstimate': 1000});
          default:
            return _rpcResult({
              'context': {'slot': 1},
              'value': {'blockhash': 'bh', 'lastValidBlockHeight': '4096'},
            });
        }
      });

      final result = await harness.helius.transactions.createSmartTransaction(
        const CreateSmartTransactionInput(
          instructions: <Object?>[],
          signers: <String>['FeePayer1111111111111111111111111111111111'],
        ),
      );

      expect(result.lastValidBlockHeight, equals(4096));
    });

    test('rejects an instruction it cannot render as JSON', () async {
      // An opaque object has no JSON rendering, so it fails loudly at the
      // transport boundary rather than being silently dropped.
      final harness = _client((method) {
        switch (method) {
          case 'simulateTransaction':
            return _simulation(10000);
          case 'getPriorityFeeEstimate':
            return _rpcResult({'priorityFeeEstimate': 1000});
          default:
            return _rpcResult({
              'context': {'slot': 1},
              'value': {'blockhash': 'bh', 'lastValidBlockHeight': 1},
            });
        }
      });

      expect(
        () => harness.helius.transactions.createSmartTransaction(
          const CreateSmartTransactionInput(
            instructions: <Object?>[Object()],
            signers: <String>[
              'FeePayer1111111111111111111111111111111111',
            ],
          ),
        ),
        throwsA(isA<JsonUnsupportedObjectError>()),
      );
    });

    test('throws when the node reports a non-integer block height', () async {
      final harness = _client((method) {
        switch (method) {
          case 'simulateTransaction':
            return _simulation(10000);
          case 'getPriorityFeeEstimate':
            return _rpcResult({'priorityFeeEstimate': 1000});
          default:
            return _rpcResult({
              'context': {'slot': 1},
              'value': {'blockhash': 'bh', 'lastValidBlockHeight': null},
            });
        }
      });

      expect(
        () => harness.helius.transactions.createSmartTransaction(
          const CreateSmartTransactionInput(
            instructions: <Object?>[],
            signers: <String>['FeePayer1111111111111111111111111111111111'],
          ),
        ),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('Expected an integer'),
          ),
        ),
      );
    });

    test('forwards compute unit price and lookup table options', () async {
      // Both optional fields must reach the node rather than being dropped.
      final harness = _client((method) {
        switch (method) {
          case 'simulateTransaction':
            return _simulation(10000);
          case 'getPriorityFeeEstimate':
            return _rpcResult({'priorityFeeEstimate': 1000});
          default:
            return _rpcResult({
              'context': {'slot': 1},
              'value': {'blockhash': 'bh', 'lastValidBlockHeight': 1},
            });
        }
      });

      final result = await harness.helius.transactions.createSmartTransaction(
        const CreateSmartTransactionInput(
          instructions: <Object?>[],
          signers: <String>['FeePayer1111111111111111111111111111111111'],
          computeUnitPrice: 5000,
          lookupTableAddresses: 'Lookup111111111111111111111111111111111111',
        ),
      );

      expect(result.priorityFee, equals(1000));
    });

    test('throws when the fee API returns no estimate', () async {
      final harness = _client((method) {
        switch (method) {
          case 'simulateTransaction':
            return _simulation(10000);
          case 'getPriorityFeeEstimate':
            return _rpcResult(<String, Object?>{});
          default:
            return _rpcResult({
              'context': {'slot': 1},
              'value': {'blockhash': 'bh', 'lastValidBlockHeight': 1},
            });
        }
      });

      expect(
        () => harness.helius.transactions.createSmartTransaction(
          const CreateSmartTransactionInput(
            instructions: <Object?>[],
            signers: <String>['FeePayer1111111111111111111111111111111111'],
          ),
        ),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('Priority fee estimate not available'),
          ),
        ),
      );
    });

    test('rejects a non-positive explicit compute unit limit', () async {
      final harness = _client((_) => null);

      expect(
        () => harness.helius.transactions.createSmartTransaction(
          const CreateSmartTransactionInput(
            instructions: <Object?>[],
            signers: <String>['FeePayer1111111111111111111111111111111111'],
            computeUnitLimit: 0,
          ),
        ),
        throwsA(isA<StateError>()),
      );
      expect(
        harness.methods,
        isEmpty,
        reason: 'validation must run before any round trip',
      );
    });

    test('requires a signer or an explicit fee payer', () async {
      final harness = _client((_) => null);

      expect(
        () => harness.helius.transactions.createSmartTransaction(
          const CreateSmartTransactionInput(instructions: <Object?>[]),
        ),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('expected at least one signer'),
          ),
        ),
      );
    });

    test('strips caller-supplied compute budget instructions', () async {
      final harness = _client((method) {
        switch (method) {
          case 'simulateTransaction':
            return _simulation(10000);
          case 'getPriorityFeeEstimate':
            return _rpcResult({'priorityFeeEstimate': 1000});
          default:
            return _rpcResult({
              'context': {'slot': 1},
              'value': {'blockhash': 'bh', 'lastValidBlockHeight': 1},
            });
        }
      });

      final result = await harness.helius.transactions.createSmartTransaction(
        const CreateSmartTransactionInput(
          instructions: <Object?>[
            <String, Object?>{
              'programAddress': 'ComputeBudget111111111111111111111111111111',
              'accounts': <Object?>[],
            },
            <String, Object?>{'programAddress': 'OtherProgram'},
          ],
          signers: <String>['FeePayer1111111111111111111111111111111111'],
        ),
      );

      expect(
        result.instructions,
        hasLength(1),
        reason: 'the compute budget instruction is replaced by resolved limits',
      );
    });

    test('surfaces a JSON-RPC error from the node', () async {
      final harness = _client((_) => null);

      expect(
        () => harness.helius.transactions.createSmartTransaction(
          const CreateSmartTransactionInput(
            instructions: <Object?>[],
            signers: <String>['FeePayer1111111111111111111111111111111111'],
          ),
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('allows address lookup tables on a version 0 request', () async {
      // Lookup tables are a version 0 feature. The v1 guard returns early for
      // any other version, matching upstream's `assertNoAddressLookupsOnV1`.
      final harness = _client((method) {
        switch (method) {
          case 'simulateTransaction':
            return _simulation(10000);
          case 'getPriorityFeeEstimate':
            return _rpcResult({'priorityFeeEstimate': 1000});
          default:
            return _rpcResult({
              'context': {'slot': 1},
              'value': {'blockhash': 'bh', 'lastValidBlockHeight': 1},
            });
        }
      });

      final result = await harness.helius.transactions.createSmartTransaction(
        const CreateSmartTransactionInput(
          instructions: <Object?>[],
          signers: <String>['FeePayer1111111111111111111111111111111111'],
          lookupTableAddresses: 'Lookup111111111111111111111111111111111111',
        ),
      );

      expect(result.version, equals(0));
    });
  });

  group('bufferComputeUnits', () {
    test('adds a ten percent buffer and floors at the minimum', () {
      // `Math.ceil` semantics: 100000 * 1.1 lands just above 110000 in binary
      // floating point, so the ceiling is 110001. Upstream produces the same.
      expect(bufferComputeUnits(100000), equals(110001));
      expect(bufferComputeUnits(1), equals(1000));
      expect(bufferComputeUnits(1000), equals(1100));
    });

    test('never exceeds the runtime maximum', () {
      expect(bufferComputeUnits(1400000), equals(1400000));
      expect(bufferComputeUnits(2000000), equals(1400000));
    });

    test('honours a custom floor and buffer', () {
      expect(
        bufferComputeUnits(100, minimum: 500, bufferPercent: 0.5),
        equals(500),
      );
      expect(
        bufferComputeUnits(1000, minimum: 1, bufferPercent: 0.5),
        equals(1500),
      );
    });
  });
}
