import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_pyth/src/exceptions.dart';

/// The magic number shared by every Pyth account
/// (`0xa1b2c3d4`); kept in sync with the on-chain program.
const int pythMagic = 0xa1b2c3d4;

/// The supported version of legacy Pyth price accounts.
const int pythAccountVersion = 2;

/// Anchor discriminator for the Pyth Receiver `PriceUpdateV2` account.
const List<int> priceUpdateV2Discriminator = [
  0x22,
  0xf1,
  0x23,
  0x63,
  0x9d,
  0x7e,
  0xf4,
  0xcd,
];

/// Number of slots that can pass before a publisher's price is no longer
/// included in the aggregate.
const int pythMaxSlotDifference = 25;

/// Type of a Pyth account (see [PythPriceAccount.accountType]).
enum PythAccountType {
  /// Unknown or uninitialized account type.
  unknown(0),

  /// A mapping account that links to product accounts.
  mapping(1),

  /// A product account with symbol metadata.
  product(2),

  /// A price account carrying price feed data.
  price(3),

  /// A test account.
  test(4),

  /// A permissions account.
  permission(5);

  const PythAccountType(this.value);

  /// The numeric account type used on chain.
  final int value;

  /// Resolves an account type value; unknown values map to
  /// [PythAccountType.unknown].
  static PythAccountType fromValue(int value) => switch (value) {
    1 => PythAccountType.mapping,
    2 => PythAccountType.product,
    3 => PythAccountType.price,
    4 => PythAccountType.test,
    5 => PythAccountType.permission,
    _ => PythAccountType.unknown,
  };
}

/// Status of a price aggregation.
enum PythPriceStatus {
  /// No price is currently available.
  unknown(0),

  /// The price is valid and actively updated.
  trading(1),

  /// Price updates are currently halted.
  halted(2),

  /// The price is in the middle of an aggregation auction.
  auction(3),

  /// The price is ignored (excluded from aggregation).
  ignored(4);

  const PythPriceStatus(this.value);

  /// The numeric status used on chain.
  final int value;

  /// Resolves a status value; unknown values map to
  /// [PythPriceStatus.unknown].
  static PythPriceStatus fromValue(int value) => switch (value) {
    1 => PythPriceStatus.trading,
    2 => PythPriceStatus.halted,
    3 => PythPriceStatus.auction,
    4 => PythPriceStatus.ignored,
    _ => PythPriceStatus.unknown,
  };
}

/// Whether an account holds a plain price or a derived value.
enum PythPriceType {
  /// Unknown price type.
  unknown(0),

  /// The account holds a regular price.
  price(1);

  const PythPriceType(this.value);

  /// The numeric price type used on chain.
  final int value;

  /// Resolves a price type value; unknown values map to
  /// [PythPriceType.unknown].
  static PythPriceType fromValue(int value) =>
      value == 1 ? PythPriceType.price : PythPriceType.unknown;
}

/// Corporate action marker of a price info block.
enum PythCorpAction {
  /// No corporate action happened.
  noCorpAct(0);

  const PythCorpAction(this.value);

  /// The numeric value used on chain.
  final int value;
}

/// One aggregate or component price sample.
class PythPriceInfo {
  const PythPriceInfo._({
    required this.priceComponent,
    required this.confidenceComponent,
    required this.status,
    required this.corporateAction,
    required this.publishSlot,
  });

  /// Decodes a 32-byte price info block at [offset].
  factory PythPriceInfo.fromBytes(Uint8List data, int offset) {
    final priceComponent = _readBigInt64(data, offset);
    final confidenceComponent = _readBigUint64(data, offset + 8);
    final statusValue = _readUint32(data, offset + 16);
    final corporateAction = _readUint32(data, offset + 20);
    final publishSlot = _readBigUint64(data, offset + 24);

    return PythPriceInfo._(
      priceComponent: BigInt.from(priceComponent),
      confidenceComponent: confidenceComponent,
      status: PythPriceStatus.fromValue(statusValue),
      corporateAction: corporateAction,
      publishSlot: publishSlot,
    );
  }

  /// The aggregate price component; scale by `10^exponent` of the parent
  /// price account.
  final BigInt priceComponent;

  /// The confidence interval around [priceComponent].
  final BigInt confidenceComponent;

  /// Status of this price sample.
  final PythPriceStatus status;

  /// Raw corporate action marker.
  final int corporateAction;

  /// Slot at which this price was published.
  final BigInt publishSlot;

  @override
  String toString() =>
      'PythPriceInfo(priceComponent: $priceComponent, '
      'confidenceComponent: $confidenceComponent, status: $status, '
      'publishSlot: $publishSlot)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PythPriceInfo &&
          priceComponent == other.priceComponent &&
          confidenceComponent == other.confidenceComponent &&
          status == other.status &&
          corporateAction == other.corporateAction &&
          publishSlot == other.publishSlot;

  @override
  int get hashCode => Object.hash(
    priceComponent,
    confidenceComponent,
    status,
    corporateAction,
    publishSlot,
  );
}

/// An exponential moving average of a price or confidence interval, stored as
/// a numerator/denominator pair.
class PythEma {
  const PythEma._({
    required this.valueComponent,
    required this.numerator,
    required this.denominator,
  });

  /// Decodes a 24-byte EMA block at [offset].
  factory PythEma.fromBytes(Uint8List data, int offset) {
    return PythEma._(
      valueComponent: BigInt.from(_readBigInt64(data, offset)),
      numerator: BigInt.from(_readBigInt64(data, offset + 8)),
      denominator: BigInt.from(_readBigInt64(data, offset + 16)),
    );
  }

  /// The current EMA value component; scale by `10^exponent`.
  final BigInt valueComponent;

  /// Numerator state used to compute the next EMA update.
  final BigInt numerator;

  /// Denominator state used to compute the next EMA update.
  final BigInt denominator;

  @override
  String toString() =>
      'PythEma(valueComponent: $valueComponent, '
      'numerator: $numerator, denominator: $denominator)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PythEma &&
          valueComponent == other.valueComponent &&
          numerator == other.numerator &&
          denominator == other.denominator;

  @override
  int get hashCode => Object.hash(valueComponent, numerator, denominator);
}

/// A publisher-specific price contribution: the publisher's key plus its
/// aggregate and latest price samples.
class PythPriceComponent {
  const PythPriceComponent._({
    required this.publisher,
    required this.aggregate,
    required this.latest,
  });

  /// The publisher address.
  final Address publisher;

  /// The publisher's contribution to the current aggregate.
  final PythPriceInfo aggregate;

  /// The publisher's most recent raw price.
  final PythPriceInfo latest;

  @override
  String toString() => 'PythPriceComponent(publisher: $publisher)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PythPriceComponent &&
          publisher == other.publisher &&
          aggregate == other.aggregate &&
          latest == other.latest;

  @override
  int get hashCode =>
      Object.hash(publisher, Object.hashAll([aggregate, latest]));
}

/// Feature flags stored in a price account.
class PythPriceFlags {
  const PythPriceFlags._({
    required this.accumulatorV2,
    required this.messageBufferCleared,
  });

  /// Whether the account is managed by the accumulator v2 pipeline.
  final bool accumulatorV2;

  /// Whether the message buffer has been cleared.
  final bool messageBufferCleared;

  @override
  String toString() =>
      'PythPriceFlags(accumulatorV2: $accumulatorV2, '
      'messageBufferCleared: $messageBufferCleared)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PythPriceFlags &&
          accumulatorV2 == other.accumulatorV2 &&
          messageBufferCleared == other.messageBufferCleared;

  @override
  int get hashCode => Object.hash(accumulatorV2, messageBufferCleared);
}

/// Decoded contents of a Pyth price account (classic Pyth oracle layout,
/// version 2).
///
/// This decoder mirrors `parsePriceData` from `@pythnetwork/client`; field
/// offsets follow the C layout of the on-chain program:
///
/// | offset | size | field                  |
/// | ------ | ---- | ---------------------- |
/// | 0      | 4    | magic (u32 LE)         |
/// | 4      | 4    | version (u32 LE)       |
/// | 8      | 4    | account type (u32 LE)  |
/// | 12     | 4    | size (u32 LE)          |
/// | 16     | 4    | price type (u32 LE)    |
/// | 20     | 4    | exponent (i32 LE)      |
/// | 24     | 4    | numComponentPrices     |
/// | 28     | 4    | numQuoters             |
/// | 32     | 8    | lastSlot (u64 LE)      |
/// | 40     | 8    | validSlot (u64 LE)     |
/// | 48     | 24   | emaPrice               |
/// | 72     | 24   | emaConfidence          |
/// | 96     | 8    | timestamp (i64 LE)     |
/// | 104    | 1    | minPublishers          |
/// | 105    | 1    | messageSent            |
/// | 106    | 1    | maxLatency             |
/// | 107    | 1    | flags                  |
/// | 108    | 4    | feedIndex (i32 LE)     |
/// | 112    | 32   | productAccountKey      |
/// | 144    | 32   | nextPriceAccountKey    |
/// | 176    | 8    | previousSlot           |
/// | 184    | 8    | previousPriceComponent |
/// | 192    | 8    | previousConfidence     |
/// | 200    | 8    | previousTimestamp      |
/// | 208    | 32   | aggregate price info   |
/// | 240    | n×96 | publisher components   |
class PythPriceAccount {
  const PythPriceAccount._({
    required this.magic,
    required this.version,
    required this.accountType,
    required this.size,
    required this.priceType,
    required this.exponent,
    required this.numComponentPrices,
    required this.numQuoters,
    required this.lastSlot,
    required this.validSlot,
    required this.emaPrice,
    required this.emaConfidence,
    required this.timestamp,
    required this.minPublishers,
    required this.flags,
    required this.feedIndex,
    required this.productAccountKey,
    required this.nextPriceAccountKey,
    required this.previousSlot,
    required this.previousPriceComponent,
    required this.previousConfidenceComponent,
    required this.previousTimestamp,
    required this.aggregate,
    required this.priceComponents,
    required this.status,
  });

  /// The account magic; always [pythMagic] for successfully decoded accounts.
  final int magic;

  /// The layout version of the account.
  final int version;

  /// The type of the account; [PythAccountType.price] for price accounts.
  final PythAccountType accountType;

  /// The used size of the account in bytes.
  final int size;

  /// Whether this account holds a price or a derived value.
  final PythPriceType priceType;

  /// The exponent to scale price and confidence components with.
  final int exponent;

  /// Number of publisher components attached to this account.
  final int numComponentPrices;

  /// Number of quoters that contributed to the aggregate.
  final int numQuoters;

  /// Slot of the last valid aggregate price.
  final BigInt lastSlot;

  /// Slot until which the aggregate price is valid.
  final BigInt validSlot;

  /// Exponential moving average of the price.
  final PythEma emaPrice;

  /// Exponential moving average of the confidence interval.
  final PythEma emaConfidence;

  /// Unix timestamp (in seconds) of the current aggregate price.
  final BigInt timestamp;

  /// Minimum number of publishers required for a trading status.
  final int minPublishers;

  /// Operational flags of the account.
  final PythPriceFlags flags;

  /// Globally immutable feed index used for publishing.
  final int feedIndex;

  /// The product (symbol metadata) account of this price feed.
  final Address productAccountKey;

  /// The next price account in the linked list, or `null`.
  final Address? nextPriceAccountKey;

  /// Valid slot of the previous update.
  final BigInt previousSlot;

  /// Aggregate price component of the previous update.
  final BigInt previousPriceComponent;

  /// Confidence component of the previous update.
  final BigInt previousConfidenceComponent;

  /// Unix timestamp (in seconds) of the previous update.
  final BigInt previousTimestamp;

  /// The current aggregate price sample.
  final PythPriceInfo aggregate;

  /// The publisher components, [numComponentPrices] entries.
  final List<PythPriceComponent> priceComponents;

  /// Effective status of the feed — the aggregate status, demoted to
  /// [PythPriceStatus.unknown] when the data is stale relative to the slot
  /// the account was read at (which the aggregate status never accounts for
  /// itself).
  final PythPriceStatus status;

  @override
  String toString() =>
      'PythPriceAccount(exponent: $exponent, status: $status, '
      'aggregate: $aggregate, timestamp: $timestamp)';
}

/// Decodes a Pyth price account.
///
/// Pass `currentSlot` (the slot the account was read at) to mark stale
/// aggregates as [PythPriceStatus.unknown] in the derived `status` field,
/// mirroring `parsePriceData(data, currentSlot)` upstream.
///
/// Throws a `PythDecodeException` when the data does not look like a Pyth
/// price account.
PythPriceAccount decodePythPriceAccount(Uint8List data, {int? currentSlot}) {
  const headerSize = 240;
  if (data.length < headerSize) {
    throw PythDecodeException(
      'Data is too short (${data.length} bytes) to be a Pyth price account',
    );
  }
  final magic = _readUint32(data, 0);
  if (magic != pythMagic) {
    throw PythDecodeException(
      'Unexpected Pyth magic 0x${magic.toRadixString(16)}',
    );
  }
  final version = _readUint32(data, 4);
  if (version != pythAccountVersion) {
    throw PythDecodeException(
      'Unsupported Pyth account version $version '
      '(expected $pythAccountVersion)',
    );
  }
  final accountTypeValue = _readUint32(data, 8);
  final accountType = PythAccountType.fromValue(accountTypeValue);
  if (accountType != PythAccountType.price) {
    throw PythDecodeException(
      'Unexpected Pyth account type $accountTypeValue (expected 3)',
    );
  }
  final size = _readUint32(data, 12);
  final priceType = PythPriceType.fromValue(_readUint32(data, 16));
  final exponent = ByteData.sublistView(
    data,
    20,
    24,
  ).getInt32(0, Endian.little);
  final numComponentPrices = _readUint32(data, 24);
  final numQuoters = _readUint32(data, 28);
  final lastSlot = _readBigUint64(data, 32);
  final validSlot = _readBigUint64(data, 40);
  final emaPrice = PythEma.fromBytes(data, 48);
  final emaConfidence = PythEma.fromBytes(data, 72);
  final timestamp = BigInt.from(_readBigInt64(data, 96));
  final minPublishers = data[104];
  final flagBits = data[107];
  final flags = PythPriceFlags._(
    accumulatorV2: (flagBits & (1 << 0)) != 0,
    messageBufferCleared: (flagBits & (1 << 1)) != 0,
  );
  final feedIndex = ByteData.sublistView(data, 108, 112).getInt32(
    0,
    Endian.little,
  );
  final productAccountKey = getAddressCodec().decode(
    Uint8List.sublistView(data, 112, 144),
  );
  final nextPriceAccountKey = _readAddressOrNull(
    Uint8List.sublistView(data, 144, 176),
  );
  final previousSlot = _readBigUint64(data, 176);
  final previousPriceComponent = BigInt.from(_readBigInt64(data, 184));
  final previousConfidenceComponent = _readBigUint64(data, 192);
  final previousTimestamp = BigInt.from(_readBigInt64(data, 200));
  final aggregate = PythPriceInfo.fromBytes(data, 208);

  var status = aggregate.status;
  if (currentSlot != null && status == PythPriceStatus.trading) {
    if (currentSlot - aggregate.publishSlot.toInt() > pythMaxSlotDifference) {
      status = PythPriceStatus.unknown;
    }
  }

  var offset = headerSize;
  final priceComponents = <PythPriceComponent>[];
  for (var i = 0; i < numComponentPrices; i++) {
    if (offset + 96 > data.length) {
      throw PythDecodeException(
        'Price component $i is truncated '
        '(of $numComponentPrices components)',
      );
    }
    priceComponents.add(
      PythPriceComponent._(
        publisher: getAddressCodec().decode(
          Uint8List.sublistView(data, offset, offset + 32),
        ),
        aggregate: PythPriceInfo.fromBytes(data, offset + 32),
        latest: PythPriceInfo.fromBytes(data, offset + 64),
      ),
    );
    offset += 96;
  }

  return PythPriceAccount._(
    magic: magic,
    version: version,
    accountType: accountType,
    size: size,
    priceType: priceType,
    exponent: exponent,
    numComponentPrices: numComponentPrices,
    numQuoters: numQuoters,
    lastSlot: lastSlot,
    validSlot: validSlot,
    emaPrice: emaPrice,
    emaConfidence: emaConfidence,
    timestamp: timestamp,
    minPublishers: minPublishers,
    flags: flags,
    feedIndex: feedIndex,
    productAccountKey: productAccountKey,
    nextPriceAccountKey: nextPriceAccountKey,
    previousSlot: previousSlot,
    previousPriceComponent: previousPriceComponent,
    previousConfidenceComponent: previousConfidenceComponent,
    previousTimestamp: previousTimestamp,
    aggregate: aggregate,
    priceComponents: priceComponents,
    status: status,
  );
}

/// The verification level recorded in a PriceUpdateV2 account.
class PythVerificationLevel {
  const PythVerificationLevel._(this.numSignatures);

  /// Creates a full verification level (Wormhole quorum reached).
  PythVerificationLevel.full() : this._(null);

  /// Creates a partial verification level with [numSignatures] signatures.
  PythVerificationLevel.partial(this.numSignatures) {
    if (numSignatures == null) {
      throw const PythDecodeException(
        'Partial verification level requires a signature count',
      );
    }
  }

  /// Number of guardian signatures that were checked, or `null` when the
  /// full Wormhole quorum was reached.
  final int? numSignatures;

  /// Whether the update was verified against the full guardian quorum.
  bool get isFull => numSignatures == null;

  @override
  String toString() => isFull
      ? 'PythVerificationLevel.full'
      : 'PythVerificationLevel.partial($numSignatures)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PythVerificationLevel && numSignatures == other.numSignatures;

  @override
  int get hashCode => Object.hash(PythVerificationLevel, numSignatures);
}

/// Decoded contents of a Pyth push oracle `PriceUpdateV2` account — the
/// long-lived price feed accounts maintained by the Pyth push oracle program.
class PriceUpdateV2Account {
  const PriceUpdateV2Account._({
    required this.writeAuthority,
    required this.verificationLevel,
    required this.feedId,
    required this.price,
    required this.conf,
    required this.exponent,
    required this.publishTime,
    required this.prevPublishTime,
    required this.emaPrice,
    required this.emaConf,
    required this.postedSlot,
  });

  /// Authority allowed to close or rewrite the account.
  final Address writeAuthority;

  /// How many guardian signatures were verified for this update.
  final PythVerificationLevel verificationLevel;

  /// The 32-byte price feed id.
  final Uint8List feedId;

  /// Price component; scale by `10^exponent`.
  final BigInt price;

  /// Confidence component; scale by `10^exponent`.
  final BigInt conf;

  /// Exponent for [price], [conf] and the EMA values.
  final int exponent;

  /// Unix timestamp (in seconds) of the price.
  final BigInt publishTime;

  /// Unix timestamp (in seconds) of the previous price.
  final BigInt prevPublishTime;

  /// EMA price component.
  final BigInt emaPrice;

  /// EMA confidence component.
  final BigInt emaConf;

  /// Solana slot at which the update was posted.
  final BigInt postedSlot;

  /// The feed id as a hex string (without a `0x` prefix).
  String get feedIdHex {
    final buffer = StringBuffer();
    for (final byte in feedId) {
      buffer.write(byte.toRadixString(16).padLeft(2, '0'));
    }
    return buffer.toString();
  }
}

/// Decodes an on-chain `PriceUpdateV2` account (push oracle price feed
/// account).
///
/// The account layout is Anchor borsh (little-endian), appended after the
/// 8-byte account discriminator: `writeAuthority` (32 bytes),
/// `verificationLevel` (1-byte enum variant, plus one u8 for the partial
/// signature count), `priceMessage` ([PriceUpdateV2Account] feed and price
/// fields), and `postedSlot` (u64).
///
/// Throws a [PythDecodeException] when the data is too short or malformed.
PriceUpdateV2Account decodePriceUpdateV2Account(Uint8List data) {
  const discriminatorSize = 8;
  const authoritySize = 32;
  const messageSize = 84;
  const minimumSize = discriminatorSize + authoritySize + 2 + messageSize + 8;
  if (data.length < minimumSize) {
    throw PythDecodeException(
      'Data is too short (${data.length} bytes) to be a PriceUpdateV2 account',
    );
  }
  for (var i = 0; i < priceUpdateV2Discriminator.length; i++) {
    if (data[i] != priceUpdateV2Discriminator[i]) {
      throw const PythDecodeException(
        'Unexpected PriceUpdateV2 account discriminator',
      );
    }
  }
  var cursor = discriminatorSize;
  final writeAuthority = getAddressCodec().decode(
    Uint8List.sublistView(data, cursor, cursor + authoritySize),
  );
  cursor += authoritySize;

  final verificationVariant = data[cursor];
  cursor += 1;
  if (verificationVariant > 1) {
    throw PythDecodeException(
      'Unknown verification level variant $verificationVariant',
    );
  }
  final verificationLevel = verificationVariant == 0
      ? PythVerificationLevel.partial(data[cursor])
      : PythVerificationLevel.full();
  if (verificationVariant == 0) {
    cursor += 1;
  }

  final feedId = Uint8List.sublistView(data, cursor, cursor + 32);
  cursor += 32;
  final price = BigInt.from(_readBigInt64(data, cursor));
  cursor += 8;
  final conf = _readBigUint64(data, cursor);
  cursor += 8;
  final exponent = ByteData.sublistView(
    data,
    cursor,
    cursor + 4,
  ).getInt32(0, Endian.little);
  cursor += 4;
  final publishTime = BigInt.from(_readBigInt64(data, cursor));
  cursor += 8;
  final prevPublishTime = BigInt.from(_readBigInt64(data, cursor));
  cursor += 8;
  final emaPrice = BigInt.from(_readBigInt64(data, cursor));
  cursor += 8;
  final emaConf = _readBigUint64(data, cursor);
  cursor += 8;
  final postedSlot = _readBigUint64(data, cursor);

  return PriceUpdateV2Account._(
    writeAuthority: writeAuthority,
    verificationLevel: verificationLevel,
    feedId: feedId,
    price: price,
    conf: conf,
    exponent: exponent,
    publishTime: publishTime,
    prevPublishTime: prevPublishTime,
    emaPrice: emaPrice,
    emaConf: emaConf,
    postedSlot: postedSlot,
  );
}

Address? _readAddressOrNull(Uint8List bytes) {
  var isZero = true;
  for (final byte in bytes) {
    if (byte != 0) {
      isZero = false;
      break;
    }
  }
  return isZero ? null : getAddressCodec().decode(bytes);
}

int _readUint32(Uint8List bytes, int offset) =>
    ByteData.sublistView(bytes, offset, offset + 4).getUint32(0, Endian.little);

BigInt _readBigUint64(Uint8List bytes, int offset) {
  final data = ByteData.sublistView(bytes, offset, offset + 8);

  // Reading two halves avoids converting an unsigned u64 through a signed int.
  return (BigInt.from(data.getUint32(4, Endian.little)) << 32) |
      BigInt.from(data.getUint32(0, Endian.little));
}

int _readBigInt64(Uint8List bytes, int offset) =>
    ByteData.sublistView(bytes, offset, offset + 8).getInt64(0, Endian.little);
