// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_accounts/solana_kit_accounts.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';

import '../types/proposal_status.dart';

@immutable
class Proposal {
  Proposal({
    required this.multisig,
    required this.transactionIndex,
    required this.status,
    required this.bump,
    required this.approved,
    required this.rejected,
    required this.cancelled,
  }) : discriminator = Uint8List.fromList([
         0x1a,
         0x5e,
         0xbd,
         0xbb,
         0x74,
         0x88,
         0x35,
         0x21,
       ]);

  final Uint8List discriminator;
  final Address multisig;
  final BigInt transactionIndex;
  final ProposalStatus status;
  final int bump;
  final List<Address> approved;
  final List<Address> rejected;
  final List<Address> cancelled;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Proposal &&
          runtimeType == other.runtimeType &&
          discriminator == other.discriminator &&
          multisig == other.multisig &&
          transactionIndex == other.transactionIndex &&
          status == other.status &&
          bump == other.bump &&
          approved == other.approved &&
          rejected == other.rejected &&
          cancelled == other.cancelled;

  @override
  int get hashCode => Object.hash(
    discriminator,
    multisig,
    transactionIndex,
    status,
    bump,
    approved,
    rejected,
    cancelled,
  );

  @override
  String toString() =>
      'Proposal(discriminator: $discriminator, multisig: $multisig, transactionIndex: $transactionIndex, status: $status, bump: $bump, approved: $approved, rejected: $rejected, cancelled: $cancelled)';
}

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

Encoder<Proposal> getProposalEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    (
      'discriminator',
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false),
    ),
    ('multisig', getAddressEncoder()),
    ('transactionIndex', getU64Encoder()),
    ('status', getProposalStatusEncoder()),
    ('bump', getU8Encoder()),
    (
      'approved',
      getArrayEncoder(
        transformEncoder(getAddressEncoder(), (Address value) => value),
      ),
    ),
    (
      'rejected',
      getArrayEncoder(
        transformEncoder(getAddressEncoder(), (Address value) => value),
      ),
    ),
    (
      'cancelled',
      getArrayEncoder(
        transformEncoder(getAddressEncoder(), (Address value) => value),
      ),
    ),
  ]);

  return transformEncoder(
    structEncoder,
    (Proposal value) => <String, Object?>{
      'discriminator': Uint8List.fromList([
        0x1a,
        0x5e,
        0xbd,
        0xbb,
        0x74,
        0x88,
        0x35,
        0x21,
      ]),
      'multisig': value.multisig,
      'transactionIndex': value.transactionIndex,
      'status': value.status,
      'bump': value.bump,
      'approved': value.approved,
      'rejected': value.rejected,
      'cancelled': value.cancelled,
    },
  );
}

Decoder<Proposal> getProposalDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', fixDecoderSize(getBytesDecoder(), 8)),
    ('multisig', getAddressDecoder()),
    ('transactionIndex', getU64Decoder()),
    ('status', getProposalStatusDecoder()),
    ('bump', getU8Decoder()),
    ('approved', getArrayDecoder(getAddressDecoder())),
    ('rejected', getArrayDecoder(getAddressDecoder())),
    ('cancelled', getArrayDecoder(getAddressDecoder())),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'proposal account decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (Proposal, int) readTopLevel(Uint8List bytes, int offset) {
    getConstantDecoder(
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false).encode(
        Uint8List.fromList([0x1a, 0x5e, 0xbd, 0xbb, 0x74, 0x88, 0x35, 0x21]),
      ),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);

    return (
      Proposal(
        multisig: map['multisig']! as Address,
        transactionIndex: map['transactionIndex']! as BigInt,
        status: map['status']! as ProposalStatus,
        bump: map['bump']! as int,
        approved: map['approved']! as List<Address>,
        rejected: map['rejected']! as List<Address>,
        cancelled: map['cancelled']! as List<Address>,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() => FixedSizeDecoder<Proposal>(
      fixedSize: structDecoder.fixedSize,
      read: (bytes, offset) {
        final bytesLength = bytes.length - offset;
        if (bytesLength < structDecoder.fixedSize) {
          throwInvalidByteLength(structDecoder.fixedSize, bytesLength);
        }
        return readTopLevel(bytes, offset);
      },
    ),
    VariableSizeDecoder<Map<String, Object?>>() =>
      VariableSizeDecoder<Proposal>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<Proposal, Proposal> getProposalCodec() {
  return combineCodec(getProposalEncoder(), getProposalDecoder());
}

Account<Proposal> decodeProposal(EncodedAccount encodedAccount) {
  return decodeAccount(encodedAccount, getProposalDecoder());
}
