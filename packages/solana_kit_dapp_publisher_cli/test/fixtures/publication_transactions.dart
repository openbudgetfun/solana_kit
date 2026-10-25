import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_mpl_token_metadata/solana_kit_mpl_token_metadata.dart';

/// Complete CreateV1/MintV1 accounts, in the Metaplex wire order.
Future<List<Instruction>> releaseInstructions({
  required Address publisher,
  required Address payer,
  required Address mint,
  required Address collection,
  required String name,
  required String uri,
}) async {
  final metadata = (await findMetadataPda(mint: mint)).$1;
  final edition = (await findMasterEditionPda(mint: mint)).$1;
  final token = (await getProgramDerivedAddress(
    programAddress: associatedTokenProgramAddress,
    seeds: [
      getAddressEncoder().encode(publisher),
      getAddressEncoder().encode(tokenProgramAddress),
      getAddressEncoder().encode(mint),
    ],
  )).$1;

  return [
    Instruction(
      programAddress: tokenMetadataProgramAddress,
      accounts: [
        AccountMeta(address: metadata, role: AccountRole.writable),
        AccountMeta(address: edition, role: AccountRole.writable),
        AccountMeta(address: mint, role: AccountRole.writableSigner),
        AccountMeta(address: publisher, role: AccountRole.readonlySigner),
        AccountMeta(address: payer, role: AccountRole.writableSigner),
        AccountMeta(address: publisher, role: AccountRole.readonly),
        const AccountMeta(
          address: systemProgramAddress,
          role: AccountRole.readonly,
        ),
        const AccountMeta(
          address: sysvarInstructionsAddress,
          role: AccountRole.readonly,
        ),
        const AccountMeta(
          address: tokenProgramAddress,
          role: AccountRole.readonly,
        ),
      ],
      data: getCreateInstructionDataEncoder().encode(
        CreateInstructionData(
          createArgs: CreateArgsV1(
            assetData: AssetData(
              name: name,
              symbol: '',
              uri: uri,
              sellerFeeBasisPoints: 0,
              creators: [
                Creator(address: publisher, verified: true, share: 100),
              ],
              primarySaleHappened: false,
              isMutable: true,
              tokenStandard: TokenStandard.nonFungible,
              collection: Collection(key: collection, verified: false),
              uses: null,
              collectionDetails: null,
              ruleSet: null,
            ),
            decimals: null,
            printSupply: const PrintSupplyZero(),
          ),
        ),
      ),
    ),
    Instruction(
      programAddress: tokenMetadataProgramAddress,
      accounts: [
        AccountMeta(address: token, role: AccountRole.writable),
        AccountMeta(address: publisher, role: AccountRole.readonly),
        AccountMeta(address: metadata, role: AccountRole.readonly),
        AccountMeta(address: edition, role: AccountRole.writable),
        const AccountMeta(
          address: tokenMetadataProgramAddress,
          role: AccountRole.readonly,
        ),
        AccountMeta(address: mint, role: AccountRole.writable),
        AccountMeta(address: publisher, role: AccountRole.readonlySigner),
        const AccountMeta(
          address: tokenMetadataProgramAddress,
          role: AccountRole.readonly,
        ),
        AccountMeta(address: payer, role: AccountRole.writableSigner),
        const AccountMeta(
          address: systemProgramAddress,
          role: AccountRole.readonly,
        ),
        const AccountMeta(
          address: sysvarInstructionsAddress,
          role: AccountRole.readonly,
        ),
        const AccountMeta(
          address: tokenProgramAddress,
          role: AccountRole.readonly,
        ),
        const AccountMeta(
          address: associatedTokenProgramAddress,
          role: AccountRole.readonly,
        ),
        const AccountMeta(
          address: tokenMetadataProgramAddress,
          role: AccountRole.readonly,
        ),
        const AccountMeta(
          address: tokenMetadataProgramAddress,
          role: AccountRole.readonly,
        ),
      ],
      data: getMintInstructionDataEncoder().encode(
        MintInstructionData(
          mintArgs: MintArgsV1(amount: BigInt.one, authorizationData: null),
        ),
      ),
    ),
  ];
}

/// Complete Verify(CollectionV1) accounts, in the Metaplex wire order.
Future<List<Instruction>> verifyInstructions({
  required Address authority,
  required Address mint,
  required Address collection,
}) async => [
  Instruction(
    programAddress: tokenMetadataProgramAddress,
    accounts: [
      AccountMeta(address: authority, role: AccountRole.readonlySigner),
      const AccountMeta(
        address: tokenMetadataProgramAddress,
        role: AccountRole.readonly,
      ),
      AccountMeta(
        address: (await findMetadataPda(mint: mint)).$1,
        role: AccountRole.writable,
      ),
      AccountMeta(address: collection, role: AccountRole.readonly),
      AccountMeta(
        address: (await findMetadataPda(mint: collection)).$1,
        role: AccountRole.writable,
      ),
      AccountMeta(
        address: (await findMasterEditionPda(mint: collection)).$1,
        role: AccountRole.readonly,
      ),
      const AccountMeta(
        address: systemProgramAddress,
        role: AccountRole.readonly,
      ),
      const AccountMeta(
        address: sysvarInstructionsAddress,
        role: AccountRole.readonly,
      ),
    ],
    data: getVerifyInstructionDataEncoder().encode(
      const VerifyInstructionData(
        verificationArgs: VerificationArgs.collectionV1,
      ),
    ),
  ),
];
