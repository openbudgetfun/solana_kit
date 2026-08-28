// coverage:ignore-file

import 'package:solana_kit_wallet_adapter/src/mobile_wallet.dart';
import 'package:solana_kit_wallet_standard/solana_kit_wallet_standard.dart';

/// Creates an empty registry for unsupported platforms.
WalletRegistry createPlatformWalletRegistry({
  required WalletAppIdentity appIdentity,
  required String chain,
}) => WalletRegistryController();
