import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

import 'package:solana_kit_privacy_rings/src/codec/transact.dart';
import 'package:solana_kit_privacy_rings/src/constants.dart';
import 'package:solana_kit_privacy_rings/src/exception.dart';
import 'package:solana_kit_privacy_rings/src/pdas.dart';

/// Where a withdrawal pays a public balance.
sealed class WithdrawalTarget {
  const WithdrawalTarget();
}

/// Withdraw native SOL to [recipient].
class SolWithdrawalTarget extends WithdrawalTarget {
  /// Creates a SOL withdrawal target.
  const SolWithdrawalTarget(this.recipient);

  /// Public SOL recipient.
  final Address recipient;
}

/// Withdraw an SPL or Token-2022 token to [recipientTokenAccount].
class SplWithdrawalTarget extends WithdrawalTarget {
  /// Creates an SPL withdrawal target.
  const SplWithdrawalTarget({
    required this.mint,
    required this.recipientTokenAccount,
    required this.tokenProgram,
    required this.splInterface,
  });

  /// Mint being withdrawn.
  final Address mint;

  /// Recipient token account.
  final Address recipientTokenAccount;

  /// Token program that owns [mint].
  final Address tokenProgram;

  /// The mint's SPL interface PDA.
  final Address splInterface;
}

/// One public settlement leg and the accounts it appends.
///
/// Account order matches `Settlement::accounts` in the Rust Kit client.
sealed class PublicSettlement {
  const PublicSettlement();
}

/// Move public SOL into the pool.
class SolDepositSettlement extends PublicSettlement {
  /// Creates a SOL deposit leg.
  const SolDepositSettlement({required this.funder, required this.amount});

  /// System account that funds the deposit. It must sign.
  final Address funder;

  /// Lamports.
  final BigInt amount;
}

/// Move private SOL to a public system account.
class SolWithdrawalSettlement extends PublicSettlement {
  /// Creates a SOL withdrawal leg.
  const SolWithdrawalSettlement({
    required this.recipient,
    required this.amount,
  });

  /// System account that receives the lamports.
  final Address recipient;

  /// Lamports.
  final BigInt amount;
}

/// Move public SPL into the pool.
class SplDepositSettlement extends PublicSettlement {
  /// Creates an SPL deposit leg.
  const SplDepositSettlement({
    required this.mint,
    required this.splInterface,
    required this.tokenAuthority,
    required this.source,
    required this.tokenProgram,
    required this.amount,
    required this.interfaceBump,
  });

  /// Mint.
  final Address mint;

  /// SPL interface PDA.
  final Address splInterface;

  /// Token-account authority. This account must sign.
  final Address tokenAuthority;

  /// Source token account.
  final Address source;

  /// Token program that owns [mint].
  final Address tokenProgram;

  /// Amount in base units.
  final BigInt amount;

  /// SPL interface bump.
  final int interfaceBump;
}

/// Move private SPL to a public token account.
class SplWithdrawalSettlement extends PublicSettlement {
  /// Creates an SPL withdrawal leg.
  const SplWithdrawalSettlement({
    required this.mint,
    required this.splInterface,
    required this.recipientTokenAccount,
    required this.tokenProgram,
    required this.amount,
    required this.interfaceBump,
  });

  /// Mint.
  final Address mint;

  /// SPL interface PDA.
  final Address splInterface;

  /// Destination token account.
  final Address recipientTokenAccount;

  /// Token program that owns [mint].
  final Address tokenProgram;

  /// Amount in base units.
  final BigInt amount;

  /// SPL interface bump.
  final int interfaceBump;
}

/// Writable cache account and the signer that authorizes the write.
class CacheWriter {
  /// Creates a cache writer.
  const CacheWriter({required this.cache, required this.writer});

  /// Cache account. The instruction marks it writable.
  final Address cache;

  /// Cache writer. This account must sign.
  final Address writer;
}

/// Builds a `transact` instruction.
///
/// Account order matches `Transact::accounts` in the Rust Kit client and
/// `transactInstruction` in
/// `sdk-libs/ts/src/interface/instructions/index.ts`. Tag 16 accepts a
/// confidential signer or confidential EdDSA selector, including the
/// cached forms. Ring selectors are rejected. A cached selector appends
/// the read-only cache and, when it writes, the writable cache plus its
/// signer.
///
/// [inputTrees] lists one or two input trees. When it is omitted, the
/// instruction uses [inputTree] alone. [settlements] is the public-leg
/// list. When it is omitted, [withdrawal] is the single unshield leg.
/// A confidential transfer passes neither.
Future<Instruction> transactInstruction({
  required Address payer,
  required Address inputTree,
  required Address outputTree,
  required List<Address> ownerSigners,
  required TransactInstructionData data,
  WithdrawalTarget? withdrawal,
  List<Address>? inputTrees,
  List<PublicSettlement>? settlements,
  Address? readCache,
  CacheWriter? writeCache,
}) async {
  final circuit = data.circuit;
  if (!circuit.fitsTransact) {
    throw PrivacyRingsException(
      'tag 16 rejects ring circuit ${circuit.kind}',
      code: 'transact_circuit',
    );
  }
  final cache = circuit.cacheAccess;
  final reads = cache?.readsCache ?? false;
  final writes = cache?.writesCache ?? false;
  if (cache != null && !reads && !writes) {
    throw PrivacyRingsException(
      'a cached circuit selects no cache slot',
      code: 'transact_cache',
    );
  }
  if (reads != (readCache != null) || writes != (writeCache != null)) {
    throw PrivacyRingsException(
      'cache accounts do not match the circuit selector',
      code: 'settlement_mismatch',
    );
  }
  final trees = inputTrees ?? [inputTree];
  if (trees.isEmpty || trees.length > 2) {
    throw PrivacyRingsException(
      'transact takes one or two input trees',
      code: 'invalid_shape',
    );
  }
  if (data.treeContexts.length != trees.length ||
      data.inputs.any((input) => input.treeIndex >= trees.length)) {
    throw PrivacyRingsException(
      'input trees do not match the instruction data',
      code: 'invalid_shape',
    );
  }
  if (data.outputs.length > 16) {
    throw PrivacyRingsException(
      'transact takes at most 16 outputs',
      code: 'invalid_length',
    );
  }
  if (settlements != null && withdrawal != null) {
    throw PrivacyRingsException(
      'pass settlements or withdrawal, not both',
      code: 'withdrawal_mismatch',
    );
  }
  if (settlements != null) {
    if (settlements.length > 32) {
      throw PrivacyRingsException(
        'transact takes at most 32 settlement legs',
        code: 'invalid_length',
      );
    }
    _checkSettlements(data, settlements);
  } else {
    _checkWithdrawal(data, withdrawal);
  }
  final accounts = <AccountMeta>[
    AccountMeta(address: payer, role: AccountRole.writableSigner),
    AccountMeta(address: outputTree, role: AccountRole.writable),
    const AccountMeta(
      address: shieldedPoolProgramId,
      role: AccountRole.readonly,
    ),
    const AccountMeta(
      address: systemProgramAddress,
      role: AccountRole.readonly,
    ),
  ];
  for (final tree in trees) {
    accounts.add(AccountMeta(address: tree, role: AccountRole.writable));
  }
  for (final input in data.inputs) {
    accounts.add(
      AccountMeta(
        address: await nullifierPda(
          trees[input.treeIndex],
          input.nullifierHash,
        ),
        role: AccountRole.writable,
      ),
    );
  }
  for (final signer in ownerSigners) {
    accounts.add(
      AccountMeta(address: signer, role: AccountRole.readonlySigner),
    );
  }
  if (settlements != null) {
    for (final settlement in settlements) {
      accounts.addAll(_settlementAccounts(settlement));
    }
  } else {
    accounts.addAll(_withdrawalAccounts(withdrawal));
  }
  if (readCache != null) {
    accounts.add(AccountMeta(address: readCache, role: AccountRole.readonly));
  }
  if (writeCache != null) {
    accounts
      ..add(
        AccountMeta(address: writeCache.cache, role: AccountRole.writable),
      )
      ..add(
        AccountMeta(
          address: writeCache.writer,
          role: AccountRole.readonlySigner,
        ),
      );
  }
  return Instruction(
    programAddress: shieldedPoolProgramId,
    accounts: accounts,
    data: Uint8List.fromList([
      transactInstructionTag,
      ...encodeTransactInstructionData(data),
    ]),
  );
}

/// Confidential transfer: a `transact` with no public withdrawal.
Future<Instruction> confidentialTransferInstruction({
  required Address payer,
  required Address inputTree,
  required Address outputTree,
  required List<Address> ownerSigners,
  required TransactInstructionData data,
}) {
  return transactInstruction(
    payer: payer,
    inputTree: inputTree,
    outputTree: outputTree,
    ownerSigners: ownerSigners,
    data: data,
  );
}

/// Withdrawal (unshield): a `transact` that pays [withdrawal].
Future<Instruction> withdrawInstruction({
  required Address payer,
  required Address inputTree,
  required Address outputTree,
  required List<Address> ownerSigners,
  required WithdrawalTarget withdrawal,
  required TransactInstructionData data,
}) {
  return transactInstruction(
    payer: payer,
    inputTree: inputTree,
    outputTree: outputTree,
    ownerSigners: ownerSigners,
    data: data,
    withdrawal: withdrawal,
  );
}

void _checkWithdrawal(
  TransactInstructionData data,
  WithdrawalTarget? withdrawal,
) {
  final withdrawals = data.interfaceTransfers.where(
    (transfer) =>
        transfer is SolWithdrawalTransfer || transfer is SplWithdrawalTransfer,
  );
  if (withdrawal == null) {
    if (data.interfaceTransfers.isNotEmpty) {
      throw PrivacyRingsException(
        'interface transfers require matching settlements or a withdrawal target',
        code: 'withdrawal_mismatch',
      );
    }
    return;
  }
  if (withdrawals.length != 1 || data.interfaceTransfers.length != 1) {
    throw PrivacyRingsException(
      'this builder supports one withdrawal leg and no other interface transfer',
      code: 'withdrawal_mismatch',
    );
  }
  final leg = data.interfaceTransfers.single;
  switch (withdrawal) {
    case SolWithdrawalTarget() when leg is! SolWithdrawalTransfer:
      throw PrivacyRingsException(
        'withdrawal target is SOL but the instruction data is not',
        code: 'withdrawal_mismatch',
      );
    case SplWithdrawalTarget() when leg is! SplWithdrawalTransfer:
      throw PrivacyRingsException(
        'withdrawal target is SPL but the instruction data is not',
        code: 'withdrawal_mismatch',
      );
    case SolWithdrawalTarget():
    case SplWithdrawalTarget():
      return;
  }
}

List<AccountMeta> _withdrawalAccounts(WithdrawalTarget? withdrawal) {
  if (withdrawal == null) return const [];
  return switch (withdrawal) {
    SolWithdrawalTarget(:final recipient) => _settlementAccounts(
      SolWithdrawalSettlement(recipient: recipient, amount: BigInt.zero),
    ),
    SplWithdrawalTarget(
      :final mint,
      :final recipientTokenAccount,
      :final tokenProgram,
      :final splInterface,
    ) =>
      _settlementAccounts(
        SplWithdrawalSettlement(
          mint: mint,
          splInterface: splInterface,
          recipientTokenAccount: recipientTokenAccount,
          tokenProgram: tokenProgram,
          amount: BigInt.zero,
          interfaceBump: 0,
        ),
      ),
  };
}

void _checkSettlements(
  TransactInstructionData data,
  List<PublicSettlement> settlements,
) {
  if (settlements.length != data.interfaceTransfers.length) {
    throw PrivacyRingsException(
      'settlement accounts do not match the instruction data',
      code: 'settlement_mismatch',
    );
  }
  for (var i = 0; i < settlements.length; i++) {
    final settlement = settlements[i];
    final transfer = data.interfaceTransfers[i];
    final matches = switch (settlement) {
      SolDepositSettlement(:final amount) =>
        transfer is SolDepositTransfer && transfer.amount == amount,
      SolWithdrawalSettlement(:final amount) =>
        transfer is SolWithdrawalTransfer && transfer.amount == amount,
      SplDepositSettlement(:final amount, :final interfaceBump) =>
        transfer is SplDepositTransfer &&
            transfer.amount == amount &&
            transfer.splInterfaceBump == interfaceBump,
      SplWithdrawalSettlement(:final amount, :final interfaceBump) =>
        transfer is SplWithdrawalTransfer &&
            transfer.amount == amount &&
            transfer.splInterfaceBump == interfaceBump,
    };
    if (!matches) {
      throw PrivacyRingsException(
        'settlement leg $i does not match the instruction data',
        code: 'settlement_mismatch',
      );
    }
  }
}

List<AccountMeta> _settlementAccounts(PublicSettlement settlement) {
  return switch (settlement) {
    SolDepositSettlement(:final funder) => [
      const AccountMeta(
        address: solInterfaceAddress,
        role: AccountRole.writable,
      ),
      AccountMeta(address: funder, role: AccountRole.writableSigner),
    ],
    SolWithdrawalSettlement(:final recipient) => [
      const AccountMeta(
        address: solInterfaceAddress,
        role: AccountRole.writable,
      ),
      AccountMeta(address: recipient, role: AccountRole.writable),
    ],
    SplDepositSettlement(
      :final mint,
      :final splInterface,
      :final tokenAuthority,
      :final source,
      :final tokenProgram,
    ) =>
      [
        AccountMeta(address: mint, role: AccountRole.readonly),
        AccountMeta(address: splInterface, role: AccountRole.writable),
        AccountMeta(address: tokenAuthority, role: AccountRole.readonlySigner),
        AccountMeta(address: source, role: AccountRole.writable),
        AccountMeta(address: tokenProgram, role: AccountRole.readonly),
      ],
    SplWithdrawalSettlement(
      :final mint,
      :final splInterface,
      :final recipientTokenAccount,
      :final tokenProgram,
    ) =>
      [
        const AccountMeta(
          address: shieldedPoolCpiAuthority,
          role: AccountRole.readonly,
        ),
        AccountMeta(address: mint, role: AccountRole.readonly),
        AccountMeta(address: splInterface, role: AccountRole.writable),
        AccountMeta(address: recipientTokenAccount, role: AccountRole.writable),
        AccountMeta(address: tokenProgram, role: AccountRole.readonly),
      ],
  };
}
