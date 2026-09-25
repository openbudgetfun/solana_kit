import 'package:solana_kit_accounts/solana_kit_accounts.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_instruction_plans/solana_kit_instruction_plans.dart';
import 'package:solana_kit_subscribable/solana_kit_subscribable.dart';

// ignore_for_file: one_member_abstracts

/// Represents a client that provides a default identity signer.
///
/// The identity is the signer whose assets the application is acting upon. In
/// many applications the identity and payer are the same signer, but the roles
/// can differ when a service pays fees on behalf of a user.
abstract interface class ClientWithIdentity<TSigner extends Object> {
  /// The default identity signer.
  TSigner get identity;
}

/// Represents a client that provides a default transaction payer.
///
/// The payer is the signer responsible for transaction fees and account-rent
/// funding. It may differ from [ClientWithIdentity.identity].
abstract interface class ClientWithPayer<TSigner extends Object> {
  /// The default transaction payer signer.
  TSigner get payer;
}

/// Registers a listener for changes to a reactive client capability.
///
/// Returns an idempotent unsubscribe callback.
typedef SubscribeToFn = void Function() Function(void Function() listener);

/// Represents a client that advertises [ClientWithPayer.payer] as reactive.
abstract interface class ClientWithSubscribeToPayer {
  /// Registers [listener] to run when the payer may have changed.
  void Function() subscribeToPayer(void Function() listener);
}

/// Represents a client that advertises [ClientWithIdentity.identity] as reactive.
abstract interface class ClientWithSubscribeToIdentity {
  /// Registers [listener] to run when the identity may have changed.
  void Function() subscribeToIdentity(void Function() listener);
}

/// Represents a client that can compute the minimum balance for rent
/// exemption.
abstract interface class ClientWithGetMinimumBalance {
  /// Computes the minimum balance for rent exemption for the given [space].
  ///
  /// By default the 128-byte account header is included on top of [space];
  /// pass [withoutHeader] to compute the minimum balance for the data portion
  /// only.
  Future<BigInt> getMinimumBalance(int space, {bool withoutHeader = false});
}

/// Represents a client that can fetch the encoded content of accounts from
/// their addresses.
abstract interface class ClientWithFetchAccounts {
  /// Fetches the encoded content of accounts from their addresses.
  ///
  /// The returned list matches the provided addresses in length and order,
  /// using [MaybeEncodedAccount] to represent accounts that may not exist.
  Future<List<MaybeEncodedAccount>> fetchAccounts(
    List<Address> addresses, {
    FetchAccountConfig? config,
  });
}

/// Represents a client that can send transactions to the Solana network.
///
/// Transaction sending handles signing, submission, and confirmation of
/// transactions. It supports flexible input formats including instructions,
/// instruction plans, transaction messages, or transaction plans.
///
/// Successful results carry a signature-bearing context: the context map is
/// guaranteed to include a `signature` on every successful result. This
/// mirrors upstream `ClientWithTransactionSending` in `@solana/plugin-interfaces`
/// (#1899), which defaults its `TContext` type parameter to
/// `TransactionPlanResultContextWithSignature` for backward compatibility. The
/// Dart port models result contexts as `Map<String, Object?>` rather than a
/// generic type parameter, so that default is expressed as this documented
/// guarantee instead.
abstract interface class ClientWithTransactionSending {
  /// Sends a single transaction to the network.
  ///
  /// Accepts flexible input: an `Instruction`, an [InstructionPlan], a list of
  /// instructions or plans, a `TransactionMessage`, or a [TransactionPlan].
  ///
  /// Returns the successful transaction result, whose context includes the
  /// transaction's `signature`.
  Future<SuccessfulSingleTransactionPlanResult> sendTransaction(
    Object input, {
    CancellationToken? abortSignal,
  });

  /// Sends one or more transactions to the network.
  ///
  /// Accepts flexible input: an `Instruction`, an [InstructionPlan], a list of
  /// instructions or plans, a `TransactionMessage`, or a [TransactionPlan].
  ///
  /// Returns the results for all transactions, with a `signature` on every
  /// successful single result's context.
  Future<TransactionPlanResult> sendTransactions(
    Object input, {
    CancellationToken? abortSignal,
  });
}

/// Represents a client that can sign transactions without submitting them to
/// the network.
///
/// Transaction signing accepts the same flexible inputs as
/// [ClientWithTransactionSending] — instructions, instruction plans,
/// transaction messages, or transaction plans — but stops short of sending the
/// resulting transactions. Use it to hand transactions off to another party,
/// such as an authority wallet signing a transaction that a relayer will pay
/// for and submit later.
///
/// Unlike the sending interface, this interface makes no default guarantee
/// about what a result's context contains: what it holds is entirely decided
/// by the implementation providing the capability, which would typically
/// guarantee a `context.transaction` on successful results. This mirrors
/// upstream `ClientWithTransactionSigning<TContext = TransactionPlanResultContext>`
/// in `@solana/plugin-interfaces` (#1899).
abstract interface class ClientWithTransactionSigning {
  /// Signs a single transaction without sending it.
  ///
  /// Accepts flexible input: an `Instruction`, an [InstructionPlan], a list of
  /// instructions or plans, a `TransactionMessage`, or a [TransactionPlan].
  ///
  /// Returns the successful transaction result carrying the context the
  /// implementation was parameterized with.
  Future<SuccessfulSingleTransactionPlanResult> signTransaction(
    Object input, {
    CancellationToken? abortSignal,
  });

  /// Signs one or more transactions without sending them.
  ///
  /// Accepts flexible input: an `Instruction`, an [InstructionPlan], a list of
  /// instructions or plans, a `TransactionMessage`, or a [TransactionPlan].
  ///
  /// Returns the results for all transactions. Successful leaves carry the
  /// context the implementation was parameterized with.
  Future<TransactionPlanResult> signTransactions(
    Object input, {
    CancellationToken? abortSignal,
  });
}
