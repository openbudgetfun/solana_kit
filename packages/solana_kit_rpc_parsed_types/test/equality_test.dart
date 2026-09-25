import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_rpc_parsed_types/solana_kit_rpc_parsed_types.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart'
    show
        Blockhash,
        StringifiedBigInt,
        StringifiedNumber,
        TokenAmount,
        UnixTimestamp;
import 'package:test/test.dart';

// ---------------------------------------------------------------------------
// Minimal concrete helper with proper equality, used throughout the tests.
// ---------------------------------------------------------------------------

@immutable
class _IntInfo {
  const _IntInfo(this.value);
  final int value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is _IntInfo && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => '_IntInfo($value)';
}

/// A concrete [RpcParsedType] subclass for tests.
class _TestParsedType extends RpcParsedType<String, _IntInfo> {
  const _TestParsedType({required super.info}) : super(type: 'test');
}

/// A second concrete [RpcParsedType] subclass with a different runtimeType.
class _OtherParsedType extends RpcParsedType<String, _IntInfo> {
  const _OtherParsedType({required super.info}) : super(type: 'test');
}

/// A concrete [RpcParsedInfo] subclass for tests.
class _TestParsedInfo extends RpcParsedInfo<_IntInfo> {
  const _TestParsedInfo({required super.info});
}

/// A second concrete [RpcParsedInfo] subclass with a different runtimeType.
class _OtherParsedInfo extends RpcParsedInfo<_IntInfo> {
  const _OtherParsedInfo({required super.info});
}

// Convenience addresses used throughout.
const _addr1 = Address('11111111111111111111111111111111');
const _addr2 = Address('22222222222222222222222222222222');

void main() {
  // ---------------------------------------------------------------------------
  // RpcParsedType
  // ---------------------------------------------------------------------------
  group('RpcParsedType equality', () {
    test('equal when type and info match (same subclass)', () {
      const a = _TestParsedType(info: _IntInfo(1));
      const b = _TestParsedType(info: _IntInfo(1));
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('identical instance equals itself', () {
      const a = _TestParsedType(info: _IntInfo(7));
      expect(a, equals(a));
    });

    test('not equal when info differs', () {
      const a = _TestParsedType(info: _IntInfo(1));
      const b = _TestParsedType(info: _IntInfo(2));
      expect(a, isNot(equals(b)));
    });

    test('not equal when runtimeType differs (same type string and info)', () {
      const a = _TestParsedType(info: _IntInfo(1));
      const b = _OtherParsedType(info: _IntInfo(1));
      expect(a, isNot(equals(b)));
    });

    test('not equal to a different type', () {
      const a = _TestParsedType(info: _IntInfo(1));
      expect(a, isNot(equals('test')));
    });

    test('toString contains type field and info', () {
      const a = _TestParsedType(info: _IntInfo(5));
      expect(a.toString(), contains('RpcParsedType'));
      expect(a.toString(), contains('5'));
    });
  });

  // ---------------------------------------------------------------------------
  // RpcParsedInfo
  // ---------------------------------------------------------------------------
  group('RpcParsedInfo equality', () {
    test('equal when info matches (same subclass)', () {
      const a = _TestParsedInfo(info: _IntInfo(10));
      const b = _TestParsedInfo(info: _IntInfo(10));
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('identical instance equals itself', () {
      const a = _TestParsedInfo(info: _IntInfo(3));
      expect(a, equals(a));
    });

    test('not equal when info differs', () {
      const a = _TestParsedInfo(info: _IntInfo(10));
      const b = _TestParsedInfo(info: _IntInfo(20));
      expect(a, isNot(equals(b)));
    });

    test('not equal when runtimeType differs (same info)', () {
      const a = _TestParsedInfo(info: _IntInfo(10));
      const b = _OtherParsedInfo(info: _IntInfo(10));
      expect(a, isNot(equals(b)));
    });

    test('not equal to a different type', () {
      const a = _TestParsedInfo(info: _IntInfo(1));
      expect(a, isNot(equals(42)));
    });

    test('toString contains info', () {
      const a = _TestParsedInfo(info: _IntInfo(99));
      expect(a.toString(), contains('RpcParsedInfo'));
      expect(a.toString(), contains('99'));
    });
  });

  // ---------------------------------------------------------------------------
  // JsonParsedNonceFeeCalculator
  // ---------------------------------------------------------------------------
  group('JsonParsedNonceFeeCalculator equality', () {
    test('equal when lamportsPerSignature matches', () {
      const a = JsonParsedNonceFeeCalculator(
        lamportsPerSignature: StringifiedBigInt('5000'),
      );
      const b = JsonParsedNonceFeeCalculator(
        lamportsPerSignature: StringifiedBigInt('5000'),
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('not equal when lamportsPerSignature differs', () {
      const a = JsonParsedNonceFeeCalculator(
        lamportsPerSignature: StringifiedBigInt('5000'),
      );
      const b = JsonParsedNonceFeeCalculator(
        lamportsPerSignature: StringifiedBigInt('9000'),
      );
      expect(a, isNot(equals(b)));
    });

    test('toString is descriptive', () {
      const a = JsonParsedNonceFeeCalculator(
        lamportsPerSignature: StringifiedBigInt('5000'),
      );
      expect(a.toString(), contains('5000'));
    });
  });

  // ---------------------------------------------------------------------------
  // JsonParsedNonceInfo
  // ---------------------------------------------------------------------------
  group('JsonParsedNonceInfo equality', () {
    const calc = JsonParsedNonceFeeCalculator(
      lamportsPerSignature: StringifiedBigInt('5000'),
    );

    test('equal when all fields match', () {
      const a = JsonParsedNonceInfo(
        authority: _addr1,
        blockhash: Blockhash('hash1'),
        feeCalculator: calc,
      );
      const b = JsonParsedNonceInfo(
        authority: _addr1,
        blockhash: Blockhash('hash1'),
        feeCalculator: calc,
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('not equal when authority differs', () {
      const a = JsonParsedNonceInfo(
        authority: _addr1,
        blockhash: Blockhash('hash1'),
        feeCalculator: calc,
      );
      const b = JsonParsedNonceInfo(
        authority: _addr2,
        blockhash: Blockhash('hash1'),
        feeCalculator: calc,
      );
      expect(a, isNot(equals(b)));
    });

    test('toString is descriptive', () {
      const a = JsonParsedNonceInfo(
        authority: _addr1,
        blockhash: Blockhash('hash1'),
        feeCalculator: calc,
      );
      expect(a.toString(), contains('hash1'));
    });
  });

  // ---------------------------------------------------------------------------
  // JsonParsedBpfProgramInfo
  // ---------------------------------------------------------------------------
  group('JsonParsedBpfProgramInfo equality', () {
    test('equal when programData matches', () {
      const a = JsonParsedBpfProgramInfo(programData: _addr1);
      const b = JsonParsedBpfProgramInfo(programData: _addr1);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('not equal when programData differs', () {
      const a = JsonParsedBpfProgramInfo(programData: _addr1);
      const b = JsonParsedBpfProgramInfo(programData: _addr2);
      expect(a, isNot(equals(b)));
    });

    test('deep equality flows up through JsonParsedBpfProgram', () {
      const a = JsonParsedBpfProgram(
        info: JsonParsedBpfProgramInfo(programData: _addr1),
      );
      const b = JsonParsedBpfProgram(
        info: JsonParsedBpfProgramInfo(programData: _addr1),
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('toString is descriptive', () {
      const a = JsonParsedBpfProgramInfo(programData: _addr1);
      expect(a.toString(), contains('programData'));
    });
  });

  // ---------------------------------------------------------------------------
  // JsonParsedStakeConfigInfo
  // ---------------------------------------------------------------------------
  group('JsonParsedStakeConfigInfo equality', () {
    test('equal when all fields match', () {
      const a = JsonParsedStakeConfigInfo(
        slashPenalty: 12,
        warmupCooldownRate: 0.25,
      );
      const b = JsonParsedStakeConfigInfo(
        slashPenalty: 12,
        warmupCooldownRate: 0.25,
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('not equal when slashPenalty differs', () {
      const a = JsonParsedStakeConfigInfo(
        slashPenalty: 12,
        warmupCooldownRate: 0.25,
      );
      const b = JsonParsedStakeConfigInfo(
        slashPenalty: 5,
        warmupCooldownRate: 0.25,
      );
      expect(a, isNot(equals(b)));
    });

    test('deep equality flows up through JsonParsedStakeConfig', () {
      const a = JsonParsedStakeConfig(
        info: JsonParsedStakeConfigInfo(
          slashPenalty: 12,
          warmupCooldownRate: 0.25,
        ),
      );
      const b = JsonParsedStakeConfig(
        info: JsonParsedStakeConfigInfo(
          slashPenalty: 12,
          warmupCooldownRate: 0.25,
        ),
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });

  // ---------------------------------------------------------------------------
  // JsonParsedValidatorInfoKey
  // ---------------------------------------------------------------------------
  group('JsonParsedValidatorInfoKey equality', () {
    test('equal when all fields match', () {
      const a = JsonParsedValidatorInfoKey(pubkey: _addr1, signer: true);
      const b = JsonParsedValidatorInfoKey(pubkey: _addr1, signer: true);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('not equal when signer differs', () {
      const a = JsonParsedValidatorInfoKey(pubkey: _addr1, signer: true);
      const b = JsonParsedValidatorInfoKey(pubkey: _addr1, signer: false);
      expect(a, isNot(equals(b)));
    });
  });

  // ---------------------------------------------------------------------------
  // JsonParsedValidatorInfoData
  // ---------------------------------------------------------------------------
  group('JsonParsedValidatorInfoData equality', () {
    const key1 = JsonParsedValidatorInfoKey(pubkey: _addr1, signer: true);
    const key2 = JsonParsedValidatorInfoKey(pubkey: _addr2, signer: false);

    test('equal when all fields match', () {
      const a = JsonParsedValidatorInfoData(configData: 'cfg', keys: [key1]);
      const b = JsonParsedValidatorInfoData(configData: 'cfg', keys: [key1]);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('not equal when configData differs', () {
      const a = JsonParsedValidatorInfoData(configData: 'cfg1', keys: [key1]);
      const b = JsonParsedValidatorInfoData(configData: 'cfg2', keys: [key1]);
      expect(a, isNot(equals(b)));
    });

    test('not equal when keys list differs', () {
      const a = JsonParsedValidatorInfoData(configData: 'cfg', keys: [key1]);
      const b = JsonParsedValidatorInfoData(configData: 'cfg', keys: [key2]);
      expect(a, isNot(equals(b)));
    });
  });

  // ---------------------------------------------------------------------------
  // JsonParsedAddressLookupTableInfo
  // ---------------------------------------------------------------------------
  group('JsonParsedAddressLookupTableInfo equality', () {
    test('equal when all fields match', () {
      const a = JsonParsedAddressLookupTableInfo(
        addresses: [_addr1, _addr2],
        deactivationSlot: StringifiedBigInt('18446744073709551615'),
        lastExtendedSlot: StringifiedBigInt('100'),
        lastExtendedSlotStartIndex: 0,
        authority: _addr1,
      );
      const b = JsonParsedAddressLookupTableInfo(
        addresses: [_addr1, _addr2],
        deactivationSlot: StringifiedBigInt('18446744073709551615'),
        lastExtendedSlot: StringifiedBigInt('100'),
        lastExtendedSlotStartIndex: 0,
        authority: _addr1,
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('not equal when addresses list differs', () {
      const a = JsonParsedAddressLookupTableInfo(
        addresses: [_addr1],
        deactivationSlot: StringifiedBigInt('0'),
        lastExtendedSlot: StringifiedBigInt('0'),
        lastExtendedSlotStartIndex: 0,
      );
      const b = JsonParsedAddressLookupTableInfo(
        addresses: [_addr2],
        deactivationSlot: StringifiedBigInt('0'),
        lastExtendedSlot: StringifiedBigInt('0'),
        lastExtendedSlotStartIndex: 0,
      );
      expect(a, isNot(equals(b)));
    });

    test('not equal when authority differs', () {
      const a = JsonParsedAddressLookupTableInfo(
        addresses: [],
        deactivationSlot: StringifiedBigInt('0'),
        lastExtendedSlot: StringifiedBigInt('0'),
        lastExtendedSlotStartIndex: 0,
        authority: _addr1,
      );
      const b = JsonParsedAddressLookupTableInfo(
        addresses: [],
        deactivationSlot: StringifiedBigInt('0'),
        lastExtendedSlot: StringifiedBigInt('0'),
        lastExtendedSlotStartIndex: 0,
      );
      expect(a, isNot(equals(b)));
    });
  });

  // ---------------------------------------------------------------------------
  // Vote account info classes
  // ---------------------------------------------------------------------------
  group('JsonParsedAuthorizedVoter equality', () {
    test('equal when all fields match', () {
      final a = JsonParsedAuthorizedVoter(
        authorizedVoter: _addr1,
        epoch: BigInt.zero,
      );
      final b = JsonParsedAuthorizedVoter(
        authorizedVoter: _addr1,
        epoch: BigInt.zero,
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('not equal when epoch differs', () {
      final a = JsonParsedAuthorizedVoter(
        authorizedVoter: _addr1,
        epoch: BigInt.zero,
      );
      final b = JsonParsedAuthorizedVoter(
        authorizedVoter: _addr1,
        epoch: BigInt.one,
      );
      expect(a, isNot(equals(b)));
    });
  });

  group('JsonParsedEpochCredit equality', () {
    test('equal when all fields match', () {
      final a = JsonParsedEpochCredit(
        credits: const StringifiedBigInt('100'),
        epoch: BigInt.zero,
        previousCredits: const StringifiedBigInt('50'),
      );
      final b = JsonParsedEpochCredit(
        credits: const StringifiedBigInt('100'),
        epoch: BigInt.zero,
        previousCredits: const StringifiedBigInt('50'),
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });

  group('JsonParsedLastTimestamp equality', () {
    test('equal when all fields match', () {
      final a = JsonParsedLastTimestamp(
        slot: BigInt.zero,
        timestamp: UnixTimestamp(BigInt.from(1000)),
      );
      final b = JsonParsedLastTimestamp(
        slot: BigInt.zero,
        timestamp: UnixTimestamp(BigInt.from(1000)),
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('not equal when timestamp differs', () {
      final a = JsonParsedLastTimestamp(
        slot: BigInt.zero,
        timestamp: UnixTimestamp(BigInt.from(1000)),
      );
      final b = JsonParsedLastTimestamp(
        slot: BigInt.zero,
        timestamp: UnixTimestamp(BigInt.from(2000)),
      );
      expect(a, isNot(equals(b)));
    });
  });

  group('JsonParsedPriorVoter equality', () {
    test('equal when all fields match', () {
      final a = JsonParsedPriorVoter(
        authorizedPubkey: _addr1,
        epochOfLastAuthorizedSwitch: BigInt.zero,
        targetEpoch: BigInt.zero,
      );
      final b = JsonParsedPriorVoter(
        authorizedPubkey: _addr1,
        epochOfLastAuthorizedSwitch: BigInt.zero,
        targetEpoch: BigInt.zero,
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });

  group('JsonParsedVote equality', () {
    test('equal when all fields match', () {
      final a = JsonParsedVote(confirmationCount: 32, slot: BigInt.zero);
      final b = JsonParsedVote(confirmationCount: 32, slot: BigInt.zero);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('not equal when confirmationCount differs', () {
      final a = JsonParsedVote(confirmationCount: 32, slot: BigInt.zero);
      final b = JsonParsedVote(confirmationCount: 1, slot: BigInt.zero);
      expect(a, isNot(equals(b)));
    });
  });

  group('JsonParsedVoteInfo equality', () {
    test('equal when all list fields match', () {
      final ts = JsonParsedLastTimestamp(
        slot: BigInt.zero,
        timestamp: UnixTimestamp(BigInt.from(0)),
      );
      final a = JsonParsedVoteInfo(
        authorizedVoters: [
          JsonParsedAuthorizedVoter(
            authorizedVoter: _addr1,
            epoch: BigInt.zero,
          ),
        ],
        authorizedWithdrawer: _addr2,
        commission: 10,
        epochCredits: [
          JsonParsedEpochCredit(
            credits: const StringifiedBigInt('10'),
            epoch: BigInt.zero,
            previousCredits: const StringifiedBigInt('0'),
          ),
        ],
        lastTimestamp: ts,
        nodePubkey: _addr1,
        priorVoters: const [],
        votes: [JsonParsedVote(confirmationCount: 1, slot: BigInt.zero)],
      );
      final b = JsonParsedVoteInfo(
        authorizedVoters: [
          JsonParsedAuthorizedVoter(
            authorizedVoter: _addr1,
            epoch: BigInt.zero,
          ),
        ],
        authorizedWithdrawer: _addr2,
        commission: 10,
        epochCredits: [
          JsonParsedEpochCredit(
            credits: const StringifiedBigInt('10'),
            epoch: BigInt.zero,
            previousCredits: const StringifiedBigInt('0'),
          ),
        ],
        lastTimestamp: ts,
        nodePubkey: _addr1,
        priorVoters: const [],
        votes: [JsonParsedVote(confirmationCount: 1, slot: BigInt.zero)],
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });

  // ---------------------------------------------------------------------------
  // Token account info classes
  // ---------------------------------------------------------------------------
  group('JsonParsedMultisigInfo equality', () {
    test('equal when all fields match', () {
      const a = JsonParsedMultisigInfo(
        isInitialized: true,
        numRequiredSigners: 2,
        numValidSigners: 3,
        signers: [_addr1, _addr2],
      );
      const b = JsonParsedMultisigInfo(
        isInitialized: true,
        numRequiredSigners: 2,
        numValidSigners: 3,
        signers: [_addr1, _addr2],
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('not equal when signers list differs', () {
      const a = JsonParsedMultisigInfo(
        isInitialized: true,
        numRequiredSigners: 2,
        numValidSigners: 3,
        signers: [_addr1],
      );
      const b = JsonParsedMultisigInfo(
        isInitialized: true,
        numRequiredSigners: 2,
        numValidSigners: 3,
        signers: [_addr2],
      );
      expect(a, isNot(equals(b)));
    });
  });

  group('JsonParsedMintInfo equality', () {
    test('equal when all fields match (no extensions)', () {
      const a = JsonParsedMintInfo(
        decimals: 6,
        isInitialized: true,
        supply: StringifiedBigInt('1000000'),
        mintAuthority: _addr1,
      );
      const b = JsonParsedMintInfo(
        decimals: 6,
        isInitialized: true,
        supply: StringifiedBigInt('1000000'),
        mintAuthority: _addr1,
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('not equal when supply differs', () {
      const a = JsonParsedMintInfo(
        decimals: 6,
        isInitialized: true,
        supply: StringifiedBigInt('1000000'),
      );
      const b = JsonParsedMintInfo(
        decimals: 6,
        isInitialized: true,
        supply: StringifiedBigInt('2000000'),
      );
      expect(a, isNot(equals(b)));
    });

    test('deep equality flows up through JsonParsedMintAccount', () {
      const a = JsonParsedMintAccount(
        info: JsonParsedMintInfo(
          decimals: 9,
          isInitialized: true,
          supply: StringifiedBigInt('0'),
        ),
      );
      const b = JsonParsedMintAccount(
        info: JsonParsedMintInfo(
          decimals: 9,
          isInitialized: true,
          supply: StringifiedBigInt('0'),
        ),
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });

  // ---------------------------------------------------------------------------
  // Stake account info classes
  // ---------------------------------------------------------------------------
  group('JsonParsedStakeAuthorized equality', () {
    test('equal when all fields match', () {
      const a = JsonParsedStakeAuthorized(staker: _addr1, withdrawer: _addr2);
      const b = JsonParsedStakeAuthorized(staker: _addr1, withdrawer: _addr2);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('not equal when staker differs', () {
      const a = JsonParsedStakeAuthorized(staker: _addr1, withdrawer: _addr2);
      const b = JsonParsedStakeAuthorized(staker: _addr2, withdrawer: _addr2);
      expect(a, isNot(equals(b)));
    });
  });

  group('JsonParsedStakeLockup equality', () {
    test('equal when all fields match', () {
      final a = JsonParsedStakeLockup(
        custodian: _addr1,
        epoch: BigInt.zero,
        unixTimestamp: UnixTimestamp(BigInt.from(0)),
      );
      final b = JsonParsedStakeLockup(
        custodian: _addr1,
        epoch: BigInt.zero,
        unixTimestamp: UnixTimestamp(BigInt.from(0)),
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });

  group('JsonParsedStakeDelegation equality', () {
    test('equal when all fields match', () {
      const a = JsonParsedStakeDelegation(
        activationEpoch: StringifiedBigInt('0'),
        deactivationEpoch: StringifiedBigInt('18446744073709551615'),
        stake: StringifiedBigInt('1000000'),
        voter: _addr1,
        warmupCooldownRate: 0.25,
      );
      const b = JsonParsedStakeDelegation(
        activationEpoch: StringifiedBigInt('0'),
        deactivationEpoch: StringifiedBigInt('18446744073709551615'),
        stake: StringifiedBigInt('1000000'),
        voter: _addr1,
        warmupCooldownRate: 0.25,
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });

  // ---------------------------------------------------------------------------
  // Sysvar info classes
  // ---------------------------------------------------------------------------
  group('JsonParsedClockInfo equality', () {
    test('equal when all fields match', () {
      final a = JsonParsedClockInfo(
        epoch: BigInt.zero,
        epochStartTimestamp: UnixTimestamp(BigInt.from(0)),
        leaderScheduleEpoch: BigInt.one,
        slot: BigInt.zero,
        unixTimestamp: UnixTimestamp(BigInt.from(0)),
      );
      final b = JsonParsedClockInfo(
        epoch: BigInt.zero,
        epochStartTimestamp: UnixTimestamp(BigInt.from(0)),
        leaderScheduleEpoch: BigInt.one,
        slot: BigInt.zero,
        unixTimestamp: UnixTimestamp(BigInt.from(0)),
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('not equal when slot differs', () {
      final a = JsonParsedClockInfo(
        epoch: BigInt.zero,
        epochStartTimestamp: UnixTimestamp(BigInt.from(0)),
        leaderScheduleEpoch: BigInt.one,
        slot: BigInt.zero,
        unixTimestamp: UnixTimestamp(BigInt.from(0)),
      );
      final b = JsonParsedClockInfo(
        epoch: BigInt.zero,
        epochStartTimestamp: UnixTimestamp(BigInt.from(0)),
        leaderScheduleEpoch: BigInt.one,
        slot: BigInt.one,
        unixTimestamp: UnixTimestamp(BigInt.from(0)),
      );
      expect(a, isNot(equals(b)));
    });
  });

  group('JsonParsedFeeCalculator equality', () {
    test('equal when lamportsPerSignature matches', () {
      const a = JsonParsedFeeCalculator(
        lamportsPerSignature: StringifiedBigInt('5000'),
      );
      const b = JsonParsedFeeCalculator(
        lamportsPerSignature: StringifiedBigInt('5000'),
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('not equal when lamportsPerSignature differs', () {
      const a = JsonParsedFeeCalculator(
        lamportsPerSignature: StringifiedBigInt('5000'),
      );
      const b = JsonParsedFeeCalculator(
        lamportsPerSignature: StringifiedBigInt('10000'),
      );
      expect(a, isNot(equals(b)));
    });
  });

  group('JsonParsedRentInfo equality', () {
    test('equal when all fields match', () {
      const a = JsonParsedRentInfo(
        burnPercent: 50,
        exemptionThreshold: 2,
        lamportsPerByteYear: StringifiedBigInt('3480'),
      );
      const b = JsonParsedRentInfo(
        burnPercent: 50,
        exemptionThreshold: 2,
        lamportsPerByteYear: StringifiedBigInt('3480'),
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });

  group('JsonParsedSlotHistoryInfo equality', () {
    test('equal when all fields match', () {
      final a = JsonParsedSlotHistoryInfo(bits: '0101', nextSlot: BigInt.zero);
      final b = JsonParsedSlotHistoryInfo(bits: '0101', nextSlot: BigInt.zero);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });

  group('JsonParsedStakeHistoryData equality', () {
    test('equal when all fields match', () {
      final a = JsonParsedStakeHistoryData(
        activating: BigInt.from(100),
        deactivating: BigInt.zero,
        effective: BigInt.from(500),
      );
      final b = JsonParsedStakeHistoryData(
        activating: BigInt.from(100),
        deactivating: BigInt.zero,
        effective: BigInt.from(500),
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });

  group('JsonParsedLastRestartSlotInfo equality', () {
    test('equal when lastRestartSlot matches', () {
      final a = JsonParsedLastRestartSlotInfo(lastRestartSlot: BigInt.zero);
      final b = JsonParsedLastRestartSlotInfo(lastRestartSlot: BigInt.zero);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });

  group('JsonParsedEpochRewardsInfo equality', () {
    test('equal when all fields match', () {
      final a = JsonParsedEpochRewardsInfo(
        distributedRewards: BigInt.from(1000),
        distributionCompleteBlockHeight: BigInt.from(200),
        totalRewards: BigInt.from(5000),
      );
      final b = JsonParsedEpochRewardsInfo(
        distributedRewards: BigInt.from(1000),
        distributionCompleteBlockHeight: BigInt.from(200),
        totalRewards: BigInt.from(5000),
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });

  group('low-coverage parsed account branches', () {
    test(
      'stake account wrappers include nested values in equality and toString',
      () {
        const authorized = JsonParsedStakeAuthorized(
          staker: _addr1,
          withdrawer: _addr2,
        );
        final lockup = JsonParsedStakeLockup(
          custodian: _addr1,
          epoch: BigInt.one,
          unixTimestamp: UnixTimestamp(BigInt.from(2)),
        );
        const delegation = JsonParsedStakeDelegation(
          activationEpoch: StringifiedBigInt('1'),
          deactivationEpoch: StringifiedBigInt('2'),
          stake: StringifiedBigInt('3'),
          voter: _addr1,
          warmupCooldownRate: 0.5,
        );
        final account = JsonParsedStakeAccountInfo(
          meta: JsonParsedStakeMeta(
            authorized: authorized,
            lockup: lockup,
            rentExemptReserve: const StringifiedBigInt('4'),
          ),
          stake: JsonParsedStakeData(
            creditsObserved: BigInt.from(5),
            delegation: delegation,
          ),
        );

        expect(
          JsonParsedDelegatedStake(info: account),
          JsonParsedDelegatedStake(info: account),
        );
        expect(account.toString(), contains('rentExemptReserve: 4'));
        expect(authorized.toString(), contains('withdrawer'));
        expect(lockup.toString(), contains('custodian'));
      },
    );

    test(
      'token account list equality handles nulls and differing elements',
      () {
        const tokenAmount = TokenAmount(
          amount: StringifiedBigInt('1'),
          decimals: 6,
          uiAmountString: StringifiedNumber('0.000001'),
        );
        const a = JsonParsedTokenAccount(
          isNative: false,
          mint: _addr1,
          owner: _addr2,
          state: TokenAccountState.initialized,
          tokenAmount: tokenAmount,
          extensions: ['memo'],
        );
        const b = JsonParsedTokenAccount(
          isNative: false,
          mint: _addr1,
          owner: _addr2,
          state: TokenAccountState.initialized,
          tokenAmount: tokenAmount,
          extensions: ['memo'],
        );
        const c = JsonParsedTokenAccount(
          isNative: false,
          mint: _addr1,
          owner: _addr2,
          state: TokenAccountState.initialized,
          tokenAmount: tokenAmount,
        );
        const d = JsonParsedMintInfo(
          decimals: 6,
          isInitialized: true,
          supply: StringifiedBigInt('9'),
          extensions: ['memo'],
        );

        expect(a, b);
        expect(a.hashCode, b.hashCode);
        expect(a, isNot(c));
        expect(a.toString(), contains('extensions: [memo]'));
        expect(d.toString(), contains('extensions: [memo]'));
        expect(
          const JsonParsedTokenAccountVariant(info: a),
          const JsonParsedTokenAccountVariant(info: a),
        );
      },
    );

    test('sysvar parsed models preserve list-like value semantics', () {
      const recentBlockhash = JsonParsedRecentBlockhashEntry(
        blockhash: Blockhash('hash'),
        feeCalculator: JsonParsedFeeCalculator(
          lamportsPerSignature: StringifiedBigInt('5000'),
        ),
      );
      final stakeHistory = JsonParsedStakeHistoryEntry(
        epoch: BigInt.zero,
        stakeHistory: JsonParsedStakeHistoryData(
          activating: BigInt.one,
          deactivating: BigInt.from(2),
          effective: BigInt.from(3),
        ),
      );
      final a = JsonParsedSlotHistoryInfo(bits: '1010', nextSlot: BigInt.one);
      final b = JsonParsedSlotHistoryInfo(bits: '1010', nextSlot: BigInt.one);

      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a.toString(), contains('nextSlot: 1'));
      expect(recentBlockhash.toString(), contains('hash'));
      expect(stakeHistory.toString(), contains('effective: 3'));
      expect(
        const JsonParsedRecentBlockhashesSysvar(info: [recentBlockhash]),
        const JsonParsedRecentBlockhashesSysvar(info: [recentBlockhash]),
      );
    });
  });
}
