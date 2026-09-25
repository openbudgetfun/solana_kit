import 'package:solana_kit_wallet_adapter/src/mobile_wallet.dart';
import 'package:solana_kit_wallet_adapter/src/platform/default_registry_stub.dart'
    if (dart.library.io) 'package:solana_kit_wallet_adapter/src/platform/default_registry_native.dart'
    if (dart.library.js_interop) 'package:solana_kit_wallet_adapter/src/platform/default_registry_web.dart'
    as platform;
import 'package:solana_kit_wallet_standard/solana_kit_wallet_standard.dart';

/// Creates the Wallet Standard registry appropriate for the current platform.
///
/// [additionalWallets] are always available alongside the wallets detected on
/// the platform, which is how the embedded docs demo guarantees its
/// deterministic demo wallet while still listing detected browser wallets.
WalletRegistry createDefaultWalletRegistry({
  required WalletAppIdentity appIdentity,
  required String chain,
  List<Wallet> additionalWallets = const [],
}) => platform.createPlatformWalletRegistry(
  appIdentity: appIdentity,
  chain: chain,
  additionalWallets: additionalWallets,
);
