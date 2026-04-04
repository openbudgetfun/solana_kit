// Tests for generated SPL Token account codecs and types.

import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_token/solana_kit_token.dart';
import 'package:test/test.dart';

const _mint = Address('EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v');
const _owner = Address('11111111111111111111111111111111');
const _delegate = Address('22222222222222222222222222222222222222222222');
const _signer1 = Address('33333333333333333333333333333333333333333333');
const _signer2 = Address('44444444444444444444444444444444444444444444');

void main() {
  // ── Mint account codec ────────────────────────────────────────────────────
  group('Mint account', () {
    test('round-trip with no freeze authority', () {
      final mint = Mint(
        mintAuthority: _owner,
        supply: BigInt.from(500000000),
        decimals: 6,
        isInitialized: true,
        freezeAuthority: null,
      );
      final encoded = getMintEncoder().encode(mint);
      expect(encoded.length, mintSize);
      final decoded = getMintDecoder().decode(encoded);
      expect(decoded.mintAuthority, _owner);
      expect(decoded.supply, BigInt.from(500000000));
      expect(decoded.decimals, 6);
      expect(decoded.isInitialized, true);
      expect(decoded.freezeAuthority, isNull);
    });

    test('round-trip with freeze authority', () {
      final mint = Mint(
        mintAuthority: _owner,
        supply: BigInt.zero,
        decimals: 0,
        isInitialized: true,
        freezeAuthority: _delegate,
      );
      final encoded = getMintEncoder().encode(mint);
      final decoded = getMintDecoder().decode(encoded);
      expect(decoded.freezeAuthority, _delegate);
    });

    test('round-trip with no mint authority', () {
      final mint = Mint(
        mintAuthority: null,
        supply: BigInt.from(1000000000000),
        decimals: 9,
        isInitialized: true,
        freezeAuthority: null,
      );
      final encoded = getMintEncoder().encode(mint);
      final decoded = getMintDecoder().decode(encoded);
      expect(decoded.mintAuthority, isNull);
      expect(decoded.supply, BigInt.from(1000000000000));
    });

    test('getMintCodec round-trip', () {
      final mint = Mint(
        mintAuthority: _owner,
        supply: BigInt.from(42),
        decimals: 2,
        isInitialized: false,
        freezeAuthority: null,
      );
      final codec = getMintCodec();
      final decoded = codec.decode(codec.encode(mint));
      expect(decoded.decimals, 2);
      expect(decoded.isInitialized, false);
    });

    test('equality and hashCode', () {
      final a = Mint(
        mintAuthority: _owner,
        supply: BigInt.zero,
        decimals: 6,
        isInitialized: true,
        freezeAuthority: null,
      );
      final b = Mint(
        mintAuthority: _owner,
        supply: BigInt.zero,
        decimals: 6,
        isInitialized: true,
        freezeAuthority: null,
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('not equal when decimals differ', () {
      final a = Mint(
        mintAuthority: _owner,
        supply: BigInt.zero,
        decimals: 6,
        isInitialized: true,
        freezeAuthority: null,
      );
      final b = Mint(
        mintAuthority: _owner,
        supply: BigInt.zero,
        decimals: 9,
        isInitialized: true,
        freezeAuthority: null,
      );
      expect(a, isNot(equals(b)));
    });

    test('toString contains field values', () {
      final mint = Mint(
        mintAuthority: _owner,
        supply: BigInt.from(100),
        decimals: 6,
        isInitialized: true,
        freezeAuthority: null,
      );
      expect(mint.toString(), contains('decimals: 6'));
      expect(mint.toString(), contains('isInitialized: true'));
    });
  });

  // ── Token account codec ───────────────────────────────────────────────────
  group('Token account', () {
    test('round-trip initialized non-native account', () {
      final token = Token(
        mint: _mint,
        owner: _owner,
        amount: BigInt.from(100000),
        delegate: null,
        state: AccountState.initialized,
        isNative: null,
        delegatedAmount: BigInt.zero,
        closeAuthority: null,
      );
      final encoded = getTokenEncoder().encode(token);
      expect(encoded.length, tokenSize);
      final decoded = getTokenDecoder().decode(encoded);
      expect(decoded.mint, _mint);
      expect(decoded.owner, _owner);
      expect(decoded.amount, BigInt.from(100000));
      expect(decoded.delegate, isNull);
      expect(decoded.state, AccountState.initialized);
      expect(decoded.isNative, isNull);
      expect(decoded.delegatedAmount, BigInt.zero);
      expect(decoded.closeAuthority, isNull);
    });

    test('round-trip frozen account with delegate', () {
      final token = Token(
        mint: _mint,
        owner: _owner,
        amount: BigInt.from(500),
        delegate: _delegate,
        state: AccountState.frozen,
        isNative: null,
        delegatedAmount: BigInt.from(500),
        closeAuthority: _delegate,
      );
      final encoded = getTokenEncoder().encode(token);
      final decoded = getTokenDecoder().decode(encoded);
      expect(decoded.delegate, _delegate);
      expect(decoded.state, AccountState.frozen);
      expect(decoded.delegatedAmount, BigInt.from(500));
      expect(decoded.closeAuthority, _delegate);
    });

    test('round-trip native (wrapped SOL) account', () {
      const wsolMint = Address('So11111111111111111111111111111111111111112');
      final token = Token(
        mint: wsolMint,
        owner: _owner,
        amount: BigInt.from(1000000000),
        delegate: null,
        state: AccountState.initialized,
        isNative: BigInt.from(1000000000),
        delegatedAmount: BigInt.zero,
        closeAuthority: null,
      );
      final encoded = getTokenEncoder().encode(token);
      final decoded = getTokenDecoder().decode(encoded);
      expect(decoded.isNative, BigInt.from(1000000000));
    });

    test('uninitialized state round-trips', () {
      final token = Token(
        mint: _mint,
        owner: _owner,
        amount: BigInt.zero,
        delegate: null,
        state: AccountState.uninitialized,
        isNative: null,
        delegatedAmount: BigInt.zero,
        closeAuthority: null,
      );
      final encoded = getTokenEncoder().encode(token);
      final decoded = getTokenDecoder().decode(encoded);
      expect(decoded.state, AccountState.uninitialized);
    });

    test('getTokenCodec round-trip', () {
      final token = Token(
        mint: _mint,
        owner: _owner,
        amount: BigInt.from(1),
        delegate: null,
        state: AccountState.initialized,
        isNative: null,
        delegatedAmount: BigInt.zero,
        closeAuthority: null,
      );
      final codec = getTokenCodec();
      final decoded = codec.decode(codec.encode(token));
      expect(decoded.amount, BigInt.from(1));
    });
  });

  // ── Multisig account codec ────────────────────────────────────────────────
  group('Multisig account', () {
    // The signers field is a fixed-size array of 11 Address slots.
    // Unused slots must be padded with a zero address.
    const zero = Address('11111111111111111111111111111111');
    List<Address> padSigners(List<Address> signers) {
      return List<Address>.generate(
        11,
        (i) => i < signers.length ? signers[i] : zero,
      );
    }

    test('round-trip 2-of-3 multisig (11 signer slots)', () {
      final multisig = Multisig(
        m: 2,
        n: 3,
        isInitialized: true,
        signers: padSigners([_owner, _signer1, _signer2]),
      );
      final encoded = getMultisigEncoder().encode(multisig);
      expect(encoded.length, multisigSize);
      final decoded = getMultisigDecoder().decode(encoded);
      expect(decoded.m, 2);
      expect(decoded.n, 3);
      expect(decoded.isInitialized, true);
      expect(decoded.signers[0], _owner);
      expect(decoded.signers[1], _signer1);
      expect(decoded.signers[2], _signer2);
      expect(decoded.signers.length, 11);
    });

    test('round-trip 1-of-1 multisig (11 signer slots, 10 zero-padded)', () {
      final multisig = Multisig(
        m: 1,
        n: 1,
        isInitialized: true,
        signers: padSigners([_owner]),
      );
      final encoded = getMultisigEncoder().encode(multisig);
      final decoded = getMultisigDecoder().decode(encoded);
      expect(decoded.m, 1);
      expect(decoded.n, 1);
      expect(decoded.signers[0], _owner);
      expect(decoded.signers.length, 11);
    });

    test('getMultisigCodec round-trip', () {
      final multisig = Multisig(
        m: 2,
        n: 2,
        isInitialized: false,
        signers: padSigners([_signer1, _signer2]),
      );
      final codec = getMultisigCodec();
      final decoded = codec.decode(codec.encode(multisig));
      expect(decoded.isInitialized, false);
      expect(decoded.signers[0], _signer1);
    });
  });

  // ── AccountState enum codec ───────────────────────────────────────────────
  group('AccountState codec', () {
    test('encodes uninitialized as 0', () {
      final encoded = getAccountStateEncoder().encode(AccountState.uninitialized);
      expect(encoded[0], 0);
    });

    test('encodes initialized as 1', () {
      final encoded = getAccountStateEncoder().encode(AccountState.initialized);
      expect(encoded[0], 1);
    });

    test('encodes frozen as 2', () {
      final encoded = getAccountStateEncoder().encode(AccountState.frozen);
      expect(encoded[0], 2);
    });

    test('decodes 0 → uninitialized', () {
      final decoded = getAccountStateDecoder()
          .decode(Uint8List.fromList([0]));
      expect(decoded, AccountState.uninitialized);
    });

    test('decodes 1 → initialized', () {
      final decoded = getAccountStateDecoder()
          .decode(Uint8List.fromList([1]));
      expect(decoded, AccountState.initialized);
    });

    test('decodes 2 → frozen', () {
      final decoded = getAccountStateDecoder()
          .decode(Uint8List.fromList([2]));
      expect(decoded, AccountState.frozen);
    });

    test('codec round-trips all variants', () {
      for (final state in AccountState.values) {
        final encoded = getAccountStateEncoder().encode(state);
        final decoded = getAccountStateDecoder().decode(encoded);
        expect(decoded, state);
      }
    });

    test('getAccountStateCodec round-trips all variants', () {
      final codec = getAccountStateCodec();
      for (final state in AccountState.values) {
        expect(codec.decode(codec.encode(state)), state);
      }
    });
  });

  // ── AuthorityType enum codec ──────────────────────────────────────────────
  group('AuthorityType codec', () {
    test('encodes mintTokens as 0', () {
      expect(getAuthorityTypeEncoder().encode(AuthorityType.mintTokens)[0], 0);
    });

    test('encodes freezeAccount as 1', () {
      expect(getAuthorityTypeEncoder().encode(AuthorityType.freezeAccount)[0], 1);
    });

    test('encodes accountOwner as 2', () {
      expect(getAuthorityTypeEncoder().encode(AuthorityType.accountOwner)[0], 2);
    });

    test('encodes closeAccount as 3', () {
      expect(getAuthorityTypeEncoder().encode(AuthorityType.closeAccount)[0], 3);
    });

    test('codec round-trips all variants', () {
      for (final type in AuthorityType.values) {
        final encoded = getAuthorityTypeEncoder().encode(type);
        final decoded = getAuthorityTypeDecoder().decode(encoded);
        expect(decoded, type);
      }
    });

    test('getAuthorityTypeCodec round-trips all variants', () {
      final codec = getAuthorityTypeCodec();
      for (final type in AuthorityType.values) {
        expect(codec.decode(codec.encode(type)), type);
      }
    });
  });
}
