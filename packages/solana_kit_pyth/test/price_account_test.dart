import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_pyth/solana_kit_pyth.dart';
import 'package:test/test.dart';

const _publisherPattern = 0xEE;
const _productPattern = 0xCD;
const _nextPattern = 0xAB;

/// Builds a synthetic classic Pyth price account.
///
/// Layout documentation: see [decodePythPriceAccount].
Uint8List buildPriceAccount({
  int numComponentPrices = 1,
  int status = 1,
  int aggregatePrice = 1234000000,
  int aggregateConfidence = 60000,
  int aggregatePublishSlot = 1000,
  int timestamp = 1700000000,
}) {
  final totalSize = 240 + numComponentPrices * 96;
  final bytes = Uint8List(totalSize);
  final view = ByteData.sublistView(bytes);

  void setU32(int offset, int value) =>
      view.setUint32(offset, value, Endian.little);
  void setU64(int offset, int value) =>
      view.setUint64(offset, value, Endian.little);

  setU32(0, pythMagic); // magic
  setU32(4, 2); // version
  setU32(8, PythAccountType.price.value); // account type
  setU32(12, totalSize); // size
  setU32(16, PythPriceType.price.value); // price type
  view.setInt32(20, -8, Endian.little); // exponent
  setU32(24, numComponentPrices); // num component prices
  setU32(28, 2); // num quoters
  setU64(32, 100); // last slot
  setU64(40, 120); // valid slot
  setU64(48, 555); // ema price value component
  setU64(56, 999); // ema price numerator
  setU64(64, 11); // ema price denominator
  setU64(72, 6); // ema conf value component
  setU64(80, 77); // ema conf numerator
  setU64(88, 7); // ema conf denominator
  setU64(96, timestamp); // publish time
  bytes[104] = 3; // min publishers
  bytes[105] = 0; // message sent
  bytes[106] = 5; // max latency
  bytes[107] = 3; // flags: accumulatorV2 | messageBufferCleared
  view.setInt32(108, 777, Endian.little); // feed index
  bytes
    ..setAll(112, List.filled(32, _productPattern)) // product key
    ..setAll(144, List.filled(32, _nextPattern)); // next price key
  setU64(176, 119); // previous slot
  setU64(184, 1200000000); // previous price component
  setU64(192, 9); // previous confidence component
  setU64(200, 1699999000); // previous timestamp

  // Aggregate price info block.
  setU64(208, aggregatePrice);
  setU64(216, aggregateConfidence);
  setU32(224, status); // status
  setU32(228, 0); // corporate action
  setU64(232, aggregatePublishSlot); // publish slot

  // Publisher components.
  for (var i = 0; i < numComponentPrices; i++) {
    final base = 240 + i * 96;
    bytes.setAll(base, List.filled(32, _publisherPattern + i));
    setU64(base + 32, 1); // aggregate price component
    setU64(base + 40, 2); // aggregate confidence component
    setU32(base + 48, 1); // aggregate status
    setU64(base + 56, 995); // aggregate publish slot
    setU64(base + 64, 3); // latest price component
    setU64(base + 72, 4); // latest confidence component
    setU32(base + 80, 1); // latest status
    setU64(base + 88, 999); // latest publish slot
  }
  return bytes;
}

void main() {
  group('decodePythPriceAccount', () {
    test('decodes every header field', () {
      final account = decodePythPriceAccount(buildPriceAccount());
      expect(account.magic, pythMagic);
      expect(account.version, 2);
      expect(account.accountType, PythAccountType.price);
      expect(account.size, 240 + 96);
      expect(account.priceType, PythPriceType.price);
      expect(account.exponent, -8);
      expect(account.numComponentPrices, 1);
      expect(account.numQuoters, 2);
      expect(account.lastSlot, BigInt.from(100));
      expect(account.validSlot, BigInt.from(120));
      expect(account.emaPrice.valueComponent, BigInt.from(555));
      expect(account.emaPrice.numerator, BigInt.from(999));
      expect(account.emaPrice.denominator, BigInt.from(11));
      expect(account.emaConfidence.valueComponent, BigInt.from(6));
      expect(account.emaConfidence.numerator, BigInt.from(77));
      expect(account.emaConfidence.denominator, BigInt.from(7));
      expect(account.timestamp, BigInt.from(1700000000));
      expect(account.minPublishers, 3);
      expect(account.flags.accumulatorV2, isTrue);
      expect(account.flags.messageBufferCleared, isTrue);
      expect(account.feedIndex, 777);
    });

    test('decodes keys via the address codec', () {
      final account = decodePythPriceAccount(buildPriceAccount());
      expect(
        account.productAccountKey,
        getAddressCodec().decode(
          Uint8List.fromList(List<int>.filled(32, _productPattern)),
        ),
      );
      expect(
        account.nextPriceAccountKey,
        getAddressCodec().decode(
          Uint8List.fromList(List<int>.filled(32, _nextPattern)),
        ),
      );
    });

    test('decodes the aggregate and components', () {
      final account = decodePythPriceAccount(buildPriceAccount());
      expect(account.aggregate.priceComponent, BigInt.from(1234000000));
      expect(account.aggregate.confidenceComponent, BigInt.from(60000));
      expect(account.aggregate.status, PythPriceStatus.trading);
      expect(account.aggregate.publishSlot, BigInt.from(1000));
      expect(account.status, PythPriceStatus.trading);
      expect(account.previousSlot, BigInt.from(119));
      expect(account.previousPriceComponent, BigInt.from(1200000000));
      expect(account.previousConfidenceComponent, BigInt.from(9));
      expect(account.previousTimestamp, BigInt.from(1699999000));
      expect(account.priceComponents, hasLength(1));
      final component = account.priceComponents.single;
      expect(
        component.publisher,
        getAddressCodec().decode(
          Uint8List.fromList(List<int>.filled(32, _publisherPattern)),
        ),
      );
      expect(component.aggregate.priceComponent, BigInt.one);
      expect(component.latest.priceComponent, BigInt.from(3));
    });

    test('treats an all-zero next key as absent', () {
      final bytes = buildPriceAccount()..setAll(144, List.filled(32, 0));
      expect(decodePythPriceAccount(bytes).nextPriceAccountKey, isNull);
    });

    test('marks stale aggregates as unknown', () {
      final trading = decodePythPriceAccount(
        buildPriceAccount(),
        currentSlot: 1010,
      );
      expect(trading.status, PythPriceStatus.trading);
      final stale = decodePythPriceAccount(
        buildPriceAccount(),
        currentSlot: 1000 + pythMaxSlotDifference + 1,
      );
      expect(stale.status, PythPriceStatus.unknown);
      expect(stale.aggregate.status, PythPriceStatus.trading);
    });

    test('supports multiple components', () {
      final account = decodePythPriceAccount(
        buildPriceAccount(numComponentPrices: 3),
      );
      expect(account.numComponentPrices, 3);
      expect(account.priceComponents, hasLength(3));
      expect(
        account.priceComponents[2].publisher,
        getAddressCodec().decode(
          Uint8List.fromList(List<int>.filled(32, _publisherPattern + 2)),
        ),
      );
    });

    test('rejects wrong magic', () {
      final bytes = buildPriceAccount()..setAll(0, [0, 0, 0, 0]);
      expect(
        () => decodePythPriceAccount(bytes),
        throwsA(isA<PythDecodeException>()),
      );
    });

    test('rejects truncated component data', () {
      final bytes = buildPriceAccount(
        numComponentPrices: 2,
      ).sublist(0, 240 + 96 - 1);
      expect(
        () => decodePythPriceAccount(bytes),
        throwsA(isA<PythDecodeException>()),
      );
    });

    test('rejects short data', () {
      expect(
        () => decodePythPriceAccount(Uint8List(100)),
        throwsA(isA<PythDecodeException>()),
      );
    });

    test('rejects unsupported versions and non-price accounts', () {
      final wrongVersion = buildPriceAccount();
      ByteData.sublistView(wrongVersion).setUint32(4, 1, Endian.little);
      expect(
        () => decodePythPriceAccount(wrongVersion),
        throwsA(isA<PythDecodeException>()),
      );

      final wrongType = buildPriceAccount();
      ByteData.sublistView(wrongType).setUint32(8, 2, Endian.little);
      expect(
        () => decodePythPriceAccount(wrongType),
        throwsA(isA<PythDecodeException>()),
      );
    });
  });

  group('decodePriceUpdateV2Account', () {
    Uint8List buildAccount({bool partial = true}) {
      const feedIdPattern = 0x11;
      final bytes = Uint8List(8 + 32 + 2 + 84 + 8);
      final view = ByteData.sublistView(bytes);
      bytes
        ..setAll(0, [0x22, 0xf1, 0x23, 0x63, 0x9d, 0x7e, 0xf4, 0xcd])
        ..setAll(8, List.filled(32, 0x33)); // write authority
      var cursor = 40;
      bytes[cursor++] = partial ? 0 : 1; // verification level variant
      if (partial) {
        bytes[cursor++] = 5; // num signatures
      }
      bytes.setAll(cursor, List.filled(32, feedIdPattern)); // feed id
      cursor += 32;
      view.setInt64(cursor, 3000123456789, Endian.little); // price
      cursor += 8;
      view.setUint64(cursor, 48765432, Endian.little); // conf
      cursor += 8;
      view.setInt32(cursor, -8, Endian.little); // exponent
      cursor += 4;
      view.setInt64(cursor, 1700000000, Endian.little); // publish time
      cursor += 8;
      view.setInt64(cursor, 1699999900, Endian.little); // prev publish time
      cursor += 8;
      view.setInt64(cursor, 2999000000, Endian.little); // ema price
      cursor += 8;
      view.setUint64(cursor, 48650000, Endian.little); // ema conf
      cursor += 8;
      view.setUint64(cursor, 4242, Endian.little); // posted slot
      return bytes;
    }

    test('decodes a partially verified account', () {
      final account = decodePriceUpdateV2Account(buildAccount());
      expect(
        account.writeAuthority,
        getAddressCodec().decode(
          Uint8List.fromList(List<int>.filled(32, 0x33)),
        ),
      );
      expect(account.verificationLevel.isFull, isFalse);
      expect(account.verificationLevel.numSignatures, 5);
      expect(account.feedId, Uint8List.fromList(List<int>.filled(32, 0x11)));
      expect(account.feedIdHex, '11' * 32);
      expect(account.price, BigInt.from(3000123456789));
      expect(account.conf, BigInt.from(48765432));
      expect(account.exponent, -8);
      expect(account.publishTime, BigInt.from(1700000000));
      expect(account.prevPublishTime, BigInt.from(1699999900));
      expect(account.emaPrice, BigInt.from(2999000000));
      expect(account.emaConf, BigInt.from(48650000));
      expect(account.postedSlot, BigInt.from(4242));
    });

    test('decodes a fully verified account', () {
      final account = decodePriceUpdateV2Account(buildAccount(partial: false));
      expect(account.verificationLevel.isFull, isTrue);
      expect(account.verificationLevel.numSignatures, isNull);
    });

    test('rejects unknown verification level variants', () {
      final bytes = buildAccount()..[40] = 2;
      expect(
        () => decodePriceUpdateV2Account(bytes),
        throwsA(isA<PythDecodeException>()),
      );
    });

    test('rejects the wrong Anchor account discriminator', () {
      final bytes = buildAccount()..[0] ^= 0xff;
      expect(
        () => decodePriceUpdateV2Account(bytes),
        throwsA(isA<PythDecodeException>()),
      );
    });

    test('rejects short data', () {
      expect(
        () => decodePriceUpdateV2Account(Uint8List(50)),
        throwsA(isA<PythDecodeException>()),
      );
    });
  });

  group('PythAccountType.fromValue', () {
    test('resolves known values', () {
      expect(PythAccountType.fromValue(1), PythAccountType.mapping);
      expect(PythAccountType.fromValue(2), PythAccountType.product);
      expect(PythAccountType.fromValue(3), PythAccountType.price);
      expect(PythAccountType.fromValue(4), PythAccountType.test);
      expect(PythAccountType.fromValue(5), PythAccountType.permission);
    });

    test('maps unknown values to unknown', () {
      expect(PythAccountType.fromValue(0), PythAccountType.unknown);
      expect(PythAccountType.fromValue(99), PythAccountType.unknown);
    });
  });

  group('PythPriceStatus.fromValue', () {
    test('resolves known values', () {
      expect(PythPriceStatus.fromValue(1), PythPriceStatus.trading);
      expect(PythPriceStatus.fromValue(2), PythPriceStatus.halted);
      expect(PythPriceStatus.fromValue(3), PythPriceStatus.auction);
      expect(PythPriceStatus.fromValue(4), PythPriceStatus.ignored);
    });

    test('maps unknown values to unknown', () {
      expect(PythPriceStatus.fromValue(0), PythPriceStatus.unknown);
      expect(PythPriceStatus.fromValue(255), PythPriceStatus.unknown);
    });
  });

  group('PythPriceType.fromValue', () {
    test('resolves known and unknown values', () {
      expect(PythPriceType.fromValue(1), PythPriceType.price);
      expect(PythPriceType.fromValue(0), PythPriceType.unknown);
      expect(PythPriceType.fromValue(7), PythPriceType.unknown);
    });
  });

  group('price account model formatting', () {
    test('PythPriceInfo renders, compares, and hashes', () {
      final account = decodePythPriceAccount(buildPriceAccount());
      final aggregate = account.aggregate;
      expect(
        aggregate.toString(),
        startsWith('PythPriceInfo(priceComponent: 1234000000,'),
      );

      final same = decodePythPriceAccount(buildPriceAccount()).aggregate;
      expect(aggregate == same, isTrue);
      expect(aggregate.hashCode, same.hashCode);
      expect(aggregate.corporateAction, 0);
      expect(aggregate == aggregate, isTrue);

      final different = decodePythPriceAccount(
        buildPriceAccount(aggregatePrice: 42),
      ).aggregate;
      expect(aggregate == different, isFalse);
      expect(aggregate == Object(), isFalse);
    });

    test('PythEma renders, compares, and hashes', () {
      final account = decodePythPriceAccount(buildPriceAccount());
      final ema = account.emaPrice;
      expect(ema.toString(), startsWith('PythEma(valueComponent: 555,'));

      final same = decodePythPriceAccount(buildPriceAccount()).emaPrice;
      expect(ema == same, isTrue);
      expect(ema.hashCode, same.hashCode);
      expect(ema == ema, isTrue);
      expect(ema == Object(), isFalse);
    });

    test('PythPriceComponent renders, compares, and hashes', () {
      final account = decodePythPriceAccount(buildPriceAccount());
      final component = account.priceComponents.single;
      expect(
        component.toString(),
        startsWith('PythPriceComponent(publisher: '),
      );

      final same = decodePythPriceAccount(
        buildPriceAccount(),
      ).priceComponents.single;
      expect(component == same, isTrue);
      expect(component.hashCode, same.hashCode);
      expect(component == component, isTrue);
      expect(component == Object(), isFalse);
    });

    test('PythPriceFlags renders, compares, and hashes', () {
      final account = decodePythPriceAccount(buildPriceAccount());
      final flags = account.flags;
      expect(
        flags.toString(),
        'PythPriceFlags(accumulatorV2: true, messageBufferCleared: true)',
      );

      final same = decodePythPriceAccount(buildPriceAccount()).flags;
      expect(flags == same, isTrue);
      expect(flags.hashCode, same.hashCode);
      expect(flags == flags, isTrue);
      expect(flags == Object(), isFalse);
    });

    test('PythPriceAccount renders a debug representation', () {
      final account = decodePythPriceAccount(buildPriceAccount());
      expect(account.toString(), startsWith('PythPriceAccount(exponent: -8,'));
    });
  });

  group('PythVerificationLevel', () {
    test('full levels render and compare', () {
      final full = PythVerificationLevel.full();
      expect(full.isFull, isTrue);
      expect(full.numSignatures, isNull);
      expect(full.toString(), 'PythVerificationLevel.full');
      expect(full, PythVerificationLevel.full());
      expect(full.hashCode, PythVerificationLevel.full().hashCode);
      expect(full == full, isTrue);
      expect(full == PythVerificationLevel.partial(5), isFalse);
      expect(full == Object(), isFalse);
    });

    test('partial levels render and compare', () {
      final partial = PythVerificationLevel.partial(5);
      expect(partial.isFull, isFalse);
      expect(partial.numSignatures, 5);
      expect(partial.toString(), 'PythVerificationLevel.partial(5)');
      expect(partial, PythVerificationLevel.partial(5));
      expect(partial.hashCode, PythVerificationLevel.partial(5).hashCode);
      expect(partial == PythVerificationLevel.partial(4), isFalse);
      expect(partial == Object(), isFalse);
    });

    test('requires a signature count', () {
      expect(
        () => PythVerificationLevel.partial(null),
        throwsA(
          isA<PythDecodeException>().having(
            (e) => e.message,
            'message',
            'Partial verification level requires a signature count',
          ),
        ),
      );
    });
  });
}
