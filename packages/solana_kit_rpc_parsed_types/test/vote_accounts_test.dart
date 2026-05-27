import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_rpc_parsed_types/solana_kit_rpc_parsed_types.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:test/test.dart';

void main() {
  group('JsonParsedVoteAccount', () {
    test('can be constructed with all fields', () {
      final account = JsonParsedVoteAccount(
        info: JsonParsedVoteInfo(
          authorizedVoters: [
            JsonParsedAuthorizedVoter(
              authorizedVoter: const Address(
                'HMU77m6WSL9Xew9YvVCgz1hLuhzamz74eD9avi4XPdr',
              ),
              epoch: BigInt.from(529),
            ),
          ],
          authorizedWithdrawer: const Address(
            'HMU77m6WSL9Xew9YvVCgz1hLuhzamz74eD9avi4XPdr',
          ),
          blockRevenueCollector: const Address(
            'Vote111111111111111111111111111111111111111',
          ),
          blockRevenueCommissionBps: BigInt.from(125),
          blsPubkeyCompressed: 'bls-compressed-key',
          commission: 50,
          epochCredits: [
            JsonParsedEpochCredit(
              credits: const StringifiedBigInt('68697256'),
              epoch: BigInt.from(466),
              previousCredits: const StringifiedBigInt('68325825'),
            ),
            JsonParsedEpochCredit(
              credits: const StringifiedBigInt('69068118'),
              epoch: BigInt.from(467),
              previousCredits: const StringifiedBigInt('68697256'),
            ),
          ],
          inflationRewardsCollector: const Address(
            'Vote111111111111111111111111111111111111111',
          ),
          inflationRewardsCommissionBps: BigInt.from(250),
          lastTimestamp: JsonParsedLastTimestamp(
            slot: BigInt.from(228884530),
            timestamp: UnixTimestamp(BigInt.from(1689090220)),
          ),
          nodePubkey: const Address(
            'HMU77m6WSL9Xew9YvVCgz1hLuhzamz74eD9avi4XPdr',
          ),
          pendingDelegatorRewards: const StringifiedBigInt('123456789'),
          priorVoters: [],
          rootSlot: BigInt.from(228884499),
          votes: [
            JsonParsedVote(
              confirmationCount: 31,
              latency: BigInt.from(2),
              slot: BigInt.from(228884500),
            ),
            JsonParsedVote(confirmationCount: 30, slot: BigInt.from(228884501)),
          ],
        ),
      );

      expect(account.info.authorizedVoters, hasLength(1));
      expect(
        account.info.authorizedVoters[0].authorizedVoter.value,
        'HMU77m6WSL9Xew9YvVCgz1hLuhzamz74eD9avi4XPdr',
      );
      expect(account.info.authorizedVoters[0].epoch, BigInt.from(529));
      expect(
        account.info.authorizedWithdrawer.value,
        'HMU77m6WSL9Xew9YvVCgz1hLuhzamz74eD9avi4XPdr',
      );
      expect(
        account.info.blockRevenueCollector?.value,
        'Vote111111111111111111111111111111111111111',
      );
      expect(account.info.blockRevenueCommissionBps, BigInt.from(125));
      expect(account.info.blsPubkeyCompressed, 'bls-compressed-key');
      expect(account.info.commission, 50);
      expect(account.info.epochCredits, hasLength(2));
      expect(account.info.epochCredits[0].credits.value, '68697256');
      expect(account.info.lastTimestamp.slot, BigInt.from(228884530));
      expect(
        account.info.lastTimestamp.timestamp.value,
        BigInt.from(1689090220),
      );
      expect(
        account.info.nodePubkey.value,
        'HMU77m6WSL9Xew9YvVCgz1hLuhzamz74eD9avi4XPdr',
      );
      expect(
        account.info.inflationRewardsCollector?.value,
        'Vote111111111111111111111111111111111111111',
      );
      expect(account.info.inflationRewardsCommissionBps, BigInt.from(250));
      expect(account.info.pendingDelegatorRewards?.value, '123456789');
      expect(account.info.priorVoters, isEmpty);
      expect(account.info.rootSlot, BigInt.from(228884499));
      expect(account.info.votes, hasLength(2));
      expect(account.info.votes[0].confirmationCount, 31);
      expect(account.info.votes[0].latency, BigInt.from(2));
      expect(account.info.votes[0].slot, BigInt.from(228884500));
    });

    test('compares and formats Agave v3 fields', () {
      const collector = Address('Vote111111111111111111111111111111111111111');
      const withdrawer = Address('HMU77m6WSL9Xew9YvVCgz1hLuhzamz74eD9avi4XPdr');
      final timestamp = JsonParsedLastTimestamp(
        slot: BigInt.one,
        timestamp: UnixTimestamp(BigInt.two),
      );
      final vote = JsonParsedVote(
        confirmationCount: 1,
        latency: BigInt.from(3),
        slot: BigInt.from(4),
      );
      final sameVote = JsonParsedVote(
        confirmationCount: 1,
        latency: BigInt.from(3),
        slot: BigInt.from(4),
      );
      final info = JsonParsedVoteInfo(
        authorizedVoters: const [],
        authorizedWithdrawer: withdrawer,
        blockRevenueCollector: collector,
        blockRevenueCommissionBps: BigInt.from(500),
        commission: 10,
        epochCredits: const [],
        inflationRewardsCollector: collector,
        inflationRewardsCommissionBps: BigInt.from(600),
        lastTimestamp: timestamp,
        nodePubkey: withdrawer,
        pendingDelegatorRewards: const StringifiedBigInt('42'),
        priorVoters: const [],
        votes: [vote],
      );
      final sameInfo = JsonParsedVoteInfo(
        authorizedVoters: const [],
        authorizedWithdrawer: withdrawer,
        blockRevenueCollector: collector,
        blockRevenueCommissionBps: BigInt.from(500),
        commission: 10,
        epochCredits: const [],
        inflationRewardsCollector: collector,
        inflationRewardsCommissionBps: BigInt.from(600),
        lastTimestamp: timestamp,
        nodePubkey: withdrawer,
        pendingDelegatorRewards: const StringifiedBigInt('42'),
        priorVoters: const [],
        votes: [sameVote],
      );

      expect(vote, sameVote);
      expect(vote.hashCode, sameVote.hashCode);
      expect(vote.toString(), contains('latency: 3'));
      expect(info, sameInfo);
      expect(info.hashCode, sameInfo.hashCode);
      expect(info.toString(), contains('blockRevenueCommissionBps: 500'));
      expect(info.toString(), contains('pendingDelegatorRewards: 42'));
    });

    test('can be constructed with null rootSlot', () {
      final account = JsonParsedVoteAccount(
        info: JsonParsedVoteInfo(
          authorizedVoters: [],
          authorizedWithdrawer: const Address(
            'HMU77m6WSL9Xew9YvVCgz1hLuhzamz74eD9avi4XPdr',
          ),
          commission: 0,
          epochCredits: [],
          lastTimestamp: JsonParsedLastTimestamp(
            slot: BigInt.zero,
            timestamp: UnixTimestamp(BigInt.zero),
          ),
          nodePubkey: const Address(
            'HMU77m6WSL9Xew9YvVCgz1hLuhzamz74eD9avi4XPdr',
          ),
          priorVoters: [],
          votes: [],
        ),
      );

      expect(account.info.rootSlot, isNull);
    });
  });
}
