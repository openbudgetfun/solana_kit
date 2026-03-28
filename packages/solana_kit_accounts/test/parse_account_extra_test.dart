import 'dart:typed_data';

import 'package:solana_kit_accounts/solana_kit_accounts.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:test/test.dart';

const _addr = Address('GQE2yjns7SKKuMc89tveBDpzYHwXfeuB2PGAbGaPWc6G');
const _owner = '11111111111111111111111111111111';

void main() {
  // ---------------------------------------------------------------------------
  // parseBaseAccount – edge cases
  // ---------------------------------------------------------------------------
  group('parseBaseAccount extra edge cases', () {
    test('parses lamports and space provided as strings', () {
      final rpcAccount = <String, dynamic>{
        'executable': false,
        'lamports': '999999',
        'owner': _owner,
        'space': '128',
      };

      final base = parseBaseAccount(rpcAccount);

      expect(base.lamports, Lamports(BigInt.from(999999)));
      expect(base.space, BigInt.from(128));
      expect(base.executable, isFalse);
      expect(base.programAddress, const Address(_owner));
    });

    test('parses executable=true', () {
      final rpcAccount = <String, dynamic>{
        'executable': true,
        'lamports': 1,
        'owner': _owner,
        'space': 0,
      };

      final base = parseBaseAccount(rpcAccount);
      expect(base.executable, isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // parseBase64RpcAccount – extra cases
  // ---------------------------------------------------------------------------
  group('parseBase64RpcAccount extra cases', () {
    test('parses when data is a plain string (not a list)', () {
      // Some RPC nodes return data as a plain base64 string.
      final rpcAccount = <String, dynamic>{
        'data': 'AAEC', // base64 for [0, 1, 2]
        'executable': false,
        'lamports': 1000,
        'owner': _owner,
        'space': 3,
      };

      final result = parseBase64RpcAccount(_addr, rpcAccount);

      expect(result.exists, isTrue);
      final existing = result as ExistingAccount<Uint8List>;
      expect(existing.data, equals(Uint8List.fromList([0, 1, 2])));
    });

    test('parsed account has correct metadata from rpc map', () {
      final rpcAccount = <String, dynamic>{
        'data': ['', 'base64'],
        'executable': true,
        'lamports': BigInt.from(5000000),
        'owner': _owner,
        'space': 0,
      };

      final result = parseBase64RpcAccount(_addr, rpcAccount);
      expect(result.exists, isTrue);
      final existing = result as ExistingAccount<Uint8List>;
      expect(existing.executable, isTrue);
      expect(existing.lamports, Lamports(BigInt.from(5000000)));
      expect(existing.address, _addr);
    });
  });

  // ---------------------------------------------------------------------------
  // parseBase58RpcAccount – extra cases
  // ---------------------------------------------------------------------------
  group('parseBase58RpcAccount extra cases', () {
    test('parses when data is neither String nor List (toString fallback)', () {
      // An unusual value – toString() should be called on it.
      final rpcAccount = <String, dynamic>{
        'data': 11111, // integer value → toString() → '11111' in base58
        'executable': false,
        'lamports': 1000,
        'owner': _owner,
        'space': 0,
      };

      // Should not throw; the data is treated as base58-encoded string '11111'
      expect(() => parseBase58RpcAccount(_addr, rpcAccount), returnsNormally);
    });
  });

  // ---------------------------------------------------------------------------
  // ParsedAccountMeta toString and equality
  // ---------------------------------------------------------------------------
  group('ParsedAccountMeta toString and equality', () {
    test('toString includes program and type', () {
      const meta = ParsedAccountMeta(program: 'splToken', type: 'token');
      final str = meta.toString();
      expect(str, contains('splToken'));
      expect(str, contains('token'));
      expect(str, contains('ParsedAccountMeta'));
    });

    test('toString works when type is null', () {
      const meta = ParsedAccountMeta(program: 'splToken');
      final str = meta.toString();
      expect(str, contains('splToken'));
      expect(str, contains('null'));
    });

    test('two equal metas are equal', () {
      const a = ParsedAccountMeta(program: 'p', type: 't');
      const b = ParsedAccountMeta(program: 'p', type: 't');
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('not equal when program differs', () {
      const a = ParsedAccountMeta(program: 'a', type: 't');
      const b = ParsedAccountMeta(program: 'b', type: 't');
      expect(a, isNot(equals(b)));
    });

    test('not equal when type differs', () {
      const a = ParsedAccountMeta(program: 'p', type: 'a');
      const b = ParsedAccountMeta(program: 'p', type: 'b');
      expect(a, isNot(equals(b)));
    });

    test('not equal when type is null vs non-null', () {
      const a = ParsedAccountMeta(program: 'p');
      const b = ParsedAccountMeta(program: 'p', type: 't');
      expect(a, isNot(equals(b)));
    });
  });

  // ---------------------------------------------------------------------------
  // JsonParsedAccountData toString and equality
  // ---------------------------------------------------------------------------
  group('JsonParsedAccountData toString and equality', () {
    test('toString includes data and parsedAccountMeta', () {
      const jpad = JsonParsedAccountData<String>(
        data: 'my-data',
        parsedAccountMeta: ParsedAccountMeta(program: 'prog'),
      );
      final str = jpad.toString();
      expect(str, contains('my-data'));
      expect(str, contains('JsonParsedAccountData'));
    });

    test('toString works when parsedAccountMeta is null', () {
      const jpad = JsonParsedAccountData<String>(data: 'my-data');
      final str = jpad.toString();
      expect(str, contains('my-data'));
      expect(str, contains('null'));
    });

    test('two equal instances are equal', () {
      const a = JsonParsedAccountData<String>(
        data: 'x',
        parsedAccountMeta: ParsedAccountMeta(program: 'p'),
      );
      const b = JsonParsedAccountData<String>(
        data: 'x',
        parsedAccountMeta: ParsedAccountMeta(program: 'p'),
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('not equal when data differs', () {
      const a = JsonParsedAccountData<String>(data: 'a');
      const b = JsonParsedAccountData<String>(data: 'b');
      expect(a, isNot(equals(b)));
    });

    test('not equal when parsedAccountMeta differs', () {
      const a = JsonParsedAccountData<String>(
        data: 'x',
        parsedAccountMeta: ParsedAccountMeta(program: 'a'),
      );
      const b = JsonParsedAccountData<String>(
        data: 'x',
        parsedAccountMeta: ParsedAccountMeta(program: 'b'),
      );
      expect(a, isNot(equals(b)));
    });
  });

  // ---------------------------------------------------------------------------
  // parseJsonRpcAccount – extra cases
  // ---------------------------------------------------------------------------
  group('parseJsonRpcAccount extra cases', () {
    test('parses when only program is present (no type)', () {
      final rpcAccount = <String, dynamic>{
        'data': <String, dynamic>{
          'parsed': <String, dynamic>{
            'info': <String, dynamic>{'amount': '100'},
          },
          'program': 'splToken',
          'space': 165,
        },
        'executable': false,
        'lamports': 1000000000,
        'owner': _owner,
        'space': 165,
      };

      final result = parseJsonRpcAccount(_addr, rpcAccount);
      expect(result.exists, isTrue);
      final existing =
          result
              as ExistingAccount<JsonParsedAccountData<Map<String, dynamic>>>;
      expect(existing.data.parsedAccountMeta, isNotNull);
      expect(existing.data.parsedAccountMeta!.program, 'splToken');
      expect(existing.data.parsedAccountMeta!.type, isNull);
    });
  });
}
