import 'package:solana_kit_address_lookup_table/solana_kit_address_lookup_table.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:test/test.dart';

const _authority = Address('GsbwXfJraMomNxBcpR3DBFsMki6Djb89kBbHFwNVBgkw');
const _payer = Address('11111111111111111111111111111112');
const _tableAddress = Address('AKptnhx5oMn2sX9qZ7wH5d7mN3o2cF8u1nYxBcVx5Bpa');
const _recipient = Address('11111111111111111111111111111115');

Address _programAddress = addressLookupTableProgramAddress;

void main() {
  group('CreateLookupTable instruction', () {
    test('builds an Instruction with the lookup-table program address', () {
      final ix = getCreateLookupTableInstruction(
        programAddress: _programAddress,
        address: _tableAddress,
        authority: _authority,
        payer: _payer,
        systemProgram: systemProgramAddress,
        recentSlot: BigInt.from(123),
        bump: 254,
      );

      expect(ix.programAddress, equals(_programAddress));
      expect(ix.data, isNotNull);
      expect(ix.accounts, hasLength(4));
      expect(ix.accounts![0].address, _tableAddress);
      expect(ix.accounts![0].role, AccountRole.writable);
      expect(ix.accounts![1].address, _authority);
      expect(ix.accounts![1].role, AccountRole.readonly);
      expect(ix.accounts![2].address, _payer);
      expect(ix.accounts![2].role, AccountRole.writableSigner);
      expect(ix.accounts![3].address, systemProgramAddress);
      expect(ix.accounts![3].role, AccountRole.readonly);
    });

    test('parseCreateLookupTableInstruction round-trips data', () {
      final ix = getCreateLookupTableInstruction(
        programAddress: _programAddress,
        address: _tableAddress,
        authority: _authority,
        payer: _payer,
        systemProgram: systemProgramAddress,
        recentSlot: BigInt.from(456),
        bump: 12,
      );
      final parsed = parseCreateLookupTableInstruction(ix);
      expect(parsed.recentSlot, equals(BigInt.from(456)));
      expect(parsed.bump, equals(12));
      expect(parsed.discriminator, equals(0));
    });
  });

  group('ExtendLookupTable instruction', () {
    test('builds and parses with provided addresses', () {
      final addresses = [
        const Address('TreeQeQqLKhG5qHR7K1xGqZq7xGmo7xGmo7xGmo7xGm'),
      ];
      final ix = getExtendLookupTableInstruction(
        programAddress: _programAddress,
        address: _tableAddress,
        authority: _authority,
        payer: _payer,
        systemProgram: systemProgramAddress,
        addresses: addresses,
      );

      expect(ix.programAddress, equals(_programAddress));
      expect(ix.accounts, hasLength(4));
      expect(
        parseExtendLookupTableInstruction(ix).addresses,
        equals(addresses),
      );
    });
  });

  group('FreezeLookupTable / DeactivateLookupTable instructions', () {
    test('freeze accounts table + authority', () {
      final ix = getFreezeLookupTableInstruction(
        programAddress: _programAddress,
        address: _tableAddress,
        authority: _authority,
      );

      expect(ix.accounts, hasLength(2));
      expect(ix.accounts![0].address, _tableAddress);
      expect(ix.accounts![1].address, _authority);
      expect(ix.accounts![1].role, AccountRole.readonlySigner);
    });

    test('deactivate accounts table + authority', () {
      final ix = getDeactivateLookupTableInstruction(
        programAddress: _programAddress,
        address: _tableAddress,
        authority: _authority,
      );

      expect(ix.accounts, hasLength(2));
      expect(ix.accounts![0].address, _tableAddress);
      expect(ix.accounts![1].address, _authority);
    });
  });

  group('CloseLookupTable instruction', () {
    test('close accounts table + authority + recipient', () {
      final ix = getCloseLookupTableInstruction(
        programAddress: _programAddress,
        address: _tableAddress,
        authority: _authority,
        recipient: _recipient,
      );

      expect(ix.accounts, hasLength(3));
      expect(ix.accounts![0].address, _tableAddress);
      expect(ix.accounts![1].address, _authority);
      expect(ix.accounts![2].address, _recipient);
    });
  });
}
