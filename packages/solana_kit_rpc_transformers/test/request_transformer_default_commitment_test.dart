import 'package:solana_kit_rpc_transformers/src/request_transformer_default_commitment_internal.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:test/test.dart';

const _mockCommitmentPropertyName = 'commitmentProperty';

void main() {
  group('applyDefaultCommitment', () {
    for (final expectedPosition in [0, 1, 2]) {
      group('in relation to a method whose commitment config is argument '
          '#$expectedPosition', () {
        test('adds the default commitment when absent from the call', () {
          final result = applyDefaultCommitment(
            commitmentPropertyName: _mockCommitmentPropertyName,
            optionsObjectPositionInParams: expectedPosition,
            overrideCommitment: Commitment.processed,
            params: [],
          );
          expect(result.length, expectedPosition + 1);
          expect(result[expectedPosition], {
            _mockCommitmentPropertyName: 'processed',
          });
        });

        for (final defaultCommitment in Commitment.values) {
          group('when the default commitment is set to '
              '`${defaultCommitment.name}`', () {
            for (final existingCommitment in ['confirmed', 'processed']) {
              test('does not overwrite existing commitment '
                  '`$existingCommitment`', () {
                final params = [
                  ...List<Object?>.filled(expectedPosition, null),
                  {_mockCommitmentPropertyName: existingCommitment},
                ];
                final result = applyDefaultCommitment(
                  commitmentPropertyName: _mockCommitmentPropertyName,
                  optionsObjectPositionInParams: expectedPosition,
                  overrideCommitment: defaultCommitment,
                  params: params,
                );
                // Should return original params unchanged.
                expect(identical(result, params), isTrue);
              });
            }

            for (final existingCommitment in ['finalized', null]) {
              group('and the params already specify a commitment of '
                  '`$existingCommitment`', () {
                test('removes the commitment property when there are other '
                    'properties in the config object', () {
                  final params = [
                    ...List<Object?>.filled(expectedPosition, null),
                    <String, Object?>{
                      _mockCommitmentPropertyName: existingCommitment,
                      'other': 'property',
                    },
                  ];
                  final result = applyDefaultCommitment(
                    commitmentPropertyName: _mockCommitmentPropertyName,
                    optionsObjectPositionInParams: expectedPosition,
                    overrideCommitment: defaultCommitment,
                    params: params,
                  );
                  expect(result[expectedPosition], {'other': 'property'});
                });

                test('sets the config object to null when there are no '
                    'other properties and config is not the last param', () {
                  final params = [
                    ...List<Object?>.filled(expectedPosition, null),
                    <String, Object?>{
                      _mockCommitmentPropertyName: existingCommitment,
                    },
                    'someParam',
                  ];
                  final result = applyDefaultCommitment(
                    commitmentPropertyName: _mockCommitmentPropertyName,
                    optionsObjectPositionInParams: expectedPosition,
                    overrideCommitment: defaultCommitment,
                    params: params,
                  );
                  expect(result[expectedPosition], isNull);
                  expect(result.last, 'someParam');
                });

                test('truncates the params when there are no other '
                    'properties and config is the last param', () {
                  final params = [
                    ...List<Object?>.filled(expectedPosition, null),
                    <String, Object?>{
                      _mockCommitmentPropertyName: existingCommitment,
                    },
                  ];
                  final result = applyDefaultCommitment(
                    commitmentPropertyName: _mockCommitmentPropertyName,
                    optionsObjectPositionInParams: expectedPosition,
                    overrideCommitment: defaultCommitment,
                    params: params,
                  );
                  expect(result.length, expectedPosition);
                });
              });
            }
          });
        }

        for (final paramInConfigPosition in <Object?>[
          null,
          1,
          '1',
          BigInt.one,
          [1, 2, 3],
        ]) {
          if (paramInConfigPosition == null) continue;
          test('does not overwrite existing param when it is a non-object '
              'like `$paramInConfigPosition`', () {
            final params = [
              ...List<Object?>.filled(expectedPosition, null),
              paramInConfigPosition,
            ];
            final result = applyDefaultCommitment(
              commitmentPropertyName: _mockCommitmentPropertyName,
              optionsObjectPositionInParams: expectedPosition,
              overrideCommitment: Commitment.processed,
              params: params,
            );
            expect(identical(result, params), isTrue);
          });
        }
      });
    }
  });
}
