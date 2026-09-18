import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart'
    hide token2022ProgramAddress;
import 'package:solana_kit_token_2022/solana_kit_token_2022.dart';
import 'package:test/test.dart';

void main() {
  const mint = Address('11111111111111111111111111111111');
  const authority = Address('11111111111111111111111111111112');
  const metadata = Address('11111111111111111111111111111113');
  const delegate = Address('11111111111111111111111111111114');
  const alternateProgram = Address('11111111111111111111111111111115');

  group('size helpers', () {
    test('getMintSize matches encoded mint length', () {
      final extensions = <Extension>[
        const ExtensionMetadataPointer(
          authority: authority,
          metadataAddress: metadata,
        ),
        ExtensionInterestBearingConfig(
          rateAuthority: authority,
          initializationTimestamp: BigInt.zero,
          preUpdateAverageRate: 0,
          lastUpdateTimestamp: BigInt.zero,
          currentRate: 250,
        ),
      ];

      final account = Mint(
        mintAuthority: authority,
        supply: BigInt.zero,
        decimals: 6,
        isInitialized: true,
        freezeAuthority: authority,
        extensions: extensions,
      );

      expect(getMintSize(), mintSize);
      expect(getMintSize(extensions), getMintEncoder().encode(account).length);
    });

    test('getTokenSize matches encoded token length', () {
      final extensions = <Extension>[
        const ExtensionMemoTransfer(requireIncomingTransferMemos: true),
        const ExtensionCpiGuard(lockCpi: true),
      ];

      final account = Token(
        mint: mint,
        owner: authority,
        amount: BigInt.zero,
        delegate: null,
        state: AccountState.initialized,
        isNative: null,
        delegatedAmount: BigInt.zero,
        closeAuthority: null,
        extensions: extensions,
      );

      expect(getTokenSize(), tokenSize);
      expect(
        getTokenSize(extensions),
        getTokenEncoder().encode(account).length,
      );
    });
  });

  group('getPreInitializeInstructionsForMintExtensions', () {
    test('builds focused mint pre-initialize instructions', () {
      final instructions = getPreInitializeInstructionsForMintExtensions(
        mint: mint,
        extensions: <Extension>[
          ExtensionTransferFeeConfig(
            transferFeeConfigAuthority: authority,
            withdrawWithheldAuthority: delegate,
            withheldAmount: BigInt.zero,
            olderTransferFee: TransferFee(
              epoch: BigInt.zero,
              maximumFee: BigInt.zero,
              transferFeeBasisPoints: 0,
            ),
            newerTransferFee: TransferFee(
              epoch: BigInt.one,
              maximumFee: BigInt.from(99),
              transferFeeBasisPoints: 25,
            ),
          ),
          const ExtensionMetadataPointer(
            authority: authority,
            metadataAddress: metadata,
          ),
          const ExtensionMintCloseAuthority(closeAuthority: delegate),
        ],
      );

      expect(instructions, hasLength(3));
      expect(
        instructions.every(
          (ix) => ix.programAddress == token2022ProgramAddress,
        ),
        isTrue,
      );

      final transferFee = parseInitializeTransferFeeConfigInstruction(
        instructions[0],
      );
      expect(transferFee.transferFeeConfigAuthority, authority);
      expect(transferFee.withdrawWithheldAuthority, delegate);
      expect(transferFee.transferFeeBasisPoints, 25);
      expect(transferFee.maximumFee, BigInt.from(99));

      final metadataPointer = parseInitializeMetadataPointerInstruction(
        instructions[1],
      );
      expect(metadataPointer.authority, authority);
      expect(metadataPointer.metadataAddress, metadata);

      final mintCloseAuthority = parseInitializeMintCloseAuthorityInstruction(
        instructions[2],
      );
      expect(mintCloseAuthority.closeAuthority, delegate);
    });

    test(
      'covers all supported mint extensions and ignores unsupported ones',
      () {
        final instructions = getPreInitializeInstructionsForMintExtensions(
          mint: mint,
          programAddress: alternateProgram,
          extensions: <Extension>[
            const ExtensionConfidentialTransferMint(
              authority: authority,
              autoApproveNewAccounts: true,
              auditorElgamalPubkey: metadata,
            ),
            const ExtensionDefaultAccountState(state: AccountState.frozen),
            ExtensionTransferFeeConfig(
              transferFeeConfigAuthority: authority,
              withdrawWithheldAuthority: delegate,
              withheldAmount: BigInt.zero,
              olderTransferFee: TransferFee(
                epoch: BigInt.zero,
                maximumFee: BigInt.zero,
                transferFeeBasisPoints: 0,
              ),
              newerTransferFee: TransferFee(
                epoch: BigInt.one,
                maximumFee: BigInt.from(5),
                transferFeeBasisPoints: 7,
              ),
            ),
            const ExtensionMetadataPointer(
              authority: authority,
              metadataAddress: metadata,
            ),
            ExtensionInterestBearingConfig(
              rateAuthority: authority,
              initializationTimestamp: BigInt.zero,
              preUpdateAverageRate: 1,
              lastUpdateTimestamp: BigInt.one,
              currentRate: 123,
            ),
            ExtensionScaledUiAmountConfig(
              authority: authority,
              multiplier: 1.5,
              newMultiplierEffectiveTimestamp: BigInt.from(2),
              newMultiplier: 2.5,
            ),
            const ExtensionPausableConfig(authority: authority, paused: false),
            const ExtensionPermissionedBurn(authority: delegate),
            const ExtensionGroupPointer(
              authority: authority,
              groupAddress: metadata,
            ),
            const ExtensionGroupMemberPointer(
              authority: authority,
              memberAddress: delegate,
            ),
            const ExtensionNonTransferable(),
            const ExtensionTransferHook(
              authority: authority,
              programId: delegate,
            ),
            const ExtensionPermanentDelegate(delegate: delegate),
            ExtensionConfidentialTransferFee(
              authority: authority,
              elgamalPubkey: metadata,
              harvestToMintEnabled: true,
              withheldAmount: Uint8List(0),
            ),
            const ExtensionMintCloseAuthority(closeAuthority: delegate),
            const ExtensionMemoTransfer(requireIncomingTransferMemos: true),
          ],
        );

        expect(instructions, hasLength(15));
        expect(
          instructions.map((instruction) => instruction.programAddress),
          everyElement(alternateProgram),
        );

        expect(
          parseInitializeConfidentialTransferMintInstruction(
            instructions[0],
          ).authority,
          authority,
        );
        expect(
          parseInitializeDefaultAccountStateInstruction(instructions[1]).state,
          AccountState.frozen,
        );
        expect(
          parseInitializeTransferFeeConfigInstruction(
            instructions[2],
          ).transferFeeBasisPoints,
          7,
        );
        expect(
          parseInitializeMetadataPointerInstruction(
            instructions[3],
          ).metadataAddress,
          metadata,
        );
        expect(
          parseInitializeInterestBearingMintInstruction(instructions[4]).rate,
          123,
        );
        expect(
          parseInitializeScaledUiAmountMintInstruction(
            instructions[5],
          ).multiplier,
          1.5,
        );
        expect(
          parseInitializePausableConfigInstruction(instructions[6]).authority,
          authority,
        );
        expect(
          parseInitializePermissionedBurnInstruction(instructions[7]).authority,
          delegate,
        );
        expect(
          parseInitializeGroupPointerInstruction(instructions[8]).groupAddress,
          metadata,
        );
        expect(
          parseInitializeGroupMemberPointerInstruction(
            instructions[9],
          ).memberAddress,
          delegate,
        );
        expect(
          parseInitializeNonTransferableMintInstruction(
            instructions[10],
          ).discriminator,
          isNonZero,
        );
        expect(
          parseInitializeTransferHookInstruction(instructions[11]).programId,
          delegate,
        );
        expect(
          parseInitializePermanentDelegateInstruction(
            instructions[12],
          ).delegate,
          delegate,
        );
        expect(
          parseInitializeConfidentialTransferFeeInstruction(
            instructions[13],
          ).withdrawWithheldAuthorityElGamalPubkey,
          metadata,
        );
        expect(
          parseInitializeMintCloseAuthorityInstruction(
            instructions[14],
          ).closeAuthority,
          delegate,
        );
      },
    );

    test('throws when ExtensionPermissionedBurn authority is null', () {
      expect(
        () => getPreInitializeInstructionsForMintExtensions(
          mint: mint,
          extensions: const <Extension>[
            ExtensionPermissionedBurn(authority: null),
          ],
        ),
        throwsArgumentError,
      );
    });
  });

  group('TLV extension region', () {
    // The program stops walking the TLV region at the first `Uninitialized`
    // (type 0) header, or when fewer than two bytes remain, and ignores
    // whatever follows. Accounts are allocated with spare room of any size —
    // including the two-byte padding that keeps a mint from colliding with the
    // multisig account length — so decoding must not consume that tail as
    // extensions.
    Mint mintWith(List<Extension>? extensions) => Mint(
      mintAuthority: authority,
      supply: BigInt.zero,
      decimals: 6,
      isInitialized: true,
      freezeAuthority: authority,
      extensions: extensions,
    );

    test('decodes an account with unused trailing space', () {
      final encoded = getMintEncoder().encode(
        mintWith(<Extension>[
          const ExtensionMetadataPointer(
            authority: authority,
            metadataAddress: metadata,
          ),
        ]),
      );

      for (final padding in [1, 2, 5, 6, 8]) {
        final padded = Uint8List(encoded.length + padding)..setAll(0, encoded);

        final decoded = getMintDecoder().decode(padded);

        expect(
          decoded.extensions,
          hasLength(1),
          reason:
              '$padding bytes of unused space must not decode as extensions',
        );
        expect(decoded.extensions!.single, isA<ExtensionMetadataPointer>());
      }
    });

    test('never reports Uninitialized padding as an extension', () {
      final encoded = getMintEncoder().encode(
        mintWith(<Extension>[
          const ExtensionCpiGuard(lockCpi: true),
        ]),
      );
      final padded = Uint8List(encoded.length + 2)..setAll(0, encoded);

      final decoded = getMintDecoder().decode(padded);

      expect(decoded.extensions, hasLength(1));
      expect(
        decoded.extensions!.whereType<ExtensionUninitialized>(),
        isEmpty,
      );
    });

    test('round-trips a token account with unused trailing space', () {
      final encoded = getTokenEncoder().encode(
        Token(
          mint: mint,
          owner: authority,
          amount: BigInt.zero,
          delegate: null,
          state: AccountState.initialized,
          isNative: null,
          delegatedAmount: BigInt.zero,
          closeAuthority: null,
          extensions: const <Extension>[
            ExtensionMemoTransfer(requireIncomingTransferMemos: true),
          ],
        ),
      );
      final padded = Uint8List(encoded.length + 6)..setAll(0, encoded);

      final decoded = getTokenDecoder().decode(padded);

      expect(decoded.extensions, hasLength(1));
      expect(decoded.extensions!.single, isA<ExtensionMemoTransfer>());
    });
  });
}
