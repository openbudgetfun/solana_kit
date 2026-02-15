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
  });
}
