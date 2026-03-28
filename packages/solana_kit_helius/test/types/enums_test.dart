import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

void main() {
  group('HeliusCluster', () {
    test('toJson returns wire string', () {
      expect(HeliusCluster.mainnet.toJson(), 'mainnet-beta');
      expect(HeliusCluster.devnet.toJson(), 'devnet');
    });
    test('fromJson roundtrips all variants', () {
      for (final v in HeliusCluster.values) {
        expect(HeliusCluster.fromJson(v.toJson()), v);
      }
    });
    test('fromJson throws on unknown value', () {
      expect(() => HeliusCluster.fromJson('bad'), throwsArgumentError);
    });
  });

  group('HeliusAssetInterface', () {
    test('toJson returns wire string', () {
      expect(HeliusAssetInterface.v1Nft.toJson(), 'V1_NFT');
      expect(HeliusAssetInterface.fungibleToken.toJson(), 'FungibleToken');
      expect(HeliusAssetInterface.mplCoreAsset.toJson(), 'MplCoreAsset');
    });
    test('fromJson roundtrips all variants', () {
      for (final v in HeliusAssetInterface.values) {
        expect(HeliusAssetInterface.fromJson(v.toJson()), v);
      }
    });
    test('fromJson throws on unknown value', () {
      expect(() => HeliusAssetInterface.fromJson('bad'), throwsArgumentError);
    });
  });

  group('HeliusOwnershipModel', () {
    test('fromJson roundtrips all variants', () {
      for (final v in HeliusOwnershipModel.values) {
        expect(HeliusOwnershipModel.fromJson(v.toJson()), v);
      }
    });
    test('fromJson throws on unknown value', () {
      expect(() => HeliusOwnershipModel.fromJson('bad'), throwsArgumentError);
    });
  });

  group('HeliusRoyaltyModel', () {
    test('fromJson roundtrips all variants', () {
      for (final v in HeliusRoyaltyModel.values) {
        expect(HeliusRoyaltyModel.fromJson(v.toJson()), v);
      }
    });
    test('fromJson throws on unknown value', () {
      expect(() => HeliusRoyaltyModel.fromJson('bad'), throwsArgumentError);
    });
  });

  group('HeliusScope', () {
    test('fromJson roundtrips all variants', () {
      for (final v in HeliusScope.values) {
        expect(HeliusScope.fromJson(v.toJson()), v);
      }
    });
    test('fromJson throws on unknown value', () {
      expect(() => HeliusScope.fromJson('bad'), throwsArgumentError);
    });
  });

  group('HeliusUseMethod', () {
    test('fromJson roundtrips all variants', () {
      for (final v in HeliusUseMethod.values) {
        expect(HeliusUseMethod.fromJson(v.toJson()), v);
      }
    });
    test('fromJson throws on unknown value', () {
      expect(() => HeliusUseMethod.fromJson('bad'), throwsArgumentError);
    });
  });

  group('HeliusContext', () {
    test('fromJson roundtrips all variants', () {
      for (final v in HeliusContext.values) {
        expect(HeliusContext.fromJson(v.toJson()), v);
      }
    });
    test('fromJson throws on unknown value', () {
      expect(() => HeliusContext.fromJson('bad'), throwsArgumentError);
    });
  });

  group('AssetSortBy', () {
    test('fromJson roundtrips all variants', () {
      for (final v in AssetSortBy.values) {
        expect(AssetSortBy.fromJson(v.toJson()), v);
      }
    });
    test('fromJson throws on unknown value', () {
      expect(() => AssetSortBy.fromJson('bad'), throwsArgumentError);
    });
  });

  group('AssetSortDirection', () {
    test('fromJson roundtrips all variants', () {
      for (final v in AssetSortDirection.values) {
        expect(AssetSortDirection.fromJson(v.toJson()), v);
      }
    });
    test('fromJson throws on unknown value', () {
      expect(() => AssetSortDirection.fromJson('bad'), throwsArgumentError);
    });
  });

  group('TokenStandard', () {
    test('fromJson roundtrips all variants', () {
      for (final v in TokenStandard.values) {
        expect(TokenStandard.fromJson(v.toJson()), v);
      }
    });
    test('fromJson throws on unknown value', () {
      expect(() => TokenStandard.fromJson('bad'), throwsArgumentError);
    });
  });

  group('PriorityLevel', () {
    test('fromJson roundtrips all variants', () {
      for (final v in PriorityLevel.values) {
        expect(PriorityLevel.fromJson(v.toJson()), v);
      }
    });
    test('fromJson throws on unknown value', () {
      expect(() => PriorityLevel.fromJson('bad'), throwsArgumentError);
    });
  });

  group('UiTransactionEncoding', () {
    test('fromJson roundtrips all variants', () {
      for (final v in UiTransactionEncoding.values) {
        expect(UiTransactionEncoding.fromJson(v.toJson()), v);
      }
    });
    test('fromJson throws on unknown value', () {
      expect(
        () => UiTransactionEncoding.fromJson('bad'),
        throwsArgumentError,
      );
    });
  });

  group('WebhookType', () {
    test('fromJson roundtrips all variants', () {
      for (final v in WebhookType.values) {
        expect(WebhookType.fromJson(v.toJson()), v);
      }
    });
    test('fromJson throws on unknown value', () {
      expect(() => WebhookType.fromJson('bad'), throwsArgumentError);
    });
  });

  group('TransactionStatus', () {
    test('fromJson roundtrips all variants', () {
      for (final v in TransactionStatus.values) {
        expect(TransactionStatus.fromJson(v.toJson()), v);
      }
    });
    test('fromJson throws on unknown value', () {
      expect(() => TransactionStatus.fromJson('bad'), throwsArgumentError);
    });
  });

  group('CommitmentLevel', () {
    test('fromJson roundtrips all variants', () {
      for (final v in CommitmentLevel.values) {
        expect(CommitmentLevel.fromJson(v.toJson()), v);
      }
    });
    test('fromJson throws on unknown value', () {
      expect(() => CommitmentLevel.fromJson('bad'), throwsArgumentError);
    });
  });
}
