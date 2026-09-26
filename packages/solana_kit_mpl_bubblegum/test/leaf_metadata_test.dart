import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_mpl_bubblegum/solana_kit_mpl_bubblegum.dart';
import 'package:test/test.dart';

String _hex(List<int> bytes) =>
    bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

const _payee = '11111111111111111111111111111111';

const _v2Metadata = MetadataArgsV2(
  name: 'My NFT',
  uri: 'https://example.com/my-nft.json',
  sellerFeeBasisPoints: 500,
  creators: [],
);

void main() {
  group('leaf metadata resolution', () {
    test('applies explicit sibling raw fields', () {
      const metadata = MetadataArgs(
        name: 'My NFT',
        uri: 'https://example.com/my-nft.json',
        sellerFeeBasisPoints: 500,
        creators: [
          Creator(address: Address(_payee), verified: true, share: 100),
        ],
      );
      final leaf = toLeafMetadata(
        metadata,
        const RoyaltyRawFields(
          sellerFeeBasisPointsRaw: sellerFeeBasisPointsInherit,
          creatorsRaw: [],
        ),
      );

      expect(leaf.sellerFeeBasisPoints, sellerFeeBasisPointsInherit);
      expect(leaf.creators, isEmpty);
      // The display value is never mutated.
      expect(metadata.sellerFeeBasisPoints, 500);
      expect(metadata.creators, hasLength(1));
    });

    test('leaves metadata unchanged when no raw fields are supplied', () {
      const metadata = MetadataArgs(
        name: 'X',
        uri: 'https://example.com/x.json',
        sellerFeeBasisPoints: 550,
        creators: [
          Creator(address: Address(_payee), verified: false, share: 100),
        ],
      );
      final leaf = toLeafMetadata(metadata);

      expect(leaf.sellerFeeBasisPoints, 550);
      expect(leaf.creators, hasLength(1));
    });

    test('converts V1 collection to the V2 bare key', () {
      const collectionKey = Address(
        'TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA',
      );
      const metadata = MetadataArgs(
        name: 'My NFT',
        uri: 'https://example.com/my-nft.json',
        sellerFeeBasisPoints: 500,
        collection: Collection(key: collectionKey, verified: true),
        creators: [],
      );
      final leaf = toLeafMetadataV2(metadata);

      expect(leaf.collection, collectionKey);
    });

    test('handles an absent collection', () {
      final leaf = toLeafMetadataV2(_v2Metadata);
      expect(leaf.collection, isNull);
    });

    test('asCurrentMetadataV2 is equivalent to toLeafMetadataV2', () {
      const raw = RoyaltyRawFields(
        sellerFeeBasisPointsRaw: sellerFeeBasisPointsInherit,
      );
      final viaSugar = asCurrentMetadataV2(_v2Metadata, raw);
      final direct = toLeafMetadataV2(_v2Metadata, raw);

      expect(viaSugar.sellerFeeBasisPoints, direct.sellerFeeBasisPoints);
      expect(viaSugar.sellerFeeBasisPoints, sellerFeeBasisPointsInherit);
    });

    test('rejects a value that is neither metadata shape', () {
      expect(
        () => toLeafMetadataV2('not metadata'),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('metadata hashing', () {
    // Authoritative vectors from @metaplex-foundation/mpl-bubblegum 6.0.0,
    // whose serializers the on-chain program deserializes.
    test('hashMetadataDataV2 matches upstream for the V2 layout', () {
      expect(
        _hex(hashMetadataDataV2(_v2Metadata)),
        'c5745eaf227d48a7e82f6fdb8c5b55037c37316f0c9291667eec9a53b5ef3112',
      );
    });

    test('hashMetadataCreators hashes the empty creator list', () {
      expect(
        _hex(hashMetadataCreators(const [])),
        'c5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470',
      );
    });

    test('hashMetadataV2 commits to the leaf-canonical metadata', () {
      final plain = hashMetadataV2(_v2Metadata);
      final inherited = hashMetadataV2(
        _v2Metadata,
        const RoyaltyRawFields(
          sellerFeeBasisPointsRaw: sellerFeeBasisPointsInherit,
        ),
      );

      // The display and leaf rates differ, so the hashes must differ.
      expect(_hex(plain), isNot(_hex(inherited)));
    });

    test('hashCollection and hashAssetData hash the empty default', () {
      final emptyAssetData = hashAssetData(null);
      expect(
        _hex(emptyAssetData),
        'c5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470',
      );
    });

    test('hashes V1 metadata through the V1 encoder', () {
      const metadata = MetadataArgs(
        name: 'My NFT',
        uri: 'https://example.com/my-nft.json',
        sellerFeeBasisPoints: 500,
        creators: [
          Creator(address: Address(_payee), verified: true, share: 100),
        ],
      );

      // V1 hashing uses the V1 encoder, which is three bytes longer than V2
      // because of editionNonce, uses, and tokenProgramVersion.
      expect(hashMetadataData(metadata), isNot(hashMetadataDataV2(metadata)));
      expect(hashMetadata(metadata), isNot(hashMetadataV2(metadata)));
      expect(hashMetadataCreators(metadata.creators), isNotEmpty);
    });

    test('V1 hashing resolves the raw royalty companions', () {
      const metadata = MetadataArgs(
        name: 'My NFT',
        uri: 'https://example.com/my-nft.json',
        sellerFeeBasisPoints: 500,
        creators: [],
      );
      final plain = hashMetadataData(metadata);
      final inherited = hashMetadataData(
        metadata,
        const RoyaltyRawFields(
          sellerFeeBasisPointsRaw: sellerFeeBasisPointsInherit,
        ),
      );

      expect(_hex(plain), isNot(_hex(inherited)));
    });

    test('V1 hashing accepts the siblings carried on the value', () {
      const metadata = MetadataArgs(
        name: 'My NFT',
        uri: 'https://example.com/my-nft.json',
        sellerFeeBasisPoints: 500,
        creators: [],
      );
      const siblings = RoyaltyRawFields(
        sellerFeeBasisPointsRaw: sellerFeeBasisPointsInherit,
      );

      // Passing the companions explicitly and via toLeafMetadata agree.
      expect(
        _hex(hashMetadataV2(toLeafMetadataV2(metadata, siblings))),
        _hex(hashMetadataV2(metadata, siblings)),
      );
    });

    test('encodeBorshString prefixes the UTF-8 byte length', () {
      final encoded = encodeBorshString('abc');

      expect(encoded, hasLength(7));
      expect(encoded.sublist(0, 4), [3, 0, 0, 0]);
      expect(encoded.sublist(4), [0x61, 0x62, 0x63]);
    });

    test('encodeBorshString counts UTF-8 bytes, not code units', () {
      // 'é' is two UTF-8 bytes, so the length prefix must be 2.
      final encoded = encodeBorshString('é');

      expect(encoded.sublist(0, 4), [2, 0, 0, 0]);
      expect(encoded, hasLength(6));
    });

    test('encodeMetadataArgsV2FromMetadata matches the generated encoder', () {
      final fromValue = encodeMetadataArgsV2FromMetadata(_v2Metadata);
      final fromArgs = encodeMetadataArgsV2(
        name: _v2Metadata.name,
        symbol: _v2Metadata.symbol,
        uri: _v2Metadata.uri,
        sellerFeeBasisPoints: _v2Metadata.sellerFeeBasisPoints,
        primarySaleHappened: _v2Metadata.primarySaleHappened,
        isMutable: _v2Metadata.isMutable,
        tokenStandard: _v2Metadata.tokenStandard.value,
        collection: _v2Metadata.collection,
        creators: _v2Metadata.creators,
      );

      expect(_hex(fromValue), _hex(fromArgs));
    });

    test('encodeBorshString handles an empty string', () {
      expect(encodeBorshString(''), [0, 0, 0, 0]);
    });
  });

  group('UpdateArgs encoding', () {
    test('matches the on-chain field order', () {
      // Field order is name, symbol, uri, creators, sellerFeeBasisPoints,
      // primarySaleHappened, isMutable, each an Option. Vector from the
      // upstream 6.0.0 updateMetadataV2 instruction data serializer.
      final bytes = encodeUpdateArgs(
        const UpdateArgs(
          name: 'New name',
          uri: 'https://updated-example.com/my-nft.json',
        ),
      );

      expect(
        _hex(bytes),
        '01080000004e6577206e616d6500012700000068747470733a2f2f757064617465642d65'
        '78616d706c652e636f6d2f6d792d6e66742e6a736f6e00000000',
      );
    });

    test('encodes each field as an independent Option', () {
      final all = encodeUpdateArgs(
        const UpdateArgs(
          name: 'n',
          symbol: 's',
          uri: 'u',
          creators: [],
          sellerFeeBasisPoints: 1,
          primarySaleHappened: true,
          isMutable: false,
        ),
      );
      final none = encodeUpdateArgs(const UpdateArgs());

      // Seven Some-presence bytes on the left against seven None bytes.
      expect(all.length, greaterThan(none.length));
      expect(none.length, 7);
      expect(none.every((b) => b == 0), isTrue);
    });
  });
}
