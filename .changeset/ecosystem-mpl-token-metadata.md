---
"solana_kit_mpl_token_metadata": major
---

# Add the Token Metadata program client

Add the mpl-token-metadata program client, generated with `codama-renderers-dart` from the metaplex-foundation shank IDL: 58 instruction builders, 14 account codecs, 203 error helpers, instruction identification and parsing, and PDA derivations for metadata, master editions, edition markers, collection and use authority records, token records, delegate records, and program-as-burner.

```dart
final (metadata, bump) = await findMetadataPda(mint: mint);
```
