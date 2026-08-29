import 'package:solana_kit_pyth/solana_kit_pyth.dart';
import 'package:test/test.dart';

void main() {
  group('HermesPrice', () {
    test('decodes price/conf strings into bigints', () {
      final price = HermesPrice.fromJson({
        'price': '304001500',
        'conf': '30400150',
        'expo': -8,
        'publish_time': 1700000000,
      });
      expect(price.price, BigInt.from(304001500));
      expect(price.conf, BigInt.from(30400150));
      expect(price.expo, -8);
      expect(price.publishTime, 1700000000);
    });

    test('supports value equality', () {
      final price = HermesPrice(
        price: BigInt.one,
        conf: BigInt.two,
        expo: -6,
        publishTime: 1,
      );
      expect(
        price,
        equals(
          HermesPrice.fromJson(const {
            'price': '1',
            'conf': '2',
            'expo': -6,
            'publish_time': 1,
          }),
        ),
      );
    });
  });

  group('HermesPriceFeed', () {
    final fixture = <String, Object?>{
      'id':
          '0xff61491a931112ddf1bd8147cd1b641375f79f5825126d665480874634fd0ace',
      'price': {
        'conf': '30400150',
        'expo': -8,
        'price': '3040015000',
        'publish_time': 1700000000,
      },
      'ema_price': {
        'conf': '100',
        'expo': -8,
        'price': '3030000000',
        'publish_time': 1700000001,
      },
      'metadata': {
        'slot': 12345,
        'prev_publish_time': 1699999900,
        'proof_available_time': 1700000100,
      },
    };

    test('decodes a parsed feed', () {
      final feed = HermesPriceFeed.fromJson(fixture);
      expect(feed.id, fixture['id']);
      expect(feed.price.price, BigInt.from(3040015000));
      expect(feed.price.publishTime, 1700000000);
      expect(feed.emaPrice.price, BigInt.from(3030000000));
      expect(feed.metadata?.slot, 12345);
      expect(feed.metadata?.prevPublishTime, 1699999900);
      expect(feed.metadata?.proofAvailableTime, 1700000100);
    });

    test('metadata is optional', () {
      final feed = HermesPriceFeed.fromJson({
        ...fixture,
        'metadata': null,
      });
      expect(feed.metadata, isNull);
    });
  });

  group('HermesPriceUpdate', () {
    test('decodes binary + parsed response', () {
      final update = HermesPriceUpdate.fromJson(const {
        'binary': {
          'data': ['AnU='],
          'encoding': 'base64',
        },
        'parsed': [
          {
            'id': 'feed-1',
            'price': {
              'price': '100',
              'conf': '5',
              'expo': -2,
              'publish_time': 1700000000,
            },
            'ema_price': {
              'price': '99',
              'conf': '4',
              'expo': -2,
              'publish_time': 1700000001,
            },
          },
        ],
      });
      expect(update.binaryEncoding, HermesEncoding.base64);
      expect(update.binaryData, ['AnU=']);
      expect(update.parsed, hasLength(1));
      expect(update.parsed!.single.id, 'feed-1');
      expect(update.parsed!.single.price.price, BigInt.from(100));
    });

    test('decodes response without parsed field', () {
      final update = HermesPriceUpdate.fromJson(const {
        'binary': {
          'data': ['de', 'ad'],
          'encoding': 'hex',
        },
      });
      expect(update.binaryEncoding, HermesEncoding.hex);
      expect(update.binaryData, ['de', 'ad']);
      expect(update.parsed, isNull);
    });

    test('value equality includes parsed feeds', () {
      const raw = {
        'binary': {
          'data': ['AA=='],
          'encoding': 'base64',
        },
      };
      expect(HermesPriceUpdate.fromJson(raw), HermesPriceUpdate.fromJson(raw));
    });
  });

  group('HermesPriceFeedMetadata', () {
    test('decodes a price_feeds entry', () {
      final metadata = HermesPriceFeedMetadata.fromJson(const {
        'asset_type': 'crypto',
        'attributes': {
          'country': 'US',
          'display_symbol': 'BTC_USDT',
        },
        'base': 'BTC',
        'description': 'Bitcoin / United States Dollar',
        'display_symbol': null,
        'generic_symbol': 'BTCUSD',
        'id': 'feed-abc',
        'quote': 'USDT',
        'symbol': 'BTC/USDT',
      });
      expect(metadata.id, 'feed-abc');
      expect(metadata.base, 'BTC');
      expect(metadata.quote, 'USDT');
      expect(metadata.symbol, 'BTC/USDT');
      expect(metadata.assetType, 'crypto');
      expect(metadata.attributes['country'], 'US');
    });

    test('id is required', () {
      expect(
        () => HermesPriceFeedMetadata.fromJson(const {'symbol': 'BTC/USD'}),
        throwsArgumentError,
      );
    });
  });

  group('HermesPrice formatting', () {
    test('asDouble scales with a positive exponent', () {
      final price = HermesPrice(
        price: BigInt.from(150),
        conf: BigInt.one,
        expo: 2,
        publishTime: 1,
      );
      expect(price.asDouble, 15000.0);
    });

    test('asDouble leaves a zero exponent unchanged', () {
      final price = HermesPrice(
        price: BigInt.from(12345),
        conf: BigInt.one,
        expo: 0,
        publishTime: 1,
      );
      expect(price.asDouble, 12345.0);
    });

    test('asDouble scales with a negative exponent', () {
      final price = HermesPrice.fromJson(const {
        'price': '3040015000',
        'conf': '1',
        'expo': -8,
        'publish_time': 1,
      });
      expect(price.asDouble, closeTo(30.40015, 1e-9));
    });

    test('renders a debug representation', () {
      final price = HermesPrice(
        price: BigInt.from(150),
        conf: BigInt.from(3),
        expo: 2,
        publishTime: 7,
      );
      expect(
        price.toString(),
        'HermesPrice(price: 150, conf: 3, expo: 2, publishTime: 7)',
      );
    });

    test('value equality covers every field and hashCode agreement', () {
      final price = HermesPrice(
        price: BigInt.from(150),
        conf: BigInt.from(3),
        expo: 2,
        publishTime: 7,
      );
      final same = HermesPrice(
        price: BigInt.from(150),
        conf: BigInt.from(3),
        expo: 2,
        publishTime: 7,
      );
      expect(price == same, isTrue);
      expect(price.hashCode, same.hashCode);
      expect(price == price, isTrue);
      for (final other in [
        HermesPrice(
          price: BigInt.from(151),
          conf: BigInt.from(3),
          expo: 2,
          publishTime: 7,
        ),
        HermesPrice(
          price: BigInt.from(150),
          conf: BigInt.from(4),
          expo: 2,
          publishTime: 7,
        ),
        HermesPrice(
          price: BigInt.from(150),
          conf: BigInt.from(3),
          expo: 3,
          publishTime: 7,
        ),
        HermesPrice(
          price: BigInt.from(150),
          conf: BigInt.from(3),
          expo: 2,
          publishTime: 8,
        ),
      ]) {
        expect(
          price == other,
          isFalse,
          reason: 'expected difference for $other',
        );
      }
    });
  });

  group('ParsedHermesPriceMetadata formatting', () {
    final feed = HermesPriceFeed.fromJson(const {
      'id': 'feed-1',
      'price': {
        'price': '1',
        'conf': '1',
        'expo': 0,
        'publish_time': 1,
      },
      'ema_price': {
        'price': '1',
        'conf': '1',
        'expo': 0,
        'publish_time': 1,
      },
      'metadata': {
        'slot': 12345,
        'prev_publish_time': 1699999900,
        'proof_available_time': 1700000100,
      },
    });
    final metadata = feed.metadata!;

    test('renders a debug representation', () {
      expect(
        metadata.toString(),
        'ParsedHermesPriceMetadata(slot: 12345, '
        'prevPublishTime: 1699999900, proofAvailableTime: 1700000100)',
      );
    });

    test('value equality and hashCode', () {
      final feed2 = HermesPriceFeed.fromJson(const {
        'id': 'feed-1',
        'price': {
          'price': '1',
          'conf': '1',
          'expo': 0,
          'publish_time': 1,
        },
        'ema_price': {
          'price': '1',
          'conf': '1',
          'expo': 0,
          'publish_time': 1,
        },
        'metadata': {
          'slot': 12345,
          'prev_publish_time': 1699999900,
          'proof_available_time': 1700000100,
        },
      });
      final sameMetadata = feed2.metadata!;
      expect(metadata == sameMetadata, isTrue);
      expect(metadata.hashCode, sameMetadata.hashCode);
      expect(metadata == metadata, isTrue);
    });
  });

  group('HermesPriceFeed formatting', () {
    final feed = HermesPriceFeed.fromJson(const {
      'id': 'feed-1',
      'price': {
        'price': '1',
        'conf': '1',
        'expo': 0,
        'publish_time': 1,
      },
      'ema_price': {
        'price': '1',
        'conf': '1',
        'expo': 0,
        'publish_time': 1,
      },
      'metadata': {'slot': 42},
    });

    test('renders a debug representation', () {
      expect(feed.toString(), startsWith('HermesPriceFeed(id: feed-1,'));
    });

    test('value equality covers every field and hashCode agreement', () {
      final sameFeed = HermesPriceFeed.fromJson(const {
        'id': 'feed-1',
        'price': {
          'price': '1',
          'conf': '1',
          'expo': 0,
          'publish_time': 1,
        },
        'ema_price': {
          'price': '1',
          'conf': '1',
          'expo': 0,
          'publish_time': 1,
        },
        'metadata': {'slot': 42},
      });
      expect(feed, sameFeed);
      expect(feed.hashCode, sameFeed.hashCode);
      expect(feed == feed, isTrue);
      expect(
        HermesPriceFeed.fromJson(const {
          'id': 'feed-2',
          'price': {
            'price': '1',
            'conf': '1',
            'expo': 0,
            'publish_time': 1,
          },
          'ema_price': {
            'price': '1',
            'conf': '1',
            'expo': 0,
            'publish_time': 1,
          },
          'metadata': {'slot': 42},
        }),
        isNot(feed),
      );
      expect(
        HermesPriceFeed.fromJson(const {
          'id': 'feed-1',
          'price': {
            'price': '2',
            'conf': '1',
            'expo': 0,
            'publish_time': 1,
          },
          'ema_price': {
            'price': '1',
            'conf': '1',
            'expo': 0,
            'publish_time': 1,
          },
          'metadata': {'slot': 42},
        }),
        isNot(feed),
      );
      expect(
        HermesPriceFeed.fromJson(const {
          'id': 'feed-1',
          'price': {
            'price': '1',
            'conf': '1',
            'expo': 0,
            'publish_time': 1,
          },
          'ema_price': {
            'price': '2',
            'conf': '1',
            'expo': 0,
            'publish_time': 1,
          },
          'metadata': {'slot': 42},
        }),
        isNot(feed),
      );
      expect(
        HermesPriceFeed.fromJson(const {
          'id': 'feed-1',
          'price': {
            'price': '1',
            'conf': '1',
            'expo': 0,
            'publish_time': 1,
          },
          'ema_price': {
            'price': '1',
            'conf': '1',
            'expo': 0,
            'publish_time': 1,
          },
        }),
        isNot(feed),
      );
    });
  });

  group('HermesPriceFeedMetadata formatting', () {
    Map<String, Object?> entry({String symbol = 'BTC/USD'}) => {
      'id': 'feed-1',
      'asset_type': 'crypto',
      'base': 'BTC',
      'description': 'Bitcoin / United States Dollar',
      'display_symbol': 'BTC',
      'generic_symbol': 'BTCUSD',
      'quote': 'USD',
      'symbol': symbol,
      'attributes': {'country': 'US'},
    };

    test('renders a debug representation', () {
      final metadata = HermesPriceFeedMetadata.fromJson(entry());
      expect(
        metadata.toString(),
        'HermesPriceFeedMetadata(id: feed-1, symbol: BTC/USD)',
      );
    });

    test('value equality covers every field and hashCode agreement', () {
      final metadata = HermesPriceFeedMetadata.fromJson(entry());
      final sameMetadata = HermesPriceFeedMetadata.fromJson(entry());
      expect(metadata == sameMetadata, isTrue);
      expect(metadata.hashCode, sameMetadata.hashCode);
      for (final other in [
        HermesPriceFeedMetadata.fromJson(entry(symbol: 'ETH/USD')),
        HermesPriceFeedMetadata.fromJson({
          ...entry(),
          'asset_type': 'equity',
        }),
        HermesPriceFeedMetadata.fromJson({
          ...entry(),
          'base': 'ETH',
        }),
        HermesPriceFeedMetadata.fromJson({
          ...entry(),
          'description': 'Ethereum / United States Dollar',
        }),
        HermesPriceFeedMetadata.fromJson({
          ...entry(),
          'display_symbol': 'ETH',
        }),
        HermesPriceFeedMetadata.fromJson({
          ...entry(),
          'generic_symbol': 'ETHUSD',
        }),
        HermesPriceFeedMetadata.fromJson({
          ...entry(),
          'quote': 'EUR',
        }),
      ]) {
        expect(
          metadata == other,
          isFalse,
          reason: 'expected difference for $other',
        );
      }
    });
  });

  group('HermesPriceUpdate formatting', () {
    const updateFixture = <String, Object?>{
      'binary': {
        'data': ['AB'],
        'encoding': 'hex',
      },
      'parsed': [
        {
          'id': 'feed-1',
          'price': {'price': '1', 'conf': '1', 'expo': 0, 'publish_time': 1},
          'ema_price': {
            'price': '1',
            'conf': '1',
            'expo': 0,
            'publish_time': 1,
          },
        },
      ],
    };

    test('renders parsed updates', () {
      final update = HermesPriceUpdate.fromJson(updateFixture);
      expect(
        update.toString(),
        'HermesPriceUpdate(binaryEncoding: HermesEncoding.hex, '
        'binaryData: 1 chunk(s), parsed: 1)',
      );
    });

    test('renders updates without parsed feeds', () {
      const raw = <String, Object?>{
        'binary': {
          'data': ['AB'],
          'encoding': 'hex',
        },
      };
      final update = HermesPriceUpdate.fromJson(raw);
      expect(update.toString(), contains('parsed: n/a'));
    });

    test('hashCode agrees for equal updates', () {
      expect(
        HermesPriceUpdate.fromJson(updateFixture).hashCode,
        HermesPriceUpdate.fromJson(updateFixture).hashCode,
      );
      const raw = <String, Object?>{
        'binary': {
          'data': ['AB'],
          'encoding': 'hex',
        },
      };
      expect(HermesPriceUpdate.fromJson(raw).hashCode, isNot(0));
    });
  });

  group('HermesPriceUpdate parsed-feed equality', () {
    Map<String, Object?> feedJson(String id) => {
      'id': id,
      'price': {'price': '1', 'conf': '1', 'expo': 0, 'publish_time': 1},
      'ema_price': {'price': '1', 'conf': '1', 'expo': 0, 'publish_time': 1},
    };

    HermesPriceUpdate updateWith(List<Object?>? parsed) {
      final json = <String, Object?>{
        'binary': {
          'data': ['AB'],
          'encoding': 'hex',
        },
        'parsed': ?parsed,
      };
      return HermesPriceUpdate.fromJson(json);
    }

    test('handles null parsed feeds', () {
      final withoutParsed = updateWith(null);
      final withParsed = updateWith([feedJson('feed-1')]);
      expect(withoutParsed == withParsed, isFalse);
      expect(withParsed == withoutParsed, isFalse);
      expect(withParsed == withParsed, isTrue);
    });

    test('handles different parsed feed counts', () {
      final oneFeed = updateWith([feedJson('feed-1')]);
      final twoFeeds = updateWith([feedJson('feed-1'), feedJson('feed-2')]);
      expect(oneFeed == twoFeeds, isFalse);
      expect(twoFeeds == oneFeed, isFalse);
    });

    test('handles different parsed feed contents', () {
      final first = updateWith([feedJson('feed-1'), feedJson('feed-2')]);
      final second = updateWith([feedJson('feed-1'), feedJson('feed-3')]);
      expect(first == second, isFalse);
    });
  });

  group('Hermes JSON validation', () {
    test('rejects non-object price entries', () {
      expect(
        () => HermesPrice.fromJson(const {
          'price': 1.5,
          'conf': '1',
          'expo': 0,
          'publish_time': 0,
        }),
        throwsArgumentError,
      );
      expect(
        () => HermesPrice.fromJson(const {
          'price': '1',
          'conf': true,
          'expo': 0,
          'publish_time': 0,
        }),
        throwsArgumentError,
      );
      expect(
        () => HermesPrice.fromJson(const {
          'price': '1',
          'conf': '1',
          'expo': 0,
          'publish_time': 0,
        }),
        returnsNormally,
      );
    });

    test('requires integer expo and publish_time', () {
      expect(
        () => HermesPrice.fromJson(const {
          'price': '1',
          'conf': '1',
          'expo': 'zero',
          'publish_time': 0,
        }),
        throwsArgumentError,
      );
      expect(
        () => HermesPrice.fromJson(const {
          'price': '1',
          'conf': '1',
          'expo': 0,
          'publish_time': null,
        }),
        throwsArgumentError,
      );
    });

    test('metadata must be an object', () {
      expect(
        () => HermesPriceFeed.fromJson(const {
          'id': 'feed-1',
          'price': {'price': '1', 'conf': '1', 'expo': 0, 'publish_time': 1},
          'ema_price': {
            'price': '1',
            'conf': '1',
            'expo': 0,
            'publish_time': 1,
          },
          'metadata': 42,
        }),
        throwsArgumentError,
      );
    });

    test('binary payloads must be objects', () {
      expect(
        () => HermesPriceUpdate.fromJson(const {'binary': 'nope'}),
        throwsArgumentError,
      );
    });

    test('binary payloads require an encoding', () {
      expect(
        () => HermesPriceUpdate.fromJson(
          const {
            'binary': {
              'data': ['AB'],
            },
          },
        ),
        throwsArgumentError,
      );
    });

    test('binary encodings must be known', () {
      expect(
        () => HermesPriceUpdate.fromJson(
          const {
            'binary': {
              'data': ['AB'],
              'encoding': 'zzz',
            },
          },
        ),
        throwsA(
          isA<PythException>().having(
            (e) => e.message,
            'message',
            'Unknown Hermes encoding: zzz',
          ),
        ),
      );
    });
  });
}
