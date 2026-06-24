import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_surfpool/solana_kit_surfpool.dart';
import 'package:test/test.dart';

void main() {
  const account = Address('11111111111111111111111111111111');
  const owner = Address('BPFLoaderUpgradeab1e11111111111111111111111');

  group('SolAccountFunding', () {
    test('stores address and lamports', () {
      const funding = SolAccountFunding(address: account, lamports: 10);

      expect(funding.address, account);
      expect(funding.lamports, 10);
    });
  });

  group('KeypairInfo', () {
    test('requires 64-byte secret keys and copies them defensively', () {
      final secretKey = Uint8List.fromList(
        List<int>.generate(64, (index) => index),
      );
      final info = KeypairInfo(publicKey: account, secretKey: secretKey);

      secretKey[0] = 255;
      final exposedSecretKey = info.secretKey;
      exposedSecretKey[1] = 255;

      expect(info.publicKey, account);
      expect(info.address, account);
      expect(info.secretKey.take(2), <int>[0, 1]);
      expect(
        () => KeypairInfo(publicKey: account, secretKey: Uint8List(63)),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('SetTokenAccountUpdate', () {
    test('serializes set and clear operations', () {
      expect(
        const SetTokenAccountUpdate(
          amount: 5,
          delegate: owner,
          state: 'initialized',
          delegatedAmount: 2,
          closeAuthority: owner,
        ).toJson(),
        <String, Object?>{
          'amount': 5,
          'delegate': owner.value,
          'state': 'initialized',
          'delegatedAmount': 2,
          'closeAuthority': owner.value,
        },
      );
      expect(
        const SetTokenAccountUpdate(
          clearDelegate: true,
          clearCloseAuthority: true,
        ).toJson(),
        <String, Object?>{
          'delegate': 'null',
          'closeAuthority': 'null',
        },
      );
    });

    test('rejects invalid update combinations and negative amounts', () {
      expect(
        () => const SetTokenAccountUpdate(amount: -1).toJson(),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => const SetTokenAccountUpdate(delegatedAmount: -1).toJson(),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => const SetTokenAccountUpdate(
          delegate: owner,
          clearDelegate: true,
        ).toJson(),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => const SetTokenAccountUpdate(
          closeAuthority: owner,
          clearCloseAuthority: true,
        ).toJson(),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('ResetAccountOptions and StreamAccountOptions', () {
    test('serialize empty and explicit options', () {
      expect(const ResetAccountOptions().toJson(), isEmpty);
      expect(
        const ResetAccountOptions(includeOwnedAccounts: true).toJson(),
        <String, Object?>{'includeOwnedAccounts': true},
      );
      expect(const StreamAccountOptions().toJson(), isEmpty);
      expect(
        const StreamAccountOptions(includeOwnedAccounts: false).toJson(),
        <String, Object?>{'includeOwnedAccounts': false},
      );
    });
  });

  group('DeployOptions', () {
    test('requires exactly one program byte source and copies bytes', () {
      final soBytes = Uint8List.fromList(<int>[1, 2, 3]);
      final options = DeployOptions(programId: account, soBytes: soBytes);

      soBytes[0] = 9;
      final exposedBytes = options.soBytes!;
      exposedBytes[1] = 9;

      expect(options.programId, account);
      expect(options.soPath, isNull);
      expect(options.soBytes, <int>[1, 2, 3]);
      expect(options.idlPath, isNull);
      expect(
        () => DeployOptions(programId: account),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => DeployOptions(
          programId: account,
          soPath: 'program.so',
          soBytes: Uint8List(1),
        ),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('EpochInfoValue', () {
    test('parses JSON and round trips', () {
      final info = EpochInfoValue.fromJson(const <String, Object?>{
        'absoluteSlot': 10,
        'slotIndex': 2,
        'slotsInEpoch': 32,
        'epoch': 1,
        'blockHeight': 9,
        'transactionCount': 4,
      });
      final withoutTransactionCount = EpochInfoValue.fromJson(
        const <String, Object?>{
          'absoluteSlot': 11,
          'slotIndex': 3,
          'slotsInEpoch': 32,
          'epoch': 1,
          'blockHeight': 10,
        },
      );

      expect(info.absoluteSlot, 10);
      expect(info.toJson(), <String, Object?>{
        'absoluteSlot': 10,
        'slotIndex': 2,
        'slotsInEpoch': 32,
        'epoch': 1,
        'blockHeight': 9,
        'transactionCount': 4,
      });
      final fromGenericMap = EpochInfoValue.fromJson(const <Object, Object?>{
        'absoluteSlot': 12,
        'slotIndex': 4,
        'slotsInEpoch': 32,
        'epoch': 1,
        'blockHeight': 11,
      });

      expect(withoutTransactionCount.transactionCount, isNull);
      expect(
        withoutTransactionCount.toJson(),
        isNot(containsPair('transactionCount', anything)),
      );
      expect(fromGenericMap.absoluteSlot, 12);
    });

    test('rejects malformed JSON', () {
      expect(() => EpochInfoValue.fromJson(null), throwsFormatException);
      expect(
        () => EpochInfoValue.fromJson(const <String, Object?>{
          'absoluteSlot': '10',
          'slotIndex': 2,
          'slotsInEpoch': 32,
          'epoch': 1,
          'blockHeight': 9,
        }),
        throwsFormatException,
      );
      expect(
        () => EpochInfoValue.fromJson(const <String, Object?>{
          'absoluteSlot': 10,
          'slotIndex': 2,
          'slotsInEpoch': 32,
          'epoch': 1,
          'blockHeight': 9,
          'transactionCount': '4',
        }),
        throwsFormatException,
      );
    });
  });

  group('ClockValue', () {
    test('parses JSON and round trips', () {
      final clock = ClockValue.fromJson(const <String, Object?>{
        'slot': 1,
        'epochStartTimestamp': 2,
        'epoch': 3,
        'leaderScheduleEpoch': 4,
        'unixTimestamp': 5,
      });
      const emptyClock = ClockValue();

      expect(clock.slot, 1);
      expect(clock.epochStartTimestamp, 2);
      expect(clock.epoch, 3);
      expect(clock.leaderScheduleEpoch, 4);
      expect(clock.unixTimestamp, 5);
      expect(clock.toJson(), <String, Object?>{
        'slot': 1,
        'epochStartTimestamp': 2,
        'epoch': 3,
        'leaderScheduleEpoch': 4,
        'unixTimestamp': 5,
      });
      expect(emptyClock.toJson(), isEmpty);
      expect(() => ClockValue.fromJson(null), throwsFormatException);
      expect(
        () => ClockValue.fromJson(const <String, Object?>{'slot': '1'}),
        throwsFormatException,
      );
    });
  });

  group('SimnetEventValue', () {
    test('parses optional nested values', () {
      final event = SimnetEventValue.fromJson(<String, Object?>{
        'kind': 'transactionProcessed',
        'message': 'processed',
        'timestamp': '2026-01-01T00:00:00.000Z',
        'initialTransactionCount': 1,
        'clock': const <String, Object?>{'slot': 9},
        'epochInfo': const <String, Object?>{
          'absoluteSlot': 10,
          'slotIndex': 2,
          'slotsInEpoch': 32,
          'epoch': 1,
          'blockHeight': 9,
        },
        'clockCommand': 'advance',
        'slotIntervalMs': 20,
        'accountPubkey': account.value,
        'transactionSignature': 'sig',
        'logs': const <String>['log 1'],
        'computeUnitsConsumed': 10,
        'fee': 5000,
        'errorMessage': 'boom',
        'tag': 'profile',
        'profileKey': 'key',
        'profileSlot': 11,
        'runbookId': 'runbook',
        'runbookErrors': const <String>['error 1'],
      });

      expect(event.kind, 'transactionProcessed');
      expect(event.message, 'processed');
      expect(event.timestamp, '2026-01-01T00:00:00.000Z');
      expect(event.initialTransactionCount, 1);
      expect(event.clock?.slot, 9);
      expect(event.epochInfo?.absoluteSlot, 10);
      expect(event.clockCommand, 'advance');
      expect(event.slotIntervalMs, 20);
      expect(event.accountPubkey, account.value);
      expect(event.transactionSignature, 'sig');
      expect(event.logs, <String>['log 1']);
      expect(event.computeUnitsConsumed, 10);
      expect(event.fee, 5000);
      expect(event.errorMessage, 'boom');
      expect(event.tag, 'profile');
      expect(event.profileKey, 'key');
      expect(event.profileSlot, 11);
      expect(event.runbookId, 'runbook');
      expect(event.runbookErrors, <String>['error 1']);
      expect(() => event.logs!.add('mutate'), throwsUnsupportedError);
      expect(() => event.runbookErrors!.add('mutate'), throwsUnsupportedError);
      expect(event.toJson(), <String, Object?>{
        'kind': 'transactionProcessed',
        'message': 'processed',
        'timestamp': '2026-01-01T00:00:00.000Z',
        'initialTransactionCount': 1,
        'clock': <String, Object?>{'slot': 9},
        'epochInfo': <String, Object?>{
          'absoluteSlot': 10,
          'slotIndex': 2,
          'slotsInEpoch': 32,
          'epoch': 1,
          'blockHeight': 9,
        },
        'clockCommand': 'advance',
        'slotIntervalMs': 20,
        'accountPubkey': account.value,
        'transactionSignature': 'sig',
        'logs': <String>['log 1'],
        'computeUnitsConsumed': 10,
        'fee': 5000,
        'errorMessage': 'boom',
        'tag': 'profile',
        'profileKey': 'key',
        'profileSlot': 11,
        'runbookId': 'runbook',
        'runbookErrors': <String>['error 1'],
      });
    });

    test('handles events without optional lists', () {
      final event = SimnetEventValue.fromJson(const <String, Object?>{
        'kind': 'startup',
      });

      expect(event.logs, isNull);
      expect(event.runbookErrors, isNull);
      expect(event.toJson(), <String, Object?>{'kind': 'startup'});
    });

    test('rejects malformed event fields', () {
      expect(() => SimnetEventValue.fromJson(null), throwsFormatException);
      expect(
        () => SimnetEventValue.fromJson(const <String, Object?>{'kind': 1}),
        throwsFormatException,
      );
      expect(
        () => SimnetEventValue.fromJson(const <String, Object?>{
          'kind': 'event',
          'message': 1,
        }),
        throwsFormatException,
      );
      expect(
        () => SimnetEventValue.fromJson(const <String, Object?>{
          'kind': 'event',
          'logs': 'not a list',
        }),
        throwsFormatException,
      );
      expect(
        () => SimnetEventValue.fromJson(const <String, Object?>{
          'kind': 'event',
          'logs': <Object?>['ok', 1],
        }),
        throwsFormatException,
      );
    });
  });
}
