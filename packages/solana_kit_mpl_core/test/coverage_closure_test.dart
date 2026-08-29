import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_mpl_core/solana_kit_mpl_core.dart';
import 'package:test/test.dart';

Address get _any =>
    const Address('Fg6PaFpoGXkYsidMpWTK6W2BeZ7FEfcYkg476zPFsLnS');

void main() {
  test('custom PDA with all seed kinds derives deterministically', () async {
    final first = await deriveExtraAccountAddress(
      ExtraAccountCustomPda(
        seeds: [
          const SeedCollection(),
          const SeedOwner(),
          const SeedRecipient(),
          const SeedAsset(),
          SeedAddress(_any),
          SeedBytes(Uint8List.fromList([1, 2, 3])),
        ],
        customProgramId: null,
        isSigner: false,
        isWritable: true,
      ),
      asset: _any,
      collection: _any,
      owner: _any,
      recipient: _any,
    );
    final second = await deriveExtraAccountAddress(
      ExtraAccountCustomPda(
        seeds: [
          const SeedCollection(),
          const SeedOwner(),
          const SeedRecipient(),
          const SeedAsset(),
          SeedAddress(_any),
          SeedBytes(Uint8List.fromList([1, 2, 3])),
        ],
        customProgramId: null,
        isSigner: false,
        isWritable: true,
      ),
      asset: _any,
      collection: _any,
      owner: _any,
      recipient: _any,
    );
    expect(first, second);
  });

  test('preconfigured collection/owner/recipient/asset PDAs derive', () async {
    final collection = await deriveExtraAccountAddress(
      const ExtraAccountPreconfiguredCollection(
        isSigner: false,
        isWritable: false,
      ),
      collection: _any,
    );
    final owner = await deriveExtraAccountAddress(
      const ExtraAccountPreconfiguredOwner(
        isSigner: false,
        isWritable: false,
      ),
      owner: _any,
    );
    final recipient = await deriveExtraAccountAddress(
      const ExtraAccountPreconfiguredRecipient(
        isSigner: false,
        isWritable: false,
      ),
      recipient: _any,
    );
    final asset = await deriveExtraAccountAddress(
      const ExtraAccountPreconfiguredAsset(
        isSigner: false,
        isWritable: false,
      ),
      asset: _any,
    );
    expect(collection, isA<Address>());
    expect(owner, isA<Address>());
    expect(recipient, isA<Address>());
    expect(asset, isA<Address>());
  });

  test('missing context accounts throw for preconfigured variants', () async {
    await expectLater(
      deriveExtraAccountAddress(
        const ExtraAccountPreconfiguredCollection(
          isSigner: false,
          isWritable: false,
        ),
      ),
      throwsArgumentError,
    );
  });

  test('custom PDA falls under the default program when unset', () {
    expect(
      deriveExtraAccountAddress(
        ExtraAccountCustomPda(
          seeds: [SeedAddress(_any)],
          customProgramId: null,
          isSigner: false,
          isWritable: false,
        ),
      ),
      completes,
    );
  });

  group('preconfigured named wrappers', () {
    test('asset wrapper derives the same as the key variant', () async {
      final wrapped = await findPreconfiguredAssetPda(asset: _any);
      final direct = await findPreconfiguredPda(key: _any);
      expect(wrapped.$1, direct.$1);
    });

    test('collection wrapper derives the key variant', () async {
      final wrapped = await findPreconfiguredCollectionPda(collection: _any);
      final direct = await findPreconfiguredPda(key: _any);
      expect(wrapped.$1, direct.$1);
    });

    test('owner wrapper derives the key variant', () async {
      final wrapped = await findPreconfiguredOwnerPda(owner: _any);
      final direct = await findPreconfiguredPda(key: _any);
      expect(wrapped.$1, direct.$1);
    });

    test('recipient wrapper derives the key variant', () async {
      final wrapped = await findPreconfiguredRecipientPda(recipient: _any);
      final direct = await findPreconfiguredPda(key: _any);
      expect(wrapped.$1, direct.$1);
    });
  });
}
