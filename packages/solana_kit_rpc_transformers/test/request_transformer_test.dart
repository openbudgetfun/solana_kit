import 'package:solana_kit_rpc_spec_types/solana_kit_rpc_spec_types.dart';
import 'package:solana_kit_rpc_transformers/solana_kit_rpc_transformers.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:test/test.dart';

const _maxSafeInteger = 9007199254740991; // 2^53 - 1

void main() {
  group('getDefaultRequestTransformerForSolanaRpc', () {
    group('given no config', () {
      late RpcRequestTransformer requestTransformer;

      setUp(() {
        requestTransformer = getDefaultRequestTransformerForSolanaRpc();
      });

      RpcRequest<Object?> createRequest(Object? params) =>
          RpcRequest(methodName: 'getFoo', params: params);

      group('given an array as input', () {
        test('casts the bigints in the array to int, recursively', () {
          final input = [
            BigInt.from(10),
            10,
            '10',
            [
              '10',
              [10, BigInt.from(10)],
              BigInt.from(10),
            ],
          ];
          final request = createRequest(input);
          expect(requestTransformer(request).params, [
            10,
            10,
            '10',
            [
              '10',
              [10, 10],
              10,
            ],
          ]);
        });
      });

      group('given an object as input', () {
        test('casts the bigints in the object to int, recursively', () {
          final input = {
            'a': BigInt.from(10),
            'b': 10,
            'c': {'c1': '10', 'c2': BigInt.from(10)},
          };
          final request = createRequest(input);
          expect(requestTransformer(request).params, {
            'a': 10,
            'b': 10,
            'c': {'c1': '10', 'c2': 10},
          });
        });
      });
    });

    group('with respect to the default commitment', () {
      const methodsSubjectToCommitmentDefaulting = [
        'accountNotifications',
        'blockNotifications',
        'getAccountInfo',
        'getBalance',
        'getBlock',
        'getBlockHeight',
        'getBlockProduction',
        'getBlocks',
        'getBlocksWithLimit',
        'getEpochInfo',
        'getFeeForMessage',
        'getInflationGovernor',
        'getInflationReward',
        'getLargestAccounts',
        'getLatestBlockhash',
        'getLeaderSchedule',
        'getMinimumBalanceForRentExemption',
        'getMultipleAccounts',
        'getProgramAccounts',
        'getSignaturesForAddress',
        'getSlot',
        'getSlotLeader',
        'getStakeMinimumDelegation',
        'getSupply',
        'getTokenAccountBalance',
        'getTokenAccountsByDelegate',
        'getTokenAccountsByOwner',
        'getTokenLargestAccounts',
        'getTokenSupply',
        'getTransaction',
        'getTransactionCount',
        'getVoteAccounts',
        'isBlockhashValid',
        'logsNotifications',
        'programNotifications',
        'requestAirdrop',
        'signatureNotifications',
        'simulateTransaction',
      ];

      for (final defaultCommitment in ['processed', 'confirmed']) {
        group('with the default commitment set to `$defaultCommitment`', () {
          late RpcRequestTransformer requestTransformer;

          setUp(() {
            requestTransformer = getDefaultRequestTransformerForSolanaRpc(
              RequestTransformerConfig(
                defaultCommitment: Commitment.values.byName(defaultCommitment),
              ),
            );
          });

          for (final methodName in methodsSubjectToCommitmentDefaulting) {
            test('adds a default commitment on calls for `$methodName`', () {
              final result = requestTransformer(
                RpcRequest(methodName: methodName, params: <Object?>[]),
              );
              final params = result.params! as List;
              final hasCommitment = params.any(
                (p) =>
                    p is Map<String, Object?> &&
                    p['commitment'] == defaultCommitment,
              );
              if (methodName == 'sendTransaction') {
                final hasPreflight = params.any(
                  (p) =>
                      p is Map<String, Object?> &&
                      p['preflightCommitment'] == defaultCommitment,
                );
                expect(hasPreflight, isTrue);
              } else {
                expect(hasCommitment, isTrue);
              }
            });
          }

          test('adds a default preflight commitment on calls to '
              '`sendTransaction`', () {
            final result = requestTransformer(
              const RpcRequest(
                methodName: 'sendTransaction',
                params: <Object?>[],
              ),
            );
            final params = result.params! as List;
            final hasPreflight = params.any(
              (p) =>
                  p is Map<String, Object?> &&
                  p['preflightCommitment'] == defaultCommitment,
            );
            expect(hasPreflight, isTrue);
          });
        });
      }

      group('with the default commitment set to `finalized`', () {
        late RpcRequestTransformer requestTransformer;

        setUp(() {
          requestTransformer = getDefaultRequestTransformerForSolanaRpc(
            const RequestTransformerConfig(
              defaultCommitment: Commitment.finalized,
            ),
          );
        });

        for (final methodName in methodsSubjectToCommitmentDefaulting) {
          test('adds no commitment on calls for `$methodName`', () {
            final result = requestTransformer(
              RpcRequest(methodName: methodName, params: <Object?>[]),
            );
            final params = result.params;
            if (params is List) {
              for (final p in params) {
                if (p is Map<String, Object?>) {
                  expect(p.containsKey('commitment'), isFalse);
                }
              }
            }
          });
        }

        test('adds no preflight commitment on calls to `sendTransaction`', () {
          final result = requestTransformer(
            const RpcRequest(
              methodName: 'sendTransaction',
              params: <Object?>[],
            ),
          );
          final params = result.params;
          if (params is List) {
            for (final p in params) {
              if (p is Map<String, Object?>) {
                expect(p.containsKey('preflightCommitment'), isFalse);
              }
            }
          }
        });
      });

      group('with no default commitment set', () {
        late RpcRequestTransformer requestTransformer;

        setUp(() {
          requestTransformer = getDefaultRequestTransformerForSolanaRpc();
        });

        for (final methodName in methodsSubjectToCommitmentDefaulting) {
          test('sets no commitment on calls to `$methodName`', () {
            final result = requestTransformer(
              RpcRequest(methodName: methodName, params: <Object?>[]),
            );
            final params = result.params;
            if (params is List) {
              for (final p in params) {
                if (p is Map<String, Object?>) {
                  expect(p.containsKey('commitment'), isFalse);
                }
              }
            }
          });
        }
      });

      for (final existingCommitment in ['finalized', null]) {
        group('when the params already specify a commitment of '
            '`$existingCommitment`', () {
          for (final methodName in methodsSubjectToCommitmentDefaulting) {
            final optionsObjectPosition =
                OPTIONS_OBJECT_POSITION_BY_METHOD[methodName]!;

            test('removes the commitment property on calls to `$methodName` '
                'when there are other properties in the config object', () {
              final params = <Object?>[
                ...List<Object?>.filled(optionsObjectPosition, null),
                <String, Object?>{
                  'commitment': existingCommitment,
                  'other': 'property',
                },
              ];
              final requestTransformer =
                  getDefaultRequestTransformerForSolanaRpc();
              final result = requestTransformer(
                RpcRequest(methodName: methodName, params: params),
              );
              final resultParams = result.params! as List;
              expect(resultParams[optionsObjectPosition], {
                'other': 'property',
              });
            });

            test(
              'deletes the commitment on calls to `$methodName` when '
              'there are no other properties and config is not last param',
              () {
                final params = <Object?>[
                  ...List<Object?>.filled(optionsObjectPosition, null),
                  <String, Object?>{'commitment': existingCommitment},
                  'someParam',
                ];
                final requestTransformer =
                    getDefaultRequestTransformerForSolanaRpc();
                final result = requestTransformer(
                  RpcRequest(methodName: methodName, params: params),
                );
                final resultParams = result.params! as List;
                expect(resultParams[optionsObjectPosition], isNull);
                expect(resultParams.last, 'someParam');
              },
            );

            test(
              'truncates the params on calls to `$methodName` when '
              'there are no other properties and config is the last param',
              () {
                final params = <Object?>[
                  ...List<Object?>.filled(optionsObjectPosition, null),
                  <String, Object?>{'commitment': existingCommitment},
                ];
                final requestTransformer =
                    getDefaultRequestTransformerForSolanaRpc();
                final result = requestTransformer(
                  RpcRequest(methodName: methodName, params: params),
                );
                final resultParams = result.params! as List;
                expect(resultParams.length, optionsObjectPosition);
              },
            );
          }

          test('removes the preflight commitment property on calls to '
              '`sendTransaction` when there are other properties in the '
              'config object', () {
            final optionsObjectPosition =
                OPTIONS_OBJECT_POSITION_BY_METHOD['sendTransaction']!;
            final params = <Object?>[
              ...List<Object?>.filled(optionsObjectPosition, null),
              <String, Object?>{
                'other': 'property',
                'preflightCommitment': existingCommitment,
              },
            ];
            final requestTransformer =
                getDefaultRequestTransformerForSolanaRpc();
            final result = requestTransformer(
              RpcRequest(methodName: 'sendTransaction', params: params),
            );
            final resultParams = result.params! as List;
            expect(resultParams[optionsObjectPosition], {'other': 'property'});
          });

          test('deletes the preflight commitment on calls to '
              '`sendTransaction` when there are no other properties and '
              'config is not the last param', () {
            final optionsObjectPosition =
                OPTIONS_OBJECT_POSITION_BY_METHOD['sendTransaction']!;
            final params = <Object?>[
              ...List<Object?>.filled(optionsObjectPosition, null),
              <String, Object?>{'preflightCommitment': existingCommitment},
              'someParam',
            ];
            final requestTransformer =
                getDefaultRequestTransformerForSolanaRpc();
            final result = requestTransformer(
              RpcRequest(methodName: 'sendTransaction', params: params),
            );
            final resultParams = result.params! as List;
            expect(resultParams[optionsObjectPosition], isNull);
            expect(resultParams.last, 'someParam');
          });

          test('truncates params on calls to `sendTransaction` when there '
              'are no other properties and config is the last param', () {
            final optionsObjectPosition =
                OPTIONS_OBJECT_POSITION_BY_METHOD['sendTransaction']!;
            final params = <Object?>[
              ...List<Object?>.filled(optionsObjectPosition, null),
              <String, Object?>{'preflightCommitment': existingCommitment},
            ];
            final requestTransformer =
                getDefaultRequestTransformerForSolanaRpc();
            final result = requestTransformer(
              RpcRequest(methodName: 'sendTransaction', params: params),
            );
            final resultParams = result.params! as List;
            expect(resultParams.length, optionsObjectPosition);
          });
        });
      }
    });

    group('given an integer overflow handler', () {
      late List<(RpcRequest<Object?>, KeyPath, BigInt)> overflowCalls;
      late RpcRequestTransformer requestTransformer;

      RpcRequest<Object?> createRequest(Object? params) =>
          RpcRequest(methodName: 'getFoo', params: params);

      setUp(() {
        overflowCalls = [];
        requestTransformer = getDefaultRequestTransformerForSolanaRpc(
          RequestTransformerConfig(
            onIntegerOverflow: (request, keyPath, value) {
              overflowCalls.add((request, keyPath, value));
            },
          ),
        );
      });

      test('calls onIntegerOverflow when passed a value above '
          'MAX_SAFE_INTEGER', () {
        final value = BigInt.from(_maxSafeInteger) + BigInt.one;
        final request = createRequest(value);
        requestTransformer(request);
        expect(overflowCalls, hasLength(1));
        expect(overflowCalls[0].$1.methodName, request.methodName);
        expect(overflowCalls[0].$2, isEmpty);
        expect(overflowCalls[0].$3, value);
      });

      test('calls onIntegerOverflow when passed a value below negative '
          'MAX_SAFE_INTEGER', () {
        final value = BigInt.from(-_maxSafeInteger) - BigInt.one;
        final request = createRequest(value);
        requestTransformer(request);
        expect(overflowCalls, hasLength(1));
        expect(overflowCalls[0].$1.methodName, request.methodName);
        expect(overflowCalls[0].$2, isEmpty);
        expect(overflowCalls[0].$3, value);
      });

      test('calls onIntegerOverflow when passed a nested array having a '
          'value above MAX_SAFE_INTEGER', () {
        final value = BigInt.from(_maxSafeInteger) + BigInt.one;
        final request = createRequest([
          1,
          2,
          [3, value],
        ]);
        requestTransformer(request);
        expect(overflowCalls, hasLength(1));
        expect(overflowCalls[0].$2, [2, 1]);
        expect(overflowCalls[0].$3, value);
      });

      test('calls onIntegerOverflow when passed a nested object having a '
          'value above MAX_SAFE_INTEGER', () {
        final value = BigInt.from(_maxSafeInteger) + BigInt.one;
        final request = createRequest({
          'a': 1,
          'b': {'b1': 2, 'b2': value},
        });
        requestTransformer(request);
        expect(overflowCalls, hasLength(1));
        expect(overflowCalls[0].$2, ['b', 'b2']);
        expect(overflowCalls[0].$3, value);
      });

      test('does not call onIntegerOverflow when passed MAX_SAFE_INTEGER', () {
        final request = createRequest(BigInt.from(_maxSafeInteger));
        requestTransformer(request);
        expect(overflowCalls, isEmpty);
      });
    });
  });
}
