import 'dart:convert';
import 'dart:typed_data';

import 'package:solana_kit_address_constants/solana_kit_address_constants.dart'
    as constants;
import 'package:solana_kit_addresses/solana_kit_addresses.dart'
    hide tokenMetadataProgramAddress;
import 'package:solana_kit_dapp_publisher_cli/src/errors.dart';
import 'package:solana_kit_dapp_publisher_cli/src/publication_signer.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_keys/solana_kit_keys.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';
import 'package:solana_kit_transactions/solana_kit_transactions.dart';
import 'package:test/test.dart';

import 'fixtures/publication_transactions.dart';

final KeyPair publisherKeypair = generateKeyPair();
final KeyPair mintKeypair = generateKeyPair();
final KeyPair authorityKeypair = generateKeyPair();
final Address publisher = getAddressFromPublicKey(publisherKeypair.publicKey);
final Address mint = getAddressFromPublicKey(mintKeypair.publicKey);
final Address authority = getAddressFromPublicKey(authorityKeypair.publicKey);
final Address collection = getAddressFromPublicKey(generateKeyPair().publicKey);
const blockhash = 'GPEsEFh2hEbJdH8CQe79rzuwL9V6trBY4qLXZ9iwbFqN';
const name = 'Release';
const uri = 'https://meta.example.com/1.json';

ReleaseMintValidation releaseValidation() => ReleaseMintValidation(
  expectedBlockhash: blockhash,
  expectedFeePayerAddress: publisher.value,
  expectedSignerAddress: publisher.value,
  expectedMintAddress: mint.value,
  expectedAppMintAddress: collection.value,
  expectedName: name,
  expectedMetadataUri: uri,
);

VerifyCollectionValidation verifyValidation({Address? collectionAuthority}) =>
    VerifyCollectionValidation(
      expectedBlockhash: blockhash,
      expectedFeePayerAddress: publisher.value,
      expectedSignerAddress: publisher.value,
      expectedNftMintAddress: mint.value,
      expectedCollectionMintAddress: collection.value,
      expectedCollectionAuthority: (collectionAuthority ?? publisher).value,
    );

CompiledTransactionMessage copyMessage(
  CompiledTransactionMessage message, {
  List<Address>? accounts,
  List<CompiledInstruction>? instructions,
  MessageHeader? header,
  String? lifetime,
  List<AddressTableLookup>? lookups,
}) => CompiledTransactionMessage(
  version: message.version,
  header: header ?? message.header,
  staticAccounts: accounts ?? message.staticAccounts,
  instructions: instructions ?? message.instructions,
  lifetimeToken: lifetime ?? blockhash,
  addressTableLookups: lookups ?? message.addressTableLookups,
  configMask: message.configMask,
  configValues: message.configValues,
  instructionHeaders: message.instructionHeaders,
  instructionPayloads: message.instructionPayloads,
  numInstructions: message.numInstructions,
  numStaticAccounts: message.numStaticAccounts,
);

Transaction transactionFromMessage(
  CompiledTransactionMessage message, {
  bool signMint = true,
}) {
  final bytes = getCompiledTransactionMessageEncoder().encode(message);

  return Transaction(
    messageBytes: bytes,
    signatures: {
      for (final account in message.staticAccounts.take(
        message.header.numSignerAccounts,
      ))
        account: account == mint && signMint
            ? SignatureBytes(signBytes(mintKeypair.privateKey, bytes).value)
            : null,
    },
  );
}

CompiledTransactionMessage messageFor(
  List<Instruction> instructions, {
  TransactionVersion version = TransactionVersion.legacy,
}) => copyMessage(
  compileTransactionMessage(
    TransactionMessage(
      version: version,
      feePayer: publisher,
      instructions: instructions,
    ),
  ),
);

Instruction withData(Instruction instruction, Uint8List data) => Instruction(
  programAddress: instruction.programAddress,
  accounts: instruction.accounts,
  data: data,
);

Instruction budgetLimit(int units) => Instruction(
  programAddress: computeBudgetProgramAddress,
  data:
      (ByteData(5)
            ..setUint8(0, 2)
            ..setUint32(1, units, Endian.little))
          .buffer
          .asUint8List(),
);

Instruction budgetPrice(BigInt price) {
  final data = Uint8List(9)..[0] = 3;

  for (var i = 1; i < data.length; i++) {
    data[i] = ((price >> ((i - 1) * 8)) & BigInt.from(255)).toInt();
  }

  return Instruction(programAddress: computeBudgetProgramAddress, data: data);
}

class RecordingSigner implements PublicationSigner {
  int transactionCalls = 0;

  @override
  String get address => publisher.value;

  @override
  Future<Transaction> signTransaction(Transaction transaction) async {
    transactionCalls++;
    return partiallySignTransaction([publisherKeypair], transaction);
  }

  @override
  Future<Uint8List> signMessage(Uint8List message) async =>
      signBytes(publisherKeypair.privateKey, message).value;
}

void main() {
  late List<Instruction> release;
  late List<Instruction> verify;
  late RecordingSigner signer;

  setUp(() async {
    release = await releaseInstructions(
      publisher: publisher,
      payer: publisher,
      mint: mint,
      collection: collection,
      name: name,
      uri: uri,
    );
    verify = await verifyInstructions(
      authority: publisher,
      mint: mint,
      collection: collection,
    );
    signer = RecordingSigner();
  });

  Future<void> reject(
    CompiledTransactionMessage message,
    PublicationTransactionValidation validation, {
    bool signMint = true,
  }) async {
    final transaction = transactionFromMessage(message, signMint: signMint);
    await expectLater(
      signPreparedTransaction(
        signer,
        getBase64EncodedWireTransaction(transaction),
        validation,
      ),
      throwsA(isA<PublisherCliException>()),
    );
    expect(signer.transactionCalls, 0);
  }

  for (final version in [TransactionVersion.legacy, TransactionVersion.v0]) {
    for (final isRelease in [true, false]) {
      test(
        'signs a complete ${isRelease ? 'release' : 'verification'} $version transaction',
        () async {
          final transaction = transactionFromMessage(
            messageFor(isRelease ? release : verify, version: version),
          );
          final wire = await signPreparedTransaction(
            signer,
            getBase64EncodedWireTransaction(transaction),
            isRelease ? releaseValidation() : verifyValidation(),
          );
          final signed = getTransactionDecoder().decode(base64Decode(wire));
          expect(
            verifySignature(
              publisherKeypair.publicKey,
              signed.signatures[publisher]!,
              signed.messageBytes,
            ),
            isTrue,
          );
          expect(signed.messageBytes, transaction.messageBytes);
          expect(signed.signatures[mint], transaction.signatures[mint]);
          expect(signer.transactionCalls, 1);
        },
      );
    }
  }

  test('supports a separate collection authority', () async {
    final instructions = await verifyInstructions(
      authority: authority,
      mint: mint,
      collection: collection,
    );
    final transaction = transactionFromMessage(messageFor(instructions));
    await validatePublicationTransaction(
      signer,
      transaction,
      verifyValidation(collectionAuthority: authority),
    );
  });

  test(
    'accepts safe compute budgets including the priority fee boundary',
    () async {
      for (final prefix in [
        <Instruction>[],
        [budgetLimit(1000000)],
        [budgetPrice(BigInt.one)],
        [budgetLimit(1000000), budgetPrice(BigInt.from(100000))],
      ]) {
        await validatePublicationTransaction(
          signer,
          transactionFromMessage(messageFor([...prefix, ...release])),
          releaseValidation(),
        );
      }
    },
  );

  test(
    'allows different ordering within a static account privilege group',
    () async {
      final message = messageFor(release);
      final accounts = [...message.staticAccounts];
      final first = message.header.numSignerAccounts;
      final second = first + 1;
      final saved = accounts[first];
      accounts[first] = accounts[second];
      accounts[second] = saved;
      int remap(int i) => i == first
          ? second
          : i == second
          ? first
          : i;
      final reordered = copyMessage(
        message,
        accounts: accounts,
        instructions: [
          for (final instruction in message.instructions)
            CompiledInstruction(
              programAddressIndex: remap(instruction.programAddressIndex),
              accountIndices: instruction.accountIndices!.map(remap).toList(),
              data: instruction.data,
            ),
        ],
      );
      await validatePublicationTransaction(
        signer,
        transactionFromMessage(reordered),
        releaseValidation(),
      );
    },
  );

  for (final isRelease in [true, false]) {
    group(isRelease ? 'release signing boundary' : 'verification signing boundary', () {
      List<Instruction> instructions() => isRelease ? release : verify;
      PublicationTransactionValidation validation() =>
          isRelease ? releaseValidation() : verifyValidation();

      for (final opcode in [15, 17, 25, 29, 41, 44, 49, 50]) {
        test(
          'rejects appended metadata opcode $opcode before signing',
          () async {
            final malicious = Instruction(
              programAddress: tokenMetadataProgramAddress,
              accounts: instructions().first.accounts,
              data: Uint8List.fromList([opcode, 0]),
            );
            await reject(
              messageFor([...instructions(), malicious]),
              validation(),
            );
          },
        );
        test(
          'rejects replacement metadata opcode $opcode before signing',
          () async {
            final changed = [...instructions()];
            changed[0] = withData(changed[0], Uint8List.fromList([opcode, 0]));
            await reject(messageFor(changed), validation());
          },
        );
      }

      test('rejects an appended System transfer', () async {
        final transfer = Instruction(
          programAddress: constants.systemProgramAddress,
          accounts: [
            AccountMeta(address: publisher, role: AccountRole.writableSigner),
            AccountMeta(address: authority, role: AccountRole.writable),
          ],
          data:
              (ByteData(12)
                    ..setUint32(0, 2, Endian.little)
                    ..setUint64(4, 1, Endian.little))
                  .buffer
                  .asUint8List(),
        );
        await reject(messageFor([...instructions(), transfer]), validation());
      });

      test(
        'rejects duplicate, missing, reordered and trailing instructions',
        () async {
          final expected = instructions();
          for (final changed in [
            <Instruction>[],
            [...expected, expected.first],
            [expected.last, ...expected.take(expected.length - 1)],
            [...expected, budgetLimit(1000000)],
          ]) {
            if (changed.length == expected.length && expected.length == 1) {
              continue;
            }
            await reject(messageFor(changed), validation());
          }
        },
      );

      test(
        'rejects every altered instruction byte, including data discriminators',
        () async {
          final expected = instructions();

          for (var i = 0; i < expected.length; i++) {
            for (var byte = 0; byte < expected[i].data!.length; byte++) {
              final changed = [...expected];
              final data = Uint8List.fromList(expected[i].data!);
              data[byte] ^= 1;
              changed[i] = withData(changed[i], data);
              await reject(messageFor(changed), validation());
            }
            for (final data in [
              Uint8List(0),
              Uint8List.fromList([...expected[i].data!, 0]),
            ]) {
              final changed = [...expected]..[i] = withData(expected[i], data);
              await reject(messageFor(changed), validation());
            }
          }
        },
      );

      test(
        'rejects substituted, reordered, missing and extra account roles',
        () async {
          final expected = instructions();

          for (var i = 0; i < expected.length; i++) {
            final instruction = expected[i];
            final accounts = instruction.accounts!;

            for (var j = 0; j < accounts.length; j++) {
              final changedAccounts = [...accounts]
                ..[j] = AccountMeta(address: authority, role: accounts[j].role);
              final changed = [...expected]
                ..[i] = Instruction(
                  programAddress: instruction.programAddress,
                  accounts: changedAccounts,
                  data: instruction.data,
                );
              await reject(messageFor(changed), validation());
            }
            for (final changedAccounts in [
              accounts.reversed.toList(),
              accounts.sublist(1),
              [...accounts, accounts.first],
            ]) {
              final changed = [...expected]
                ..[i] = Instruction(
                  programAddress: instruction.programAddress,
                  accounts: changedAccounts,
                  data: instruction.data,
                );
              await reject(messageFor(changed), validation());
            }
          }
        },
      );

      test(
        'rejects unexpected compute budget opcodes, order, accounts and values',
        () async {
          for (final prefix in [
            [budgetLimit(0)],
            [budgetLimit(1400001)],
            [budgetPrice(BigInt.one << 63)],
            [budgetLimit(1000000), budgetPrice(BigInt.from(100001))],
            [budgetLimit(1000000), budgetLimit(1000000)],
            [budgetPrice(BigInt.one), budgetPrice(BigInt.one)],
            [budgetPrice(BigInt.one), budgetLimit(1000000)],
            [
              Instruction(
                programAddress: computeBudgetProgramAddress,
                data: Uint8List.fromList([1, 0, 0, 1, 0]),
              ),
            ],
            [
              Instruction(
                programAddress: computeBudgetProgramAddress,
                data: Uint8List.fromList([4, 1, 0, 0, 0]),
              ),
            ],
            [
              Instruction(
                programAddress: computeBudgetProgramAddress,
                data: Uint8List.fromList([2, 1]),
              ),
            ],
            [
              Instruction(
                programAddress: computeBudgetProgramAddress,
                data: Uint8List.fromList([...budgetLimit(1000000).data!, 0]),
              ),
            ],
            [
              Instruction(
                programAddress: computeBudgetProgramAddress,
                accounts: [
                  AccountMeta(
                    address: publisher,
                    role: AccountRole.writableSigner,
                  ),
                ],
                data: budgetLimit(1000000).data,
              ),
            ],
          ]) {
            await reject(
              messageFor([...prefix, ...instructions()]),
              validation(),
            );
          }
        },
      );

      test(
        'rejects escalated account privileges and duplicate static addresses',
        () async {
          final message = messageFor(instructions());
          final header = message.header;
          await reject(
            copyMessage(
              message,
              header: MessageHeader(
                numSignerAccounts: header.numSignerAccounts,
                numReadonlySignerAccounts: header.numReadonlySignerAccounts,
                numReadonlyNonSignerAccounts:
                    header.numReadonlyNonSignerAccounts - 1,
              ),
            ),
            validation(),
          );
          await reject(
            copyMessage(
              message,
              accounts: [
                ...message.staticAccounts,
                message.staticAccounts.last,
              ],
            ),
            validation(),
          );
        },
      );

      test('rejects unresolved lookup tables', () async {
        final message = messageFor(
          instructions(),
          version: TransactionVersion.v0,
        );
        await reject(
          copyMessage(
            message,
            lookups: [
              AddressTableLookup(
                lookupTableAddress: authority,
                writableIndexes: const [0],
                readonlyIndexes: const [],
              ),
            ],
          ),
          validation(),
        );
      });

      test('rejects invalid program and account indices', () async {
        final message = messageFor(instructions());
        final first = message.instructions.first;
        for (final changed in [
          CompiledInstruction(
            programAddressIndex: 255,
            accountIndices: first.accountIndices,
            data: first.data,
          ),
          CompiledInstruction(
            programAddressIndex: first.programAddressIndex,
            accountIndices: const [255],
            data: first.data,
          ),
        ]) {
          await reject(
            copyMessage(
              message,
              instructions: [changed, ...message.instructions.skip(1)],
            ),
            validation(),
          );
        }
      });

      test('rejects a mismatched blockhash and fee payer', () async {
        final message = messageFor(instructions());
        await reject(
          copyMessage(message, lifetime: authority.value),
          validation(),
        );
        final accounts = [...message.staticAccounts]..[0] = authority;
        await reject(copyMessage(message, accounts: accounts), validation());
      });

      test('rejects v1 transaction configuration', () async {
        await reject(
          messageFor(instructions(), version: TransactionVersion.v1),
          validation(),
        );
      });
    });
  }

  test('requires an existing valid mint signature', () async {
    final message = messageFor(release);
    await reject(message, releaseValidation(), signMint: false);
    final transaction = transactionFromMessage(message);
    final invalid = Transaction(
      messageBytes: transaction.messageBytes,
      signatures: {
        ...transaction.signatures,
        mint: SignatureBytes(Uint8List(64)),
      },
    );
    await expectLater(
      validatePublicationTransaction(signer, invalid, releaseValidation()),
      throwsA(isA<PublisherCliException>()),
    );
    expect(signer.transactionCalls, 0);
  });

  test('requires transaction intent even when validation is omitted', () async {
    await expectLater(
      signPreparedTransaction(
        signer,
        getBase64EncodedWireTransaction(
          transactionFromMessage(messageFor(verify)),
        ),
      ),
      throwsA(isA<PublisherCliException>()),
    );
    expect(signer.transactionCalls, 0);
  });

  test('rejects malformed base64 without signing', () async {
    await expectLater(
      signPreparedTransaction(signer, '!!!not-base64!!!', releaseValidation()),
      throwsA(isA<PublisherCliException>()),
    );
    expect(signer.transactionCalls, 0);
  });
}
