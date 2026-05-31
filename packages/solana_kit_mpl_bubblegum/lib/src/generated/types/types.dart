// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'package:solana_kit_addresses/solana_kit_addresses.dart';

/// The version of the token program.
enum TokenProgramVersion {
  original(0),
  token2022(1);

  const TokenProgramVersion(this.value);
  final int value;
}

/// The token standard for the asset.
enum TokenStandard {
  nonFungible(0),
  fungibleAsset(1),
  fungible(2),
  nonFungibleEdition(3);

  const TokenStandard(this.value);
  final int value;
}

/// The method of use for an asset.
enum UseMethod {
  burn(0),
  multiple(1),
  single(2);

  const UseMethod(this.value);
  final int value;
}

/// Creator information for a compressed NFT.
class Creator {
  const Creator({
    required this.address,
    required this.verified,
    required this.share,
  });

  final Address address;
  final bool verified;
  final int share;
}

/// Collection information for a compressed NFT.
class Collection {
  const Collection({required this.verified, required this.key});

  final bool verified;
  final Address key;
}

/// Uses information for a compressed NFT.
class Uses {
  const Uses({
    required this.useMethod,
    required this.remaining,
    required this.total,
  });

  final UseMethod useMethod;
  final int remaining;
  final int total;
}
