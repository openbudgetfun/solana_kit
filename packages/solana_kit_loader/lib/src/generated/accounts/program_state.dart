// ignore_for_file: public_member_api_docs

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

const programStateAccountSize = 48;

enum LoaderV4Status { retracted, deployed, finalized }

@immutable
class ProgramStateAccount {
  const ProgramStateAccount({
    required this.slot,
    required this.authorityAddressOrNextVersion,
    required this.status,
  });

  final BigInt slot;
  final Address authorityAddressOrNextVersion;
  final LoaderV4Status status;

  @override
  bool operator ==(Object other) =>
      other is ProgramStateAccount &&
      other.slot == slot &&
      other.authorityAddressOrNextVersion == authorityAddressOrNextVersion &&
      other.status == status;

  @override
  int get hashCode => Object.hash(slot, authorityAddressOrNextVersion, status);

  @override
  String toString() =>
      'ProgramStateAccount(slot: $slot, '
      'authorityAddressOrNextVersion: $authorityAddressOrNextVersion, '
      'status: $status)';
}

Encoder<LoaderV4Status> getLoaderV4StatusEncoder() =>
    transformEncoder(getU8Encoder(), (LoaderV4Status value) => value.index);

Decoder<LoaderV4Status> getLoaderV4StatusDecoder() => transformDecoder(
  getU8Decoder(),
  (int value, _, _) => LoaderV4Status.values[value],
);

Codec<LoaderV4Status, LoaderV4Status> getLoaderV4StatusCodec() =>
    combineCodec(getLoaderV4StatusEncoder(), getLoaderV4StatusDecoder());

Encoder<ProgramStateAccount> getProgramStateAccountEncoder() =>
    FixedSizeEncoder<ProgramStateAccount>(
      fixedSize: programStateAccountSize,
      write: (value, bytes, offset) {
        var cursor = offset;
        cursor = getU64Encoder().write(value.slot, bytes, cursor);
        cursor = getAddressEncoder().write(
          value.authorityAddressOrNextVersion,
          bytes,
          cursor,
        );
        cursor = getLoaderV4StatusEncoder().write(value.status, bytes, cursor);
        bytes.setRange(cursor, cursor + 7, Uint8List(7));
        return cursor + 7;
      },
    );

Decoder<ProgramStateAccount> getProgramStateAccountDecoder() =>
    FixedSizeDecoder<ProgramStateAccount>(
      fixedSize: programStateAccountSize,
      read: (bytes, offset) {
        var cursor = offset;
        final slot = getU64Decoder().read(bytes, cursor);
        cursor = slot.$2;
        final authority = getAddressDecoder().read(bytes, cursor);
        cursor = authority.$2;
        final status = getLoaderV4StatusDecoder().read(bytes, cursor);
        cursor = status.$2 + 7;
        return (
          ProgramStateAccount(
            slot: slot.$1,
            authorityAddressOrNextVersion: authority.$1,
            status: status.$1,
          ),
          cursor,
        );
      },
    );

Codec<ProgramStateAccount, ProgramStateAccount> getProgramStateAccountCodec() =>
    combineCodec(
      getProgramStateAccountEncoder(),
      getProgramStateAccountDecoder(),
    );
