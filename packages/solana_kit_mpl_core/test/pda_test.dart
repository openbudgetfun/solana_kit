import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart'
    hide mplCoreProgramAddress;
import 'package:solana_kit_mpl_core/solana_kit_mpl_core.dart';
import 'package:test/test.dart';

// Reference vectors were computed with the exact seeds read from the mpl-core
// Rust sources (`processor/execute.rs`, prefix `mpl-core-execute`; and
// `plugins/external_plugin_adapters.rs`, prefix `mpl-core`) and cross-verified
// against the standalone `@solana/web3.js` PDA implementation
// (`findProgramAddressSync`).
const _programId = 'CoREENxT6tW1HoK8ypY1SxRMZTcVPm7R94rH4PZNhX7d';
const _assetId = 'So11111111111111111111111111111111111111112';
const _ownerId = '9WzDXwBbmkg8ZTbNMqUxvQRAyrZzDsGYdLVL9zYtAWWM';
const _baseProgramId = 'G5VeVfFCLYP2WwXTb4kTWhfHecDnEuVF2qGBd9Qv7aEJ';
const _systemProgramId = '11111111111111111111111111111111';

void main() {
  group('program addresses', () {
    test('mplCoreProgramAddress matches the on-chain program id', () {
      expect(mplCoreProgramAddress, _programId);
      expect(mplCoreProgramAddressObject, const Address(_programId));
    });
  });

  group('findAssetSignerPda', () {
    test('matches the verified vector from the on-chain seeds', () async {
      final (pda, bump) = await findAssetSignerPda(
        asset: const Address(_assetId),
      );

      expect(
        pda,
        const Address('BScC4A8jz6F4ZJKHrwWs7KJetuuAzy7bLKjauJsgbsXQ'),
      );
      expect(bump, 255);
    });

    test('is deterministic', () async {
      final (first, firstBump) = await findAssetSignerPda(
        asset: const Address(_assetId),
      );
      final (second, secondBump) = await findAssetSignerPda(
        asset: const Address(_assetId),
      );

      expect(first, second);
      expect(firstBump, secondBump);
      expect(bumpIsInRange(firstBump), isTrue);
    });

    test('differs per asset', () async {
      final (forAsset, _) = await findAssetSignerPda(
        asset: const Address(_assetId),
      );
      final (forOwner, _) = await findAssetSignerPda(
        asset: const Address(_ownerId),
      );

      expect(forAsset, isNot(forOwner));
    });
  });

  group('preconfigured PDAs', () {
    test('findPreconfiguredAssetPda matches the verified vector', () async {
      final (pda, bump) = await findPreconfiguredAssetPda(
        asset: const Address(_assetId),
      );

      // Bump seed is 254 for this input: bump 255 lands on the ed25519 curve.
      expect(
        pda,
        const Address('FcCyJhf11qot76FbAyFaKAPWqxJwiBH3pfmMZpj2ULxi'),
      );
      expect(bump, 254);
    });

    test('findPreconfiguredOwnerPda matches the verified vector', () async {
      final (pda, bump) = await findPreconfiguredOwnerPda(
        owner: const Address(_ownerId),
      );

      expect(
        pda,
        const Address('Cv1iCaujHHL8DmJmxAPJ2eFoMVpLcnRvrxt7PtrUQ3F6'),
      );
      expect(bump, 255);
    });

    test('findPreconfiguredProgramPda matches the verified vector', () async {
      final (pda, bump) = await findPreconfiguredProgramPda();

      expect(
        pda,
        const Address('CKMh9MdJJqMb163H8UznSQziqNGiBhEe6cdUjyzMR7Ry'),
      );
      expect(bump, 251);
    });

    test('findPreconfiguredPda derives the same address per key', () async {
      final (fromOwner, _) = await findPreconfiguredPda(
        key: const Address(_ownerId),
      );
      final (viaOwnerHelper, _) = await findPreconfiguredOwnerPda(
        owner: const Address(_ownerId),
      );

      expect(fromOwner, viaOwnerHelper);
    });

    test('derives on a custom program when provided', () async {
      final (pda, bump) = await findPreconfiguredPda(
        key: const Address(_assetId),
        programAddress: const Address(_baseProgramId),
      );

      expect(
        pda,
        const Address('2GKyLK8Fi8tUNgLKpMagr2vUCF5ff4J7ogpBVoyvyrZs'),
      );
      expect(bump, 255);
    });
  });

  group('findOracleAccount', () {
    test('returns the base address when no config is present', () async {
      final address = await findOracleAccount(
        baseAddress: const Address(_baseProgramId),
      );

      expect(address, const Address(_baseProgramId));
    });

    test(
      'derives the preconfigured program PDA on the base program',
      () async {
        final address = await findOracleAccount(
          baseAddress: const Address(_baseProgramId),
          baseAddressConfig: const ExtraAccountPreconfiguredProgram(
            isSigner: false,
            isWritable: false,
          ),
        );

        expect(
          address,
          const Address('FfBScmC6jUVRdv3Qrk1sSRRSg2KdS7MsdfcncDxoeyGx'),
        );
      },
    );

    test('derives a custom PDA with the configured seeds', () async {
      final address = await findOracleAccount(
        baseAddress: const Address(_baseProgramId),
        baseAddressConfig: ExtraAccountCustomPda(
          seeds: [
            SeedBytes(Uint8List.fromList([0x6f, 0x72, 0x61, 0x63, 0x6c, 0x65])),
          ],
          customProgramId: null,
          isSigner: false,
          isWritable: false,
        ),
      );

      // Seeds ['oracle'] on the base program.
      expect(
        address,
        const Address('B4kNGsN3F9VwSTBA7VJ1x6MqwBsPSN5VjyCVsHad7bTC'),
      );
    });

    test('returns a direct address unchanged', () async {
      const direct = Address(_assetId);

      final address = await findOracleAccount(
        baseAddress: const Address(_baseProgramId),
        baseAddressConfig: const ExtraAccountAddress(
          address: direct,
          isSigner: false,
          isWritable: false,
        ),
      );

      expect(address, direct);
    });
  });

  group('deriveExtraAccountAddress', () {
    test(
      'derives preconfigured asset PDAs like the on-chain program',
      () async {
        final address = await deriveExtraAccountAddress(
          const ExtraAccountPreconfiguredAsset(
            isSigner: false,
            isWritable: false,
          ),
          asset: const Address(_assetId),
        );

        expect(
          address,
          const Address('FcCyJhf11qot76FbAyFaKAPWqxJwiBH3pfmMZpj2ULxi'),
        );
      },
    );

    test('derives custom PDAs on the custom program when configured', () async {
      final address = await deriveExtraAccountAddress(
        ExtraAccountCustomPda(
          seeds: [
            SeedBytes(Uint8List.fromList([0x6f, 0x72, 0x61, 0x63, 0x6c, 0x65])),
            const SeedAsset(),
          ],
          customProgramId: const Address(_systemProgramId),
          isSigner: false,
          isWritable: false,
        ),
        asset: const Address(_assetId),
      );

      // Seeds ['oracle', asset] on the custom program.
      expect(
        address,
        const Address('D2TDeihn1232WNT1NoDXEhqrcnCzXsi58Q51X3j9MU27'),
      );
    });

    test('defaults the custom PDA program to the mpl-core program', () async {
      final (expectedPda, _) = await findPreconfiguredPda(
        key: const Address(_ownerId),
      );

      final address = await deriveExtraAccountAddress(
        ExtraAccountCustomPda(
          seeds: [
            SeedBytes(
              Uint8List.fromList([
                0x6d,
                0x70,
                0x6c,
                0x2d,
                0x63,
                0x6f,
                0x72,
                0x65,
              ]),
            ),
            const SeedAddress(Address(_ownerId)),
          ],
          customProgramId: null,
          isSigner: false,
          isWritable: false,
        ),
      );

      expect(address, expectedPda);
    });

    test('throws when a required context address is missing', () {
      expect(
        () => deriveExtraAccountAddress(
          const ExtraAccountPreconfiguredCollection(
            isSigner: false,
            isWritable: false,
          ),
        ),
        throwsArgumentError,
      );
    });
  });
}

/// Whether [bump] is a valid bump seed value.
bool bumpIsInRange(int bump) => bump >= 0 && bump <= 255;
