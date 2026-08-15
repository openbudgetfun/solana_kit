import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_surfpool/src/builders.dart';
import 'package:solana_kit_surfpool/src/internal/hex.dart';
import 'package:solana_kit_surfpool/src/surfnet.dart';
import 'package:solana_kit_surfpool/src/types.dart';

/// A raw cheatcode request for methods without a dedicated builder.
@immutable
class _RawCheatcode implements CheatcodeBuilder {
  const _RawCheatcode(this.method, this.params);

  @override
  final String method;

  @override
  final List<Object?> params;
}

/// Typed access to every `surfnet_*` cheatcode, mirroring the
/// `client.cheatcodes` surface of `@solana/surfpool/kit`.
///
/// Method names drop the `surfnet_` prefix (e.g. `timeTravel` instead of
/// `surfnet_timeTravel`); the prefix is re-added on the wire. Responses are
/// returned unwrapped from their `{ context, value }` envelope.
class SurfnetCheatcodes {
  /// Creates a cheatcode client bound to `surfnet`.
  SurfnetCheatcodes(this._surfnet);

  final Surfnet _surfnet;

  Future<Object?> _call(String method, [List<Object?> params = const []]) =>
      _surfnet.execute(_RawCheatcode(method, params));

  /// Moves the local clock to an absolute slot, epoch, or timestamp.
  ///
  /// Exactly one of [absoluteSlot], [absoluteEpoch], or [absoluteTimestamp]
  /// must be provided.
  Future<EpochInfoValue> timeTravel({
    int? absoluteSlot,
    int? absoluteEpoch,
    int? absoluteTimestamp,
  }) {
    final params = <Object?>[
      if (absoluteSlot != null) <String, Object?>{'absoluteSlot': absoluteSlot},
      if (absoluteEpoch != null)
        <String, Object?>{'absoluteEpoch': absoluteEpoch},
      if (absoluteTimestamp != null)
        <String, Object?>{'absoluteTimestamp': absoluteTimestamp},
    ];
    return _call('surfnet_timeTravel', params).then(EpochInfoValue.fromJson);
  }

  /// Pauses the local clock.
  Future<EpochInfoValue> pauseClock() =>
      _call('surfnet_pauseClock').then(EpochInfoValue.fromJson);

  /// Resumes the local clock.
  Future<EpochInfoValue> resumeClock() =>
      _call('surfnet_resumeClock').then(EpochInfoValue.fromJson);

  /// Sets arbitrary account state in one call.
  Future<void> setAccount(
    Address address, {
    int? lamports,
    Uint8List? data,
    Address? owner,
    int? rentEpoch,
    bool? executable,
  }) => _surfnet.execute(
    SetAccount(
      address,
      lamports: lamports,
      data: data,
      owner: owner,
      rentEpoch: rentEpoch,
      executable: executable,
    ),
  );

  /// Sets the token balance for [owner]'s associated token account.
  Future<void> setTokenBalance(
    Address owner,
    Address mint,
    int amount, {
    Address tokenProgram = tokenProgramAddress,
  }) =>
      _surfnet.setTokenBalance(owner, mint, amount, tokenProgram: tokenProgram);

  /// Mutates advanced token-account fields.
  Future<void> setTokenAccount(
    Address owner,
    Address mint,
    SetTokenAccountUpdate update, {
    Address tokenProgram = tokenProgramAddress,
  }) =>
      _surfnet.setTokenAccount(owner, mint, update, tokenProgram: tokenProgram);

  /// Resets an account to upstream state, when an upstream RPC is configured.
  Future<void> resetAccount(
    Address address, {
    bool? includeOwnedAccounts,
  }) => _surfnet.resetAccount(
    address,
    options: ResetAccountOptions(
      includeOwnedAccounts: includeOwnedAccounts,
    ),
  );

  /// Streams an account from the upstream RPC, when an upstream RPC is
  /// configured.
  Future<void> streamAccount(
    Address address, {
    bool? includeOwnedAccounts,
  }) => _surfnet.streamAccount(
    address,
    options: StreamAccountOptions(
      includeOwnedAccounts: includeOwnedAccounts,
    ),
  );

  /// Marks an account as offline so reads fail until it is reset.
  Future<void> offlineAccount(
    Address address, {
    Map<String, Object?>? config,
  }) => _call('surfnet_offlineAccount', [
    address.value,
    ?config,
  ]);

  /// Streams several accounts from the upstream RPC in one call.
  Future<void> streamAccounts(List<Map<String, Object?>> accounts) =>
      _call('surfnet_streamAccounts', [accounts]);

  /// Returns the accounts currently being streamed.
  Future<Object?> getStreamedAccounts() => _call('surfnet_getStreamedAccounts');

  /// Clones a program account from [sourceProgramId] to [destinationProgramId].
  Future<void> cloneProgramAccount(
    Address sourceProgramId,
    Address destinationProgramId,
  ) => _call('surfnet_cloneProgramAccount', [
    sourceProgramId.value,
    destinationProgramId.value,
  ]);

  /// Sets the authority of a program account.
  Future<void> setProgramAuthority(
    Address programId, {
    Address? newAuthority,
  }) => _call('surfnet_setProgramAuthority', [
    programId.value,
    ?newAuthority?.value,
  ]);

  /// Writes [data] at [offset] into the program account at [programId].
  Future<void> writeProgram(
    Address programId,
    Uint8List data,
    int offset, {
    Address? authority,
  }) => _call('surfnet_writeProgram', [
    programId.value,
    bytesToHex(data),
    offset,
    ?authority?.value,
  ]);

  /// Profiles a transaction and returns the profile result.
  Future<Object?> profileTransaction(
    String transactionData, {
    String? tag,
    Map<String, Object?>? config,
  }) => _call('surfnet_profileTransaction', [
    transactionData,
    ?tag,
    ?config,
  ]);

  /// Returns the profile for a signature or UUID.
  Future<Object?> getTransactionProfile(
    String signatureOrUuid, {
    Map<String, Object?>? config,
  }) => _call('surfnet_getTransactionProfile', [
    signatureOrUuid,
    ?config,
  ]);

  /// Returns the profiles recorded under [tag].
  Future<Object?> getProfileResultsByTag(
    String tag, {
    Map<String, Object?>? config,
  }) => _call('surfnet_getProfileResultsByTag', [
    tag,
    ?config,
  ]);

  /// Registers an Anchor IDL for a program.
  Future<void> registerIdl(
    Map<String, Object?> idl, {
    int? slot,
  }) => _call('surfnet_registerIdl', [
    idl,
    ?slot,
  ]);

  /// Returns the active IDL for [programId].
  Future<Object?> getActiveIdl(
    Address programId, {
    int? slot,
  }) => _call('surfnet_getActiveIdl', [
    programId.value,
    ?slot,
  ]);

  /// Sets the total supply of SOL.
  Future<void> setSupply(Map<String, Object?> update) =>
      _call('surfnet_setSupply', [update]);

  /// Resets the network to its initial state.
  Future<void> resetNetwork() => _call('surfnet_resetNetwork');

  /// Returns information about the Surfnet.
  Future<Object?> getSurfnetInfo() => _call('surfnet_getSurfnetInfo');

  /// Exports a snapshot of the current account state.
  Future<Object?> exportSnapshot({Map<String, Object?>? config}) =>
      _call('surfnet_exportSnapshot', [
        ?config,
      ]);

  /// Registers a scenario for replay.
  Future<void> registerScenario(
    Map<String, Object?> scenario, {
    int? slot,
  }) => _call('surfnet_registerScenario', [
    scenario,
    ?slot,
  ]);

  /// Returns the most recent local signatures.
  Future<Object?> getLocalSignatures({int? limit}) =>
      _call('surfnet_getLocalSignatures', [
        ?limit,
      ]);

  /// Enables cheatcodes matching [filter] (`'all'` or a list of method names).
  Future<void> enableCheatcode(Object filter) =>
      _call('surfnet_enableCheatcode', [filter]);

  /// Disables cheatcodes matching [filter], optionally with a [lockout].
  Future<void> disableCheatcode(
    Object filter, {
    Map<String, Object?>? lockout,
  }) => _call('surfnet_disableCheatcode', [
    filter,
    ?lockout,
  ]);
}
