import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';
import 'package:test/test.dart';

void main() {
  // Known test addresses:
  // k7FaK87WHGVXzkaoHb7CdVPgkKDQhZ29VLDeBVbDfYn decodes to [11{32}]
  // 2VDW9dFE1ZXz4zWAbaBDQFynNVdRpQ73HyfSHMzBSL6Z decodes to [22{32}]
  // 3EKkiwNLWqoUbzFkPrmKbtUB4EweE6f4STzevYUmezeL decodes to [33{32}]
  // 3yS1JFVT284y8z1LC9MRoWxZjzFrdoD5axKsZiyMsfC7 decodes to [44{32}]

  group('Compiled transaction message encoder', () {
    test('serializes a versioned transaction according to the spec', () {
      final encoder = getCompiledTransactionMessageEncoder();
      final byteArray = encoder.encode(
        CompiledTransactionMessage(
          version: TransactionVersion.v0,
          header: const MessageHeader(
            numSignerAccounts: 3,
            numReadonlySignerAccounts: 2,
            numReadonlyNonSignerAccounts: 1,
          ),
          staticAccounts: const [
            Address('k7FaK87WHGVXzkaoHb7CdVPgkKDQhZ29VLDeBVbDfYn'),
            Address('2VDW9dFE1ZXz4zWAbaBDQFynNVdRpQ73HyfSHMzBSL6Z'),
          ],
          lifetimeToken: '3EKkiwNLWqoUbzFkPrmKbtUB4EweE6f4STzevYUmezeL',
          instructions: [
            const CompiledInstruction(programAddressIndex: 44),
            CompiledInstruction(
              programAddressIndex: 55,
              accountIndices: const [77, 66],
              data: Uint8List.fromList([7, 8, 9]),
            ),
          ],
          addressTableLookups: const [
            AddressTableLookup(
              lookupTableAddress: Address(
                '3yS1JFVT284y8z1LC9MRoWxZjzFrdoD5axKsZiyMsfC7',
              ),
              writableIndexes: [66, 55],
              readonlyIndexes: [77],
            ),
          ],
        ),
      );
      expect(
        byteArray,
        equals(
          Uint8List.fromList([
            // VERSION HEADER
            128, // 0 + version mask

            // MESSAGE HEADER
            3, // numSignerAccounts
            2, // numReadonlySignerAccounts
            1, // numReadonlyNonSignerAccounts

            // STATIC ADDRESSES
            2, // Number of static accounts
            // k7FaK87WHGVXzkaoHb7CdVPgkKDQhZ29VLDeBVbDfYn
            11, 11, 11, 11, 11, 11, 11, 11,
            11, 11, 11, 11, 11, 11, 11, 11,
            11, 11, 11, 11, 11, 11, 11, 11,
            11, 11, 11, 11, 11, 11, 11, 11,
            // 2VDW9dFE1ZXz4zWAbaBDQFynNVdRpQ73HyfSHMzBSL6Z
            22, 22, 22, 22, 22, 22, 22, 22,
            22, 22, 22, 22, 22, 22, 22, 22,
            22, 22, 22, 22, 22, 22, 22, 22,
            22, 22, 22, 22, 22, 22, 22, 22,

            // TRANSACTION LIFETIME TOKEN (blockhash)
            // 3EKkiwNLWqoUbzFkPrmKbtUB4EweE6f4STzevYUmezeL
            33, 33, 33, 33, 33, 33, 33, 33,
            33, 33, 33, 33, 33, 33, 33, 33,
            33, 33, 33, 33, 33, 33, 33, 33,
            33, 33, 33, 33, 33, 33, 33, 33,

            // INSTRUCTIONS
            2, // Number of instructions

            // First instruction
            44, // Program address index
            0, // Number of address indices
            0, // Length of instruction data

            // Second instruction
            55, // Program address index
            2, // Number of address indices
            77, 66, // Address indices
            3, // Length of instruction data
            7, 8, 9, // Instruction data

            // ADDRESS TABLE LOOKUPS
            1, // Number of address table lookups

            // First address table lookup
            // 3yS1JFVT284y8z1LC9MRoWxZjzFrdoD5axKsZiyMsfC7
            44, 44, 44, 44, 44, 44, 44, 44,
            44, 44, 44, 44, 44, 44, 44, 44,
            44, 44, 44, 44, 44, 44, 44, 44,
            44, 44, 44, 44, 44, 44, 44, 44,
            2, // Number of writable indices
            66, 55, // Writable indices
            1, // Number of readonly indices
            77, // Readonly indices
          ]),
        ),
      );
    });

    test(
      'serializes a versioned transaction with null address table lookups',
      () {
        final encoder = getCompiledTransactionMessageEncoder();
        final byteArray = encoder.encode(
          const CompiledTransactionMessage(
            version: TransactionVersion.v0,
            header: MessageHeader(
              numSignerAccounts: 3,
              numReadonlySignerAccounts: 2,
              numReadonlyNonSignerAccounts: 1,
            ),
            staticAccounts: <Address>[],
            lifetimeToken: 'k7FaK87WHGVXzkaoHb7CdVPgkKDQhZ29VLDeBVbDfYn',
            instructions: <CompiledInstruction>[],
          ),
        );
        expect(
          byteArray,
          equals(
            Uint8List.fromList([
              // VERSION HEADER
              128, // 0 + version mask

              // MESSAGE HEADER
              3, 2, 1,

              // STATIC ADDRESSES
              0, // Number of static accounts

              // TRANSACTION LIFETIME TOKEN
              11, 11, 11, 11, 11, 11, 11, 11,
              11, 11, 11, 11, 11, 11, 11, 11,
              11, 11, 11, 11, 11, 11, 11, 11,
              11, 11, 11, 11, 11, 11, 11, 11,

              // INSTRUCTIONS
              0, // Number of instructions

              // ADDRESS TABLE LOOKUPS (serialized despite not being present)
              0, // Number of address table lookups
            ]),
          ),
        );
      },
    );

    test('omits the version header for legacy transactions', () {
      final encoder = getCompiledTransactionMessageEncoder();
      final byteArray = encoder.encode(
        const CompiledTransactionMessage(
          version: TransactionVersion.legacy,
          header: MessageHeader(
            numSignerAccounts: 3,
            numReadonlySignerAccounts: 2,
            numReadonlyNonSignerAccounts: 1,
          ),
          staticAccounts: <Address>[],
          lifetimeToken: 'k7FaK87WHGVXzkaoHb7CdVPgkKDQhZ29VLDeBVbDfYn',
          instructions: <CompiledInstruction>[],
        ),
      );
      expect(
        byteArray,
        equals(
          Uint8List.fromList([
            // NO VERSION HEADER

            // MESSAGE HEADER
            3, 2, 1,

            // STATIC ADDRESSES
            0,

            // TRANSACTION LIFETIME TOKEN
            11, 11, 11, 11, 11, 11, 11, 11,
            11, 11, 11, 11, 11, 11, 11, 11,
            11, 11, 11, 11, 11, 11, 11, 11,
            11, 11, 11, 11, 11, 11, 11, 11,

            // INSTRUCTIONS
            0,
          ]),
        ),
      );
    });

    test('omits the address table lookups for legacy transactions', () {
      final codec = getCompiledTransactionMessageCodec();
      final byteArray = codec.encode(
        const CompiledTransactionMessage(
          version: TransactionVersion.legacy,
          header: MessageHeader(
            numSignerAccounts: 3,
            numReadonlySignerAccounts: 2,
            numReadonlyNonSignerAccounts: 1,
          ),
          staticAccounts: <Address>[],
          lifetimeToken: 'k7FaK87WHGVXzkaoHb7CdVPgkKDQhZ29VLDeBVbDfYn',
          instructions: <CompiledInstruction>[],
        ),
      );
      expect(
        byteArray,
        equals(
          Uint8List.fromList([
            // MESSAGE HEADER
            3, 2, 1,

            // STATIC ADDRESSES
            0,

            // TRANSACTION LIFETIME TOKEN
            11, 11, 11, 11, 11, 11, 11, 11,
            11, 11, 11, 11, 11, 11, 11, 11,
            11, 11, 11, 11, 11, 11, 11, 11,
            11, 11, 11, 11, 11, 11, 11, 11,

            // INSTRUCTIONS
            0,

            // NO ADDRESS TABLE LOOKUPS
          ]),
        ),
      );
    });
  });

  group('Compiled transaction message decoder', () {
    test('deserializes a version 0 transaction according to the spec', () {
      final decoder = getCompiledTransactionMessageDecoder();
      final byteArray = Uint8List.fromList([
        // VERSION HEADER
        128, // 0 + version mask

        // MESSAGE HEADER
        3, 2, 1,

        // STATIC ADDRESSES
        2, // Number of static accounts
        // k7FaK87WHGVXzkaoHb7CdVPgkKDQhZ29VLDeBVbDfYn
        11, 11, 11, 11, 11, 11, 11, 11,
        11, 11, 11, 11, 11, 11, 11, 11,
        11, 11, 11, 11, 11, 11, 11, 11,
        11, 11, 11, 11, 11, 11, 11, 11,
        // 2VDW9dFE1ZXz4zWAbaBDQFynNVdRpQ73HyfSHMzBSL6Z
        22, 22, 22, 22, 22, 22, 22, 22,
        22, 22, 22, 22, 22, 22, 22, 22,
        22, 22, 22, 22, 22, 22, 22, 22,
        22, 22, 22, 22, 22, 22, 22, 22,

        // TRANSACTION LIFETIME TOKEN
        33, 33, 33, 33, 33, 33, 33, 33,
        33, 33, 33, 33, 33, 33, 33, 33,
        33, 33, 33, 33, 33, 33, 33, 33,
        33, 33, 33, 33, 33, 33, 33, 33,

        // INSTRUCTIONS
        2, // Number of instructions

        // First instruction
        44, // Program address index
        0, // Number of address indices
        0, // Length of instruction data

        // Second instruction
        55, // Program address index
        2, // Number of address indices
        77, 66, // Address indices
        3, // Length of instruction data
        7, 8, 9, // Instruction data

        // ADDRESS TABLE LOOKUPS
        1, // Number of address table lookups

        // First address table lookup
        // 3yS1JFVT284y8z1LC9MRoWxZjzFrdoD5axKsZiyMsfC7
        44, 44, 44, 44, 44, 44, 44, 44,
        44, 44, 44, 44, 44, 44, 44, 44,
        44, 44, 44, 44, 44, 44, 44, 44,
        44, 44, 44, 44, 44, 44, 44, 44,
        2, // Number of writable indices
        66, 55, // Writable indices
        1, // Number of readonly indices
        77, // Readonly indices
      ]);

      final (message, offset) = decoder.read(byteArray, 0);

      expect(message.version, equals(TransactionVersion.v0));
      expect(message.header.numSignerAccounts, equals(3));
      expect(message.header.numReadonlySignerAccounts, equals(2));
      expect(message.header.numReadonlyNonSignerAccounts, equals(1));
      expect(message.staticAccounts.length, equals(2));
      expect(
        message.staticAccounts[0],
        equals(const Address('k7FaK87WHGVXzkaoHb7CdVPgkKDQhZ29VLDeBVbDfYn')),
      );
      expect(
        message.staticAccounts[1],
        equals(const Address('2VDW9dFE1ZXz4zWAbaBDQFynNVdRpQ73HyfSHMzBSL6Z')),
      );
      expect(
        message.lifetimeToken,
        equals('3EKkiwNLWqoUbzFkPrmKbtUB4EweE6f4STzevYUmezeL'),
      );
      expect(message.instructions.length, equals(2));
      expect(message.instructions[0].programAddressIndex, equals(44));
      expect(message.instructions[0].accountIndices, isNull);
      expect(message.instructions[0].data, isNull);
      expect(message.instructions[1].programAddressIndex, equals(55));
      expect(message.instructions[1].accountIndices, equals([77, 66]));
      expect(
        message.instructions[1].data,
        equals(Uint8List.fromList([7, 8, 9])),
      );
      expect(message.addressTableLookups, isNotNull);
      expect(message.addressTableLookups!.length, equals(1));
      expect(
        message.addressTableLookups![0].lookupTableAddress,
        equals(const Address('3yS1JFVT284y8z1LC9MRoWxZjzFrdoD5axKsZiyMsfC7')),
      );
      expect(message.addressTableLookups![0].writableIndexes, equals([66, 55]));
      expect(message.addressTableLookups![0].readonlyIndexes, equals([77]));
      // Expect the entire byte array to have been consumed.
      expect(offset, equals(byteArray.length));
    });

    test(
      'sets addressTableLookups to null when lookups are zero-length for v0',
      () {
        final decoder = getCompiledTransactionMessageDecoder();
        final result = decoder.decode(
          Uint8List.fromList([
            // VERSION HEADER
            128, // 0 + version mask

            // MESSAGE HEADER
            3, 2, 1,

            // STATIC ADDRESSES
            0,

            // TRANSACTION LIFETIME TOKEN
            33, 33, 33, 33, 33, 33, 33, 33,
            33, 33, 33, 33, 33, 33, 33, 33,
            33, 33, 33, 33, 33, 33, 33, 33,
            33, 33, 33, 33, 33, 33, 33, 33,

            // INSTRUCTIONS
            0,

            // ADDRESS TABLE LOOKUPS
            0, // Zero lookups
          ]),
        );
        expect(result.addressTableLookups, isNull);
      },
    );

    test('deserializes a legacy transaction according to the spec', () {
      final decoder = getCompiledTransactionMessageDecoder();
      final byteArray = Uint8List.fromList([
        // MESSAGE HEADER (no version header)
        3, 2, 1,

        // STATIC ADDRESSES
        2, // Number of static accounts
        // k7FaK87WHGVXzkaoHb7CdVPgkKDQhZ29VLDeBVbDfYn
        11, 11, 11, 11, 11, 11, 11, 11,
        11, 11, 11, 11, 11, 11, 11, 11,
        11, 11, 11, 11, 11, 11, 11, 11,
        11, 11, 11, 11, 11, 11, 11, 11,
        // 2VDW9dFE1ZXz4zWAbaBDQFynNVdRpQ73HyfSHMzBSL6Z
        22, 22, 22, 22, 22, 22, 22, 22,
        22, 22, 22, 22, 22, 22, 22, 22,
        22, 22, 22, 22, 22, 22, 22, 22,
        22, 22, 22, 22, 22, 22, 22, 22,

        // TRANSACTION LIFETIME TOKEN
        33, 33, 33, 33, 33, 33, 33, 33,
        33, 33, 33, 33, 33, 33, 33, 33,
        33, 33, 33, 33, 33, 33, 33, 33,
        33, 33, 33, 33, 33, 33, 33, 33,

        // INSTRUCTIONS
        2,

        // First instruction
        44, 0, 0,

        // Second instruction
        55, 2, 77, 66, 3, 7, 8, 9,
      ]);

      final (message, offset) = decoder.read(byteArray, 0);

      expect(message.version, equals(TransactionVersion.legacy));
      expect(message.header.numSignerAccounts, equals(3));
      expect(message.staticAccounts.length, equals(2));
      expect(
        message.staticAccounts[0],
        equals(const Address('k7FaK87WHGVXzkaoHb7CdVPgkKDQhZ29VLDeBVbDfYn')),
      );
      expect(
        message.staticAccounts[1],
        equals(const Address('2VDW9dFE1ZXz4zWAbaBDQFynNVdRpQ73HyfSHMzBSL6Z')),
      );
      expect(
        message.lifetimeToken,
        equals('3EKkiwNLWqoUbzFkPrmKbtUB4EweE6f4STzevYUmezeL'),
      );
      expect(message.instructions.length, equals(2));
      expect(message.instructions[0].programAddressIndex, equals(44));
      expect(message.instructions[1].programAddressIndex, equals(55));
      expect(message.instructions[1].accountIndices, equals([77, 66]));
      expect(
        message.instructions[1].data,
        equals(Uint8List.fromList([7, 8, 9])),
      );
      // Legacy transactions should not have address table lookups.
      expect(message.addressTableLookups, isNull);
      // Expect the entire byte array to have been consumed.
      expect(offset, equals(byteArray.length));
    });
  });

  group('Compiled transaction message codec', () {
    test('round-trips a versioned transaction with all fields', () {
      final codec = getCompiledTransactionMessageCodec();
      final message = CompiledTransactionMessage(
        version: TransactionVersion.v0,
        header: const MessageHeader(
          numSignerAccounts: 2,
          numReadonlySignerAccounts: 1,
          numReadonlyNonSignerAccounts: 0,
        ),
        staticAccounts: const [
          Address('k7FaK87WHGVXzkaoHb7CdVPgkKDQhZ29VLDeBVbDfYn'),
        ],
        lifetimeToken: '3EKkiwNLWqoUbzFkPrmKbtUB4EweE6f4STzevYUmezeL',
        instructions: [
          CompiledInstruction(
            programAddressIndex: 0,
            accountIndices: const [0],
            data: Uint8List.fromList([1, 2, 3]),
          ),
        ],
        addressTableLookups: const [
          AddressTableLookup(
            lookupTableAddress: Address(
              '3yS1JFVT284y8z1LC9MRoWxZjzFrdoD5axKsZiyMsfC7',
            ),
            writableIndexes: [0],
            readonlyIndexes: [1],
          ),
        ],
      );
      final encoded = codec.encode(message);
      final decoded = codec.decode(encoded);

      expect(decoded.version, equals(message.version));
      expect(decoded.header, equals(message.header));
      expect(decoded.staticAccounts.length, equals(1));
      expect(decoded.staticAccounts[0], equals(message.staticAccounts[0]));
      expect(decoded.lifetimeToken, equals(message.lifetimeToken));
      expect(decoded.instructions.length, equals(1));
      expect(decoded.instructions[0], equals(message.instructions[0]));
      expect(decoded.addressTableLookups, isNotNull);
      expect(decoded.addressTableLookups!.length, equals(1));
      expect(
        decoded.addressTableLookups![0],
        equals(message.addressTableLookups![0]),
      );
    });
  });
}
