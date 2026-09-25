import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_associated_token_account/src/program.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';

const int _maxSeeds = 16;
const int _maxSeedLength = 32;
final Uint8List _pdaMarkerBytes = Uint8List.fromList(
  utf8.encode('ProgramDerivedAddress'),
);

/// Seeds used to derive an associated token account PDA.
@immutable
class AssociatedTokenSeeds {
  /// Creates an [AssociatedTokenSeeds] value.
  const AssociatedTokenSeeds({
    required this.owner,
    required this.tokenProgram,
    required this.mint,
  });

  /// Wallet address that owns the ATA.
  final Address owner;

  /// Token program address, such as SPL Token or Token-2022.
  final Address tokenProgram;

  /// Mint address for the ATA.
  final Address mint;

  @override
  String toString() {
    return 'AssociatedTokenSeeds(owner: $owner, '
        'tokenProgram: $tokenProgram, mint: $mint)';
  }

  @override
  bool operator ==(Object other) {
    return other is AssociatedTokenSeeds &&
        other.owner == owner &&
        other.tokenProgram == tokenProgram &&
        other.mint == mint;
  }

  @override
  int get hashCode => Object.hash(owner, tokenProgram, mint);
}

/// Returns the associated token account address synchronously.
Address getAssociatedTokenAddressSync({
  required Address owner,
  required Address tokenProgram,
  required Address mint,
  Address programAddress = ataProgramAddress,
}) {
  final (address, _) = findAssociatedTokenPdaSync(
    seeds: AssociatedTokenSeeds(
      owner: owner,
      tokenProgram: tokenProgram,
      mint: mint,
    ),
    programAddress: programAddress,
  );
  return address;
}

/// Finds the ATA program-derived address asynchronously.
Future<(Address, int)> findAssociatedTokenPda({
  required AssociatedTokenSeeds seeds,
  Address programAddress = ataProgramAddress,
}) async {
  return findAssociatedTokenPdaSync(
    seeds: seeds,
    programAddress: programAddress,
  );
}

/// Finds the ATA program-derived address synchronously.
(Address, int) findAssociatedTokenPdaSync({
  required AssociatedTokenSeeds seeds,
  Address programAddress = ataProgramAddress,
}) {
  final seedValues = <Object>[
    getAddressEncoder().encode(seeds.owner),
    getAddressEncoder().encode(seeds.tokenProgram),
    getAddressEncoder().encode(seeds.mint),
  ];
  return _findProgramDerivedAddressSync(
    programAddress: programAddress,
    seeds: seedValues,
  );
}

(Address, int) _findProgramDerivedAddressSync({
  required Address programAddress,
  required List<Object> seeds,
}) {
  var bumpSeed = 255;
  while (bumpSeed >= 0) {
    try {
      final addr = _createProgramDerivedAddressSync(
        programAddress: programAddress,
        seeds: [
          ...seeds,
          Uint8List.fromList([bumpSeed]),
        ],
      );
      return (addr, bumpSeed);
    } on SolanaError catch (error) {
      if (isSolanaError(
        error,
        SolanaErrorCode.addressesInvalidSeedsPointOnCurve,
      )) {
        bumpSeed--;
      } else {
        rethrow;
      }
    }
  }

  throw SolanaError(SolanaErrorCode.addressesFailedToFindViablePdaBumpSeed);
}

Address _createProgramDerivedAddressSync({
  required Address programAddress,
  required List<Object> seeds,
}) {
  if (seeds.length > _maxSeeds) {
    throw SolanaError(SolanaErrorCode.addressesMaxNumberOfPdaSeedsExceeded, {
      'actual': seeds.length,
      'maxSeeds': _maxSeeds,
    });
  }

  final seedBytesList = <int>[];
  for (var i = 0; i < seeds.length; i++) {
    final seed = seeds[i];
    final Uint8List seedBytes;
    if (seed is Uint8List) {
      seedBytes = seed;
    } else if (seed is String) {
      seedBytes = Uint8List.fromList(utf8.encode(seed));
    } else {
      throw ArgumentError('Seed must be a String or Uint8List, got $seed');
    }

    if (seedBytes.length > _maxSeedLength) {
      throw SolanaError(SolanaErrorCode.addressesMaxPdaSeedLengthExceeded, {
        'actual': seedBytes.length,
        'index': i,
        'maxSeedLength': _maxSeedLength,
      });
    }

    seedBytesList.addAll(seedBytes);
  }

  final codec = getAddressCodec();
  final programAddressBytes = codec.encode(programAddress);
  final hashInput = Uint8List.fromList([
    ...seedBytesList,
    ...programAddressBytes,
    ..._pdaMarkerBytes,
  ]);
  final hashResult = sha256.convert(hashInput);
  final addressBytes = Uint8List.fromList(hashResult.bytes);
  final address = codec.decode(addressBytes);

  if (isOnCurveAddress(address)) {
    throw SolanaError(SolanaErrorCode.addressesInvalidSeedsPointOnCurve);
  }

  return address;
}
