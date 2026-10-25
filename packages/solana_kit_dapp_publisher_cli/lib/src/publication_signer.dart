import 'dart:typed_data';

import 'package:solana_kit_address_constants/solana_kit_address_constants.dart'
    as constants;
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_dapp_publisher_cli/src/errors.dart';
import 'package:solana_kit_dapp_publisher_cli/src/files.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_keys/solana_kit_keys.dart';
import 'package:solana_kit_mpl_token_metadata/solana_kit_mpl_token_metadata.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';
import 'package:solana_kit_transactions/solana_kit_transactions.dart';

/// The token metadata program address.
const tokenMetadataProgramAddress = Address(
  'metaqbxxUerdq28cj1RbAWkYQm3ybzjb6a8bt518x1s',
);

/// The maximum priority fee a prepared publication may request (0.0001 SOL).
const maximumPublicationPriorityFeeLamports = 100000;

/// Signs transactions and messages for a publication.
abstract interface class PublicationSigner {
  /// The base58 address of the signer.
  String get address;

  /// Adds this signer's signature to [transaction].
  Future<Transaction> signTransaction(Transaction transaction);

  /// Signs an arbitrary message with Ed25519.
  Future<Uint8List> signMessage(Uint8List message);
}

/// A publication signer backed by a local key pair.
final class LocalPublicationSigner implements PublicationSigner {
  /// Creates a signer that signs with [keyPair].
  const LocalPublicationSigner(this.keyPair);

  /// The key pair used for signing.
  final KeyPair keyPair;

  @override
  String get address => getAddressFromPublicKey(keyPair.publicKey).toString();

  @override
  Future<Transaction> signTransaction(Transaction transaction) =>
      partiallySignTransaction([keyPair], transaction);

  @override
  Future<Uint8List> signMessage(Uint8List message) async =>
      signBytes(keyPair.privateKey, message).value;
}

/// Creates a [PublicationSigner] from a Solana CLI keypair (64 bytes).
PublicationSigner createPublicationSignerFromKeypairBytes(Uint8List bytes) {
  final keyPair = createKeyPairFromBytes(bytes);

  return LocalPublicationSigner(keyPair);
}

/// Validation requirements for a prepared portal transaction.
sealed class PublicationTransactionValidation {
  const PublicationTransactionValidation();

  /// The expected recent blockhash.
  abstract final String expectedBlockhash;

  /// The expected fee payer address.
  abstract final String expectedFeePayerAddress;

  /// The expected local signer address.
  abstract final String expectedSignerAddress;
}

/// Validation for the release NFT mint transaction.
final class ReleaseMintValidation extends PublicationTransactionValidation {
  /// Creates the validation.
  const ReleaseMintValidation({
    required this.expectedBlockhash,
    required this.expectedFeePayerAddress,
    required this.expectedSignerAddress,
    required this.expectedMintAddress,
    required this.expectedAppMintAddress,
    required this.expectedName,
    required this.expectedMetadataUri,
  });

  @override
  final String expectedBlockhash;

  @override
  final String expectedFeePayerAddress;

  @override
  final String expectedSignerAddress;

  /// The release mint address.
  final String expectedMintAddress;

  /// The app (collection) mint address.
  final String expectedAppMintAddress;

  /// The release name supplied to transaction preparation.
  final String expectedName;

  /// The metadata URI supplied to transaction preparation.
  final String expectedMetadataUri;
}

/// Validation for the collection verification transaction.
final class VerifyCollectionValidation
    extends PublicationTransactionValidation {
  /// Creates the validation.
  const VerifyCollectionValidation({
    required this.expectedBlockhash,
    required this.expectedFeePayerAddress,
    required this.expectedSignerAddress,
    required this.expectedNftMintAddress,
    required this.expectedCollectionMintAddress,
    required this.expectedCollectionAuthority,
  });

  @override
  final String expectedBlockhash;

  @override
  final String expectedFeePayerAddress;

  @override
  final String expectedSignerAddress;

  /// The release NFT mint address.
  final String expectedNftMintAddress;

  /// The app (collection) mint address.
  final String expectedCollectionMintAddress;

  /// The collection authority address.
  final String expectedCollectionAuthority;
}

/// Validates and signs a base64-encoded portal transaction, returning the
/// fully signed wire transaction as base64.
///
/// Throws [PublisherCliException] if [validation] is omitted or the transaction
/// differs from the locally expected publication instructions.
Future<String> signPreparedTransaction(
  PublicationSigner signer,
  String serializedTransaction, [
  PublicationTransactionValidation? validation,
]) async {
  if (validation == null) {
    throw const PublisherCliException(
      'Publication transaction validation is required before signing.',
    );
  }

  final bytes = base64DecodeBytes(serializedTransaction);
  final transaction = getTransactionDecoder().decode(bytes);
  await validatePublicationTransaction(signer, transaction, validation);
  final signedTransaction = await signer.signTransaction(transaction);

  return getBase64EncodedWireTransaction(signedTransaction);
}

/// Validates a prepared portal transaction against [validation] before
/// signing, including every instruction's data, account order and privileges.
Future<void> validatePublicationTransaction(
  PublicationSigner signer,
  Transaction transaction,
  PublicationTransactionValidation validation,
) async {
  final compiledMessage = getCompiledTransactionMessageDecoder().decode(
    transaction.messageBytes,
  );

  if (compiledMessage.version == TransactionVersion.v1 ||
      (compiledMessage.addressTableLookups?.isNotEmpty ?? false)) {
    throw const PublisherCliException(
      'Publication transactions must use legacy or v0 messages without lookup tables.',
    );
  }

  if (compiledMessage.lifetimeToken != validation.expectedBlockhash) {
    throw PublisherCliException(
      'Portal transaction blockhash mismatch. '
      'Expected ${validation.expectedBlockhash}; '
      'received ${compiledMessage.lifetimeToken}.',
    );
  }

  final accountAddresses = compiledMessage.staticAccounts;

  if (accountAddresses.isEmpty) {
    throw const PublisherCliException(
      'Portal transaction is missing a fee payer.',
    );
  }

  final feePayerAddress = accountAddresses[0].toString();

  if (feePayerAddress != validation.expectedFeePayerAddress) {
    throw PublisherCliException(
      'Portal transaction fee payer mismatch. '
      'Expected ${validation.expectedFeePayerAddress}; received $feePayerAddress.',
    );
  }

  if (signer.address != validation.expectedSignerAddress) {
    throw PublisherCliException(
      'Publication signer mismatch. '
      'Expected ${validation.expectedSignerAddress}; received ${signer.address}.',
    );
  }

  assertExistingSignaturesValid(transaction);

  final requiredSignerAddresses = accountAddresses
      .take(compiledMessage.header.numSignerAccounts)
      .map((address) => address.toString())
      .toList();

  if (!requiredSignerAddresses.contains(signer.address)) {
    throw PublisherCliException(
      'Portal transaction does not require the local signer ${signer.address}.',
    );
  }

  switch (validation) {
    case ReleaseMintValidation(
      :final expectedFeePayerAddress,
      :final expectedMintAddress,
    ):
      assertExactAddressSet(
        requiredSignerAddresses,
        [expectedFeePayerAddress, expectedMintAddress],
        'Release mint transaction',
      );
      final hasMintSignature = transaction.signatures.entries.any(
        (entry) =>
            entry.key.toString() == expectedMintAddress && entry.value != null,
      );

      if (!hasMintSignature) {
        throw const PublisherCliException(
          'Release mint transaction is missing the pre-signed mint signature.',
        );
      }
    case VerifyCollectionValidation(
      :final expectedFeePayerAddress,
      :final expectedCollectionAuthority,
    ):
      assertExactAddressSet(
        requiredSignerAddresses,
        [expectedFeePayerAddress, expectedCollectionAuthority],
        'Collection verification transaction',
      );
  }

  final expectedInstructions = await _publicationInstructions(validation);
  final budgetInstructions = _validateComputeBudget(compiledMessage);
  final expectedMessage = compileTransactionMessage(
    TransactionMessage(
      version: compiledMessage.version,
      feePayer: Address(validation.expectedFeePayerAddress),
      instructions: [...budgetInstructions, ...expectedInstructions],
    ),
  );
  _assertMessageIntent(compiledMessage, expectedMessage);
}

/// Asserts that the required signer set matches [expected] exactly.
void assertExactAddressSet(
  List<String> actual,
  List<String> expected,
  String label,
) {
  final normalizedActual = actual.toSet().toList()..sort();
  final normalizedExpected = expected.toSet().toList()..sort();
  final matches =
      normalizedActual.length == normalizedExpected.length &&
      normalizedExpected.asMap().entries.every(
        (entry) => normalizedActual[entry.key] == entry.value,
      );

  if (!matches) {
    throw PublisherCliException(
      '$label signer set mismatch. '
      'Expected ${normalizedExpected.join(', ')}; '
      'received ${normalizedActual.isEmpty ? '[none]' : normalizedActual.join(', ')}.',
    );
  }
}

/// Asserts that [accountAddresses] contains every expected account.
void assertAccountsPresent(
  List<Address> accountAddresses,
  List<(String, String)> expectedAddresses,
) {
  final addresses = accountAddresses
      .map((address) => address.toString())
      .toSet();

  for (final (label, address) in expectedAddresses) {
    if (!addresses.contains(address)) {
      throw PublisherCliException(
        'Portal transaction is missing the expected $label account: $address',
      );
    }
  }
}

/// Asserts that existing transaction signatures verify against the message.
///
/// Takes no signer: the caller has already established which identity is
/// signing, and which signatures a transaction may carry is a property of the
/// message itself, not of the local signer.
void assertExistingSignaturesValid(Transaction transaction) {
  final signedEntries = transaction.signatures.entries
      .where((entry) => entry.value != null)
      .toList();

  if (signedEntries.isEmpty) {
    return;
  }

  final message = transaction.messageBytes;
  final invalidSigners = <String>[];

  for (final entry in signedEntries) {
    final addressBytes = getAddressEncoder().encode(entry.key);

    if (!verifySignature(addressBytes, entry.value!, message)) {
      invalidSigners.add(entry.key.toString());
    }
  }

  if (invalidSigners.isNotEmpty) {
    throw PublisherCliException(
      'Portal transaction contains invalid existing signatures for '
      '${invalidSigners.join(', ')} and may have been modified in transit.',
    );
  }
}

/// Builds the complete intent locally; portal data never supplies a template.
Future<List<Instruction>> _publicationInstructions(
  PublicationTransactionValidation validation,
) async {
  final payer = Address(validation.expectedFeePayerAddress);

  switch (validation) {
    case ReleaseMintValidation():
      final mint = Address(validation.expectedMintAddress);
      final publisher = Address(validation.expectedSignerAddress);
      final metadata = (await findMetadataPda(mint: mint)).$1;
      final edition = (await findMasterEditionPda(mint: mint)).$1;
      final token = (await getProgramDerivedAddress(
        programAddress: constants.associatedTokenProgramAddress,
        seeds: [
          getAddressEncoder().encode(publisher),
          getAddressEncoder().encode(constants.tokenProgramAddress),
          getAddressEncoder().encode(mint),
        ],
      )).$1;
      final create = getCreateInstruction(
        programAddress: tokenMetadataProgramAddress,
        metadata: metadata,
        masterEdition: edition,
        mint: mint,
        authority: publisher,
        payer: payer,
        updateAuthority: publisher,
        systemProgram: constants.systemProgramAddress,
        sysvarInstructions: constants.sysvarInstructionsAddress,
        splTokenProgram: constants.tokenProgramAddress,
        createArgs: CreateArgsV1(
          assetData: AssetData(
            name: validation.expectedName,
            symbol: '',
            uri: validation.expectedMetadataUri,
            sellerFeeBasisPoints: 0,
            creators: [Creator(address: publisher, verified: true, share: 100)],
            primarySaleHappened: false,
            isMutable: true,
            tokenStandard: TokenStandard.nonFungible,
            collection: Collection(
              key: Address(validation.expectedAppMintAddress),
              verified: false,
            ),
            uses: null,
            collectionDetails: null,
            ruleSet: null,
          ),
          decimals: null,
          printSupply: const PrintSupplyZero(),
        ),
      );

      return [
        // A newly created mint must sign; the generic builder also supports
        // existing mints and therefore does not mark it as a signer itself.
        Instruction(
          programAddress: create.programAddress,
          accounts: [
            for (final account in create.accounts!)
              if (account.address == mint)
                AccountMeta(address: mint, role: AccountRole.writableSigner)
              else
                account,
          ],
          data: create.data,
        ),
        getMintInstruction(
          programAddress: tokenMetadataProgramAddress,
          token: token,
          tokenOwner: publisher,
          metadata: metadata,
          masterEdition: edition,
          mint: mint,
          authority: publisher,
          payer: payer,
          systemProgram: constants.systemProgramAddress,
          sysvarInstructions: constants.sysvarInstructionsAddress,
          splTokenProgram: constants.tokenProgramAddress,
          splAtaProgram: constants.associatedTokenProgramAddress,
          mintArgs: MintArgsV1(amount: BigInt.one, authorizationData: null),
        ),
      ];
    case VerifyCollectionValidation():
      final mint = Address(validation.expectedNftMintAddress);
      final collection = Address(validation.expectedCollectionMintAddress);

      return [
        getVerifyInstruction(
          programAddress: tokenMetadataProgramAddress,
          authority: Address(validation.expectedCollectionAuthority),
          metadata: (await findMetadataPda(mint: mint)).$1,
          collectionMint: collection,
          collectionMetadata: (await findMetadataPda(mint: collection)).$1,
          collectionMasterEdition: (await findMasterEditionPda(
            mint: collection,
          )).$1,
          systemProgram: constants.systemProgramAddress,
          sysvarInstructions: constants.sysvarInstructionsAddress,
          verificationArgs: VerificationArgs.collectionV1,
        ),
      ];
  }
}

/// Allows only an optional limit then an optional price, with a fixed fee cap.
List<Instruction> _validateComputeBudget(CompiledTransactionMessage message) {
  final instructions = <Instruction>[];
  var previousOpcode = 1;
  var units = 1400000;
  var price = BigInt.zero;

  for (final instruction in message.instructions) {
    final index = instruction.programAddressIndex;

    if (index < 0 || index >= message.staticAccounts.length) {
      throw const PublisherCliException('Invalid publication program index.');
    }

    if (message.staticAccounts[index] != computeBudgetProgramAddress) {
      break;
    }

    final data = instruction.data;

    if ((instruction.accountIndices?.isNotEmpty ?? false) ||
        data == null ||
        data.isEmpty ||
        (data[0] != 2 && data[0] != 3) ||
        data[0] <= previousOpcode ||
        data.length != (data[0] == 2 ? 5 : 9)) {
      throw const PublisherCliException(
        'Unexpected publication compute budget instruction.',
      );
    }

    previousOpcode = data[0];
    final bytes = ByteData.sublistView(data);

    if (data[0] == 2) {
      units = bytes.getUint32(1, Endian.little);

      if (units == 0 || units > 1400000) {
        throw const PublisherCliException(
          'Publication compute limit is out of bounds.',
        );
      }
    } else {
      price =
          BigInt.from(bytes.getUint32(1, Endian.little)) +
          (BigInt.from(bytes.getUint32(5, Endian.little)) << 32);
    }

    instructions.add(
      Instruction(
        programAddress: computeBudgetProgramAddress,
        accounts: const [],
        data: data,
      ),
    );
  }

  if (price * BigInt.from(units) >
      BigInt.from(maximumPublicationPriorityFeeLamports) *
          BigInt.from(1000000)) {
    throw const PublisherCliException(
      'Publication priority fee exceeds the allowed maximum.',
    );
  }

  return instructions;
}

/// Compares semantics without depending on a compiler's static-account order.
void _assertMessageIntent(
  CompiledTransactionMessage actual,
  CompiledTransactionMessage expected,
) {
  final accounts = actual.staticAccounts;
  final header = actual.header;

  if (accounts.toSet().length != accounts.length ||
      accounts.length != expected.staticAccounts.length ||
      header != expected.header ||
      actual.instructions.length != expected.instructions.length) {
    throw const PublisherCliException(
      'Publication transaction intent mismatch.',
    );
  }

  final expectedIndices = {
    for (var i = 0; i < expected.staticAccounts.length; i++)
      expected.staticAccounts[i]: i,
  };
  final remappedIndices = <int>[];

  for (var i = 0; i < accounts.length; i++) {
    final expectedIndex = expectedIndices[accounts[i]];

    if (expectedIndex == null ||
        _accountRole(actual, i) != _accountRole(expected, expectedIndex)) {
      throw const PublisherCliException(
        'Publication account or privilege mismatch.',
      );
    }

    remappedIndices.add(expectedIndex);
  }

  int remap(int index) {
    if (index < 0 || index >= remappedIndices.length) {
      throw const PublisherCliException('Invalid publication account index.');
    }

    return remappedIndices[index];
  }

  for (var i = 0; i < actual.instructions.length; i++) {
    final instruction = actual.instructions[i];
    final remapped = CompiledInstruction(
      programAddressIndex: remap(instruction.programAddressIndex),
      accountIndices: (instruction.accountIndices ?? const [])
          .map(remap)
          .toList(),
      data: instruction.data,
    );
    final expectedInstruction = expected.instructions[i];

    if (remapped != expectedInstruction) {
      throw PublisherCliException(
        'Publication instruction $i does not match the expected intent.',
      );
    }
  }
}

/// Reads the privileges the runtime grants to a static account.
AccountRole _accountRole(CompiledTransactionMessage message, int index) {
  final header = message.header;
  final signer = index < header.numSignerAccounts;
  final writable = signer
      ? index < header.numSignerAccounts - header.numReadonlySignerAccounts
      : index <
            message.staticAccounts.length - header.numReadonlyNonSignerAccounts;

  return signer
      ? (writable ? AccountRole.writableSigner : AccountRole.readonlySigner)
      : (writable ? AccountRole.writable : AccountRole.readonly);
}
