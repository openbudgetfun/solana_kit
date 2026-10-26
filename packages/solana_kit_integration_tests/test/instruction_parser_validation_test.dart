import 'dart:typed_data';

import 'package:solana_kit_address_lookup_table/solana_kit_address_lookup_table.dart'
    as lookup;
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_compute_budget/solana_kit_compute_budget.dart'
    as compute;
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_loader/solana_kit_loader.dart' as loader;
import 'package:solana_kit_mpl_bubblegum/solana_kit_mpl_bubblegum.dart'
    as bubblegum;
import 'package:solana_kit_stake/solana_kit_stake.dart' as stake;
import 'package:solana_kit_subscriptions/solana_kit_subscriptions.dart'
    as subscriptions;
import 'package:solana_kit_system/solana_kit_system.dart' as system;
import 'package:solana_kit_token/solana_kit_token.dart' as token;
import 'package:test/test.dart';

void main() {
  final fixtures =
      <
        (
          String,
          List<int>,
          Decoder<Object?>,
          Object? Function(Instruction),
        )
      >[
        (
          'allocate',
          [8, 0, 0, 0, 42, 0, 0, 0, 0, 0, 0, 0],
          system.getAllocateInstructionDataDecoder(),
          system.parseAllocateInstruction,
        ),
        (
          'close lookup table',
          [4, 0, 0, 0],
          lookup.getCloseLookupTableInstructionDataDecoder(),
          lookup.parseCloseLookupTableInstruction,
        ),
        (
          'set compute unit limit',
          [2, 1, 0, 0, 0],
          compute.getSetComputeUnitLimitInstructionDataDecoder(),
          compute.parseSetComputeUnitLimitInstruction,
        ),
        (
          'set authority without new authority',
          [6, 0, 0],
          token.getSetAuthorityInstructionDataDecoder(),
          token.parseSetAuthorityInstruction,
        ),
        (
          'set authority with new authority',
          [6, 0, 1, ...List<int>.filled(32, 0)],
          token.getSetAuthorityInstructionDataDecoder(),
          token.parseSetAuthorityInstruction,
        ),
        (
          'close upgradeable program',
          [5, 0, 0, 0],
          loader.getCloseInstructionDataDecoder(),
          loader.parseCloseInstruction,
        ),
        (
          'minimum delegation',
          [13, 0, 0, 0],
          stake.getGetMinimumDelegationInstructionDataDecoder(),
          stake.parseGetMinimumDelegationInstruction,
        ),
        (
          'delete subscription plan',
          [9],
          subscriptions.getDeletePlanInstructionDataDecoder(),
          subscriptions.parseDeletePlanInstruction,
        ),
        (
          'set tree delegate',
          bubblegum.SetTreeDelegateInstructionDiscriminator,
          bubblegum.getSetTreeDelegateInstructionDataDecoder(),
          (instruction) => bubblegum
              .getSetTreeDelegateInstructionDataDecoder()
              .decode(instruction.data!),
        ),
      ];

  for (final (name, payload, decoder, parse) in fixtures) {
    group(name, () {
      Instruction instruction(List<int> bytes) => Instruction(
        programAddress: const Address('11111111111111111111111111111111'),
        data: Uint8List.fromList(bytes),
      );

      test('accepts valid data and a decoder offset', () {
        expect(parse(instruction(payload)), isNotNull);
        final (_, end) = decoder.read(Uint8List.fromList([99, ...payload]), 1);
        expect(end, payload.length + 1);
      });

      test('rejects a different discriminator', () {
        final wrongOpcode = [...payload]..[0] ^= 1;
        expect(
          () => parse(instruction(wrongOpcode)),
          throwsA(isA<SolanaError>()),
        );
        expect(
          () => decoder.decode(Uint8List.fromList(wrongOpcode)),
          throwsA(isA<SolanaError>()),
        );
      });

      test('rejects trailing data through parser and decoder', () {
        for (final tail in [0, 255]) {
          final bytes = Uint8List.fromList([...payload, tail]);
          expect(() => parse(instruction(bytes)), throwsA(isA<SolanaError>()));
          expect(() => decoder.decode(bytes), throwsA(isA<SolanaError>()));
          expect(
            () => decoder.read(Uint8List.fromList([99, ...bytes]), 1),
            throwsA(isA<SolanaError>()),
          );
        }
      });

      test('rejects truncated data', () {
        expect(
          () => parse(instruction(payload.sublist(0, payload.length - 1))),
          throwsA(anything),
        );
      });
    });
  }
}
