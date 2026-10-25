---
"solana_kit_dapp_publisher_cli": major
---

# Validate the complete intent of portal publication transactions

Require complete local intent validation before signing portal transactions. Release minting now checks the exact CreateV1/MintV1 sequence, metadata name and URI, token recipient, supply, authorities, account privileges and derived addresses. Collection verification checks the exact Verify(CollectionV1) instruction. Reject extra or altered instructions, lookup tables, v1 messages and excessive priority fees.

`ReleaseMintValidation` now requires `expectedName` and `expectedMetadataUri`. Calling `signPreparedTransaction` without validation throws before signing. Only the documented publication instruction templates are accepted.

```dart
ReleaseMintValidation(
  expectedBlockhash: prepared.blockhash,
  expectedFeePayerAddress: payerAddress,
  expectedSignerAddress: publisherAddress,
  expectedMintAddress: prepared.mintAddress,
  expectedAppMintAddress: appMintAddress,
  expectedName: releaseName,
  expectedMetadataUri: releaseMetadataUri,
);
```
