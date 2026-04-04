import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_token_2022/src/generated/instructions/initialize_confidential_transfer_fee.dart';
import 'package:solana_kit_token_2022/src/generated/instructions/initialize_confidential_transfer_mint.dart';
import 'package:solana_kit_token_2022/src/generated/instructions/initialize_default_account_state.dart';
import 'package:solana_kit_token_2022/src/generated/instructions/initialize_group_member_pointer.dart';
import 'package:solana_kit_token_2022/src/generated/instructions/initialize_group_pointer.dart';
import 'package:solana_kit_token_2022/src/generated/instructions/initialize_interest_bearing_mint.dart';
import 'package:solana_kit_token_2022/src/generated/instructions/initialize_metadata_pointer.dart';
import 'package:solana_kit_token_2022/src/generated/instructions/initialize_mint_close_authority.dart';
import 'package:solana_kit_token_2022/src/generated/instructions/initialize_non_transferable_mint.dart';
import 'package:solana_kit_token_2022/src/generated/instructions/initialize_pausable_config.dart';
import 'package:solana_kit_token_2022/src/generated/instructions/initialize_permanent_delegate.dart';
import 'package:solana_kit_token_2022/src/generated/instructions/initialize_permissioned_burn.dart';
import 'package:solana_kit_token_2022/src/generated/instructions/initialize_scaled_ui_amount_mint.dart';
import 'package:solana_kit_token_2022/src/generated/instructions/initialize_transfer_fee_config.dart';
import 'package:solana_kit_token_2022/src/generated/instructions/initialize_transfer_hook.dart';
import 'package:solana_kit_token_2022/src/generated/programs/token_2022.dart';
import 'package:solana_kit_token_2022/src/generated/types/extension.dart';

/// Returns the instructions that must run before `initializeMint` for the
/// provided mint extensions.
List<Instruction> getPreInitializeInstructionsForMintExtensions({
  required Address mint,
  required List<Extension> extensions,
  Address programAddress = token2022ProgramAddress,
}) {
  return extensions
      .expand((extension) {
        return switch (extension) {
          ConfidentialTransferMint(
            authority: final authority,
            autoApproveNewAccounts: final autoApproveNewAccounts,
            auditorElgamalPubkey: final auditorElgamalPubkey,
          ) =>
            [
              getInitializeConfidentialTransferMintInstruction(
                programAddress: programAddress,
                mint: mint,
                authority: authority,
                autoApproveNewAccounts: autoApproveNewAccounts,
                auditorElgamalPubkey: auditorElgamalPubkey,
              ),
            ],
          DefaultAccountState(state: final state) => [
            getInitializeDefaultAccountStateInstruction(
              programAddress: programAddress,
              mint: mint,
              state: state,
            ),
          ],
          TransferFeeConfig(
            transferFeeConfigAuthority: final transferFeeConfigAuthority,
            withdrawWithheldAuthority: final withdrawWithheldAuthority,
            newerTransferFee: final newerTransferFee,
          ) =>
            [
              getInitializeTransferFeeConfigInstruction(
                programAddress: programAddress,
                mint: mint,
                transferFeeConfigAuthority: transferFeeConfigAuthority,
                withdrawWithheldAuthority: withdrawWithheldAuthority,
                transferFeeBasisPoints: newerTransferFee.transferFeeBasisPoints,
                maximumFee: newerTransferFee.maximumFee,
              ),
            ],
          MetadataPointer(
            authority: final authority,
            metadataAddress: final metadataAddress,
          ) =>
            [
              getInitializeMetadataPointerInstruction(
                programAddress: programAddress,
                mint: mint,
                authority: authority,
                metadataAddress: metadataAddress,
              ),
            ],
          InterestBearingConfig(
            rateAuthority: final rateAuthority,
            currentRate: final currentRate,
          ) =>
            [
              getInitializeInterestBearingMintInstruction(
                programAddress: programAddress,
                mint: mint,
                rateAuthority: rateAuthority,
                rate: currentRate,
              ),
            ],
          ScaledUiAmountConfig(
            authority: final authority,
            multiplier: final multiplier,
          ) =>
            [
              getInitializeScaledUiAmountMintInstruction(
                programAddress: programAddress,
                mint: mint,
                authority: authority,
                multiplier: multiplier,
              ),
            ],
          PausableConfig(authority: final authority) => [
            getInitializePausableConfigInstruction(
              programAddress: programAddress,
              mint: mint,
              authority: authority,
            ),
          ],
          PermissionedBurn(authority: final authority) => [
            getInitializePermissionedBurnInstruction(
              programAddress: programAddress,
              mint: mint,
              authority:
                  authority ??
                  (throw ArgumentError.value(
                    authority,
                    'extensions',
                    'PermissionedBurn requires a non-null authority.',
                  )),
            ),
          ],
          GroupPointer(
            authority: final authority,
            groupAddress: final groupAddress,
          ) =>
            [
              getInitializeGroupPointerInstruction(
                programAddress: programAddress,
                mint: mint,
                authority: authority,
                groupAddress: groupAddress,
              ),
            ],
          GroupMemberPointer(
            authority: final authority,
            memberAddress: final memberAddress,
          ) =>
            [
              getInitializeGroupMemberPointerInstruction(
                programAddress: programAddress,
                mint: mint,
                authority: authority,
                memberAddress: memberAddress,
              ),
            ],
          NonTransferable() => [
            getInitializeNonTransferableMintInstruction(
              programAddress: programAddress,
              mint: mint,
            ),
          ],
          TransferHook(
            authority: final authority,
            programId: final programId,
          ) =>
            [
              getInitializeTransferHookInstruction(
                programAddress: programAddress,
                mint: mint,
                authority: authority,
                programId: programId,
              ),
            ],
          PermanentDelegate(delegate: final delegate) => [
            getInitializePermanentDelegateInstruction(
              programAddress: programAddress,
              mint: mint,
              delegate: delegate,
            ),
          ],
          ConfidentialTransferFee(
            authority: final authority,
            elgamalPubkey: final elgamalPubkey,
          ) =>
            [
              getInitializeConfidentialTransferFeeInstruction(
                programAddress: programAddress,
                mint: mint,
                authority: authority,
                withdrawWithheldAuthorityElGamalPubkey: elgamalPubkey,
              ),
            ],
          MintCloseAuthority(closeAuthority: final closeAuthority) => [
            getInitializeMintCloseAuthorityInstruction(
              programAddress: programAddress,
              mint: mint,
              closeAuthority: closeAuthority,
            ),
          ],
          _ => const <Instruction>[],
        };
      })
      .toList(growable: false);
}
