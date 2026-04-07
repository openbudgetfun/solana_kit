# solana_kit_associated_token_account

Handwritten Associated Token Account (ATA) client for the Solana Kit Dart SDK.

This package exposes the canonical ATA program address, PDA derivation helpers,
and typed instruction builders shared by `solana_kit_token` and
`solana_kit_token_2022`.

## Usage

```dart
import 'package:solana_kit_associated_token_account/solana_kit_associated_token_account.dart';

Future<void> main() async {
  const owner = Address('11111111111111111111111111111111');
  const mint = Address('EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v');
  const tokenProgram = Address('TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA');

  final ata = getAssociatedTokenAddressSync(
    owner: owner,
    tokenProgram: tokenProgram,
    mint: mint,
  );

  print(ata.value);
}
```
