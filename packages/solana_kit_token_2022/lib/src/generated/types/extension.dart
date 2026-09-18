// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';

import './account_state.dart';
import './decryptable_balance.dart';
import './encrypted_balance.dart';
import './transfer_fee.dart';

sealed class Extension {
  const Extension();
}

final class ExtensionUninitialized extends Extension {
  const ExtensionUninitialized();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ExtensionUninitialized;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'Extension.Uninitialized()';
}

final class ExtensionTransferFeeConfig extends Extension {
  const ExtensionTransferFeeConfig({
    required this.transferFeeConfigAuthority,
    required this.withdrawWithheldAuthority,
    required this.withheldAmount,
    required this.olderTransferFee,
    required this.newerTransferFee,
  });

  final Address transferFeeConfigAuthority;
  final Address withdrawWithheldAuthority;
  final BigInt withheldAmount;
  final TransferFee olderTransferFee;
  final TransferFee newerTransferFee;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExtensionTransferFeeConfig &&
          transferFeeConfigAuthority == other.transferFeeConfigAuthority &&
          withdrawWithheldAuthority == other.withdrawWithheldAuthority &&
          withheldAmount == other.withheldAmount &&
          olderTransferFee == other.olderTransferFee &&
          newerTransferFee == other.newerTransferFee;

  @override
  int get hashCode => Object.hash(
    transferFeeConfigAuthority,
    withdrawWithheldAuthority,
    withheldAmount,
    olderTransferFee,
    newerTransferFee,
  );

  @override
  String toString() =>
      'Extension.TransferFeeConfig(transferFeeConfigAuthority: $transferFeeConfigAuthority, withdrawWithheldAuthority: $withdrawWithheldAuthority, withheldAmount: $withheldAmount, olderTransferFee: $olderTransferFee, newerTransferFee: $newerTransferFee)';
}

final class ExtensionTransferFeeAmount extends Extension {
  const ExtensionTransferFeeAmount({
    required this.withheldAmount,
  });

  final BigInt withheldAmount;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExtensionTransferFeeAmount &&
          withheldAmount == other.withheldAmount;

  @override
  int get hashCode => withheldAmount.hashCode;

  @override
  String toString() =>
      'Extension.TransferFeeAmount(withheldAmount: $withheldAmount)';
}

final class ExtensionMintCloseAuthority extends Extension {
  const ExtensionMintCloseAuthority({
    required this.closeAuthority,
  });

  final Address closeAuthority;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExtensionMintCloseAuthority &&
          closeAuthority == other.closeAuthority;

  @override
  int get hashCode => closeAuthority.hashCode;

  @override
  String toString() =>
      'Extension.MintCloseAuthority(closeAuthority: $closeAuthority)';
}

final class ExtensionConfidentialTransferMint extends Extension {
  const ExtensionConfidentialTransferMint({
    required this.authority,
    required this.autoApproveNewAccounts,
    required this.auditorElgamalPubkey,
  });

  final Address? authority;
  final bool autoApproveNewAccounts;
  final Address? auditorElgamalPubkey;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExtensionConfidentialTransferMint &&
          authority == other.authority &&
          autoApproveNewAccounts == other.autoApproveNewAccounts &&
          auditorElgamalPubkey == other.auditorElgamalPubkey;

  @override
  int get hashCode =>
      Object.hash(authority, autoApproveNewAccounts, auditorElgamalPubkey);

  @override
  String toString() =>
      'Extension.ConfidentialTransferMint(authority: $authority, autoApproveNewAccounts: $autoApproveNewAccounts, auditorElgamalPubkey: $auditorElgamalPubkey)';
}

final class ExtensionConfidentialTransferAccount extends Extension {
  const ExtensionConfidentialTransferAccount({
    required this.approved,
    required this.elgamalPubkey,
    required this.pendingBalanceLow,
    required this.pendingBalanceHigh,
    required this.availableBalance,
    required this.decryptableAvailableBalance,
    required this.allowConfidentialCredits,
    required this.allowNonConfidentialCredits,
    required this.pendingBalanceCreditCounter,
    required this.maximumPendingBalanceCreditCounter,
    required this.expectedPendingBalanceCreditCounter,
    required this.actualPendingBalanceCreditCounter,
  });

  final bool approved;
  final Address elgamalPubkey;
  final EncryptedBalance pendingBalanceLow;
  final EncryptedBalance pendingBalanceHigh;
  final EncryptedBalance availableBalance;
  final DecryptableBalance decryptableAvailableBalance;
  final bool allowConfidentialCredits;
  final bool allowNonConfidentialCredits;
  final BigInt pendingBalanceCreditCounter;
  final BigInt maximumPendingBalanceCreditCounter;
  final BigInt expectedPendingBalanceCreditCounter;
  final BigInt actualPendingBalanceCreditCounter;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExtensionConfidentialTransferAccount &&
          approved == other.approved &&
          elgamalPubkey == other.elgamalPubkey &&
          pendingBalanceLow == other.pendingBalanceLow &&
          pendingBalanceHigh == other.pendingBalanceHigh &&
          availableBalance == other.availableBalance &&
          decryptableAvailableBalance == other.decryptableAvailableBalance &&
          allowConfidentialCredits == other.allowConfidentialCredits &&
          allowNonConfidentialCredits == other.allowNonConfidentialCredits &&
          pendingBalanceCreditCounter == other.pendingBalanceCreditCounter &&
          maximumPendingBalanceCreditCounter ==
              other.maximumPendingBalanceCreditCounter &&
          expectedPendingBalanceCreditCounter ==
              other.expectedPendingBalanceCreditCounter &&
          actualPendingBalanceCreditCounter ==
              other.actualPendingBalanceCreditCounter;

  @override
  int get hashCode => Object.hash(
    approved,
    elgamalPubkey,
    pendingBalanceLow,
    pendingBalanceHigh,
    availableBalance,
    decryptableAvailableBalance,
    allowConfidentialCredits,
    allowNonConfidentialCredits,
    pendingBalanceCreditCounter,
    maximumPendingBalanceCreditCounter,
    expectedPendingBalanceCreditCounter,
    actualPendingBalanceCreditCounter,
  );

  @override
  String toString() =>
      'Extension.ConfidentialTransferAccount(approved: $approved, elgamalPubkey: $elgamalPubkey, pendingBalanceLow: $pendingBalanceLow, pendingBalanceHigh: $pendingBalanceHigh, availableBalance: $availableBalance, decryptableAvailableBalance: $decryptableAvailableBalance, allowConfidentialCredits: $allowConfidentialCredits, allowNonConfidentialCredits: $allowNonConfidentialCredits, pendingBalanceCreditCounter: $pendingBalanceCreditCounter, maximumPendingBalanceCreditCounter: $maximumPendingBalanceCreditCounter, expectedPendingBalanceCreditCounter: $expectedPendingBalanceCreditCounter, actualPendingBalanceCreditCounter: $actualPendingBalanceCreditCounter)';
}

final class ExtensionDefaultAccountState extends Extension {
  const ExtensionDefaultAccountState({
    required this.state,
  });

  final AccountState state;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExtensionDefaultAccountState && state == other.state;

  @override
  int get hashCode => state.hashCode;

  @override
  String toString() => 'Extension.DefaultAccountState(state: $state)';
}

final class ExtensionImmutableOwner extends Extension {
  const ExtensionImmutableOwner();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ExtensionImmutableOwner && true;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'Extension.ImmutableOwner()';
}

final class ExtensionMemoTransfer extends Extension {
  const ExtensionMemoTransfer({
    required this.requireIncomingTransferMemos,
  });

  final bool requireIncomingTransferMemos;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExtensionMemoTransfer &&
          requireIncomingTransferMemos == other.requireIncomingTransferMemos;

  @override
  int get hashCode => requireIncomingTransferMemos.hashCode;

  @override
  String toString() =>
      'Extension.MemoTransfer(requireIncomingTransferMemos: $requireIncomingTransferMemos)';
}

final class ExtensionNonTransferable extends Extension {
  const ExtensionNonTransferable();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ExtensionNonTransferable && true;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'Extension.NonTransferable()';
}

final class ExtensionInterestBearingConfig extends Extension {
  const ExtensionInterestBearingConfig({
    required this.rateAuthority,
    required this.initializationTimestamp,
    required this.preUpdateAverageRate,
    required this.lastUpdateTimestamp,
    required this.currentRate,
  });

  final Address rateAuthority;
  final BigInt initializationTimestamp;
  final int preUpdateAverageRate;
  final BigInt lastUpdateTimestamp;
  final int currentRate;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExtensionInterestBearingConfig &&
          rateAuthority == other.rateAuthority &&
          initializationTimestamp == other.initializationTimestamp &&
          preUpdateAverageRate == other.preUpdateAverageRate &&
          lastUpdateTimestamp == other.lastUpdateTimestamp &&
          currentRate == other.currentRate;

  @override
  int get hashCode => Object.hash(
    rateAuthority,
    initializationTimestamp,
    preUpdateAverageRate,
    lastUpdateTimestamp,
    currentRate,
  );

  @override
  String toString() =>
      'Extension.InterestBearingConfig(rateAuthority: $rateAuthority, initializationTimestamp: $initializationTimestamp, preUpdateAverageRate: $preUpdateAverageRate, lastUpdateTimestamp: $lastUpdateTimestamp, currentRate: $currentRate)';
}

final class ExtensionCpiGuard extends Extension {
  const ExtensionCpiGuard({
    required this.lockCpi,
  });

  final bool lockCpi;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExtensionCpiGuard && lockCpi == other.lockCpi;

  @override
  int get hashCode => lockCpi.hashCode;

  @override
  String toString() => 'Extension.CpiGuard(lockCpi: $lockCpi)';
}

final class ExtensionPermanentDelegate extends Extension {
  const ExtensionPermanentDelegate({
    required this.delegate,
  });

  final Address delegate;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExtensionPermanentDelegate && delegate == other.delegate;

  @override
  int get hashCode => delegate.hashCode;

  @override
  String toString() => 'Extension.PermanentDelegate(delegate: $delegate)';
}

final class ExtensionNonTransferableAccount extends Extension {
  const ExtensionNonTransferableAccount();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExtensionNonTransferableAccount && true;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'Extension.NonTransferableAccount()';
}

final class ExtensionTransferHook extends Extension {
  const ExtensionTransferHook({
    required this.authority,
    required this.programId,
  });

  final Address authority;
  final Address programId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExtensionTransferHook &&
          authority == other.authority &&
          programId == other.programId;

  @override
  int get hashCode => Object.hash(authority, programId);

  @override
  String toString() =>
      'Extension.TransferHook(authority: $authority, programId: $programId)';
}

final class ExtensionTransferHookAccount extends Extension {
  const ExtensionTransferHookAccount({
    required this.transferring,
  });

  final bool transferring;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExtensionTransferHookAccount &&
          transferring == other.transferring;

  @override
  int get hashCode => transferring.hashCode;

  @override
  String toString() =>
      'Extension.TransferHookAccount(transferring: $transferring)';
}

final class ExtensionConfidentialTransferFee extends Extension {
  const ExtensionConfidentialTransferFee({
    required this.authority,
    required this.elgamalPubkey,
    required this.harvestToMintEnabled,
    required this.withheldAmount,
  });

  final Address? authority;
  final Address elgamalPubkey;
  final bool harvestToMintEnabled;
  final EncryptedBalance withheldAmount;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExtensionConfidentialTransferFee &&
          authority == other.authority &&
          elgamalPubkey == other.elgamalPubkey &&
          harvestToMintEnabled == other.harvestToMintEnabled &&
          withheldAmount == other.withheldAmount;

  @override
  int get hashCode => Object.hash(
    authority,
    elgamalPubkey,
    harvestToMintEnabled,
    withheldAmount,
  );

  @override
  String toString() =>
      'Extension.ConfidentialTransferFee(authority: $authority, elgamalPubkey: $elgamalPubkey, harvestToMintEnabled: $harvestToMintEnabled, withheldAmount: $withheldAmount)';
}

final class ExtensionConfidentialTransferFeeAmount extends Extension {
  const ExtensionConfidentialTransferFeeAmount({
    required this.withheldAmount,
  });

  final EncryptedBalance withheldAmount;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExtensionConfidentialTransferFeeAmount &&
          withheldAmount == other.withheldAmount;

  @override
  int get hashCode => withheldAmount.hashCode;

  @override
  String toString() =>
      'Extension.ConfidentialTransferFeeAmount(withheldAmount: $withheldAmount)';
}

final class ExtensionMetadataPointer extends Extension {
  const ExtensionMetadataPointer({
    required this.authority,
    required this.metadataAddress,
  });

  final Address? authority;
  final Address? metadataAddress;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExtensionMetadataPointer &&
          authority == other.authority &&
          metadataAddress == other.metadataAddress;

  @override
  int get hashCode => Object.hash(authority, metadataAddress);

  @override
  String toString() =>
      'Extension.MetadataPointer(authority: $authority, metadataAddress: $metadataAddress)';
}

final class ExtensionTokenMetadata extends Extension {
  const ExtensionTokenMetadata({
    required this.updateAuthority,
    required this.mint,
    required this.name,
    required this.symbol,
    required this.uri,
    required this.additionalMetadata,
  });

  final Address? updateAuthority;
  final Address mint;
  final String name;
  final String symbol;
  final String uri;
  final Map<String, String> additionalMetadata;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExtensionTokenMetadata &&
          updateAuthority == other.updateAuthority &&
          mint == other.mint &&
          name == other.name &&
          symbol == other.symbol &&
          uri == other.uri &&
          additionalMetadata == other.additionalMetadata;

  @override
  int get hashCode =>
      Object.hash(updateAuthority, mint, name, symbol, uri, additionalMetadata);

  @override
  String toString() =>
      'Extension.TokenMetadata(updateAuthority: $updateAuthority, mint: $mint, name: $name, symbol: $symbol, uri: $uri, additionalMetadata: $additionalMetadata)';
}

final class ExtensionGroupPointer extends Extension {
  const ExtensionGroupPointer({
    required this.authority,
    required this.groupAddress,
  });

  final Address? authority;
  final Address? groupAddress;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExtensionGroupPointer &&
          authority == other.authority &&
          groupAddress == other.groupAddress;

  @override
  int get hashCode => Object.hash(authority, groupAddress);

  @override
  String toString() =>
      'Extension.GroupPointer(authority: $authority, groupAddress: $groupAddress)';
}

final class ExtensionTokenGroup extends Extension {
  const ExtensionTokenGroup({
    required this.updateAuthority,
    required this.mint,
    required this.size,
    required this.maxSize,
  });

  final Address? updateAuthority;
  final Address mint;
  final BigInt size;
  final BigInt maxSize;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExtensionTokenGroup &&
          updateAuthority == other.updateAuthority &&
          mint == other.mint &&
          size == other.size &&
          maxSize == other.maxSize;

  @override
  int get hashCode => Object.hash(updateAuthority, mint, size, maxSize);

  @override
  String toString() =>
      'Extension.TokenGroup(updateAuthority: $updateAuthority, mint: $mint, size: $size, maxSize: $maxSize)';
}

final class ExtensionGroupMemberPointer extends Extension {
  const ExtensionGroupMemberPointer({
    required this.authority,
    required this.memberAddress,
  });

  final Address? authority;
  final Address? memberAddress;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExtensionGroupMemberPointer &&
          authority == other.authority &&
          memberAddress == other.memberAddress;

  @override
  int get hashCode => Object.hash(authority, memberAddress);

  @override
  String toString() =>
      'Extension.GroupMemberPointer(authority: $authority, memberAddress: $memberAddress)';
}

final class ExtensionTokenGroupMember extends Extension {
  const ExtensionTokenGroupMember({
    required this.mint,
    required this.group,
    required this.memberNumber,
  });

  final Address mint;
  final Address group;
  final BigInt memberNumber;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExtensionTokenGroupMember &&
          mint == other.mint &&
          group == other.group &&
          memberNumber == other.memberNumber;

  @override
  int get hashCode => Object.hash(mint, group, memberNumber);

  @override
  String toString() =>
      'Extension.TokenGroupMember(mint: $mint, group: $group, memberNumber: $memberNumber)';
}

final class ExtensionConfidentialMintBurn extends Extension {
  const ExtensionConfidentialMintBurn({
    required this.confidentialSupply,
    required this.decryptableSupply,
    required this.supplyElgamalPubkey,
    required this.pendingBurn,
  });

  final EncryptedBalance confidentialSupply;
  final DecryptableBalance decryptableSupply;
  final Address supplyElgamalPubkey;
  final EncryptedBalance pendingBurn;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExtensionConfidentialMintBurn &&
          confidentialSupply == other.confidentialSupply &&
          decryptableSupply == other.decryptableSupply &&
          supplyElgamalPubkey == other.supplyElgamalPubkey &&
          pendingBurn == other.pendingBurn;

  @override
  int get hashCode => Object.hash(
    confidentialSupply,
    decryptableSupply,
    supplyElgamalPubkey,
    pendingBurn,
  );

  @override
  String toString() =>
      'Extension.ConfidentialMintBurn(confidentialSupply: $confidentialSupply, decryptableSupply: $decryptableSupply, supplyElgamalPubkey: $supplyElgamalPubkey, pendingBurn: $pendingBurn)';
}

final class ExtensionScaledUiAmountConfig extends Extension {
  const ExtensionScaledUiAmountConfig({
    required this.authority,
    required this.multiplier,
    required this.newMultiplierEffectiveTimestamp,
    required this.newMultiplier,
  });

  final Address authority;
  final double multiplier;
  final BigInt newMultiplierEffectiveTimestamp;
  final double newMultiplier;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExtensionScaledUiAmountConfig &&
          authority == other.authority &&
          multiplier == other.multiplier &&
          newMultiplierEffectiveTimestamp ==
              other.newMultiplierEffectiveTimestamp &&
          newMultiplier == other.newMultiplier;

  @override
  int get hashCode => Object.hash(
    authority,
    multiplier,
    newMultiplierEffectiveTimestamp,
    newMultiplier,
  );

  @override
  String toString() =>
      'Extension.ScaledUiAmountConfig(authority: $authority, multiplier: $multiplier, newMultiplierEffectiveTimestamp: $newMultiplierEffectiveTimestamp, newMultiplier: $newMultiplier)';
}

final class ExtensionPausableConfig extends Extension {
  const ExtensionPausableConfig({
    required this.authority,
    required this.paused,
  });

  final Address? authority;
  final bool paused;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExtensionPausableConfig &&
          authority == other.authority &&
          paused == other.paused;

  @override
  int get hashCode => Object.hash(authority, paused);

  @override
  String toString() =>
      'Extension.PausableConfig(authority: $authority, paused: $paused)';
}

final class ExtensionPausableAccount extends Extension {
  const ExtensionPausableAccount();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ExtensionPausableAccount && true;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'Extension.PausableAccount()';
}

final class ExtensionPermissionedBurn extends Extension {
  const ExtensionPermissionedBurn({
    required this.authority,
  });

  final Address? authority;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExtensionPermissionedBurn && authority == other.authority;

  @override
  int get hashCode => authority.hashCode;

  @override
  String toString() => 'Extension.PermissionedBurn(authority: $authority)';
}

Encoder<Extension> getExtensionEncoder() {
  return transformEncoder<Map<String, Object?>, Extension>(
    getDiscriminatedUnionEncoder([
      (0, getStructEncoder(<(String, Encoder<Object?>)>[])),
      (
        1,
        getStructEncoder([
          ('transferFeeConfigAuthority', getAddressEncoder()),
          ('withdrawWithheldAuthority', getAddressEncoder()),
          ('withheldAmount', getU64Encoder()),
          ('olderTransferFee', getTransferFeeEncoder()),
          ('newerTransferFee', getTransferFeeEncoder()),
        ]),
      ),
      (2, getStructEncoder([('withheldAmount', getU64Encoder())])),
      (3, getStructEncoder([('closeAuthority', getAddressEncoder())])),
      (
        4,
        getStructEncoder([
          (
            'authority',
            getNullableEncoder<Address>(
              getAddressEncoder(),
              hasPrefix: false,
              noneValue: const ZeroesNoneValue(),
            ),
          ),
          ('autoApproveNewAccounts', getBooleanEncoder()),
          (
            'auditorElgamalPubkey',
            getNullableEncoder<Address>(
              getAddressEncoder(),
              hasPrefix: false,
              noneValue: const ZeroesNoneValue(),
            ),
          ),
        ]),
      ),
      (
        5,
        getStructEncoder([
          ('approved', getBooleanEncoder()),
          ('elgamalPubkey', getAddressEncoder()),
          ('pendingBalanceLow', getEncryptedBalanceEncoder()),
          ('pendingBalanceHigh', getEncryptedBalanceEncoder()),
          ('availableBalance', getEncryptedBalanceEncoder()),
          ('decryptableAvailableBalance', getDecryptableBalanceEncoder()),
          ('allowConfidentialCredits', getBooleanEncoder()),
          ('allowNonConfidentialCredits', getBooleanEncoder()),
          ('pendingBalanceCreditCounter', getU64Encoder()),
          ('maximumPendingBalanceCreditCounter', getU64Encoder()),
          ('expectedPendingBalanceCreditCounter', getU64Encoder()),
          ('actualPendingBalanceCreditCounter', getU64Encoder()),
        ]),
      ),
      (6, getStructEncoder([('state', getAccountStateEncoder())])),
      (7, getStructEncoder([])),
      (
        8,
        getStructEncoder([
          ('requireIncomingTransferMemos', getBooleanEncoder()),
        ]),
      ),
      (9, getStructEncoder([])),
      (
        10,
        getStructEncoder([
          ('rateAuthority', getAddressEncoder()),
          ('initializationTimestamp', getU64Encoder()),
          ('preUpdateAverageRate', getI16Encoder()),
          ('lastUpdateTimestamp', getU64Encoder()),
          ('currentRate', getI16Encoder()),
        ]),
      ),
      (11, getStructEncoder([('lockCpi', getBooleanEncoder())])),
      (12, getStructEncoder([('delegate', getAddressEncoder())])),
      (13, getStructEncoder([])),
      (
        14,
        getStructEncoder([
          ('authority', getAddressEncoder()),
          ('programId', getAddressEncoder()),
        ]),
      ),
      (15, getStructEncoder([('transferring', getBooleanEncoder())])),
      (
        16,
        getStructEncoder([
          (
            'authority',
            getNullableEncoder<Address>(
              getAddressEncoder(),
              hasPrefix: false,
              noneValue: const ZeroesNoneValue(),
            ),
          ),
          ('elgamalPubkey', getAddressEncoder()),
          ('harvestToMintEnabled', getBooleanEncoder()),
          ('withheldAmount', getEncryptedBalanceEncoder()),
        ]),
      ),
      (
        17,
        getStructEncoder([('withheldAmount', getEncryptedBalanceEncoder())]),
      ),
      (
        18,
        getStructEncoder([
          (
            'authority',
            getNullableEncoder<Address>(
              getAddressEncoder(),
              hasPrefix: false,
              noneValue: const ZeroesNoneValue(),
            ),
          ),
          (
            'metadataAddress',
            getNullableEncoder<Address>(
              getAddressEncoder(),
              hasPrefix: false,
              noneValue: const ZeroesNoneValue(),
            ),
          ),
        ]),
      ),
      (
        19,
        getStructEncoder([
          (
            'updateAuthority',
            getNullableEncoder<Address>(
              getAddressEncoder(),
              hasPrefix: false,
              noneValue: const ZeroesNoneValue(),
            ),
          ),
          ('mint', getAddressEncoder()),
          ('name', addEncoderSizePrefix(getUtf8Encoder(), getU32Encoder())),
          ('symbol', addEncoderSizePrefix(getUtf8Encoder(), getU32Encoder())),
          ('uri', addEncoderSizePrefix(getUtf8Encoder(), getU32Encoder())),
          (
            'additionalMetadata',
            getMapEncoder(
              addEncoderSizePrefix(getUtf8Encoder(), getU32Encoder()),
              addEncoderSizePrefix(getUtf8Encoder(), getU32Encoder()),
            ),
          ),
        ]),
      ),
      (
        20,
        getStructEncoder([
          (
            'authority',
            getNullableEncoder<Address>(
              getAddressEncoder(),
              hasPrefix: false,
              noneValue: const ZeroesNoneValue(),
            ),
          ),
          (
            'groupAddress',
            getNullableEncoder<Address>(
              getAddressEncoder(),
              hasPrefix: false,
              noneValue: const ZeroesNoneValue(),
            ),
          ),
        ]),
      ),
      (
        21,
        getStructEncoder([
          (
            'updateAuthority',
            getNullableEncoder<Address>(
              getAddressEncoder(),
              hasPrefix: false,
              noneValue: const ZeroesNoneValue(),
            ),
          ),
          ('mint', getAddressEncoder()),
          ('size', getU64Encoder()),
          ('maxSize', getU64Encoder()),
        ]),
      ),
      (
        22,
        getStructEncoder([
          (
            'authority',
            getNullableEncoder<Address>(
              getAddressEncoder(),
              hasPrefix: false,
              noneValue: const ZeroesNoneValue(),
            ),
          ),
          (
            'memberAddress',
            getNullableEncoder<Address>(
              getAddressEncoder(),
              hasPrefix: false,
              noneValue: const ZeroesNoneValue(),
            ),
          ),
        ]),
      ),
      (
        23,
        getStructEncoder([
          ('mint', getAddressEncoder()),
          ('group', getAddressEncoder()),
          ('memberNumber', getU64Encoder()),
        ]),
      ),
      (
        24,
        getStructEncoder([
          ('confidentialSupply', getEncryptedBalanceEncoder()),
          ('decryptableSupply', getDecryptableBalanceEncoder()),
          ('supplyElgamalPubkey', getAddressEncoder()),
          ('pendingBurn', getEncryptedBalanceEncoder()),
        ]),
      ),
      (
        25,
        getStructEncoder([
          ('authority', getAddressEncoder()),
          ('multiplier', getF64Encoder()),
          ('newMultiplierEffectiveTimestamp', getU64Encoder()),
          ('newMultiplier', getF64Encoder()),
        ]),
      ),
      (
        26,
        getStructEncoder([
          (
            'authority',
            getNullableEncoder<Address>(
              getAddressEncoder(),
              hasPrefix: false,
              noneValue: const ZeroesNoneValue(),
            ),
          ),
          ('paused', getBooleanEncoder()),
        ]),
      ),
      (27, getStructEncoder([])),
      (
        28,
        getStructEncoder([
          (
            'authority',
            getNullableEncoder<Address>(
              getAddressEncoder(),
              hasPrefix: false,
              noneValue: const ZeroesNoneValue(),
            ),
          ),
        ]),
      ),
    ], size: getU16Encoder()),
    (Extension value) => switch (value) {
      ExtensionUninitialized() => <String, Object?>{'__kind': 0},
      ExtensionTransferFeeConfig(
        transferFeeConfigAuthority: final transferFeeConfigAuthority,
        withdrawWithheldAuthority: final withdrawWithheldAuthority,
        withheldAmount: final withheldAmount,
        olderTransferFee: final olderTransferFee,
        newerTransferFee: final newerTransferFee,
      ) =>
        <String, Object?>{
          '__kind': 1,
          'transferFeeConfigAuthority': transferFeeConfigAuthority,
          'withdrawWithheldAuthority': withdrawWithheldAuthority,
          'withheldAmount': withheldAmount,
          'olderTransferFee': olderTransferFee,
          'newerTransferFee': newerTransferFee,
        },
      ExtensionTransferFeeAmount(withheldAmount: final withheldAmount) =>
        <String, Object?>{'__kind': 2, 'withheldAmount': withheldAmount},
      ExtensionMintCloseAuthority(closeAuthority: final closeAuthority) =>
        <String, Object?>{'__kind': 3, 'closeAuthority': closeAuthority},
      ExtensionConfidentialTransferMint(
        authority: final authority,
        autoApproveNewAccounts: final autoApproveNewAccounts,
        auditorElgamalPubkey: final auditorElgamalPubkey,
      ) =>
        <String, Object?>{
          '__kind': 4,
          'authority': authority,
          'autoApproveNewAccounts': autoApproveNewAccounts,
          'auditorElgamalPubkey': auditorElgamalPubkey,
        },
      ExtensionConfidentialTransferAccount(
        approved: final approved,
        elgamalPubkey: final elgamalPubkey,
        pendingBalanceLow: final pendingBalanceLow,
        pendingBalanceHigh: final pendingBalanceHigh,
        availableBalance: final availableBalance,
        decryptableAvailableBalance: final decryptableAvailableBalance,
        allowConfidentialCredits: final allowConfidentialCredits,
        allowNonConfidentialCredits: final allowNonConfidentialCredits,
        pendingBalanceCreditCounter: final pendingBalanceCreditCounter,
        maximumPendingBalanceCreditCounter: final maximumPendingBalanceCreditCounter,
        expectedPendingBalanceCreditCounter: final expectedPendingBalanceCreditCounter,
        actualPendingBalanceCreditCounter: final actualPendingBalanceCreditCounter,
      ) =>
        <String, Object?>{
          '__kind': 5,
          'approved': approved,
          'elgamalPubkey': elgamalPubkey,
          'pendingBalanceLow': pendingBalanceLow,
          'pendingBalanceHigh': pendingBalanceHigh,
          'availableBalance': availableBalance,
          'decryptableAvailableBalance': decryptableAvailableBalance,
          'allowConfidentialCredits': allowConfidentialCredits,
          'allowNonConfidentialCredits': allowNonConfidentialCredits,
          'pendingBalanceCreditCounter': pendingBalanceCreditCounter,
          'maximumPendingBalanceCreditCounter':
              maximumPendingBalanceCreditCounter,
          'expectedPendingBalanceCreditCounter':
              expectedPendingBalanceCreditCounter,
          'actualPendingBalanceCreditCounter':
              actualPendingBalanceCreditCounter,
        },
      ExtensionDefaultAccountState(state: final state) => <String, Object?>{
        '__kind': 6,
        'state': state,
      },
      ExtensionImmutableOwner() => <String, Object?>{'__kind': 7},
      ExtensionMemoTransfer(
        requireIncomingTransferMemos: final requireIncomingTransferMemos,
      ) =>
        <String, Object?>{
          '__kind': 8,
          'requireIncomingTransferMemos': requireIncomingTransferMemos,
        },
      ExtensionNonTransferable() => <String, Object?>{'__kind': 9},
      ExtensionInterestBearingConfig(
        rateAuthority: final rateAuthority,
        initializationTimestamp: final initializationTimestamp,
        preUpdateAverageRate: final preUpdateAverageRate,
        lastUpdateTimestamp: final lastUpdateTimestamp,
        currentRate: final currentRate,
      ) =>
        <String, Object?>{
          '__kind': 10,
          'rateAuthority': rateAuthority,
          'initializationTimestamp': initializationTimestamp,
          'preUpdateAverageRate': preUpdateAverageRate,
          'lastUpdateTimestamp': lastUpdateTimestamp,
          'currentRate': currentRate,
        },
      ExtensionCpiGuard(lockCpi: final lockCpi) => <String, Object?>{
        '__kind': 11,
        'lockCpi': lockCpi,
      },
      ExtensionPermanentDelegate(delegate: final delegate) => <String, Object?>{
        '__kind': 12,
        'delegate': delegate,
      },
      ExtensionNonTransferableAccount() => <String, Object?>{'__kind': 13},
      ExtensionTransferHook(
        authority: final authority,
        programId: final programId,
      ) =>
        <String, Object?>{
          '__kind': 14,
          'authority': authority,
          'programId': programId,
        },
      ExtensionTransferHookAccount(transferring: final transferring) =>
        <String, Object?>{'__kind': 15, 'transferring': transferring},
      ExtensionConfidentialTransferFee(
        authority: final authority,
        elgamalPubkey: final elgamalPubkey,
        harvestToMintEnabled: final harvestToMintEnabled,
        withheldAmount: final withheldAmount,
      ) =>
        <String, Object?>{
          '__kind': 16,
          'authority': authority,
          'elgamalPubkey': elgamalPubkey,
          'harvestToMintEnabled': harvestToMintEnabled,
          'withheldAmount': withheldAmount,
        },
      ExtensionConfidentialTransferFeeAmount(
        withheldAmount: final withheldAmount,
      ) =>
        <String, Object?>{'__kind': 17, 'withheldAmount': withheldAmount},
      ExtensionMetadataPointer(
        authority: final authority,
        metadataAddress: final metadataAddress,
      ) =>
        <String, Object?>{
          '__kind': 18,
          'authority': authority,
          'metadataAddress': metadataAddress,
        },
      ExtensionTokenMetadata(
        updateAuthority: final updateAuthority,
        mint: final mint,
        name: final name,
        symbol: final symbol,
        uri: final uri,
        additionalMetadata: final additionalMetadata,
      ) =>
        <String, Object?>{
          '__kind': 19,
          'updateAuthority': updateAuthority,
          'mint': mint,
          'name': name,
          'symbol': symbol,
          'uri': uri,
          'additionalMetadata': additionalMetadata,
        },
      ExtensionGroupPointer(
        authority: final authority,
        groupAddress: final groupAddress,
      ) =>
        <String, Object?>{
          '__kind': 20,
          'authority': authority,
          'groupAddress': groupAddress,
        },
      ExtensionTokenGroup(
        updateAuthority: final updateAuthority,
        mint: final mint,
        size: final size,
        maxSize: final maxSize,
      ) =>
        <String, Object?>{
          '__kind': 21,
          'updateAuthority': updateAuthority,
          'mint': mint,
          'size': size,
          'maxSize': maxSize,
        },
      ExtensionGroupMemberPointer(
        authority: final authority,
        memberAddress: final memberAddress,
      ) =>
        <String, Object?>{
          '__kind': 22,
          'authority': authority,
          'memberAddress': memberAddress,
        },
      ExtensionTokenGroupMember(
        mint: final mint,
        group: final group,
        memberNumber: final memberNumber,
      ) =>
        <String, Object?>{
          '__kind': 23,
          'mint': mint,
          'group': group,
          'memberNumber': memberNumber,
        },
      ExtensionConfidentialMintBurn(
        confidentialSupply: final confidentialSupply,
        decryptableSupply: final decryptableSupply,
        supplyElgamalPubkey: final supplyElgamalPubkey,
        pendingBurn: final pendingBurn,
      ) =>
        <String, Object?>{
          '__kind': 24,
          'confidentialSupply': confidentialSupply,
          'decryptableSupply': decryptableSupply,
          'supplyElgamalPubkey': supplyElgamalPubkey,
          'pendingBurn': pendingBurn,
        },
      ExtensionScaledUiAmountConfig(
        authority: final authority,
        multiplier: final multiplier,
        newMultiplierEffectiveTimestamp: final newMultiplierEffectiveTimestamp,
        newMultiplier: final newMultiplier,
      ) =>
        <String, Object?>{
          '__kind': 25,
          'authority': authority,
          'multiplier': multiplier,
          'newMultiplierEffectiveTimestamp': newMultiplierEffectiveTimestamp,
          'newMultiplier': newMultiplier,
        },
      ExtensionPausableConfig(
        authority: final authority,
        paused: final paused,
      ) =>
        <String, Object?>{
          '__kind': 26,
          'authority': authority,
          'paused': paused,
        },
      ExtensionPausableAccount() => <String, Object?>{'__kind': 27},
      ExtensionPermissionedBurn(authority: final authority) =>
        <String, Object?>{'__kind': 28, 'authority': authority},
    },
  );
}

Decoder<Extension> getExtensionDecoder() {
  return transformDecoder<Map<String, Object?>, Extension>(
    getDiscriminatedUnionDecoder([
      (
        0,
        transformDecoder<Map<String, Object?>, Map<String, Object?>>(
          getStructDecoder(<(String, Decoder<Object?>)>[]),
          (Map<String, Object?> map, Uint8List bytes, int offset) =>
              <String, Object?>{},
        ),
      ),
      (
        1,
        transformDecoder<Map<String, Object?>, Map<String, Object?>>(
          getStructDecoder([
            ('transferFeeConfigAuthority', getAddressDecoder()),
            ('withdrawWithheldAuthority', getAddressDecoder()),
            ('withheldAmount', getU64Decoder()),
            ('olderTransferFee', getTransferFeeDecoder()),
            ('newerTransferFee', getTransferFeeDecoder()),
          ]),
          (Map<String, Object?> map, Uint8List bytes, int offset) => map,
        ),
      ),
      (
        2,
        transformDecoder<Map<String, Object?>, Map<String, Object?>>(
          getStructDecoder([('withheldAmount', getU64Decoder())]),
          (Map<String, Object?> map, Uint8List bytes, int offset) => map,
        ),
      ),
      (
        3,
        transformDecoder<Map<String, Object?>, Map<String, Object?>>(
          getStructDecoder([('closeAuthority', getAddressDecoder())]),
          (Map<String, Object?> map, Uint8List bytes, int offset) => map,
        ),
      ),
      (
        4,
        transformDecoder<Map<String, Object?>, Map<String, Object?>>(
          getStructDecoder([
            (
              'authority',
              getNullableDecoder<Address>(
                getAddressDecoder(),
                hasPrefix: false,
                noneValue: const ZeroesNoneValue(),
              ),
            ),
            ('autoApproveNewAccounts', getBooleanDecoder()),
            (
              'auditorElgamalPubkey',
              getNullableDecoder<Address>(
                getAddressDecoder(),
                hasPrefix: false,
                noneValue: const ZeroesNoneValue(),
              ),
            ),
          ]),
          (Map<String, Object?> map, Uint8List bytes, int offset) => map,
        ),
      ),
      (
        5,
        transformDecoder<Map<String, Object?>, Map<String, Object?>>(
          getStructDecoder([
            ('approved', getBooleanDecoder()),
            ('elgamalPubkey', getAddressDecoder()),
            ('pendingBalanceLow', getEncryptedBalanceDecoder()),
            ('pendingBalanceHigh', getEncryptedBalanceDecoder()),
            ('availableBalance', getEncryptedBalanceDecoder()),
            ('decryptableAvailableBalance', getDecryptableBalanceDecoder()),
            ('allowConfidentialCredits', getBooleanDecoder()),
            ('allowNonConfidentialCredits', getBooleanDecoder()),
            ('pendingBalanceCreditCounter', getU64Decoder()),
            ('maximumPendingBalanceCreditCounter', getU64Decoder()),
            ('expectedPendingBalanceCreditCounter', getU64Decoder()),
            ('actualPendingBalanceCreditCounter', getU64Decoder()),
          ]),
          (Map<String, Object?> map, Uint8List bytes, int offset) => map,
        ),
      ),
      (
        6,
        transformDecoder<Map<String, Object?>, Map<String, Object?>>(
          getStructDecoder([('state', getAccountStateDecoder())]),
          (Map<String, Object?> map, Uint8List bytes, int offset) => map,
        ),
      ),
      (
        7,
        transformDecoder<Map<String, Object?>, Map<String, Object?>>(
          getStructDecoder([]),
          (Map<String, Object?> map, Uint8List bytes, int offset) => map,
        ),
      ),
      (
        8,
        transformDecoder<Map<String, Object?>, Map<String, Object?>>(
          getStructDecoder([
            ('requireIncomingTransferMemos', getBooleanDecoder()),
          ]),
          (Map<String, Object?> map, Uint8List bytes, int offset) => map,
        ),
      ),
      (
        9,
        transformDecoder<Map<String, Object?>, Map<String, Object?>>(
          getStructDecoder([]),
          (Map<String, Object?> map, Uint8List bytes, int offset) => map,
        ),
      ),
      (
        10,
        transformDecoder<Map<String, Object?>, Map<String, Object?>>(
          getStructDecoder([
            ('rateAuthority', getAddressDecoder()),
            ('initializationTimestamp', getU64Decoder()),
            ('preUpdateAverageRate', getI16Decoder()),
            ('lastUpdateTimestamp', getU64Decoder()),
            ('currentRate', getI16Decoder()),
          ]),
          (Map<String, Object?> map, Uint8List bytes, int offset) => map,
        ),
      ),
      (
        11,
        transformDecoder<Map<String, Object?>, Map<String, Object?>>(
          getStructDecoder([('lockCpi', getBooleanDecoder())]),
          (Map<String, Object?> map, Uint8List bytes, int offset) => map,
        ),
      ),
      (
        12,
        transformDecoder<Map<String, Object?>, Map<String, Object?>>(
          getStructDecoder([('delegate', getAddressDecoder())]),
          (Map<String, Object?> map, Uint8List bytes, int offset) => map,
        ),
      ),
      (
        13,
        transformDecoder<Map<String, Object?>, Map<String, Object?>>(
          getStructDecoder([]),
          (Map<String, Object?> map, Uint8List bytes, int offset) => map,
        ),
      ),
      (
        14,
        transformDecoder<Map<String, Object?>, Map<String, Object?>>(
          getStructDecoder([
            ('authority', getAddressDecoder()),
            ('programId', getAddressDecoder()),
          ]),
          (Map<String, Object?> map, Uint8List bytes, int offset) => map,
        ),
      ),
      (
        15,
        transformDecoder<Map<String, Object?>, Map<String, Object?>>(
          getStructDecoder([('transferring', getBooleanDecoder())]),
          (Map<String, Object?> map, Uint8List bytes, int offset) => map,
        ),
      ),
      (
        16,
        transformDecoder<Map<String, Object?>, Map<String, Object?>>(
          getStructDecoder([
            (
              'authority',
              getNullableDecoder<Address>(
                getAddressDecoder(),
                hasPrefix: false,
                noneValue: const ZeroesNoneValue(),
              ),
            ),
            ('elgamalPubkey', getAddressDecoder()),
            ('harvestToMintEnabled', getBooleanDecoder()),
            ('withheldAmount', getEncryptedBalanceDecoder()),
          ]),
          (Map<String, Object?> map, Uint8List bytes, int offset) => map,
        ),
      ),
      (
        17,
        transformDecoder<Map<String, Object?>, Map<String, Object?>>(
          getStructDecoder([('withheldAmount', getEncryptedBalanceDecoder())]),
          (Map<String, Object?> map, Uint8List bytes, int offset) => map,
        ),
      ),
      (
        18,
        transformDecoder<Map<String, Object?>, Map<String, Object?>>(
          getStructDecoder([
            (
              'authority',
              getNullableDecoder<Address>(
                getAddressDecoder(),
                hasPrefix: false,
                noneValue: const ZeroesNoneValue(),
              ),
            ),
            (
              'metadataAddress',
              getNullableDecoder<Address>(
                getAddressDecoder(),
                hasPrefix: false,
                noneValue: const ZeroesNoneValue(),
              ),
            ),
          ]),
          (Map<String, Object?> map, Uint8List bytes, int offset) => map,
        ),
      ),
      (
        19,
        transformDecoder<Map<String, Object?>, Map<String, Object?>>(
          getStructDecoder([
            (
              'updateAuthority',
              getNullableDecoder<Address>(
                getAddressDecoder(),
                hasPrefix: false,
                noneValue: const ZeroesNoneValue(),
              ),
            ),
            ('mint', getAddressDecoder()),
            ('name', addDecoderSizePrefix(getUtf8Decoder(), getU32Decoder())),
            ('symbol', addDecoderSizePrefix(getUtf8Decoder(), getU32Decoder())),
            ('uri', addDecoderSizePrefix(getUtf8Decoder(), getU32Decoder())),
            (
              'additionalMetadata',
              getMapDecoder(
                addDecoderSizePrefix(getUtf8Decoder(), getU32Decoder()),
                addDecoderSizePrefix(getUtf8Decoder(), getU32Decoder()),
              ),
            ),
          ]),
          (Map<String, Object?> map, Uint8List bytes, int offset) => map,
        ),
      ),
      (
        20,
        transformDecoder<Map<String, Object?>, Map<String, Object?>>(
          getStructDecoder([
            (
              'authority',
              getNullableDecoder<Address>(
                getAddressDecoder(),
                hasPrefix: false,
                noneValue: const ZeroesNoneValue(),
              ),
            ),
            (
              'groupAddress',
              getNullableDecoder<Address>(
                getAddressDecoder(),
                hasPrefix: false,
                noneValue: const ZeroesNoneValue(),
              ),
            ),
          ]),
          (Map<String, Object?> map, Uint8List bytes, int offset) => map,
        ),
      ),
      (
        21,
        transformDecoder<Map<String, Object?>, Map<String, Object?>>(
          getStructDecoder([
            (
              'updateAuthority',
              getNullableDecoder<Address>(
                getAddressDecoder(),
                hasPrefix: false,
                noneValue: const ZeroesNoneValue(),
              ),
            ),
            ('mint', getAddressDecoder()),
            ('size', getU64Decoder()),
            ('maxSize', getU64Decoder()),
          ]),
          (Map<String, Object?> map, Uint8List bytes, int offset) => map,
        ),
      ),
      (
        22,
        transformDecoder<Map<String, Object?>, Map<String, Object?>>(
          getStructDecoder([
            (
              'authority',
              getNullableDecoder<Address>(
                getAddressDecoder(),
                hasPrefix: false,
                noneValue: const ZeroesNoneValue(),
              ),
            ),
            (
              'memberAddress',
              getNullableDecoder<Address>(
                getAddressDecoder(),
                hasPrefix: false,
                noneValue: const ZeroesNoneValue(),
              ),
            ),
          ]),
          (Map<String, Object?> map, Uint8List bytes, int offset) => map,
        ),
      ),
      (
        23,
        transformDecoder<Map<String, Object?>, Map<String, Object?>>(
          getStructDecoder([
            ('mint', getAddressDecoder()),
            ('group', getAddressDecoder()),
            ('memberNumber', getU64Decoder()),
          ]),
          (Map<String, Object?> map, Uint8List bytes, int offset) => map,
        ),
      ),
      (
        24,
        transformDecoder<Map<String, Object?>, Map<String, Object?>>(
          getStructDecoder([
            ('confidentialSupply', getEncryptedBalanceDecoder()),
            ('decryptableSupply', getDecryptableBalanceDecoder()),
            ('supplyElgamalPubkey', getAddressDecoder()),
            ('pendingBurn', getEncryptedBalanceDecoder()),
          ]),
          (Map<String, Object?> map, Uint8List bytes, int offset) => map,
        ),
      ),
      (
        25,
        transformDecoder<Map<String, Object?>, Map<String, Object?>>(
          getStructDecoder([
            ('authority', getAddressDecoder()),
            ('multiplier', getF64Decoder()),
            ('newMultiplierEffectiveTimestamp', getU64Decoder()),
            ('newMultiplier', getF64Decoder()),
          ]),
          (Map<String, Object?> map, Uint8List bytes, int offset) => map,
        ),
      ),
      (
        26,
        transformDecoder<Map<String, Object?>, Map<String, Object?>>(
          getStructDecoder([
            (
              'authority',
              getNullableDecoder<Address>(
                getAddressDecoder(),
                hasPrefix: false,
                noneValue: const ZeroesNoneValue(),
              ),
            ),
            ('paused', getBooleanDecoder()),
          ]),
          (Map<String, Object?> map, Uint8List bytes, int offset) => map,
        ),
      ),
      (
        27,
        transformDecoder<Map<String, Object?>, Map<String, Object?>>(
          getStructDecoder([]),
          (Map<String, Object?> map, Uint8List bytes, int offset) => map,
        ),
      ),
      (
        28,
        transformDecoder<Map<String, Object?>, Map<String, Object?>>(
          getStructDecoder([
            (
              'authority',
              getNullableDecoder<Address>(
                getAddressDecoder(),
                hasPrefix: false,
                noneValue: const ZeroesNoneValue(),
              ),
            ),
          ]),
          (Map<String, Object?> map, Uint8List bytes, int offset) => map,
        ),
      ),
    ], size: getU16Decoder()),
    (Map<String, Object?> map, Uint8List bytes, int offset) {
      switch (map['__kind']) {
        case 0:
          return const ExtensionUninitialized();
        case 1:
          return ExtensionTransferFeeConfig(
            transferFeeConfigAuthority:
                map['transferFeeConfigAuthority']! as Address,
            withdrawWithheldAuthority:
                map['withdrawWithheldAuthority']! as Address,
            withheldAmount: map['withheldAmount']! as BigInt,
            olderTransferFee: map['olderTransferFee']! as TransferFee,
            newerTransferFee: map['newerTransferFee']! as TransferFee,
          );
        case 2:
          return ExtensionTransferFeeAmount(
            withheldAmount: map['withheldAmount']! as BigInt,
          );
        case 3:
          return ExtensionMintCloseAuthority(
            closeAuthority: map['closeAuthority']! as Address,
          );
        case 4:
          return ExtensionConfidentialTransferMint(
            authority: map['authority'] as Address?,
            autoApproveNewAccounts: map['autoApproveNewAccounts']! as bool,
            auditorElgamalPubkey: map['auditorElgamalPubkey'] as Address?,
          );
        case 5:
          return ExtensionConfidentialTransferAccount(
            approved: map['approved']! as bool,
            elgamalPubkey: map['elgamalPubkey']! as Address,
            pendingBalanceLow: map['pendingBalanceLow']! as EncryptedBalance,
            pendingBalanceHigh: map['pendingBalanceHigh']! as EncryptedBalance,
            availableBalance: map['availableBalance']! as EncryptedBalance,
            decryptableAvailableBalance:
                map['decryptableAvailableBalance']! as DecryptableBalance,
            allowConfidentialCredits: map['allowConfidentialCredits']! as bool,
            allowNonConfidentialCredits:
                map['allowNonConfidentialCredits']! as bool,
            pendingBalanceCreditCounter:
                map['pendingBalanceCreditCounter']! as BigInt,
            maximumPendingBalanceCreditCounter:
                map['maximumPendingBalanceCreditCounter']! as BigInt,
            expectedPendingBalanceCreditCounter:
                map['expectedPendingBalanceCreditCounter']! as BigInt,
            actualPendingBalanceCreditCounter:
                map['actualPendingBalanceCreditCounter']! as BigInt,
          );
        case 6:
          return ExtensionDefaultAccountState(
            state: map['state']! as AccountState,
          );
        case 7:
          return ExtensionImmutableOwner();
        case 8:
          return ExtensionMemoTransfer(
            requireIncomingTransferMemos:
                map['requireIncomingTransferMemos']! as bool,
          );
        case 9:
          return ExtensionNonTransferable();
        case 10:
          return ExtensionInterestBearingConfig(
            rateAuthority: map['rateAuthority']! as Address,
            initializationTimestamp: map['initializationTimestamp']! as BigInt,
            preUpdateAverageRate: map['preUpdateAverageRate']! as int,
            lastUpdateTimestamp: map['lastUpdateTimestamp']! as BigInt,
            currentRate: map['currentRate']! as int,
          );
        case 11:
          return ExtensionCpiGuard(lockCpi: map['lockCpi']! as bool);
        case 12:
          return ExtensionPermanentDelegate(
            delegate: map['delegate']! as Address,
          );
        case 13:
          return ExtensionNonTransferableAccount();
        case 14:
          return ExtensionTransferHook(
            authority: map['authority']! as Address,
            programId: map['programId']! as Address,
          );
        case 15:
          return ExtensionTransferHookAccount(
            transferring: map['transferring']! as bool,
          );
        case 16:
          return ExtensionConfidentialTransferFee(
            authority: map['authority'] as Address?,
            elgamalPubkey: map['elgamalPubkey']! as Address,
            harvestToMintEnabled: map['harvestToMintEnabled']! as bool,
            withheldAmount: map['withheldAmount']! as EncryptedBalance,
          );
        case 17:
          return ExtensionConfidentialTransferFeeAmount(
            withheldAmount: map['withheldAmount']! as EncryptedBalance,
          );
        case 18:
          return ExtensionMetadataPointer(
            authority: map['authority'] as Address?,
            metadataAddress: map['metadataAddress'] as Address?,
          );
        case 19:
          return ExtensionTokenMetadata(
            updateAuthority: map['updateAuthority'] as Address?,
            mint: map['mint']! as Address,
            name: map['name']! as String,
            symbol: map['symbol']! as String,
            uri: map['uri']! as String,
            additionalMetadata:
                map['additionalMetadata']! as Map<String, String>,
          );
        case 20:
          return ExtensionGroupPointer(
            authority: map['authority'] as Address?,
            groupAddress: map['groupAddress'] as Address?,
          );
        case 21:
          return ExtensionTokenGroup(
            updateAuthority: map['updateAuthority'] as Address?,
            mint: map['mint']! as Address,
            size: map['size']! as BigInt,
            maxSize: map['maxSize']! as BigInt,
          );
        case 22:
          return ExtensionGroupMemberPointer(
            authority: map['authority'] as Address?,
            memberAddress: map['memberAddress'] as Address?,
          );
        case 23:
          return ExtensionTokenGroupMember(
            mint: map['mint']! as Address,
            group: map['group']! as Address,
            memberNumber: map['memberNumber']! as BigInt,
          );
        case 24:
          return ExtensionConfidentialMintBurn(
            confidentialSupply: map['confidentialSupply']! as EncryptedBalance,
            decryptableSupply: map['decryptableSupply']! as DecryptableBalance,
            supplyElgamalPubkey: map['supplyElgamalPubkey']! as Address,
            pendingBurn: map['pendingBurn']! as EncryptedBalance,
          );
        case 25:
          return ExtensionScaledUiAmountConfig(
            authority: map['authority']! as Address,
            multiplier: map['multiplier']! as double,
            newMultiplierEffectiveTimestamp:
                map['newMultiplierEffectiveTimestamp']! as BigInt,
            newMultiplier: map['newMultiplier']! as double,
          );
        case 26:
          return ExtensionPausableConfig(
            authority: map['authority'] as Address?,
            paused: map['paused']! as bool,
          );
        case 27:
          return ExtensionPausableAccount();
        case 28:
          return ExtensionPermissionedBurn(
            authority: map['authority'] as Address?,
          );
      }
      throw StateError('Unsupported Extension discriminator: ${map['__kind']}');
    },
  );
}

Codec<Extension, Extension> getExtensionCodec() {
  return combineCodec(getExtensionEncoder(), getExtensionDecoder());
}
