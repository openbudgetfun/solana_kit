import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:solana_kit_addresses/src/address.dart';
import 'package:solana_kit_addresses/src/address_codec.dart';
import 'package:solana_kit_addresses/src/curve.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';

/// A program-derived address and its associated bump seed.
///
/// The first element is the derived [Address] and the second is the bump seed
/// (an integer in the range [0, 255]) used to ensure the address does not fall
/// on the Ed25519 curve.
typedef ProgramDerivedAddress = (Address pda, int bump);

/// Maximum number of seeds (including the bump seed) for PDA derivation.
const int _maxSeeds = 16;

/// Maximum byte length of a single seed.
const int _maxSeedLength = 32;

/// The bytes of the string `'ProgramDerivedAddress'`.
final Uint8List _pdaMarkerBytes = Uint8List.fromList(
  utf8.encode('ProgramDerivedAddress'),
);

/// Creates a program-derived address from the given [programAddress] and
/// [seeds] without searching for a bump seed.
///
/// This is an internal function. The hash of the concatenated seeds, program
/// address bytes, and PDA marker must NOT fall on the Ed25519 curve.
Future<Address> _createProgramDerivedAddress({
  required Address programAddress,
  required List<Object> seeds,
}) async {
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

  if (compressedPointBytesAreOnCurve(addressBytes)) {
    throw SolanaError(SolanaErrorCode.addressesInvalidSeedsPointOnCurve);
  }

  return codec.decode(addressBytes);
}

/// Finds a program-derived address by trying bump seeds from 255 down to 0.
///
/// Given a program's [programAddress] and up to 16 [seeds], this returns the
/// PDA and the bump seed used to derive it. The bump seed is appended as an
/// additional single-byte seed.
///
/// Seeds can be [String] values (UTF-8 encoded) or [Uint8List] byte arrays.
/// Each seed must be at most 32 bytes, and there can be at most 16 seeds
/// (including the bump).
///
/// Throws [SolanaError] with:
/// - [SolanaErrorCode.addressesMaxNumberOfPdaSeedsExceeded] if too many seeds
/// - [SolanaErrorCode.addressesMaxPdaSeedLengthExceeded] if a seed is too long
/// - [SolanaErrorCode.addressesFailedToFindViablePdaBumpSeed] if no valid bump
///   seed produces an off-curve address
Future<ProgramDerivedAddress> getProgramDerivedAddress({
  required Address programAddress,
  required List<Object> seeds,
}) async {
  var bumpSeed = 255;
  while (bumpSeed >= 0) {
    try {
      final addr = await _createProgramDerivedAddress(
        programAddress: programAddress,
        seeds: [
          ...seeds,
          Uint8List.fromList([bumpSeed]),
        ],
      );
      return (addr, bumpSeed);
    } on SolanaError catch (e) {
      if (isSolanaError(e, SolanaErrorCode.addressesInvalidSeedsPointOnCurve)) {
        bumpSeed--;
      } else {
        rethrow;
      }
    }
  }
  throw SolanaError(SolanaErrorCode.addressesFailedToFindViablePdaBumpSeed);
}

/// Creates an address with a seed using SHA-256.
///
/// The derived address is the SHA-256 hash of the concatenation of:
/// - [baseAddress] bytes (32 bytes)
/// - [seed] bytes (String is UTF-8 encoded, or a Uint8List)
/// - [programAddress] bytes (32 bytes)
///
/// Throws [SolanaError] with:
/// - [SolanaErrorCode.addressesMaxPdaSeedLengthExceeded] if [seed] exceeds 32
///   bytes
/// - [SolanaErrorCode.addressesPdaEndsWithPdaMarker] if [programAddress]
///   bytes end with the "ProgramDerivedAddress" marker
Future<Address> createAddressWithSeed({
  required Address baseAddress,
  required Address programAddress,
  required Object seed,
}) async {
  final codec = getAddressCodec();

  final Uint8List seedBytes;
  if (seed is String) {
    seedBytes = Uint8List.fromList(utf8.encode(seed));
  } else if (seed is Uint8List) {
    seedBytes = seed;
  } else {
    throw ArgumentError('Seed must be a String or Uint8List, got $seed');
  }

  if (seedBytes.length > _maxSeedLength) {
    throw SolanaError(SolanaErrorCode.addressesMaxPdaSeedLengthExceeded, {
      'actual': seedBytes.length,
      'index': 0,
      'maxSeedLength': _maxSeedLength,
    });
  }

  final programAddressBytes = codec.encode(programAddress);

  // Check that the program address bytes don't end with the PDA marker.
  if (programAddressBytes.length >= _pdaMarkerBytes.length) {
    final tail = programAddressBytes.sublist(
      programAddressBytes.length - _pdaMarkerBytes.length,
    );
    if (bytesEqual(tail, _pdaMarkerBytes)) {
      throw SolanaError(SolanaErrorCode.addressesPdaEndsWithPdaMarker);
    }
  }

  final baseAddressBytes = codec.encode(baseAddress);

  final hashInput = Uint8List.fromList([
    ...baseAddressBytes,
    ...seedBytes,
    ...programAddressBytes,
  ]);

  final hashResult = sha256.convert(hashInput);
  final addressBytes = Uint8List.fromList(hashResult.bytes);

  return codec.decode(addressBytes);
}
