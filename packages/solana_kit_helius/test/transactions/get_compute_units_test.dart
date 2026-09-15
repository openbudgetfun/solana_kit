import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:test/test.dart';

void main() {
  group('TransactionsClient.getComputeUnits', () {
    test(
      'sends simulateTransaction RPC and deserializes compute units',
      () async {
        final client = MockClient((request) async {
          expect(request.method, 'POST');
          final body = jsonDecode(request.body) as Map<String, Object?>;
          expect(body['method'], 'simulateTransaction');
          expect(body['jsonrpc'], '2.0');
          final params = body['params']! as List<Object?>;
          expect(params.length, 2);
          final options = params[1]! as Map<String, Object?>;
          expect(options['replaceRecentBlockhash'], true);
          expect(options['sigVerify'], false);
          return http.Response(
            jsonEncode(<String, Object?>{
              'jsonrpc': '2.0',
              'id': 1,
              'result': <String, Object?>{
                'value': <String, Object?>{'unitsConsumed': 150000},
              },
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        });

        final helius = createHelius(
          HeliusConfig(apiKey: 'test-key'),
          client: client,
        );

        final estimate = await helius.transactions.getComputeUnits(
          const CreateSmartTransactionInput(
            instructions: <Object?>['instruction1'],
          ),
        );

        expect(estimate.units, 150000);
      },
    );

    test('throws when unitsConsumed is absent', () async {
      // Inventing a default here would size the transaction for work the
      // simulation never confirmed, so a missing counter is an error.
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode(<String, Object?>{
            'jsonrpc': '2.0',
            'id': 1,
            'result': <String, Object?>{
              'value': <String, Object?>{},
            },
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final helius = createHelius(
        HeliusConfig(apiKey: 'test-key'),
        client: client,
      );

      expect(
        () => helius.transactions.getComputeUnits(
          const CreateSmartTransactionInput(instructions: <Object?>[]),
        ),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('did not report unitsConsumed'),
          ),
        ),
      );
    });

    test('serializes lookup-table accounts with their table address', () async {
      List<Object?>? sentParams;
      final client = MockClient((request) async {
        final body = jsonDecode(request.body) as Map<String, Object?>;
        sentParams = body['params']! as List<Object?>;
        return http.Response(
          jsonEncode(<String, Object?>{
            'jsonrpc': '2.0',
            'id': 1,
            'result': <String, Object?>{
              'value': <String, Object?>{'unitsConsumed': 4200, 'err': null},
            },
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final helius = createHelius(
        HeliusConfig(apiKey: 'test-key'),
        client: client,
      );

      await helius.transactions.getComputeUnits(
        CreateSmartTransactionInput(
          instructions: <Object?>[
            Instruction(
              programAddress: const Address(
                'Program1111111111111111111111111111111111',
              ),
              accounts: const <AccountMeta>[
                AccountLookupMeta(
                  address: Address(
                    'LookedUp1111111111111111111111111111111111',
                  ),
                  addressIndex: 3,
                  lookupTableAddress: Address(
                    'Table1111111111111111111111111111111111111',
                  ),
                  role: AccountRole.writable,
                ),
              ],
              data: Uint8List(0),
            ),
          ],
        ),
      );

      final payload = sentParams!.first! as Map<String, Object?>;
      final instructions = payload['instructions']! as List<Object?>;
      final serialized = instructions.single! as Map<String, Object?>;
      final accounts = serialized['accounts']! as List<Object?>;
      final account = accounts.single! as Map<String, Object?>;
      expect(account['lookupTableAddress'], isNotNull);
      expect(account['role'], equals('writable'));
    });

    test('serializes every account role name', () async {
      List<Object?>? sentParams;
      final client = MockClient((request) async {
        final body = jsonDecode(request.body) as Map<String, Object?>;
        sentParams = body['params']! as List<Object?>;
        return http.Response(
          jsonEncode(<String, Object?>{
            'jsonrpc': '2.0',
            'id': 1,
            'result': <String, Object?>{
              'value': <String, Object?>{'unitsConsumed': 4200, 'err': null},
            },
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final helius = createHelius(
        HeliusConfig(apiKey: 'test-key'),
        client: client,
      );

      await helius.transactions.getComputeUnits(
        const CreateSmartTransactionInput(
          instructions: <Object?>[
            Instruction(
              programAddress: Address(
                'Program1111111111111111111111111111111111',
              ),
              accounts: <AccountMeta>[
                AccountMeta(
                  address: Address(
                    'Readonly1111111111111111111111111111111111',
                  ),
                  role: AccountRole.readonly,
                ),
                AccountMeta(
                  address: Address(
                    'Writable1111111111111111111111111111111111',
                  ),
                  role: AccountRole.writable,
                ),
                AccountMeta(
                  address: Address(
                    'ReadonlySigner1111111111111111111111111111',
                  ),
                  role: AccountRole.readonlySigner,
                ),
              ],
            ),
          ],
        ),
      );

      final payload = sentParams!.first! as Map<String, Object?>;
      final instructions = payload['instructions']! as List<Object?>;
      final serialized = instructions.single! as Map<String, Object?>;
      final accounts = serialized['accounts']! as List<Object?>;
      expect(
        accounts.map((a) => (a! as Map<String, Object?>)['role']),
        ['readonly', 'writable', 'readonlySigner'],
      );
      // A null data field is omitted entirely rather than sent as null.
      expect(serialized.containsKey('data'), isFalse);
    });

    test('throws when the simulation itself failed', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode(<String, Object?>{
            'jsonrpc': '2.0',
            'id': 1,
            'result': <String, Object?>{
              'value': <String, Object?>{
                'err': {
                  'InsufficientFundsForRent': {'account_index': 1},
                },
                'unitsConsumed': 150,
              },
            },
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final helius = createHelius(
        HeliusConfig(apiKey: 'test-key'),
        client: client,
      );

      expect(
        () => helius.transactions.getComputeUnits(
          const CreateSmartTransactionInput(instructions: <Object?>[]),
        ),
        throwsA(
          isA<SolanaError>()
              .having(
                (e) => e.code,
                'code',
                SolanaErrorCode.heliusTransactionSimulationFailed,
              )
              .having(
                (e) => e.context['message'],
                'message',
                contains('simulateTransaction failed'),
              ),
        ),
      );
    });

    test('serializes real Instruction objects', () async {
      List<Object?>? sentParams;
      final client = MockClient((request) async {
        final body = jsonDecode(request.body) as Map<String, Object?>;
        sentParams = body['params']! as List<Object?>;
        return http.Response(
          jsonEncode(<String, Object?>{
            'jsonrpc': '2.0',
            'id': 1,
            'result': <String, Object?>{
              'value': <String, Object?>{'unitsConsumed': 4200, 'err': null},
            },
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final helius = createHelius(
        HeliusConfig(apiKey: 'test-key'),
        client: client,
      );

      await helius.transactions.getComputeUnits(
        CreateSmartTransactionInput(
          instructions: <Object?>[
            Instruction(
              programAddress: const Address(
                'Program1111111111111111111111111111111111',
              ),
              accounts: const <AccountMeta>[
                AccountMeta(
                  address: Address('AccountA'),
                  role: AccountRole.writableSigner,
                ),
              ],
              data: Uint8List.fromList(<int>[1, 2, 3]),
            ),
          ],
        ),
      );

      // The instruction must reach the node as plain JSON, not as an object
      // the encoder cannot render.
      final payload = sentParams!.first! as Map<String, Object?>;
      final instructions = payload['instructions']! as List<Object?>;
      final serialized = instructions.single! as Map<String, Object?>;
      expect(
        serialized['programAddress'],
        equals('Program1111111111111111111111111111111111'),
      );
      final accounts = serialized['accounts']! as List<Object?>;
      expect(
        (accounts.single! as Map<String, Object?>)['role'],
        equals('writableSigner'),
      );
      expect(serialized['data'], isA<String>());
    });
  });
}
