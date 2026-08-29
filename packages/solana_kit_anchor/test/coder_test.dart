import 'dart:convert';
import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_anchor/solana_kit_anchor.dart';
import 'package:test/test.dart';

const _initializeHex =
    'AFAF6D1F0D989BEDDA075CB2FF5EC6817613DE530B692A8735477769DA47430C'
    'BD8154335C4A832739300000000000000500000068656C6C6F0300000007000'
    '000090000000B0000000102030401FBFFFFFFFFFFFFFF';

/// A tiny IDL covering every scalar, compound, and defined-type shape the
/// dynamic coder supports.
const Map<String, Object?> _miniIdl = {
  'address': 'Fg6PaFpoGXkYsidMpWTK6W2BeZ7FEfcYkg476zPFsLnS',
  'metadata': {'name': 'mini'},
  'instructions': [
    {
      'name': 'initialize',
      'discriminator': [175, 175, 109, 31, 13, 152, 155, 237],
      'args': [
        {'name': 'authority', 'type': 'pubkey'},
        {'name': 'amount', 'type': 'u64'},
        {'name': 'name', 'type': 'string'},
        {
          'name': 'tags',
          'type': {'vec': 'u32'},
        },
        {
          'name': 'key',
          'type': {
            'array': ['u8', 4],
          },
        },
        {
          'name': 'maybe',
          'type': {
            'option': 'i64',
          },
        },
      ],
    },
    {
      'name': 'close',
      'discriminator': [0, 0, 0, 0, 0, 0, 0, 0],
    },
  ],
  'accounts': [
    {
      'name': 'Counter',
      'discriminator': [246, 28, 6, 87, 251, 45, 50, 42],
    },
  ],
  'events': [
    {
      'name': 'MyEvent',
      'discriminator': [96, 184, 197, 243, 139, 2, 90, 148],
    },
  ],
  'errors': [
    {'code': 6000, 'name': 'Custom', 'msg': 'custom message'},
  ],
  'types': [
    {
      'name': 'Counter',
      'type': {
        'kind': 'struct',
        'fields': [
          {'name': 'authority', 'type': 'pubkey'},
          {'name': 'count', 'type': 'u64'},
          {
            'name': 'state',
            'type': {
              'defined': {'name': 'CounterState'},
            },
          },
        ],
      },
    },
    {
      'name': 'CounterState',
      'type': {
        'kind': 'enum',
        'variants': [
          {'name': 'Unit'},
          {
            'name': 'Running',
            'fields': [
              {'name': 'step', 'type': 'u32'},
              {'name': 'label', 'type': 'string'},
            ],
          },
          {
            'name': 'Tuple',
            'fields': ['u8', 'u8'],
          },
        ],
      },
    },
    {
      'name': 'MyEvent',
      'type': {
        'kind': 'struct',
        'fields': [
          {'name': 'from', 'type': 'pubkey'},
          {'name': 'delta', 'type': 'i32'},
        ],
      },
    },
    {
      'name': 'Legacy',
      'type': {'kind': 'struct'},
    },
  ],
};

/// The `initialize` fixture values as a request argument map.
Map<String, Object?> initialArgs(Address authority) => {
  'authority': authority,
  'amount': BigInt.from(12345),
  'name': 'hello',
  'tags': [7, 9, 11],
  'key': [1, 2, 3, 4],
  'maybe': BigInt.from(-5),
};

Address get authorityAddress =>
    const Address('Fg6PaFpoGXkYsidMpWTK6W2BeZ7FEfcYkg476zPFsLnS');

AnchorCoder miniCoder() => AnchorCoder(AnchorIdlProgram.parse(_miniIdl));

void main() {
  final coder = miniCoder();

  test('encodeInstructionData matches borsh byte-for-byte', () {
    final bytes = coder.encodeInstructionData(
      'initialize',
      initialArgs(authorityAddress),
    );
    final expected = Uint8List.fromList(bytesFromHex(_initializeHex));
    expect(bytes, expected);
  });

  test('encodeInstructionData validates the discriminator', () {
    final bytes = coder.encodeInstructionData('close', {});
    expect(bytes, hasLength(8));
    expect(bytes.every((byte) => byte == 0), isTrue);
  });

  test('decodeInstructionData round-trips the encoded arguments', () {
    final bytes = coder.encodeInstructionData(
      'initialize',
      initialArgs(authorityAddress),
    );
    final parsed = coder.decodeInstructionData('initialize', bytes);
    expect(parsed['authority'], authorityAddress);
    expect(parsed['amount'], BigInt.from(12345));
    expect(parsed['name'], 'hello');
    expect(parsed['tags'], [7, 9, 11]);
    expect(parsed['key'], [1, 2, 3, 4]);
    expect(parsed['maybe'], BigInt.from(-5));
  });

  test('unknown instruction names throw', () {
    expect(
      () => coder.encodeInstructionData('nope', {}),
      throwsArgumentError,
    );
    expect(
      () => coder.decodeInstructionData('nope', List.filled(8, 0)),
      throwsArgumentError,
    );
  });

  test('missing instruction arguments throw', () {
    expect(
      () => coder.encodeInstructionData('initialize', {}),
      throwsArgumentError,
    );
  });

  test('accounts round-trip through the dynamic coder', () {
    final values = <String, Object?>{
      'authority': authorityAddress,
      'count': BigInt.from(999),
      'state': {'__kind': 'Running', 'step': 3, 'label': 'go'},
    };
    final encoded = coder.encodeAccount('Counter', values);
    final decoded = coder.decodeAccount('Counter', encoded);

    expect(decoded.discriminator, [246, 28, 6, 87, 251, 45, 50, 42]);
    expect(decoded.data['count'], BigInt.from(999));
    expect(
      decoded.data['state'],
      {'__kind': 'Running', 'step': 3, 'label': 'go'},
    );
  });

  test('account data with a wrong discriminator throws', () {
    final encoded = coder.encodeAccount('Counter', {
      'authority': authorityAddress,
      'count': BigInt.zero,
      'state': {'__kind': 'Unit'},
    });
    final corrupted = List<int>.from(encoded);
    corrupted[5] = encoded[5] ^ 0xff;
    expect(
      () => coder.decodeAccount('Counter', corrupted),
      throwsA(isA<AnchorDiscriminatorMismatch>()),
    );
    expect(
      coder.decodeAccount('Counter', encoded).discriminator,
      [246, 28, 6, 87, 251, 45, 50, 42],
    );
  });

  test('unknown account names throw on both directions', () {
    expect(() => coder.encodeAccount('Nope', {}), throwsArgumentError);
    expect(
      () => coder.decodeAccount('Nope', List.filled(8, 0)),
      throwsArgumentError,
    );
  });

  test('enum unit and tuple variants round-trip', () {
    final unit = coder.encodeAccount('Counter', {
      'authority': authorityAddress,
      'count': BigInt.zero,
      'state': {'__kind': 'Unit'},
    });
    expect(
      coder.decodeAccount('Counter', unit).data['state'],
      {'__kind': 'Unit'},
    );
    final tuple = coder.encodeAccount('Counter', {
      'authority': authorityAddress,
      'count': BigInt.zero,
      'state': {'__kind': 'Tuple', 'field0': 8, 'field1': 9},
    });
    expect(
      coder.decodeAccount('Counter', tuple).data['state'],
      {'__kind': 'Tuple', 'field0': 8, 'field1': 9},
    );
  });

  test('decodeEventLogs extracts typed events from program logs', () {
    final eventPayload = <int>[
      ...eventDiscriminator('MyEvent'),
      ...getAddressEncoder().encode(authorityAddress),
      7,
      0,
      0,
      0,
    ];
    final logs = [
      'Program 11111111111111111111111111111111 invoke [1]',
      'Program log: hello',
      'Program data: ${base64Encode(eventPayload)}',
      'Program 11111111111111111111111111111111 success',
    ];
    final events = coder.decodeEventLogs(logs);
    expect(events, hasLength(1));
    expect(events.first.name, 'MyEvent');
    expect(events.first.data['from'], authorityAddress);
    expect(events.first.data['delta'], 7);

    expect(coder.decodeEventLogs(['Program log: nothing here']), isEmpty);
  });

  test('errors resolve against IDL codes first, then the standard table', () {
    final error = anchorProgramError(6000, idl: coder.idl);
    expect(error.name, 'Custom');
    expect(error.message, 'custom message');

    final standard = anchorProgramError(1001);
    expect(standard.name, 'AccountDiscriminatorNotFound');

    final unknown = anchorProgramError(987654);
    expect(unknown.name, 'Unknown');
    expect(
      unknown.message,
      contains('not a known Anchor error'),
    );
  });
}

List<int> bytesFromHex(String hex) {
  final result = <int>[];
  final clean = hex.replaceAll(RegExp('[^0-9a-fA-F]'), '');
  for (var i = 0; i + 1 < clean.length; i += 2) {
    result.add(int.parse(clean.substring(i, i + 2), radix: 16));
  }
  return result;
}
