import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_offchain_messages/src/codecs/signing_domain.dart';
import 'package:solana_kit_offchain_messages/src/version.dart';

/// Creates a decoder that reads the signing domain, version, and any
/// additional fields for the offchain message preamble.
Decoder<Map<String, Object?>> createOffchainMessagePreambleDecoder(
  OffchainMessageVersion expectedVersion,
  List<(String, Decoder<Object?>)> fields,
) {
  final versionDecoder = transformDecoder<int, int>(getU8Decoder(), (
    value,
    Uint8List bytes,
    int offset,
  ) {
    _validateVersion(value, expectedVersion);
    return value;
  });
  return getHiddenPrefixDecoder(
    getStructDecoder([('version', versionDecoder), ...fields]),
    [getOffchainMessageSigningDomainDecoder()],
  );
}

/// Creates an encoder that writes the signing domain, version, and any
/// additional fields for the offchain message preamble.
Encoder<Map<String, Object?>> createOffchainMessagePreambleEncoder(
  OffchainMessageVersion expectedVersion,
  List<(String, Encoder<Object?>)> fields,
) {
  final versionEncoder = transformEncoder<num, int>(getU8Encoder(), (value) {
    _validateVersion(value, expectedVersion);
    return value;
  });
  return getHiddenPrefixEncoder(
    getStructEncoder([('version', versionEncoder), ...fields]),
    [getOffchainMessageSigningDomainEncoder()],
  );
}

/// Decodes the required signatory addresses from the raw message bytes.
///
/// This function reads the signing domain, version, and then extracts the
/// signatory addresses list from the correct position depending on the
/// version.
List<Address> decodeRequiredSignatoryAddresses(Uint8List bytes) {
  // First, decode the version and rest of bytes after version.
  final versionDecoder = transformDecoder<int, int>(getU8Decoder(), (
    value,
    Uint8List bytes,
    int offset,
  ) {
    if (value > 1) {
      throw SolanaError(
        SolanaErrorCode.offchainMessageVersionNumberNotSupported,
        {'unsupportedVersion': value},
      );
    }
    return value;
  });

  final preambleDecoder = getHiddenPrefixDecoder(
    getStructDecoder([
      ('version', versionDecoder),
      ('bytesAfterVersion', getBytesDecoder()),
    ]),
    [getOffchainMessageSigningDomainDecoder()],
  );

  final preamble = preambleDecoder.decode(bytes);
  final version = preamble['version']! as int;
  final bytesAfterVersion = preamble['bytesAfterVersion']! as Uint8List;

  // For v0: skip 32 bytes application domain + 1 byte message format = 33
  // For v1: no skip
  final skipBytes = version == 0 ? 33 : 0;

  // Decode array of addresses from bytesAfterVersion, skipping the
  // appropriate number of bytes.
  final signatoryDecoder = transformDecoder<List<Object?>, List<Address>>(
    getArrayDecoder(
      getAddressDecoder() as Decoder<Object?>,
      size: PrefixedArraySize(getU8Decoder()),
    ),
    (signatoryAddresses, Uint8List bytes, int offset) {
      final addresses = signatoryAddresses.cast<Address>();
      if (addresses.isEmpty) {
        throw SolanaError(
          SolanaErrorCode.offchainMessageNumRequiredSignersCannotBeZero,
        );
      }
      return addresses;
    },
  );

  return signatoryDecoder.decode(bytesAfterVersion, skipBytes);
}

/// Returns a comparator for byte arrays that sorts lexicographically.
///
/// Shorter arrays sort before longer arrays. Within arrays of equal length,
/// comparison is byte-by-byte.
int Function(Uint8List, Uint8List) getSignatoriesComparator() {
  return (Uint8List x, Uint8List y) {
    if (x.length != y.length) {
      return x.length < y.length ? -1 : 1;
    }
    for (var i = 0; i < x.length; i++) {
      if (x[i] == y[i]) continue;
      return x[i] < y[i] ? -1 : 1;
    }
    return 0;
  };
}

void _validateVersion(int version, int? expectedVersion) {
  if (version > 1) {
    throw SolanaError(
      SolanaErrorCode.offchainMessageVersionNumberNotSupported,
      {'unsupportedVersion': version},
    );
  }
  if (expectedVersion != null && version != expectedVersion) {
    throw SolanaError(SolanaErrorCode.offchainMessageUnexpectedVersion, {
      'actualVersion': version,
      'expectedVersion': expectedVersion,
    });
  }
}
