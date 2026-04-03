// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: document_ignores

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:test/test.dart';

const _addr1 = Address('11111111111111111111111111111111');
const _addr2 = Address('TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA');

void main() {
  // ---------------------------------------------------------------------------
  // DataSlice
  // ---------------------------------------------------------------------------
  group('DataSlice equality', () {
    test('equal when offset and length match', () {
      const a = DataSlice(offset: 0, length: 32);
      const b = DataSlice(offset: 0, length: 32);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('not equal when offset differs', () {
      const a = DataSlice(offset: 0, length: 32);
      const b = DataSlice(offset: 4, length: 32);
      expect(a, isNot(equals(b)));
    });

    test('not equal when length differs', () {
      const a = DataSlice(offset: 0, length: 32);
      const b = DataSlice(offset: 0, length: 64);
      expect(a, isNot(equals(b)));
    });

    test('identical instance equals itself', () {
      const a = DataSlice(offset: 8, length: 16);
      expect(a, equals(a));
    });
  });

  // ---------------------------------------------------------------------------
  // MemcmpFilterBase58
  // ---------------------------------------------------------------------------
  group('MemcmpFilterBase58 equality', () {
    final a = MemcmpFilterBase58(
      bytes: const Base58EncodedBytes('111111'),
      offset: BigInt.from(0),
    );
    final b = MemcmpFilterBase58(
      bytes: const Base58EncodedBytes('111111'),
      offset: BigInt.from(0),
    );
    final c = MemcmpFilterBase58(
      bytes: const Base58EncodedBytes('222222'),
      offset: BigInt.from(0),
    );

    test('equal when bytes and offset match', () {
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('not equal when bytes differ', () {
      expect(a, isNot(equals(c)));
    });
  });

  // ---------------------------------------------------------------------------
  // MemcmpFilterBase64
  // ---------------------------------------------------------------------------
  group('MemcmpFilterBase64 equality', () {
    final a = MemcmpFilterBase64(
      bytes: const Base64EncodedBytes('AQID'),
      offset: BigInt.from(4),
    );
    final b = MemcmpFilterBase64(
      bytes: const Base64EncodedBytes('AQID'),
      offset: BigInt.from(4),
    );
    final c = MemcmpFilterBase64(
      bytes: const Base64EncodedBytes('AQID'),
      offset: BigInt.from(8),
    );

    test('equal when bytes and offset match', () {
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('not equal when offset differs', () {
      expect(a, isNot(equals(c)));
    });
  });

  // ---------------------------------------------------------------------------
  // GetProgramAccountsMemcmpFilter
  // ---------------------------------------------------------------------------
  group('GetProgramAccountsMemcmpFilter equality', () {
    final inner = MemcmpFilterBase58(
      bytes: const Base58EncodedBytes('abc'),
      offset: BigInt.zero,
    );
    final a = GetProgramAccountsMemcmpFilter(memcmp: inner);
    final b = GetProgramAccountsMemcmpFilter(memcmp: inner);

    test('equal when memcmp is the same object', () {
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });

  // ---------------------------------------------------------------------------
  // GetProgramAccountsDatasizeFilter
  // ---------------------------------------------------------------------------
  group('GetProgramAccountsDatasizeFilter equality', () {
    test('equal when dataSize matches', () {
      final a = GetProgramAccountsDatasizeFilter(dataSize: BigInt.from(165));
      final b = GetProgramAccountsDatasizeFilter(dataSize: BigInt.from(165));
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('not equal when dataSize differs', () {
      final a = GetProgramAccountsDatasizeFilter(dataSize: BigInt.from(165));
      final b = GetProgramAccountsDatasizeFilter(dataSize: BigInt.from(200));
      expect(a, isNot(equals(b)));
    });
  });

  // ---------------------------------------------------------------------------
  // AccountInfoBase
  // ---------------------------------------------------------------------------
  group('AccountInfoBase equality', () {
    test('equal when all fields match', () {
      final a = AccountInfoBase(
        executable: false,
        lamports: lamports(BigInt.from(5000)),
        owner: _addr1,
        space: BigInt.from(128),
      );
      final b = AccountInfoBase(
        executable: false,
        lamports: lamports(BigInt.from(5000)),
        owner: _addr1,
        space: BigInt.from(128),
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('not equal when executable differs', () {
      final a = AccountInfoBase(
        executable: true,
        lamports: lamports(BigInt.from(5000)),
        owner: _addr1,
        space: BigInt.from(128),
      );
      final b = AccountInfoBase(
        executable: false,
        lamports: lamports(BigInt.from(5000)),
        owner: _addr1,
        space: BigInt.from(128),
      );
      expect(a, isNot(equals(b)));
    });

    test('not equal when owner differs', () {
      final a = AccountInfoBase(
        executable: false,
        lamports: lamports(BigInt.from(1)),
        owner: _addr1,
        space: BigInt.zero,
      );
      final b = AccountInfoBase(
        executable: false,
        lamports: lamports(BigInt.from(1)),
        owner: _addr2,
        space: BigInt.zero,
      );
      expect(a, isNot(equals(b)));
    });
  });

  // ---------------------------------------------------------------------------
  // ParsedAccountData
  // ---------------------------------------------------------------------------
  group('ParsedAccountData equality', () {
    test('equal when all fields match', () {
      final a = ParsedAccountData(
        type: 'mint',
        program: 'spl-token',
        space: BigInt.from(82),
        info: const {'decimals': 9},
      );
      final b = ParsedAccountData(
        type: 'mint',
        program: 'spl-token',
        space: BigInt.from(82),
        info: const {'decimals': 9},
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('not equal when type differs', () {
      final a = ParsedAccountData(
        type: 'mint',
        program: 'spl-token',
        space: BigInt.from(82),
      );
      final b = ParsedAccountData(
        type: 'account',
        program: 'spl-token',
        space: BigInt.from(82),
      );
      expect(a, isNot(equals(b)));
    });
  });

  // ---------------------------------------------------------------------------
  // AccountInfoJsonData variants
  // ---------------------------------------------------------------------------
  group('AccountInfoJsonData variants equality', () {
    const data = (Base64EncodedBytes('AQID'), 'base64');

    test('AccountInfoJsonDataBase64 equals another with same data', () {
      const a = AccountInfoJsonDataBase64(data: data);
      const b = AccountInfoJsonDataBase64(data: data);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('AccountInfoJsonDataParsed equals another with same parsed data', () {
      final parsed = ParsedAccountData(
        type: 'mint',
        program: 'spl-token',
        space: BigInt.from(82),
      );
      final a = AccountInfoJsonDataParsed(parsed: parsed);
      final b = AccountInfoJsonDataParsed(parsed: parsed);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('AccountInfoJsonDataBase64 not equal to AccountInfoJsonDataParsed', () {
      const base64 = AccountInfoJsonDataBase64(data: data);
      final parsed = AccountInfoJsonDataParsed(
        parsed: ParsedAccountData(
          type: 'mint',
          program: 'spl-token',
          space: BigInt.zero,
        ),
      );
      expect(base64, isNot(equals(parsed)));
    });
  });

  // ---------------------------------------------------------------------------
  // AccountInfoWithPubkey
  // ---------------------------------------------------------------------------
  group('AccountInfoWithPubkey equality', () {
    test('equal when account and pubkey match', () {
      final base = AccountInfoBase(
        executable: false,
        lamports: lamports(BigInt.from(1)),
        owner: _addr1,
        space: BigInt.zero,
      );
      final a = AccountInfoWithPubkey<AccountInfoBase>(
        account: base,
        pubkey: _addr2,
      );
      final b = AccountInfoWithPubkey<AccountInfoBase>(
        account: base,
        pubkey: _addr2,
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('not equal when pubkey differs', () {
      final base = AccountInfoBase(
        executable: false,
        lamports: lamports(BigInt.from(1)),
        owner: _addr1,
        space: BigInt.zero,
      );
      final a = AccountInfoWithPubkey<AccountInfoBase>(
        account: base,
        pubkey: _addr1,
      );
      final b = AccountInfoWithPubkey<AccountInfoBase>(
        account: base,
        pubkey: _addr2,
      );
      expect(a, isNot(equals(b)));
    });
  });

  // ---------------------------------------------------------------------------
  // RpcResponseContext
  // ---------------------------------------------------------------------------
  group('RpcResponseContext equality', () {
    test('equal when slot matches', () {
      final a = RpcResponseContext(slot: BigInt.from(100));
      final b = RpcResponseContext(slot: BigInt.from(100));
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('not equal when slot differs', () {
      final a = RpcResponseContext(slot: BigInt.from(100));
      final b = RpcResponseContext(slot: BigInt.from(200));
      expect(a, isNot(equals(b)));
    });
  });

  // ---------------------------------------------------------------------------
  // SolanaRpcResponse
  // ---------------------------------------------------------------------------
  group('SolanaRpcResponse equality', () {
    test('equal when context and value match', () {
      final a = SolanaRpcResponse<int>(
        context: RpcResponseContext(slot: BigInt.from(50)),
        value: 42,
      );
      final b = SolanaRpcResponse<int>(
        context: RpcResponseContext(slot: BigInt.from(50)),
        value: 42,
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('not equal when value differs', () {
      final a = SolanaRpcResponse<int>(
        context: RpcResponseContext(slot: BigInt.from(50)),
        value: 42,
      );
      final b = SolanaRpcResponse<int>(
        context: RpcResponseContext(slot: BigInt.from(50)),
        value: 99,
      );
      expect(a, isNot(equals(b)));
    });
  });

  // ---------------------------------------------------------------------------
  // TokenAmount
  // ---------------------------------------------------------------------------
  group('TokenAmount equality', () {
    test('equal when all fields match', () {
      const a = TokenAmount(
        amount: StringifiedBigInt('1000'),
        decimals: 6,
        uiAmountString: StringifiedNumber('0.001'),
      );
      const b = TokenAmount(
        amount: StringifiedBigInt('1000'),
        decimals: 6,
        uiAmountString: StringifiedNumber('0.001'),
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('not equal when amount differs', () {
      const a = TokenAmount(
        amount: StringifiedBigInt('1000'),
        decimals: 6,
        uiAmountString: StringifiedNumber('0.001'),
      );
      const b = TokenAmount(
        amount: StringifiedBigInt('2000'),
        decimals: 6,
        uiAmountString: StringifiedNumber('0.002'),
      );
      expect(a, isNot(equals(b)));
    });

    test('not equal when decimals differs', () {
      const a = TokenAmount(
        amount: StringifiedBigInt('1000'),
        decimals: 6,
        uiAmountString: StringifiedNumber('0.001'),
      );
      const b = TokenAmount(
        amount: StringifiedBigInt('1000'),
        decimals: 9,
        uiAmountString: StringifiedNumber('0.001'),
      );
      expect(a, isNot(equals(b)));
    });
  });

  // ---------------------------------------------------------------------------
  // TokenBalance
  // ---------------------------------------------------------------------------
  group('TokenBalance equality', () {
    test('equal when all fields match', () {
      const amount = TokenAmount(
        amount: StringifiedBigInt('500'),
        decimals: 2,
        uiAmountString: StringifiedNumber('5'),
      );
      const a = TokenBalance(
        accountIndex: 0,
        mint: _addr1,
        uiTokenAmount: amount,
        owner: _addr2,
        programId: _addr1,
      );
      const b = TokenBalance(
        accountIndex: 0,
        mint: _addr1,
        uiTokenAmount: amount,
        owner: _addr2,
        programId: _addr1,
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('not equal when accountIndex differs', () {
      const amount = TokenAmount(
        amount: StringifiedBigInt('500'),
        decimals: 2,
        uiAmountString: StringifiedNumber('5'),
      );
      const a = TokenBalance(
        accountIndex: 0,
        mint: _addr1,
        uiTokenAmount: amount,
      );
      const b = TokenBalance(
        accountIndex: 1,
        mint: _addr1,
        uiTokenAmount: amount,
      );
      expect(a, isNot(equals(b)));
    });
  });

  // ---------------------------------------------------------------------------
  // InstructionError variants
  // ---------------------------------------------------------------------------
  group('InstructionError equality', () {
    test('InstructionErrorCustom equal when code matches', () {
      const a = InstructionErrorCustom(42);
      const b = InstructionErrorCustom(42);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('InstructionErrorCustom not equal when code differs', () {
      const a = InstructionErrorCustom(1);
      const b = InstructionErrorCustom(2);
      expect(a, isNot(equals(b)));
    });

    test('InstructionErrorSimple equal when label matches', () {
      const a = InstructionErrorSimple('GenericError');
      const b = InstructionErrorSimple('GenericError');
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('InstructionErrorSimple not equal when label differs', () {
      const a = InstructionErrorSimple('GenericError');
      const b = InstructionErrorSimple('InvalidArgument');
      expect(a, isNot(equals(b)));
    });

    test('InstructionErrorCustom not equal to InstructionErrorSimple', () {
      const custom = InstructionErrorCustom(0);
      const simple = InstructionErrorSimple('Custom');
      expect(custom, isNot(equals(simple)));
    });
  });

  // ---------------------------------------------------------------------------
  // TransactionError variants
  // ---------------------------------------------------------------------------
  group('TransactionError equality', () {
    test('TransactionErrorSimple equal when label matches', () {
      const a = TransactionErrorSimple('BlockhashNotFound');
      const b = TransactionErrorSimple('BlockhashNotFound');
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('TransactionErrorSimple not equal when label differs', () {
      const a = TransactionErrorSimple('BlockhashNotFound');
      const b = TransactionErrorSimple('SanitizeFailure');
      expect(a, isNot(equals(b)));
    });

    test('TransactionErrorDuplicateInstruction equal when index matches', () {
      const a = TransactionErrorDuplicateInstruction(3);
      const b = TransactionErrorDuplicateInstruction(3);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('TransactionErrorDuplicateInstruction not equal when index differs',
        () {
      const a = TransactionErrorDuplicateInstruction(1);
      const b = TransactionErrorDuplicateInstruction(2);
      expect(a, isNot(equals(b)));
    });

    test('TransactionErrorInstructionError equal when both fields match', () {
      const a = TransactionErrorInstructionError(
        1,
        InstructionErrorCustom(42),
      );
      const b = TransactionErrorInstructionError(
        1,
        InstructionErrorCustom(42),
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('TransactionErrorInstructionError not equal when error differs', () {
      const a = TransactionErrorInstructionError(
        1,
        InstructionErrorCustom(1),
      );
      const b = TransactionErrorInstructionError(
        1,
        InstructionErrorCustom(2),
      );
      expect(a, isNot(equals(b)));
    });

    test('TransactionErrorInsufficientFundsForRent equal when index matches',
        () {
      const a = TransactionErrorInsufficientFundsForRent(0);
      const b = TransactionErrorInsufficientFundsForRent(0);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test(
        'TransactionErrorProgramExecutionTemporarilyRestricted equal when '
        'index matches', () {
      const a = TransactionErrorProgramExecutionTemporarilyRestricted(2);
      const b = TransactionErrorProgramExecutionTemporarilyRestricted(2);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });

  // ---------------------------------------------------------------------------
  // TransactionVersion variants
  // ---------------------------------------------------------------------------
  group('TransactionVersion equality', () {
    test('two TransactionVersionLegacy instances are equal', () {
      const a = TransactionVersionLegacy();
      const b = TransactionVersionLegacy();
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('two TransactionVersionV0 instances are equal', () {
      const a = TransactionVersionV0();
      const b = TransactionVersionV0();
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('legacy not equal to v0', () {
      const a = TransactionVersionLegacy();
      const b = TransactionVersionV0();
      expect(a, isNot(equals(b)));
    });
  });

  // ---------------------------------------------------------------------------
  // AddressTableLookup (rpc_types)
  // ---------------------------------------------------------------------------
  group('AddressTableLookup (rpc_types) equality', () {
    test('equal when all fields match', () {
      const a = AddressTableLookup(
        accountKey: _addr1,
        readonlyIndexes: [0, 2],
        writableIndexes: [1, 3],
      );
      const b = AddressTableLookup(
        accountKey: _addr1,
        readonlyIndexes: [0, 2],
        writableIndexes: [1, 3],
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('not equal when readonlyIndexes differ', () {
      const a = AddressTableLookup(
        accountKey: _addr1,
        readonlyIndexes: [0],
        writableIndexes: [],
      );
      const b = AddressTableLookup(
        accountKey: _addr1,
        readonlyIndexes: [1],
        writableIndexes: [],
      );
      expect(a, isNot(equals(b)));
    });
  });

  // ---------------------------------------------------------------------------
  // RewardFeeOrRent
  // ---------------------------------------------------------------------------
  group('RewardFeeOrRent equality', () {
    test('equal when all fields match', () {
      final a = RewardFeeOrRent(
        rewardLamports: -BigInt.from(100),
        postBalance: lamports(BigInt.from(5000)),
        pubkey: _addr1,
        rewardType: 'rent',
      );
      final b = RewardFeeOrRent(
        rewardLamports: -BigInt.from(100),
        postBalance: lamports(BigInt.from(5000)),
        pubkey: _addr1,
        rewardType: 'rent',
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('not equal when rewardType differs', () {
      final a = RewardFeeOrRent(
        rewardLamports: BigInt.zero,
        postBalance: lamports(BigInt.zero),
        pubkey: _addr1,
        rewardType: 'fee',
      );
      final b = RewardFeeOrRent(
        rewardLamports: BigInt.zero,
        postBalance: lamports(BigInt.zero),
        pubkey: _addr1,
        rewardType: 'rent',
      );
      expect(a, isNot(equals(b)));
    });
  });

  // ---------------------------------------------------------------------------
  // RewardVotingOrStaking
  // ---------------------------------------------------------------------------
  group('RewardVotingOrStaking equality', () {
    test('equal when all fields match', () {
      final a = RewardVotingOrStaking(
        rewardLamports: BigInt.from(500),
        postBalance: lamports(BigInt.from(10000)),
        pubkey: _addr2,
        rewardType: 'voting',
        commission: 5,
      );
      final b = RewardVotingOrStaking(
        rewardLamports: BigInt.from(500),
        postBalance: lamports(BigInt.from(10000)),
        pubkey: _addr2,
        rewardType: 'voting',
        commission: 5,
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('not equal when commission differs', () {
      final a = RewardVotingOrStaking(
        rewardLamports: BigInt.zero,
        postBalance: lamports(BigInt.zero),
        pubkey: _addr1,
        rewardType: 'staking',
        commission: 5,
      );
      final b = RewardVotingOrStaking(
        rewardLamports: BigInt.zero,
        postBalance: lamports(BigInt.zero),
        pubkey: _addr1,
        rewardType: 'staking',
        commission: 10,
      );
      expect(a, isNot(equals(b)));
    });
  });

  // ---------------------------------------------------------------------------
  // ReturnData
  // ---------------------------------------------------------------------------
  group('ReturnData equality', () {
    test('equal when data and programId match', () {
      const a = ReturnData(
        data: (Base64EncodedBytes('AQID'), 'base64'),
        programId: _addr1,
      );
      const b = ReturnData(
        data: (Base64EncodedBytes('AQID'), 'base64'),
        programId: _addr1,
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('not equal when programId differs', () {
      const a = ReturnData(
        data: (Base64EncodedBytes('AQID'), 'base64'),
        programId: _addr1,
      );
      const b = ReturnData(
        data: (Base64EncodedBytes('AQID'), 'base64'),
        programId: _addr2,
      );
      expect(a, isNot(equals(b)));
    });
  });

  // ---------------------------------------------------------------------------
  // TransactionParsedAccount
  // ---------------------------------------------------------------------------
  group('TransactionParsedAccount equality', () {
    test('equal when all fields match', () {
      const a = TransactionParsedAccount(
        pubkey: _addr1,
        signer: true,
        writable: false,
        source: 'transaction',
      );
      const b = TransactionParsedAccount(
        pubkey: _addr1,
        signer: true,
        writable: false,
        source: 'transaction',
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('not equal when source differs', () {
      const a = TransactionParsedAccount(
        pubkey: _addr1,
        signer: false,
        writable: true,
        source: 'transaction',
      );
      const b = TransactionParsedAccount(
        pubkey: _addr1,
        signer: false,
        writable: true,
        source: 'lookupTable',
      );
      expect(a, isNot(equals(b)));
    });
  });

  // ---------------------------------------------------------------------------
  // toString coverage
  // ---------------------------------------------------------------------------
  group('toString coverage', () {
    test('DataSlice toString', () {
      const s = DataSlice(offset: 0, length: 32);
      expect(s.toString(), contains('DataSlice'));
    });

    test('MemcmpFilterBase58 toString', () {
      final f = MemcmpFilterBase58(bytes: const Base58EncodedBytes('AAAA'), offset: BigInt.zero);
      expect(f.toString(), contains('MemcmpFilter'));
    });

    test('GetProgramAccountsDatasizeFilter toString', () {
      final f = GetProgramAccountsDatasizeFilter(dataSize: BigInt.from(165));
      expect(f.toString(), contains('Datasize'));
    });

    test('MemcmpFilterBase64 toString', () {
      final f = MemcmpFilterBase64(bytes: const Base64EncodedBytes('AA'), offset: BigInt.zero);
      expect(f.toString(), contains('MemcmpFilter'));
    });

    test('AccountInfoBase toString', () {
      final a = AccountInfoBase(
        executable: false,
        lamports: Lamports(BigInt.one),
        owner: _addr1,
        space: BigInt.zero,
      );
      expect(a.toString(), contains('AccountInfoBase'));
    });

    test('GetProgramAccountsMemcmpFilter toString', () {
      final f = GetProgramAccountsMemcmpFilter(
        memcmp: MemcmpFilterBase58(bytes: const Base58EncodedBytes('AA'), offset: BigInt.zero),
      );
      expect(f.toString(), contains('Memcmp'));
    });

    test('RpcResponseContext toString', () {
      final c = RpcResponseContext(slot: BigInt.from(100));
      expect(c.toString(), contains('RpcResponseContext'));
    });

    test('SolanaRpcResponse toString', () {
      final r = SolanaRpcResponse(
        context: RpcResponseContext(slot: BigInt.from(1)),
        value: 42,
      );
      expect(r.toString(), contains('SolanaRpcResponse'));
    });

    test('TokenAmount toString', () {
      final t = TokenAmount(
        amount: const StringifiedBigInt('1000000'),
        decimals: 6,
        uiAmountString: StringifiedNumber('1.0'),
      );
      expect(t.toString(), contains('TokenAmount'));
    });

    test('TokenBalance toString', () {
      final t = TokenBalance(
        accountIndex: 0,
        mint: _addr1,
        uiTokenAmount: TokenAmount(
          amount: const StringifiedBigInt('0'),
          decimals: 6,
          uiAmountString: StringifiedNumber('0'),
        ),
      );
      expect(t.toString(), contains('TokenBalance'));
    });

    test('TransactionErrorSimple toString', () {
      const e = TransactionErrorSimple('AccountNotFound');
      expect(e.toString(), contains('AccountNotFound'));
    });

    test('TransactionErrorDuplicateInstruction toString', () {
      const e = TransactionErrorDuplicateInstruction(0);
      expect(e.toString(), contains('DuplicateInstruction'));
    });

    test('TransactionErrorInstructionError toString', () {
      const e = TransactionErrorInstructionError(
        0,
        InstructionErrorSimple('GenericError'),
      );
      expect(e.toString(), contains('InstructionError'));
    });

    test('InstructionErrorSimple toString', () {
      const e = InstructionErrorSimple('InvalidArgument');
      expect(e.toString(), contains('InvalidArgument'));
    });

    test('InstructionErrorCustom toString', () {
      const e = InstructionErrorCustom(42);
      expect(e.toString(), contains('42'));
    });

    test('TransactionErrorInsufficientFundsForRent toString', () {
      const e = TransactionErrorInsufficientFundsForRent(1);
      expect(e.toString(), contains('InsufficientFundsForRent'));
    });

    test('TransactionErrorProgramExecutionTemporarilyRestricted toString', () {
      const e = TransactionErrorProgramExecutionTemporarilyRestricted(2);
      expect(e.toString(), contains('ProgramExecutionTemporarilyRestricted'));
    });

    test('TransactionVersion toString', () {
      expect(const TransactionVersionLegacy().toString(), contains('legacy'));
      expect(const TransactionVersionV0().toString(), contains('0'));
    });

    test('AddressTableLookup toString', () {
      const a = AddressTableLookup(
        accountKey: _addr1,
        readonlyIndexes: [0],
        writableIndexes: [1],
      );
      expect(a.toString(), contains('AddressTableLookup'));
    });

    test('RewardFeeOrRent toString', () {
      final r = RewardFeeOrRent(
        rewardLamports: BigInt.from(5000),
        postBalance: Lamports(BigInt.from(1000000)),
        pubkey: _addr1,
        rewardType: 'fee',
      );
      expect(r.toString(), contains('RewardFeeOrRent'));
    });

    test('RewardVotingOrStaking toString', () {
      final r = RewardVotingOrStaking(
        commission: 10,
        rewardLamports: BigInt.from(5000),
        postBalance: Lamports(BigInt.from(1000000)),
        pubkey: _addr1,
        rewardType: 'voting',
      );
      expect(r.toString(), contains('RewardVotingOrStaking'));
    });

    test('ReturnData toString', () {
      const r = ReturnData(
        data: (Base64EncodedBytes('AAAA'), 'base64'),
        programId: _addr1,
      );
      expect(r.toString(), contains('ReturnData'));
    });

    test('TransactionParsedAccount toString', () {
      const a = TransactionParsedAccount(
        pubkey: _addr1,
        signer: true,
        writable: false,
        source: 'transaction',
      );
      expect(a.toString(), contains('TransactionParsedAccount'));
    });

    test('AccountInfoWithPubkey toString', () {
      final a = AccountInfoWithPubkey(
        account: AccountInfoBase(
          executable: false,
          lamports: Lamports(BigInt.one),
          owner: _addr1,
          space: BigInt.zero,
        ),
        pubkey: _addr1,
      );
      expect(a.toString(), contains('AccountInfoWithPubkey'));
    });
  });
}
