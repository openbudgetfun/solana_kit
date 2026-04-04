import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_token_2022/solana_kit_token_2022.dart';
import 'package:test/test.dart';

void main() {
  const mint = Address('11111111111111111111111111111111');
  const authority = Address('11111111111111111111111111111112');
  const metadata = Address('11111111111111111111111111111113');
  const delegate = Address('11111111111111111111111111111114');

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
