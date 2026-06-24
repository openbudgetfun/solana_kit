import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_surfpool/src/internal/hex.dart';
import 'package:solana_kit_surfpool/src/types.dart';

/// A typed Surfpool cheatcode request.
abstract interface class CheatcodeBuilder {
  /// JSON-RPC method to call.
  String get method;

  /// JSON-RPC params to pass with [method].
  List<Object?> get params;
}

/// Builder for `surfnet_setAccount`.
@immutable
class SetAccount implements CheatcodeBuilder {
  /// Creates a `surfnet_setAccount` builder for [address].
  SetAccount(
    this.address, {
    this.lamports,
    Uint8List? data,
    this.owner,
    this.rentEpoch,
    this.executable,
  }) : _data = data == null ? null : Uint8List.fromList(data);

  /// Account address to mutate.
  final Address address;

  /// Lamports to set.
  final int? lamports;

  /// Account owner to set.
  final Address? owner;

  /// Rent epoch to set.
  final int? rentEpoch;

  /// Whether the account is executable.
  final bool? executable;

  /// Account data bytes.
  Uint8List? get data {
    final data = _data;
    if (data == null) return null;
    return Uint8List.fromList(data);
  }

  final Uint8List? _data;

  /// Returns a copy that sets the account lamports.
  SetAccount withLamports(int lamports) {
    _assertNonNegative(lamports, 'lamports');
    return _copyWith(lamports: lamports);
  }

  /// Returns a copy that sets the account data bytes.
  SetAccount withData(Uint8List data) {
    return _copyWith(data: Uint8List.fromList(data));
  }

  /// Returns a copy that sets the account owner.
  SetAccount withOwner(Address owner) {
    return _copyWith(owner: owner);
  }

  /// Returns a copy that sets the account rent epoch.
  SetAccount withRentEpoch(int rentEpoch) {
    _assertNonNegative(rentEpoch, 'rentEpoch');
    return _copyWith(rentEpoch: rentEpoch);
  }

  /// Returns a copy that sets whether the account is executable.
  SetAccount withExecutable({required bool executable}) {
    return _copyWith(executable: executable);
  }

  SetAccount _copyWith({
    int? lamports,
    Uint8List? data,
    Address? owner,
    int? rentEpoch,
    bool? executable,
  }) {
    return SetAccount(
      address,
      lamports: lamports ?? this.lamports,
      data: data ?? _data,
      owner: owner ?? this.owner,
      rentEpoch: rentEpoch ?? this.rentEpoch,
      executable: executable ?? this.executable,
    );
  }

  @override
  String get method => 'surfnet_setAccount';

  @override
  List<Object?> get params {
    final data = _data;
    final owner = this.owner;
    return <Object?>[
      address.value,
      <String, Object?>{
        if (lamports != null) 'lamports': lamports,
        if (data != null) 'data': bytesToHex(data),
        if (owner != null) 'owner': owner.value,
        if (rentEpoch != null) 'rentEpoch': rentEpoch,
        if (executable != null) 'executable': executable,
      },
    ];
  }
}

/// Builder for `surfnet_setTokenAccount`.
@immutable
class SetTokenAccount implements CheatcodeBuilder {
  /// Creates a `surfnet_setTokenAccount` builder.
  const SetTokenAccount(
    this.owner,
    this.mint, {
    this.amount,
    this.delegate,
    this.clearDelegate = false,
    this.state,
    this.delegatedAmount,
    this.closeAuthority,
    this.clearCloseAuthority = false,
    this.tokenProgram,
  });

  /// Token owner wallet address.
  final Address owner;

  /// Token mint address.
  final Address mint;

  /// Token amount to set.
  final int? amount;

  /// Delegate address to set.
  final Address? delegate;

  /// Whether to clear the delegate address.
  final bool clearDelegate;

  /// Token account state to set.
  final String? state;

  /// Delegated token amount to set.
  final int? delegatedAmount;

  /// Close authority address to set.
  final Address? closeAuthority;

  /// Whether to clear the close authority.
  final bool clearCloseAuthority;

  /// Token program to use for the account mutation.
  final Address? tokenProgram;

  /// Returns a copy that sets the token amount.
  SetTokenAccount withAmount(int amount) {
    _assertNonNegative(amount, 'amount');
    return _copyWith(amount: amount);
  }

  /// Returns a copy that sets the delegate address.
  SetTokenAccount withDelegate(Address delegate) {
    return _copyWith(delegate: delegate, clearDelegate: false);
  }

  /// Returns a copy that clears the delegate address.
  SetTokenAccount withoutDelegate() {
    return _copyWith(clearDelegate: true, clearDelegateField: true);
  }

  /// Returns a copy that sets the token account state string.
  SetTokenAccount withState(String state) {
    return _copyWith(state: state);
  }

  /// Returns a copy that sets the delegated amount.
  SetTokenAccount withDelegatedAmount(int delegatedAmount) {
    _assertNonNegative(delegatedAmount, 'delegatedAmount');
    return _copyWith(delegatedAmount: delegatedAmount);
  }

  /// Returns a copy that sets the close authority.
  SetTokenAccount withCloseAuthority(Address closeAuthority) {
    return _copyWith(
      closeAuthority: closeAuthority,
      clearCloseAuthority: false,
    );
  }

  /// Returns a copy that clears the close authority.
  SetTokenAccount withoutCloseAuthority() {
    return _copyWith(clearCloseAuthority: true, clearCloseAuthorityField: true);
  }

  /// Returns a copy that uses [tokenProgram] for ATA derivation and mutation.
  SetTokenAccount withTokenProgram(Address tokenProgram) {
    return _copyWith(tokenProgram: tokenProgram);
  }

  SetTokenAccount _copyWith({
    int? amount,
    Address? delegate,
    bool? clearDelegate,
    bool clearDelegateField = false,
    String? state,
    int? delegatedAmount,
    Address? closeAuthority,
    bool? clearCloseAuthority,
    bool clearCloseAuthorityField = false,
    Address? tokenProgram,
  }) {
    return SetTokenAccount(
      owner,
      mint,
      amount: amount ?? this.amount,
      delegate: clearDelegateField ? null : delegate ?? this.delegate,
      clearDelegate: clearDelegate ?? this.clearDelegate,
      state: state ?? this.state,
      delegatedAmount: delegatedAmount ?? this.delegatedAmount,
      closeAuthority: clearCloseAuthorityField
          ? null
          : closeAuthority ?? this.closeAuthority,
      clearCloseAuthority: clearCloseAuthority ?? this.clearCloseAuthority,
      tokenProgram: tokenProgram ?? this.tokenProgram,
    );
  }

  @override
  String get method => 'surfnet_setTokenAccount';

  @override
  List<Object?> get params {
    final update = SetTokenAccountUpdate(
      amount: amount,
      delegate: delegate,
      clearDelegate: clearDelegate,
      state: state,
      delegatedAmount: delegatedAmount,
      closeAuthority: closeAuthority,
      clearCloseAuthority: clearCloseAuthority,
    ).toJson();

    final tokenProgram = this.tokenProgram;
    return <Object?>[
      owner.value,
      mint.value,
      update,
      if (tokenProgram != null) tokenProgram.value,
    ];
  }
}

/// Builder for `surfnet_resetAccount`.
@immutable
class ResetAccount implements CheatcodeBuilder {
  /// Creates a reset-account builder for [address].
  const ResetAccount(this.address, {this.includeOwnedAccounts});

  /// Account address to reset.
  final Address address;

  /// Whether to reset accounts owned by [address].
  final bool? includeOwnedAccounts;

  /// Returns a copy with [includeOwnedAccounts] set.
  ResetAccount withIncludeOwnedAccounts({required bool includeOwnedAccounts}) {
    return ResetAccount(address, includeOwnedAccounts: includeOwnedAccounts);
  }

  @override
  String get method => 'surfnet_resetAccount';

  @override
  List<Object?> get params {
    final options = ResetAccountOptions(
      includeOwnedAccounts: includeOwnedAccounts,
    ).toJson();
    return <Object?>[address.value, if (options.isNotEmpty) options];
  }
}

/// Builder for `surfnet_streamAccount`.
@immutable
class StreamAccount implements CheatcodeBuilder {
  /// Creates a stream-account builder for [address].
  const StreamAccount(this.address, {this.includeOwnedAccounts});

  /// Account address to stream from the upstream RPC.
  final Address address;

  /// Whether to stream accounts owned by [address].
  final bool? includeOwnedAccounts;

  /// Returns a copy with [includeOwnedAccounts] set.
  StreamAccount withIncludeOwnedAccounts({required bool includeOwnedAccounts}) {
    return StreamAccount(address, includeOwnedAccounts: includeOwnedAccounts);
  }

  @override
  String get method => 'surfnet_streamAccount';

  @override
  List<Object?> get params {
    final options = StreamAccountOptions(
      includeOwnedAccounts: includeOwnedAccounts,
    ).toJson();
    return <Object?>[address.value, if (options.isNotEmpty) options];
  }
}

void _assertNonNegative(int value, String name) {
  if (value < 0) {
    throw ArgumentError.value(value, name, 'must be non-negative');
  }
}
