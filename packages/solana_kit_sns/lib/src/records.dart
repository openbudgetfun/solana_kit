/// Derivation and decoding of SNS domain records.
///
/// SNS domains can carry typed records (V1 and the SNS-IP 1 V2 layout):
///
/// - **V1** record accounts are name accounts derived with the `\x01` label
///   prefix under the owning domain, with no class seed.
/// - **V2** record accounts are name accounts derived with the `\x02` label
///   prefix under the owning domain, using the
///   [centralStateSnsRecordsAddress] (`CENTRAL_STATE_SNS_RECORDS`) as the
///   class seed. Their data section starts with an 8-byte header describing
///   staleness and Right-of-Association validation, followed by the
///   validation identifiers and the record content.
///
/// Both derivations mirror `getRecordV1Address` / `getRecordV2Address` from
/// the TypeScript SDK (`js-kit/src/record`) and are byte-identical to the
/// `getRecordKey` primitive published in `@bonfida/sns-records`.
library;

import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';

import 'package:solana_kit_sns/src/domain_key.dart';
import 'package:solana_kit_sns/src/hash.dart';
import 'package:solana_kit_sns/src/program_address.dart';
import 'package:solana_kit_sns/src/registry.dart';

/// The supported SNS record identifiers.
///
/// The values match the `Record` enum of the TypeScript SDK
/// (`js-kit/src/types/record.ts`); the Dart name mirrors the TypeScript key.
enum SnsRecord {
  /// An IPFS content hash.
  ipfs('IPFS'),

  /// An Arweave transaction identifier.
  arwv('ARWV'),

  /// A Solana wallet address.
  sol('SOL'),

  /// An Ethereum wallet address.
  eth('ETH'),

  /// A Bitcoin wallet address.
  btc('BTC'),

  /// A Litecoin wallet address.
  ltc('LTC'),

  /// A Dogecoin wallet address.
  doge('DOGE'),

  /// An email address.
  email('email'),

  /// A URL.
  url('url'),

  /// A Discord handle.
  discord('discord'),

  /// A GitHub username.
  github('github'),

  /// A Reddit username.
  reddit('reddit'),

  /// A Twitter handle.
  twitter('twitter'),

  /// A Telegram handle.
  telegram('telegram'),

  /// A profile picture URL.
  pic('pic'),

  /// A Shadow Drive identifier.
  shdw('SHDW'),

  /// A POINT network identifier.
  point('POINT'),

  /// A BNB Smart Chain wallet address.
  bsc('BSC'),

  /// An Injective wallet address.
  injective('INJ'),

  /// A Backpack wallet identifier.
  backpack('backpack'),

  /// An IPv4 DNS A record (raw 4-byte address).
  a('A'),

  /// An IPv6 DNS AAAA record (raw 16-byte address).
  aaaa('AAAA'),

  /// A DNS canonical-name record.
  cname('CNAME'),

  /// A free-form DNS TXT record.
  txt('TXT'),

  /// A 32-byte avatar background image.
  background('background'),

  /// A Base wallet address.
  base('BASE'),

  /// An IPNS content identifier.
  ipns('IPNS'),

  /// A free-form biography string.
  bio('bio');

  const SnsRecord(this.label);

  /// The record label as used on chain, e.g. `'url'`.
  final String label;
}

/// The validation modes encoded in an SNS V2 record header.
enum SnsValidation {
  /// No validation identifier is present.
  none(0),

  /// A 32-byte Solana address validation identifier.
  solana(1),

  /// A 20-byte Ethereum address validation identifier.
  ethereum(2),

  /// A 32-byte, self-reported Solana address validation identifier.
  unverifiedSolana(3);

  const SnsValidation(this.value);

  /// The u16 value stored in the record header.
  final int value;

  /// The byte length of the corresponding validation identifier.
  int get identifierLength => switch (this) {
    none => 0,
    ethereum => 20,
    solana || unverifiedSolana => 32,
  };

  /// The validation for a raw header value.
  ///
  /// Throws an [ArgumentError] for values that are not part of the enum,
  /// mirroring the `InvalidValidationError` of the TypeScript SDK.
  static SnsValidation fromValue(int value) => switch (value) {
    0 => none,
    1 => solana,
    2 => ethereum,
    3 => unverifiedSolana,
    _ => throw ArgumentError.value(value, 'value', 'Invalid validation mode'),
  };
}

/// The byte length of the V2 record header.
const int recordHeaderLength = 8;

/// The offset of the record header inside a V2 record account.
///
/// The first 96 bytes of the account are the name-registry header of the
/// record account itself (see [nameRegistryHeaderLength]).
const int recordDataOffset = nameRegistryHeaderLength;

/// The decoded header of an SNS V2 record account.
class SnsRecordHeader {
  /// Creates a record header.
  const SnsRecordHeader({
    required this.stalenessValidation,
    required this.rightOfAssociationValidation,
    required this.contentLength,
  });

  /// The staleness validation mode.
  final SnsValidation stalenessValidation;

  /// The Right-of-Association validation mode.
  final SnsValidation rightOfAssociationValidation;

  /// The byte length of the record content.
  final int contentLength;
}

/// Returns the encoder for an SNS V2 record header.
FixedSizeEncoder<SnsRecordHeader> getSnsRecordHeaderEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('stalenessValidation', getU16Encoder()),
    ('rightOfAssociationValidation', getU16Encoder()),
    ('contentLength', getU32Encoder()),
  ]);

  return FixedSizeEncoder<SnsRecordHeader>(
    fixedSize: recordHeaderLength,
    write: (value, bytes, offset) {
      return structEncoder.write(
        <String, Object?>{
          'stalenessValidation': value.stalenessValidation.value,
          'rightOfAssociationValidation':
              value.rightOfAssociationValidation.value,
          'contentLength': value.contentLength,
        },
        bytes,
        offset,
      );
    },
  );
}

/// Returns the decoder for an SNS V2 record header.
FixedSizeDecoder<SnsRecordHeader> getSnsRecordHeaderDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('stalenessValidation', getU16Decoder()),
    ('rightOfAssociationValidation', getU16Decoder()),
    ('contentLength', getU32Decoder()),
  ]);

  return FixedSizeDecoder<SnsRecordHeader>(
    fixedSize: recordHeaderLength,
    read: (bytes, offset) {
      final (struct, end) = structDecoder.read(bytes, offset);
      final header = SnsRecordHeader(
        stalenessValidation: SnsValidation.fromValue(
          struct['stalenessValidation']! as int,
        ),
        rightOfAssociationValidation: SnsValidation.fromValue(
          struct['rightOfAssociationValidation']! as int,
        ),
        contentLength: struct['contentLength']! as int,
      );
      return (header, end);
    },
  );
}

/// Returns the codec for an SNS V2 record header.
FixedSizeCodec<SnsRecordHeader, SnsRecordHeader> getSnsRecordHeaderCodec() {
  return combineCodec(
        getSnsRecordHeaderEncoder(),
        getSnsRecordHeaderDecoder(),
      )
      as FixedSizeCodec<SnsRecordHeader, SnsRecordHeader>;
}

/// The decoded payload of an SNS V2 record account.
class SnsRecordV2 {
  /// Creates a decoded V2 record.
  const SnsRecordV2({required this.header, required this.data});

  /// Deserializes a V2 record account from its full account [data].
  ///
  /// The first 96 bytes are the name-registry header of the record account
  /// itself and are skipped, mirroring `RecordState.deserialize` in the
  /// TypeScript SDK.
  factory SnsRecordV2.deserialize(Uint8List data) {
    if (data.length < recordDataOffset + recordHeaderLength) {
      throw ArgumentError('Record account data is too short');
    }
    final (header, end) = getSnsRecordHeaderDecoder().read(
      data,
      recordDataOffset,
    );
    return SnsRecordV2(header: header, data: data.sublist(end));
  }

  /// The record header.
  final SnsRecordHeader header;

  /// The validation identifiers and record content.
  final Uint8List data;

  /// The staleness validation identifier, or an empty byte array.
  Uint8List get stalenessId => data.sublist(
    0,
    header.stalenessValidation.identifierLength,
  );

  /// The Right-of-Association validation identifier, or an empty byte array.
  Uint8List get roaId => data.sublist(
    header.stalenessValidation.identifierLength,
    header.stalenessValidation.identifierLength +
        header.rightOfAssociationValidation.identifierLength,
  );

  /// The record content.
  Uint8List get content {
    final startOffset =
        header.stalenessValidation.identifierLength +
        header.rightOfAssociationValidation.identifierLength;
    final endOffset = startOffset + header.contentLength;
    if (endOffset > data.length) {
      throw ArgumentError.value(
        this,
        'record',
        'Record content length exceeds account data',
      );
    }
    return data.sublist(startOffset, endOffset);
  }
}

/// Derives the address of a V1 record account.
///
/// The record label is derived as a `\x01`-prefixed record of the TLD-trimmed
/// [domain], mirroring `getRecordV1Address` of the TypeScript SDK.
///
/// ## Example
///
/// ```dart
/// final address = await findRecordV1Address(
///   domain: 'bonfida',
///   record: SnsRecord.url,
/// );
/// ```
Future<Address> findRecordV1Address({
  required String domain,
  required SnsRecord record,
}) async {
  final key = await findDomainKey(
    '${record.label}.$domain',
    record: SnsRecordVersion.v1,
  );
  return key.address;
}

/// Derives the address of a V2 (SNS-IP 1) record account.
///
/// The record label is derived as a `\x02`-prefixed record of the TLD-trimmed
/// [domain] with the records central state as class seed, mirroring
/// `getRecordV2Address` of the TypeScript SDK. Subdomains are supported: pass
/// the full subdomain, e.g. `domain: 'dex.bonfida'`.
///
/// ## Example
///
/// ```dart
/// final address = await findRecordV2Address(
///   domain: 'bonfida',
///   record: SnsRecord.sol,
/// );
/// ```
Future<Address> findRecordV2Address({
  required String domain,
  required SnsRecord record,
}) async {
  final domainKey = await findDomainKey(domain);
  final hash = getHashedName(
    String.fromCharCode(SnsRecordVersion.v2.prefixByte) + record.label,
  );
  return findNameAccountKey(
    hash,
    classAddress: centralStateSnsRecordsAddressObject,
    parentAddress: domainKey.address,
  );
}

/// The record identifiers whose V2 content is UTF-8 encoded
/// (`UTF8_ENCODED_RECORDS` in the TypeScript SDK).
const Set<SnsRecord> _utf8EncodedRecords = {
  SnsRecord.arwv,
  SnsRecord.backpack,
  SnsRecord.btc,
  SnsRecord.cname,
  SnsRecord.discord,
  SnsRecord.doge,
  SnsRecord.email,
  SnsRecord.github,
  SnsRecord.ipfs,
  SnsRecord.ipns,
  SnsRecord.ltc,
  SnsRecord.pic,
  SnsRecord.point,
  SnsRecord.reddit,
  SnsRecord.shdw,
  SnsRecord.telegram,
  SnsRecord.twitter,
  SnsRecord.txt,
  SnsRecord.url,
  SnsRecord.bio,
};

/// The record identifiers whose V2 content is a `0x`-prefixed EVM address.
const Set<SnsRecord> _evmRecords = {
  SnsRecord.base,
  SnsRecord.bsc,
  SnsRecord.eth,
};

/// Decodes V2 record [content] to a human-readable value.
///
/// Supported record types:
///
/// - UTF-8 records ([_utf8EncodedRecords]): decoded as UTF-8 text.
/// - [SnsRecord.sol]: decoded as a base58 Solana address.
/// - EVM records ([_evmRecords]): rendered as a `0x`-prefixed hex string.
///
/// Other record types (Injective bech32 addresses, raw IP addresses,
/// backgrounds) throw an [ArgumentError]; this package does not implement
/// bech32 or punycode content decoding.
String decodeRecordContent({
  required Uint8List content,
  required SnsRecord record,
}) {
  if (_utf8EncodedRecords.contains(record)) {
    return getUtf8Decoder().decode(content);
  }
  if (record == SnsRecord.sol) {
    return getAddressDecoder().decode(content).value;
  }
  if (_evmRecords.contains(record)) {
    final hex = content.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '0x$hex';
  }
  throw ArgumentError.value(record, 'record', 'Unsupported record type');
}

/// Serializes [content] for a V2 record.
///
/// Supported record types mirror [decodeRecordContent]:
///
/// - UTF-8 records ([_utf8EncodedRecords]): encoded as UTF-8 text.
/// - [SnsRecord.sol]: a base58-encoded Solana address.
/// - EVM records ([_evmRecords]): a `0x`-prefixed hex string.
Uint8List encodeRecordContent({
  required String content,
  required SnsRecord record,
}) {
  if (_utf8EncodedRecords.contains(record)) {
    return getUtf8Encoder().encode(content);
  }
  if (record == SnsRecord.sol) {
    return getAddressEncoder().encode(address(content));
  }
  if (_evmRecords.contains(record)) {
    if (content.length != 42 || !content.startsWith('0x')) {
      throw ArgumentError.value(
        content,
        'content',
        'EVM record content must be a 0x-prefixed 20-byte address',
      );
    }
    final bytes = Uint8List(20);
    for (var i = 0; i < 20; i++) {
      bytes[i] = int.parse(content.substring(2 + i * 2, 4 + i * 2), radix: 16);
    }
    return bytes;
  }
  throw ArgumentError.value(record, 'record', 'Unsupported record type');
}
