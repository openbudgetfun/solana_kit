/// Program and protocol addresses for the Solana Name Service (SNS).
///
/// All constants are taken verbatim from the SNS TypeScript SDK
/// (`SolanaNameService/sns-sdk`) `js-kit/src/constants/addresses.ts` so that
/// derivations match the reference implementation byte for byte.
library;

import 'package:solana_kit_addresses/solana_kit_addresses.dart';

/// The Solana Name Service program address.
///
/// The SPL Name Service program manages name registries, records, and
/// reverse-lookup accounts (`NAME_PROGRAM_ID` in the TypeScript SDK).
const nameProgramAddress = 'namesLPneVptA9Z5rqUDD9tMTWEJwofgaYwp8cawRkX';

/// The [Address] representation of the SPL Name Service program address.
const nameProgramAddressObject = Address(nameProgramAddress);

/// The SNS root domain account address.
///
/// This is the parent name account of every `.sol` (and `.sns`) domain
/// registered through the SNS registrar (`SNS_ROOT_DOMAIN_ACCOUNT` in the
/// TypeScript SDK). It is *not* derived; it is a well-known mainnet account.
const snsRootDomainAddress = '58PwtjSDuFHuUkYjH9BYnnQKHfwo9reZhC2zMJv9JPkx';

/// The [Address] representation of the SNS root domain account address.
const snsRootDomainAddressObject = Address(snsRootDomainAddress);

/// The SNS registrar (legacy "Registry") program address.
///
/// This is `REGISTER_PROGRAM_ID` / `REGISTRY_PROGRAM_ADDRESS` in the
/// TypeScript SDK, used by the `.sol` registration flows.
const snsRegistrarProgramAddress =
    'jCebN34bUfdeUYJT13J1yG16XWQpt5PDx6Mse9GUqhR';

/// The [Address] representation of the SNS registrar program address.
const snsRegistrarProgramAddressObject = Address(snsRegistrarProgramAddress);

/// The SNS Records program address.
///
/// The Records program (SNS-IP 1) manages V2 domain records
/// (`RECORDS_PROGRAM_ADDRESS` in the TypeScript SDK).
const snsRecordsProgramAddress = 'HP3D4D1ZCmohQGFVms2SS4LCANgJyksBf5s1F77FuFjZ';

/// The [Address] representation of the SNS Records program address.
const snsRecordsProgramAddressObject = Address(snsRecordsProgramAddress);

/// The central state address for domain records.
///
/// This name account is used as the *class* key when deriving V2 record
/// accounts. It is a PDA of the SNS Records program seeded with the program's
/// own address, matching the `CENTRAL_STATE_SNS_RECORDS` derivation published
/// in `@bonfida/sns-records`.
const centralStateSnsRecordsAddress =
    '2pMnqHvei2N5oDcVGCRdZx48gqti199wr5CsyTTafsbo';

/// The [Address] representation of the records central state address.
const centralStateSnsRecordsAddressObject = Address(
  centralStateSnsRecordsAddress,
);

/// The reverse lookup class address.
///
/// Name accounts derived with this class hold the human-readable name that
/// maps back to a domain account (`REVERSE_LOOKUP_CLASS` in the TypeScript
/// SDK, historically known as the "central state").
const reverseLookupClassAddress =
    '33m47vH6Eav6jr5Ry86XjhRft2jRBLDnDgPSHoquXi2Z';

/// The [Address] representation of the reverse lookup class address.
const reverseLookupClassAddressObject = Address(reverseLookupClassAddress);

/// The SNS Name Tokenizer program address.
///
/// Mints the NFT representing ownership of a tokenized domain
/// (`NAME_TOKENIZER_ADDRESS` in the TypeScript SDK).
const nameTokenizerProgramAddress =
    'nftD3vbNkNqfj2Sd3HZwbpw4BxxKWr4AjGb9X38JeZk';

/// The [Address] representation of the Name Tokenizer program address.
const nameTokenizerProgramAddressObject = Address(nameTokenizerProgramAddress);

/// The SNS Offers program address (`NAME_OFFERS_ADDRESS` in the TypeScript
/// SDK).
const nameOffersProgramAddress = '85iDfUvr3HJyLM2zcq5BXSiDvUWfw6cSE1FfNBo8Ap29';

/// The [Address] representation of the SNS Offers program address.
const nameOffersProgramAddressObject = Address(nameOffersProgramAddress);

/// Address of the `.twitter` TLD verification authority.
const twitterVerificationAuthorityAddress =
    'FvPH7PrVrLGKPfqaf3xJodFTjZriqrAXXLTVWEorTFBi';

/// The [Address] representation of the `.twitter` verification authority.
const twitterVerificationAuthorityAddressObject = Address(
  twitterVerificationAuthorityAddress,
);

/// The `.twitter` root parent registry address.
const twitterRootParentRegistryAddress =
    '4YcexoW3r78zz16J2aqmukBLRwGq6rAvWzJpkYAXqebv';

/// The [Address] representation of the `.twitter` root parent registry.
const twitterRootParentRegistryAddressObject = Address(
  twitterRootParentRegistryAddress,
);
