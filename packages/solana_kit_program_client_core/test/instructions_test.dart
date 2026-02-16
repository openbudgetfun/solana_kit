import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_program_client_core/solana_kit_program_client_core.dart';
import 'package:test/test.dart';

const _mockAddress = Address('11111111111111111111111111111111');

void main() {
  group('InstructionWithByteDelta', () {
    test('creates an instruction with a positive byte delta', () {
      const instruction = InstructionWithByteDelta(
        programAddress: _mockAddress,
        byteDelta: 100,
      );

      expect(instruction.programAddress, _mockAddress);
      expect(instruction.byteDelta, 100);
      expect(instruction.accounts, isNull);
      expect(instruction.data, isNull);
    });

    test('creates an instruction with a negative byte delta', () {
      const instruction = InstructionWithByteDelta(
        programAddress: _mockAddress,
        byteDelta: -50,
      );

      expect(instruction.byteDelta, -50);
    });

    test('creates an instruction with zero byte delta', () {
      const instruction = InstructionWithByteDelta(
        programAddress: _mockAddress,
        byteDelta: 0,
      );

      expect(instruction.byteDelta, 0);
    });

    test('is a subclass of Instruction', () {
      const instruction = InstructionWithByteDelta(
        programAddress: _mockAddress,
        byteDelta: 42,
      );

      expect(instruction, isA<Instruction>());
    });

    test('supports accounts and data', () {
      final accounts = [
        const AccountMeta(address: _mockAddress, role: AccountRole.readonly),
      ];
      final data = Uint8List.fromList([1, 2, 3]);

      final instruction = InstructionWithByteDelta(
        programAddress: _mockAddress,
        byteDelta: 10,
        accounts: accounts,
        data: data,
      );

      expect(instruction.accounts, hasLength(1));
      expect(instruction.data, Uint8List.fromList([1, 2, 3]));
      expect(instruction.byteDelta, 10);
    });
  });
}
