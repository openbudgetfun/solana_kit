import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_dapp_publisher_cli/src/errors.dart';
import 'package:solana_kit_dapp_publisher_cli/src/files.dart';
import 'package:solana_kit_keys/solana_kit_keys.dart';
import 'package:solana_kit_mpl_token_metadata/solana_kit_mpl_token_metadata.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';
import 'package:solana_kit_transactions/solana_kit_transactions.dart';

/// The token metadata program address.
const tokenMetadataProgramAddress = Address(
  'metaqbxxUerdq28cj1RbAWkYQm3ybzjb6a8bt518x1s',
);

/// The program addresses that publication transactions may invoke.
final Set<String> allowedPublicationProgramIds = {
  computeBudgetProgramAddress.toString(),
  tokenMetadataProgramAddress.toString(),
};

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
Future<String> signPreparedTransaction(
  PublicationSigner signer,
  String serializedTransaction, [
  PublicationTransactionValidation? validation,
]) async {
  final bytes = base64DecodeBytes(serializedTransaction);
  final transaction = getTransactionDecoder().decode(bytes);
  if (validation != null) {
    await validatePublicationTransaction(
      signer,
      transaction,
      validation,
    );
  }
  final signedTransaction = await signer.signTransaction(transaction);
  return getBase64EncodedWireTransaction(signedTransaction);
}

/// Validates a prepared portal transaction against [validation] before
/// signing. See the upstream TypeScript CLI for the exact contract.
Future<void> validatePublicationTransaction(
  PublicationSigner signer,
  Transaction transaction,
  PublicationTransactionValidation validation,
) async {
  final compiledMessage = getCompiledTransactionMessageDecoder().decode(
    transaction.messageBytes,
  );
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

  assertExistingSignaturesValid(signer, transaction);

  final requiredSignerAddresses = accountAddresses
      .take(compiledMessage.header.numSignerAccounts)
      .map((address) => address.toString())
      .toList();
  if (!requiredSignerAddresses.contains(signer.address)) {
    throw PublisherCliException(
      'Portal transaction does not require the local signer ${signer.address}.',
    );
  }

  final instructionPrograms = [
    for (final instruction in compiledMessage.instructions)
      accountAddresses[instruction.programAddressIndex].toString(),
  ];
  final unexpectedPrograms = instructionPrograms
      .where((programId) => !allowedPublicationProgramIds.contains(programId))
      .toSet()
      .toList();
  if (unexpectedPrograms.isNotEmpty) {
    throw PublisherCliException(
      'Portal transaction includes unexpected program ids: '
      '${unexpectedPrograms.join(', ')}',
    );
  }

  final hasTokenMetadataInstruction = instructionPrograms.any(
    (programId) => programId == tokenMetadataProgramAddress.toString(),
  );
  if (!hasTokenMetadataInstruction) {
    throw const PublisherCliException(
      'Portal transaction is missing the expected token metadata instruction.',
    );
  }

  switch (validation) {
    case ReleaseMintValidation(
      :final expectedFeePayerAddress,
      :final expectedMintAddress,
      :final expectedAppMintAddress,
    ):
      assertExactAddressSet(
        requiredSignerAddresses,
        [expectedFeePayerAddress, expectedMintAddress],
        'Release mint transaction',
      );
      assertAccountsPresent(accountAddresses, [
        ('release mint', expectedMintAddress),
      ]);

      final actualCollectionMintAddress =
          getTokenMetadataCreateCollectionAddress(
            compiledMessage,
          );
      if (actualCollectionMintAddress != expectedAppMintAddress) {
        throw PublisherCliException(
          'Portal transaction token metadata collection mismatch. '
          'Expected $expectedAppMintAddress; '
          'received ${actualCollectionMintAddress ?? '[none]'}.',
        );
      }

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
      :final expectedCollectionMintAddress,
      :final expectedCollectionAuthority,
    ):
      assertExactAddressSet(
        requiredSignerAddresses,
        [expectedFeePayerAddress, expectedCollectionAuthority],
        'Collection verification transaction',
      );
      final nftMint = Address(validation.expectedNftMintAddress);
      final collectionMint = Address(expectedCollectionMintAddress);
      assertAccountsPresent(accountAddresses, [
        (
          'release metadata',
          (await findMetadataPda(mint: nftMint)).$1.toString(),
        ),
        ('app collection mint', expectedCollectionMintAddress),
        (
          'app collection metadata',
          (await findMetadataPda(mint: collectionMint)).$1.toString(),
        ),
        (
          'app collection master edition',
          (await findMasterEditionPda(mint: collectionMint)).$1.toString(),
        ),
        ('collection authority', expectedCollectionAuthority),
      ]);
  }
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
void assertExistingSignaturesValid(
  PublicationSigner signer,
  Transaction transaction,
) {
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

/// Extracts the collection mint address from the create instruction, if any.
String? getTokenMetadataCreateCollectionAddress(
  CompiledTransactionMessage compiledMessage,
) {
  for (final instruction in compiledMessage.instructions) {
    final programAddress = compiledMessage
        .staticAccounts[instruction.programAddressIndex]
        .toString();
    if (programAddress != tokenMetadataProgramAddress.toString()) {
      continue;
    }
    final data = instruction.data;
    if (data == null || data.isEmpty || data[0] != 42) {
      continue;
    }
    try {
      final decoded = getCreateInstructionDataDecoder().decode(data);
      final args = decoded.createArgs;
      if (args is! CreateArgsV1) {
        continue;
      }
      final collection = args.assetData.collection;
      return collection?.key.toString();
    } on Object {
      throw const PublisherCliException(
        'Portal transaction contains an invalid token metadata create instruction.',
      );
    }
  }
  return null;
}
