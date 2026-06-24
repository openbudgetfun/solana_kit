import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_surfpool/solana_kit_surfpool.dart';
import 'package:test/test.dart';

void main() {
  group('cheatcode builders', () {
    const account = Address('11111111111111111111111111111111');
    const owner = Address('BPFLoaderUpgradeab1e11111111111111111111111');
    const mint = Address('EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v');

    test('SetAccount serializes optional fields and copies data', () {
      final data = Uint8List.fromList(<int>[0, 1, 2, 255]);
      final builder = SetAccount(account)
          .withLamports(500)
          .withData(data)
          .withOwner(owner)
          .withRentEpoch(0)
          .withExecutable(executable: false);

      data[0] = 9;
      final exposedData = builder.data!;
      exposedData[1] = 9;

      expect(builder.data, <int>[0, 1, 2, 255]);
      expect(builder.method, 'surfnet_setAccount');
      expect(builder.params, <Object?>[
        account.value,
        <String, Object?>{
          'lamports': 500,
          'data': '000102ff',
          'owner': owner.value,
          'rentEpoch': 0,
          'executable': false,
        },
      ]);
    });

    test(
      'SetTokenAccount clears delegate and close authority with string null',
      () {
        final builder = const SetTokenAccount(account, mint)
            .withAmount(2)
            .withoutDelegate()
            .withState('initialized')
            .withDelegatedAmount(1)
            .withoutCloseAuthority()
            .withTokenProgram(token2022ProgramAddress);

        expect(builder.method, 'surfnet_setTokenAccount');
        expect(builder.params, <Object?>[
          account.value,
          mint.value,
          <String, Object?>{
            'amount': 2,
            'delegate': 'null',
            'state': 'initialized',
            'delegatedAmount': 1,
            'closeAuthority': 'null',
          },
          token2022ProgramAddress.value,
        ]);
      },
    );

    test('SetTokenAccount sets authorities after clearing them', () {
      final builder = const SetTokenAccount(account, mint)
          .withoutDelegate()
          .withDelegate(owner)
          .withoutCloseAuthority()
          .withCloseAuthority(owner);

      expect(builder.params, <Object?>[
        account.value,
        mint.value,
        <String, Object?>{
          'delegate': owner.value,
          'closeAuthority': owner.value,
        },
      ]);
    });

    test('builders reject negative numeric fields', () {
      expect(
        () => SetAccount(account).withLamports(-1),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => SetAccount(account).withRentEpoch(-1),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => const SetTokenAccount(account, mint).withAmount(-1),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => const SetTokenAccount(account, mint).withDelegatedAmount(-1),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('ResetAccount omits options when unset', () {
      expect(const ResetAccount(account).params, <Object?>[account.value]);
      expect(
        const ResetAccount(account)
            .withIncludeOwnedAccounts(
              includeOwnedAccounts: true,
            )
            .params,
        <Object?>[
          account.value,
          <String, Object?>{'includeOwnedAccounts': true},
        ],
      );
    });

    test('StreamAccount omits options when unset', () {
      expect(const StreamAccount(account).params, <Object?>[account.value]);
      expect(
        const StreamAccount(account)
            .withIncludeOwnedAccounts(
              includeOwnedAccounts: false,
            )
            .params,
        <Object?>[
          account.value,
          <String, Object?>{'includeOwnedAccounts': false},
        ],
      );
    });
  });
}
