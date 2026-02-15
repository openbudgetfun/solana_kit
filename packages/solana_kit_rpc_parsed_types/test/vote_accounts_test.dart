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
          lastTimestamp: JsonParsedLastTimestamp(
            slot: BigInt.from(228884530),
            timestamp: UnixTimestamp(BigInt.from(1689090220)),
          ),
          nodePubkey: const Address(
            'HMU77m6WSL9Xew9YvVCgz1hLuhzamz74eD9avi4XPdr',
          ),
          priorVoters: [],
          rootSlot: BigInt.from(228884499),
          votes: [
            JsonParsedVote(confirmationCount: 31, slot: BigInt.from(228884500)),
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
      expect(account.info.priorVoters, isEmpty);
      expect(account.info.rootSlot, BigInt.from(228884499));
      expect(account.info.votes, hasLength(2));
      expect(account.info.votes[0].confirmationCount, 31);
      expect(account.info.votes[0].slot, BigInt.from(228884500));
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
