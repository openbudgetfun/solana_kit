import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_rpc_parsed_types/solana_kit_rpc_parsed_types.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:test/test.dart';

void main() {
  group('JsonParsedStakeProgramAccount', () {
    JsonParsedStakeAccountInfo createStakeInfo() {
      return JsonParsedStakeAccountInfo(
        meta: JsonParsedStakeMeta(
          authorized: const JsonParsedStakeAuthorized(
            staker: Address('3HRNKNXafhr3wE9NSXRpNVdFYt6EVygdqFwqf6WpG57V'),
            withdrawer: Address('3HRNKNXafhr3wE9NSXRpNVdFYt6EVygdqFwqf6WpG57V'),
          ),
          lockup: JsonParsedStakeLockup(
            custodian: const Address('11111111111111111111111111111111'),
            epoch: BigInt.zero,
            unixTimestamp: UnixTimestamp(BigInt.zero),
          ),
          rentExemptReserve: const StringifiedBigInt('2282880'),
        ),
        stake: JsonParsedStakeData(
          creditsObserved: BigInt.from(169965713),
          delegation: const JsonParsedStakeDelegation(
            activationEpoch: StringifiedBigInt('386'),
            deactivationEpoch: StringifiedBigInt('471'),
            stake: StringifiedBigInt('8007935'),
            voter: Address('CertusDeBmqN8ZawdkxK5kFGMwBXdudvWHYwtNgNhvLu'),
            warmupCooldownRate: 0.25,
          ),
        ),
      );
    }

    test('can construct an initialized stake account', () {
      final account = JsonParsedInitializedStake(info: createStakeInfo());

      expect(account.type, 'initialized');
      expect(
        account.info.meta.authorized.staker.value,
        '3HRNKNXafhr3wE9NSXRpNVdFYt6EVygdqFwqf6WpG57V',
      );
      expect(account.info.meta.rentExemptReserve.value, '2282880');
      expect(account.info.stake?.delegation.stake.value, '8007935');
      expect(account, isA<JsonParsedStakeProgramAccount>());
    });

    test('can construct a delegated stake account', () {
      final account = JsonParsedDelegatedStake(info: createStakeInfo());

      expect(account.type, 'delegated');
      expect(
        account.info.meta.authorized.staker.value,
        '3HRNKNXafhr3wE9NSXRpNVdFYt6EVygdqFwqf6WpG57V',
      );
      expect(account.info.stake?.delegation.warmupCooldownRate, 0.25);
      expect(account, isA<JsonParsedStakeProgramAccount>());
    });

    test('can construct a stake account without delegation', () {
      final account = JsonParsedInitializedStake(
        info: JsonParsedStakeAccountInfo(
          meta: JsonParsedStakeMeta(
            authorized: const JsonParsedStakeAuthorized(
              staker: Address('3HRNKNXafhr3wE9NSXRpNVdFYt6EVygdqFwqf6WpG57V'),
              withdrawer: Address(
                '3HRNKNXafhr3wE9NSXRpNVdFYt6EVygdqFwqf6WpG57V',
              ),
            ),
            lockup: JsonParsedStakeLockup(
              custodian: const Address('11111111111111111111111111111111'),
              epoch: BigInt.zero,
              unixTimestamp: UnixTimestamp(BigInt.zero),
            ),
            rentExemptReserve: const StringifiedBigInt('2282880'),
          ),
        ),
      );

      expect(account.info.stake, isNull);
    });

    test('can discriminate via sealed class', () {
      final JsonParsedStakeProgramAccount account = JsonParsedInitializedStake(
        info: createStakeInfo(),
      );

      switch (account) {
        case JsonParsedInitializedStake(:final info):
          expect(
            info.meta.authorized.staker.value,
            '3HRNKNXafhr3wE9NSXRpNVdFYt6EVygdqFwqf6WpG57V',
          );
        case JsonParsedDelegatedStake():
          fail('Expected initialized, got delegated');
      }
    });

    test('stake account models expose readable toString output', () {
      final stakeInfo = createStakeInfo();
      expect(stakeInfo.toString(), contains('rentExemptReserve'));
      expect(stakeInfo.meta.toString(), contains('authorized'));
      expect(stakeInfo.meta.authorized.toString(), contains('staker'));
      expect(stakeInfo.meta.lockup.toString(), contains('custodian'));
      expect(stakeInfo.stake.toString(), contains('creditsObserved'));
      expect(
        stakeInfo.stake!.delegation.toString(),
        contains('warmupCooldownRate: 0.25'),
      );
    });

    test('JsonParsedStakeAccountInfo equality and hashCode', () {
      final info1 = createStakeInfo();
      final info2 = createStakeInfo();
      final info3 = JsonParsedStakeAccountInfo(
        meta: JsonParsedStakeMeta(
          authorized: const JsonParsedStakeAuthorized(
            staker: Address('3HRNKNXafhr3wE9NSXRpNVdFYt6EVygdqFwqf6WpG57V'),
            withdrawer: Address('3HRNKNXafhr3wE9NSXRpNVdFYt6EVygdqFwqf6WpG57V'),
          ),
          lockup: JsonParsedStakeLockup(
            custodian: const Address('11111111111111111111111111111111'),
            epoch: BigInt.zero,
            unixTimestamp: UnixTimestamp(BigInt.zero),
          ),
          rentExemptReserve: const StringifiedBigInt('2282880'),
        ),
      );

      expect(info1, equals(info2));
      expect(info1.hashCode, equals(info2.hashCode));
      expect(info1 == info3, isFalse);
    });

    test('JsonParsedStakeMeta equality, hashCode, and toString', () {
      final meta1 = JsonParsedStakeMeta(
        authorized: const JsonParsedStakeAuthorized(
          staker: Address('3HRNKNXafhr3wE9NSXRpNVdFYt6EVygdqFwqf6WpG57V'),
          withdrawer: Address('3HRNKNXafhr3wE9NSXRpNVdFYt6EVygdqFwqf6WpG57V'),
        ),
        lockup: JsonParsedStakeLockup(
          custodian: const Address('11111111111111111111111111111111'),
          epoch: BigInt.zero,
          unixTimestamp: UnixTimestamp(BigInt.zero),
        ),
        rentExemptReserve: const StringifiedBigInt('2282880'),
      );
      final meta2 = JsonParsedStakeMeta(
        authorized: const JsonParsedStakeAuthorized(
          staker: Address('3HRNKNXafhr3wE9NSXRpNVdFYt6EVygdqFwqf6WpG57V'),
          withdrawer: Address('3HRNKNXafhr3wE9NSXRpNVdFYt6EVygdqFwqf6WpG57V'),
        ),
        lockup: JsonParsedStakeLockup(
          custodian: const Address('11111111111111111111111111111111'),
          epoch: BigInt.zero,
          unixTimestamp: UnixTimestamp(BigInt.zero),
        ),
        rentExemptReserve: const StringifiedBigInt('2282880'),
      );
      final meta3 = JsonParsedStakeMeta(
        authorized: const JsonParsedStakeAuthorized(
          staker: Address('3HRNKNXafhr3wE9NSXRpNVdFYt6EVygdqFwqf6WpG57V'),
          withdrawer: Address('3HRNKNXafhr3wE9NSXRpNVdFYt6EVygdqFwqf6WpG57V'),
        ),
        lockup: JsonParsedStakeLockup(
          custodian: const Address('11111111111111111111111111111111'),
          epoch: BigInt.zero,
          unixTimestamp: UnixTimestamp(BigInt.zero),
        ),
        rentExemptReserve: const StringifiedBigInt('999999'),
      );

      expect(meta1, equals(meta2));
      expect(meta1.hashCode, equals(meta2.hashCode));
      expect(meta1 == meta3, isFalse);
      expect(meta1.toString(), contains('rentExemptReserve'));
    });

    test('JsonParsedStakeAuthorized toString', () {
      const auth = JsonParsedStakeAuthorized(
        staker: Address('3HRNKNXafhr3wE9NSXRpNVdFYt6EVygdqFwqf6WpG57V'),
        withdrawer: Address('3HRNKNXafhr3wE9NSXRpNVdFYt6EVygdqFwqf6WpG57V'),
      );
      expect(auth.toString(), contains('staker'));
    });

    test('JsonParsedStakeData equality, hashCode, and toString', () {
      final data1 = JsonParsedStakeData(
        creditsObserved: BigInt.from(169965713),
        delegation: const JsonParsedStakeDelegation(
          activationEpoch: StringifiedBigInt('386'),
          deactivationEpoch: StringifiedBigInt('471'),
          stake: StringifiedBigInt('8007935'),
          voter: Address('CertusDeBmqN8ZawdkxK5kFGMwBXdudvWHYwtNgNhvLu'),
          warmupCooldownRate: 0.25,
        ),
      );
      final data2 = JsonParsedStakeData(
        creditsObserved: BigInt.from(169965713),
        delegation: const JsonParsedStakeDelegation(
          activationEpoch: StringifiedBigInt('386'),
          deactivationEpoch: StringifiedBigInt('471'),
          stake: StringifiedBigInt('8007935'),
          voter: Address('CertusDeBmqN8ZawdkxK5kFGMwBXdudvWHYwtNgNhvLu'),
          warmupCooldownRate: 0.25,
        ),
      );
      final data3 = JsonParsedStakeData(
        creditsObserved: BigInt.from(999),
        delegation: const JsonParsedStakeDelegation(
          activationEpoch: StringifiedBigInt('386'),
          deactivationEpoch: StringifiedBigInt('471'),
          stake: StringifiedBigInt('8007935'),
          voter: Address('CertusDeBmqN8ZawdkxK5kFGMwBXdudvWHYwtNgNhvLu'),
          warmupCooldownRate: 0.25,
        ),
      );

      expect(data1, equals(data2));
      expect(data1.hashCode, equals(data2.hashCode));
      expect(data1 == data3, isFalse);
      expect(data1.toString(), contains('creditsObserved'));
    });

    test('JsonParsedStakeDeequality, hashCode, and toString', () {
      const d1 = JsonParsedStakeDelegation(
        activationEpoch: StringifiedBigInt('386'),
        deactivationEpoch: StringifiedBigInt('471'),
        stake: StringifiedBigInt('8007935'),
        voter: Address('CertusDeBmqN8ZawdkxK5kFGMwBXdudvWHYwtNgNhvLu'),
        warmupCooldownRate: 0.25,
      );
      const d2 = JsonParsedStakeDelegation(
        activationEpoch: StringifiedBigInt('386'),
        deactivationEpoch: StringifiedBigInt('471'),
        stake: StringifiedBigInt('8007935'),
        voter: Address('CertusDeBmqN8ZawdkxK5kFGMwBXdudvWHYwtNgNhvLu'),
        warmupCooldownRate: 0.25,
      );
      const d3 = JsonParsedStakeDelegation(
        activationEpoch: StringifiedBigInt('999'),
        deactivationEpoch: StringifiedBigInt('471'),
        stake: StringifiedBigInt('8007935'),
        voter: Address('CertusDeBmqN8ZawdkxK5kFGMwBXdudvWHYwtNgNhvLu'),
        warmupCooldownRate: 0.25,
      );

      expect(d1, equals(d2));
      expect(d1.hashCode, equals(d2.hashCode));
      expect(d1 == d3, isFalse);
      expect(d1.toString(), contains('warmupCooldownRate'));
    });
  });
}
