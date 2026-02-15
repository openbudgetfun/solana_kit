import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:test/test.dart';

void main() {
  group('downgradeRoleToNonSigner', () {
    test('downgrades readonly to readonly', () {
      expect(
        downgradeRoleToNonSigner(AccountRole.readonly),
        equals(AccountRole.readonly),
      );
    });
    test('downgrades writable to writable', () {
      expect(
        downgradeRoleToNonSigner(AccountRole.writable),
        equals(AccountRole.writable),
      );
    });
    test('downgrades readonlySigner to readonly', () {
      expect(
        downgradeRoleToNonSigner(AccountRole.readonlySigner),
        equals(AccountRole.readonly),
      );
    });
    test('downgrades writableSigner to writable', () {
      expect(
        downgradeRoleToNonSigner(AccountRole.writableSigner),
        equals(AccountRole.writable),
      );
    });
  });

  group('downgradeRoleToReadonly', () {
    test('downgrades readonly to readonly', () {
      expect(
        downgradeRoleToReadonly(AccountRole.readonly),
        equals(AccountRole.readonly),
      );
    });
    test('downgrades writable to readonly', () {
      expect(
        downgradeRoleToReadonly(AccountRole.writable),
        equals(AccountRole.readonly),
      );
    });
    test('downgrades readonlySigner to readonlySigner', () {
      expect(
        downgradeRoleToReadonly(AccountRole.readonlySigner),
        equals(AccountRole.readonlySigner),
      );
    });
    test('downgrades writableSigner to readonlySigner', () {
      expect(
        downgradeRoleToReadonly(AccountRole.writableSigner),
        equals(AccountRole.readonlySigner),
      );
    });
  });

  group('isSignerRole', () {
    test('returns false for readonly', () {
      expect(isSignerRole(AccountRole.readonly), isFalse);
    });
    test('returns false for writable', () {
      expect(isSignerRole(AccountRole.writable), isFalse);
    });
    test('returns true for readonlySigner', () {
      expect(isSignerRole(AccountRole.readonlySigner), isTrue);
    });
    test('returns true for writableSigner', () {
      expect(isSignerRole(AccountRole.writableSigner), isTrue);
    });
  });

  group('isWritableRole', () {
    test('returns false for readonly', () {
      expect(isWritableRole(AccountRole.readonly), isFalse);
    });
    test('returns true for writable', () {
      expect(isWritableRole(AccountRole.writable), isTrue);
    });
    test('returns false for readonlySigner', () {
      expect(isWritableRole(AccountRole.readonlySigner), isFalse);
    });
    test('returns true for writableSigner', () {
      expect(isWritableRole(AccountRole.writableSigner), isTrue);
    });
  });

  group('mergeRoles', () {
    test('readonly + readonly = readonly', () {
      expect(
        mergeRoles(AccountRole.readonly, AccountRole.readonly),
        equals(AccountRole.readonly),
      );
    });
    test('readonly + writable = writable', () {
      expect(
        mergeRoles(AccountRole.readonly, AccountRole.writable),
        equals(AccountRole.writable),
      );
    });
    test('readonly + readonlySigner = readonlySigner', () {
      expect(
        mergeRoles(AccountRole.readonly, AccountRole.readonlySigner),
        equals(AccountRole.readonlySigner),
      );
    });
    test('readonly + writableSigner = writableSigner', () {
      expect(
        mergeRoles(AccountRole.readonly, AccountRole.writableSigner),
        equals(AccountRole.writableSigner),
      );
    });
    test('writable + readonly = writable', () {
      expect(
        mergeRoles(AccountRole.writable, AccountRole.readonly),
        equals(AccountRole.writable),
      );
    });
    test('writable + writable = writable', () {
      expect(
        mergeRoles(AccountRole.writable, AccountRole.writable),
        equals(AccountRole.writable),
      );
    });
    test('writable + readonlySigner = writableSigner', () {
      expect(
        mergeRoles(AccountRole.writable, AccountRole.readonlySigner),
        equals(AccountRole.writableSigner),
      );
    });
    test('writable + writableSigner = writableSigner', () {
      expect(
        mergeRoles(AccountRole.writable, AccountRole.writableSigner),
        equals(AccountRole.writableSigner),
      );
    });
    test('readonlySigner + readonly = readonlySigner', () {
      expect(
        mergeRoles(AccountRole.readonlySigner, AccountRole.readonly),
        equals(AccountRole.readonlySigner),
      );
    });
    test('readonlySigner + writable = writableSigner', () {
      expect(
        mergeRoles(AccountRole.readonlySigner, AccountRole.writable),
        equals(AccountRole.writableSigner),
      );
    });
    test('readonlySigner + readonlySigner = readonlySigner', () {
      expect(
        mergeRoles(AccountRole.readonlySigner, AccountRole.readonlySigner),
        equals(AccountRole.readonlySigner),
      );
    });
    test('readonlySigner + writableSigner = writableSigner', () {
      expect(
        mergeRoles(AccountRole.readonlySigner, AccountRole.writableSigner),
        equals(AccountRole.writableSigner),
      );
    });
    test('writableSigner + readonly = writableSigner', () {
      expect(
        mergeRoles(AccountRole.writableSigner, AccountRole.readonly),
        equals(AccountRole.writableSigner),
      );
    });
    test('writableSigner + writable = writableSigner', () {
      expect(
        mergeRoles(AccountRole.writableSigner, AccountRole.writable),
        equals(AccountRole.writableSigner),
      );
    });
    test('writableSigner + readonlySigner = writableSigner', () {
      expect(
        mergeRoles(AccountRole.writableSigner, AccountRole.readonlySigner),
        equals(AccountRole.writableSigner),
      );
    });
    test('writableSigner + writableSigner = writableSigner', () {
      expect(
        mergeRoles(AccountRole.writableSigner, AccountRole.writableSigner),
        equals(AccountRole.writableSigner),
      );
    });
  });

  group('upgradeRoleToSigner', () {
    test('upgrades readonly to readonlySigner', () {
      expect(
        upgradeRoleToSigner(AccountRole.readonly),
        equals(AccountRole.readonlySigner),
      );
    });
    test('upgrades writable to writableSigner', () {
      expect(
        upgradeRoleToSigner(AccountRole.writable),
        equals(AccountRole.writableSigner),
      );
    });
    test('upgrades readonlySigner to readonlySigner', () {
      expect(
        upgradeRoleToSigner(AccountRole.readonlySigner),
        equals(AccountRole.readonlySigner),
      );
    });
    test('upgrades writableSigner to writableSigner', () {
      expect(
        upgradeRoleToSigner(AccountRole.writableSigner),
        equals(AccountRole.writableSigner),
      );
    });
  });

  group('upgradeRoleToWritable', () {
    test('upgrades readonly to writable', () {
      expect(
        upgradeRoleToWritable(AccountRole.readonly),
        equals(AccountRole.writable),
      );
    });
    test('upgrades writable to writable', () {
      expect(
        upgradeRoleToWritable(AccountRole.writable),
        equals(AccountRole.writable),
      );
    });
    test('upgrades readonlySigner to writableSigner', () {
      expect(
        upgradeRoleToWritable(AccountRole.readonlySigner),
        equals(AccountRole.writableSigner),
      );
    });
    test('upgrades writableSigner to writableSigner', () {
      expect(
        upgradeRoleToWritable(AccountRole.writableSigner),
        equals(AccountRole.writableSigner),
      );
    });
  });
}
