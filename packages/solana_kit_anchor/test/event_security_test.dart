import 'dart:convert';

import 'package:solana_kit_anchor/solana_kit_anchor.dart';
import 'package:test/test.dart';

const _program = 'Fg6PaFpoGXkYsidMpWTK6W2BeZ7FEfcYkg476zPFsLnS';
const _attacker = '11111111111111111111111111111111';

void main() {
  late AnchorCoder coder;
  late String eventLog;

  setUp(() {
    coder = AnchorCoder(
      AnchorIdlProgram.parse({
        'address': _program,
        'metadata': {'name': 'ledger', 'version': '1.0.0', 'spec': '0.1.0'},
        'instructions': <Object?>[],
        'events': [
          {
            'name': 'Credit',
            'discriminator': <int>[1, 2, 3, 4, 5, 6, 7, 8],
          },
        ],
        'types': [
          {
            'name': 'Credit',
            'type': {
              'kind': 'struct',
              'fields': [
                {'name': 'amount', 'type': 'u8'},
              ],
            },
          },
        ],
      }),
    );
    eventLog = 'Program data: ${base64Encode([1, 2, 3, 4, 5, 6, 7, 8, 99])}';
  });

  group('event provenance security', () {
    test('ignores another program forging the same event discriminator', () {
      final events = coder.decodeEventLogs([
        'Program $_attacker invoke [1]',
        eventLog,
        'Program $_attacker success',
      ]);
      expect(events, isEmpty);
    });

    test('ignores forged data markers inside user-controlled message logs', () {
      final events = coder.decodeEventLogs([
        'Program $_program invoke [1]',
        'Program log: $eventLog',
        'Program $_program success',
      ]);
      expect(events, isEmpty);
    });

    test('ignores foreign CPI events and resumes the invoking program', () {
      final events = coder.decodeEventLogs([
        'Program $_program invoke [1]',
        'Program $_attacker invoke [2]',
        eventLog,
        'Program $_attacker success',
        eventLog,
        'Program $_program success',
      ]);
      expect(events, hasLength(1));
      expect(events.single.data['amount'], 99);
    });

    test('ignores event-shaped data outside an invocation', () {
      expect(coder.decodeEventLogs([eventLog]), isEmpty);
      expect(
        coder.decodeEventLogs([
          'Program $_program invoke [1]',
          'Program $_program success',
          eventLog,
        ]),
        isEmpty,
      );
    });

    test('recognizes calls to the IDL program from another program', () {
      final events = coder.decodeEventLogs([
        'Program $_attacker invoke [1]',
        'Program $_program invoke [2]',
        eventLog,
        'Program $_program success',
        eventLog,
        'Program $_attacker success',
      ]);
      expect(events, hasLength(1));
    });

    test('restores the caller after a failed nested invocation', () {
      final events = coder.decodeEventLogs([
        'Program $_program invoke [1]',
        'Program $_attacker invoke [2]',
        eventLog,
        'Program $_attacker failed: custom program error: 0x1',
        eventLog,
        'Program $_program success',
      ]);
      expect(events, hasLength(1));
    });

    test('fails closed for an invocation with missing parent context', () {
      expect(
        coder.decodeEventLogs([
          'Program $_program invoke [2]',
          eventLog,
          'Program $_program success',
        ]),
        isEmpty,
      );
    });

    test('fails closed when the completion does not match the caller', () {
      expect(
        coder.decodeEventLogs([
          'Program $_program invoke [1]',
          'Program $_attacker success',
          eventLog,
        ]),
        isEmpty,
      );
    });

    test('ignores invalid foreign payloads before base64 decoding', () {
      expect(
        coder.decodeEventLogs([
          'Program $_attacker invoke [1]',
          'Program data: %not base64%',
          'Program $_attacker success',
        ]),
        isEmpty,
      );
    });

    test('handles sequential root instructions and unknown events', () {
      final events = coder.decodeEventLogs([
        'Program $_attacker invoke [1]',
        'Program $_attacker success',
        'Program $_program invoke [1]',
        'Program data: ${base64Encode([8, 7, 6, 5, 4, 3, 2, 1])}',
        eventLog,
        'Program $_program success',
        'Program $_program invoke [1]',
        eventLog,
        'Program $_program success',
      ]);
      expect(events, hasLength(2));
    });
  });
}
