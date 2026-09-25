/// Compatibility tests for a real Anchor 0.31 program running on Surfpool.
///
/// These tests deliberately cross every public boundary used by an Anchor
/// application: the checked-in IDL is parsed at runtime, instruction data is
/// encoded by [AnchorCoder], transactions are compiled and signed by Solana
/// Kit, the Anchor program validates its accounts on-chain, and returned
/// account bytes, events, and errors are decoded by the Dart SDK.
///
/// Expected outcomes are stated in each test name and assertion. A regression
/// in the Anchor ABI, account roles, signing, transaction wire format, RPC
/// transport, or event provenance therefore fails as an observable program
/// result rather than as an implementation-specific mock expectation.
@TestOn('vm')
@Tags(['integration'])
library;

import 'dart:convert';
import 'dart:io';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_anchor/solana_kit_anchor.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_integration_tests/solana_kit_integration_tests.dart';
import 'package:solana_kit_rpc/solana_kit_rpc.dart';
import 'package:solana_kit_rpc_api/solana_kit_rpc_api.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:solana_kit_signers/solana_kit_signers.dart';
import 'package:test/test.dart';

const anchorCompatibilityProgram = Address(
  'Fg6PaFpoGXkYsidMpWTK6W2BeZ7FEfcYkg476zPFsLnS',
);
const anchorEventImposterProgram = Address(
  '8MyZkLi7NVstEPYwQoSS9VtKAcaRzGNLqxwQX4VtwW1e',
);

const _counterProgramArtifact =
    'config/programs/anchor_compatibility-v0.1.0.so';
const _counterIdlArtifact = 'config/programs/anchor_compatibility-v0.1.0.json';
const _imposterProgramArtifact =
    'config/programs/anchor_event_imposter-v0.1.0.so';
const _imposterIdlArtifact =
    'config/programs/anchor_event_imposter-v0.1.0.json';

void main() {
  late IntegrationTestEnv env;
  late AnchorCoder counterCoder;
  late AnchorCoder imposterCoder;

  setUpAll(() async {
    env = await IntegrationTestEnv.create();
    counterCoder = _readCoder(_counterIdlArtifact);
    imposterCoder = _readCoder(_imposterIdlArtifact);
    await env.deployProgram(
      anchorCompatibilityProgram,
      _counterProgramArtifact,
    );
    await env.deployProgram(
      anchorEventImposterProgram,
      _imposterProgramArtifact,
    );
  });

  tearDownAll(() => env.dispose());

  test(
    'Anchor artifacts deploy at their IDL addresses and are executable',
    () async {
      // The binary's declared program ID, the IDL address, and the deployment
      // address must agree. Anchor rejects calls when any one drifts.
      expect(counterCoder.idl.address, anchorCompatibilityProgram);
      expect(imposterCoder.idl.address, anchorEventImposterProgram);

      for (final program in [
        anchorCompatibilityProgram,
        anchorEventImposterProgram,
      ]) {
        final response = await env.rpc.getAccountInfoValue(program).send();
        expect(response.value, isNotNull, reason: '$program should exist');
        expect(response.value!['executable'], isTrue);
        expect(
          response.value!['owner'],
          'BPFLoaderUpgradeab1e11111111111111111111111',
        );
      }
    },
  );

  test(
    'IDL-encoded initialize creates state that AnchorCoder decodes exactly',
    () async {
      // A successful result proves that the Dart coder matches Anchor's
      // discriminator and Borsh ABI and that writable/signer roles survive
      // Solana Kit transaction compilation.
      final counter = generateKeyPairSigner();
      final signature = await env.sendInstructions(
        [
          _initializeInstruction(
            env,
            counterCoder,
            counter,
            initialValue: 41,
            label: 'surfpool',
          ),
        ],
        extraSigners: [counter],
      );

      final account = await _readCounter(env, counterCoder, counter.address);
      expect(account['authority'], env.payer.address);
      expect(account['value'], BigInt.from(41));
      expect(account['label'], 'surfpool');

      final events = counterCoder.decodeEventLogs(
        await env.transactionLogMessages(signature),
      );
      expect(events, hasLength(1));
      expect(events.single.name, 'CounterChanged');
      expect(events.single.data, {
        'authority': env.payer.address,
        'previous_value': BigInt.zero,
        'value': BigInt.from(41),
        'label': 'surfpool',
      });
    },
  );

  test(
    'IDL-encoded increment mutates state and emits the expected Anchor event',
    () async {
      final counter = generateKeyPairSigner();
      await env.sendInstructions(
        [
          _initializeInstruction(
            env,
            counterCoder,
            counter,
            initialValue: 7,
            label: 'counter',
          ),
        ],
        extraSigners: [counter],
      );

      final signature = await env.sendInstructions([
        _incrementInstruction(
          counterCoder,
          counter.address,
          env.payer.address,
          amount: 5,
        ),
      ]);

      final account = await _readCounter(env, counterCoder, counter.address);
      expect(account['value'], BigInt.from(12));
      expect(account['label'], 'counter');

      final events = counterCoder.decodeEventLogs(
        await env.transactionLogMessages(signature),
      );
      expect(events, hasLength(1));
      expect(events.single.data['previous_value'], BigInt.from(7));
      expect(events.single.data['value'], BigInt.from(12));
    },
  );

  test(
    'Anchor has-one and signer constraints reject another authority',
    () async {
      // The transaction is correctly signed by the attacker, but Anchor must
      // reject it because the stored authority differs. State must remain
      // unchanged after the failed transaction.
      final counter = generateKeyPairSigner();
      await env.sendInstructions(
        [
          _initializeInstruction(
            env,
            counterCoder,
            counter,
            initialValue: 10,
            label: 'owned',
          ),
        ],
        extraSigners: [counter],
      );
      final attacker = generateKeyPairSigner();

      final error = await _captureFailure(
        () => env.sendInstructions(
          [
            _incrementInstruction(
              counterCoder,
              counter.address,
              attacker.address,
              amount: 1,
            ),
          ],
          extraSigners: [attacker],
        ),
      );
      expect(_customProgramErrorCode(error), 2001);
      expect(anchorProgramError(2001).name, 'ConstraintHasOne');

      final account = await _readCounter(env, counterCoder, counter.address);
      expect(account['value'], BigInt.from(10));
    },
  );

  test(
    'custom Anchor errors propagate and failed instructions do not mutate state',
    () async {
      // Initializing at u64::MAX is valid. Incrementing by one must return the
      // fixture's first custom error (6000 / 0x1770), and Solana's atomic
      // transaction semantics must preserve the previous account value.
      final counter = generateKeyPairSigner();
      final maxU64 = BigInt.parse('18446744073709551615');
      await env.sendInstructions(
        [
          _initializeInstruction(
            env,
            counterCoder,
            counter,
            initialValue: maxU64,
            label: 'maximum',
          ),
        ],
        extraSigners: [counter],
      );

      final error = await _captureFailure(
        () => env.sendInstructions([
          _incrementInstruction(
            counterCoder,
            counter.address,
            env.payer.address,
            amount: 1,
          ),
        ]),
      );
      expect(_customProgramErrorCode(error), 6000);

      final resolved = anchorProgramError(6000, idl: counterCoder.idl);
      expect(resolved.name, 'CounterOverflow');
      expect(resolved.message, 'The counter would overflow a u64');
      final account = await _readCounter(env, counterCoder, counter.address);
      expect(account['value'], maxU64);
    },
  );

  test(
    'failed Anchor initialization leaves no partially created account',
    () async {
      // The IDL can encode a longer string, but the deployed program enforces
      // its domain limit. Its custom error must reach the client and account
      // creation must roll back with the instruction.
      final counter = generateKeyPairSigner();
      final error = await _captureFailure(
        () => env.sendInstructions(
          [
            _initializeInstruction(
              env,
              counterCoder,
              counter,
              initialValue: 1,
              label: List.filled(33, 'x').join(),
            ),
          ],
          extraSigners: [counter],
        ),
      );
      expect(_customProgramErrorCode(error), 6001);
      expect(
        anchorProgramError(6001, idl: counterCoder.idl).name,
        'LabelTooLong',
      );

      final response = await env.rpc
          .getAccountInfoValue(counter.address)
          .send();
      expect(response.value, isNull);
    },
  );

  test(
    'event decoding accepts the Anchor program and ignores identical foreign bytes',
    () async {
      // Both programs emit a CounterChanged event with the same Anchor event
      // discriminator and layout. The real coder must return only the event
      // whose runtime invocation belongs to its IDL program address.
      final counter = generateKeyPairSigner();
      await env.sendInstructions(
        [
          _initializeInstruction(
            env,
            counterCoder,
            counter,
            initialValue: 2,
            label: 'real',
          ),
        ],
        extraSigners: [counter],
      );

      final signature = await env.sendInstructions([
        _incrementInstruction(
          counterCoder,
          counter.address,
          env.payer.address,
          amount: 3,
        ),
        Instruction(
          programAddress: anchorEventImposterProgram,
          accounts: const [],
          data: imposterCoder.encodeInstructionData('emit_counter_changed', {
            'authority': env.payer.address,
            'previous_value': BigInt.from(900),
            'value': BigInt.from(901),
            'label': 'forged',
          }),
        ),
      ]);
      final logs = await env.transactionLogMessages(signature);

      final genuineEvents = counterCoder.decodeEventLogs(logs);
      expect(genuineEvents, hasLength(1));
      expect(genuineEvents.single.data['previous_value'], BigInt.from(2));
      expect(genuineEvents.single.data['value'], BigInt.from(5));
      expect(genuineEvents.single.data['label'], 'real');

      final foreignEvents = imposterCoder.decodeEventLogs(logs);
      expect(foreignEvents, hasLength(1));
      expect(foreignEvents.single.data['value'], BigInt.from(901));
      expect(foreignEvents.single.data['label'], 'forged');
    },
  );
}

Instruction _initializeInstruction(
  IntegrationTestEnv env,
  AnchorCoder coder,
  KeyPairSigner counter, {
  required Object initialValue,
  required String label,
}) => Instruction(
  programAddress: anchorCompatibilityProgram,
  accounts: [
    AccountMeta(
      address: counter.address,
      role: AccountRole.writableSigner,
    ),
    AccountMeta(
      address: env.payer.address,
      role: AccountRole.writableSigner,
    ),
    const AccountMeta(
      address: systemProgramAddress,
      role: AccountRole.readonly,
    ),
  ],
  data: coder.encodeInstructionData('initialize', {
    'initial_value': _asBigInt(initialValue),
    'label': label,
  }),
);

Instruction _incrementInstruction(
  AnchorCoder coder,
  Address counter,
  Address authority, {
  required Object amount,
}) => Instruction(
  programAddress: anchorCompatibilityProgram,
  accounts: [
    AccountMeta(address: counter, role: AccountRole.writable),
    AccountMeta(address: authority, role: AccountRole.readonlySigner),
  ],
  data: coder.encodeInstructionData('increment', {
    'amount': _asBigInt(amount),
  }),
);

BigInt _asBigInt(Object value) =>
    value is BigInt ? value : BigInt.from(value as int);

AnchorCoder _readCoder(String idlPath) {
  final file = File(resolveWorkspaceArtifactPath(idlPath));
  return AnchorCoder(AnchorIdlProgram.parse(file.readAsStringSync()));
}

Future<Map<String, AnchorValue>> _readCounter(
  IntegrationTestEnv env,
  AnchorCoder coder,
  Address address,
) async {
  final response = await env.rpc
      .getAccountInfoValue(
        address,
        const GetAccountInfoConfig(encoding: AccountEncoding.base64),
      )
      .send();
  expect(response.value, isNotNull, reason: '$address should exist');
  expect(response.value!['owner'], anchorCompatibilityProgram.value);
  final encoded = response.value!['data']! as List<Object?>;
  final bytes = base64Decode(encoded.first! as String);
  return coder.decodeAccount('Counter', bytes).data;
}

Future<Object> _captureFailure(Future<Object?> Function() action) async {
  try {
    await action();
  } on Object catch (error) {
    return error;
  }
  throw StateError('Expected the Surfpool transaction to fail');
}

Object? _customProgramErrorCode(Object error) {
  final cause = error is SolanaError ? error.context['cause'] : null;
  if (cause is! SolanaError ||
      cause.code != SolanaErrorCode.instructionErrorCustom) {
    return null;
  }
  final code = cause.context['code'];
  return code is BigInt ? code.toInt() : code;
}
