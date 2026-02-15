/// Describes the purpose for which an account participates in a transaction.
///
/// Every account that participates in a transaction can be read from, but only
/// ones that you mark as writable may be written to, and only ones that you
/// indicate must sign the transaction will gain the privileges associated with
/// signers at runtime.
///
/// The enum values use a bitflag scheme:
///
/// | Role              | isSigner | isWritable | Value |
/// | ----------------- | -------- | ---------- | ----- |
/// | `readonly`        | No       | No         | 0b00  |
/// | `writable`        | No       | Yes        | 0b01  |
/// | `readonlySigner`  | Yes      | No         | 0b10  |
/// | `writableSigner`  | Yes      | Yes        | 0b11  |
enum AccountRole {
  /// A read-only, non-signer account.
  readonly(0),

  /// A writable, non-signer account.
  writable(1),

  /// A read-only signer account.
  readonlySigner(2),

  /// A writable signer account.
  writableSigner(3);

  const AccountRole(this.value);

  /// The bitflag value of this role.
  final int value;
}

/// Bitmask for the signer bit.
const _isSignerBitmask = 0x02;

/// Bitmask for the writable bit.
const _isWritableBitmask = 0x01;

/// Returns the [AccountRole] that corresponds to the given bitflag [value].
AccountRole _roleFromValue(int value) =>
    AccountRole.values.firstWhere((r) => r.value == value);

/// Returns the non-signer variant of the supplied [role].
///
/// - [AccountRole.readonlySigner] becomes [AccountRole.readonly].
/// - [AccountRole.writableSigner] becomes [AccountRole.writable].
/// - Non-signer roles are returned unchanged.
AccountRole downgradeRoleToNonSigner(AccountRole role) =>
    _roleFromValue(role.value & ~_isSignerBitmask);

/// Returns the read-only variant of the supplied [role].
///
/// - [AccountRole.writable] becomes [AccountRole.readonly].
/// - [AccountRole.writableSigner] becomes [AccountRole.readonlySigner].
/// - Read-only roles are returned unchanged.
AccountRole downgradeRoleToReadonly(AccountRole role) =>
    _roleFromValue(role.value & ~_isWritableBitmask);

/// Returns `true` if [role] represents a signer account.
bool isSignerRole(AccountRole role) =>
    role.value >= AccountRole.readonlySigner.value;

/// Returns `true` if [role] represents a writable account.
bool isWritableRole(AccountRole role) => (role.value & _isWritableBitmask) != 0;

/// Returns the [AccountRole] that grants the highest privileges of both
/// [roleA] and [roleB].
///
/// ```dart
/// // Returns AccountRole.writableSigner
/// mergeRoles(AccountRole.readonlySigner, AccountRole.writable);
/// ```
AccountRole mergeRoles(AccountRole roleA, AccountRole roleB) =>
    _roleFromValue(roleA.value | roleB.value);

/// Returns the signer variant of the supplied [role].
///
/// - [AccountRole.readonly] becomes [AccountRole.readonlySigner].
/// - [AccountRole.writable] becomes [AccountRole.writableSigner].
/// - Signer roles are returned unchanged.
AccountRole upgradeRoleToSigner(AccountRole role) =>
    _roleFromValue(role.value | _isSignerBitmask);

/// Returns the writable variant of the supplied [role].
///
/// - [AccountRole.readonly] becomes [AccountRole.writable].
/// - [AccountRole.readonlySigner] becomes [AccountRole.writableSigner].
/// - Writable roles are returned unchanged.
AccountRole upgradeRoleToWritable(AccountRole role) =>
    _roleFromValue(role.value | _isWritableBitmask);
