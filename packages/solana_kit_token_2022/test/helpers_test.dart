import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
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
        const MetadataPointer(authority: authority, metadataAddress: metadata),
        InterestBearingConfig(
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
        const MemoTransfer(requireIncomingTransferMemos: true),
        const CpiGuard(lockCpi: true),
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
          TransferFeeConfig(
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
          const MetadataPointer(
            authority: authority,
            metadataAddress: metadata,
          ),
          const MintCloseAuthority(closeAuthority: delegate),
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
            const ConfidentialTransferMint(
              authority: authority,
              autoApproveNewAccounts: true,
              auditorElgamalPubkey: metadata,
            ),
            const DefaultAccountState(state: AccountState.frozen),
            TransferFeeConfig(
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
            const MetadataPointer(
              authority: authority,
              metadataAddress: metadata,
            ),
            InterestBearingConfig(
              rateAuthority: authority,
              initializationTimestamp: BigInt.zero,
              preUpdateAverageRate: 1,
              lastUpdateTimestamp: BigInt.one,
              currentRate: 123,
            ),
            ScaledUiAmountConfig(
              authority: authority,
              multiplier: 1.5,
              newMultiplierEffectiveTimestamp: BigInt.from(2),
              newMultiplier: 2.5,
            ),
            const PausableConfig(authority: authority, paused: false),
            const PermissionedBurn(authority: delegate),
            const GroupPointer(authority: authority, groupAddress: metadata),
            const GroupMemberPointer(
              authority: authority,
              memberAddress: delegate,
            ),
            const NonTransferable(),
            const TransferHook(authority: authority, programId: delegate),
            const PermanentDelegate(delegate: delegate),
            ConfidentialTransferFee(
              authority: authority,
              elgamalPubkey: metadata,
              harvestToMintEnabled: true,
              withheldAmount: Uint8List(0),
            ),
            const MintCloseAuthority(closeAuthority: delegate),
            const MemoTransfer(requireIncomingTransferMemos: true),
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

    test('throws when PermissionedBurn authority is null', () {
      expect(
        () => getPreInitializeInstructionsForMintExtensions(
          mint: mint,
          extensions: const <Extension>[PermissionedBurn(authority: null)],
        ),
        throwsArgumentError,
      );
    });
  });
}
