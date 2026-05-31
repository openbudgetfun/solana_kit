// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: document_ignores

import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:test/test.dart';

const _addr1 = Address('11111111111111111111111111111111');
const _addr2 = Address('TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA');

void main() {
  // ---------------------------------------------------------------------------
  // account_info.dart coverage
  // ---------------------------------------------------------------------------
  group('AccountInfoWithBase58Bytes equality', () {
    test('equal when data matches', () {
      const a = AccountInfoWithBase58Bytes(data: Base58EncodedBytes('abc'));
      const b = AccountInfoWithBase58Bytes(data: Base58EncodedBytes('abc'));
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('not equal when data differs', () {
      const a = AccountInfoWithBase58Bytes(data: Base58EncodedBytes('abc'));
      const b = AccountInfoWithBase58Bytes(data: Base58EncodedBytes('xyz'));
      expect(a, isNot(equals(b)));
    });

    test('not equal to different type', () {
      const a = AccountInfoWithBase58Bytes(data: Base58EncodedBytes('abc'));
      expect(a, isNot(equals('not a AccountInfoWithBase58Bytes')));
    });

    test('identical instance equals itself', () {
      const a = AccountInfoWithBase58Bytes(data: Base58EncodedBytes('abc'));
      expect(a, equals(a));
    });

    test('toString', () {
      const a = AccountInfoWithBase58Bytes(data: Base58EncodedBytes('abc'));
      expect(a.toString(), contains('AccountInfoWithBase58Bytes'));
    });
  });

  group('AccountInfoWithBase58EncodedData equality', () {
    test('equal when data matches', () {
      const a = AccountInfoWithBase58EncodedData(
        data: (Base58EncodedBytes('abc'), 'base58'),
      );
      const b = AccountInfoWithBase58EncodedData(
        data: (Base58EncodedBytes('abc'), 'base58'),
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('not equal when data differs', () {
      const a = AccountInfoWithBase58EncodedData(
        data: (Base58EncodedBytes('abc'), 'base58'),
      );
      const b = AccountInfoWithBase58EncodedData(
        data: (Base58EncodedBytes('xyz'), 'base58'),
      );
      expect(a, isNot(equals(b)));
    });

    test('not equal to different type', () {
      const a = AccountInfoWithBase58EncodedData(
        data: (Base58EncodedBytes('abc'), 'base58'),
      );
      expect(a, isNot(equals('other')));
    });

    test('identical instance equals itself', () {
      const a = AccountInfoWithBase58EncodedData(
        data: (Base58EncodedBytes('abc'), 'base58'),
      );
      expect(a, equals(a));
    });

    test('toString', () {
      const a = AccountInfoWithBase58EncodedData(
        data: (Base58EncodedBytes('abc'), 'base58'),
      );
      expect(a.toString(), contains('AccountInfoWithBase58EncodedData'));
    });
  });

  group('AccountInfoWithBase64EncodedData equality', () {
    test('equal when data matches', () {
      const a = AccountInfoWithBase64EncodedData(
        data: (Base64EncodedBytes('abc'), 'base64'),
      );
      const b = AccountInfoWithBase64EncodedData(
        data: (Base64EncodedBytes('abc'), 'base64'),
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('not equal when data differs', () {
      const a = AccountInfoWithBase64EncodedData(
        data: (Base64EncodedBytes('abc'), 'base64'),
      );
      const b = AccountInfoWithBase64EncodedData(
        data: (Base64EncodedBytes('xyz'), 'base64'),
      );
      expect(a, isNot(equals(b)));
    });

    test('not equal to different type', () {
      const a = AccountInfoWithBase64EncodedData(
        data: (Base64EncodedBytes('abc'), 'base64'),
      );
      expect(a, isNot(equals('other')));
    });

    test('identical instance equals itself', () {
      const a = AccountInfoWithBase64EncodedData(
        data: (Base64EncodedBytes('abc'), 'base64'),
      );
      expect(a, equals(a));
    });

    test('toString', () {
      const a = AccountInfoWithBase64EncodedData(
        data: (Base64EncodedBytes('abc'), 'base64'),
      );
      expect(a.toString(), contains('AccountInfoWithBase64EncodedData'));
    });
  });

  group('AccountInfoWithBase64EncodedZStdCompressedData equality', () {
    test('equal when data matches', () {
      const a = AccountInfoWithBase64EncodedZStdCompressedData(
        data: (Base64EncodedZStdCompressedBytes('abc'), 'base64+zstd'),
      );
      const b = AccountInfoWithBase64EncodedZStdCompressedData(
        data: (Base64EncodedZStdCompressedBytes('abc'), 'base64+zstd'),
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('not equal when data differs', () {
      const a = AccountInfoWithBase64EncodedZStdCompressedData(
        data: (Base64EncodedZStdCompressedBytes('abc'), 'base64+zstd'),
      );
      const b = AccountInfoWithBase64EncodedZStdCompressedData(
        data: (Base64EncodedZStdCompressedBytes('xyz'), 'base64+zstd'),
      );
      expect(a, isNot(equals(b)));
    });

    test('not equal to different type', () {
      const a = AccountInfoWithBase64EncodedZStdCompressedData(
        data: (Base64EncodedZStdCompressedBytes('abc'), 'base64+zstd'),
      );
      expect(a, isNot(equals('other')));
    });

    test('identical instance equals itself', () {
      const a = AccountInfoWithBase64EncodedZStdCompressedData(
        data: (Base64EncodedZStdCompressedBytes('abc'), 'base64+zstd'),
      );
      expect(a, equals(a));
    });

    test('toString', () {
      const a = AccountInfoWithBase64EncodedZStdCompressedData(
        data: (Base64EncodedZStdCompressedBytes('abc'), 'base64+zstd'),
      );
      expect(
        a.toString(),
        contains('AccountInfoWithBase64EncodedZStdCompressedData'),
      );
    });
  });

  group('AccountInfoJsonDataParsed equality', () {
    final parsed = ParsedAccountData(
      type: 'account',
      program: 'system',
      space: BigInt.from(100),
    );

    test('equal when parsed matches', () {
      final a = AccountInfoJsonDataParsed(parsed: parsed);
      final b = AccountInfoJsonDataParsed(parsed: parsed);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('not equal when parsed differs', () {
      final a = AccountInfoJsonDataParsed(parsed: parsed);
      final other = ParsedAccountData(
        type: 'other',
        program: 'token',
        space: BigInt.from(200),
      );
      final b = AccountInfoJsonDataParsed(parsed: other);
      expect(a, isNot(equals(b)));
    });

    test('not equal to different type', () {
      final a = AccountInfoJsonDataParsed(parsed: parsed);
      expect(a, isNot(equals('other')));
    });

    test('identical instance equals itself', () {
      final a = AccountInfoJsonDataParsed(parsed: parsed);
      expect(a, equals(a));
    });

    test('toString', () {
      final a = AccountInfoJsonDataParsed(parsed: parsed);
      expect(a.toString(), contains('AccountInfoJsonDataParsed'));
    });
  });

  group('AccountInfoJsonDataBase64 equality', () {
    test('equal when data matches', () {
      const a = AccountInfoJsonDataBase64(
        data: (Base64EncodedBytes('abc'), 'base64'),
      );
      const b = AccountInfoJsonDataBase64(
        data: (Base64EncodedBytes('abc'), 'base64'),
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('not equal when data differs', () {
      const a = AccountInfoJsonDataBase64(
        data: (Base64EncodedBytes('abc'), 'base64'),
      );
      const b = AccountInfoJsonDataBase64(
        data: (Base64EncodedBytes('xyz'), 'base64'),
      );
      expect(a, isNot(equals(b)));
    });

    test('not equal to different type', () {
      const a = AccountInfoJsonDataBase64(
        data: (Base64EncodedBytes('abc'), 'base64'),
      );
      expect(a, isNot(equals('other')));
    });

    test('identical instance equals itself', () {
      const a = AccountInfoJsonDataBase64(
        data: (Base64EncodedBytes('abc'), 'base64'),
      );
      expect(a, equals(a));
    });

    test('toString', () {
      const a = AccountInfoJsonDataBase64(
        data: (Base64EncodedBytes('abc'), 'base64'),
      );
      expect(a.toString(), contains('AccountInfoJsonDataBase64'));
    });
  });

  group('AccountInfoWithJsonData equality', () {
    test('equal when data matches', () {
      final data = AccountInfoJsonDataParsed(
        parsed: ParsedAccountData(
          type: 'account',
          program: 'system',
          space: BigInt.from(100),
        ),
      );
      final a = AccountInfoWithJsonData(data: data);
      final b = AccountInfoWithJsonData(data: data);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('not equal when data differs', () {
      final data1 = AccountInfoJsonDataParsed(
        parsed: ParsedAccountData(
          type: 'account',
          program: 'system',
          space: BigInt.from(100),
        ),
      );
      const data2 = AccountInfoJsonDataBase64(
        data: (Base64EncodedBytes('abc'), 'base64'),
      );
      final a = AccountInfoWithJsonData(data: data1);
      const b = AccountInfoWithJsonData(data: data2);
      expect(a, isNot(equals(b)));
    });

    test('not equal to different type', () {
      const data = AccountInfoJsonDataBase64(
        data: (Base64EncodedBytes('abc'), 'base64'),
      );
      const a = AccountInfoWithJsonData(data: data);
      expect(a, isNot(equals('other')));
    });

    test('identical instance equals itself', () {
      const data = AccountInfoJsonDataBase64(
        data: (Base64EncodedBytes('abc'), 'base64'),
      );
      const a = AccountInfoWithJsonData(data: data);
      expect(a, equals(a));
    });

    test('toString', () {
      const data = AccountInfoJsonDataBase64(
        data: (Base64EncodedBytes('abc'), 'base64'),
      );
      const a = AccountInfoWithJsonData(data: data);
      expect(a.toString(), contains('AccountInfoWithJsonData'));
    });
  });

  // ---------------------------------------------------------------------------
  // blockhash.dart coverage (line 111, 131)
  // ---------------------------------------------------------------------------
  group('blockhash comparator', () {
    test('compares equal strings returns 0', () {
      final comparator = getBlockhashComparator();
      expect(comparator('abc', 'abc'), 0);
    });

    test('handles different lengths', () {
      final comparator = getBlockhashComparator();
      expect(comparator('ab', 'abc'), lessThan(0));
      expect(comparator('abc', 'ab'), greaterThan(0));
    });

    test('handles fallback for non-alphanumeric characters', () {
      // Line 131: fallback for non-alphanumeric characters
      final comparator = getBlockhashComparator();
      // Use chars that hit the fallback path
      expect(comparator('@', 'A'), isNot(equals(0)));
    });
  });

  // ---------------------------------------------------------------------------
  // commitment.dart coverage (line 23)
  // ---------------------------------------------------------------------------
  group('getCommitmentComparator()', () {
    test('returns a comparator that works', () {
      final comparator = getCommitmentComparator();
      expect(comparator(Commitment.processed, Commitment.finalized), -1);
      expect(comparator(Commitment.finalized, Commitment.processed), 1);
      expect(comparator(Commitment.confirmed, Commitment.confirmed), 0);
    });
  });

  // ---------------------------------------------------------------------------
  // encoding.dart coverage (lines 16-18, 37, 49)
  // ---------------------------------------------------------------------------
  group('AccountEncoding.toJson()', () {
    test('base64Zstd returns "base64+zstd"', () {
      expect(AccountEncoding.base64Zstd.toJson(), 'base64+zstd');
    });

    test('base58 returns "base58"', () {
      expect(AccountEncoding.base58.toJson(), 'base58');
    });

    test('base64 returns "base64"', () {
      expect(AccountEncoding.base64.toJson(), 'base64');
    });

    test('jsonParsed returns "jsonParsed"', () {
      expect(AccountEncoding.jsonParsed.toJson(), 'jsonParsed');
    });
  });

  group('TransactionEncoding.toJson()', () {
    test('base58 returns "base58"', () {
      expect(TransactionEncoding.base58.toJson(), 'base58');
    });

    test('base64 returns "base64"', () {
      expect(TransactionEncoding.base64.toJson(), 'base64');
    });

    test('json returns "json"', () {
      expect(TransactionEncoding.json.toJson(), 'json');
    });

    test('jsonParsed returns "jsonParsed"', () {
      expect(TransactionEncoding.jsonParsed.toJson(), 'jsonParsed');
    });
  });

  group('WireTransactionEncoding.toJson()', () {
    test('base58 returns "base58"', () {
      expect(WireTransactionEncoding.base58.toJson(), 'base58');
    });

    test('base64 returns "base64"', () {
      expect(WireTransactionEncoding.base64.toJson(), 'base64');
    });
  });

  // ---------------------------------------------------------------------------
  // token_amount.dart coverage (lines 47-48)
  // ---------------------------------------------------------------------------
  group('TokenAmount equality', () {
    test(
      'equal when all fields match including uiAmount and uiAmountString',
      () {
        const a = TokenAmount(
          amount: StringifiedBigInt('100'),
          decimals: 2,
          uiAmountString: StringifiedNumber('1'),
          uiAmount: 1,
        );
        const b = TokenAmount(
          amount: StringifiedBigInt('100'),
          decimals: 2,
          uiAmountString: StringifiedNumber('1'),
          uiAmount: 1,
        );
        expect(a, equals(b));
      },
    );

    test('not equal when uiAmount differs', () {
      const a = TokenAmount(
        amount: StringifiedBigInt('100'),
        decimals: 2,
        uiAmountString: StringifiedNumber('1'),
        uiAmount: 1,
      );
      const b = TokenAmount(
        amount: StringifiedBigInt('100'),
        decimals: 2,
        uiAmountString: StringifiedNumber('1'),
        uiAmount: 2,
      );
      expect(a, isNot(equals(b)));
    });

    test('not equal when uiAmountString differs', () {
      const a = TokenAmount(
        amount: StringifiedBigInt('100'),
        decimals: 2,
        uiAmountString: StringifiedNumber('1'),
        uiAmount: 1,
      );
      const b = TokenAmount(
        amount: StringifiedBigInt('100'),
        decimals: 2,
        uiAmountString: StringifiedNumber('2'),
        uiAmount: 1,
      );
      expect(a, isNot(equals(b)));
    });
  });

  // ---------------------------------------------------------------------------
  // token_balance.dart coverage (lines 38-41)
  // ---------------------------------------------------------------------------
  group('TokenBalance equality', () {
    const tokenAmount = TokenAmount(
      amount: StringifiedBigInt('100'),
      decimals: 2,
      uiAmountString: StringifiedNumber('1'),
    );

    test('equal when all fields match', () {
      const a = TokenBalance(
        accountIndex: 1,
        mint: _addr1,
        owner: _addr2,
        programId: _addr2,
        uiTokenAmount: tokenAmount,
      );
      const b = TokenBalance(
        accountIndex: 1,
        mint: _addr1,
        owner: _addr2,
        programId: _addr2,
        uiTokenAmount: tokenAmount,
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('not equal when owner differs', () {
      const a = TokenBalance(
        accountIndex: 1,
        mint: _addr1,
        owner: _addr1,
        programId: _addr2,
        uiTokenAmount: tokenAmount,
      );
      const b = TokenBalance(
        accountIndex: 1,
        mint: _addr1,
        owner: _addr2,
        programId: _addr2,
        uiTokenAmount: tokenAmount,
      );
      expect(a, isNot(equals(b)));
    });

    test('not equal when programId differs', () {
      const a = TokenBalance(
        accountIndex: 1,
        mint: _addr1,
        owner: _addr2,
        programId: _addr1,
        uiTokenAmount: tokenAmount,
      );
      const b = TokenBalance(
        accountIndex: 1,
        mint: _addr1,
        owner: _addr2,
        programId: _addr2,
        uiTokenAmount: tokenAmount,
      );
      expect(a, isNot(equals(b)));
    });

    test('not equal when uiTokenAmount differs', () {
      const otherAmount = TokenAmount(
        amount: StringifiedBigInt('999'),
        decimals: 6,
        uiAmountString: StringifiedNumber('0.000999'),
      );
      const a = TokenBalance(
        accountIndex: 1,
        mint: _addr1,
        uiTokenAmount: tokenAmount,
      );
      const b = TokenBalance(
        accountIndex: 1,
        mint: _addr1,
        uiTokenAmount: otherAmount,
      );
      expect(a, isNot(equals(b)));
    });
  });

  // ---------------------------------------------------------------------------
  // transaction_error.dart coverage (lines 229-231, 258-260)
  // ---------------------------------------------------------------------------
  group('TransactionErrorInsufficientFundsForRent equality', () {
    test('equal when accountIndex matches', () {
      const a = TransactionErrorInsufficientFundsForRent(3);
      const b = TransactionErrorInsufficientFundsForRent(3);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('not equal when accountIndex differs', () {
      const a = TransactionErrorInsufficientFundsForRent(3);
      const b = TransactionErrorInsufficientFundsForRent(5);
      expect(a, isNot(equals(b)));
    });

    test('not equal to different type', () {
      const a = TransactionErrorInsufficientFundsForRent(3);
      expect(a, isNot(equals('other')));
    });

    test('identical instance equals itself', () {
      const a = TransactionErrorInsufficientFundsForRent(3);
      expect(a, equals(a));
    });

    test('toString', () {
      const a = TransactionErrorInsufficientFundsForRent(3);
      expect(
        a.toString(),
        contains('TransactionErrorInsufficientFundsForRent'),
      );
      expect(a.toString(), contains('3'));
    });
  });

  group('TransactionErrorProgramExecutionTemporarilyRestricted equality', () {
    test('equal when accountIndex matches', () {
      const a = TransactionErrorProgramExecutionTemporarilyRestricted(7);
      const b = TransactionErrorProgramExecutionTemporarilyRestricted(7);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('not equal when accountIndex differs', () {
      const a = TransactionErrorProgramExecutionTemporarilyRestricted(7);
      const b = TransactionErrorProgramExecutionTemporarilyRestricted(9);
      expect(a, isNot(equals(b)));
    });

    test('not equal to different type', () {
      const a = TransactionErrorProgramExecutionTemporarilyRestricted(7);
      expect(a, isNot(equals('other')));
    });

    test('identical instance equals itself', () {
      const a = TransactionErrorProgramExecutionTemporarilyRestricted(7);
      expect(a, equals(a));
    });

    test('toString', () {
      const a = TransactionErrorProgramExecutionTemporarilyRestricted(7);
      expect(
        a.toString(),
        contains('TransactionErrorProgramExecutionTemporarilyRestricted'),
      );
      expect(a.toString(), contains('7'));
    });
  });

  // ---------------------------------------------------------------------------
  // transaction_types.dart coverage
  // ---------------------------------------------------------------------------
  group('TransactionVersionLegacy equality', () {
    test('equal instances', () {
      const a = TransactionVersionLegacy();
      const b = TransactionVersionLegacy();
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('not equal to V0', () {
      const a = TransactionVersionLegacy();
      const b = TransactionVersionV0();
      expect(a, isNot(equals(b)));
    });

    test('not equal to arbitrary object', () {
      const a = TransactionVersionLegacy();
      expect(a, isNot(equals('other')));
    });
  });

  group('TransactionVersionV0 equality', () {
    test('equal instances', () {
      const a = TransactionVersionV0();
      const b = TransactionVersionV0();
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('not equal to Legacy', () {
      const a = TransactionVersionV0();
      const b = TransactionVersionLegacy();
      expect(a, isNot(equals(b)));
    });

    test('not equal to arbitrary object', () {
      const a = TransactionVersionV0();
      expect(a, isNot(equals('other')));
    });
  });

  group('AddressTableLookup equality', () {
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
        readonlyIndexes: [0, 2],
        writableIndexes: [1, 3],
      );
      const b = AddressTableLookup(
        accountKey: _addr1,
        readonlyIndexes: [0, 4],
        writableIndexes: [1, 3],
      );
      expect(a, isNot(equals(b)));
    });

    test('not equal when writableIndexes differ', () {
      const a = AddressTableLookup(
        accountKey: _addr1,
        readonlyIndexes: [0, 2],
        writableIndexes: [1, 3],
      );
      const b = AddressTableLookup(
        accountKey: _addr1,
        readonlyIndexes: [0, 2],
        writableIndexes: [1, 4],
      );
      expect(a, isNot(equals(b)));
    });

    test('not equal to different type', () {
      const a = AddressTableLookup(
        accountKey: _addr1,
        readonlyIndexes: [0],
        writableIndexes: [1],
      );
      expect(a, isNot(equals('other')));
    });

    test('identical instance equals itself', () {
      const a = AddressTableLookup(
        accountKey: _addr1,
        readonlyIndexes: [0],
        writableIndexes: [1],
      );
      expect(a, equals(a));
    });

    test('toString', () {
      const a = AddressTableLookup(
        accountKey: _addr1,
        readonlyIndexes: [0],
        writableIndexes: [1],
      );
      expect(a.toString(), contains('AddressTableLookup'));
    });
  });

  group('TransactionStatusOk equality', () {
    test('equal instances', () {
      const a = TransactionStatusOk();
      const b = TransactionStatusOk();
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('not equal to different type', () {
      const a = TransactionStatusOk();
      const err = TransactionStatusErr(TransactionErrorSimple('test'));
      expect(a, isNot(equals(err)));
    });
  });

  group('TransactionStatusErr equality', () {
    test('equal when error matches', () {
      const err = TransactionErrorSimple('test');
      const a = TransactionStatusErr(err);
      const b = TransactionStatusErr(err);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('not equal when error differs', () {
      const a = TransactionStatusErr(TransactionErrorSimple('test1'));
      const b = TransactionStatusErr(TransactionErrorSimple('test2'));
      expect(a, isNot(equals(b)));
    });

    test('not equal to different type', () {
      const a = TransactionStatusErr(TransactionErrorSimple('test'));
      expect(a, isNot(equals(const TransactionStatusOk())));
    });
  });

  group('TransactionForAccountsMetaBase equality', () {
    const tokenAmount = TokenAmount(
      amount: StringifiedBigInt('100'),
      decimals: 2,
      uiAmountString: StringifiedNumber('1'),
    );
    const tokenBalance = TokenBalance(
      accountIndex: 1,
      mint: _addr1,
      uiTokenAmount: tokenAmount,
    );

    test('equal when all fields match', () {
      final a = TransactionForAccountsMetaBase(
        err: null,
        fee: lamports(BigInt.from(5000)),
        postBalances: [lamports(BigInt.from(1000))],
        preBalances: [lamports(BigInt.from(2000))],
        postTokenBalances: const [tokenBalance],
        preTokenBalances: const [tokenBalance],
      );
      final b = TransactionForAccountsMetaBase(
        err: null,
        fee: lamports(BigInt.from(5000)),
        postBalances: [lamports(BigInt.from(1000))],
        preBalances: [lamports(BigInt.from(2000))],
        postTokenBalances: const [tokenBalance],
        preTokenBalances: const [tokenBalance],
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('not equal when err differs', () {
      final a = TransactionForAccountsMetaBase(
        err: null,
        fee: lamports(BigInt.from(5000)),
        postBalances: [lamports(BigInt.from(1000))],
        preBalances: [lamports(BigInt.from(2000))],
      );
      final b = TransactionForAccountsMetaBase(
        err: const TransactionErrorSimple('test'),
        fee: lamports(BigInt.from(5000)),
        postBalances: [lamports(BigInt.from(1000))],
        preBalances: [lamports(BigInt.from(2000))],
      );
      expect(a, isNot(equals(b)));
    });

    test('not equal when fee differs', () {
      final a = TransactionForAccountsMetaBase(
        err: null,
        fee: lamports(BigInt.from(5000)),
        postBalances: [lamports(BigInt.from(1000))],
        preBalances: [lamports(BigInt.from(2000))],
      );
      final b = TransactionForAccountsMetaBase(
        err: null,
        fee: lamports(BigInt.from(9999)),
        postBalances: [lamports(BigInt.from(1000))],
        preBalances: [lamports(BigInt.from(2000))],
      );
      expect(a, isNot(equals(b)));
    });

    test('not equal when postBalances differs', () {
      final a = TransactionForAccountsMetaBase(
        err: null,
        fee: lamports(BigInt.from(5000)),
        postBalances: [lamports(BigInt.from(1000))],
        preBalances: [lamports(BigInt.from(2000))],
      );
      final b = TransactionForAccountsMetaBase(
        err: null,
        fee: lamports(BigInt.from(5000)),
        postBalances: [lamports(BigInt.from(9999))],
        preBalances: [lamports(BigInt.from(2000))],
      );
      expect(a, isNot(equals(b)));
    });

    test('not equal when postTokenBalances differs', () {
      final a = TransactionForAccountsMetaBase(
        err: null,
        fee: lamports(BigInt.from(5000)),
        postBalances: [lamports(BigInt.from(1000))],
        preBalances: [lamports(BigInt.from(2000))],
        postTokenBalances: const [tokenBalance],
      );
      final b = TransactionForAccountsMetaBase(
        err: null,
        fee: lamports(BigInt.from(5000)),
        postBalances: [lamports(BigInt.from(1000))],
        preBalances: [lamports(BigInt.from(2000))],
      );
      expect(a, isNot(equals(b)));
    });

    test('not equal when preBalances differs', () {
      final a = TransactionForAccountsMetaBase(
        err: null,
        fee: lamports(BigInt.from(5000)),
        postBalances: [lamports(BigInt.from(1000))],
        preBalances: [lamports(BigInt.from(2000))],
      );
      final b = TransactionForAccountsMetaBase(
        err: null,
        fee: lamports(BigInt.from(5000)),
        postBalances: [lamports(BigInt.from(1000))],
        preBalances: [lamports(BigInt.from(9999))],
      );
      expect(a, isNot(equals(b)));
    });

    test('not equal when preTokenBalances differs', () {
      final a = TransactionForAccountsMetaBase(
        err: null,
        fee: lamports(BigInt.from(5000)),
        postBalances: [lamports(BigInt.from(1000))],
        preBalances: [lamports(BigInt.from(2000))],
        preTokenBalances: const [tokenBalance],
      );
      final b = TransactionForAccountsMetaBase(
        err: null,
        fee: lamports(BigInt.from(5000)),
        postBalances: [lamports(BigInt.from(1000))],
        preBalances: [lamports(BigInt.from(2000))],
      );
      expect(a, isNot(equals(b)));
    });

    test('not equal to different type', () {
      final a = TransactionForAccountsMetaBase(
        err: null,
        fee: lamports(BigInt.from(5000)),
        postBalances: [lamports(BigInt.from(1000))],
        preBalances: [lamports(BigInt.from(2000))],
      );
      expect(a, isNot(equals('other')));
    });

    test('identical instance equals itself', () {
      final a = TransactionForAccountsMetaBase(
        err: null,
        fee: lamports(BigInt.from(5000)),
        postBalances: [lamports(BigInt.from(1000))],
        preBalances: [lamports(BigInt.from(2000))],
      );
      expect(a, equals(a));
    });

    test('toString', () {
      final a = TransactionForAccountsMetaBase(
        err: null,
        fee: lamports(BigInt.from(5000)),
        postBalances: [lamports(BigInt.from(1000))],
        preBalances: [lamports(BigInt.from(2000))],
      );
      expect(a.toString(), contains('TransactionForAccountsMetaBase'));
    });
  });

  group('ReturnData equality', () {
    test('equal when all fields match', () {
      const a = ReturnData(
        data: (Base64EncodedBytes('abc'), 'base64'),
        programId: _addr1,
      );
      const b = ReturnData(
        data: (Base64EncodedBytes('abc'), 'base64'),
        programId: _addr1,
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('not equal when data differs', () {
      const a = ReturnData(
        data: (Base64EncodedBytes('abc'), 'base64'),
        programId: _addr1,
      );
      const b = ReturnData(
        data: (Base64EncodedBytes('xyz'), 'base64'),
        programId: _addr1,
      );
      expect(a, isNot(equals(b)));
    });

    test('not equal when programId differs', () {
      const a = ReturnData(
        data: (Base64EncodedBytes('abc'), 'base64'),
        programId: _addr1,
      );
      const b = ReturnData(
        data: (Base64EncodedBytes('abc'), 'base64'),
        programId: _addr2,
      );
      expect(a, isNot(equals(b)));
    });

    test('not equal to different type', () {
      const a = ReturnData(
        data: (Base64EncodedBytes('abc'), 'base64'),
        programId: _addr1,
      );
      expect(a, isNot(equals('other')));
    });

    test('identical instance equals itself', () {
      const a = ReturnData(
        data: (Base64EncodedBytes('abc'), 'base64'),
        programId: _addr1,
      );
      expect(a, equals(a));
    });

    test('toString', () {
      const a = ReturnData(
        data: (Base64EncodedBytes('abc'), 'base64'),
        programId: _addr1,
      );
      expect(a.toString(), contains('ReturnData'));
    });
  });

  group('TransactionParsedAccount equality', () {
    test('equal when all fields match', () {
      const a = TransactionParsedAccount(
        pubkey: _addr1,
        signer: true,
        writable: true,
        source: 'transaction',
      );
      const b = TransactionParsedAccount(
        pubkey: _addr1,
        signer: true,
        writable: true,
        source: 'transaction',
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('not equal when pubkey differs', () {
      const a = TransactionParsedAccount(
        pubkey: _addr1,
        signer: true,
        writable: true,
        source: 'transaction',
      );
      const b = TransactionParsedAccount(
        pubkey: _addr2,
        signer: true,
        writable: true,
        source: 'transaction',
      );
      expect(a, isNot(equals(b)));
    });

    test('not equal when signer differs', () {
      const a = TransactionParsedAccount(
        pubkey: _addr1,
        signer: true,
        writable: true,
        source: 'transaction',
      );
      const b = TransactionParsedAccount(
        pubkey: _addr1,
        signer: false,
        writable: true,
        source: 'transaction',
      );
      expect(a, isNot(equals(b)));
    });

    test('not equal when writable differs', () {
      const a = TransactionParsedAccount(
        pubkey: _addr1,
        signer: true,
        writable: true,
        source: 'transaction',
      );
      const b = TransactionParsedAccount(
        pubkey: _addr1,
        signer: true,
        writable: false,
        source: 'transaction',
      );
      expect(a, isNot(equals(b)));
    });

    test('not equal when source differs', () {
      const a = TransactionParsedAccount(
        pubkey: _addr1,
        signer: true,
        writable: true,
        source: 'transaction',
      );
      const b = TransactionParsedAccount(
        pubkey: _addr1,
        signer: true,
        writable: true,
        source: 'lookupTable',
      );
      expect(a, isNot(equals(b)));
    });

    test('not equal to different type', () {
      const a = TransactionParsedAccount(
        pubkey: _addr1,
        signer: true,
        writable: true,
        source: 'transaction',
      );
      expect(a, isNot(equals('other')));
    });

    test('identical instance equals itself', () {
      const a = TransactionParsedAccount(
        pubkey: _addr1,
        signer: true,
        writable: true,
        source: 'transaction',
      );
      expect(a, equals(a));
    });

    test('toString', () {
      const a = TransactionParsedAccount(
        pubkey: _addr1,
        signer: true,
        writable: true,
        source: 'transaction',
      );
      expect(a.toString(), contains('TransactionParsedAccount'));
    });
  });

  // ---------------------------------------------------------------------------
  // lamports.dart coverage (lines 169-178 - VariableSizeCodec path)
  // ---------------------------------------------------------------------------
  group('getLamportsEncoder with int encoder', () {
    test('encodes Lamports using int encoder', () {
      // This exercises the _lamportsEncoderForNum path
      final encoder = getLamportsEncoder(getU8Encoder());
      final bytes = Uint8List(1);
      encoder.write(lamports(BigInt.from(42)), bytes, 0);
      expect(bytes[0], 42);
    });
  });

  group('getLamportsDecoder with int decoder', () {
    test('decodes Lamports using int decoder', () {
      final decoder = getLamportsDecoder(getU8Decoder());
      final bytes = Uint8List.fromList([42]);
      final (value, _) = decoder.read(bytes, 0);
      expect(value, lamports(BigInt.from(42)));
    });
  });

  group('getLamportsCodec with int codec', () {
    test('encodes and decodes Lamports using int codec', () {
      final codec = getLamportsCodec(getU8Codec());
      final bytes = Uint8List(1);
      codec.write(lamports(BigInt.from(42)), bytes, 0);
      final (value, _) = codec.read(bytes, 0);
      expect(value, lamports(BigInt.from(42)));
    });
  });

  // ---------------------------------------------------------------------------
  // VariableSizeCodec path for BigInt (lamports.dart lines 169-178)
  // ---------------------------------------------------------------------------
  group('getLamportsCodec with VariableSizeCodec<BigInt,BigInt>', () {
    test('encodes and decodes using variable-size BigInt codec', () {
      // Create a VariableSizeCodec<BigInt, BigInt> directly
      final variableSizeBigIntCodec = VariableSizeCodec<BigInt, BigInt>(
        getSizeFromValue: (value) => 8,
        write: (value, bytes, offset) {
          final u64 = getU64Encoder();
          return u64.write(value, bytes, offset);
        },
        read: (bytes, offset) {
          final u64 = getU64Decoder();
          return u64.read(bytes, offset);
        },
        maxSize: 8,
      );

      final codec = getLamportsCodec(variableSizeBigIntCodec);
      final testValue = lamports(BigInt.from(12345));
      final buffer = codec.encode(testValue);
      expect(buffer, isNotEmpty);
      final decoded = codec.decode(buffer);
      expect(decoded, testValue);
    });
  });

  group('getLamportsEncoder with VariableSizeEncoder<num>', () {
    test('encodes using variable-size num encoder', () {
      // getShortU16Encoder returns VariableSizeEncoder<num>
      // This exercises the VariableSizeEncoder<num> branch
      final encoder =
          getLamportsEncoder(getShortU16Encoder())
              as VariableSizeEncoder<Lamports>;
      final lamportsValue = lamports(BigInt.from(300));
      final buffer = encoder.encode(lamportsValue);
      expect(buffer, isNotEmpty);
      expect(encoder.getSizeFromValue(lamportsValue), greaterThan(0));
    });
  });

  group('getLamportsDecoder with VariableSizeDecoder<int>', () {
    test('decodes using variable-size int decoder', () {
      // getShortU16Decoder returns VariableSizeDecoder<int>
      // This exercises the VariableSizeDecoder<int> branch
      final decoder =
          getLamportsDecoder(getShortU16Decoder())
              as VariableSizeDecoder<Lamports>;
      // Encode 300 using shortU16: [172, 2]
      final buffer = Uint8List.fromList([172, 2]);
      final (value, _) = decoder.read(buffer, 0);
      expect(value, lamports(BigInt.from(300)));
    });
  });

  // ---------------------------------------------------------------------------
  // _nullableListEquals path (transaction_types.dart line 413)
  // ---------------------------------------------------------------------------
  group('_nullableListEquals via TransactionForAccountsMetaBase', () {
    test('equal when both token balance lists are non-null and equal', () {
      const tokenAmount = TokenAmount(
        amount: StringifiedBigInt('100'),
        decimals: 2,
        uiAmountString: StringifiedNumber('1'),
      );
      const tokenBalance = TokenBalance(
        accountIndex: 1,
        mint: _addr1,
        uiTokenAmount: tokenAmount,
      );

      final a = TransactionForAccountsMetaBase(
        err: null,
        fee: lamports(BigInt.from(5000)),
        postBalances: [lamports(BigInt.from(1000))],
        preBalances: [lamports(BigInt.from(2000))],
        postTokenBalances: const [tokenBalance],
        preTokenBalances: const [tokenBalance],
      );
      final b = TransactionForAccountsMetaBase(
        err: null,
        fee: lamports(BigInt.from(5000)),
        postBalances: [lamports(BigInt.from(1000))],
        preBalances: [lamports(BigInt.from(2000))],
        postTokenBalances: const [tokenBalance],
        preTokenBalances: const [tokenBalance],
      );
      expect(a, equals(b));
    });

    test('not equal when both token balance lists are non-null but differ', () {
      const tokenAmount = TokenAmount(
        amount: StringifiedBigInt('100'),
        decimals: 2,
        uiAmountString: StringifiedNumber('1'),
      );
      const tokenBalance1 = TokenBalance(
        accountIndex: 1,
        mint: _addr1,
        uiTokenAmount: tokenAmount,
      );
      const tokenBalance2 = TokenBalance(
        accountIndex: 2,
        mint: _addr2,
        uiTokenAmount: tokenAmount,
      );

      final a = TransactionForAccountsMetaBase(
        err: null,
        fee: lamports(BigInt.from(5000)),
        postBalances: [lamports(BigInt.from(1000))],
        preBalances: [lamports(BigInt.from(2000))],
        postTokenBalances: const [tokenBalance1],
        preTokenBalances: const [tokenBalance1],
      );
      final b = TransactionForAccountsMetaBase(
        err: null,
        fee: lamports(BigInt.from(5000)),
        postBalances: [lamports(BigInt.from(1000))],
        preBalances: [lamports(BigInt.from(2000))],
        postTokenBalances: const [tokenBalance2],
        preTokenBalances: const [tokenBalance2],
      );
      expect(a, isNot(equals(b)));
    });
  });
}
