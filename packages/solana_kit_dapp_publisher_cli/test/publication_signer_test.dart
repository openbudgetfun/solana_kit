import 'dart:convert';
import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart'
    hide tokenMetadataProgramAddress;
import 'package:solana_kit_dapp_publisher_cli/src/errors.dart';
import 'package:solana_kit_dapp_publisher_cli/src/files.dart';
import 'package:solana_kit_dapp_publisher_cli/src/publication_signer.dart';
import 'package:solana_kit_keys/solana_kit_keys.dart';
import 'package:solana_kit_mpl_token_metadata/solana_kit_mpl_token_metadata.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';
import 'package:solana_kit_transactions/solana_kit_transactions.dart';
import 'package:test/test.dart';

final KeyPair publisherKeypair = generateKeyPair();
final KeyPair mintKeypair = generateKeyPair();
final KeyPair unrelatedKeypair = generateKeyPair();

const blockhash = 'GPEsEFh2hEbJdH8CQe79rzuwL9V6trBY4qLXZ9iwbFqN';

Address get publisherAddress =>
    getAddressFromPublicKey(publisherKeypair.publicKey);

Address get mintAddress => getAddressFromPublicKey(mintKeypair.publicKey);

Address get unrelatedAddress =>
    getAddressFromPublicKey(unrelatedKeypair.publicKey);

final KeyPair appMintKeypair = generateKeyPair();
final KeyPair collectionAuthorityKeypair = generateKeyPair();
final Address appMintAddress = getAddressFromPublicKey(
  appMintKeypair.publicKey,
);
final Address collectionAuthority = getAddressFromPublicKey(
  collectionAuthorityKeypair.publicKey,
);
final Address feePayerAddress = publisherAddress;

Uint8List buildMessageBytes({
  required List<Address> accounts,
  required int numSigners,
  required List<CompiledInstruction> instructions,
  String? lifetime,
}) {
  final encoder = getCompiledTransactionMessageEncoder();
  return encoder.encode(
    CompiledTransactionMessage(
      version: TransactionVersion.legacy,
      header: MessageHeader(
        numSignerAccounts: numSigners,
        numReadonlySignerAccounts: 0,
        numReadonlyNonSignerAccounts: 0,
      ),
      staticAccounts: accounts,
      instructions: instructions,
      lifetimeToken: blockhash,
    ),
  );
}

Uint8List createInstructionData({Address? collection}) {
  CreateInstructionData buildData() => CreateInstructionData(
    createArgs: CreateArgsV1(
      assetData: AssetData(
        name: 'Release',
        symbol: '',
        uri: 'https://meta.example.com/1.json',
        sellerFeeBasisPoints: 0,
        creators: null,
        primarySaleHappened: false,
        isMutable: true,
        tokenStandard: TokenStandard.nonFungible,
        collection: collection == null
            ? null
            : Collection(key: collection!, verified: false),
        uses: null,
        collectionDetails: null,
        ruleSet: null,
      ),
      decimals: null,
      printSupply: null,
    ),
  );

  return getCreateInstructionDataEncoder().encode(buildData());
}

Transaction buildTransaction({
  required List<Address> accounts,
  required int numSigners,
  required List<CompiledInstruction> instructions,
  Map<Address, Uint8List>? signatures,
  String? lifetimeToken,
}) {
  final messageBytes = buildMessageBytes(
    accounts: accounts,
    numSigners: numSigners,
    instructions: instructions,
  );
  final requiredSigners = accounts.take(numSigners);
  return Transaction(
    messageBytes: messageBytes,
    signatures: {
      for (final address in requiredSigners) address: null,
      ...?signatures?.map(
        (key, value) => MapEntry(key, SignatureBytes(value)),
      ),
    },
  );
}

final metadataInstruction = CompiledInstruction(
  programAddressIndex: 2,
  accountIndices: const [0, 1, 3, 4],
  data: createInstructionData(collection: appMintAddress),
);

ReleaseMintValidation releaseMintValidation({
  Address? signer,
  Address? mint,
  Address? appMint,
  Address? feePayer,
  String? blockhashOverride,
}) => ReleaseMintValidation(
  expectedBlockhash: blockhash,
  expectedFeePayerAddress: publisherAddress.toString(),
  expectedSignerAddress: (signer ?? publisherAddress).toString(),
  expectedMintAddress: (mint ?? mintAddress).toString(),
  expectedAppMintAddress: (appMint ?? appMintAddress).toString(),
);

VerifyCollectionValidation verifyValidation({Address? signer}) =>
    VerifyCollectionValidation(
      expectedBlockhash: blockhash,
      expectedFeePayerAddress: publisherAddress.toString(),
      expectedSignerAddress: (signer ?? publisherAddress).toString(),
      expectedNftMintAddress: mintAddress.toString(),
      expectedCollectionMintAddress: appMintAddress.toString(),
      expectedCollectionAuthority: publisherAddress.toString(),
    );

Future<Uint8List> signWith(KeyPair keyPair, Uint8List message) async =>
    signBytes(keyPair.privateKey, message).value;

void main() {
  group('signPreparedTransaction', () {
    test('signs a valid release mint transaction', () async {
      final accounts = [
        publisherAddress,
        mintAddress,
        tokenMetadataProgramAddress,
        const Address('Meta111111111111111111111111111111111111111'),
        const Address('11111111111111111111111111111111'),
      ];
      final transaction = buildTransaction(
        accounts: accounts,
        numSigners: 2,
        instructions: [metadataInstruction],
        signatures: {
          mintAddress: (await Future.value(
            signBytes(
              mintKeypair.privateKey,
              buildMessageBytes(
                accounts: accounts,
                numSigners: 2,
                instructions: [metadataInstruction],
              ),
            ),
          )).value,
        },
      );

      final signer = LocalPublicationSigner(publisherKeypair);
      final wire = await signPreparedTransaction(
        signer,
        base64Encode(getTransactionEncoder().encode(transaction)),
        releaseMintValidation(),
      );

      final decoded = getTransactionDecoder().decode(base64DecodeBytes(wire));
      expect(decoded.signatures[publisherAddress], isNotNull);
      expect(decoded.signatures[mintAddress], isNotNull);
    });

    test('fails when the blockhash mismatches', () async {
      final accounts = [
        publisherAddress,
        mintAddress,
        tokenMetadataProgramAddress,
        const Address('Meta111111111111111111111111111111111111111'),
        const Address('11111111111111111111111111111111'),
      ];
      final transaction = buildTransaction(
        accounts: accounts,
        numSigners: 2,
        instructions: [metadataInstruction],
      );
      final signer = LocalPublicationSigner(publisherKeypair);
      await expectLater(
        signPreparedTransaction(
          signer,
          base64Encode(getTransactionEncoder().encode(transaction)),
          ReleaseMintValidation(
            expectedBlockhash: '11111111111111111111111111111111',
            expectedFeePayerAddress: publisherAddress.toString(),
            expectedSignerAddress: publisherAddress.toString(),
            expectedMintAddress: mintAddress.toString(),
            expectedAppMintAddress: appMintAddress.toString(),
          ),
        ),
        throwsA(
          isA<PublisherCliException>().having(
            (error) => error.message,
            'message',
            contains('blockhash mismatch'),
          ),
        ),
      );
    });

    test('fails when the fee payer is missing', () async {
      final accounts = [
        publisherAddress,
        mintAddress,
        tokenMetadataProgramAddress,
        const Address('Meta111111111111111111111111111111111111111'),
        const Address('11111111111111111111111111111111'),
      ];
      final messageBytes = buildMessageBytes(
        accounts: accounts,
        numSigners: 2,
        instructions: [metadataInstruction],
      );
      final transaction = Transaction(
        messageBytes: messageBytes,
        signatures: {for (final account in accounts) account: null},
      );
      // Simulate a missing fee payer by using an empty static accounts list.
      final emptyMessage = getCompiledTransactionMessageEncoder().encode(
        const CompiledTransactionMessage(
          version: TransactionVersion.legacy,
          header: MessageHeader(
            numSignerAccounts: 2,
            numReadonlySignerAccounts: 0,
            numReadonlyNonSignerAccounts: 0,
          ),
          staticAccounts: [],
          instructions: [],
          lifetimeToken: blockhash,
        ),
      );
      final signer = LocalPublicationSigner(publisherKeypair);
      await expectLater(
        validatePublicationTransaction(
          signer,
          Transaction(messageBytes: emptyMessage, signatures: {}),
          releaseMintValidation(),
        ),
        throwsA(
          isA<PublisherCliException>().having(
            (error) => error.message,
            'message',
            contains('missing a fee payer'),
          ),
        ),
      );
      expect(transaction.signatures, isNotEmpty);
    });

    test('fails when the fee payer mismatches', () async {
      final accounts = [
        unrelatedAddress,
        mintAddress,
        tokenMetadataProgramAddress,
        const Address('Meta111111111111111111111111111111111111111'),
        const Address('11111111111111111111111111111111'),
      ];
      final transaction = buildTransaction(
        accounts: accounts,
        numSigners: 2,
        instructions: [metadataInstruction],
      );
      final signer = LocalPublicationSigner(publisherKeypair);
      await expectLater(
        validatePublicationTransaction(
          signer,
          transaction,
          releaseMintValidation(),
        ),
        throwsA(
          isA<PublisherCliException>().having(
            (error) => error.message,
            'message',
            contains('fee payer mismatch'),
          ),
        ),
      );
    });

    test('fails when the signer mismatches', () async {
      final accounts = [
        publisherAddress,
        mintAddress,
        tokenMetadataProgramAddress,
        const Address('Meta111111111111111111111111111111111111111'),
        const Address('11111111111111111111111111111111'),
      ];
      final transaction = buildTransaction(
        accounts: accounts,
        numSigners: 2,
        instructions: [metadataInstruction],
      );
      final signer = LocalPublicationSigner(unrelatedKeypair);
      await expectLater(
        validatePublicationTransaction(
          signer,
          transaction,
          releaseMintValidation(),
        ),
        throwsA(
          isA<PublisherCliException>().having(
            (error) => error.message,
            'message',
            contains('Publication signer mismatch'),
          ),
        ),
      );
    });

    test('rejects invalid existing signatures', () async {
      final accounts = [
        publisherAddress,
        mintAddress,
        tokenMetadataProgramAddress,
        const Address('Meta111111111111111111111111111111111111111'),
        const Address('11111111111111111111111111111111'),
      ];
      final transaction = buildTransaction(
        accounts: accounts,
        numSigners: 2,
        instructions: [metadataInstruction],
        signatures: {mintAddress: Uint8List(64)},
      );
      final signer = LocalPublicationSigner(publisherKeypair);
      await expectLater(
        validatePublicationTransaction(
          signer,
          transaction,
          releaseMintValidation(),
        ),
        throwsA(
          isA<PublisherCliException>().having(
            (error) => error.message,
            'message',
            contains('invalid existing signatures'),
          ),
        ),
      );
    });

    test('rejects when the signer is not required', () async {
      final accounts = [
        publisherAddress,
        mintAddress,
        tokenMetadataProgramAddress,
        const Address('Meta111111111111111111111111111111111111111'),
        const Address('11111111111111111111111111111111'),
      ];
      final transaction = buildTransaction(
        accounts: accounts,
        numSigners: 1,
        instructions: [metadataInstruction],
      );
      final signer = LocalPublicationSigner(unrelatedKeypair);
      await expectLater(
        validatePublicationTransaction(
          signer,
          transaction,
          ReleaseMintValidation(
            expectedBlockhash: blockhash,
            expectedFeePayerAddress: publisherAddress.toString(),
            expectedSignerAddress: unrelatedAddress.toString(),
            expectedMintAddress: mintAddress.toString(),
            expectedAppMintAddress: appMintAddress.toString(),
          ),
        ),
        throwsA(
          isA<PublisherCliException>().having(
            (error) => error.message,
            'message',
            contains('does not require the local signer'),
          ),
        ),
      );
    });

    test('rejects unexpected program ids', () async {
      final accounts = [
        publisherAddress,
        mintAddress,
        tokenMetadataProgramAddress,
        systemProgramAddress,
      ];
      final transaction = buildTransaction(
        accounts: accounts,
        numSigners: 2,
        instructions: [
          metadataInstruction,
          CompiledInstruction(programAddressIndex: 3, data: Uint8List(4)),
        ],
      );
      final signer = LocalPublicationSigner(publisherKeypair);
      await expectLater(
        validatePublicationTransaction(
          signer,
          transaction,
          releaseMintValidation(),
        ),
        throwsA(
          isA<PublisherCliException>().having(
            (error) => error.message,
            'message',
            contains('unexpected program ids'),
          ),
        ),
      );
    });

    test('requires a token metadata instruction', () async {
      final transaction = buildTransaction(
        accounts: [
          publisherAddress,
          const Address('ComputeBudget111111111111111111111111111111'),
        ],
        numSigners: 1,
        instructions: [
          CompiledInstruction(
            programAddressIndex: 1,
            data: Uint8List.fromList([2, 0, 0, 1]),
          ),
        ],
      );
      final signer = LocalPublicationSigner(publisherKeypair);
      await expectLater(
        validatePublicationTransaction(
          signer,
          transaction,
          releaseMintValidation(),
        ),
        throwsA(
          isA<PublisherCliException>().having(
            (error) => error.message,
            'message',
            contains('missing the expected token metadata instruction'),
          ),
        ),
      );
    });

    test('enforces the release mint signer set', () async {
      final accounts = [
        publisherAddress,
        mintAddress,
        tokenMetadataProgramAddress,
        const Address('Meta111111111111111111111111111111111111111'),
        const Address('11111111111111111111111111111111'),
      ];
      final transaction = buildTransaction(
        accounts: accounts,
        numSigners: 2,
        instructions: [metadataInstruction],
      );
      final signer = LocalPublicationSigner(publisherKeypair);
      await expectLater(
        validatePublicationTransaction(
          signer,
          transaction,
          releaseMintValidation(mint: unrelatedAddress),
        ),
        throwsA(
          isA<PublisherCliException>().having(
            (error) => error.message,
            'message',
            contains('signer set mismatch'),
          ),
        ),
      );
    });

    test('requires the release mint account', () async {
      final accounts = [
        publisherAddress,
        unrelatedAddress,
        tokenMetadataProgramAddress,
        const Address('Meta111111111111111111111111111111111111111'),
        const Address('11111111111111111111111111111111'),
      ];
      final transaction = buildTransaction(
        accounts: accounts,
        numSigners: 2,
        instructions: [metadataInstruction],
      );
      final signer = LocalPublicationSigner(publisherKeypair);
      await expectLater(
        validatePublicationTransaction(
          signer,
          transaction,
          releaseMintValidation(mint: unrelatedAddress),
        ),
        throwsA(
          isA<PublisherCliException>().having(
            (error) => error.message,
            'message',
            contains('pre-signed mint signature'),
          ),
        ),
      );
    });

    test('rejects a collection mismatch on the create instruction', () async {
      final accounts = [
        publisherAddress,
        mintAddress,
        tokenMetadataProgramAddress,
        const Address('Meta111111111111111111111111111111111111111'),
        const Address('11111111111111111111111111111111'),
      ];
      final wrongCollection = CompiledInstruction(
        programAddressIndex: 2,
        accountIndices: const [0, 1, 3, 4],
        data: createInstructionData(collection: unrelatedAddress),
      );
      final transaction = buildTransaction(
        accounts: accounts,
        numSigners: 2,
        instructions: [wrongCollection],
      );
      final signer = LocalPublicationSigner(publisherKeypair);
      await expectLater(
        validatePublicationTransaction(
          signer,
          transaction,
          releaseMintValidation(),
        ),
        throwsA(
          isA<PublisherCliException>().having(
            (error) => error.message,
            'message',
            contains('collection mismatch'),
          ),
        ),
      );
    });

    test('rejects a create instruction without a collection', () async {
      final accounts = [
        publisherAddress,
        mintAddress,
        tokenMetadataProgramAddress,
        const Address('Meta111111111111111111111111111111111111111'),
        const Address('11111111111111111111111111111111'),
      ];
      final noCollection = CompiledInstruction(
        programAddressIndex: 2,
        accountIndices: const [0, 1, 3, 4],
        data: createInstructionData(),
      );
      final transaction = buildTransaction(
        accounts: accounts,
        numSigners: 2,
        instructions: [noCollection],
      );
      final signer = LocalPublicationSigner(publisherKeypair);
      await expectLater(
        validatePublicationTransaction(
          signer,
          transaction,
          releaseMintValidation(),
        ),
        throwsA(
          isA<PublisherCliException>().having(
            (error) => error.message,
            'message',
            contains('collection mismatch'),
          ),
        ),
      );
    });

    test('rejects invalid create instruction payloads', () async {
      final accounts = [
        publisherAddress,
        mintAddress,
        tokenMetadataProgramAddress,
      ];
      final transaction = buildTransaction(
        accounts: accounts,
        numSigners: 2,
        instructions: [
          CompiledInstruction(
            programAddressIndex: 2,
            accountIndices: const [0, 1],
            data: Uint8List.fromList([42, 9, 9, 9]),
          ),
        ],
      );
      final signer = LocalPublicationSigner(publisherKeypair);
      await expectLater(
        validatePublicationTransaction(
          signer,
          transaction,
          releaseMintValidation(),
        ),
        throwsA(
          isA<PublisherCliException>().having(
            (error) => error.message,
            'message',
            contains('invalid token metadata create instruction'),
          ),
        ),
      );
    });

    test('requires a pre-signed mint signature', () async {
      final accounts = [
        publisherAddress,
        mintAddress,
        tokenMetadataProgramAddress,
        const Address('Meta111111111111111111111111111111111111111'),
        const Address('11111111111111111111111111111111'),
      ];
      final transaction = buildTransaction(
        accounts: accounts,
        numSigners: 2,
        instructions: [metadataInstruction],
      );
      final signer = LocalPublicationSigner(publisherKeypair);
      await expectLater(
        validatePublicationTransaction(
          signer,
          transaction,
          releaseMintValidation(),
        ),
        throwsA(
          isA<PublisherCliException>().having(
            (error) => error.message,
            'message',
            contains('pre-signed mint signature'),
          ),
        ),
      );
    });

    test('enforces the verify collection signer set and accounts', () async {
      final metadataPda = (await findMetadataPda(mint: mintAddress)).$1;
      final collectionMetadataPda = (await findMetadataPda(
        mint: appMintAddress,
      )).$1;
      final collectionEdition = (await findMasterEditionPda(
        mint: appMintAddress,
      )).$1;
      final accounts = [
        publisherAddress,
        collectionAuthority,
        tokenMetadataProgramAddress,
        metadataPda,
        appMintAddress,
        collectionMetadataPda,
        collectionEdition,
      ];
      final transaction = buildTransaction(
        accounts: accounts,
        numSigners: 2,
        instructions: [
          CompiledInstruction(
            programAddressIndex: 2,
            accountIndices: const [0, 1, 3, 4],
            data: Uint8List.fromList([25, 1, 2, 3]),
          ),
        ],
      );
      final signer = LocalPublicationSigner(publisherKeypair);
      await expectLater(
        validatePublicationTransaction(
          signer,
          transaction,
          VerifyCollectionValidation(
            expectedBlockhash: blockhash,
            expectedFeePayerAddress: publisherAddress.toString(),
            expectedSignerAddress: publisherAddress.toString(),
            expectedNftMintAddress: mintAddress.toString(),
            expectedCollectionMintAddress: appMintAddress.toString(),
            expectedCollectionAuthority: publisherAddress.toString(),
          ),
        ),
        throwsA(
          isA<PublisherCliException>().having(
            (error) => error.message,
            'message',
            contains('signer set mismatch'),
          ),
        ),
      );

      await validatePublicationTransaction(
        signer,
        transaction,
        VerifyCollectionValidation(
          expectedBlockhash: blockhash,
          expectedFeePayerAddress: publisherAddress.toString(),
          expectedSignerAddress: publisherAddress.toString(),
          expectedNftMintAddress: mintAddress.toString(),
          expectedCollectionMintAddress: appMintAddress.toString(),
          expectedCollectionAuthority: collectionAuthority.toString(),
        ),
      );
    });

    test('fails when verify collection accounts are missing', () async {
      final accounts = [
        publisherAddress,
        mintAddress,
        tokenMetadataProgramAddress,
      ];
      final transaction = buildTransaction(
        accounts: accounts,
        numSigners: 1,
        instructions: [
          CompiledInstruction(
            programAddressIndex: 2,
            accountIndices: const [0, 1],
            data: Uint8List.fromList([25, 1, 2, 3]),
          ),
        ],
      );
      final signer = LocalPublicationSigner(publisherKeypair);
      await expectLater(
        validatePublicationTransaction(
          signer,
          transaction,
          VerifyCollectionValidation(
            expectedBlockhash: blockhash,
            expectedFeePayerAddress: publisherAddress.toString(),
            expectedSignerAddress: publisherAddress.toString(),
            expectedNftMintAddress: mintAddress.toString(),
            expectedCollectionMintAddress: appMintAddress.toString(),
            expectedCollectionAuthority: publisherAddress.toString(),
          ),
        ),
        throwsA(
          isA<PublisherCliException>().having(
            (error) => error.message,
            'message',
            contains('missing the expected'),
          ),
        ),
      );
    });

    test('passes validation without a validation requirement', () async {
      final accounts = [publisherAddress];
      final transaction = buildTransaction(
        accounts: accounts,
        numSigners: 1,
        instructions: const [],
      );
      final signer = LocalPublicationSigner(publisherKeypair);
      final wire = await signPreparedTransaction(
        signer,
        base64Encode(getTransactionEncoder().encode(transaction)),
      );
      expect(wire, isNotEmpty);
    });

    test('assertAccountsPresent reports the missing account', () {
      expect(
        () => assertAccountsPresent(const [], [
          ('release mint', mintAddress.toString()),
        ]),
        throwsA(
          isA<PublisherCliException>().having(
            (error) => error.message,
            'message',
            contains('missing the expected release mint account'),
          ),
        ),
      );
    });

    test('assertExactAddressSet reports mismatches', () {
      expect(
        () => assertExactAddressSet(['a'], ['b'], 'Test'),
        throwsA(
          isA<PublisherCliException>().having(
            (error) => error.message,
            'message',
            contains('signer set mismatch'),
          ),
        ),
      );
      expect(
        () => assertExactAddressSet([], ['b'], 'Test'),
        throwsA(
          isA<PublisherCliException>().having(
            (error) => error.message,
            'message',
            contains('received [none]'),
          ),
        ),
      );
      expect(
        () => assertExactAddressSet(['a'], ['a'], 'Test'),
        returnsNormally,
      );
    });

    test('rejects malformed base64 payloads', () async {
      final signer = LocalPublicationSigner(publisherKeypair);
      await expectLater(
        signPreparedTransaction(signer, '!!!not-base64!!!'),
        throwsA(isA<PublisherCliException>()),
      );
    });
  });
}

const systemProgramAddress = Address('11111111111111111111111111111111');
