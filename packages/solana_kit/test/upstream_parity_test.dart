import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:solana_kit/solana_kit.dart';
import 'package:test/test.dart';

void main() {
  final fixtures = _loadFixtures();

  group('upstream parity', () {
    if (fixtures == null) {
      test(
        'requires generated upstream fixtures',
        () {},
        skip:
            'Run upstream:parity to generate fixtures before executing this harness.',
      );
      return;
    }

    final addresses = fixtures['addresses'] as Map<String, dynamic>;
    final signatures = fixtures['signatures'] as Map<String, dynamic>;
    final transactions = fixtures['transactions'] as Map<String, dynamic>;

    group('addresses', () {
      for (final validationCase
          in (addresses['validationCases'] as List)
              .cast<Map<String, dynamic>>()) {
        final input = validationCase['input'] as String;
        final isValid = validationCase['isValid'] as bool;
        final errorCode = validationCase['errorCode'] as int?;

        test('matches address($input)', () {
          expect(isAddress(input), isValid);

          if (isValid) {
            expect(address(input).value, input);
          } else if (errorCode != null) {
            expect(
              () => address(input),
              throwsA(
                isA<SolanaError>().having(
                  (error) => error.code.value,
                  'code',
                  errorCode,
                ),
              ),
            );
          } else {
            expect(() => address(input), throwsA(anything));
          }
        });
      }

      test('matches address encoder bytes', () {
        final encodingCase = addresses['encodingCase'] as Map<String, dynamic>;
        final input = encodingCase['input'] as String;
        final expectedBytes = _toUint8List(
          encodingCase['encodedBytes'] as List<dynamic>,
        );

        expect(getAddressEncoder().encode(address(input)), expectedBytes);
      });

      test('matches createAddressWithSeed()', () async {
        final createCase =
            addresses['createAddressWithSeedCase'] as Map<String, dynamic>;
        final input = createCase['input'] as Map<String, dynamic>;

        final result = await createAddressWithSeed(
          baseAddress: Address(input['baseAddress'] as String),
          programAddress: Address(input['programAddress'] as String),
          seed: _decodeSeed(input['seed'] as Map<String, dynamic>),
        );

        expect(result.value, createCase['output']);
      });

      test('matches createAddressWithSeed() error semantics', () async {
        final errorCase =
            addresses['createAddressWithSeedErrorCase'] as Map<String, dynamic>;
        final input = errorCase['input'] as Map<String, dynamic>;
        final errorCode = errorCase['errorCode'] as int?;

        await expectLater(
          createAddressWithSeed(
            baseAddress: Address(input['baseAddress'] as String),
            programAddress: Address(input['programAddress'] as String),
            seed: _decodeSeed(input['seed'] as Map<String, dynamic>),
          ),
          throwsA(
            isA<SolanaError>().having((error) => error.code.value, 'code', errorCode),
          ),
        );
      });

      test('matches getProgramDerivedAddress()', () async {
        final pdaCase =
            addresses['programDerivedAddressCase'] as Map<String, dynamic>;
        final input = pdaCase['input'] as Map<String, dynamic>;
        final output = pdaCase['output'] as Map<String, dynamic>;

        final (derivedAddress, bump) = await getProgramDerivedAddress(
          programAddress: Address(input['programAddress'] as String),
          seeds: (input['seeds'] as List<dynamic>)
              .cast<Map<String, dynamic>>()
              .map(_decodeSeed)
              .toList(growable: false),
        );

        expect(derivedAddress.value, output['address']);
        expect(bump, output['bump']);
      });

      test('matches getProgramDerivedAddress() error semantics', () async {
        final errorCase =
            addresses['programDerivedAddressErrorCase'] as Map<String, dynamic>;
        final input = errorCase['input'] as Map<String, dynamic>;
        final errorCode = errorCase['errorCode'] as int?;

        await expectLater(
          getProgramDerivedAddress(
            programAddress: Address(input['programAddress'] as String),
            seeds: (input['seeds'] as List<dynamic>)
                .cast<Map<String, dynamic>>()
                .map(_decodeSeed)
                .toList(growable: false),
          ),
          throwsA(
            isA<SolanaError>().having((error) => error.code.value, 'code', errorCode),
          ),
        );
      });
    });

    group('signatures', () {
      for (final validationCase
          in (signatures['validationCases'] as List)
              .cast<Map<String, dynamic>>()) {
        final input = validationCase['input'] as String;
        final isValid = validationCase['isValid'] as bool;
        final errorCode = validationCase['errorCode'] as int?;

        test('matches signature($input)', () {
          expect(isSignature(input), isValid);

          if (isValid) {
            expect(signature(input).value, input);
          } else if (errorCode != null) {
            expect(
              () => signature(input),
              throwsA(
                isA<SolanaError>().having(
                  (error) => error.code.value,
                  'code',
                  errorCode,
                ),
              ),
            );
          } else {
            expect(() => signature(input), throwsA(anything));
          }
        });
      }
    });

    group('transactions', () {
      for (final compileCase
          in (transactions['compileCases'] as List)
              .cast<Map<String, dynamic>>()) {
        final name = compileCase['name'] as String;
        final input = compileCase['input'] as Map<String, dynamic>;
        final output = compileCase['output'] as Map<String, dynamic>;
        final compiledMessageOutput =
            output['compiledMessage'] as Map<String, dynamic>;
        final compiledHeaderOutput =
            compiledMessageOutput['header'] as Map<String, dynamic>;
        final compiledTransactionOutput =
            output['compiledTransaction'] as Map<String, dynamic>;

        test('matches compile case $name', () {
          final message = _buildTransactionMessage(input);
          final compiledMessage = compileTransactionMessage(message);
          final transaction = compileTransaction(message);

          expect(
            compiledMessage.version,
            _decodeTransactionVersion(
              compiledMessageOutput['version'] as String,
            ),
          );
          expect(
            compiledMessage.header.numReadonlyNonSignerAccounts,
            compiledHeaderOutput['numReadonlyNonSignerAccounts'],
          );
          expect(
            compiledMessage.header.numReadonlySignerAccounts,
            compiledHeaderOutput['numReadonlySignerAccounts'],
          );
          expect(
            compiledMessage.header.numSignerAccounts,
            compiledHeaderOutput['numSignerAccounts'],
          );
          expect(
            compiledMessage.staticAccounts
                .map((address) => address.value)
                .toList(growable: false),
            (compiledMessageOutput['staticAccounts'] as List<dynamic>)
                .cast<String>(),
          );
          expect(
            compiledMessage.lifetimeToken,
            compiledMessageOutput['lifetimeToken'],
          );
          expect(
            compiledMessage.instructions.length,
            (compiledMessageOutput['instructions'] as List).length,
          );

          for (
            var index = 0;
            index < compiledMessage.instructions.length;
            index++
          ) {
            final actual = compiledMessage.instructions[index];
            final expected =
                (compiledMessageOutput['instructions'] as List<dynamic>)[index]
                    as Map<String, dynamic>;
            expect(actual.programAddressIndex, expected['programAddressIndex']);
            expect(
              actual.accountIndices,
              (expected['accountIndices'] as List<dynamic>).cast<int>(),
            );
            expect(
              actual.data,
              _toUint8List(expected['data'] as List<dynamic>),
            );
          }

          final expectedLookups =
              compiledMessageOutput['addressTableLookups'] as List<dynamic>?;
          if (expectedLookups == null) {
            expect(compiledMessage.addressTableLookups, isNull);
          } else {
            final actualLookups = compiledMessage.addressTableLookups;
            expect(actualLookups, isNotNull);
            expect(actualLookups!.length, expectedLookups.length);
            for (var index = 0; index < actualLookups.length; index++) {
              final actual = actualLookups[index];
              final expected = expectedLookups[index] as Map<String, dynamic>;
              expect(
                actual.lookupTableAddress.value,
                expected['lookupTableAddress'],
              );
              expect(
                actual.writableIndexes,
                (expected['writableIndices'] as List<dynamic>).cast<int>(),
              );
              expect(
                actual.readonlyIndexes,
                (expected['readonlyIndices'] as List<dynamic>).cast<int>(),
              );
            }
          }

          expect(
            base64Encode(transaction.messageBytes),
            compiledTransactionOutput['messageBytesBase64'],
          );
          expect(
            getBase64EncodedWireTransaction(transaction),
            compiledTransactionOutput['wireTransactionBase64'],
          );
          expect(
            transaction.signatures.keys
                .map((address) => address.value)
                .toList(growable: false),
            (compiledTransactionOutput['signatureAddresses'] as List<dynamic>)
                .cast<String>(),
          );
        });
      }
    });
  });
}

Map<String, dynamic>? _loadFixtures() {
  final fixturePath = Platform.environment['UPSTREAM_PARITY_FIXTURES_JSON'];
  if (fixturePath == null || fixturePath.isEmpty) {
    return null;
  }

  final fixtureFile = File(fixturePath);
  if (!fixtureFile.existsSync()) {
    return null;
  }

  return jsonDecode(fixtureFile.readAsStringSync()) as Map<String, dynamic>;
}

TransactionMessage _buildTransactionMessage(Map<String, dynamic> input) {
  final message =
      createTransactionMessage(
            version: _decodeTransactionVersion(input['version'] as String),
          )
          .withFeePayer(Address(input['feePayer'] as String))
          .withBlockhashLifetime(
            BlockhashLifetimeConstraint(
              blockhash: input['blockhash'] as String,
              lastValidBlockHeight: BigInt.parse(
                input['lastValidBlockHeight'] as String,
              ),
            ),
          );

  final instruction = input['instruction'] as Map<String, dynamic>?;
  if (instruction == null) {
    return message;
  }

  return message.appendInstruction(
    Instruction(
      programAddress: Address(instruction['programAddress'] as String),
      accounts: (instruction['accounts'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(
            (account) => AccountMeta(
              address: Address(account['address'] as String),
              role: _decodeAccountRole(account['role'] as String),
            ),
          )
          .toList(growable: false),
      data: _toUint8List(instruction['data'] as List<dynamic>),
    ),
  );
}

TransactionVersion _decodeTransactionVersion(String value) {
  return switch (value) {
    'legacy' => TransactionVersion.legacy,
    'v0' => TransactionVersion.v0,
    _ => throw ArgumentError('Unsupported transaction version: $value'),
  };
}

AccountRole _decodeAccountRole(String value) {
  return switch (value) {
    'READONLY' => AccountRole.readonly,
    'WRITABLE' => AccountRole.writable,
    'READONLY_SIGNER' => AccountRole.readonlySigner,
    'WRITABLE_SIGNER' => AccountRole.writableSigner,
    _ => throw ArgumentError('Unsupported account role: $value'),
  };
}

Object _decodeSeed(Map<String, dynamic> seed) {
  return switch (seed['kind']) {
    'string' => seed['value'] as String,
    'bytes' => _toUint8List(seed['value'] as List<dynamic>),
    _ => throw ArgumentError('Unsupported seed kind: ${seed['kind']}'),
  };
}

Uint8List _toUint8List(List<dynamic> values) {
  return Uint8List.fromList(values.cast<int>());
}
