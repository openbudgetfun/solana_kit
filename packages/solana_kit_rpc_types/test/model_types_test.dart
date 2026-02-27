// This file validates deprecated model compatibility while migration is active.
// ignore_for_file: deprecated_member_use_from_same_package

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:test/test.dart';

const _addressA = Address('11111111111111111111111111111111');
const _addressB = Address('TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA');

void main() {
  group('Account filter models', () {
    test('DataSlice stores offset/length', () {
      const slice = DataSlice(offset: 12, length: 64);
      expect(slice.offset, 12);
      expect(slice.length, 64);
    });

    test('MemcmpFilterBase58 exposes encoding and fields', () {
      final filter = MemcmpFilterBase58(
        bytes: const Base58EncodedBytes('1111111111'),
        offset: BigInt.from(8),
      );
      expect(filter.bytes, const Base58EncodedBytes('1111111111'));
      expect(filter.offset, BigInt.from(8));
      expect(filter.encoding, 'base58');
    });

    test('MemcmpFilterBase64 exposes encoding and fields', () {
      final filter = MemcmpFilterBase64(
        bytes: const Base64EncodedBytes('AQIDBA=='),
        offset: BigInt.from(4),
      );
      expect(filter.bytes, const Base64EncodedBytes('AQIDBA=='));
      expect(filter.offset, BigInt.from(4));
      expect(filter.encoding, 'base64');
    });

    test('program account filters preserve payload objects', () {
      final memcmpFilter = GetProgramAccountsMemcmpFilter(
        memcmp: MemcmpFilterBase58(
          bytes: const Base58EncodedBytes('11111111'),
          offset: BigInt.zero,
        ),
      );
      final dataSizeFilter = GetProgramAccountsDatasizeFilter(
        dataSize: BigInt.from(165),
      );

      expect(memcmpFilter.memcmp, isA<MemcmpFilterBase58>());
      expect(dataSizeFilter.dataSize, BigInt.from(165));
    });
  });

  group('Account info models', () {
    test('AccountInfoBase stores common account fields', () {
      final accountInfo = AccountInfoBase(
        executable: true,
        lamports: lamports(BigInt.from(5000)),
        owner: _addressA,
        space: BigInt.from(128),
      );

      expect(accountInfo.executable, isTrue);
      expect(accountInfo.lamports, lamports(BigInt.from(5000)));
      expect(accountInfo.owner, _addressA);
      expect(accountInfo.space, BigInt.from(128));
    });

    test('deprecated base58 wrappers preserve encoded tuple data', () {
      const bytes = AccountInfoWithBase58Bytes(
        data: Base58EncodedBytes('1111111111'),
      );
      const encoded = AccountInfoWithBase58EncodedData(
        data: (Base58EncodedBytes('1111111111'), 'base58'),
      );

      expect(bytes.data, const Base58EncodedBytes('1111111111'));
      expect(encoded.data.$1, const Base58EncodedBytes('1111111111'));
      expect(encoded.data.$2, 'base58');
    });

    test('base64 wrappers preserve encoded tuple data', () {
      const base64 = AccountInfoWithBase64EncodedData(
        data: (Base64EncodedBytes('AQID'), 'base64'),
      );
      const zstd = AccountInfoWithBase64EncodedZStdCompressedData(
        data: (
          Base64EncodedZStdCompressedBytes('AQIDBA=='),
          'base64+zstd',
        ),
      );

      expect(base64.data.$1, const Base64EncodedBytes('AQID'));
      expect(base64.data.$2, 'base64');
      expect(
        zstd.data.$1,
        const Base64EncodedZStdCompressedBytes('AQIDBA=='),
      );
      expect(zstd.data.$2, 'base64+zstd');
    });

    test('json account data supports parsed and fallback variants', () {
      final parsed = ParsedAccountData(
        type: 'mint',
        program: 'spl-token',
        space: BigInt.from(82),
        info: {'decimals': 9},
      );
      final parsedVariant = AccountInfoJsonDataParsed(parsed: parsed);
      const fallbackVariant = AccountInfoJsonDataBase64(
        data: (Base64EncodedBytes('AQID'), 'base64'),
      );

      final parsedWrapper = AccountInfoWithJsonData(data: parsedVariant);
      const fallbackWrapper = AccountInfoWithJsonData(data: fallbackVariant);

      expect((parsedWrapper.data as AccountInfoJsonDataParsed).parsed, parsed);
      expect(
        (fallbackWrapper.data as AccountInfoJsonDataBase64).data.$1,
        const Base64EncodedBytes('AQID'),
      );
    });

    test('AccountInfoWithPubkey keeps generic account value and pubkey', () {
      final base = AccountInfoBase(
        executable: false,
        lamports: lamports(BigInt.from(1)),
        owner: _addressA,
        space: BigInt.from(0),
      );
      final wrapper = AccountInfoWithPubkey<AccountInfoBase>(
        account: base,
        pubkey: _addressB,
      );

      expect(wrapper.account, base);
      expect(wrapper.pubkey, _addressB);
    });
  });

  group('Primitive wrapper and response models', () {
    test('cluster URL wrappers preserve original values', () {
      final mainnetUrl = mainnet('https://api.mainnet-beta.solana.com');
      final devnetUrl = devnet('https://api.devnet.solana.com');
      final testnetUrl = testnet('https://api.testnet.solana.com');

      expect(mainnetUrl, 'https://api.mainnet-beta.solana.com');
      expect(devnetUrl, 'https://api.devnet.solana.com');
      expect(testnetUrl, 'https://api.testnet.solana.com');

      final ClusterUrl clusterUrl = mainnetUrl;
      expect(clusterUrl, 'https://api.mainnet-beta.solana.com');
    });

    test('encoded byte wrappers and tuple responses keep labels', () {
      const base58 = Base58EncodedBytes('11111111');
      const base64 = Base64EncodedBytes('AQID');
      const zstd = Base64EncodedZStdCompressedBytes('AQIDBA==');

      const base58Response = (base58, 'base58');
      const base64Response = (base64, 'base64');
      const zstdResponse = (zstd, 'base64+zstd');

      expect(base58Response.$1, base58);
      expect(base58Response.$2, 'base58');
      expect(base64Response.$1, base64);
      expect(base64Response.$2, 'base64');
      expect(zstdResponse.$1, zstd);
      expect(zstdResponse.$2, 'base64+zstd');
    });

    test('rpc response wrappers preserve context and value type', () {
      final response = SolanaRpcResponse<TokenAmount>(
        context: RpcResponseContext(slot: BigInt.from(12345)),
        value: const TokenAmount(
          amount: StringifiedBigInt('1000'),
          decimals: 6,
          uiAmountString: StringifiedNumber('0.001'),
        ),
      );

      expect(response.context.slot, BigInt.from(12345));
      expect(response.value.amount, const StringifiedBigInt('1000'));
      expect(response.value.uiAmountString, const StringifiedNumber('0.001'));
    });

    test('token amount and token balance retain all fields', () {
      const amount = TokenAmount(
        amount: StringifiedBigInt('4200'),
        decimals: 2,
        uiAmount: 42,
        uiAmountString: StringifiedNumber('42'),
      );
      const balance = TokenBalance(
        accountIndex: 3,
        mint: _addressB,
        owner: _addressA,
        programId: _addressB,
        uiTokenAmount: amount,
      );

      expect(amount.amount, const StringifiedBigInt('4200'));
      expect(amount.decimals, 2);
      expect(amount.uiAmount, 42.0);
      expect(amount.uiAmountString, const StringifiedNumber('42'));
      expect(balance.accountIndex, 3);
      expect(balance.mint, _addressB);
      expect(balance.owner, _addressA);
      expect(balance.programId, _addressB);
      expect(balance.uiTokenAmount, amount);
    });

    test('typed numeric aliases and wrappers preserve values', () {
      final slot = BigInt.from(50);
      final epoch = BigInt.from(7);
      final microLamports = MicroLamports(BigInt.from(2500));
      final signedLamports = -BigInt.from(5);
      const ratio = 1.5;

      expect(slot, BigInt.from(50));
      expect(epoch, BigInt.from(7));
      expect(microLamports.value, BigInt.from(2500));
      expect(signedLamports, -BigInt.from(5));
      expect(ratio, 1.5);
    });
  });
}
