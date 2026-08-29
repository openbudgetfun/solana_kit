---
"solana_kit_mpl_core": major
---

# Add the Metaplex Core program client

Add the mpl-core (Metaplex Core) program client generated from the metaplex-foundation shank IDL: 42 instruction builders, 6 account codecs, 57 error helpers, program-level instruction identification and parsing, and PDA derivations for the asset signer, preconfigured plugin accounts, dynamic extra accounts, and oracle accounts.

```dart
final (assetSigner, bump) = await findAssetSignerPda(asset: asset);
```
